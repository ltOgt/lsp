import 'package:lsp/src/surface/param/text_documentation_position_params.dart';

/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#referenceParams

class ReferenceParams {
  /// Position of the symbol for which the references should be looked up
  final TextDocumentPositionParams position;

  /// Include the declaration of the current symbol
  final bool includeDeclaration;

  ReferenceParams({required this.position, required this.includeDeclaration});

  // ===========================================================================

  Map get json => {
        ...position.json,
        "context": {
          "includeDeclaration": includeDeclaration,
        },
      };
}
