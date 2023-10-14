import 'package:lsp/src/object/folding_range.dart';
import 'package:lsp/src/surface/response/base_response.dart';

/// The result of a "textDocument/foldingRange" request.
///
/// See [FoldingRange] for details.
class DocumentFoldingRangeResponse extends BaseResponse {
  late final List<FoldingRange> ranges;

  DocumentFoldingRangeResponse({
    required LspResponse response,
  }) : super(response: response) {
    ranges = response.results!.map(FoldingRange.fromJson).toList();
  }
}
