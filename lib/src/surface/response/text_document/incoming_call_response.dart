import 'package:lsp/lsp.dart';
import 'package:lsp/src/surface/response/base_response.dart';

/// The result of a "textDocument/hover" request.
///
/// See [CallHierarchyIncomingCall] for details.
class IncomingCallResponse extends BaseResponse {
  late final List<CallHierarchyIncomingCall> calls;

  IncomingCallResponse({
    required LspResponse response,
  }) : super(response: response) {
    calls = response.results?.map(CallHierarchyIncomingCall.fromJson).toList() ?? [];
  }
}

/// Contains [Range]s ([fromRanges]) from which the
/// [CallHierarchyItem] ([from]) is called.
///
/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#callHierarchyIncomingCall
class CallHierarchyIncomingCall {
  /// The item that makes the call.
  final CallHierarchyItem from;

  /// The ranges at which the calls appear. This is relative to the caller
  /// denoted by [`this.from`](#CallHierarchyIncomingCall.from).
  final List<Range> fromRanges;

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
        from: CallHierarchyItem.fromJson(map[_kFrom] as Map<String, dynamic>),
        fromRanges: _decodeRanges(map),
      );

  static List<Range> _decodeRanges(Map map) {
    final list = map[_kFromRanges] as List;
    list.cast<Map>();
    return list.map((e) {
      return Range.fromJson(e as Map<String, dynamic>);
    }).toList();
  }
}
