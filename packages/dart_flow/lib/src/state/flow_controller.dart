import 'dart:async';

import '../system/xypanzoom.dart';
import '../types/models.dart';
import '../utils/graph.dart';

class FlowController {
  final _changesController = StreamController<int>.broadcast();

  List<FlowNode> _nodes = const <FlowNode>[];
  List<FlowEdge> _edges = const <FlowEdge>[];
  Viewport _viewport = const Viewport();

  double _canvasWidth = 1;
  double _canvasHeight = 1;
  double minZoom = 0.2;
  double maxZoom = 2.0;
  Rect _translateExtent = const Rect(
    x: -100000,
    y: -100000,
    width: 200000,
    height: 200000,
  );

  Stream<int> get changes => _changesController.stream;

  List<FlowNode> get nodes => List<FlowNode>.unmodifiable(_nodes);
  List<FlowEdge> get edges => List<FlowEdge>.unmodifiable(_edges);
  Viewport get viewport => _viewport;
  double get canvasWidth => _canvasWidth;
  double get canvasHeight => _canvasHeight;
  Rect get translateExtent => _translateExtent;
  FlowNode? get selectedNode =>
      _nodes.where((node) => node.selected).cast<FlowNode?>().firstOrNull;
  FlowEdge? get selectedEdge =>
      _edges.where((edge) => edge.selected).cast<FlowEdge?>().firstOrNull;

  Rect get graphBounds => getNodesBounds(_nodes);

  void setNodes(List<FlowNode> nodes) {
    _nodes = nodes.map((node) => node.copyWith()).toList();
    _notify();
  }

  void setEdges(List<FlowEdge> edges) {
    _edges = edges.map((edge) => edge.copyWith()).toList();
    _notify();
  }

  void setCanvasSize(double width, double height) {
    final nextWidth = width <= 0 ? 1.0 : width;
    final nextHeight = height <= 0 ? 1.0 : height;

    if ((_canvasWidth - nextWidth).abs() < 0.01 &&
        (_canvasHeight - nextHeight).abs() < 0.01) {
      return;
    }

    _canvasWidth = nextWidth;
    _canvasHeight = nextHeight;
    _notify();
  }

  void setViewport(Viewport viewport) {
    _viewport = Viewport(
      x: viewport.x,
      y: viewport.y,
      zoom: clampDouble(viewport.zoom, minZoom, maxZoom),
    );
    _notify();
  }

  void zoomTo(double zoom, {double? anchorX, double? anchorY}) {
    final nextZoom = clampDouble(zoom, minZoom, maxZoom);
    if (anchorX == null || anchorY == null) {
      _viewport = _viewport.copyWith(zoom: nextZoom);
      _notify();
      return;
    }

    _viewport = zoomViewportAroundPoint(
      viewport: _viewport,
      zoom: nextZoom,
      anchor: XYPosition(x: anchorX, y: anchorY),
      minZoom: minZoom,
      maxZoom: maxZoom,
    );
    _notify();
  }

  void setViewportConstrained(Viewport viewport) {
    _viewport = constrainViewport(
      viewport: viewport,
      viewportExtent: Rect(
        x: 0,
        y: 0,
        width: _canvasWidth,
        height: _canvasHeight,
      ),
      translateExtent: _translateExtent,
      minZoom: minZoom,
      maxZoom: maxZoom,
    );
    _notify();
  }

  void syncViewport(Viewport viewport) {
    final next = constrainViewport(
      viewport: viewport,
      viewportExtent: Rect(
        x: 0,
        y: 0,
        width: _canvasWidth,
        height: _canvasHeight,
      ),
      translateExtent: _translateExtent,
      minZoom: minZoom,
      maxZoom: maxZoom,
    );
    if (viewportEquals(_viewport, next)) {
      return;
    }
    _viewport = next;
    _notify();
  }

  void setTranslateExtent(Rect extent) {
    _translateExtent = extent;
    _viewport = constrainViewport(
      viewport: _viewport,
      viewportExtent: Rect(
        x: 0,
        y: 0,
        width: _canvasWidth,
        height: _canvasHeight,
      ),
      translateExtent: _translateExtent,
      minZoom: minZoom,
      maxZoom: maxZoom,
    );
    _notify();
  }

  void zoomIn() => zoomTo(_viewport.zoom * 1.2);

  void zoomOut() => zoomTo(_viewport.zoom / 1.2);

  void scaleBy(double factor, {double? anchorX, double? anchorY}) {
    if (anchorX == null || anchorY == null) {
      zoomTo(_viewport.zoom * factor);
      return;
    }

    _viewport = scaleViewportBy(
      viewport: _viewport,
      factor: factor,
      anchor: XYPosition(x: anchorX, y: anchorY),
      minZoom: minZoom,
      maxZoom: maxZoom,
    );
    _notify();
  }

  void panBy(double dx, double dy) {
    _viewport = constrainViewport(
      viewport: panViewport(
        _viewport,
        dx: dx,
        dy: dy,
      ),
      viewportExtent: Rect(
        x: 0,
        y: 0,
        width: _canvasWidth,
        height: _canvasHeight,
      ),
      translateExtent: _translateExtent,
      minZoom: minZoom,
      maxZoom: maxZoom,
    );
    _notify();
  }

