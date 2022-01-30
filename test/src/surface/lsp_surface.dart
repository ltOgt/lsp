// ignore_for_file: constant_identifier_names

import 'package:test/test.dart';

import 'package:lsp/lsp.dart';

const String DART_SDK_PATH = "/Users/omni/development/flutter/bin/cache/dart-sdk/";
const String ANALYSIS_PATH = DART_SDK_PATH + "bin/snapshots/analysis_server.dart.snapshot";
const String ROOT_PATH = "/Users/omni/repos/thesis/codeatlas/lsp/";

void main() {
  group('Surface - Dart Connector', () {
    test('Initiate Connection', () async {
      final connector = LspConnectorDart(
        analysisServerPath: ANALYSIS_PATH,
        clientId: "clientId",
        clientVersion: "0.0.1",
      );

      late final LspSurface surface;
      try {
        surface = await LspSurface.start(
          lspConnector: connector,
          rootPath: ROOT_PATH,
          clientCapabilities: {},
        );
      } on LspInitializationException catch (_) {
        expect(false, isTrue);
        return;
      }

      surface.textDocument_semanticTokens_full(filePath: ROOT_PATH + "lsp.dart");
      expect(true, isTrue);
    });
  });
}
