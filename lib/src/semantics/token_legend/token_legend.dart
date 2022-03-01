import 'package:lsp/lsp.dart';

/// Defines the tokens that are supported by the LSP.
/// Needed to resolve [SemanticToken], which only contains indexes to this legend.
///
/// See:
/// https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#initializeResult
/// https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#serverCapabilities
/// https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#semanticTokensOptions
/// https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#semanticTokensLegend
class SemanticTokenLegend {
  /// Token types like "class", "type", "enumMember", ...
  /// See [SemanticTokenType].
  final List<String> tokenTypes;
  static const k_tokenTypes = "t";

  /// Token modifiers on top of token type, like "private", "declaration", "deprecated", ...
  /// See [SemanticTokenModifier]
  final List<String> tokenModifiers;
  static const k_tokenModifiers = "m";

  SemanticTokenLegend({
    required this.tokenTypes,
    required this.tokenModifiers,
  });

  Map<String, Object> encode() => {
        k_tokenTypes: tokenTypes,
        k_tokenModifiers: tokenModifiers,
      };

  static SemanticTokenLegend decode(Map<String, Object> m) => SemanticTokenLegend(
        tokenTypes: (m[k_tokenTypes]! as List).cast(),
        tokenModifiers: (m[k_tokenModifiers]! as List).cast(),
      );
}
