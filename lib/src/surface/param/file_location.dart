// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:lsp/src/surface/param/range.dart';

/// Represents a location inside a resource, such as a line inside a text file.
///
/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#location
class FileLocation {
  final Range range;

  final String filePath;
  String get uri => _kUriPrefix + filePath;

  FileLocation({
    required this.range,
    required this.filePath,
  });

  /// ==========================================================================
  static const _kUri = "uri";
  static const _kUriPrefix = "file://";
  static const _kRange = "range";

  Map toJson() => json;
  Map get json => {
        _kUri: uri,
        _kRange: range.json,
      };

  static FileLocation fromJson(Map map) => FileLocation(
        range: Range.fromJson(map[_kRange] as Map<String, dynamic>),
        filePath: (map[_kUri] as String).split(_kUriPrefix).last,
      );

  /// ==========================================================================

  @override
  bool operator ==(covariant FileLocation other) {
    if (identical(this, other)) return true;

    return other.range == range && other.filePath == filePath;
  }

  @override
  int get hashCode => range.hashCode ^ filePath.hashCode;

  @override
  String toString() => 'FileLocation(range: $range, filePath: $filePath)';
}
