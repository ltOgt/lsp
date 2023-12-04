import 'package:lsp/lsp.dart';

const String DART_SDK_PATH = "/Users/omni/development/flutter/bin/cache/dart-sdk/";
const String ANALYSIS_PATH = DART_SDK_PATH + "bin/snapshots/analysis_server.dart.snapshot";
const String ROOT_PATH = "/Users/omni/development/flutter/packages/flutter";

void main() async {
  final connector = LspConnectorDart(
    analysisServerPath: ANALYSIS_PATH,
    clientId: "clientId",
    clientVersion: "0.0.1",
  );
  final surface = await LspSurface.start(
    lspConnector: connector,
    rootPath: ROOT_PATH,
    clientCapabilities: {},
    onMessage: null,
  );

  await Future.delayed(Duration(seconds: 2));

  final tokenResponse = await surface.textDocument_semanticTokens_full(filePath: ROOT_PATH + "/lib/material.dart");
  //print(SemanticTokenDecoder.decodeTokens(tokenResponse.data));
}
