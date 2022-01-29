import 'file_position.dart';

/// A position inside a file.
///
/// [start] is the position pointing to the start of the range (inclusive).
/// [end] is the position pointing to the end of the range (exclusive).
///
/// ```
/// {
///   "start": {
///     "line": <line>,
///     "character": <character>
///   },
///   "end": {
///     "line": <line>,
///     "character": <character>
///   }
/// }
/// ```
class FileRange {
  static const String key_start = "start";
  final FilePosition start;

  static const String key_end = "end";
  final FilePosition end;

  FileRange({
    required this.start,
    required this.end,
  });

  Map encode() => {
        key_start: start.encode(),
        key_end: end.encode(),
      };

  static FileRange decode(Map m) => FileRange(
        start: FilePosition.decode(m[key_start]!),
        end: FilePosition.decode(m[key_end]!),
      );
}
