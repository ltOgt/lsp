// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';

import 'package:lsp/src/object/symbol_kind.dart';
import 'package:lsp/src/surface/param/file_location.dart';

/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolInformation
class SymbolInformation {
  /// The name of this symbol.
  final String name;

  /// The kind of this symbol.
  final SymbolKind kind;

  /// Tags for this symbol.
  final List<SymbolTag>? tags;

  /// Indicates if this symbol is deprecated.
  final bool? deprecated;

  /// The location of this symbol. The location's range is used by a tool
  /// to reveal the location in the editor. If the symbol is selected in the
  /// tool the range's start information is used to position the cursor. So
  /// the range usually spans more then the actual symbol's name and does
  /// normally include things like visibility modifiers.
  ///
  /// The range doesn't have to denote a node range in the sense of an abstract
  /// syntax tree. It can therefore not be used to re-construct a hierarchy of
  /// the symbols.
  final FileLocation location;

  /// The name of the symbol containing this symbol. This information is for
  /// user interface purposes (e.g. to render a qualifier in the user interface
  /// if necessary). It can't be used to re-infer a hierarchy for the document
  /// symbols.
  final String? containerName;

  SymbolInformation({
    required this.name,
    required this.kind,
    required this.tags,
    required this.deprecated,
    required this.location,
    required this.containerName,
  });

  // ===========================================================================

  static const _kName = "name";
  static const _kKind = "kind";
  static const _kTags = "tags";
  static const _kDeprecated = "deprecated";
  static const _kLocation = "location";
  static const _kContainerName = "containerName";

  Map toJson() => json;
  Map get json => {
        _kName: name,
        _kKind: kind,
        if (tags != null) _kTags: tags,
        if (deprecated != null) _kDeprecated: deprecated,
        _kLocation: location,
        if (containerName != null) _kContainerName: containerName,
      };

  static SymbolInformation fromJson(Map map) => SymbolInformation(
        name: map[_kName],
        kind: SymbolKind.fromValue(map[_kKind]),
        tags: map[_kTags] == null ? null : (map[_kTags] as List).cast<int>().map(SymbolTag.fromValue).toList(),
        deprecated: map[_kDeprecated],
        location: FileLocation.fromJson(map[_kLocation]! as Map),
        containerName: map[_kContainerName],
      );

  // ===========================================================================

  @override
  bool operator ==(covariant SymbolInformation other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.name == name &&
        other.kind == kind &&
        listEquals(other.tags, tags) &&
        other.deprecated == deprecated &&
        other.location == location &&
        other.containerName == containerName;
  }

  @override
  int get hashCode {
    final listHash = const DeepCollectionEquality().hash;

    return name.hashCode ^
        kind.hashCode ^
        listHash(tags) ^
        deprecated.hashCode ^
        location.hashCode ^
        containerName.hashCode;
  }

  @override
  String toString() {
    return 'SymbolInformation(name: $name, kind: $kind, tags: $tags, deprecated: $deprecated, location: $location, containerName: $containerName)';
  }
}
