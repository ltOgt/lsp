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
    // https://stackoverflow.com/a/67797686/7215915 for how to use this on apple
    // Also see https://github.com/flutter/flutter/issues/89837#issuecomment-2099544981
    return Process.start(
      "dart",
      [analysisServerPath, "--lsp", "--client-id", clientId, "--client-version", clientVersion],
    );
  }
}
