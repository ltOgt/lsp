import 'package:lsp/src/surface/response/base_response.dart';
import 'package:lsp/src/surface/response/text_document/hierarchy/prepare_hierarchy_response.dart';

/// The result of one of
/// - "typeHierarchy/superTypes" ([kind] is [HierarchyItemsResponseKind.superType])
/// - "typeHierarchy/subTypes" ([kind] is [HierarchyItemsResponseKind.subType])
///
/// Contains a list of [items] for that have the relation of [kind] to the requester "[from]".
class HierarchyItemsResponse extends BaseResponse {
  late final List<HierarchyItem> items;

  /// The [HierarchyItem] of the type for which super or sub type was requested.
  ///
  /// [CallHierarchyOutgoingCall.fromRanges] are relative to this.
  final HierarchyItem from;

  /// The type of request that caused this response.
  final HierarchyItemsResponseKind kind;

  HierarchyItemsResponse({
    required LspResponse response,
    required this.from,
    required this.kind,
  }) : super(response: response) {
    items = response.results?.map(HierarchyItem.fromJson).toList() ?? [];
  }
}

enum HierarchyItemsResponseKind {
  superType,
  subType;
}
