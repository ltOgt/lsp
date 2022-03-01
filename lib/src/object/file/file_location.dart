import 'file_range.dart';

/// Contains the [path] to a file and a [range] inside that file.
///
/// Used by
/// -
class FileLocation {
  static const String key_path = "path";
  final String path;

  static const String key_range = "range";
  final FileRange range;

  FileLocation({
    required this.path,
    required this.range,
  });

  Map<String, Object> encode() => {
        key_path: path,
        key_range: range.encode(),
      };

  static FileLocation decode(Map<String, Object> m) => FileLocation(
        path: m[key_path]! as String,
        range: FileRange.decode(m[key_range]! as Map<String, Object>),
      );
}
