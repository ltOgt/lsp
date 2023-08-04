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
@Deprecated("Deprecated, use Range instead")
class FileRangeOld {
  static const String key_start = "start";
  final FilePositionOld start;

  static const String key_end = "end";
  final FilePositionOld end;

  FileRangeOld({
    required this.start,
    required this.end,
  });

  Map<String, Object> encode() => {
        key_start: start.encode(),
        key_end: end.encode(),
      };

  static FileRangeOld decode(Map<String, Object> m) => FileRangeOld(
        start: FilePositionOld.decode(m[key_start]! as Map<String, Object>),
        end: FilePositionOld.decode(m[key_end]! as Map<String, Object>),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FileRangeOld && other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
