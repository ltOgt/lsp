/// This library provides general utilities for interacting with LSPs from dart.
library lsp;

// =============================================================================
// For starting the LSP server
export 'src/connector/base_connector.dart';
export 'src/connector/dart_connector.dart';

// =============================================================================
// For interacting with the LSP server
export 'src/surface/lsp_surface.dart';
export 'src/surface/response/init_response.dart';
export 'src/surface/response/text_document/definition_response.dart';
export 'src/surface/response/text_document/semantic_full_response.dart';

// =============================================================================
// For extracting semantic tokens and modifiers
export 'src/semantics/token_legend/token_types.dart';
export 'src/semantics/token_legend/token_mods.dart';
export 'src/semantics/token_legend/token_legend.dart';

// =============================================================================
// Containers to encapsulate data packages
export 'src/object/file/file_location.dart';
export 'src/object/file/file_range.dart';
export 'src/object/file/file_position.dart';
export 'src/object/semantic/token.dart';
