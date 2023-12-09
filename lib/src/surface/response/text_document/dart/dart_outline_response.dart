// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';

/*
https://github.com/dart-lang/sdk/blob/main/pkg/analysis_server/tool/lsp_spec/README.md
________________________________________________________________________________________________________
init options

outline (bool?):        true => dart/textDocument/publishOutline notifications will be sent
					            with outline information for open files.
flutterOutline (bool?): true => dart/textDocument/publishFlutterOutline notifications will be sent
                                with Flutter outline information for open files.
________________________________________________________________________________________________________
dart/textDocument/publishOutline Notification

Direction: Server -> Client

Params:
  uri:            string
  outline:        Outline
Outline:
  element:        Element
  range:          Range
  codeRange:      Range
  children:       Outline[]
Element:
  name:           string
  range:          Range
  kind:           string
  parameters:     string | undefined
  typeParameters: string | undefined
  returnType:     string | undefined

Nodes contains multiple ranges:

element.range     the range of the name in the declaration of the element
range             the entire range of the declaration including dartdocs
codeRange         the range of code part of the declaration (excluding dartdocs and annotations)
                  typically used when navigating to the declaration
*/

/// Notification with [method] "dart/textDocument/publishOutline"
///
/// https://github.com/dart-lang/sdk/blob/main/pkg/analysis_server/tool/lsp_spec/README.md
class DartOutlineNotification {
  static const _kMethod = "dart/textDocument/publishOutline";

  final String jsonrpc;
  final String method;
  final DartOutlineNotificationParams params;

  const DartOutlineNotification({
    required this.jsonrpc,
    required this.method,
    required this.params,
  }) : assert(method == _kMethod);

  factory DartOutlineNotification.fromJson(Map json) {
    return DartOutlineNotification(
      jsonrpc: json['jsonrpc'],
      method: json['method'],
      params: DartOutlineNotificationParams.fromJson(json['params']),
    );
  }

  // ===========================================================================

  @override
  bool operator ==(covariant DartOutlineNotification other) {
    if (identical(this, other)) return true;

    return other.jsonrpc == jsonrpc && other.method == method && other.params == params;
  }

  @override
  int get hashCode => jsonrpc.hashCode ^ method.hashCode ^ params.hashCode;

  // ===========================================================================

  @override
  String toString() => 'DartOutlineNotification(jsonrpc: $jsonrpc, method: $method, params: $params)';
}

class DartOutlineNotificationParams {
  final String uri;
  final DartOutline outline;

  const DartOutlineNotificationParams({
    required this.uri,
    required this.outline,
  });

  factory DartOutlineNotificationParams.fromJson(Map<String, dynamic> json) {
    return DartOutlineNotificationParams(
      uri: json['uri'],
      outline: DartOutline.fromJson(json['outline']),
    );
  }

  // ===========================================================================

  @override
  bool operator ==(covariant DartOutlineNotificationParams other) {
    if (identical(this, other)) return true;

    return other.uri == uri && other.outline == outline;
  }

  @override
  int get hashCode => uri.hashCode ^ outline.hashCode;

  // ===========================================================================

  @override
  String toString() => 'DartOutlineNotificationParams(uri: $uri, outline: $outline)';
}

class DartOutline {
  final ElementDartOutline element;

  /// the entire range of the declaration including dartdocs
  final RangeDartOutline range;

  /// the range of code part of the declaration (excluding dartdocs and annotations)
  /// typically used when navigating to the declaration
  final RangeDartOutline codeRange;
  final List<DartOutline>? children;

  const DartOutline({
    required this.range,
    required this.codeRange,
    required this.element,
    this.children,
  });

  factory DartOutline.fromJson(Map<String, dynamic> json) {
    List<DartOutline>? children;
    if (json['children'] != null) {
      children = List<DartOutline>.from(json['children'].map((child) => DartOutline.fromJson(child)));
    }
    return DartOutline(
      element: ElementDartOutline.fromJson(json['element']),
      range: RangeDartOutline.fromJson(json['range']),
      codeRange: RangeDartOutline.fromJson(json['codeRange']),
      children: children,
    );
  }

  // ===========================================================================

  @override
  bool operator ==(covariant DartOutline other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.element == element &&
        other.range == range &&
        other.codeRange == codeRange &&
        listEquals(other.children, children);
  }

  @override
  int get hashCode {
    final listHash = const DeepCollectionEquality().hash;
    return element.hashCode ^ range.hashCode ^ codeRange.hashCode ^ listHash(children);
  }

  // ===========================================================================

  @override
  String toString() {
    return 'DartOutline(element: $element, range: $range, codeRange: $codeRange, children: $children,)';
  }
}

class ElementDartOutline {
  final String name;

  /// the range of the name in the declaration of the element
  final RangeDartOutline range;
  final String kind;
  final String? parameters;
  final String? typeParameters;
  final String? returnType;

  const ElementDartOutline({
    required this.name,
    required this.range,
    required this.kind,
    this.parameters,
    this.typeParameters,
    this.returnType,
  });

  factory ElementDartOutline.fromJson(Map<String, dynamic> json) {
    return ElementDartOutline(
      name: json['name'],
      range: RangeDartOutline.fromJson(json['range']),
      kind: json['kind'],
      parameters: json['parameters'],
      typeParameters: json['typeParameters'],
      returnType: json['returnType'],
    );
  }

  // ===========================================================================

  @override
  bool operator ==(covariant ElementDartOutline other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.range == range &&
        other.kind == kind &&
        other.parameters == parameters &&
        other.typeParameters == typeParameters &&
        other.returnType == returnType;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        range.hashCode ^
        kind.hashCode ^
        parameters.hashCode ^
        typeParameters.hashCode ^
        returnType.hashCode;
  }

  // ===========================================================================

  @override
  String toString() {
    return 'ElementDartOutline(name: "$name", range: $range, kind: "$kind", parameters: ${parameters == null ? null : '"$parameters"'}, typeParameters: ${typeParameters == null ? null : '"$typeParameters"'}, returnType: ${returnType == null ? null : '"$returnType"'},)';
  }
}

class RangeDartOutline {
  final TextPositionDartOutline start;
  final TextPositionDartOutline end;

  const RangeDartOutline({required this.start, required this.end});

  factory RangeDartOutline.fromJson(Map<String, dynamic> json) {
    return RangeDartOutline(
      start: TextPositionDartOutline.fromJson(json['start']),
      end: TextPositionDartOutline.fromJson(json['end']),
    );
  }

  // ===========================================================================

  @override
  bool operator ==(covariant RangeDartOutline other) {
    if (identical(this, other)) return true;

    return other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;

  // ===========================================================================

  @override
  String toString() => 'RangeDartOutline(start: $start, end: $end,)';
}

class TextPositionDartOutline {
  final int character;
  final int line;

  const TextPositionDartOutline({required this.character, required this.line});

  factory TextPositionDartOutline.fromJson(Map<String, dynamic> json) {
    return TextPositionDartOutline(
      character: json['character'],
      line: json['line'],
    );
  }

  // ===========================================================================

  @override
  bool operator ==(covariant TextPositionDartOutline other) {
    if (identical(this, other)) return true;

    return other.character == character && other.line == line;
  }

  // ===========================================================================

  @override
  int get hashCode => character.hashCode ^ line.hashCode;

  @override
  String toString() => 'TextPositionDartOutline(character: $character, line: $line)';
}
