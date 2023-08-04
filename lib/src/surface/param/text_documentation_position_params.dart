import 'package:lsp/src/surface/param/position.dart';
import 'package:lsp/src/surface/param/text_document_identifier.dart';

/// Specifies a text document and a position inside that document.
///
/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocumentPositionParams
class TextDocumentPositionParams {
  final TextDocumentIdentifier textDocument;

  final Position position;

  const TextDocumentPositionParams({
    required this.textDocument,
    required this.position,
  });

  // ===========================================================================
  static const _kTextDocument = "textDocument";
  static const _kPosition = "position";

  Map get json => {
        _kTextDocument: textDocument.json,
        _kPosition: position.json,
      };

  static TextDocumentPositionParams fromJson(Map map) => TextDocumentPositionParams(
        textDocument: map[_kTextDocument],
        position: map[_kPosition],
      );
}
