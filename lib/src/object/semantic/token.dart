// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';

import 'package:lsp/lsp.dart';

/// Semantic Token.
/// Created by [SemanticTokenDecoder] from [FileTokensEncoded].
/// Part of [FileTokensDecoded].
///
/// [row] is the absolute row of the token in the corresponding file.
/// [start] is the absolute start position of the token in that row.
/// [length] is the absoulte length of the token.
/// [tokenType] needs to be resolved via [SemanticTokenLegend.tokenTypes]
/// [tokenModifiers] need to be resolved via [SemanticTokenLegend.tokenModifiers]
class SemanticToken implements Comparable<SemanticToken> {
  final int row;
  final int start;
  final int length;
  final int tokenType;
  final List<int> tokenModifiers;

  const SemanticToken({
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

  @override
  bool operator ==(covariant SemanticToken other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.row == row &&
        other.start == start &&
        other.length == length &&
        other.tokenType == tokenType &&
        listEquals(other.tokenModifiers, tokenModifiers);
  }

  @override
  int get hashCode {
    final listHash = const DeepCollectionEquality().hash;

    return row.hashCode ^
        start.hashCode ^
        length.hashCode ^
        tokenType.hashCode ^
        listHash(
          tokenModifiers,
        );
  }

  @override
  int compareTo(SemanticToken other) {
    final rowDiff = row - other.row;
    if (rowDiff != 0) return rowDiff;
    final startDiff = start - other.start;
    if (startDiff != 0) return startDiff;
    return length - other.length;
  }
}
