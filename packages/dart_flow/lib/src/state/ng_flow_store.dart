import 'dart:async';
import 'dart:collection';

import '../system/node_internals.dart';
import '../system/xypanzoom.dart';
import '../types/models.dart';
import '../utils/graph.dart';
import 'flow_controller.dart';

class NgFlowSnapshot {
  NgFlowSnapshot({
    required List<FlowNode> nodes,
    required List<FlowEdge> edges,
    required this.viewport,
    required this.canvasWidth,
    required this.canvasHeight,
  })  : nodes = List<FlowNode>.unmodifiable(nodes),
        edges = List<FlowEdge>.unmodifiable(edges),
        visibleNodes = List<FlowNode>.unmodifiable(
          nodes.where((node) => !node.hidden),
        ),
        visibleEdges = List<FlowEdge>.unmodifiable(
          edges.where((edge) => !edge.hidden),
        ),
        nodeLookup = UnmodifiableMapView<String, FlowNode>({
          for (final node in nodes) node.id: node,
        }),
        nodeInternalsLookup = UnmodifiableMapView<String, FlowNodeInternals>(
          buildNodeInternalsLookup(nodes),
        ),
        handleMetricsLookup = UnmodifiableMapView<String, FlowHandleMetrics>({
          for (final internals in buildNodeInternalsLookup(nodes).values)
            for (final entry in internals.handleLookup.entries)
              entry.key: entry.value,
        }),
        handleLookup = UnmodifiableMapView<String, FlowHandle>({
          for (final entry in buildNodeInternalsLookup(nodes).entries)
            for (final handleEntry in entry.value.handleLookup.entries)
              handleEntry.key: handleEntry.value.handle,
        }),
        edgeLookup = UnmodifiableMapView<String, FlowEdge>({
          for (final edge in edges) edge.id: edge,
        }),
        nodesInsideViewport = List<FlowNode>.unmodifiable(
          getNodesInsideViewport(
            nodes,
            viewport: viewport,
            canvasWidth: canvasWidth,
            canvasHeight: canvasHeight,
          ),
        );

  final List<FlowNode> nodes;
  final List<FlowEdge> edges;
  final List<FlowNode> visibleNodes;
  final List<FlowEdge> visibleEdges;
  final List<FlowNode> nodesInsideViewport;
  final Map<String, FlowNode> nodeLookup;
  final Map<String, FlowNodeInternals> nodeInternalsLookup;
  final Map<String, FlowHandleMetrics> handleMetricsLookup;
  final Map<String, FlowHandle> handleLookup;
  final Map<String, FlowEdge> edgeLookup;
  final Viewport viewport;
  final double canvasWidth;
  final double canvasHeight;

  FlowNode? get selectedNode =>
      nodes.where((node) => node.selected).cast<FlowNode?>().firstOrNull;
  FlowEdge? get selectedEdge =>
      edges.where((edge) => edge.selected).cast<FlowEdge?>().firstOrNull;
  Set<String> get selectedNodeIds =>
      nodes.where((node) => node.selected).map((node) => node.id).toSet();
  Set<String> get selectedEdgeIds =>
      edges.where((edge) => edge.selected).map((edge) => edge.id).toSet();
  List<FlowNode> get selectedNodes =>
      nodes.where((node) => node.selected).toList(growable: false);
  List<FlowEdge> get selectedEdges =>
      edges.where((edge) => edge.selected).toList(growable: false);
  bool get hasSelection =>
      selectedNodeIds.isNotEmpty || selectedEdgeIds.isNotEmpty;
  Rect get nodesBounds => getNodesBounds(nodes);
  Rect get visibleBounds => getNodesBounds(visibleNodes);
  Rect get viewportRect => viewportRectInFlow(
        viewport: viewport,
        canvasWidth: canvasWidth,
        canvasHeight: canvasHeight,
      );
}

class NgFlowStore {
  NgFlowStore(this._controller);

  final FlowController _controller;

