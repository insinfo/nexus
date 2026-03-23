import '../system/xyhandle.dart';
import '../system/xydrag.dart';
import '../system/xypanzoom.dart';
import '../types/models.dart';

enum XYConnectionLifecycleKind {
  connect,
  reconnect,
}

class _PendingConnectionGesture {
  const _PendingConnectionGesture({
    required this.kind,
    required this.nodeId,
    required this.handleType,
    required this.pointer,
    required this.dragThreshold,
    this.handleId,
    this.connectionMode = XYConnectionMode.strict,
    this.validator,
    this.reconnectEdgeId,
    this.reconnectSourceHandle = false,
  });

  final XYConnectionLifecycleKind kind;
  final String nodeId;
  final String? handleId;
  final HandleType handleType;
  final XYPosition pointer;
  final double dragThreshold;
  final XYConnectionMode connectionMode;
  final XYConnectionValidator? validator;
  final String? reconnectEdgeId;
  final bool reconnectSourceHandle;
}

class NgFlowInteractionController {
  String? dragNodeId;
  String? resizeNodeId;
  String? connectionStartNodeId;
  String? connectionStartHandleId;
  String? reconnectEdgeId;
  bool reconnectSourceHandle = false;
  XYHandleState handleState = const XYHandleState();
  XYPanZoomState panZoomState = const XYPanZoomState(
    viewport: Viewport(),
    isDragging: false,
  );
  bool isPanning = false;
  bool isSelecting = false;

  double dragStartPointerX = 0;
  double dragStartPointerY = 0;
  XYPosition dragStartPosition = const XYPosition(x: 0, y: 0);
  Viewport dragStartViewport = const Viewport();
  Map<String, XYPosition> dragStartPositions = const <String, XYPosition>{};

  double panStartPointerX = 0;
  double panStartPointerY = 0;
  double panStartViewportX = 0;
  double panStartViewportY = 0;

  double resizeStartPointerX = 0;
  double resizeStartPointerY = 0;
  double resizeStartWidth = 0;
  double resizeStartHeight = 0;

  XYPosition? connectionPreviewWorld;
  XYPosition? selectionStartLocal;
  XYPosition? selectionCurrentLocal;
  XYFinalConnectionState? lastConnectionEndState;
  XYFinalConnectionState? lastReconnectEndState;
  XYConnectionLifecycleKind? _activeConnectionKind;
  _PendingConnectionGesture? _pendingConnectionGesture;

  bool get hasSelectionRect =>
      selectionStartLocal != null && selectionCurrentLocal != null;
  bool get hasConnectionPreview =>
      _activeConnectionKind == XYConnectionLifecycleKind.connect &&
      connectionStartNodeId != null &&
      connectionPreviewWorld != null;
  bool get hasReconnectPreview =>
      _activeConnectionKind == XYConnectionLifecycleKind.reconnect &&
      reconnectEdgeId != null &&
      connectionPreviewWorld != null;
  bool get hasPendingConnectionGesture =>
      _pendingConnectionGesture?.kind == XYConnectionLifecycleKind.connect;
  bool get hasPendingReconnectGesture =>
      _pendingConnectionGesture?.kind == XYConnectionLifecycleKind.reconnect;
  XYConnectionLifecycleKind? get activeConnectionKind => _activeConnectionKind;

  void startNodeDrag({
    required String nodeId,
    required XYPosition pointer,
    required XYPosition startPosition,
    required Viewport viewport,
    Map<String, XYPosition> startPositions = const <String, XYPosition>{},
  }) {
    dragNodeId = nodeId;
    dragStartPointerX = pointer.x;
    dragStartPointerY = pointer.y;
    dragStartPosition = startPosition;
    dragStartViewport = viewport;
    dragStartPositions = Map<String, XYPosition>.unmodifiable(
      startPositions.isEmpty
          ? <String, XYPosition>{nodeId: startPosition}
          : startPositions,
    );
  }

  XYMultiDragResult computeNodeDrag({
    required XYPosition pointer,
    required Map<String, Dimensions> dimensions,
    required double canvasWidth,
    required double canvasHeight,
    required XYDragConfig config,
  }) {
    return computeDraggedNodePositions(
      leadNodeId: dragNodeId ?? '',
      startPositions: dragStartPositions,
      nodeDimensions: dimensions,
      startPointer: XYPosition(x: dragStartPointerX, y: dragStartPointerY),
      currentPointer: pointer,
      viewport: dragStartViewport,
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
      config: config,
    );
  }

