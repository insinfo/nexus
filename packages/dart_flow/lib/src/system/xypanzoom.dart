import '../types/models.dart';

class XYPanZoomState {
  const XYPanZoomState({
    required this.viewport,
    this.previousViewport = const Viewport(),
    required this.isDragging,
    this.lastPointer,
    this.isZoomingOrPanning = false,
    this.usedRightMouseButton = false,
    this.mouseButton = 0,
    this.isPanScrolling = false,
  });

  final Viewport viewport;
  final Viewport previousViewport;
  final bool isDragging;
  final XYPosition? lastPointer;
  final bool isZoomingOrPanning;
  final bool usedRightMouseButton;
  final int mouseButton;
  final bool isPanScrolling;

  XYPanZoomState copyWith({
    Viewport? viewport,
    Viewport? previousViewport,
    bool? isDragging,
    XYPosition? lastPointer,
    bool? isZoomingOrPanning,
    bool? usedRightMouseButton,
    int? mouseButton,
    bool? isPanScrolling,
  }) {
    return XYPanZoomState(
      viewport: viewport ?? this.viewport,
      previousViewport: previousViewport ?? this.previousViewport,
      isDragging: isDragging ?? this.isDragging,
      lastPointer: lastPointer ?? this.lastPointer,
      isZoomingOrPanning: isZoomingOrPanning ?? this.isZoomingOrPanning,
      usedRightMouseButton: usedRightMouseButton ?? this.usedRightMouseButton,
      mouseButton: mouseButton ?? this.mouseButton,
      isPanScrolling: isPanScrolling ?? this.isPanScrolling,
    );
  }
}

XYPanZoomState startPanGesture({
  required Viewport viewport,
  required XYPosition pointer,
  int mouseButton = 0,
  bool usedRightMouseButton = false,
  bool isPanScrolling = false,
}) {
  return XYPanZoomState(
    viewport: viewport,
    previousViewport: viewport,
    isDragging: true,
    lastPointer: pointer,
    isZoomingOrPanning: true,
    usedRightMouseButton: usedRightMouseButton,
    mouseButton: mouseButton,
    isPanScrolling: isPanScrolling,
  );
}

XYPanZoomState updatePanGesture(
  XYPanZoomState state, {
  required XYPosition pointer,
  required Viewport viewport,
}) {
  return state.copyWith(
    viewport: viewport,
    lastPointer: pointer,
    isDragging: true,
    isZoomingOrPanning: true,
  );
}

XYPanZoomState endPanGesture(
  XYPanZoomState state, {
  Viewport? viewport,
  XYPosition? pointer,
}) {
  return state.copyWith(
    viewport: viewport ?? state.viewport,
    lastPointer: pointer ?? state.lastPointer,
    isDragging: false,
    isZoomingOrPanning: false,
    isPanScrolling: false,
  );
}

XYPosition screenToFlowPosition({
  required XYPosition screenPosition,
  required Viewport viewport,
  XYPosition paneOrigin = const XYPosition(x: 0, y: 0),
}) {
  final localX = screenPosition.x - paneOrigin.x;
  final localY = screenPosition.y - paneOrigin.y;

  return XYPosition(
    x: (localX - viewport.x) / viewport.zoom,
    y: (localY - viewport.y) / viewport.zoom,
  );
}

XYPosition flowToScreenPosition({
  required XYPosition flowPosition,
  required Viewport viewport,
  XYPosition paneOrigin = const XYPosition(x: 0, y: 0),
}) {
  return XYPosition(
    x: paneOrigin.x + viewport.x + (flowPosition.x * viewport.zoom),
    y: paneOrigin.y + viewport.y + (flowPosition.y * viewport.zoom),
  );
}

Viewport zoomViewportAroundPoint({
  required Viewport viewport,
  required double zoom,
  required XYPosition anchor,
  double minZoom = 0.2,
  double maxZoom = 2.0,
}) {
  final nextZoom = clampDouble(zoom, minZoom, maxZoom);
  final worldX = (anchor.x - viewport.x) / viewport.zoom;
  final worldY = (anchor.y - viewport.y) / viewport.zoom;
  final nextX = anchor.x - (worldX * nextZoom);
  final nextY = anchor.y - (worldY * nextZoom);

  return Viewport(x: nextX, y: nextY, zoom: nextZoom);
}

Viewport panViewport(
  Viewport viewport, {
  double dx = 0,
  double dy = 0,
}) {
  return viewport.copyWith(
    x: viewport.x + dx,
    y: viewport.y + dy,
  );
}

Viewport constrainViewport({
  required Viewport viewport,
  required Rect viewportExtent,
  required Rect translateExtent,
  double minZoom = 0.2,
  double maxZoom = 2.0,
}) {
  final nextZoom = clampDouble(viewport.zoom, minZoom, maxZoom);
  final minX = translateExtent.x +
      viewportExtent.width -
      (translateExtent.x + translateExtent.width);
  final maxX = translateExtent.x;
  final minY = translateExtent.y +
      viewportExtent.height -
      (translateExtent.y + translateExtent.height);
  final maxY = translateExtent.y;

  return Viewport(
    x: clampDouble(viewport.x, minX > maxX ? maxX : minX, maxX),
    y: clampDouble(viewport.y, minY > maxY ? maxY : minY, maxY),
    zoom: nextZoom,
  );
}

Viewport scaleViewportTo({
  required Viewport viewport,
  required double zoom,
  required XYPosition anchor,
  double minZoom = 0.2,
  double maxZoom = 2.0,
}) {
  return zoomViewportAroundPoint(
    viewport: viewport,
    zoom: zoom,
    anchor: anchor,
    minZoom: minZoom,
    maxZoom: maxZoom,
  );
}

Viewport scaleViewportBy({
  required Viewport viewport,
  required double factor,
  required XYPosition anchor,
  double minZoom = 0.2,
  double maxZoom = 2.0,
}) {
  return scaleViewportTo(
    viewport: viewport,
    zoom: viewport.zoom * factor,
    anchor: anchor,
    minZoom: minZoom,
    maxZoom: maxZoom,
  );
}

bool viewportEquals(
  Viewport a,
  Viewport b, {
  double tolerance = 0.001,
}) {
  return (a.x - b.x).abs() <= tolerance &&
      (a.y - b.y).abs() <= tolerance &&
      (a.zoom - b.zoom).abs() <= tolerance;
}

XYPanZoomState syncPanZoomState(
  XYPanZoomState state,
  Viewport viewport, {
  double tolerance = 0.001,
}) {
  if (viewportEquals(state.viewport, viewport, tolerance: tolerance)) {
    return state;
  }

  return state.copyWith(
    previousViewport: state.viewport,
    viewport: viewport,
  );
}

Rect viewportRectInFlow({
  required Viewport viewport,
  required double canvasWidth,
  required double canvasHeight,
}) {
  return Rect(
    x: -viewport.x / viewport.zoom,
    y: -viewport.y / viewport.zoom,
    width: canvasWidth / viewport.zoom,
    height: canvasHeight / viewport.zoom,
  );
}
