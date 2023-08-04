/// Incomplete mapping of LSP Server Capabilities
/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#initializeResult
class ServerCapabilities {
  final Map capabilities;
  late final bool callHierarchyProvider = capabilities["callHierarchyProvider"] ?? false;
  late final bool codeActionProvider = capabilities["codeActionProvider"] ?? false;
  late final bool definitionProvider = capabilities["definitionProvider"] ?? false;
  late final bool documentHighlightProvider = capabilities["documentHighlightProvider"] ?? false;
  late final bool documentSymbolProvider = capabilities["documentSymbolProvider"] ?? false;
  late final bool foldingRangeProvider = capabilities["foldingRangeProvider"] ?? false;
  late final bool hoverProvider = capabilities["hoverProvider"] ?? false;
  late final bool implementationProvider = capabilities["implementationProvider"] ?? false;
  late final bool referenceProvider = capabilities["referencesProvider"] ?? false;
  late final bool selectionRangeProvider = capabilities["selectionRangeProvider"] ?? false;
  late final Map semanticTokensProvider = capabilities["semanticTokensProvider"] ?? false;
  late final bool typeHierarchyProvider = capabilities["typeHierarchyProvider"] ?? false;
  late final bool workspaceSymbolProvider = capabilities["workspaceSymbolProvider"] ?? false;
  late final bool typeDefinitionProvider = capabilities["typeDefinitionProvider"] ?? false;

  ServerCapabilities.fromJson(this.capabilities);
}