  void stopNodeDrag() {
    dragNodeId = null;
    dragStartPositions = const <String, XYPosition>{};
  }

  void startResize({
    required String nodeId,
    required XYPosition pointer,
    required double width,
    required double height,
  }) {
    resizeNodeId = nodeId;
    resizeStartPointerX = pointer.x;
    resizeStartPointerY = pointer.y;
    resizeStartWidth = width;
    resizeStartHeight = height;
  }

  Dimensions computeResize({
    required XYPosition pointer,
    required Viewport viewport,
  }) {
    final dx = (pointer.x - resizeStartPointerX) / viewport.zoom;
    final dy = (pointer.y - resizeStartPointerY) / viewport.zoom;
    return Dimensions(
      width: resizeStartWidth + dx,
      height: resizeStartHeight + dy,
    );
  }

  void stopResize() {
    resizeNodeId = null;
  }

  void startPan({
    required XYPosition pointer,
    required Viewport viewport,
    int mouseButton = 0,
  }) {
    isPanning = true;
    panStartPointerX = pointer.x;
    panStartPointerY = pointer.y;
    panStartViewportX = viewport.x;
    panStartViewportY = viewport.y;
    panZoomState = startPanGesture(
      viewport: viewport,
      pointer: pointer,
      mouseButton: mouseButton,
      usedRightMouseButton: mouseButton == 2,
    );
  }

  Viewport computePan({
    required XYPosition pointer,
    required Viewport viewport,
  }) {
    final dx = pointer.x - panStartPointerX;
    final dy = pointer.y - panStartPointerY;
    final nextViewport = Viewport(
      x: panStartViewportX + dx,
      y: panStartViewportY + dy,
      zoom: viewport.zoom,
    );
    panZoomState = updatePanGesture(
      panZoomState,
      pointer: pointer,
      viewport: nextViewport,
    );
    return nextViewport;
  }

  void stopPan() {
    isPanning = false;
    panZoomState = endPanGesture(panZoomState);
  }

  void startSelection(XYPosition localPointer) {
    isSelecting = true;
    selectionStartLocal = localPointer;
    selectionCurrentLocal = localPointer;
  }

  void updateSelection(XYPosition localPointer) {
    selectionCurrentLocal = localPointer;
  }

  Rect? selectionRectWorld(XYPosition Function(XYPosition) toWorld) {
    final start = selectionStartLocal;
    final current = selectionCurrentLocal;
    if (start == null || current == null) {
      return null;
    }
    return selectionRectFromPoints(
      toWorld(start),
      toWorld(current),
    );
  }

  Set<String> finalizeSelection(
    Iterable<FlowNode> nodes,
    XYPosition Function(XYPosition) toWorld,
  ) {
    final rect = selectionRectWorld(toWorld);
    isSelecting = false;
    selectionStartLocal = null;
    selectionCurrentLocal = null;
    if (rect == null) {
      return <String>{};
    }
    return selectNodesWithinRect(nodes, rect);
  }

  bool startConnection({
    required String nodeId,
    required HandleType handleType,
    String? handleId,
    required XYPosition pointer,
    double dragThreshold = 1,
    XYConnectionMode connectionMode = XYConnectionMode.strict,
    XYConnectionValidator? validator,
  }) {
    _pendingConnectionGesture = _PendingConnectionGesture(
      kind: XYConnectionLifecycleKind.connect,
      nodeId: nodeId,
      handleType: handleType,
      handleId: handleId,
      pointer: pointer,
      dragThreshold: dragThreshold,
      connectionMode: connectionMode,
      validator: validator,
    );
    if (dragThreshold <= 0) {
      return _activatePendingConnectionGesture(pointer);
    }
    return false;
  }

  XYConnectionMode _connectionMode = XYConnectionMode.strict;
  XYConnectionValidator? _connectionValidator;

  bool updateConnection(XYPosition pointer) {
    return _updateOrActivateConnectionGesture(pointer);
  }

  void previewConnectionTarget({
    required XYPosition pointer,
    String? nodeId,
    String? handleId,
    HandleType? handleType,
  }) {
    handleState = _updateConnectionLifecycle(
      pointer: pointer,
      targetNodeId: nodeId,
      targetHandleId: handleId,
      targetType: handleType,
    );
  }

