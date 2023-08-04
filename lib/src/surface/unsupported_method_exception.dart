import 'package:lsp/lsp.dart';

/// The client requested a method that the server declared
/// to be incapable of completing.
///
/// Check [LspSurface.capabilities]
class UnsupportedMethodException {
  final String method;

  UnsupportedMethodException(this.method);
}
