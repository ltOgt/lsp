/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
enum SymbolKind {
  file(1),
  module(2),
  namespace(3),
  package(4),
  class_(5),
  method(6),
  property(7),
  field(8),
  constructor(9),
  enum_(10),
  interface(11),
  function(12),
  variable(13),
  constant(14),
  string(15),
  number(16),
  boolean(17),
  array(18),
  object(19),
  key(20),
  null_(21),
  enumMember(22),
  struct(23),
  event(24),
  operator(25),
  typeParameter(26);

  const SymbolKind(this.value);
  final int value;

  static SymbolKind fromValue(int value) => SymbolKind.values[value - 1];
}

enum SymbolTag {
  deprecated(1);

  const SymbolTag(this.value);
  final int value;

  static SymbolTag fromValue(int value) => SymbolTag.values[value - 1];
}
