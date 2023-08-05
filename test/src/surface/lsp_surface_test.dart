// ignore_for_file: constant_identifier_names
import 'dart:io';

import 'package:test/test.dart';

import 'package:lsp/lsp.dart';

// TODO add requests that result in empty list responses

const String DART_SDK_PATH = "/Users/omni/development/flutter/bin/cache/dart-sdk/";
const String ANALYSIS_PATH = DART_SDK_PATH + "bin/snapshots/analysis_server.dart.snapshot";
const String ROOT_PATH = "/Users/omni/repos/package/lsp/";
const String SEMANTIC_TEST_FILE_PATH = ROOT_PATH + "test/_test_data/semantic_token_source.dart";

const kTestClassPosition = TextDocumentPositionParams(
  textDocument: TextDocumentIdentifier(SEMANTIC_TEST_FILE_PATH),
  // "TestClass" in "class TestClass extends BaseClass"
  position: Position(
    line: 5,
    character: 10,
  ),
);
const kBaseClassPosition = TextDocumentPositionParams(
  textDocument: TextDocumentIdentifier(SEMANTIC_TEST_FILE_PATH),
  // "TestClass" in "class TestClass extends BaseClass"
  position: Position(
    line: 0,
    character: 19,
  ),
);

const kInnerCallPosition = TextDocumentPositionParams(
  textDocument: TextDocumentIdentifier(SEMANTIC_TEST_FILE_PATH),
  position: Position(
    line: 25,
    character: 10,
  ),
);

const _expectedHover = """```dart
class TestClass extends BaseClass
```
*test/_test_data/semantic_token_source.dart*

---
This is the docstring for [TestClass]""";

