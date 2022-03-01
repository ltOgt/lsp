/// A position inside a file.
///
/// [line] is the zero based line index of the cursor.
///
/// [character] is the zero based index of the cursor inside the line.
class FilePosition {
  static const String key_line = "line";
  final int line;

  static const String key_character = "character";
  final int character;

  FilePosition({
    required this.line,
    required this.character,
  });

  Map<String, Object> encode() => {
        key_line: "$line",
        key_character: "$character",
      };

  static FilePosition decode(Map<String, Object> m) => FilePosition(
        line: int.parse(m[key_line]! as String),
        character: int.parse(m[key_character]! as String),
      );
}
