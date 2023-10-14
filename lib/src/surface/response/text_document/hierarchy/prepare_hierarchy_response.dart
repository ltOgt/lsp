// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';
import 'package:lsp/src/object/symbol_kind.dart';

import 'package:lsp/src/surface/param/file_range.dart';
import 'package:lsp/src/surface/response/base_response.dart';

/// The result of one of
/// - "textDocument/prepareCallHierarchy"
/// - "textDocument/prepareTypeHierarchy"
///
/// See [HierarchyItem] for details.
class PrepareHierarchyResponse extends BaseResponse {
  late final List<HierarchyItem> items;

  PrepareHierarchyResponse({
    required LspResponse response,
  }) : super(response: response) {
    items = response.results?.map(HierarchyItem.fromJson).toList() ?? [];
  }
}

/// An item of a hierarchy, for calls or types.
///
/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#callHierarchyItem
/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#typeHierarchyItem
class HierarchyItem {
  /// The name of this item.
  final String name;

  /// The kind of this item.
  final SymbolKind kind;

  /// Tags for this item.
  final List<SymbolTag>? tags;

  /// More detail for this item, e.g. the signature of a function.
  final String? detail;

  /// The resource identifier of this item.
  String get uri => _kUriPrefix + filePath;
  final String filePath;

  /// The range enclosing this symbol not including leading/trailing whitespace
  /// but everything else, e.g. comments and code.
  final FileRange range;

  /// The range that should be selected and revealed when this symbol is being
  /// picked, e.g. the name of a function. Must be contained by the
  /// [`range`](#CallHierarchyItem.range).
  final FileRange selectionRange;

  /// A data entry field that is preserved between a call hierarchy prepare and
  /// incoming calls or outgoing calls requests.
  final dynamic data;

  HierarchyItem({
    required this.name,
    required this.kind,
    required this.tags,
    required this.detail,
    required this.filePath,
    required this.range,
    required this.selectionRange,
    required this.data,
  });

  // ===========================================================================
  static const _kUriPrefix = "file://";
  static const _kName = "name";
  static const _kKind = "kind";
  static const _kTags = "tags";
  static const _kDetail = "detail";
  static const _kUri = "uri";
  static const _kRange = "range";
  static const _kSelectionRange = "selectionRange";
  static const _kData = "data";

  Map toJson() => json;
  Map get json => {
        _kName: name,
        _kKind: kind.value,
        if (tags != null) _kTags: tags!.map((e) => e.value),
        if (detail != null) _kDetail: detail,
        _kUri: uri,
        _kRange: range.json,
        _kSelectionRange: selectionRange.json,
        _kData: data,
      };

  static HierarchyItem fromJson(Map map) => HierarchyItem(
        name: map[_kName],
        kind: SymbolKind.fromValue(map[_kKind] as int),
        tags: _decodeTags(map),
        detail: map[_kDetail],
        filePath: (map[_kUri] as String).split(_kUriPrefix).last,
        range: FileRange.fromJson(map[_kRange] as Map<String, dynamic>),
        selectionRange: FileRange.fromJson(map[_kSelectionRange] as Map<String, dynamic>),
        data: map[_kData],
      );

  static List<SymbolTag>? _decodeTags(Map map) {
    final list = map[_kTags] as List?;
    if (list == null) return null;
    return list.cast<int>().map(SymbolTag.fromValue).toList();
  }

  // ===========================================================================

  @override
  bool operator ==(covariant HierarchyItem other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.name == name &&
        other.kind == kind &&
        listEquals(other.tags, tags) &&
        other.detail == detail &&
        other.filePath == filePath &&
        other.range == range &&
        other.selectionRange == selectionRange &&
        listEquals(other.data, data);
  }

  @override
  int get hashCode {
    final listHash = const DeepCollectionEquality().hash;

    return name.hashCode ^
        kind.hashCode ^
        listHash(tags) ^
        detail.hashCode ^
        filePath.hashCode ^
        range.hashCode ^
        selectionRange.hashCode ^
        listHash(data);
  }

  @override
  String toString() {
    return 'HierarchyItem(name: $name, kind: $kind, tags: $tags, detail: $detail, filePath: $filePath, range: $range, selectionRange: $selectionRange, data: $data)';
  }
}
