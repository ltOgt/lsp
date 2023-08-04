/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#initializeResult
class ServerInfo {
  final String name;
  final String? version;

  ServerInfo({required this.name, required this.version});
  static ServerInfo? fromJson(Map? map) => map == null
      ? null
      : ServerInfo(
          name: map["name"],
          version: map["version"],
        );
}
