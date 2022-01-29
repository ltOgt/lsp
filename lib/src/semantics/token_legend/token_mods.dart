import 'package:lsp/src/semantics/token_legend/token_types.dart';

/// Modifiers on top of [SemanticTokenType].
/// One source code token can have multiple [SemanticTokenModifier]s.
///
/// For the general concept see:
/// https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#semanticTokensLegend
///
/// These default values are defined at:
/// https://microsoft.github.io/language-server-protocol/specifications/specification-3-16/#textDocument_semanticTokens
///
/// Note that each LSP can defined additional token mods! TODO add interface to be extended for each language; fallback if not in here
enum SemanticTokenModifier {
  declaration_,
  definition_,
  readonly_,
  static_,
  deprecated_,
  abstract_,
  async_,
  modification_,
  documentation_,
  defaultLibrary_,
}
