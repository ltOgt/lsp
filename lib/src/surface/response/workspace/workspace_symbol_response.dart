import 'package:lsp/src/object/symbol_information.dart';
import 'package:lsp/src/surface/response/base_response.dart';

/// The result of a "workspace/symbol" request.
///
/// See [Hover] for details.
class WorkspaceSymbolResponse extends BaseResponse {
  late final List<SymbolInformation>? symbols;

  WorkspaceSymbolResponse({
    required LspResponse response,
  }) : super(response: response) {
    symbols = response.results?.map(SymbolInformation.fromJson).toList() ?? [];
  }
}
