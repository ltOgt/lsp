import 'package:lsp/src/semantics/token_decoder.dart';
import 'package:lsp/src/surface/response/base_response.dart';

class SemanticTokenFullResponse extends BaseResponse {
  SemanticTokenFullResponse({
    required LspResponse response,
  }) : super(response: response);

  /// Use [SemanticTokenDecoder] to decode.
  List<int> get data => (response.result!["data"]! as List<dynamic>).cast();
}
