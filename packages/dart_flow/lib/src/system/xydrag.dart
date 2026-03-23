import '../types/models.dart';

class XYDragConfig {
  const XYDragConfig({
    this.snapToGrid = false,
    this.snapGrid = const XYPosition(x: 16, y: 16),
    this.extent,
    this.autoPan = false,
    this.autoPanPadding = 40,
    this.autoPanStep = 16,
  });

  final bool snapToGrid;
  final XYPosition snapGrid;
  final Rect? extent;
  final bool autoPan;
  final double autoPanPadding;
  final double autoPanStep;
}

class XYDragResult {
  const XYDragResult({
    required this.position,
    required this.viewportDelta,
  });

  final XYPosition position;
  final XYPosition viewportDelta;
}

class XYMultiDragResult {
  const XYMultiDragResult({
    required this.positions,
    required this.viewportDelta,
  });

  final Map<String, XYPosition> positions;
  final XYPosition viewportDelta;
}

Rect selectionRectFromPoints(XYPosition start, XYPosition end) {
  final left = start.x < end.x ? start.x : end.x;
  final top = start.y < end.y ? start.y : end.y;
  final right = start.x > end.x ? start.x : end.x;
  final bottom = start.y > end.y ? start.y : end.y;

  return Rect(
    x: left,
    y: top,
    width: right - left,
    height: bottom - top,
  );
}

Set<String> selectNodesWithinRect(Iterable<FlowNode> nodes, Rect rect) {
  return nodes
      .where(
        (node) =>
            node.position.x < rect.x2 &&
            node.position.x + node.width > rect.x &&
            node.position.y < rect.y2 &&
            node.position.y + node.height > rect.y,
      )
      .map((node) => node.id)
      .toSet();
}

XYDragResult computeDraggedNodePosition({
  required XYPosition startPosition,
  required XYPosition startPointer,
  required XYPosition currentPointer,
  required Viewport viewport,
  required Dimensions nodeDimensions,
  required double canvasWidth,
  required double canvasHeight,
  XYDragConfig config = const XYDragConfig(),
}) {
  final dx = (currentPointer.x - startPointer.x) / viewport.zoom;
  final dy = (currentPointer.y - startPointer.y) / viewport.zoom;

  var next = startPosition.translate(dx, dy);
  next = _applySnap(next, config);
  next = _applyExtent(next, nodeDimensions, config.extent);

  final viewportDelta = _computeAutoPan(
    currentPointer: currentPointer,
    canvasWidth: canvasWidth,
    canvasHeight: canvasHeight,
    config: config,
  );

  return XYDragResult(position: next, viewportDelta: viewportDelta);
}

XYMultiDragResult computeDraggedNodePositions({
  required String leadNodeId,
  required Map<String, XYPosition> startPositions,
  required Map<String, Dimensions> nodeDimensions,
  required XYPosition startPointer,
  required XYPosition currentPointer,
  required Viewport viewport,
  required double canvasWidth,
  required double canvasHeight,
  XYDragConfig config = const XYDragConfig(),
}) {
  final leadStartPosition = startPositions[leadNodeId];
  final leadDimensions = nodeDimensions[leadNodeId];
  if (leadStartPosition == null || leadDimensions == null) {
    return const XYMultiDragResult(
      positions: <String, XYPosition>{},
      viewportDelta: XYPosition(x: 0, y: 0),
    );
  }

  final leadResult = computeDraggedNodePosition(
    startPosition: leadStartPosition,
    startPointer: startPointer,
    currentPointer: currentPointer,
    viewport: viewport,
    nodeDimensions: leadDimensions,
    canvasWidth: canvasWidth,
    canvasHeight: canvasHeight,
    config: config,
  );

  final deltaX = leadResult.position.x - leadStartPosition.x;
  final deltaY = leadResult.position.y - leadStartPosition.y;

  final positions = <String, XYPosition>{};
  for (final entry in startPositions.entries) {
    final dimensions = nodeDimensions[entry.key];
    if (dimensions == null) {
      continue;
    }

    var next = entry.value.translate(deltaX, deltaY);
    next = _applyExtent(next, dimensions, config.extent);
    positions[entry.key] = next;
  }

  return XYMultiDragResult(
    positions: Map<String, XYPosition>.unmodifiable(positions),
    viewportDelta: leadResult.viewportDelta,
  );
}

XYPosition _applySnap(XYPosition position, XYDragConfig config) {
  if (!config.snapToGrid) {
    return position;
  }

  final gridX = config.snapGrid.x <= 0 ? 1.0 : config.snapGrid.x;
  final gridY = config.snapGrid.y <= 0 ? 1.0 : config.snapGrid.y;

  return XYPosition(
    x: (position.x / gridX).round() * gridX,
    y: (position.y / gridY).round() * gridY,
  );
}

XYPosition _applyExtent(
  XYPosition position,
  Dimensions nodeDimensions,
  Rect? extent,
) {
  if (extent == null) {
    return position;
  }

  final maxX = extent.x + extent.width - nodeDimensions.width;
  final maxY = extent.y + extent.height - nodeDimensions.height;

  return XYPosition(
    x: clampDouble(position.x, extent.x, maxX < extent.x ? extent.x : maxX),
    y: clampDouble(position.y, extent.y, maxY < extent.y ? extent.y : maxY),
  );
}

XYPosition _computeAutoPan({
  required XYPosition currentPointer,
  required double canvasWidth,
  required double canvasHeight,
  required XYDragConfig config,
}) {
  if (!config.autoPan) {
    return const XYPosition(x: 0, y: 0);
  }

  var dx = 0.0;
  var dy = 0.0;

  if (currentPointer.x < config.autoPanPadding) {
    dx = config.autoPanStep;
  } else if (currentPointer.x > canvasWidth - config.autoPanPadding) {
    dx = -config.autoPanStep;
  }

  if (currentPointer.y < config.autoPanPadding) {
    dy = config.autoPanStep;
  } else if (currentPointer.y > canvasHeight - config.autoPanPadding) {
    dy = -config.autoPanStep;
  }

  return XYPosition(x: dx, y: dy);
}
