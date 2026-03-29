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
  final usaCoordenadasExplicitas = handle != null &&
      (handle.x != 0 ||
          handle.y != 0 ||
          handle.width != 12 ||
          handle.height != 12);

  if (usaCoordenadasExplicitas) {
    final x = node.position.x + handle.x;
    final y = node.position.y + handle.y;

    switch (handle.position) {
      case Position.left:
        return XYPosition(x: x, y: y + (handle.height / 2));
      case Position.top:
        return XYPosition(x: x + (handle.width / 2), y: y);
      case Position.right:
        return XYPosition(x: x + handle.width, y: y + (handle.height / 2));
      case Position.bottom:
        return XYPosition(x: x + (handle.width / 2), y: y + handle.height);
    }
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
  double borderRadius = 5,
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

  final path = _getRoundedPath(points, borderRadius);

  return EdgePathResult(
    path: path,
    labelX: centerX,
    labelY: centerY,
    offsetX: (centerX - sourceX).abs(),
    offsetY: (centerY - sourceY).abs(),
  );
}

String _getRoundedPath(List<XYPosition> points, double radius) {
  // Filter out duplicate consecutive points to avoid division by zero
  final filteredPoints = <XYPosition>[];
  for (final p in points) {
    if (filteredPoints.isEmpty ||
        (filteredPoints.last.x != p.x || filteredPoints.last.y != p.y)) {
      filteredPoints.add(p);
    }
  }

  if (filteredPoints.length < 2) return '';
  final commands = <String>[
    'M ${filteredPoints.first.x},${filteredPoints.first.y}'
  ];

  for (var i = 1; i < filteredPoints.length; i++) {
    final p0 = filteredPoints[i - 1];
    final p1 = filteredPoints[i];
    final p2 = i < filteredPoints.length - 1 ? filteredPoints[i + 1] : null;

    if (p2 == null || radius <= 0) {
      commands.add('L ${p1.x},${p1.y}');
    } else {
      final v10 = XYPosition(x: p0.x - p1.x, y: p0.y - p1.y);
      final v12 = XYPosition(x: p2.x - p1.x, y: p2.y - p1.y);

      final d10 = math.sqrt(v10.x * v10.x + v10.y * v10.y);
      final d12 = math.sqrt(v12.x * v12.x + v12.y * v12.y);

      if (d10 == 0 || d12 == 0) {
        commands.add('L ${p1.x},${p1.y}');
        continue;
      }

      final r = math.min(radius, math.min(d10, d12) / 2);

      final start = XYPosition(
        x: p1.x + v10.x * (r / d10),
        y: p1.y + v10.y * (r / d10),
      );
      final end = XYPosition(
        x: p1.x + v12.x * (r / d12),
        y: p1.y + v12.y * (r / d12),
      );

      commands.add('L ${start.x},${start.y}');
      commands.add('Q ${p1.x},${p1.y} ${end.x},${end.y}');
    }
  }

  return commands.join(' ');
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
