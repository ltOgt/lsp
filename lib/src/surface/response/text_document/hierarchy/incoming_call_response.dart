import 'package:lsp/src/surface/param/file_range.dart';
import 'package:lsp/src/surface/response/base_response.dart';
import 'package:lsp/src/surface/response/text_document/hierarchy/prepare_hierarchy_response.dart';

/// The result of a "callHierarchy/incomingCalls" request.
///
/// See [CallHierarchyIncomingCall] for details.
class IncomingCallResponse extends BaseResponse {
  late final List<CallHierarchyIncomingCall> calls;

  final HierarchyItem to;

  IncomingCallResponse({
    required LspResponse response,
    required this.to,
  }) : super(response: response) {
    calls = response.results?.map(CallHierarchyIncomingCall.fromJson).toList() ?? [];
  }
}

/// Contains [FileRange]s ([fromRanges]) from which the requesting item
/// [IncomingCallResponse.to] is called.
///
/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#callHierarchyIncomingCall
class CallHierarchyIncomingCall {
  /// The item that makes the call to [IncomingCallResponse.to]
  final HierarchyItem from;

  /// The ranges at which the calls appear.
  /// This is relative to the caller: [from].
  final List<FileRange> fromRanges;

  CallHierarchyIncomingCall({
    required this.from,
    required this.fromRanges,
  });

  // ===========================================================================

  static const _kFrom = "from";
  static const _kFromRanges = "fromRanges";

  Map toJson() => json;
  Map get json => {
        _kFrom: from.json,
        _kFromRanges: fromRanges.map((e) => e.json).toList(),
      };

  static CallHierarchyIncomingCall fromJson(Map map) => CallHierarchyIncomingCall(
        from: HierarchyItem.fromJson(map[_kFrom] as Map<String, dynamic>),
        fromRanges: _decodeRanges(map),
      );

  static List<FileRange> _decodeRanges(Map map) {
    final list = map[_kFromRanges] as List;
    list.cast<Map>();
    return list.map((e) {
      return FileRange.fromJson(e as Map<String, dynamic>);
    }).toList();
  }
}
