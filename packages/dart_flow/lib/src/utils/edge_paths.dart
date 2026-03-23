import 'dart:math' as math;

import '../types/models.dart';

FlowHandle? getNodeHandle(
  FlowNode node,
  HandleType type,
  String? handleId,
) {
  final typedHandles = node.handles
      .where((handle) => handle.type == type)
      .toList(growable: false);
  if (typedHandles.isEmpty) {
    return null;
  }

  if (handleId == null) {
    return typedHandles.first;
  }

  for (final handle in typedHandles) {
    if (handle.id == handleId) {
      return handle;
    }
  }

  return typedHandles.first;
}

EdgePosition? getEdgePosition(FlowEdge edge, List<FlowNode> nodes) {
  final sourceNode = nodes.where((node) => node.id == edge.source).firstOrNull;
  final targetNode = nodes.where((node) => node.id == edge.target).firstOrNull;
  if (sourceNode == null || targetNode == null) {
    return null;
  }

  final sourceHandle =
      getNodeHandle(sourceNode, HandleType.source, edge.sourceHandle);
  final targetHandle =
      getNodeHandle(targetNode, HandleType.target, edge.targetHandle);
  final sourcePosition = sourceHandle?.position ?? sourceNode.sourcePosition;
  final targetPosition = targetHandle?.position ?? targetNode.targetPosition;
  final source = getNodeConnectionPoint(
    sourceNode,
    sourcePosition,
    handle: sourceHandle,
  );
  final target = getNodeConnectionPoint(
    targetNode,
    targetPosition,
    handle: targetHandle,
  );

  return EdgePosition(
    sourceX: source.x,
    sourceY: source.y,
    targetX: target.x,
    targetY: target.y,
    sourcePosition: sourcePosition,
    targetPosition: targetPosition,
  );
}

