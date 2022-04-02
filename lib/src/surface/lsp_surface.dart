// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:lsp/lsp.dart';
import 'dart:io';

import 'package:lsp/src/surface/response/base_response.dart';

/// ID to match request to respnse.
/// This is needed since request <i> may take longer than <i+1>
typedef LspRequestId = int;

class LspInitializationException implements Exception {}

class LspSurface {
  /// Language Specific LSP Process Starter
  final LspConnectorBase lspConnector;

  /// The acrual process started by [lspConnector].
  final Process lspProcess;

  /// Abstraction around communication with the [lspProcess].
  /// Handles encoding and sending of request, and receiving and decoding of responses.
  /// Also async matches requests and responses via their id.
  final _RequestCompleter _requestCompleter;

  /// Legend provided during lsp initialization.
  /// Needed to resolve eventual [SemanticToken]s, which contain only indexes to this legend.
  late final SemanticTokenLegend semanticTokenLegend;

  LspSurface._({
    required this.lspConnector,
    required this.lspProcess,
    required _RequestCompleter requestCompleter,
  }) : _requestCompleter = requestCompleter;

  /// Launch the Connection handler.
  /// DONT FORGET TO CALL [dispose] when done.
  ///
  /// Throws [LspInitializationException] on failed initialziation.
  static Future<LspSurface> start({
    required LspConnectorBase lspConnector,
    required String rootPath,
    required Map clientCapabilities,
  }) async {
    // Start process
    final process = await lspConnector.startProcess();

    // Setup request => response completer
    final requestCompleter = _RequestCompleter(process: process);

    // Create object
    final lsm = LspSurface._(
      lspConnector: lspConnector,
      lspProcess: process,
      requestCompleter: requestCompleter,
    );

    // Initialized LSP handshake
    final r1 = await lsm._initializeConnection(
      rootPath: rootPath,
      clientCapabilities: clientCapabilities,
      clientId: lspConnector.clientId,
      clientVersion: lspConnector.clientVersion,
    );
    if (r1.isError) {
      throw LspInitializationException();
    }

    // Confirm Handshake
    final r2 = await lsm._initializedConfirm();
    if (r2.isError) {
      throw LspInitializationException();
    }

    // Store semantic token infos
    lsm.semanticTokenLegend = SemanticTokenLegend(
      tokenTypes: r1.semanticTokenTypes,
      tokenModifiers: r1.semanticTokenModifiers,
    );

    return lsm;
  }

  bool dispose() => lspProcess.kill();

  // ====================================================================
  /// Initialize the connection between Client and LSP Server
  ///
  /// See: https://microsoft.github.io/language-server-protocol/specification#initialize
  Future<InitResponse> _initializeConnection({
    required String rootPath,
    Map clientCapabilities = const {},
    required String clientId,
    required String clientVersion,
  }) async {
    var clientInfo = {
      "name": clientId,
      "version": clientVersion,
    };
    var initializeParams = {
      "processId": null,
      "clientInfo": clientInfo,
      "capabilities": clientCapabilities,
      // ? deprecated according to spec, but must be provided anyway
      "rootUri": "file://" + rootPath,
    };

    return InitResponse(
      response: await _requestCompleter.sendRequest("initialize", initializeParams),
    );
  }

  /// Send by the client after [initializeConnection] to confirm initialization.
  ///
  /// Must be send after [initializeConnection] and before any other request
  /// Must be called only once.
  ///
  /// https://microsoft.github.io/language-server-protocol/specification#initialized
  Future<LspResponse> _initializedConfirm() {
    return _requestCompleter.sendRequest("initialized", {});
  }

  // ====================================================================
  /// Get [SemanticTokenType]s and [SemanticTokenModifier]s for the whole file at [filePath].
  /// Use [SemanticTokenDecoder] to decode the [SemanticTokenFullResponse.data].
  ///
  /// https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#semanticTokens_fullRequest
  Future<SemanticTokenFullResponse> textDocument_semanticTokens_full({required String filePath}) async {
    var textDocumentIdentifier = {
      "uri": "file://" + filePath,
    };
    var semanticTokenParams = {
      "textDocument": textDocumentIdentifier,
    };

    final res = await _requestCompleter.sendRequest("textDocument/semanticTokens/full", semanticTokenParams);
    return SemanticTokenFullResponse(response: res);
  }

  /// Request the location of the definition of the symbol under the cursor.
  ///
  /// [filePath] points to the source file.
  /// [line] is a zero based offset for the line the cursor is in (first line ^= 0)
  /// [character] is a zero based offset for the cursor inside the line (before first character ^= 0)
  ///
  /// https://microsoft.github.io/language-server-protocol/specification#textDocument_definition
  /// https://microsoft.github.io/language-server-protocol/specification#textDocumentPositionParams
  Future<DefinitionResponse> textDocument_definition({
    required String filePath,
    required int line,
    required int character,
  }) async {
    var position = {
      "line": line,
      "character": character,
    };
    var textDocumentIdentifier = {
      "uri": "file://" + filePath,
    };
    var textDocumentPositionParams = {
      "textDocument": textDocumentIdentifier,
      "position": position,
    };

    final res = await _requestCompleter.sendRequest("textDocument/definition", textDocumentPositionParams);
    return DefinitionResponse(response: res);
  }

