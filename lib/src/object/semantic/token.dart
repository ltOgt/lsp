/// Semantic Token.
/// Created by [SemanticTokenDecoder] from [FileTokensEncoded].
/// Part of [FileTokensDecoded].
///
/// [row] is the absolute row of the token in the corresponding file.
/// [start] is the absolute start position of the token in that row.
/// [length] is the absoulte length of the token.
/// [tokenType] needs to be resolved via [TokenLegend().tokenType]
/// [tokenModifiers] need to be resolved via [TokenLegend().tokenModifiers]
class SemanticToken {
  final int row;
  final int start;
  final int length;
  final int tokenType;
  final List<int> tokenModifiers;

  SemanticToken({
    required this.row,
    required this.start,
    required this.length,
    required this.tokenType,
    required this.tokenModifiers,
  });

  @override
  String toString() {
    return 'SemanticToken(row: $row, start: $start, length: $length, tokenType: $tokenType, tokenModifiers: $tokenModifiers)';
  }
}
