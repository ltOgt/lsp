// ignore_for_file: public_member_api_docs, sort_constructors_first
/// Position in a text document expressed as zero-based line and zero-based character offset.
///
/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#position
class FilePosition {
  /// Line position in a document (zero-based).
  final int line;

  /// Character offset on a line in a document (zero-based).
  ///
  /// The meaning of this offset is determined by the negotiated `PositionEncodingKind`.
  final int character;

  const FilePosition({
    required this.line,
    required this.character,
  });

  // ===========================================================================

  static const _kLine = "line";
  static const _kCharacter = "character";

  Map toJson() => json;
  Map get json => {
        _kLine: line,
        _kCharacter: character,
      };

  static FilePosition fromJson(Map map) => FilePosition(
        line: map[_kLine],
        character: map[_kCharacter],
      );

  // ===========================================================================

  @override
  bool operator ==(covariant FilePosition other) {
    if (identical(this, other)) return true;

    return other.line == line && other.character == character;
  }

  @override
  int get hashCode => line.hashCode ^ character.hashCode;

  @override
  String toString() => 'FilePosition(line: $line, character: $character)';
}
