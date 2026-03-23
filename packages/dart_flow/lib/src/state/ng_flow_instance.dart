import 'dart:async';

import '../system/node_internals.dart';
import '../system/xypanzoom.dart' as panzoom;
import '../types/models.dart';
import '../utils/graph.dart';
import 'flow_controller.dart';
import 'ng_flow_store.dart';

class NgFlowInstance {
  NgFlowInstance(this._controller, this._store);

  final FlowController _controller;
  final NgFlowStore _store;

  Stream<int> get changes => _controller.changes;
  Stream<Viewport> get viewportChanges =>
      changes.map((_) => _controller.viewport).asBroadcastStream();
  Stream<List<FlowNode>> get nodesChanges =>
      changes.map((_) => _controller.nodes).asBroadcastStream();
  Stream<List<FlowEdge>> get edgesChanges =>
      changes.map((_) => _controller.edges).asBroadcastStream();
  Stream<Set<String>> get selectionChanges =>
      changes.map((_) => selectedNodeIds).asBroadcastStream();
  Stream<NgFlowSnapshot> get snapshotChanges => _store.snapshots;

  List<FlowNode> get nodes => _controller.nodes;
  List<FlowEdge> get edges => _controller.edges;
  List<FlowNode> get visibleNodes => _store.visibleNodes;
  List<FlowEdge> get visibleEdges => _store.visibleEdges;
  List<FlowNode> get nodesInsideViewport => _store.nodesInsideViewport;
  List<FlowNode> get selectedNodes => _store.selectedNodes;
  List<FlowEdge> get selectedEdges => _store.selectedEdges;
  Viewport get viewport => _controller.viewport;
  Rect get nodesBounds => _controller.graphBounds;
  Rect get visibleBounds => _store.visibleBounds;
  Rect get viewportRect => _store.viewportRect;
  NgFlowStore get store => _store;
  FlowNode? get selectedNode => _controller.selectedNode;
  FlowEdge? get selectedEdge => _controller.selectedEdge;
  Set<String> get selectedNodeIds => _controller.nodes
      .where((node) => node.selected)
      .map((node) => node.id)
      .toSet();
  Set<String> get selectedEdgeIds => _controller.edges
      .where((edge) => edge.selected)
      .map((edge) => edge.id)
      .toSet();
  bool get hasSelection => _store.hasSelection;

  void setNodes(List<FlowNode> nodes) => _controller.setNodes(nodes);

  void setEdges(List<FlowEdge> edges) => _controller.setEdges(edges);

  void setViewport(Viewport viewport) => _controller.setViewport(viewport);

  void setViewportConstrained(Viewport viewport) =>
      _controller.setViewportConstrained(viewport);

  void zoomIn() => _controller.zoomIn();

  void zoomOut() => _controller.zoomOut();

  void zoomTo(double zoom, {double? anchorX, double? anchorY}) {
    _controller.zoomTo(zoom, anchorX: anchorX, anchorY: anchorY);
  }

  void scaleBy(double factor, {double? anchorX, double? anchorY}) {
    _controller.scaleBy(factor, anchorX: anchorX, anchorY: anchorY);
  }

  void fitView({double padding = 0.12}) =>
      _controller.fitView(padding: padding);

  void panBy(double dx, double dy) => _controller.panBy(dx, dy);

  void syncViewport(Viewport viewport) => _controller.syncViewport(viewport);

  void setTranslateExtent(Rect extent) =>
      _controller.setTranslateExtent(extent);

  XYPosition screenToFlowPosition(
    XYPosition screenPosition, {
    XYPosition paneOrigin = const XYPosition(x: 0, y: 0),
  }) {
    return panzoom.screenToFlowPosition(
      screenPosition: screenPosition,
      viewport: viewport,
      paneOrigin: paneOrigin,
    );
  }

  XYPosition flowToScreenPosition(
    XYPosition flowPosition, {
    XYPosition paneOrigin = const XYPosition(x: 0, y: 0),
  }) {
    return panzoom.flowToScreenPosition(
      flowPosition: flowPosition,
      viewport: viewport,
      paneOrigin: paneOrigin,
    );
  }

  FlowNode? getNode(String id) => _store.getNode(id);

  FlowHandle? getHandle(String nodeId, HandleType type, [String? handleId]) {
    return _store.getHandle(nodeId, type, handleId);
  }

  FlowNodeInternals? getNodeInternals(String nodeId) {
    return _store.getNodeInternals(nodeId);
  }

  FlowHandleMetrics? getHandleMetrics(
    String nodeId,
    HandleType type, [
    String? handleId,
  ]) {
    return _store.getHandleMetrics(nodeId, type, handleId);
  }

  FlowEdge? getEdge(String id) => _store.getEdge(id);

  void updateNodePosition(String nodeId, XYPosition position) {
    _controller.updateNodePosition(nodeId, position);
  }

  void updateNodeDimensions(String nodeId, double width, double height) {
    _controller.updateNodeDimensions(nodeId, width, height);
  }

  void selectNode(String nodeId) => _controller.selectNode(nodeId);

  void selectEdge(String edgeId) => _controller.selectEdge(edgeId);

  void selectNodesByIds(Set<String> nodeIds) =>
      _controller.selectNodesByIds(nodeIds);

  void clearSelection() => _controller.clearSelection();

  void deleteSelected() => _controller.deleteSelected();

  FlowNode? duplicateSelectedNode() => _controller.duplicateSelectedNode();

  void addConnection(
    FlowConnection connection, {
    String? id,
    ConnectionLineType type = ConnectionLineType.bezier,
    MarkerType? markerEnd = MarkerType.arrowClosed,
  }) {
    _controller.setEdges(
      addEdge(
        connection,
        _controller.edges,
        id: id,
        type: type,
        markerEnd: markerEnd,
      ),
    );
  }

  void reconnect(FlowEdge edge, FlowConnection connection) {
    _controller.setEdges(reconnectEdge(edge, connection, _controller.edges));
  }

  void reconnectById(
    String edgeId, {
    String? source,
    String? target,
    String? sourceHandle,
    String? targetHandle,
  }) {
    _controller.reconnectEdge(
      edgeId,
      source: source,
      target: target,
      sourceHandle: sourceHandle,
      targetHandle: targetHandle,
    );
  }
}
