// ignore_for_file: constant_identifier_names
import 'dart:io';

import 'package:test/test.dart';

import 'package:lsp/lsp.dart';

const String DART_SDK_PATH = "/Users/omni/development/flutter/bin/cache/dart-sdk/";
const String ANALYSIS_PATH = DART_SDK_PATH + "bin/snapshots/analysis_server.dart.snapshot";
const String ROOT_PATH = "/Users/omni/repos/package/lsp/";
const String SEMANTIC_TEST_FILE_PATH = ROOT_PATH + "test/_test_data/semantic_token_source.dart";

Future<LspSurface> init(String clientId) {
  final connector = LspConnectorDart(
    analysisServerPath: ANALYSIS_PATH,
    clientId: clientId,
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
        surface = await init("t1");
      } on LspInitializationException catch (_) {
        expect(false, isTrue);
        return;
      }
      expect(surface.serverInfo, isNotNull);
      expect(surface.capabilities.callHierarchyProvider, isTrue);
      expect(surface.capabilities.codeActionProvider, isTrue);
      expect(surface.capabilities.definitionProvider, isTrue);
      expect(surface.capabilities.documentHighlightProvider, isTrue);
      expect(surface.capabilities.documentSymbolProvider, isTrue);
      expect(surface.capabilities.foldingRangeProvider, isTrue);
      expect(surface.capabilities.hoverProvider, isTrue);
      expect(surface.capabilities.implementationProvider, isTrue);
      expect(surface.capabilities.referenceProvider, isTrue);
      expect(surface.capabilities.selectionRangeProvider, isTrue);
      expect(surface.capabilities.typeHierarchyProvider, isTrue);
      expect(surface.capabilities.workspaceSymbolProvider, isTrue);
      expect(surface.capabilities.typeDefinitionProvider, isFalse); // Not provided by dart server
      surface.dispose();
    });

    test('Semantic Token Legend', () async {
      final surface = await init("t2");
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
      final LspSurface surface = await init("t3");
      SemanticTokenFullResponse r = await surface.textDocument_semanticTokens_full(
        filePath: SEMANTIC_TEST_FILE_PATH,
      );
      List<SemanticToken> tokens = SemanticTokenDecoder.decodeTokens(r.data);
      expect(tokens.length, equals(35));

      // "testField" declaration (line 8, col 16)
      final testFieldToken = tokens[17];

      expect(surface.semanticTokenLegend.tokenTypes[testFieldToken.tokenType], equals("property"));
      expect(surface.semanticTokenLegend.tokenModifiers[testFieldToken.tokenModifiers[0]], equals("declaration"));
      expect(surface.semanticTokenLegend.tokenModifiers[testFieldToken.tokenModifiers[1]], equals("instance"));

      surface.dispose();
    });

    test('Find all references', () async {
      final LspSurface surface = await init("t4");
      ReferenceResponse r = await surface.textDocument_references(
        ReferenceParams(
          position: TextDocumentPositionParams(
            textDocument: TextDocumentIdentifier(SEMANTIC_TEST_FILE_PATH),
            // "TestClass" in "class TestClass extends BaseClass"
            position: Position(
              line: 5,
              character: 10,
            ),
          ),
          includeDeclaration: false,
        ),
      );

      surface.dispose();
      expect(r.fileLocations.length, equals(4));

      void _expectRanges(FileLocation actual, Position start, Position end) {
        expect(
          actual,
          equals(
            FileLocation(
              filePath: SEMANTIC_TEST_FILE_PATH,
              range: Range(
                // occurence in doc string
                start: start,
                end: end,
              ),
            ),
          ),
        );
      }

      // occurence in doc string
      _expectRanges(
        r.fileLocations[0],
        Position(line: 4, character: 31),
        Position(line: 4, character: 40),
      );

      // occurence in constructor
      _expectRanges(
        r.fileLocations[1],
        Position(line: 10, character: 2),
        Position(line: 10, character: 11),
      );

      // occurence in main() declaration
      _expectRanges(
        r.fileLocations[2],
        Position(line: 16, character: 2),
        Position(line: 16, character: 11),
      );

      // occurence in main() instantiation
      _expectRanges(
        r.fileLocations[3],
        Position(line: 16, character: 24),
        Position(line: 16, character: 33),
      );
    });
  });
}
