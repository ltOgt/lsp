import 'package:lsp/src/surface/lsp_surface.dart';

/// Wrapper around [LspResponse] that can be extended to provide extractors for specifc response types
abstract class BaseResponse {
  final LspResponse response;

  BaseResponse({required this.response});

  /// The id that was used at the time of the request
  LspRequestId get id => response.id;

  /// The version of jsonrpc
  String get jsonrpc => response.jsonrpc;

  /// Some responses contain only one result
  /// XOR [results]
  Map? get result => response.result;

  /// Some responses contain a list of results
  /// XOR [result]
  List<Map>? get results => response.results;

  /// Errors returned by the LSP
  Map? get error => response.error;

  bool get isError => response.isError;
}

/// Wrapper for the raw response by the LSP server.
/// Used by [LspSurface].
class LspResponse {
  /// The id that was used at the time of the request
  final LspRequestId id;

  /// The version of jsonrpc
  final String jsonrpc;

  /// Some responses contain only one result
  /// XOR [results]
  late final Map? result;

  /// Some responses contain a list of results
  /// XOR [result]
  late final List<Map>? results;

  /// Errors returned by the LSP
  late final Map? error;

  bool get isError => error != null;

  LspResponse._({
    required this.id,
    required this.jsonrpc,
    required Map? result,
    required this.results,
    required this.error,
  }) {
    // result might be null for notification responses such as to "initialized"
    if (error == null && result == null && results == null) {
      this.result = {};
    } else {
      this.result = result;
    }
  }

  /// Used to decode the raw json returned from the LSP inside [LspSurface]
  static LspResponse fromMap(Map response) {
    dynamic _result = response["result"];
    Map? __result;
    List<Map>? __results;
    if (_result != null) {
      if (_result is List) {
        __results = _result.cast();
      } else if (_result is Map) {
        __result = _result;
      } else {
        throw "Unexpected type for result: ${_result.runtimeType}";
      }
    }

    return LspResponse._(
      id: response["id"],
      jsonrpc: response["jsonrpc"],
      result: __result,
      results: __results,
      error: response["error"],
    );
  }
}
