import 'package:lsp/src/semantics/token_legend/token_mods.dart';

/// Semantic Base Type for a token within source code.
/// Also see [SemanticTokenModifier]
///
/// For the general concept see:
/// https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#semanticTokensLegend
///
/// These default values are defined at:
/// https://microsoft.github.io/language-server-protocol/specifications/specification-3-16/#textDocument_semanticTokens
///
/// Note that each LSP can defined additional token types! TODO add interface to be extended for each language; fallback if not in here
enum SemanticTokenType {
  type_,
  class_,
  enum_,
  interface_,
  struct_,
  typeParameter_,
  parameter_,
  variable_,
  property_,
  enumMember_,
  event_,
  function_,
  method_,
  macro_,
  keyword_,
  modifier_,
  comment_,
  string_,
  number_,
  regexp_,
  operator_,
}
