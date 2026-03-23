import '../types/changes.dart';
import '../types/models.dart';

List<FlowNode> applyNodeChanges(
  List<FlowNodeChange> changes,
  List<FlowNode> nodes,
) {
  var next = List<FlowNode>.from(nodes);

  for (final change in changes) {
    if (change is FlowNodePositionChange) {
      next = next
          .map(
            (node) => node.id == change.id
                ? node.copyWith(position: change.position)
                : node,
          )
          .toList();
      continue;
    }

    if (change is FlowNodeSelectionChange) {
      next = next
          .map(
            (node) => node.id == change.id
                ? node.copyWith(selected: change.selected)
                : node,
          )
          .toList();
      continue;
    }

    if (change is FlowNodeRemoveChange) {
      next.removeWhere((node) => node.id == change.id);
      continue;
    }

    if (change is FlowNodeAddChange) {
      next.add(change.item);
      continue;
    }

    if (change is FlowNodeReplaceChange) {
      next = next
          .map((node) => node.id == change.id ? change.item : node)
          .toList();
    }
  }

  return next;
}

List<FlowEdge> applyEdgeChanges(
  List<FlowEdgeChange> changes,
  List<FlowEdge> edges,
) {
  var next = List<FlowEdge>.from(edges);

  for (final change in changes) {
    if (change is FlowEdgeSelectionChange) {
      next = next
          .map(
            (edge) => edge.id == change.id
                ? edge.copyWith(selected: change.selected)
                : edge,
          )
          .toList();
      continue;
    }

    if (change is FlowEdgeRemoveChange) {
      next.removeWhere((edge) => edge.id == change.id);
      continue;
    }

    if (change is FlowEdgeAddChange) {
      next.add(change.item);
      continue;
    }

    if (change is FlowEdgeReplaceChange) {
      next = next
          .map((edge) => edge.id == change.id ? change.item : edge)
          .toList();
    }
  }

  return next;
}
