import 'dart:math' as math;

enum Position {
  left,
  top,
  right,
  bottom,
}

enum ConnectionLineType {
  bezier,
  straight,
  step,
  smoothStep,
  simpleBezier,
}

enum MarkerType {
  arrow,
  arrowClosed,
}

enum HandleType {
  source,
  target,
}

enum PanelPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class XYPosition {
  const XYPosition({required this.x, required this.y});

  final double x;
  final double y;

  XYPosition copyWith({double? x, double? y}) {
    return XYPosition(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  XYPosition translate(double dx, double dy) {
    return XYPosition(x: x + dx, y: y + dy);
  }
}

class Dimensions {
  const Dimensions({required this.width, required this.height});

  final double width;
  final double height;
}

class Rect {
  const Rect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;

  double get x2 => x + width;
  double get y2 => y + height;

  Rect inflate(double value) {
    return Rect(
      x: x - value,
      y: y - value,
      width: width + (value * 2),
      height: height + (value * 2),
    );
  }
}

class Viewport {
  const Viewport({
    this.x = 0,
    this.y = 0,
    this.zoom = 1,
  });

  final double x;
  final double y;
  final double zoom;

  Viewport copyWith({double? x, double? y, double? zoom}) {
    return Viewport(
      x: x ?? this.x,
      y: y ?? this.y,
      zoom: zoom ?? this.zoom,
    );
  }
}

class FlowHandle {
  const FlowHandle({
    this.id,
    required this.type,
    required this.position,
    this.x = 0,
    this.y = 0,
    this.width = 12,
    this.height = 12,
  });

  final String? id;
  final HandleType type;
  final Position position;
  final double x;
  final double y;
  final double width;
  final double height;
}

class FlowNode {
  const FlowNode({
    required this.id,
    required this.position,
    this.data = const <String, Object?>{},
    this.type,
    this.hidden = false,
    this.selected = false,
    this.dragging = false,
    this.draggable = true,
    this.selectable = true,
    this.connectable = true,
    this.deletable = true,
    this.width = 180,
    this.height = 56,
    this.sourcePosition = Position.right,
    this.targetPosition = Position.left,
    this.parentId,
    this.zIndex = 0,
    this.ariaLabel,
    this.handles = const <FlowHandle>[],
  });

  final String id;
  final XYPosition position;
  final Map<String, Object?> data;
  final String? type;
  final bool hidden;
  final bool selected;
  final bool dragging;
  final bool draggable;
  final bool selectable;
  final bool connectable;
  final bool deletable;
  final double width;
  final double height;
  final Position sourcePosition;
  final Position targetPosition;
  final String? parentId;
  final int zIndex;
  final String? ariaLabel;
  final List<FlowHandle> handles;

  String get label {
    final value = data['label'];
    return value?.toString() ?? id;
  }

  Rect get bounds => Rect(
        x: position.x,
        y: position.y,
        width: width,
        height: height,
      );

  FlowNode copyWith({
    XYPosition? position,
    Map<String, Object?>? data,
    String? type,
    bool? hidden,
    bool? selected,
    bool? dragging,
    bool? draggable,
    bool? selectable,
    bool? connectable,
    bool? deletable,
    double? width,
    double? height,
    Position? sourcePosition,
    Position? targetPosition,
    String? parentId,
    int? zIndex,
    String? ariaLabel,
    List<FlowHandle>? handles,
  }) {
    return FlowNode(
      id: id,
      position: position ?? this.position,
      data: data ?? Map<String, Object?>.from(this.data),
      type: type ?? this.type,
      hidden: hidden ?? this.hidden,
      selected: selected ?? this.selected,
      dragging: dragging ?? this.dragging,
      draggable: draggable ?? this.draggable,
      selectable: selectable ?? this.selectable,
      connectable: connectable ?? this.connectable,
      deletable: deletable ?? this.deletable,
      width: width ?? this.width,
      height: height ?? this.height,
      sourcePosition: sourcePosition ?? this.sourcePosition,
      targetPosition: targetPosition ?? this.targetPosition,
      parentId: parentId ?? this.parentId,
      zIndex: zIndex ?? this.zIndex,
      ariaLabel: ariaLabel ?? this.ariaLabel,
      handles: handles ?? List<FlowHandle>.from(this.handles),
    );
  }
}

class FlowEdge {
  const FlowEdge({
    required this.id,
    required this.source,
    required this.target,
    this.sourceHandle,
    this.targetHandle,
    this.type = ConnectionLineType.bezier,
    this.customType,
    this.animated = false,
    this.hidden = false,
    this.deletable = true,
    this.selectable = true,
    this.data = const <String, Object?>{},
    this.selected = false,
    this.markerStart,
    this.markerEnd = MarkerType.arrowClosed,
    this.zIndex = 0,
    this.ariaLabel,
    this.interactionWidth = 16,
    this.label,
  });

  final String id;
  final String source;
  final String target;
  final String? sourceHandle;
  final String? targetHandle;
  final ConnectionLineType type;
  final String? customType;
  final bool animated;
  final bool hidden;
  final bool deletable;
  final bool selectable;
  final Map<String, Object?> data;
  final bool selected;
  final MarkerType? markerStart;
  final MarkerType? markerEnd;
  final int zIndex;
  final String? ariaLabel;
  final double interactionWidth;
  final String? label;

  FlowEdge copyWith({
    String? source,
    String? target,
    String? sourceHandle,
    String? targetHandle,
    ConnectionLineType? type,
    String? customType,
    bool? animated,
    bool? hidden,
    bool? deletable,
    bool? selectable,
    Map<String, Object?>? data,
    bool? selected,
    MarkerType? markerStart,
    MarkerType? markerEnd,
    int? zIndex,
    String? ariaLabel,
    double? interactionWidth,
    String? label,
  }) {
    return FlowEdge(
      id: id,
      source: source ?? this.source,
      target: target ?? this.target,
      sourceHandle: sourceHandle ?? this.sourceHandle,
      targetHandle: targetHandle ?? this.targetHandle,
      type: type ?? this.type,
      customType: customType ?? this.customType,
      animated: animated ?? this.animated,
      hidden: hidden ?? this.hidden,
      deletable: deletable ?? this.deletable,
      selectable: selectable ?? this.selectable,
      data: data ?? Map<String, Object?>.from(this.data),
      selected: selected ?? this.selected,
      markerStart: markerStart ?? this.markerStart,
      markerEnd: markerEnd ?? this.markerEnd,
      zIndex: zIndex ?? this.zIndex,
      ariaLabel: ariaLabel ?? this.ariaLabel,
      interactionWidth: interactionWidth ?? this.interactionWidth,
      label: label ?? this.label,
    );
  }
}

class FlowConnection {
  const FlowConnection({
    required this.source,
    required this.target,
    this.sourceHandle,
    this.targetHandle,
  });

  final String source;
  final String target;
  final String? sourceHandle;
  final String? targetHandle;
}

class EdgePosition {
  const EdgePosition({
    required this.sourceX,
    required this.sourceY,
    required this.targetX,
    required this.targetY,
    required this.sourcePosition,
    required this.targetPosition,
  });

  final double sourceX;
  final double sourceY;
  final double targetX;
  final double targetY;
  final Position sourcePosition;
  final Position targetPosition;
}

class EdgePathResult {
  const EdgePathResult({
    required this.path,
    required this.labelX,
    required this.labelY,
    required this.offsetX,
    required this.offsetY,
  });

  final String path;
  final double labelX;
  final double labelY;
  final double offsetX;
  final double offsetY;
}

extension PositionValue on Position {
  String get value {
    switch (this) {
      case Position.left:
        return 'left';
      case Position.top:
        return 'top';
      case Position.right:
        return 'right';
      case Position.bottom:
        return 'bottom';
    }
  }

  Position get opposite {
    switch (this) {
      case Position.left:
        return Position.right;
      case Position.top:
        return Position.bottom;
      case Position.right:
        return Position.left;
      case Position.bottom:
        return Position.top;
    }
  }
}

extension PanelPositionValue on PanelPosition {
  String get value {
    switch (this) {
      case PanelPosition.topLeft:
        return 'top-left';
      case PanelPosition.topRight:
        return 'top-right';
      case PanelPosition.bottomLeft:
        return 'bottom-left';
      case PanelPosition.bottomRight:
        return 'bottom-right';
    }
  }
}

extension ConnectionLineTypeValue on ConnectionLineType {
  String get value {
    switch (this) {
      case ConnectionLineType.bezier:
        return 'default';
      case ConnectionLineType.straight:
        return 'straight';
      case ConnectionLineType.step:
        return 'step';
      case ConnectionLineType.smoothStep:
        return 'smoothstep';
      case ConnectionLineType.simpleBezier:
        return 'simplebezier';
    }
  }
}

extension MarkerTypeValue on MarkerType {
  String get value {
    switch (this) {
      case MarkerType.arrow:
        return 'arrow';
      case MarkerType.arrowClosed:
        return 'arrowclosed';
    }
  }
}

double clampDouble(double value, double min, double max) {
  return math.max(min, math.min(max, value));
}
