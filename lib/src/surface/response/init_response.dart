import 'package:lsp/src/object/server_info.dart';
import 'package:lsp/src/surface/response/base_response.dart';

class InitResponse extends BaseResponse {
  InitResponse({
    required LspResponse response,
  }) : super(response: response);

  late final Map capabilities = result!["capabilities"]!;
  late final ServerInfo? serverInfo = ServerInfo.fromJson(result!["serverInfo"]);
  late final Map _semanticTokensProvider = capabilities["semanticTokensProvider"]!;
  late final Map _semanticTokensLegend = _semanticTokensProvider["legend"]!;
  late final List<String> semanticTokenTypes = (_semanticTokensLegend["tokenTypes"]! as List<dynamic>).cast();
  late final List<String> semanticTokenModifiers = (_semanticTokensLegend["tokenModifiers"]! as List<dynamic>).cast();
}
