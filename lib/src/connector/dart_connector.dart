import 'dart:io';

import 'package:lsp/src/connector/base_connector.dart';

class LspConnectorDart extends LspConnectorBase {
  /// The path to the dart analysis server executable.
  final String analysisServerPath;

  LspConnectorDart({
    required this.analysisServerPath,
    required String clientId,
    required String clientVersion,
  }) : super(clientId: clientId, clientVersion: clientVersion);

  @override
  Future<Process> startProcess() {
    return Process.start(
        "dart", [analysisServerPath, "--lsp", "--client-id", clientId, "--client-version", clientVersion]);
  }
}
