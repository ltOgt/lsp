// ignore_for_file: constant_identifier_names

import 'package:lsp/src/semantics/token_decoder.dart';
import 'package:lsp/src/surface/response/text_document/semantic_full_response.dart';
import 'package:test/test.dart';

import 'package:lsp/lsp.dart';

const String DART_SDK_PATH = "/Users/omni/development/flutter/bin/cache/dart-sdk/";
const String ANALYSIS_PATH = DART_SDK_PATH + "bin/snapshots/analysis_server.dart.snapshot";
const String ROOT_PATH = "/Users/omni/repos/thesis/codeatlas/lsp/";
const String SEMANTIC_TEST_FILE_PATH = ROOT_PATH + "test/_test_data/semantic_token_source.dart";

Future<LspSurface> init() {
  final connector = LspConnectorDart(
    analysisServerPath: ANALYSIS_PATH,
    clientId: "clientId",
    clientVersion: "0.0.1",
  );
  return LspSurface.start(
    lspConnector: connector,
    rootPath: ROOT_PATH,
    clientCapabilities: {},
  );
}

void main() {
  group('Surface - Dart Connector', () {
    test('Initiate Connection', () async {
      try {
        await init();
      } on LspInitializationException catch (_) {
        expect(false, isTrue);
        return;
      }
      expect(true, isTrue);
    });

    test('Semantic Token Request + Decode', () async {
      final LspSurface surface = await init();
      SemanticTokenFullResponse r = await surface.textDocument_semanticTokens_full(
        filePath: SEMANTIC_TEST_FILE_PATH,
      );
      List<SemanticToken> tokens = SemanticTokenDecoder.decodeTokens(r.data);
      expect(tokens.length, equals(12));

      // "testField" declaration
      final testFieldToken = tokens[7];

      expect(surface.semanticTokenTypes[testFieldToken.tokenType], equals("property"));
      expect(surface.semanticTokenModifiers[testFieldToken.tokenModifiers[0]], equals("declaration"));
      expect(surface.semanticTokenModifiers[testFieldToken.tokenModifiers[1]], equals("instance"));
    });
  });
}
