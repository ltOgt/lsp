/// Position in a text document expressed as zero-based line and zero-based character offset.
///
/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#position
class Position {
  /// Line position in a document (zero-based).
  final int line;

  /// Character offset on a line in a document (zero-based).
  ///
  /// The meaning of this offset is determined by the negotiated `PositionEncodingKind`.
  final int character;

  Position(this.line, this.character);

  // ===========================================================================

  static const _kLine = "line";
  static const _kCharacter = "character";

  Map get json => {
        _kLine: line,
        _kCharacter: character,
      };

  static Position fromJson(Map map) => Position(
        map[_kLine],
        map[_kCharacter],
      );
}
