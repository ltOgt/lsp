import 'package:lsp/src/surface/param/range.dart';
import 'package:lsp/src/surface/response/base_response.dart';
import 'package:lsp/src/surface/response/text_document/hierarchy/prepare_hierarchy_response.dart';

/// The result of a "callHierarchy/outgoingCalls" request.
///
/// See [CallHierarchyOutgoingCall] for details.
class OutgoingCallResponse extends BaseResponse {
  late final List<CallHierarchyOutgoingCall> calls;

  /// The caller for which the outgoing calls where requested.
  /// [CallHierarchyOutgoingCall.fromRanges] are relative to this.
  final HierarchyItem from;

  OutgoingCallResponse({
    required LspResponse response,
    required this.from,
  }) : super(response: response) {
    calls = response.results?.map(CallHierarchyOutgoingCall.fromJson).toList() ?? [];
  }
}

/// Contains [Range]s ([fromRanges], relative to the caller used for the request)
/// from which the [HierarchyItem] ([to]) is called.
///
/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#callHierarchyOutgoingCall
class CallHierarchyOutgoingCall {
  /// The item that is called.
  final HierarchyItem to;

  /// The range at which this item is called.
  /// This is the range relative to the caller,
  /// e.g the item passed to `callHierarchy/outgoingCalls` request.
  ///
  /// See [OutgoingCallResponse.from]
  final List<Range> fromRanges;

  CallHierarchyOutgoingCall({
    required this.to,
    required this.fromRanges,
  });

  // ===========================================================================

  static const _kTo = "to";
  static const _kFromRanges = "fromRanges";

  Map toJson() => json;
  Map get json => {
        _kTo: to.json,
        _kFromRanges: fromRanges.map((e) => e.json).toList(),
      };

  static CallHierarchyOutgoingCall fromJson(Map map) => CallHierarchyOutgoingCall(
        to: HierarchyItem.fromJson(map[_kTo] as Map<String, dynamic>),
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
