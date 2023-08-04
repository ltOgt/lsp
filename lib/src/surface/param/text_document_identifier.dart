/// Specifies a file via its [filePath].
///
/// Transmitted as [uri].
///
/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocumentIdentifier
class TextDocumentIdentifier {
  final String filePath;

  const TextDocumentIdentifier(this.filePath);

  // ===========================================================================

  static const _kUri = "uri";
  static const kUriPrefix = "file://";

  String get uri => "file://" + filePath;
  Map toJson() => json;
  Map get json => {
        _kUri: uri,
      };

  static TextDocumentIdentifier fromJson(Map map) => TextDocumentIdentifier(
        (map[_kUri] as String).split(kUriPrefix).last,
      );
}
