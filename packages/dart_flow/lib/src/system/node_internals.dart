import '../types/models.dart';
import '../system/xypanzoom.dart';

class FlowHandleMetrics {
  const FlowHandleMetrics({
    required this.nodeId,
    required this.handle,
    required this.bounds,
    required this.center,
    required this.lookupId,
  });

  final String nodeId;
  final FlowHandle handle;
  final Rect bounds;
  final XYPosition center;
  final String lookupId;
}

class FlowNodeInternals {
  const FlowNodeInternals({
    required this.node,
    required this.bounds,
    required this.sourceHandles,
    required this.targetHandles,
    required this.handleLookup,
  });

  final FlowNode node;
  final Rect bounds;
  final List<FlowHandleMetrics> sourceHandles;
  final List<FlowHandleMetrics> targetHandles;
  final Map<String, FlowHandleMetrics> handleLookup;

  FlowHandleMetrics? getHandle(HandleType type, [String? handleId]) {
    return handleLookup[_handleLookupId(node.id, type, handleId ?? '0')];
  }
}

FlowNodeInternals buildNodeInternals(FlowNode node) {
  final sourceHandles =
      _handlesForNode(node, HandleType.source, node.sourcePosition);
  final targetHandles =
      _handlesForNode(node, HandleType.target, node.targetPosition);
  final allHandles = <FlowHandleMetrics>[
    ...sourceHandles,
    ...targetHandles,
  ];

  return FlowNodeInternals(
    node: node,
    bounds: node.bounds,
    sourceHandles: List<FlowHandleMetrics>.unmodifiable(sourceHandles),
    targetHandles: List<FlowHandleMetrics>.unmodifiable(targetHandles),
    handleLookup: Map<String, FlowHandleMetrics>.unmodifiable({
      for (final handle in allHandles) handle.lookupId: handle,
    }),
  );
}

Map<String, FlowNodeInternals> buildNodeInternalsLookup(
    Iterable<FlowNode> nodes) {
  return Map<String, FlowNodeInternals>.unmodifiable({
    for (final node in nodes) node.id: buildNodeInternals(node),
  });
}

List<FlowNode> getNodesInsideViewport(
  Iterable<FlowNode> nodes, {
  required Viewport viewport,
  required double canvasWidth,
  required double canvasHeight,
}) {
  final viewportRect = viewportRectInFlow(
    viewport: viewport,
    canvasWidth: canvasWidth,
    canvasHeight: canvasHeight,
  );

  return nodes
      .where(
        (node) =>
            !node.hidden &&
            node.position.x < viewportRect.x2 &&
            node.position.x + node.width > viewportRect.x &&
            node.position.y < viewportRect.y2 &&
            node.position.y + node.height > viewportRect.y,
      )
      .toList(growable: false);
}

String handleLookupId(String nodeId, HandleType type, [String? handleId]) {
  return _handleLookupId(nodeId, type, handleId ?? '0');
}

List<FlowHandleMetrics> _handlesForNode(
  FlowNode node,
  HandleType type,
  Position fallbackPosition,
) {
  final explicit = node.handles
      .where((handle) => handle.type == type)
      .toList(growable: false);
  final handles = explicit.isNotEmpty
      ? explicit
      : <FlowHandle>[
          FlowHandle(type: type, position: fallbackPosition),
        ];

  return List<FlowHandleMetrics>.generate(handles.length, (index) {
    final handle = handles[index];
    final lookupId = _handleLookupId(node.id, type, handle.id ?? '$index');
    final center = _handleCenter(node, handle);
    return FlowHandleMetrics(
      nodeId: node.id,
      handle: handle,
      bounds: Rect(
        x: center.x - (handle.width / 2),
        y: center.y - (handle.height / 2),
        width: handle.width,
        height: handle.height,
      ),
      center: center,
      lookupId: lookupId,
    );
  }, growable: false);
}

XYPosition _handleCenter(FlowNode node, FlowHandle handle) {
  if (handle.x != 0 ||
      handle.y != 0 ||
      handle.width != 12 ||
      handle.height != 12) {
    return XYPosition(
      x: node.position.x + handle.x + (handle.width / 2),
      y: node.position.y + handle.y + (handle.height / 2),
    );
  }

  switch (handle.position) {
    case Position.left:
      return XYPosition(
          x: node.position.x, y: node.position.y + node.height / 2);
    case Position.top:
      return XYPosition(
          x: node.position.x + node.width / 2, y: node.position.y);
    case Position.right:
      return XYPosition(
        x: node.position.x + node.width,
        y: node.position.y + node.height / 2,
      );
    case Position.bottom:
      return XYPosition(
        x: node.position.x + node.width / 2,
        y: node.position.y + node.height,
      );
  }
}

String _handleLookupId(String nodeId, HandleType type, String handleId) {
  return '$nodeId:${type.name}:$handleId';
}