  FlowConnection? completeConnection({
    required String nodeId,
    String? handleId,
    required HandleType handleType,
  }) {
    final result = _finalizeConnectionLifecycle(
      kind: XYConnectionLifecycleKind.connect,
      targetNodeId: nodeId,
      targetHandleId: handleId,
      targetType: handleType,
    );
    lastConnectionEndState = result.$2;
    return result.$1;
  }

  XYFinalConnectionState? cancelConnection() {
    if (hasPendingConnectionGesture && _activeConnectionKind == null) {
      _pendingConnectionGesture = null;
      return null;
    }
    lastConnectionEndState = _cancelConnectionLifecycle(
      kind: XYConnectionLifecycleKind.connect,
    );
    return lastConnectionEndState;
  }

  void clearConnection() {
    connectionStartNodeId = null;
    connectionStartHandleId = null;
    connectionPreviewWorld = null;
    handleState = const XYHandleState();
    _connectionMode = XYConnectionMode.strict;
    _connectionValidator = null;
    if (_activeConnectionKind == XYConnectionLifecycleKind.connect) {
      _activeConnectionKind = null;
    }
    if (_pendingConnectionGesture?.kind == XYConnectionLifecycleKind.connect) {
      _pendingConnectionGesture = null;
    }
  }

  bool startReconnect({
    required FlowEdge edge,
    required bool sourceHandle,
    required XYPosition pointer,
    double dragThreshold = 1,
  }) {
    _pendingConnectionGesture = _PendingConnectionGesture(
      kind: XYConnectionLifecycleKind.reconnect,
      nodeId: sourceHandle ? edge.target : edge.source,
      handleId: sourceHandle ? edge.targetHandle : edge.sourceHandle,
      handleType: sourceHandle ? HandleType.target : HandleType.source,
      pointer: pointer,
      dragThreshold: dragThreshold,
      reconnectEdgeId: edge.id,
      reconnectSourceHandle: sourceHandle,
    );
    if (dragThreshold <= 0) {
      return _activatePendingConnectionGesture(pointer);
    }
    return false;
  }

  bool updateReconnect(XYPosition pointer) {
    return _updateOrActivateConnectionGesture(pointer);
  }

  FlowConnection? completeReconnect({
    required FlowEdge edge,
    required String nodeId,
    String? handleId,
  }) {
    final reconnectingEdgeId = reconnectEdgeId;
    if (reconnectingEdgeId == null || reconnectingEdgeId != edge.id) {
      return null;
    }

    final result = _finalizeConnectionLifecycle(
      kind: XYConnectionLifecycleKind.reconnect,
      targetNodeId: nodeId,
      targetHandleId: handleId,
      targetType: reconnectSourceHandle ? HandleType.source : HandleType.target,
    );
    lastReconnectEndState = result.$2;
    return result.$1;
  }

  XYFinalConnectionState? cancelReconnect() {
    if (hasPendingReconnectGesture && _activeConnectionKind == null) {
      _pendingConnectionGesture = null;
      return null;
    }
    lastReconnectEndState = _cancelConnectionLifecycle(
      kind: XYConnectionLifecycleKind.reconnect,
    );
    return lastReconnectEndState;
  }

  void clearReconnect() {
    reconnectEdgeId = null;
    reconnectSourceHandle = false;
    connectionPreviewWorld = null;
    if (_activeConnectionKind == XYConnectionLifecycleKind.reconnect) {
      _activeConnectionKind = null;
    }
    if (_pendingConnectionGesture?.kind ==
        XYConnectionLifecycleKind.reconnect) {
      _pendingConnectionGesture = null;
    }
  }

  void clearPointerModes() {
    cancelConnection();
    cancelReconnect();
    stopPan();
    stopResize();
    isSelecting = false;
    selectionStartLocal = null;
    selectionCurrentLocal = null;
  }

  void finishDocumentPointer() {
    stopNodeDrag();
    stopResize();
    stopPan();
  }

