import 'package:lsp/src/object/file/file_location.dart';
import 'package:lsp/src/object/file/file_position.dart';
import 'package:lsp/src/object/file/file_range.dart';
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
        String uri = location["uri"];
        String path = uri.split("file://")[1];

        Map _range = location["range"];
        Map _start = _range["start"];
        Map _end = _range["end"];

        return FileLocation(
          path: path,
          range: FileRange(
            start: FilePosition(
              line: _start["line"],
              character: _start["character"],
            ),
            end: FilePosition(
              line: _end["line"],
              character: _end["character"],
            ),
          ),
        );
      },
    ).toList();
  }
}
