import 'dart:async';
import 'dart:io';

import 'package:lsp/src/surface/lsp_surface.dart';

/// Base Class for Language Server Connectors.
///
/// Implement this interface to provide [LspSurface] with the LSP [Process]
abstract class LspConnectorBase {
  /// The ID that will be used by both the server ([Process]) and the client ([LspSurface]) to identify the connection.
  /// § "MyClientId"
  final String clientId;

  /// The version of the client that will be used by both the server ([Process]) and the client ([LspSurface]) to identify the connection.
  /// § "0.0.1"
  final String clientVersion;

  LspConnectorBase({
    required this.clientId,
    required this.clientVersion,
  });

  /// Launch the actual Language Server as an IO [Process].
  Future<Process> startProcess();
}
