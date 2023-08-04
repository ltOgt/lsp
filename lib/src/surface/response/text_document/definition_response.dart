import 'package:lsp/src/surface/param/file_location.dart';
import 'package:lsp/src/surface/response/base_response.dart';

/// ```
/// [
///   {
///     "uri" : file://<path>,
///     "range" : {
///       "start": {
///         "line" : <line>,
///         "character": <character>
///       },
///       "end": {
///         "line" : <line>,
///         "character": <character>
///       }
///     }
///   },
///   ...
/// ]
/// ```
class DefinitionResponse extends BaseResponse {
  late final List<FileLocation> fileLocations;

  DefinitionResponse({
    required LspResponse response,
  }) : super(response: response) {
    fileLocations = (response.results!).map(
      (Map location) {
        return FileLocation.fromJson(location);
      },
    ).toList();
  }
}
