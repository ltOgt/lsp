import 'package:lsp/src/surface/response/base_response.dart';

class InitResponse extends BaseResponse {
  InitResponse({
    required LspResponse response,
  }) : super(response: response);

  Map get capabilities => result!["capabilities"]!;
  Map get semanticTokensProvider => capabilities["semanticTokensProvider"]!;
  Map get semanticTokensLegend => semanticTokensProvider["legend"]!;
  List<String> get semanticTokenTypes => (semanticTokensLegend["tokenTypes"]! as List<dynamic>).cast();
  List<String> get semanticTokenModifiers => (semanticTokensLegend["tokenModifiers"]! as List<dynamic>).cast();
}
