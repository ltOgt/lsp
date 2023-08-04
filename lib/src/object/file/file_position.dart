// ignore_for_file: public_member_api_docs, sort_constructors_first
/// A position inside a file.
///
/// [line] is the zero based line index of the cursor.
///
/// [character] is the zero based index of the cursor inside the line.
///
/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#position
@Deprecated("Potentially deprecated")
class FilePositionOld {
  static const String _kLine = "line";
  final int line;

  static const String _kCharacter = "character";
  final int character;

  FilePositionOld({
    required this.line,
    required this.character,
  });

  Map<String, Object> encode() => {
        _kLine: "$line",
        _kCharacter: "$character",
      };

  static FilePositionOld decode(Map<String, Object> m) => FilePositionOld(
        line: int.parse(m[_kLine]! as String),
        character: int.parse(m[_kCharacter]! as String),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FilePositionOld && other.line == line && other.character == character;
  }

  @override
  int get hashCode => line.hashCode ^ character.hashCode;
}
