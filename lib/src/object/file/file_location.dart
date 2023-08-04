// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'file_range.dart';

/// Contains the [path] to a file and a [range] inside that file.
///
/// Used by
/// -
@Deprecated("")
class FileLocationOld {
  static const String key_path = "path";
  final String path;

  static const String key_range = "range";
  final FileRangeOld range;

  FileLocationOld({
    required this.path,
    required this.range,
  });

  Map<String, Object> encode() => {
        key_path: path,
        key_range: range.encode(),
      };

  static FileLocationOld decode(Map<String, Object> m) => FileLocationOld(
        path: m[key_path]! as String,
        range: FileRangeOld.decode(m[key_range]! as Map<String, Object>),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FileLocationOld && other.path == path && other.range == range;
  }

  @override
  int get hashCode => path.hashCode ^ range.hashCode;
}
