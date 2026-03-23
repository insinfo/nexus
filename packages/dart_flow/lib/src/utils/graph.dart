import 'dart:math' as math;

import '../types/models.dart';

List<FlowNode> getIncomers(
  FlowNode node,
  Iterable<FlowNode> nodes,
  Iterable<FlowEdge> edges,
) {
  final incomingIds = edges
      .where((edge) => edge.target == node.id)
      .map((edge) => edge.source)
      .toSet();

  return nodes
      .where((candidate) => incomingIds.contains(candidate.id))
      .toList();
}

List<FlowNode> getOutgoers(
  FlowNode node,
  Iterable<FlowNode> nodes,
  Iterable<FlowEdge> edges,
) {
  final outgoingIds = edges
      .where((edge) => edge.source == node.id)
      .map((edge) => edge.target)
      .toSet();

  return nodes
      .where((candidate) => outgoingIds.contains(candidate.id))
      .toList();
}

List<FlowEdge> getConnectedEdges(
  Iterable<FlowNode> nodes,
  Iterable<FlowEdge> edges,
) {
  final nodeIds = nodes.map((node) => node.id).toSet();
  return edges
      .where((edge) =>
          nodeIds.contains(edge.source) || nodeIds.contains(edge.target))
      .toList();
}

Rect getNodesBounds(Iterable<FlowNode> nodes) {
  final visibleNodes = nodes.where((node) => !node.hidden).toList();
  if (visibleNodes.isEmpty) {
    return const Rect(x: 0, y: 0, width: 1, height: 1);
  }

  var minX = visibleNodes.first.position.x;
  var minY = visibleNodes.first.position.y;
  var maxX = visibleNodes.first.position.x + visibleNodes.first.width;
  var maxY = visibleNodes.first.position.y + visibleNodes.first.height;

  for (final node in visibleNodes.skip(1)) {
    minX = math.min(minX, node.position.x);
    minY = math.min(minY, node.position.y);
    maxX = math.max(maxX, node.position.x + node.width);
    maxY = math.max(maxY, node.position.y + node.height);
  }

  return Rect(
    x: minX,
    y: minY,
    width: math.max(1, maxX - minX),
    height: math.max(1, maxY - minY),
  );
}

Viewport getViewportForBounds(
  Rect bounds, {
  required double width,
  required double height,
  double minZoom = 0.2,
  double maxZoom = 1.8,
  double padding = 0.12,
}) {
  final paddedWidth = bounds.width * (1 + padding * 2);
  final paddedHeight = bounds.height * (1 + padding * 2);

  final zoomX = width / paddedWidth;
  final zoomY = height / paddedHeight;
  final zoom = clampDouble(math.min(zoomX, zoomY), minZoom, maxZoom);
  final offsetX = ((width - (bounds.width * zoom)) / 2) - (bounds.x * zoom);
  final offsetY = ((height - (bounds.height * zoom)) / 2) - (bounds.y * zoom);

  return Viewport(x: offsetX, y: offsetY, zoom: zoom);
}

List<FlowEdge> addEdge(
  FlowConnection connection,
  List<FlowEdge> edges, {
  String? id,
  ConnectionLineType type = ConnectionLineType.bezier,
  MarkerType? markerEnd = MarkerType.arrowClosed,
}) {
  final next = List<FlowEdge>.from(edges);
  next.add(
    FlowEdge(
      id: id ?? '${connection.source}-${connection.target}-${edges.length + 1}',
      source: connection.source,
      target: connection.target,
      sourceHandle: connection.sourceHandle,
      targetHandle: connection.targetHandle,
      type: type,
      markerEnd: markerEnd,
    ),
  );
  return next;
}

List<FlowEdge> reconnectEdge(
  FlowEdge edge,
  FlowConnection connection,
  List<FlowEdge> edges,
) {
  return edges
      .map(
        (candidate) => candidate.id == edge.id
            ? candidate.copyWith(
                source: connection.source,
                target: connection.target,
                sourceHandle: connection.sourceHandle,
                targetHandle: connection.targetHandle,
              )
            : candidate,
      )
      .toList();
}