  void fitView({double padding = 0.12}) {
    if (_nodes.where((node) => !node.hidden).isEmpty) {
      return;
    }

    _viewport = getViewportForBounds(
      graphBounds,
      width: _canvasWidth,
      height: _canvasHeight,
      minZoom: minZoom,
      maxZoom: maxZoom,
      padding: padding,
    );
    _notify();
  }

  void updateNodePosition(String nodeId, XYPosition position) {
    _nodes = _nodes
        .map(
          (node) =>
              node.id == nodeId ? node.copyWith(position: position) : node,
        )
        .toList();
    _notify();
  }

  void updateNodePositions(Map<String, XYPosition> positions) {
    if (positions.isEmpty) {
      return;
    }

    _nodes = _nodes
        .map(
          (node) => positions.containsKey(node.id)
              ? node.copyWith(position: positions[node.id]!)
              : node,
        )
        .toList();
    _notify();
  }

  void updateNodeDimensions(String nodeId, double width, double height) {
    _nodes = _nodes
        .map(
          (node) => node.id == nodeId
              ? node.copyWith(
                  width: width < 80 ? 80 : width,
                  height: height < 40 ? 40 : height,
                )
              : node,
        )
        .toList();
    _notify();
  }

  void setNodeDragging(String nodeId, bool dragging) {
    _nodes = _nodes
        .map(
          (node) =>
              node.id == nodeId ? node.copyWith(dragging: dragging) : node,
        )
        .toList();
    _notify();
  }

  void setNodesDragging(Set<String> nodeIds, bool dragging) {
    if (nodeIds.isEmpty) {
      return;
    }

    _nodes = _nodes
        .map(
          (node) => nodeIds.contains(node.id)
              ? node.copyWith(dragging: dragging)
              : node,
        )
        .toList();
    _notify();
  }

  void selectNode(String nodeId) {
    _nodes = _nodes
        .map((node) => node.copyWith(selected: node.id == nodeId))
        .toList();
    _edges = _edges.map((edge) => edge.copyWith(selected: false)).toList();
    _notify();
  }

  void selectEdge(String edgeId) {
    _edges = _edges
        .map((edge) => edge.copyWith(selected: edge.id == edgeId))
        .toList();
    _nodes = _nodes.map((node) => node.copyWith(selected: false)).toList();
    _notify();
  }

  void clearSelection() {
    _nodes = _nodes.map((node) => node.copyWith(selected: false)).toList();
    _edges = _edges.map((edge) => edge.copyWith(selected: false)).toList();
    _notify();
  }

  void selectNodesByIds(Set<String> nodeIds) {
    _nodes = _nodes
        .map((node) => node.copyWith(selected: nodeIds.contains(node.id)))
        .toList();
    _edges = _edges.map((edge) => edge.copyWith(selected: false)).toList();
    _notify();
  }

  void deleteSelected() {
    final selectedNodeIds =
        _nodes.where((node) => node.selected).map((node) => node.id).toSet();

    _nodes = _nodes.where((node) => !node.selected).toList();
    _edges = _edges
        .where(
          (edge) =>
              !edge.selected &&
              !selectedNodeIds.contains(edge.source) &&
              !selectedNodeIds.contains(edge.target),
        )
        .toList();
    _notify();
  }

  FlowNode? duplicateSelectedNode() {
    final node = selectedNode;
    if (node == null) {
      return null;
    }

    final duplicated = node.copyWith(
      position: node.position.translate(48, 48),
      data: <String, Object?>{
        ...node.data,
        'label': '${node.label} copia',
      },
      selected: false,
      dragging: false,
    );

    final nextId = _nextNodeId(node.id);
    final nextNode = FlowNode(
      id: nextId,
      position: duplicated.position,
      data: duplicated.data,
      type: duplicated.type,
      hidden: duplicated.hidden,
      selected: true,
      dragging: duplicated.dragging,
      draggable: duplicated.draggable,
      selectable: duplicated.selectable,
      connectable: duplicated.connectable,
      deletable: duplicated.deletable,
      width: duplicated.width,
      height: duplicated.height,
      sourcePosition: duplicated.sourcePosition,
      targetPosition: duplicated.targetPosition,
      parentId: duplicated.parentId,
      zIndex: duplicated.zIndex,
      ariaLabel: duplicated.ariaLabel,
      handles: duplicated.handles,
    );

    _nodes = _nodes
        .map((candidate) => candidate.copyWith(selected: false))
        .toList()
      ..add(nextNode);
    _notify();
    return nextNode;
  }

  void reconnectEdge(
    String edgeId, {
    String? source,
    String? target,
    String? sourceHandle,
    String? targetHandle,
  }) {
    _edges = _edges
        .map(
          (edge) => edge.id == edgeId
              ? edge.copyWith(
                  source: source ?? edge.source,
                  target: target ?? edge.target,
                  sourceHandle: sourceHandle ?? edge.sourceHandle,
                  targetHandle: targetHandle ?? edge.targetHandle,
                )
              : edge,
        )
        .toList();
    _notify();
  }

  void dispose() {
    _changesController.close();
  }

  void _notify() {
    if (!_changesController.isClosed) {
      _changesController.add(DateTime.now().microsecondsSinceEpoch);
    }
  }

  String _nextNodeId(String fallback) {
    final numericIds =
        _nodes.map((node) => int.tryParse(node.id)).whereType<int>().toList();
    if (numericIds.isEmpty) {
      return '${fallback}_${_nodes.length + 1}';
    }

    return '${numericIds.reduce((a, b) => a > b ? a : b) + 1}';
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