  /// Request the location of all project-wide references of the symbol under the cursor.
  ///
  /// [filePath] points to the source file.
  /// [line] is a zero based offset for the line the cursor is in (first line ^= 0)
  /// [character] is a zero based offset for the cursor inside the line (before first character ^= 0)
  /// [includeDeclaration] toggles whether the declaration of the requested symbol should be included in the results.
  ///
  /// https://microsoft.github.io/language-server-protocol/specification#textDocument_references
  /// https://microsoft.github.io/language-server-protocol/specification#textDocumentPositionParams
  Future<ReferenceResponse> textDocument_references({
    required String filePath,
    required int line,
    required int character,
    required bool includeDeclaration,
  }) async {
    var position = {
      "line": line,
      "character": character,
    };
    var textDocumentIdentifier = {
      "uri": "file://" + filePath,
    };
    var referenceContext = {
      "includeDeclaration": includeDeclaration,
    };
    var referenceParams = {
      "textDocument": textDocumentIdentifier,
      "position": position,
      "context": referenceContext,
    };

    final res = await _requestCompleter.sendRequest("textDocument/references", referenceParams);
    return ReferenceResponse(response: res);
  }
}

// =============================================================================
// =============================================================================
// =============================================================================
/// Handles sending of requests and receiving of responses for [LspSurface]
class _RequestCompleter {
  static const JsonEncoder _encoderJSON = JsonEncoder();
  static const Utf8Encoder _encoderUTF8 = Utf8Encoder();
  static const AsciiEncoder _encoderASCII = AsciiEncoder();
  static const Utf8Decoder _decoderUTF8 = Utf8Decoder();
  static const JsonDecoder _decoderJSON = JsonDecoder();

  // ===========================================================================

  late final IOSink lspProcessStdin;

  // ===========================================================================

  _RequestCompleter({required Process process}) {
    /// Bind stdin / std out of process
    process.stdout.listen(
      _handleResponse,
      onDone: () => print("StdOut done"),
      onError: (e) => print("StdOut error <$e>"),
      cancelOnError: false,
    );
    process.stderr.listen(
      _handleError,
      cancelOnError: false,
    );

    /// Store reference to stdin to be used in [sendRequest]
    lspProcessStdin = process.stdin;
  }

  // ===========================================================================

  /// [Completer]s created for each request that is send to the LSP [lspProcess]
  /// Will be resolved once the response with the same [LspRequestId] arrives.
  final Map<LspRequestId, Completer<LspResponse>> _responses = {};

  /// The very first ID that is used by [LspSurface._initializeConnection].
  static const LspRequestId _FIRST_ID = 1;

  /// Keeps track of the current ID to be used for the next request.
  LspRequestId _currentId = _FIRST_ID;

  // ===========================================================================

  /// Sends a request to the Server
  ///
  /// [method] is the remote procedure to call
  /// [params] is the map of parameters required by [method]
  ///
  /// Returns a Future that will complete once the matching response arrives.
  Future<LspResponse> sendRequest(String method, Map params) {
    print("[$pid] <$_currentId> sending: $method");

    var content = {
      "jsonrpc": "2.0",
      "id": _currentId,
      "method": method,
      "params": params,
    };

    String contentJSON = _encoderJSON.convert(content);
    Uint8List contentUTF8 = _encoderUTF8.convert(contentJSON);

    /**
      https://microsoft.github.io/language-server-protocol/specification#headerPart

      HEADER IS ENCODED ASCII
      CONTENT IS ENCODED UTF-8

      Each line of header ends with \r\n and header ends with \r\n
    */
    const String DELIM = "\r\n";
    String header = "Content-Length: ${contentUTF8.lengthInBytes}" + DELIM + DELIM;
    Uint8List headerASCII = _encoderASCII.convert(header);

    // Send message
    lspProcessStdin.add(headerASCII + contentUTF8);

    /// Create a completer and listen to stdout to complete once a response arives
    final completer = Completer<LspResponse>();
    _responses[_currentId] = completer;

    _currentId += 1;
    return completer.future;
  }

  // ===========================================================================

  _handleResponse(List<int> response) {
    String r = _decoderUTF8.convert(response);

    // Get response
    List<Map> jsons = _extractJson(r);
    for (Map json in jsons) {
      if (false == json.containsKey("id")) {
        // Skip other messages for now
        // § "{"method":"$/analyzerStatus","params":{"isAnalyzing":true},"jsonrpc":"2.0"}"
      } else {
        int requestID = json["id"];
        if (_responses.containsKey(requestID)) {
          _responses[requestID]!.complete(LspResponse.fromMap(json));
          _responses.remove(requestID);
        } else {
          throw ("Received Response for Request that does not exist or has already completed: $requestID");
        }
      }
    }
  }

  _handleError(List<int> response) {
    String r = _decoderUTF8.convert(response);
    print("LSP ERROR: $r");
  }

  /// STDOUT can contain the following messages
  ///
  /// (1)
  /// ```
  /// {<message>}
  /// ```
  ///
  /// (2)
  /// ```
  /// Content-Length: <bytes>
  /// Content-Type: application/vscode-jsonrpc; charset=utf-8
  /// ```
  ///
  /// (3)
  /// ```
  /// Content-Length: <bytes>
  /// Content-Type: application/vscode-jsonrpc; charset=utf-8
  ///
  /// {<message>}Content-Length: <bytes>
  /// Content-Type: application/vscode-jsonrpc; charset=utf-8
  ///
  /// {<message>}Content-Length: <bytes>
  /// Content-Type: application/vscode-jsonrpc; charset=utf-8
  ///
  /// ...
  /// {<message>}
  /// ```
  ///
  /// (1) should return `[Map]`
  /// (2) should return `[]`
  /// (3) should return `[Map, Map, ..., Map]`
  List<Map> _extractJson(String potentialMessages) {
    List<Map> r = [];
    try {
      for (String line in potentialMessages.split("\n")) {
        int first = line.indexOf("{");
        int last = line.lastIndexOf("}") + 1;
        if (first > -1 && last > -1) {
          r.add(_decoderJSON.convert(
            line.substring(first, last),
          ));
        }
      }
    } catch (e) {
      print("Catastrophic failure during _extractJson: $e");
    }

    return r;
  }
}
