// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:io';

import 'package:lsp/lsp.dart';
import 'package:lsp/src/object/server_capabilities.dart';
import 'package:lsp/src/object/server_info.dart';
import 'package:lsp/src/surface/response/base_response.dart';
import 'package:lsp/src/surface/response/text_document/dart/dart_outline_response.dart';
import 'package:lsp/src/surface/response/text_document/document_folding_range_response.dart';
import 'package:lsp/src/surface/response/text_document/document_symbols_response.dart';
import 'package:lsp/src/surface/response/workspace/workspace_symbol_response.dart';
import 'package:lsp/src/surface/unsupported_method_exception.dart';
import 'package:lsp/src/surface/wireformat.dart';

/// ID to match request to respnse.
/// This is needed since request <i> may take longer than <i+1>
typedef LspRequestId = int;

/// Callback for messages from the Language Server that are
/// no a response to a request.
typedef MessageCallback = void Function(Map onResponseMessage);

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

  late final ServerCapabilities capabilities;
  late final ServerInfo? serverInfo;

  /// Root path for the project that should be analyzed
  //. Not really needed after [start], but can be exposed to consumers
  late final String rootPath;

  final MessageCallback? onMessage;

  final StreamController<Map> internalMessageStream;

  final Map initializationOptions;

  LspSurface._({
    required this.lspConnector,
    required this.lspProcess,
    required _RequestCompleter requestCompleter,
    required this.onMessage,
    required this.internalMessageStream,
    required this.initializationOptions,
  }) : _requestCompleter = requestCompleter;

  /// Launch the Connection handler.
  /// DONT FORGET TO CALL [dispose] when done.
  ///
  /// Throws [LspInitializationException] on failed initialziation.
  static Future<LspSurface> start({
    required LspConnectorBase lspConnector,
    required String rootPath,
    required Map clientCapabilities,
    Map initializationOptions = const {},
    MessageCallback? onMessage,
  }) async {
    // Start process
    final process = await lspConnector.startProcess();

    // to listen to messages from the server internally
    final internalMessageStream = StreamController<Map>.broadcast();

    // Setup request => response completer
    final requestCompleter = _RequestCompleter(
      process: process,
      onMessage: onMessage,
      internalMessageStream: internalMessageStream,
    );

    // Create object
    final lsm = LspSurface._(
      lspConnector: lspConnector,
      lspProcess: process,
      requestCompleter: requestCompleter,
      onMessage: onMessage,
      internalMessageStream: internalMessageStream,
      initializationOptions: initializationOptions,
    );

    // Initialized LSP handshake
    final r1 = await lsm._initializeConnection(
      rootPath: rootPath,
      clientCapabilities: clientCapabilities,
      initializationOptions: initializationOptions,
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

    // Store server info
    lsm.capabilities = r1.capabilities;
    lsm.serverInfo = r1.serverInfo;
    lsm.semanticTokenLegend = SemanticTokenLegend(
      tokenTypes: r1.semanticTokenTypes,
      tokenModifiers: r1.semanticTokenModifiers,
    );

    // Store root path as a nice to have
    lsm.rootPath = rootPath;

    return lsm;
  }

  bool dispose() {
    internalMessageStream.close();
    return lspProcess.kill();
  }

  // ====================================================================
  /// Initialize the connection between Client and LSP Server
  ///
  /// See: https://microsoft.github.io/language-server-protocol/specification#initialize
  Future<InitResponse> _initializeConnection({
    required String rootPath,
    Map clientCapabilities = const {},
    Map initializationOptions = const {},
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
      "initializationOptions": initializationOptions,
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
  /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_didOpen
  Future<LspResponse> textDocument_didOpen({required String filePath, required String fileContent}) async {
    var params = {
      "textDocument": {
        "uri": "file://$filePath",
        "languageId": "dart",
        "version": 1,
        "text": fileContent,
      },
    };

    final res = await _requestCompleter.sendRequest("textDocument/didOpen", params);
    return res;
  }

  /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_didClose
  Future<LspResponse> textDocument_didClose(TextDocumentIdentifier textDocumentIdentifier) async {
    var params = {
      "textDocument": textDocumentIdentifier,
    };

    final res = await _requestCompleter.sendRequest("textDocument/didClose", params);
    return res;
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
  /// https://microsoft.github.io/language-server-protocol/specification#textDocument_definition
  /// https://microsoft.github.io/language-server-protocol/specification#textDocumentPositionParams
  Future<LocationsResponse> textDocument_definition(TextDocumentPositionParams params) async {
    const _method = "textDocument/definition";
    if (!capabilities.definitionProvider) throw UnsupportedMethodException(_method);

    final res = await _requestCompleter.sendRequest(_method, params.json);
    return LocationsResponse(response: res);
  }

  /// Request the location of all project-wide references of the symbol under the cursor.
  ///
  /// https://microsoft.github.io/language-server-protocol/specification#textDocument_references
  /// https://microsoft.github.io/language-server-protocol/specification#textDocumentPositionParams
  Future<LocationsResponse> textDocument_references(ReferenceParams params) async {
    const _method = "textDocument/references";
    if (!capabilities.referenceProvider) throw UnsupportedMethodException(_method);

    final res = await _requestCompleter.sendRequest(_method, params.json);
    return LocationsResponse(response: res);
  }

  /// Request the location of the implementation of a symbol at a given text document position.
  ///
  /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_implementation
  Future<LocationsResponse> textDocument_implementation(TextDocumentPositionParams params) async {
    const _method = "textDocument/implementation";
    if (!capabilities.implementationProvider) throw UnsupportedMethodException(_method);

    final res = await _requestCompleter.sendRequest(_method, params.json);
    return LocationsResponse(response: res);
  }

  /// Request a list of all symbols for a given [TextDocumentIdentifier].
  ///
  /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_documentSymbol
  Future<DocumentSymbolsResponse> textDocument_documentSymbol(TextDocumentIdentifier textDocumentIdentifier) async {
    const _method = "textDocument/documentSymbol";
    if (!capabilities.documentSymbolProvider) throw UnsupportedMethodException(_method);

    final res = await _requestCompleter.sendRequest(_method, {
      "textDocument": textDocumentIdentifier.json,
    });

    return DocumentSymbolsResponse(response: res);
  }

  /// Request a list of all folding ranges for a given [TextDocumentIdentifier].
  ///
  /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_foldingRange
  Future<DocumentFoldingRangeResponse> textDocument_foldingRange(TextDocumentIdentifier textDocumentIdentifier) async {
    const _method = "textDocument/foldingRange";
    if (!capabilities.foldingRangeProvider) throw UnsupportedMethodException(_method);

    final res = await _requestCompleter.sendRequest(_method, {
      "textDocument": textDocumentIdentifier.json,
    });

    return DocumentFoldingRangeResponse(response: res);
  }

  /// Request hover information at a given text document position.
  ///
  /// The hover information may e.g. be the doc string of the symbol as Markdown.
  ///
  /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_hover
  Future<HoverResponse> textDocument_hover(TextDocumentPositionParams params) async {
    const _method = "textDocument/hover";
    if (!capabilities.hoverProvider) throw UnsupportedMethodException(_method);

    final res = await _requestCompleter.sendRequest(_method, params.json);
    return HoverResponse(response: res);
  }

  /// Request highlight information at a given text document position.
  ///
  /// Usually highlights all references to the symbol scoped to this file.
  ///
  /// As opposed to [textDocument_references], which is across all files.
  ///
  /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_documentHighlight
  Future<DocumentHighlightResponse> textDocument_documentHighlight(TextDocumentPositionParams params) async {
    const _method = "textDocument/documentHighlight";
    if (!capabilities.documentHighlightProvider) throw UnsupportedMethodException(_method);

    final res = await _requestCompleter.sendRequest(_method, params.json);
    return DocumentHighlightResponse(response: res);
  }

  /// Request a call hierarchy for the language element of given text document position.
  ///
  /// This is the first step, which resolves a hierarchy item
  ///
  /// Follow up with
  /// - [callHierarchy_incomingCalls]
  /// - [callHierarchy_outgoingCalls]
  ///
  /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_prepareCallHierarchy
  Future<PrepareHierarchyResponse> textDocument_prepareCallHierarchy(TextDocumentPositionParams params) async {
    const _method = "textDocument/prepareCallHierarchy";
    if (!capabilities.callHierarchyProvider) throw UnsupportedMethodException(_method);

    final res = await _requestCompleter.sendRequest(_method, params.json);
    return PrepareHierarchyResponse(response: res);
  }

  /// Request to resolve incoming calls for a given call hierarchy item.
  ///
  /// This is the second step, i.e. follow up for
  /// - [textDocument_prepareCallHierarchy]
  ///
  /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#callHierarchy_incomingCalls
  Future<IncomingCallResponse> callHierarchy_incomingCalls(HierarchyItem item) async {
    const _method = "callHierarchy/incomingCalls";
    if (!capabilities.callHierarchyProvider) throw UnsupportedMethodException(_method);

    final params = {
      "item": item.json,
    };

    final res = await _requestCompleter.sendRequest(_method, params);
    return IncomingCallResponse(response: res, to: item);
  }

  /// Request to resolve outgoing calls for a given call hierarchy item.
  ///
  /// This is the second step, i.e. follow up for
  /// - [textDocument_prepareCallHierarchy]
  ///
  /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#callHierarchy_outgoingCalls
  Future<OutgoingCallResponse> callHierarchy_outgoingCalls(HierarchyItem item) async {
    const _method = "callHierarchy/outgoingCalls";
    if (!capabilities.callHierarchyProvider) throw UnsupportedMethodException(_method);

    final params = {
      "item": item.json,
    };

    final res = await _requestCompleter.sendRequest(_method, params);
    return OutgoingCallResponse(response: res, from: item);
  }

  /// Request a type hierarchy for the language element of given text document position.
  ///
  /// This is the first step, which resolves a hierarchy item
  ///
  /// Follow up with
  /// - [typeHierarchy_superTypes]
  /// - [typeHierarchy_subTypes]
  ///
  /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_prepareTypeHierarchy
  Future<PrepareHierarchyResponse> textDocument_prepareTypeHierarchy(TextDocumentPositionParams params) async {
    const _method = "textDocument/prepareTypeHierarchy";
    if (!capabilities.typeHierarchyProvider) throw UnsupportedMethodException(_method);

    final res = await _requestCompleter.sendRequest(_method, params.json);
    return PrepareHierarchyResponse(response: res);
  }

  /// Request to resolve super types for a given call hierarchy [item].
  ///
  /// This is the second step, i.e. follow up for
  /// - [textDocument_prepareTypeHierarchy]
  ///
  /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#typeHierarchy_supertypes
  Future<HierarchyItemsResponse> typeHierarchy_superTypes(HierarchyItem item) async {
    const _method = "typeHierarchy/supertypes";
    if (!capabilities.typeHierarchyProvider) throw UnsupportedMethodException(_method);

    final params = {
      "item": item.json,
    };

    final res = await _requestCompleter.sendRequest(_method, params);
    return HierarchyItemsResponse(
      response: res,
      from: item,
      kind: HierarchyItemsResponseKind.superType,
    );
  }

  /// Request to resolve sub types for a given call hierarchy [item].
  ///
  /// This is the second step, i.e. follow up for
  /// - [textDocument_prepareTypeHierarchy]
  ///
  /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#typeHierarchy_subtypes
  Future<HierarchyItemsResponse> typeHierarchy_subTypes(HierarchyItem item) async {
    const _method = "typeHierarchy/subtypes";
    if (!capabilities.typeHierarchyProvider) throw UnsupportedMethodException(_method);

    final params = {
      "item": item.json,
    };

    final res = await _requestCompleter.sendRequest(_method, params);
    return HierarchyItemsResponse(
      response: res,
      from: item,
      kind: HierarchyItemsResponseKind.subType,
    );
  }

  /// Request to list project-wide symbols matching the query string.
  ///
  /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workspace_symbol
  Future<WorkspaceSymbolResponse> workspace_symbol(String query) async {
    const _method = "workspace/symbol";
    if (!capabilities.workspaceSymbolProvider) throw UnsupportedMethodException(_method);

    final params = {
      "query": query,
    };

    final res = await _requestCompleter.sendRequest(_method, params);
    return WorkspaceSymbolResponse(response: res);
  }

  // ====================================================================
  // ====================================================================
  // ====================================================================
  // ====================================================================
  // ====================================================================

  /// Dart-Analysis-Server implements the old non-nested and information-poor
  /// version of [textDocument_documentSymbol].
  ///
  /// It does however implement its own notification that returns a nested,
  /// information-rich outline.
  ///
  /// See https://github.com/dart-lang/sdk/blob/main/pkg/analysis_server/tool/lsp_spec/README.md
  Future<DartOutlineNotification> dart_textDocument_outline({
    required String filePath,
    required String fileContent,
  }) async {
    const _method = "dart/textDocument/publishOutline";
    if (!initializationOptions.containsKey("outline")) {
      throw UnsupportedMethodException(_method);
    }

    final textDocumentIdentifier = TextDocumentIdentifier(filePath);

    final outlineFuture = internalMessageStream.stream.firstWhere(
      (msg) {
        bool matchMethod = msg["method"] == _method;
        bool matchUri = msg["params"]["uri"] == textDocumentIdentifier.uri;

        // print("outline listener: $msg");
        // print("matchMethod: $matchMethod");
        // print("matchUri: $matchUri");
        return matchMethod && matchUri;
      },
    );

    // the file has to be opened for the dart server to send outline messages
    final r = await textDocument_didOpen(filePath: filePath, fileContent: fileContent);
    if (r.isError) throw r.error!;

    // need any interaction with the open document to trigger the outline message
    // this is undocumented, but I found this by trial and error and looking at
    // the logs from vscode talking to dart LSP
    final _ = await textDocument_hover(
      TextDocumentPositionParams(
        textDocument: textDocumentIdentifier,
        position: FilePosition(line: 0, character: 0),
      ),
    );

    // wait for the message
    final outline = await outlineFuture;

    // close the file again
    await textDocument_didClose(TextDocumentIdentifier(filePath));

    return DartOutlineNotification.fromJson(outline);
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

  // ===========================================================================

  late final IOSink lspProcessStdin;

  /// For non response messages
  final MessageCallback? onMessage;

  final StreamController<Map> internalMessageStream;

  // ===========================================================================

  _RequestCompleter({
    required Process process,
    required this.onMessage,
    required this.internalMessageStream,
  }) {
    /// Bind stdin / std out of process
    lspChannel(process.stdout, process.stdin).stream.listen(
          _handleResponse,
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
    //print("[$pid] <$_currentId> sending: $method");

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
    const String kDelim = "\r\n";
    String header = "Content-Length: ${contentUTF8.lengthInBytes}" + kDelim + kDelim;
    Uint8List headerASCII = _encoderASCII.convert(header);

    // Send message
    lspProcessStdin.add(headerASCII + contentUTF8);
    assert(() {
      log("REQ<$_currentId>:$contentJSON");
      return true;
    }());

    /// Create a completer and listen to stdout to complete once a response arives
    final completer = Completer<LspResponse>();
    _responses[_currentId] = completer;

    _currentId += 1;
    return completer.future;
  }

  // ===========================================================================
  _handleResponse(String response) {
    final json = jsonDecode(response);

    if (!json.containsKey("id") || json.containsKey("method")) {
      // § {"method":"$/analyzerStatus","params":{"isAnalyzing":true},"jsonrpc":"2.0"}
      // § {"jsonrpc":"2.0","method":"textDocument/publishDiagnostics","params":{"diagnostics"...
      onMessage?.call(json);
      internalMessageStream.add(json);

      assert(() {
        log("MSG:$json");
        return true;
      }());
    } else {
      int requestID = json["id"];
      if (_responses.containsKey(requestID)) {
        _responses[requestID]!.complete(LspResponse.fromMap(json));
        _responses.remove(requestID);
        assert(() {
          log("RES:$json");
          return true;
        }());
      } else {
        throw ("Received Response for Request that does not exist or has already completed: $requestID");
      }
    }
  }

  _handleError(List<int> response) {
    String r = _decoderUTF8.convert(response);
    print("LSP ERROR: $r");
  }
}
