/// https://microsoft.github.io/kind-server-protocol/specifications/lsp/3.17/specification/#markupContent
class MarkupContent {
  final String kind;
  final String value;

  const MarkupContent({required this.kind, required this.value});

  // ===========================================================================

  Map toJson() => json;
  Map get json => {
        "kind": kind,
        "value": value,
      };

  static MarkupContent fromJson(dynamic value) {
    if (value is Map) {
      return MarkupContent(
        kind: value['kind'] as String,
        value: value['value'] as String,
      );
    }
    if (value is String) {
      return MarkupContent(
        kind: "plaintext",
        value: value,
      );
    }
    throw StateError("Unsupported type: $value");
  }

  // ===========================================================================

  @override
  bool operator ==(covariant MarkupContent other) {
    if (identical(this, other)) return true;

    return other.kind == kind && other.value == value;
  }

  @override
  int get hashCode => kind.hashCode ^ value.hashCode;

  // ===========================================================================

  @override
  String toString() => 'MarkedString(kind: $kind, value: $value)';
}
