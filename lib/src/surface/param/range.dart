// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:lsp/src/surface/param/position.dart';

/// A range in a text document expressed as (zero-based) start and end [Positions].
///
/// A range is comparable to a selection in an editor.
/// Therefore, the end position is exclusive.
///
/// If you want to specify a range that contains a line including the line ending character(s),
/// then use an end position denoting the start of the next line
///
/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#range
class Range {
  /// The ranges start position (inclusive).
  final Position start;

  /// The ranges end position (exclusive).
  final Position end;

  Range({
    required this.start,
    required this.end,
  });

  // ===========================================================================

  static const _kStart = "start";
  static const _kEnd = "end";

  Map get json => {
        _kStart: start.json,
        _kEnd: end.json,
      };

  static Range fromJson(Map map) => Range(
        start: Position.fromJson(map[_kStart]! as Map<String, dynamic>),
        end: Position.fromJson(map[_kEnd]! as Map<String, dynamic>),
      );

  // ===========================================================================

  @override
  bool operator ==(covariant Range other) {
    if (identical(this, other)) return true;

    return other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;

  @override
  String toString() => 'Range(start: $start, end: $end)';
}
