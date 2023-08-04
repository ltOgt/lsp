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
export 'src/surface/response/text_document/semantic_full_response.dart';
export 'src/surface/response/text_document/locations_response.dart';
export 'src/surface/response/text_document/hover_response.dart';
export 'src/surface/response/text_document/document_highlight_response.dart';
export 'src/surface/response/text_document/prepare_call_hierarchy_response.dart';

// =============================================================================
// For extracting semantic tokens and modifiers
export 'src/semantics/token_legend/token_types.dart';
export 'src/semantics/token_legend/token_mods.dart';
export 'src/semantics/token_legend/token_legend.dart';
export '/src/semantics/token_decoder.dart';

// =============================================================================
// Containers to encapsulate data packages
export 'src/object/semantic/token.dart';
export 'src/surface/param/file_location.dart';
export 'src/surface/param/position.dart';
export 'src/surface/param/range.dart';
export 'src/surface/param/reference_params.dart';
export 'src/surface/param/text_document_identifier.dart';
export 'src/surface/param/text_documentation_position_params.dart';
