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
class LocationsResponse extends BaseResponse {
  late final List<FileLocation> fileLocations;

  LocationsResponse({
    required LspResponse response,
  }) : super(response: response) {
    fileLocations = response.results?.map(FileLocation.fromJson).toList() ?? [];
  }
}