XYPosition getNodeConnectionPoint(
  FlowNode node,
  Position position, {
  FlowHandle? handle,
}) {
  if (handle != null) {
    return XYPosition(
      x: node.position.x + handle.x + (handle.width / 2),
      y: node.position.y + handle.y + (handle.height / 2),
    );
  }

  switch (position) {
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

EdgePathResult getEdgeCenter({
  required double sourceX,
  required double sourceY,
  required double targetX,
  required double targetY,
}) {
  final labelX = (sourceX + targetX) / 2;
  final labelY = (sourceY + targetY) / 2;

  return EdgePathResult(
    path: 'M $sourceX,$sourceY L $targetX,$targetY',
    labelX: labelX,
    labelY: labelY,
    offsetX: (labelX - sourceX).abs(),
    offsetY: (labelY - sourceY).abs(),
  );
}

double _calculateControlOffset(double distance, double curvature) {
  if (distance >= 0) {
    return 0.5 * distance;
  }

  return curvature * 25 * math.sqrt(-distance);
}

XYPosition _getControlPoint({
  required Position pos,
  required double x1,
  required double y1,
  required double x2,
  required double y2,
  required double curvature,
}) {
  switch (pos) {
    case Position.left:
      return XYPosition(
        x: x1 - _calculateControlOffset(x1 - x2, curvature),
        y: y1,
      );
    case Position.right:
      return XYPosition(
        x: x1 + _calculateControlOffset(x2 - x1, curvature),
        y: y1,
      );
    case Position.top:
      return XYPosition(
        x: x1,
        y: y1 - _calculateControlOffset(y1 - y2, curvature),
      );
    case Position.bottom:
      return XYPosition(
        x: x1,
        y: y1 + _calculateControlOffset(y2 - y1, curvature),
      );
  }
}

EdgePathResult getBezierPath({
  required double sourceX,
  required double sourceY,
  Position sourcePosition = Position.bottom,
  required double targetX,
  required double targetY,
  Position targetPosition = Position.top,
  double curvature = 0.25,
}) {
  final sourceControl = _getControlPoint(
    pos: sourcePosition,
    x1: sourceX,
    y1: sourceY,
    x2: targetX,
    y2: targetY,
    curvature: curvature,
  );
  final targetControl = _getControlPoint(
    pos: targetPosition,
    x1: targetX,
    y1: targetY,
    x2: sourceX,
    y2: sourceY,
    curvature: curvature,
  );

  final labelX = (sourceX * 0.125) +
      (sourceControl.x * 0.375) +
      (targetControl.x * 0.375) +
      (targetX * 0.125);
  final labelY = (sourceY * 0.125) +
      (sourceControl.y * 0.375) +
      (targetControl.y * 0.375) +
      (targetY * 0.125);

  return EdgePathResult(
    path:
        'M$sourceX,$sourceY C${sourceControl.x},${sourceControl.y} ${targetControl.x},${targetControl.y} $targetX,$targetY',
    labelX: labelX,
    labelY: labelY,
    offsetX: (labelX - sourceX).abs(),
    offsetY: (labelY - sourceY).abs(),
  );
}

EdgePathResult getStraightPath({
  required double sourceX,
  required double sourceY,
  required double targetX,
  required double targetY,
}) {
  final center = getEdgeCenter(
    sourceX: sourceX,
    sourceY: sourceY,
    targetX: targetX,
    targetY: targetY,
  );
  return EdgePathResult(
    path: 'M $sourceX,$sourceY L $targetX,$targetY',
    labelX: center.labelX,
    labelY: center.labelY,
    offsetX: center.offsetX,
    offsetY: center.offsetY,
  );
}

EdgePathResult getSmoothStepPath({
  required double sourceX,
  required double sourceY,
  Position sourcePosition = Position.bottom,
  required double targetX,
  required double targetY,
  Position targetPosition = Position.top,
  double offset = 24,
  double stepPosition = 0.5,
}) {
  final sourceGap = _applyOffset(sourceX, sourceY, sourcePosition, offset);
  final targetGap = _applyOffset(targetX, targetY, targetPosition, offset);

  final horizontal =
      sourcePosition == Position.left || sourcePosition == Position.right;
  final centerX = horizontal
      ? sourceGap.x + ((targetGap.x - sourceGap.x) * stepPosition)
      : (sourceGap.x + targetGap.x) / 2;
  final centerY = horizontal
      ? (sourceGap.y + targetGap.y) / 2
      : sourceGap.y + ((targetGap.y - sourceGap.y) * stepPosition);

  final points = <XYPosition>[
    XYPosition(x: sourceX, y: sourceY),
    sourceGap,
    if (horizontal) XYPosition(x: centerX, y: sourceGap.y),
    if (horizontal) XYPosition(x: centerX, y: targetGap.y),
    if (!horizontal) XYPosition(x: sourceGap.x, y: centerY),
    if (!horizontal) XYPosition(x: targetGap.x, y: centerY),
    targetGap,
    XYPosition(x: targetX, y: targetY),
  ];

  final commands = <String>['M ${points.first.x},${points.first.y}'];
  for (final point in points.skip(1)) {
    commands.add('L ${point.x},${point.y}');
  }

  return EdgePathResult(
    path: commands.join(' '),
    labelX: centerX,
    labelY: centerY,
    offsetX: (centerX - sourceX).abs(),
    offsetY: (centerY - sourceY).abs(),
  );
}

EdgePathResult getSimpleBezierPath({
  required double sourceX,
  required double sourceY,
  Position sourcePosition = Position.bottom,
  required double targetX,
  required double targetY,
  Position targetPosition = Position.top,
}) {
  return getBezierPath(
    sourceX: sourceX,
    sourceY: sourceY,
    sourcePosition: sourcePosition,
    targetX: targetX,
    targetY: targetY,
    targetPosition: targetPosition,
    curvature: 0.12,
  );
}

XYPosition _applyOffset(double x, double y, Position position, double offset) {
  switch (position) {
    case Position.left:
      return XYPosition(x: x - offset, y: y);
    case Position.top:
      return XYPosition(x: x, y: y - offset);
    case Position.right:
      return XYPosition(x: x + offset, y: y);
    case Position.bottom:
      return XYPosition(x: x, y: y + offset);
  }
}

extension FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) {
      return null;
    }
    return first;
  }
}
