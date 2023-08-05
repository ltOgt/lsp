import 'package:lsp/src/surface/param/file_range.dart';
import 'package:lsp/src/surface/response/base_response.dart';

/// The result of a "textDocument/hover" request.
///
/// See [Hover] for details.
class HoverResponse extends BaseResponse {
  late final Hover hover;

  String get contents => hover.contents;
  FileRange? get range => hover.range;

  HoverResponse({
    required LspResponse response,
  }) : super(response: response) {
    hover = Hover.fromJson(response.result!);
  }
}

/// The result of a "textDocument/hover" request.
///
/// [contents] may e.g. be the docstring of a symbol
///
/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#hover
class Hover {
  final String contents;

  /// An optional range is a range inside a text document
  /// that is used to visualize a hover, e.g. by changing the background color.
  final FileRange? range;

  Hover({
    required this.contents,
    required this.range,
  });

  // ===========================================================================
  static const _kContents = "contents";
  static const _kRange = "range";

  Map toJson() => json;
  Map get json => {
        _kContents: contents,
        if (range != null) _kRange: range!.json,
      };

  static Hover fromJson(Map map) => Hover(
        contents: map[_kContents],
        range: FileRange.fromJson(map[_kRange] as Map<String, dynamic>),
      );
}
