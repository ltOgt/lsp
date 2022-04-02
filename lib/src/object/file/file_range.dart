// ignore_for_file: public_member_api_docs, sort_constructors_first
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

  Map<String, Object> encode() => {
        key_start: start.encode(),
        key_end: end.encode(),
      };

  static FileRange decode(Map<String, Object> m) => FileRange(
        start: FilePosition.decode(m[key_start]! as Map<String, Object>),
        end: FilePosition.decode(m[key_end]! as Map<String, Object>),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FileRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
