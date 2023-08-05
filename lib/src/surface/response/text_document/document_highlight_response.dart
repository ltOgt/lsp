// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:lsp/src/surface/param/range.dart';
import 'package:lsp/src/surface/response/base_response.dart';

/// The result of a "textDocument/documentHighlight" request.
///
/// See [DocumentHighlight] for details.
class DocumentHighlightResponse extends BaseResponse {
  late final List<DocumentHighlight> highlights;

  DocumentHighlightResponse({
    required LspResponse response,
  }) : super(response: response) {
    highlights = response.results?.map(DocumentHighlight.fromJson).toList() ?? [];
  }
}

/// A document highlight is a range inside a text document which deserves
/// special attention.
///
/// Usually a document highlight is visualized by changing
/// the background color of its range.
///
/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_documentHighlight
class DocumentHighlight {
  /// The range this highlight applies to.
  final Range range;

  /// The highlight kind.
  final DocumentHighlightKind? kind;

  DocumentHighlight({
    required this.range,
    required this.kind,
  });

  // ===========================================================================
  static const _kRange = "range";
  static const _kKind = "kind";

  Map toJson() => json;
  Map get json => {
        _kRange: range.json,
        _kKind: kind?.value ?? DocumentHighlightKind.text,
      };

  static DocumentHighlight fromJson(Map map) => DocumentHighlight(
        range: Range.fromJson(map[_kRange] as Map<String, dynamic>),
        kind: DocumentHighlightKind.fromValueOrNull(map[_kKind] as int?),
      );

  // ===========================================================================

  @override
  bool operator ==(covariant DocumentHighlight other) {
    if (identical(this, other)) return true;

    return other.range == range && other.kind == kind;
  }

  @override
  int get hashCode => range.hashCode ^ kind.hashCode;

  @override
  String toString() => 'DocumentHighlight(range: $range, kind: $kind)';
}

enum DocumentHighlightKind {
  /// A textual occurrence.
  text(1),

  /// Read-access of a symbol, like reading a variable.
  read(2),

  /// Write-access of a symbol, like writing to a variable.
  write(3);

  const DocumentHighlightKind(this.value);
  final int value;

  static DocumentHighlightKind? fromValueOrNull(int? value) => value == null //
      ? null
      : DocumentHighlightKind.values[value - 1];
}
