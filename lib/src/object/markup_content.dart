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

  static MarkupContent fromJson(Map map) {
    return MarkupContent(
      kind: map['kind'] as String,
      value: map['value'] as String,
    );
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