  Stream<int> get changes => _controller.changes;
  Stream<NgFlowSnapshot> get snapshots =>
      changes.map((_) => snapshot).asBroadcastStream();
  Stream<Map<String, FlowNode>> get nodeLookupChanges =>
      snapshots.map((snapshot) => snapshot.nodeLookup).asBroadcastStream();
  Stream<Map<String, FlowNodeInternals>> get nodeInternalsLookupChanges =>
      snapshots
          .map((snapshot) => snapshot.nodeInternalsLookup)
          .asBroadcastStream();
  Stream<Map<String, FlowEdge>> get edgeLookupChanges =>
      snapshots.map((snapshot) => snapshot.edgeLookup).asBroadcastStream();
  Stream<Map<String, FlowHandleMetrics>> get handleMetricsLookupChanges =>
      snapshots
          .map((snapshot) => snapshot.handleMetricsLookup)
          .asBroadcastStream();
  Stream<Map<String, FlowHandle>> get handleLookupChanges =>
      snapshots.map((snapshot) => snapshot.handleLookup).asBroadcastStream();
  Stream<List<FlowNode>> get visibleNodesChanges =>
      snapshots.map((snapshot) => snapshot.visibleNodes).asBroadcastStream();
  Stream<List<FlowNode>> get nodesInsideViewportChanges => snapshots
      .map((snapshot) => snapshot.nodesInsideViewport)
      .asBroadcastStream();
  Stream<List<FlowEdge>> get visibleEdgesChanges =>
      snapshots.map((snapshot) => snapshot.visibleEdges).asBroadcastStream();
  Stream<List<FlowNode>> get selectedNodesChanges =>
      snapshots.map((snapshot) => snapshot.selectedNodes).asBroadcastStream();
  Stream<List<FlowEdge>> get selectedEdgesChanges =>
      snapshots.map((snapshot) => snapshot.selectedEdges).asBroadcastStream();
  Stream<Set<String>> get selectedNodeIdsChanges =>
      snapshots.map((snapshot) => snapshot.selectedNodeIds).asBroadcastStream();
  Stream<Set<String>> get selectedEdgeIdsChanges =>
      snapshots.map((snapshot) => snapshot.selectedEdgeIds).asBroadcastStream();
  Stream<bool> get hasSelectionChanges =>
      snapshots.map((snapshot) => snapshot.hasSelection).asBroadcastStream();
  Stream<Rect> get nodesBoundsChanges =>
      snapshots.map((snapshot) => snapshot.nodesBounds).asBroadcastStream();
  Stream<Rect> get visibleBoundsChanges =>
      snapshots.map((snapshot) => snapshot.visibleBounds).asBroadcastStream();
  Stream<Rect> get viewportRectChanges =>
      snapshots.map((snapshot) => snapshot.viewportRect).asBroadcastStream();

  NgFlowSnapshot get snapshot => NgFlowSnapshot(
        nodes: _controller.nodes,
        edges: _controller.edges,
        viewport: _controller.viewport,
        canvasWidth: _controller.canvasWidth,
        canvasHeight: _controller.canvasHeight,
      );

  Map<String, FlowNode> get nodeLookup => snapshot.nodeLookup;
  Map<String, FlowNodeInternals> get nodeInternalsLookup =>
      snapshot.nodeInternalsLookup;
  Map<String, FlowHandleMetrics> get handleMetricsLookup =>
      snapshot.handleMetricsLookup;
  Map<String, FlowHandle> get handleLookup => snapshot.handleLookup;
  Map<String, FlowEdge> get edgeLookup => snapshot.edgeLookup;
  List<FlowNode> get visibleNodes => snapshot.visibleNodes;
  List<FlowEdge> get visibleEdges => snapshot.visibleEdges;
  List<FlowNode> get nodesInsideViewport => snapshot.nodesInsideViewport;
  List<FlowNode> get selectedNodes => snapshot.selectedNodes;
  List<FlowEdge> get selectedEdges => snapshot.selectedEdges;
  bool get hasSelection => snapshot.hasSelection;
  Rect get nodesBounds => snapshot.nodesBounds;
  Rect get visibleBounds => snapshot.visibleBounds;
  Rect get viewportRect => snapshot.viewportRect;
  FlowNode? getNode(String id) => nodeLookup[id];
  FlowNodeInternals? getNodeInternals(String nodeId) =>
      nodeInternalsLookup[nodeId];
  FlowHandleMetrics? getHandleMetrics(
    String nodeId,
    HandleType type, [
    String? handleId,
  ]) {
    return handleMetricsLookup[handleLookupId(nodeId, type, handleId)];
  }

  FlowHandle? getHandle(String nodeId, HandleType type, [String? handleId]) {
    final lookupId = handleLookupId(nodeId, type, handleId);
    return handleLookup[lookupId];
  }

  FlowEdge? getEdge(String id) => edgeLookup[id];
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
