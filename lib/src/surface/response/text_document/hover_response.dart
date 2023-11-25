import 'package:lsp/src/object/markup_content.dart';
import 'package:lsp/src/surface/param/file_range.dart';
import 'package:lsp/src/surface/response/base_response.dart';

/// The result of a "textDocument/hover" request.
///
/// See [Hover] for details.
class HoverResponse extends BaseResponse {
  late final Hover? hover;

  MarkupContent? get contents => hover?.contents;
  FileRange? get range => hover?.range;

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
  final MarkupContent contents;

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

  static Hover? fromJson(Map map) {
    if (map.isEmpty) return null;

    return Hover(
      contents: MarkupContent.fromJson(map[_kContents] as dynamic),
      range: FileRange.fromJson(map[_kRange] as Map<String, dynamic>),
    );
  }

  // ===========================================================================

  @override
  bool operator ==(covariant Hover other) {
    if (identical(this, other)) return true;

    return other.contents == contents && other.range == range;
  }

  @override
  int get hashCode => contents.hashCode ^ range.hashCode;
}

// /// MarkedString | MarkedString[] | MarkupContent
// ///
// /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#hover
// class HoverContents {
//   final MarkupContent? markedString;
//   final List<MarkupContent>? markedStrings;
//   final String? markupContent;

//   HoverContents({
//     this.markedString,
//     this.markedStrings,
//     this.markupContent,
//   }) : assert(
//           ((markedString != null) != (markedStrings != null)) != (markupContent != null),
//           "Provide exactly one",
//         );

//   // ===========================================================================

//   static HoverContents fromJson(dynamic value) {
//     return switch (value) {
//       String() => HoverContents(markupContent: value),
//       Map() => HoverContents(markedString: MarkupContent.fromJson(value)),
//       List<Map>() => HoverContents(markedStrings: value.map(MarkupContent.fromJson).toList()),
//       _ => throw StateError("Unsupported type for Hover Contents"),
//     };
//   }

//   // ===========================================================================

//   @override
//   bool operator ==(covariant HoverContents other) {
//     if (identical(this, other)) return true;
//     final listEquals = const DeepCollectionEquality().equals;

//     return other.markedString == markedString &&
//         listEquals(other.markedStrings, markedStrings) &&
//         other.markupContent == markupContent;
//   }

//   @override
//   int get hashCode {
//     final listHash = const DeepCollectionEquality().hash;
//     return markedString.hashCode ^ listHash(markedStrings) ^ markupContent.hashCode;
//   }
// }