  void _beginConnectionLifecycle({
    required XYConnectionLifecycleKind kind,
    required String nodeId,
    required HandleType handleType,
    String? handleId,
    required XYPosition pointer,
    XYConnectionMode connectionMode = XYConnectionMode.strict,
    XYConnectionValidator? validator,
  }) {
    _activeConnectionKind = kind;
    connectionStartNodeId = nodeId;
    connectionStartHandleId = handleId;
    connectionPreviewWorld = pointer;
    handleState = startHandleConnection(
      nodeId: nodeId,
      handleType: handleType,
      handleId: handleId,
      pointer: pointer,
    );
    _connectionMode = connectionMode;
    _connectionValidator = validator;
  }

  bool _activatePendingConnectionGesture(XYPosition pointer) {
    final pending = _pendingConnectionGesture;
    if (pending == null) {
      return false;
    }

    reconnectEdgeId = pending.reconnectEdgeId;
    reconnectSourceHandle = pending.reconnectSourceHandle;
    _beginConnectionLifecycle(
      kind: pending.kind,
      nodeId: pending.nodeId,
      handleType: pending.handleType,
      handleId: pending.handleId,
      pointer: pending.pointer,
      connectionMode: pending.connectionMode,
      validator: pending.validator,
    );
    _pendingConnectionGesture = null;
    _updateConnectionLifecycle(pointer: pointer);
    return true;
  }

  bool _updateOrActivateConnectionGesture(XYPosition pointer) {
    if (_activeConnectionKind != null) {
      _updateConnectionLifecycle(pointer: pointer);
      return false;
    }

    final pending = _pendingConnectionGesture;
    if (pending == null) {
      return false;
    }

    final dx = pointer.x - pending.pointer.x;
    final dy = pointer.y - pending.pointer.y;
    final threshold = pending.dragThreshold;
    if ((dx * dx) + (dy * dy) <= threshold * threshold) {
      return false;
    }

    return _activatePendingConnectionGesture(pointer);
  }

  XYHandleState _updateConnectionLifecycle({
    required XYPosition pointer,
    String? targetNodeId,
    String? targetHandleId,
    HandleType? targetType,
  }) {
    connectionPreviewWorld = pointer;
    handleState = updateHandleConnection(
      handleState,
      pointer: pointer,
      targetNodeId: targetNodeId,
      targetHandleId: targetHandleId,
      targetType: targetType,
      connectionMode: _connectionMode,
      validator: _connectionValidator,
    );
    return handleState;
  }

  (FlowConnection?, XYFinalConnectionState?) _finalizeConnectionLifecycle({
    required XYConnectionLifecycleKind kind,
    required String targetNodeId,
    String? targetHandleId,
    required HandleType targetType,
  }) {
    if (_activeConnectionKind != kind) {
      return (null, null);
    }

    final resolvedState = _updateConnectionLifecycle(
      pointer: connectionPreviewWorld ??
          handleState.pointer ??
          const XYPosition(x: 0, y: 0),
      targetNodeId: targetNodeId,
      targetHandleId: targetHandleId,
      targetType: targetType,
    );
    final finalState = finalizeHandleConnection(resolvedState);
    final connection = resolvedState.connection;

    if (kind == XYConnectionLifecycleKind.connect) {
      clearConnection();
    } else {
      clearReconnect();
    }

    return (connection, finalState);
  }

  XYFinalConnectionState? _cancelConnectionLifecycle({
    required XYConnectionLifecycleKind kind,
  }) {
    if (_activeConnectionKind != kind) {
      if (kind == XYConnectionLifecycleKind.connect) {
        clearConnection();
      } else {
        clearReconnect();
      }
      return null;
    }

    final finalState = _normalizeFinalConnectionState(
      finalizeHandleConnection(handleState),
    );
    if (kind == XYConnectionLifecycleKind.connect) {
      clearConnection();
    } else {
      clearReconnect();
    }
    return finalState;
  }

  XYFinalConnectionState? _normalizeFinalConnectionState(
    XYFinalConnectionState? state,
  ) {
    if (state == null || state.isValid != null) {
      return state;
    }

    return XYFinalConnectionState(
      fromNodeId: state.fromNodeId,
      fromHandleId: state.fromHandleId,
      fromType: state.fromType,
      startPointer: state.startPointer,
      pointer: state.pointer,
      targetNodeId: state.targetNodeId,
      targetHandleId: state.targetHandleId,
      targetType: state.targetType,
      isValid: false,
      connection: state.connection,
    );
  }
}