// =============================================================================
// =============================================================================
// =============================================================================

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

    // =========================================================================
    // =========================================================================
    // =========================================================================

    test('Initiate Connection', () async {
      late LspSurface surface;
      try {
        surface = await init();
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

    // =========================================================================
    // =========================================================================
    // =========================================================================

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

    // =========================================================================
    // =========================================================================
    // =========================================================================

    test('Semantic Token Request + Decode', () async {
      final LspSurface surface = await init();
      SemanticTokenFullResponse r = await surface.textDocument_semanticTokens_full(
        filePath: SEMANTIC_TEST_FILE_PATH,
      );
      List<SemanticToken> tokens = SemanticTokenDecoder.decodeTokens(r.data);
      expect(tokens.length, equals(44));

      // "testField" declaration (line 8, col 16)
      final testFieldToken = tokens[17];

      expect(surface.semanticTokenLegend.tokenTypes[testFieldToken.tokenType], equals("property"));
      expect(surface.semanticTokenLegend.tokenModifiers[testFieldToken.tokenModifiers[0]], equals("declaration"));
      expect(surface.semanticTokenLegend.tokenModifiers[testFieldToken.tokenModifiers[1]], equals("instance"));

      surface.dispose();
    });

    // =========================================================================
    // =========================================================================
    // =========================================================================

    test('Find all references', () async {
      final LspSurface surface = await init();
      LocationsResponse r = await surface.textDocument_references(
        ReferenceParams(
          position: kTestClassPosition,
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

    // =========================================================================
    // =========================================================================
    // =========================================================================

    test('Find all implementations', () async {
      final LspSurface surface = await init();
      LocationsResponse r = await surface.textDocument_implementation(
        kBaseClassPosition,
      );

      surface.dispose();
      expect(r.fileLocations.length, equals(1));

      expect(
        r.fileLocations.first,
        equals(
          /// "TestClass" in "class TestClass extends BaseClass"
          FileLocation(
            filePath: SEMANTIC_TEST_FILE_PATH,
            range: Range(
              start: Position(line: 5, character: 6),
              end: Position(line: 5, character: 15),
            ),
          ),
        ),
      );
    });

    // =========================================================================
    // =========================================================================
    // =========================================================================

    test('Hover', () async {
      final LspSurface surface = await init();
      HoverResponse r = await surface.textDocument_hover(
        kTestClassPosition,
      );

      surface.dispose();

      expect(r.contents, _expectedHover);
      expect(
        r.range,
        Range(
          start: Position(line: 5, character: 6),
          end: Position(line: 5, character: 15),
        ),
      );
    });

    // =========================================================================
    // =========================================================================
    // =========================================================================

    test('Document Highlight', () async {
      final LspSurface surface = await init();
      DocumentHighlightResponse r = await surface.textDocument_documentHighlight(
        kTestClassPosition,
      );

      surface.dispose();

      expect(r.highlights.length, 5);

      void _expectRanges(
        DocumentHighlight actual,
        Position expectedStart,
        Position expectedEnd,
        DocumentHighlightKind? expectedKind,
      ) {
        expect(
          actual,
          equals(
            DocumentHighlight(
              range: Range(
                start: expectedStart,
                end: expectedEnd,
              ),
              kind: expectedKind,
            ),
          ),
        );
      }

      // occurence in class definition (the origin of the request)
      _expectRanges(
        r.highlights[0],
        Position(line: 5, character: 6),
        Position(line: 5, character: 15),
        null,
      );

      // occurence in doc string
      _expectRanges(
        r.highlights[1],
        Position(line: 4, character: 31),
        Position(line: 4, character: 40),
        null,
      );

      // occurence in constructor
      _expectRanges(
        r.highlights[2],
        Position(line: 10, character: 2),
        Position(line: 10, character: 11),
        null,
      );

      // occurence in main() declaration
      _expectRanges(
        r.highlights[3],
        Position(line: 16, character: 2),
        Position(line: 16, character: 11),
        null,
      );

      // occurence in main() instantiation
      _expectRanges(
        r.highlights[4],
        Position(line: 16, character: 24),
        Position(line: 16, character: 33),
        null,
      );
    });

    // =========================================================================
    // =========================================================================
    // =========================================================================

    group("Call Hierarchy", () {
      test('Prepare Call hierarchy', () async {
        final LspSurface surface = await init();
        PrepareHierarchyResponse r = await surface.textDocument_prepareCallHierarchy(
          kInnerCallPosition,
        );
        surface.dispose();

        expect(r.items.length, 1);
        expect(
          r.items.first,
          HierarchyItem(
            name: "innerCall",
            kind: SymbolKind.constant,
            tags: null,
            detail: "semantic_token_source.dart",
            filePath: SEMANTIC_TEST_FILE_PATH,
            range: Range(
              start: Position(
                line: 25,
                character: 0,
              ),
              end: Position(
                line: 27,
                character: 1,
              ),
            ),
            selectionRange: Range(
              start: Position(
                line: 25,
                character: 5,
              ),
              end: Position(
                line: 25,
                character: 14,
              ),
            ),
            data: null,
          ),
        );
      });

      test('Resolve Incomming Calls', () async {
        final LspSurface surface = await init();
        PrepareHierarchyResponse r = await surface.textDocument_prepareCallHierarchy(
          kInnerCallPosition,
        );
        expect(r.items.length, 1);
        final itemThatIsCalled = r.items.first;

        IncomingCallResponse r2 = await surface.callHierarchy_incomingCalls(
          itemThatIsCalled,
        );
        surface.dispose();

        // inner call, i.e. the requester
        expect(r2.to, itemThatIsCalled);

        // outer call, ie.e the item that is calling
        expect(r2.calls.length, 1);
        final itemThatIsCalling = r2.calls.first;
        expect(
          itemThatIsCalling.from,
          HierarchyItem(
            name: "outerCall",
            kind: SymbolKind.constant,
            tags: null,
            detail: "semantic_token_source.dart",
            filePath: SEMANTIC_TEST_FILE_PATH,
            range: Range(
              start: Position(line: 21, character: 0),
              end: Position(line: 23, character: 1),
            ),
            selectionRange: Range(
              start: Position(line: 21, character: 5),
              end: Position(line: 21, character: 14),
            ),
            data: null,
          ),
        );
        expect(itemThatIsCalling.fromRanges, isNotEmpty);
        expect(itemThatIsCalling.fromRanges.length, 1);
        expect(
          itemThatIsCalling.fromRanges.first,
          Range(
            start: Position(line: 22, character: 2),
            end: Position(line: 22, character: 11),
          ),
        );
      });

      test('Resolve Outgoing Calls', () async {
        final LspSurface surface = await init();
        PrepareHierarchyResponse r = await surface.textDocument_prepareCallHierarchy(
          kInnerCallPosition,
        );
        expect(r.items.length, 1);
        final itemThatIsCalling = r.items.first;

        OutgoingCallResponse r2 = await surface.callHierarchy_outgoingCalls(
          itemThatIsCalling,
        );
        surface.dispose();

        // inner call, i.e. the requester
        expect(r2.from, itemThatIsCalling);

        // another call, i.e the item that is being called
        expect(r2.calls.length, 1);
        final _itemThatIsCalled = r2.calls.first;
        expect(
          _itemThatIsCalled.to,
          HierarchyItem(
            name: "anotherCall",
            kind: SymbolKind.constant,
            tags: null,
            detail: "semantic_token_source.dart",
            filePath: SEMANTIC_TEST_FILE_PATH,
            range: Range(
              start: Position(line: 29, character: 0),
              end: Position(line: 29, character: 21),
            ),
            selectionRange: Range(
              start: Position(line: 29, character: 5),
              end: Position(line: 29, character: 16),
            ),
            data: null,
          ),
        );
        expect(_itemThatIsCalled.fromRanges, isNotEmpty);
        expect(_itemThatIsCalled.fromRanges.length, 1);
        expect(
          _itemThatIsCalled.fromRanges.first,
          Range(
            start: Position(line: 26, character: 2),
            end: Position(line: 26, character: 13),
          ),
        );
      });
    });

    // =========================================================================
    // =========================================================================
    // =========================================================================

    group("Type Hierarchy", () {
      test('Prepare Type hierarchy', () async {
        final LspSurface surface = await init();
        PrepareHierarchyResponse r = await surface.textDocument_prepareTypeHierarchy(
          kTestClassPosition,
        );
        surface.dispose();

        expect(r.items.length, 1);

        expect(
          r.items.first,
          HierarchyItem(
            name: "TestClass",
            kind: SymbolKind.property,
            tags: null,
            detail: null,
            filePath: SEMANTIC_TEST_FILE_PATH,
            range: Range(
              start: Position(line: 4, character: 0),
              end: Position(line: 13, character: 1),
            ),
            selectionRange: Range(
              start: Position(line: 5, character: 6),
              end: Position(line: 5, character: 15),
            ),
            data: {
              "ref":
                  "file:///Users/omni/repos/package/lsp/test/_test_data/semantic_token_source.dart;file:///Users/omni/repos/package/lsp/test/_test_data/semantic_token_source.dart;TestClass",
            },
          ),
        );
      });
    });
  });
}
