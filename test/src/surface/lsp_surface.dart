// ignore_for_file: constant_identifier_names
import 'dart:io';

import 'package:test/test.dart';

import 'package:lsp/lsp.dart';

const String DART_SDK_PATH = "/Users/omni/development/flutter/bin/cache/dart-sdk/";
const String ANALYSIS_PATH = DART_SDK_PATH + "bin/snapshots/analysis_server.dart.snapshot";
const String ROOT_PATH = "/Users/omni/repos/package/lsp/";
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
  group('Surface - Dart Connector:', () {
    if (!File(SEMANTIC_TEST_FILE_PATH).existsSync()) {
      throw "Test file does not exist";
    }

    test('Initiate Connection', () async {
      late LspSurface surface;
      try {
        surface = await init();
      } on LspInitializationException catch (_) {
        expect(false, isTrue);
        return;
      }
      expect(true, isTrue);
      surface.dispose();
    });

    test('Semantic Token Legend', () async {
      final surface = await init();
      expect(surface.semanticTokenLegend.tokenTypes, [
        "annotation",
        "keyword",
        "class",
        "comment",
        "method",
        "variable",
        "parameter",
        "enum",
        "enumMember",
        "type",
        "source",
        "property",
        "namespace",
        "boolean",
        "number",
        "string",
        "function",
        "typeParameter"
      ]);
      expect(surface.semanticTokenLegend.tokenModifiers, [
        "documentation",
        "constructor",
        "declaration",
        "importPrefix",
        "instance",
        "static",
        "escape",
        "annotation",
        "control",
        "label",
        "interpolation",
        "void"
      ]);
      surface.dispose();
    });

    test('Semantic Token Request + Decode', () async {
      final LspSurface surface = await init();
      SemanticTokenFullResponse r = await surface.textDocument_semanticTokens_full(
        filePath: SEMANTIC_TEST_FILE_PATH,
      );
      List<SemanticToken> tokens = SemanticTokenDecoder.decodeTokens(r.data);
      expect(tokens.length, equals(22));

      // "testField" declaration
      final testFieldToken = tokens[7];

      expect(surface.semanticTokenLegend.tokenTypes[testFieldToken.tokenType], equals("property"));
      expect(surface.semanticTokenLegend.tokenModifiers[testFieldToken.tokenModifiers[0]], equals("declaration"));
      expect(surface.semanticTokenLegend.tokenModifiers[testFieldToken.tokenModifiers[1]], equals("instance"));

      surface.dispose();
    });

    test('Find all references', () async {
      final LspSurface surface = await init();
      ReferenceResponse r = await surface.textDocument_references(
        filePath: SEMANTIC_TEST_FILE_PATH,
        line: 1,
        character: 10, // points at "TestClass"
        includeDeclaration: false,
      );
      expect(r.fileLocations.length, equals(4));

      void _expectRanges(FileLocation actual, FilePosition start, FilePosition end) {
        expect(
            actual,
            equals(FileLocation(
              path: SEMANTIC_TEST_FILE_PATH,
              range: FileRange(
                // occurence in doc string
                start: start,
                end: end,
              ),
            )));
      }

      // occurence in doc string
      _expectRanges(
        r.fileLocations[0],
        FilePosition(line: 0, character: 31),
        FilePosition(line: 0, character: 40),
      );

      // occurence in constructor
      _expectRanges(
        r.fileLocations[1],
        FilePosition(line: 5, character: 2),
        FilePosition(line: 5, character: 11),
      );

      // occurence in main() declaration
      _expectRanges(
        r.fileLocations[2],
        FilePosition(line: 11, character: 2),
        FilePosition(line: 11, character: 11),
      );

      // occurence in main() instantiation
      _expectRanges(
        r.fileLocations[3],
        FilePosition(line: 11, character: 24),
        FilePosition(line: 11, character: 33),
      );
    });
  });
}
