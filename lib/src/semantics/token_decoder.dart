import '../object/semantic/token.dart';

class SemanticTokenDecoder {
  /// Decode [SemanticToken]s from `List<int>[<int_relativeRow>, <int_relativeStart>, <int_length>, <int_tokenType>, <bitmask_tokenModifiers>]`.
  ///
  /// https://microsoft.github.io/language-server-protocol/specifications/specification-3-16/#textDocument_semanticTokens
  ///
  /// E.g:
  ///    first-      second-     third-    -token
  /// [  2,5,3,0,3,  0,5,4,1,0,  3,2,7,2,0 ]
  static List<SemanticToken> decodeTokens(List<int> encodedTokens) {
    List<SemanticToken> tokens = [];
    SemanticToken previous = SemanticToken(row: 0, start: 0, length: 0, tokenType: 0, tokenModifiers: []);
    for (int i = 0; i < encodedTokens.length; i += 5) {
      int relativeRow = encodedTokens[i];
      int relativeStart = encodedTokens[i + 1];
      int length = encodedTokens[i + 2];
      int tokenType = encodedTokens[i + 3];
      int tokenModBitMask = encodedTokens[i + 4];

      final SemanticToken current = SemanticToken(
        // Row is relative to previous token
        row: previous.row + relativeRow,
        // Start is relative to previous start iff they are on the same row
        start: (encodedTokens[i] == 0 ? previous.start : 0) + relativeStart,
        length: length,
        tokenType: tokenType,
        tokenModifiers: unmaskBitmask(tokenModBitMask),
      );
      tokens.add(current);
      previous = current;
    }

    return tokens;
  }
}

/// Take in [mask] and return zero based list of bit-positions that are 1.
/// Mask length is the cutoff for bits to look at.
///
/// Returns e.g. `[]` for `0` (`0000`)
///
/// Returns e.g. `[0,1]` list for 3 (`0011`)
List<int> unmaskBitmask(int mask, [int maskLength = 64]) {
  List<int> positions = [];
  for (int i = 0; i < maskLength; i++) {
    // 1011 & 1 = 1; 1010 & 1 = 0;
    if ((mask & 1) == 1) {
      positions.add(i);
    }
    // 1011 => 0101 => 0010 => ...
    mask = (mask >> 1);
  }
  return positions;
}
