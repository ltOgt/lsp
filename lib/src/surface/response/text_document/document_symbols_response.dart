import 'package:lsp/src/object/symbol_information.dart';
import 'package:lsp/src/surface/response/base_response.dart';

/// The result of a "textDocument/documentSymbol" request.
///
/// See [SymbolInformation] for details.
class DocumentSymbolsResponse extends BaseResponse {
  late final List<SymbolInformation> symbols;

  DocumentSymbolsResponse({
    required LspResponse response,
  }) : super(response: response) {
    symbols = response.results!.map(SymbolInformation.fromJson).toList();
  }
}
