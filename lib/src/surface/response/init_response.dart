import 'package:lsp/src/surface/response/base_response.dart';

class InitResponse extends BaseResponse {
  InitResponse({
    required LspResponse response,
  }) : super(response: response);

  Map get _capabilities => result!["capabilities"]!;
  Map get _semanticTokensProvider => _capabilities["semanticTokensProvider"]!;
  Map get _semanticTokensLegend => _semanticTokensProvider["legend"]!;
  List<String> get semanticTokenTypes => (_semanticTokensLegend["tokenTypes"]! as List<dynamic>).cast();
  List<String> get semanticTokenModifiers => (_semanticTokensLegend["tokenModifiers"]! as List<dynamic>).cast();
}
