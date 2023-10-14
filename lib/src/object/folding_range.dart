// ignore_for_file: public_member_api_docs, sort_constructors_first
/// Represents a folding range. To be valid, start and end line must be bigger
/// than zero and smaller than the number of lines in the document. Clients
/// are free to ignore invalid ranges.
///
/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#foldingRange
class FoldingRange {
  /// The zero-based start line of the range to fold. The folded area starts
  /// after the line's last character. To be valid, the end must be zero or
  /// larger and smaller than the number of lines in the document.
  final int startLine;

  /// The zero-based character offset from where the folded range starts. If
  /// not defined, defaults to the length of the start line.
  final int? startCharacter;

  /// The zero-based end line of the range to fold. The folded area ends with
  /// the line's last character. To be valid, the end must be zero or larger
  /// and smaller than the number of lines in the document.
  final int endLine;

  /// The zero-based character offset before the folded range ends. If not
  /// defined, defaults to the length of the end line.
  final int? endCharacter;

  /// Describes the kind of the folding range such as `comment` or `region`.
  /// The kind is used to categorize folding ranges and used by commands like
  /// 'Fold all comments'. See [FoldingRangeKind](#FoldingRangeKind) for an
  /// enumeration of standardized kinds.
  //kind?: FoldingRangeKind;

  /// The text that the client should show when the specified range is
  /// collapsed. If not defined or not supported by the client, a default
  /// will be chosen by the client.
  ///
  /// @since 3.17.0 - proposed
  //collapsedText?: string;

  FoldingRange({
    required this.startLine,
    required this.startCharacter,
    required this.endLine,
    required this.endCharacter,
  });

  // ===========================================================================
  static const _kStartLine = "startLine";
  static const _kStartCharacter = "startCharacter";
  static const _kEndLine = "endLine";
  static const _kEndCharacter = "endCharacter";

  Map toJson() => json;
  Map get json => {
        _kStartLine: startLine,
        if (startCharacter != null) //
          _kStartCharacter: startCharacter,
        _kEndLine: endLine,
        if (endCharacter != null) //
          _kEndCharacter: endCharacter,
      };

  static FoldingRange fromJson(Map map) => FoldingRange(
        startLine: map[_kStartLine],
        startCharacter: map[_kStartCharacter],
        endLine: map[_kEndLine],
        endCharacter: map[_kEndCharacter],
      );

  // ===========================================================================

  @override
  bool operator ==(covariant FoldingRange other) {
    if (identical(this, other)) return true;

    return other.startLine == startLine &&
        other.startCharacter == startCharacter &&
        other.endLine == endLine &&
        other.endCharacter == endCharacter;
  }

  @override
  int get hashCode {
    return startLine.hashCode ^ startCharacter.hashCode ^ endLine.hashCode ^ endCharacter.hashCode;
  }

  @override
  String toString() {
    return 'FoldingRange(startLine: $startLine, startCharacter: $startCharacter, endLine: $endLine, endCharacter: $endCharacter)';
  }
}
