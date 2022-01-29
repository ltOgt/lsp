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

// =============================================================================
// For extracting semantic tokens and modifiers
export 'src/semantics/token_legend/token_types.dart';
export 'src/semantics/token_legend/token_mods.dart';
