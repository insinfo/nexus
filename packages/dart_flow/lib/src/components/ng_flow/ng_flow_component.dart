import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';

import '../../system/xydrag.dart';
import '../../system/xyhandle.dart';
import '../../system/xypanzoom.dart';
import '../../state/flow_controller.dart';
import '../../state/ng_flow_instance.dart';
import '../../state/ng_flow_interaction_controller.dart';
import '../../state/ng_flow_store.dart';
import '../../types/changes.dart';
import '../../types/models.dart';
import '../../types/renderers.dart';
import '../../utils/edge_paths.dart';
import '../../utils/graph.dart';
import '../background/background_component.dart';
import '../controls/controls_component.dart';
import '../dynamic_edge_host/dynamic_edge_host_component.dart';
import '../dynamic_node_host/dynamic_node_host_component.dart';
import '../minimap/minimap_component.dart';
import '../panel/panel_component.dart';
import '../ng_flow_provider/ng_flow_provider_component.dart';

// extension _FirstOrNullExtension<T> on Iterable<T> {
//   T? get firstOrNull => isEmpty ? null : first;
// }

typedef NodeHtmlRenderer = String Function(FlowNode node);
typedef NodeTextRenderer = String Function(FlowNode node);
typedef EdgePathRenderer = EdgePathResult Function(
    FlowEdge edge, EdgePosition position);
typedef EdgeTextRenderer = String Function(FlowEdge edge);

class FlowConnectionStartEvent {
  const FlowConnectionStartEvent({
    required this.nodeId,
    required this.handleType,
    this.handleId,
  });

  final String? nodeId;
  final String? handleId;
  final HandleType? handleType;
}

class FlowReconnectStartEvent {
  const FlowReconnectStartEvent({
    required this.edge,
    required this.handleType,
  });

  final FlowEdge edge;
  final HandleType handleType;
}

class FlowReconnectEndEvent {
  const FlowReconnectEndEvent({
    required this.edge,
    required this.handleType,
    required this.connectionState,
  });

  final FlowEdge edge;
  final HandleType handleType;
  final XYFinalConnectionState connectionState;
}

@Component(
  selector: 'ng-flow',
  templateUrl: 'ng_flow_component.html',
  styleUrls: ['ng_flow_component.css'],
  directives: [
    coreDirectives,
    BackgroundComponent,
    ControlsComponent,
    DynamicEdgeHostComponent,
    DynamicNodeHostComponent,
    MiniMapComponent,
    PanelComponent,
    NgFlowProviderComponent,
  ],
  providers: [
    ClassProvider(FlowController),
    ClassProvider(NgFlowInteractionController),
    ClassProvider(NgFlowStore),
    ClassProvider(NgFlowInstance),
  ],
)
class NgFlowComponent implements AfterViewInit, OnDestroy {
  NgFlowComponent(
    this._controller,
    this._instance,
    this._interaction,
    this._changeDetectorRef,
  );

  final FlowController _controller;
  final NgFlowInstance _instance;
  final NgFlowInteractionController _interaction;
  final ChangeDetectorRef _changeDetectorRef;

  final _nodesChangeController =
      StreamController<List<FlowNodeChange>>.broadcast();
  final _edgesChangeController =
      StreamController<List<FlowEdgeChange>>.broadcast();
  final _viewportChangeController = StreamController<Viewport>.broadcast();
  final _nodeClickController = StreamController<FlowNode>.broadcast();
  final _nodeDoubleClickController = StreamController<FlowNode>.broadcast();
  final _edgeClickController = StreamController<FlowEdge>.broadcast();
  final _edgeDoubleClickController = StreamController<FlowEdge>.broadcast();
  final _connectController = StreamController<FlowConnection>.broadcast();
  final _reconnectController = StreamController<FlowConnection>.broadcast();
  final _connectStartController =
      StreamController<FlowConnectionStartEvent>.broadcast();
  final _connectEndController =
      StreamController<XYFinalConnectionState>.broadcast();
  final _reconnectStartController =
      StreamController<FlowReconnectStartEvent>.broadcast();
  final _reconnectEndController =
      StreamController<FlowReconnectEndEvent>.broadcast();
  final _selectionController = StreamController<Set<String>>.broadcast();

  StreamSubscription<int>? _subscription;
  StreamSubscription<html.MouseEvent>? _moveSubscription;
  StreamSubscription<html.MouseEvent>? _upSubscription;
  html.ResizeObserver? _resizeObserver;

  html.Element? _viewportHost;
  bool _spacePressed = false;
  int _focusedNodeIndex = -1;
  int _focusedEdgeIndex = -1;

  List<FlowNode> _visibleNodes = const <FlowNode>[];
  List<FlowEdge> _visibleEdges = const <FlowEdge>[];
  String _viewportTransformValue = 'translate(0px, 0px) scale(1)';
  String _svgTransformValue = 'translate(0, 0) scale(1)';

  @ViewChild('viewportHost')
  set viewportHost(html.Element? value) {
    _viewportHost = value;
  }

  @Input()
  bool fitView = true;

  @Input()
  bool nodesDraggable = true;

  @Input()
  bool nodesResizable = true;

  @Input()
  bool selectionOnDrag = true;

  @Input()
  bool keyboardA11y = true;

  @Input()
  bool rovingFocus = true;

  @Input()
  bool connectOnClick = true;

  @Input()
  bool connectOnDrag = true;

  @Input()
  double connectionDragThreshold = 1.0;

  @Input()
  bool autoAddConnectedEdge = false;

  @Input()
  double minZoom = 0.2;

  @Input()
  double maxZoom = 2.0;

  @Input()
  bool snapToGrid = false;

  @Input()
  double snapGridX = 16.0;

  @Input()
  double snapGridY = 16.0;

  @Input()
  bool autoPanOnNodeDrag = true;

  @Input()
  double autoPanPadding = 40.0;

  @Input()
  double autoPanSpeed = 16.0;

  @Input()
  Rect? nodeExtent;

  @Input()
  String deleteKey = 'Delete';

  @Input()
  String panActivationKey = ' ';

  @Input()
  String selectAllKey = 'a';

  @Input()
  NodeTextRenderer? nodeTitleBuilder;

  @Input()
  NodeTextRenderer? nodeSubtitleBuilder;

  @Input()
  NodeHtmlRenderer? nodeHtmlBuilder;

  @Input()
  Map<String, NodeTextRenderer>? nodeTypeTitleBuilders;

  @Input()
  Map<String, NodeTextRenderer>? nodeTypeSubtitleBuilders;

  @Input()
  Map<String, NodeHtmlRenderer>? nodeTypeHtmlBuilders;

  @Input()
  FlowNodeComponentFactoryMap? nodeComponentFactories;

  @Input()
  EdgeTextRenderer? edgeLabelBuilder;

  @Input()
  Map<String, EdgeTextRenderer>? edgeTypeLabelBuilders;

  @Input()
  Map<String, EdgePathRenderer>? edgeTypePathBuilders;

  @Input()
  FlowEdgeComponentFactoryMap? edgeComponentFactories;

  @Input()
  set nodes(List<FlowNode> value) {
    _controller.setNodes(value);
    _syncViewModel();
  }

  @Input()
  set edges(List<FlowEdge> value) {
    _controller.setEdges(value);
    _syncViewModel();
  }

  @Output('nodesChange')
  Stream<List<FlowNodeChange>> get nodesChange => _nodesChangeController.stream;

  @Output('edgesChange')
  Stream<List<FlowEdgeChange>> get edgesChange => _edgesChangeController.stream;

  @Output('viewportChange')
  Stream<Viewport> get viewportChange => _viewportChangeController.stream;

  @Output('nodeClick')
  Stream<FlowNode> get nodeClick => _nodeClickController.stream;

  @Output('nodeDoubleClick')
  Stream<FlowNode> get nodeDoubleClick => _nodeDoubleClickController.stream;

  @Output('edgeClick')
  Stream<FlowEdge> get edgeClick => _edgeClickController.stream;

  @Output('edgeDoubleClick')
  Stream<FlowEdge> get edgeDoubleClick => _edgeDoubleClickController.stream;

  @Output('connect')
  Stream<FlowConnection> get connect => _connectController.stream;

  @Output('reconnect')
  Stream<FlowConnection> get reconnect => _reconnectController.stream;

  @Output('connectStart')
  Stream<FlowConnectionStartEvent> get connectStart =>
      _connectStartController.stream;

  @Output('connectEnd')
  Stream<XYFinalConnectionState> get connectEnd => _connectEndController.stream;

  @Output('reconnectStart')
  Stream<FlowReconnectStartEvent> get reconnectStart =>
      _reconnectStartController.stream;

  @Output('reconnectEnd')
  Stream<FlowReconnectEndEvent> get reconnectEnd =>
      _reconnectEndController.stream;

  @Output('selectionChange')
  Stream<Set<String>> get selectionChange => _selectionController.stream;

  List<FlowNode> get visibleNodes => _visibleNodes;
  List<FlowEdge> get visibleEdges => _visibleEdges;
  String get viewportTransform => _viewportTransformValue;
  String get svgTransform => _svgTransformValue;
  FlowNode? get selectedNode => _controller.selectedNode;
  FlowEdge? get selectedEdge => _controller.selectedEdge;
  bool get hasSelectionRect => _interaction.hasSelectionRect;
  bool get hasConnectionPreview => _interaction.hasConnectionPreview;
  bool get hasReconnectPreview => _interaction.hasReconnectPreview;
  XYFinalConnectionState? get lastConnectionEndState =>
      _interaction.lastConnectionEndState;
  XYFinalConnectionState? get lastReconnectEndState =>
      _interaction.lastReconnectEndState;
  bool get isPanning => _spacePressed || _interaction.isPanning;
  String get accessibilityDescription =>
      'Use Tab para navegar entre nos e arestas, Enter ou espaco para selecionar, setas para mover o no selecionado, Delete para remover, F para enquadrar e Escape para limpar a selecao.';

  String get selectionRectStyle {
    if (!hasSelectionRect) {
      return 'display:none;';
    }

    final start = _interaction.selectionStartLocal!;
    final current = _interaction.selectionCurrentLocal!;
    final left = start.x < current.x ? start.x : current.x;
    final top = start.y < current.y ? start.y : current.y;
    final width = (start.x - current.x).abs();
    final height = (start.y - current.y).abs();
    return 'left:${left}px;top:${top}px;width:${width}px;height:${height}px;';
  }

  String get previewPath {
    if (hasReconnectPreview) {
      return _reconnectPreviewPath();
    }
    if (hasConnectionPreview) {
      return _connectionPreviewPath();
    }
    return '';
  }

  String get nodeToolbarStyle {
    final node = selectedNode;
    if (node == null) {
      return 'display:none;';
    }

    final x = (node.position.x + node.width / 2) * _controller.viewport.zoom +
        _controller.viewport.x;
    final y = node.position.y * _controller.viewport.zoom +
        _controller.viewport.y -
        48;
    return 'left:${x}px;top:${y}px;';
  }

  String get edgeToolbarStyle {
    final edge = selectedEdge;
    if (edge == null) {
      return 'display:none;';
    }

    final position = getEdgePosition(edge, visibleNodes);
    if (position == null) {
      return 'display:none;';
    }

    final result = _edgeResult(edge, position);
    final x =
        result.labelX * _controller.viewport.zoom + _controller.viewport.x;
    final y =
        result.labelY * _controller.viewport.zoom + _controller.viewport.y - 44;
    return 'left:${x}px;top:${y}px;';
  }

  String nodeStyle(FlowNode node) =>
      'left: ${node.position.x}px; top: ${node.position.y}px; width: ${node.width}px; height: ${node.height}px; z-index: ${node.zIndex};';

  int nodeTabIndex(FlowNode node, int index) {
    if (!keyboardA11y || !rovingFocus) {
      return 0;
    }
    if (_focusedNodeIndex == -1 && _focusedEdgeIndex == -1) {
      return index == 0 ? 0 : -1;
    }
    return _focusedNodeIndex == index ? 0 : -1;
  }

  int edgeTabIndex(FlowEdge edge, int index) {
    if (!keyboardA11y || !rovingFocus) {
      return 0;
    }
    return _focusedEdgeIndex == index ? 0 : -1;
  }

  String nodeTabIndexAttr(FlowNode node, int index) =>
      '${nodeTabIndex(node, index)}';
  String edgeTabIndexAttr(FlowEdge edge, int index) =>
      '${edgeTabIndex(edge, index)}';
  String nodeAriaSelected(FlowNode node) => '${node.selected}';

  String edgePath(FlowEdge edge) {
    final position = getEdgePosition(edge, visibleNodes);
    if (position == null) {
      return '';
    }

    return _edgeResult(edge, position).path;
  }

  String edgeLabelXAttr(FlowEdge edge) {
    final position = getEdgePosition(edge, visibleNodes);
    if (position == null) {
      return '0';
    }
    return '${_edgeResult(edge, position).labelX}';
  }

  String edgeLabelYAttr(FlowEdge edge) {
    final position = getEdgePosition(edge, visibleNodes);
    if (position == null) {
      return '0';
    }
    return '${_edgeResult(edge, position).labelY}';
  }

  String markerEnd(FlowEdge edge) {
    if (edge.markerEnd == null) {
      return '';
    }
    return 'url(#rf-marker-${edge.markerEnd!.value})';
  }

  String markerStart(FlowEdge edge) {
    if (edge.markerStart == null) {
      return '';
    }
    return 'url(#rf-marker-${edge.markerStart!.value})';
  }

  String edgeInteractionWidth(FlowEdge edge) => '${edge.interactionWidth}';
  String edgeAriaLabel(FlowEdge edge) =>
      edge.ariaLabel ??
      'Aresta ${edge.id} de ${edge.source} para ${edge.target}';

  String edgeLabelText(FlowEdge edge) {
    final customType = edge.customType;
    if (customType != null) {
      final renderer = edgeTypeLabelBuilders?[customType];
      if (renderer != null) {
        return renderer(edge);
      }
    }

    return edgeLabelBuilder?.call(edge) ?? (edge.label ?? '');
  }

  bool shouldRenderEdgeLabel(FlowEdge edge) {
    if (hasDynamicEdgeComponent(edge)) {
      return false;
    }

    return edge.label != null ||
        edgeLabelBuilder != null ||
        (edge.customType != null &&
            edgeTypeLabelBuilders?[edge.customType!] != null);
  }

  bool hasCustomNodeHtml(FlowNode node) {
    if (hasDynamicNodeComponent(node)) {
      return false;
    }

    if (node.type != null && nodeTypeHtmlBuilders?[node.type!] != null) {
      return true;
    }
    return nodeHtmlBuilder != null;
  }

  String nodeTitle(FlowNode node) {
    if (node.type != null) {
      final renderer = nodeTypeTitleBuilders?[node.type!];
      if (renderer != null) {
        return renderer(node);
      }
    }
    return nodeTitleBuilder?.call(node) ?? node.label;
  }

  String nodeSubtitle(FlowNode node) {
    if (node.type != null) {
      final renderer = nodeTypeSubtitleBuilders?[node.type!];
      if (renderer != null) {
        return renderer(node);
      }
    }
    return nodeSubtitleBuilder?.call(node) ?? (node.type ?? 'default');
  }

  String nodeIconClass(FlowNode node) {
    switch (node.type) {
      case 'inicio':
        return 'ph-sign-in';
      case 'fim':
        return 'ph-sign-out';
      case 'formulario':
        return 'ph-list-bullets';
      case 'conteudo_dinamico':
        return 'ph-file-text';
      case 'api':
        return 'ph-plugs';
      case 'condicao':
        return 'ph-git-branch';
      case 'regra':
        return 'ph-scales';
      case 'classificacao':
        return 'ph-sort-ascending';
      case 'email':
        return 'ph-envelope-simple';
      case 'notificacao':
        return 'ph-bell';
      case 'triagem':
        return 'ph-users';
      case 'acao_status':
        return 'ph-flag';
      case 'distribuicao':
        return 'ph-share-network';
      case 'temporizador':
        return 'ph-clock';
      default:
        return 'ph-cube';
    }
  }

  String nodeHtml(FlowNode node) {
    if (node.type != null) {
      final renderer = nodeTypeHtmlBuilders?[node.type!];
      if (renderer != null) {
        return renderer(node);
      }
    }
    return nodeHtmlBuilder?.call(node) ?? '';
  }

  bool hasDynamicNodeComponent(FlowNode node) {
    final type = node.type;
    return type != null && nodeComponentFactories?[type] != null;
  }

  ComponentFactory<Object>? nodeComponentFactory(FlowNode node) {
    final type = node.type;
    if (type == null) {
      return null;
    }
    return nodeComponentFactories?[type];
  }

  FlowNodeRenderContext nodeRenderContext(FlowNode node) {
    return FlowNodeRenderContext(
      node: node,
      instance: _instance,
      selected: node.selected,
    );
  }

  bool hasDynamicEdgeComponent(FlowEdge edge) {
    final type = edge.customType;
    return type != null && edgeComponentFactories?[type] != null;
  }

  ComponentFactory<Object>? edgeComponentFactory(FlowEdge edge) {
    final type = edge.customType;
    if (type == null) {
      return null;
    }
    return edgeComponentFactories?[type];
  }

  FlowEdgeRenderContext? edgeRenderContext(FlowEdge edge) {
    final position = getEdgePosition(edge, visibleNodes);
    if (position == null) {
      return null;
    }

    return FlowEdgeRenderContext(
      edge: edge,
      position: position,
      path: _edgeResult(edge, position),
      instance: _instance,
      selected: edge.selected,
    );
  }

  String edgeComponentStyle(FlowEdge edge) {
    final position = getEdgePosition(edge, visibleNodes);
    if (position == null) {
      return 'display:none;';
    }

    final result = _edgeResult(edge, position);
    final x =
        result.labelX * _controller.viewport.zoom + _controller.viewport.x;
    final y =
        result.labelY * _controller.viewport.zoom + _controller.viewport.y;
    return 'left:${x}px;top:${y}px;';
  }

  String handleClass(Position position, bool source) {
    return 'rf-node__handle rf-node__handle--${position.value} ${source ? 'rf-node__handle--source' : 'rf-node__handle--target'}';
  }

  String handleStyle(FlowHandle handle) {
    if (!handleUsesExplicitCoordinates(handle)) {
      return '';
    }

    return 'left:${handle.x}px;top:${handle.y}px;width:${handle.width}px;height:${handle.height}px;';
  }

  bool handleUsesExplicitCoordinates(FlowHandle handle) {
    return handle.x != 0 ||
        handle.y != 0 ||
        handle.width != 12 ||
        handle.height != 12;
  }

  List<FlowHandle> sourceHandlesForNode(FlowNode node) {
    return _instance
            .getNodeInternals(node.id)
            ?.sourceHandles
            .map((handle) => handle.handle)
            .toList(growable: false) ??
        const <FlowHandle>[];
  }

  List<FlowHandle> targetHandlesForNode(FlowNode node) {
    return _instance
            .getNodeInternals(node.id)
            ?.targetHandles
            .map((handle) => handle.handle)
            .toList(growable: false) ??
        const <FlowHandle>[];
  }

  Object? trackByHandle(int index, dynamic handle) {
    final typedHandle = handle as FlowHandle;
    return '${typedHandle.type.name}:${typedHandle.id ?? index}:${typedHandle.position.value}';
  }

  bool isConnectionSource(FlowNode node, [FlowHandle? handle]) {
    if (_interaction.connectionStartNodeId != node.id) {
      return false;
    }

    return handle == null || handle.id == _interaction.connectionStartHandleId;
  }

  String resizeHandleStyle(FlowNode node) =>
      'left:${node.width - 8}px;top:${node.height - 8}px;';

  String selectedEdgeAnchorStyle(bool source) {
    final edge = selectedEdge;
    if (edge == null) {
      return 'display:none;';
    }
    return reconnectAnchorStyle(edge, source);
  }

  void onSelectedEdgeReconnectStart(html.MouseEvent event, bool sourceHandle) {
    final edge = selectedEdge;
    if (edge == null) {
      return;
    }
    onReconnectAnchorMouseDown(event, edge, sourceHandle);
  }

  String reconnectAnchorStyle(FlowEdge edge, bool source) {
    final position = getEdgePosition(edge, visibleNodes);
    if (position == null) {
      return 'display:none;';
    }

    final x = (source ? position.sourceX : position.targetX) *
            _controller.viewport.zoom +
        _controller.viewport.x;
    final y = (source ? position.sourceY : position.targetY) *
            _controller.viewport.zoom +
        _controller.viewport.y;
    return 'left:${x - 6}px;top:${y - 6}px;';
  }

  Object? trackByNodeId(int index, dynamic node) => (node as FlowNode).id;
  Object? trackByEdgeId(int index, dynamic edge) => (edge as FlowEdge).id;

  void onNodeFocus(FlowNode node, int index) {
    _focusedNodeIndex = index;
    _focusedEdgeIndex = -1;
  }

  void onEdgeFocus(FlowEdge edge, int index) {
    _focusedEdgeIndex = index;
    _focusedNodeIndex = -1;
  }

  void onNodeKeyDown(html.KeyboardEvent event, FlowNode node, int index) {
    if (!keyboardA11y) {
      return;
    }

    if (event.key == ' ' || event.key == 'Enter') {
      event.preventDefault();
      onNodeClick(node);
      return;
    }

    if (event.key == 'Tab' && rovingFocus) {
      event.preventDefault();
      _focusNextTarget(reverse: event.shiftKey);
      return;
    }

    if (event.key == deleteKey || event.key == 'Backspace') {
      event.preventDefault();
      _controller.deleteSelected();
      _syncViewModel();
      return;
    }

    if (nodesResizable &&
        event.shiftKey &&
        (event.key == 'ArrowUp' ||
            event.key == 'ArrowDown' ||
            event.key == 'ArrowLeft' ||
            event.key == 'ArrowRight')) {
      event.preventDefault();
      _resizeSelectedWithKeyboard(event.key!);
      return;
    }
  }

  void onEdgeKeyDown(html.KeyboardEvent event, FlowEdge edge, int index) {
    if (!keyboardA11y) {
      return;
    }

    if (event.key == ' ' || event.key == 'Enter') {
      event.preventDefault();
      _controller.selectEdge(edge.id);
      _edgeClickController.add(edge);
      return;
    }

    if (event.key == 'Tab' && rovingFocus) {
      event.preventDefault();
      _focusNextTarget(reverse: event.shiftKey);
      return;
    }

    if (event.key == deleteKey || event.key == 'Backspace') {
      event.preventDefault();
      _controller.deleteSelected();
      _syncViewModel();
      return;
    }
  }

  void onPaneMouseDown(html.MouseEvent event) {
    if (event.button != 0 && event.button != 1) {
      return;
    }

    _controller.clearSelection();
    _selectionController.add(<String>{});
    _interaction.cancelConnection();

    if (_spacePressed || event.button == 1) {
      _startPan(event);
    } else if (selectionOnDrag) {
      _startSelection(event);
    }

    _bindDocumentDrag();
  }

  void onNodeMouseDown(html.MouseEvent event, FlowNode node) {
    event.stopPropagation();
    if (!nodesDraggable || !node.draggable) {
      return;
    }

    final selectedNodes = _instance.selectedNodeIds.contains(node.id)
        ? _instance.selectedNodes
        : <FlowNode>[node];
    final startPositions = <String, XYPosition>{
      for (final selectedNode in selectedNodes)
        selectedNode.id: selectedNode.position,
    };
    _interaction.startNodeDrag(
      nodeId: node.id,
      pointer: _toLocal(event.client.x.toDouble(), event.client.y.toDouble()),
      startPosition: node.position,
      viewport: _controller.viewport,
      startPositions: startPositions,
    );
    _controller.selectNode(node.id);
    _controller.setNodesDragging(startPositions.keys.toSet(), true);
    _selectionController.add(<String>{node.id});
    _bindDocumentDrag();
  }

  void onNodeClick(FlowNode node) {
    _controller.selectNode(node.id);
    _selectionController.add(<String>{node.id});
    _nodeClickController.add(node);
  }

  void onNodeDoubleClick(FlowNode node, html.MouseEvent event) {
    event.stopPropagation();
    _controller.selectNode(node.id);
    _selectionController.add(<String>{node.id});
    _nodeDoubleClickController.add(node);
  }

  void onEdgeClick(FlowEdge edge, html.MouseEvent event) {
    event.stopPropagation();
    _controller.selectEdge(edge.id);
    _edgeClickController.add(edge);
  }

  void onEdgeDoubleClick(FlowEdge edge, html.MouseEvent event) {
    event.stopPropagation();
    _controller.selectEdge(edge.id);
    _edgeDoubleClickController.add(edge);
  }

  void onWheel(html.WheelEvent event) {
    event.preventDefault();
    final host = _viewportHost;
    if (host == null) {
      return;
    }

    final rect = host.getBoundingClientRect();
    final anchorX = (event.client.x - rect.left).toDouble();
    final anchorY = (event.client.y - rect.top).toDouble();
    final factor = event.deltaY < 0 ? 1.12 : 0.88;
    _controller.zoomTo(_controller.viewport.zoom * factor,
        anchorX: anchorX, anchorY: anchorY);
    _viewportChangeController.add(_controller.viewport);
  }

  void onShellKeyDown(html.KeyboardEvent event) {
    if (!keyboardA11y) {
      return;
    }

    if (event.key == panActivationKey) {
      _spacePressed = true;
      return;
    }

    if (event.key == deleteKey || event.key == 'Backspace') {
      event.preventDefault();
      _controller.deleteSelected();
      _syncViewModel();
      return;
    }

    if (event.key == 'Escape') {
      _cancelPointerModes();
      _controller.clearSelection();
      _syncViewModel();
      _changeDetectorRef.markForCheck();
      return;
    }

    if (event.key == '+' || event.key == '=') {
      _controller.zoomIn();
      return;
    }

    if (event.key == '-' || event.key == '_') {
      _controller.zoomOut();
      return;
    }

    if (event.key == 'f' || event.key == 'F') {
      _controller.fitView();
      return;
    }

    if (event.key == 'd' || event.key == 'D') {
      _controller.duplicateSelectedNode();
      return;
    }

    final key = event.key;
    if ((event.ctrlKey || event.metaKey) &&
        key != null &&
        key.toLowerCase() == selectAllKey.toLowerCase()) {
      event.preventDefault();
      _controller.selectNodesByIds(
        _visibleNodes.map((node) => node.id).toSet(),
      );
      _selectionController.add(_visibleNodes.map((node) => node.id).toSet());
      return;
    }

    if (event.key == 'PageUp') {
      event.preventDefault();
      _controller.zoomIn();
      return;
    }

    if (event.key == 'PageDown') {
      event.preventDefault();
      _controller.zoomOut();
      return;
    }

    if (event.key == 'Home') {
      event.preventDefault();
      _focusFirstNode();
      return;
    }

    if (event.key == 'End') {
      event.preventDefault();
      _focusLastEdgeOrNode();
      return;
    }

    const step = 20.0;
    if (event.key == 'ArrowUp') {
      event.preventDefault();
      _handleArrowInput(0, -step);
    } else if (event.key == 'ArrowDown') {
      event.preventDefault();
      _handleArrowInput(0, step);
    } else if (event.key == 'ArrowLeft') {
      event.preventDefault();
      _handleArrowInput(-step, 0);
    } else if (event.key == 'ArrowRight') {
      event.preventDefault();
      _handleArrowInput(step, 0);
    }
  }

  void onShellKeyUp(html.KeyboardEvent event) {
    if (event.key == panActivationKey) {
      _spacePressed = false;
    }
  }

  void onSourceHandleMouseDown(
      html.MouseEvent event, FlowNode node, FlowHandle handle) {
    event.stopPropagation();
    if (!node.connectable) {
      return;
    }

    final pointer =
        getNodeConnectionPoint(node, handle.position, handle: handle);
    final activated = _interaction.startConnection(
      nodeId: node.id,
      handleType: HandleType.source,
      handleId: handle.id,
      pointer: pointer,
      dragThreshold: connectionDragThreshold,
    );
    if (activated) {
      _emitConnectStart();
    }
    _bindDocumentDrag();
    _changeDetectorRef.markForCheck();
  }

  void onSourceHandleMouseUp(
      html.MouseEvent event, FlowNode node, FlowHandle handle) {
    event.stopPropagation();

    if (_interaction.reconnectEdgeId == null ||
        !_interaction.reconnectSourceHandle) {
      return;
    }

    _finalizeReconnect(node.id, handle.id);
  }

  void onTargetHandleMouseUp(
      html.MouseEvent event, FlowNode node, FlowHandle handle) {
    event.stopPropagation();
    if (_interaction.reconnectEdgeId != null) {
      _finalizeReconnect(node.id, handle.id);
      return;
    }

    final connection = _interaction.completeConnection(
      nodeId: node.id,
      handleId: handle.id,
      handleType: HandleType.target,
    );
    _emitConnectEnd(_interaction.lastConnectionEndState);
    if (connection == null) {
      return;
    }
    _connectController.add(connection);
    if (autoAddConnectedEdge) {
      _addConnectedEdge(connection);
    }
    _syncViewModel();
    _changeDetectorRef.markForCheck();
  }

  void onTargetHandleMouseDown(html.MouseEvent event) {
    event.stopPropagation();
  }

  void onHandleClick(
      html.MouseEvent event, FlowNode node, bool source, FlowHandle handle) {
    event.stopPropagation();
    if (!connectOnClick || !node.connectable) {
      return;
    }

    if (source) {
      final pointer =
          getNodeConnectionPoint(node, handle.position, handle: handle);
      _interaction.startConnection(
        nodeId: node.id,
        handleType: HandleType.source,
        handleId: handle.id,
        pointer: pointer,
        dragThreshold: 0,
      );
      _changeDetectorRef.markForCheck();
      return;
    }

    final connection = _interaction.completeConnection(
      nodeId: node.id,
      handleId: handle.id,
      handleType: HandleType.target,
    );
    if (connection == null) {
      return;
    }
    _connectController.add(connection);
    if (autoAddConnectedEdge) {
      _addConnectedEdge(connection);
    }
    _syncViewModel();
    _changeDetectorRef.markForCheck();
  }

  void onReconnectAnchorMouseDown(
      html.MouseEvent event, FlowEdge edge, bool sourceHandle) {
    event.stopPropagation();
    final position = getEdgePosition(edge, visibleNodes);
    if (position == null) {
      return;
    }

    final activated = _interaction.startReconnect(
      edge: edge,
      sourceHandle: sourceHandle,
      pointer: XYPosition(
        x: sourceHandle ? position.sourceX : position.targetX,
        y: sourceHandle ? position.sourceY : position.targetY,
      ),
      dragThreshold: connectionDragThreshold,
    );
    if (activated) {
      _emitConnectStart();
      _emitReconnectStart(edge);
    }
    _bindDocumentDrag();
  }

  void onResizeHandleMouseDown(html.MouseEvent event, FlowNode node) {
    if (!nodesResizable) {
      return;
    }
    event.stopPropagation();
    _interaction.startResize(
      nodeId: node.id,
      pointer: _toLocal(event.client.x.toDouble(), event.client.y.toDouble()),
      width: node.width,
      height: node.height,
    );
    _bindDocumentDrag();
  }

  void duplicateSelectedNode() {
    final duplicated = _controller.duplicateSelectedNode();
    if (duplicated != null) {
      _nodesChangeController.add([FlowNodeAddChange(item: duplicated)]);
    }
    _syncViewModel();
  }

  void deleteSelected() {
    final deletedNodeIds = _instance.selectedNodeIds.toList();
    final deletedEdgeIds = _instance.selectedEdgeIds.toList();

    for (final edge in _instance.edges) {
      if (deletedNodeIds.contains(edge.source) ||
          deletedNodeIds.contains(edge.target)) {
        if (!deletedEdgeIds.contains(edge.id)) {
          deletedEdgeIds.add(edge.id);
        }
      }
    }

    if (deletedNodeIds.isNotEmpty) {
      _nodesChangeController.add(
          deletedNodeIds.map((id) => FlowNodeRemoveChange(id: id)).toList());
    }
    if (deletedEdgeIds.isNotEmpty) {
      _edgesChangeController.add(
          deletedEdgeIds.map((id) => FlowEdgeRemoveChange(id: id)).toList());
    }

    _controller.deleteSelected();
    _syncViewModel();
  }

  void reverseSelectedEdge() {
    final edge = selectedEdge;
    if (edge == null) {
      return;
    }

    _controller.reconnectEdge(edge.id,
        source: edge.target, target: edge.source);
    _edgesChangeController.add([
      FlowEdgeReplaceChange(
          item: edge.copyWith(source: edge.target, target: edge.source)),
    ]);
  }

  @override
  void ngAfterViewInit() {
    _controller.minZoom = minZoom;
    _controller.maxZoom = maxZoom;
    _syncViewModel();

    _subscription = _instance.changes.listen((_) {
      _syncViewModel();
      _changeDetectorRef.markForCheck();
      _viewportChangeController.add(_controller.viewport);
    });

    Future<void>.delayed(Duration.zero, () {
      _updateCanvasSize();

      final host = _viewportHost;
      if (host != null) {
        _resizeObserver = html.ResizeObserver((_, __) {
          _updateCanvasSize();
        })
          ..observe(host);
      }

      if (fitView) {
        _controller.fitView();
      }

      _syncViewModel();
      _changeDetectorRef.markForCheck();
    });
  }

  @override
  void ngOnDestroy() {
    _subscription?.cancel();
    _moveSubscription?.cancel();
    _upSubscription?.cancel();
    _resizeObserver?.disconnect();
    _nodesChangeController.close();
    _edgesChangeController.close();
    _viewportChangeController.close();
    _nodeClickController.close();
    _nodeDoubleClickController.close();
    _edgeClickController.close();
    _edgeDoubleClickController.close();
    _connectController.close();
    _reconnectController.close();
    _connectStartController.close();
    _connectEndController.close();
    _reconnectStartController.close();
    _reconnectEndController.close();
    _selectionController.close();
    _controller.dispose();
  }

  EdgePathResult _edgeResult(FlowEdge edge, EdgePosition position) {
    final customType = edge.customType;
    if (customType != null) {
      final renderer = edgeTypePathBuilders?[customType];
      if (renderer != null) {
        return renderer(edge, position);
      }
    }

    switch (edge.type) {
      case ConnectionLineType.straight:
        return getStraightPath(
          sourceX: position.sourceX,
          sourceY: position.sourceY,
          targetX: position.targetX,
          targetY: position.targetY,
        );
      case ConnectionLineType.step:
      case ConnectionLineType.smoothStep:
        return getSmoothStepPath(
          sourceX: position.sourceX,
          sourceY: position.sourceY,
          sourcePosition: position.sourcePosition,
          targetX: position.targetX,
          targetY: position.targetY,
          targetPosition: position.targetPosition,
        );
      case ConnectionLineType.simpleBezier:
        return getSimpleBezierPath(
          sourceX: position.sourceX,
          sourceY: position.sourceY,
          sourcePosition: position.sourcePosition,
          targetX: position.targetX,
          targetY: position.targetY,
          targetPosition: position.targetPosition,
        );
      case ConnectionLineType.bezier:
        return getBezierPath(
          sourceX: position.sourceX,
          sourceY: position.sourceY,
          sourcePosition: position.sourcePosition,
          targetX: position.targetX,
          targetY: position.targetY,
          targetPosition: position.targetPosition,
        );
    }
  }

  void _updateCanvasSize() {
    final host = _viewportHost;
    if (host == null) {
      return;
    }
    final rect = host.getBoundingClientRect();
    _controller.setCanvasSize(rect.width.toDouble(), rect.height.toDouble());
  }

  void _syncViewModel() {
    _visibleNodes =
        _controller.nodes.where((node) => !node.hidden).toList(growable: false);
    _visibleEdges =
        _controller.edges.where((edge) => !edge.hidden).toList(growable: false);

    final viewport = _controller.viewport;
    _viewportTransformValue =
        'translate(${viewport.x}px, ${viewport.y}px) scale(${viewport.zoom})';
    _svgTransformValue =
        'translate(${viewport.x}, ${viewport.y}) scale(${viewport.zoom})';
  }

  void _bindDocumentDrag() {
    _moveSubscription ??=
        html.document.onMouseMove.listen(_onDocumentMouseMove);
    _upSubscription ??= html.document.onMouseUp.listen(_onDocumentMouseUp);
  }

  void _onDocumentMouseMove(html.MouseEvent event) {
    if (_interaction.dragNodeId != null) {
      final draggedNode = _controller.nodes
          .where((node) => node.id == _interaction.dragNodeId)
          .firstOrNull;
      if (draggedNode == null) {
        return;
      }

      final dragDimensions = <String, Dimensions>{
        for (final node in _controller.nodes)
          if (_interaction.dragStartPositions.containsKey(node.id))
            node.id: Dimensions(width: node.width, height: node.height),
      };

      final dragResult = _interaction.computeNodeDrag(
        pointer: _toLocal(event.client.x.toDouble(), event.client.y.toDouble()),
        dimensions: dragDimensions,
        canvasWidth: _controller.canvasWidth,
        canvasHeight: _controller.canvasHeight,
        config: XYDragConfig(
          snapToGrid: snapToGrid,
          snapGrid: XYPosition(x: snapGridX, y: snapGridY),
          extent: nodeExtent,
          autoPan: autoPanOnNodeDrag,
          autoPanPadding: autoPanPadding,
          autoPanStep: autoPanSpeed,
        ),
      );

      if (dragResult.viewportDelta.x != 0 || dragResult.viewportDelta.y != 0) {
        _controller.panBy(
          dragResult.viewportDelta.x,
          dragResult.viewportDelta.y,
        );
      }

      _controller.updateNodePositions(dragResult.positions);
      _nodesChangeController.add([
        for (final entry in dragResult.positions.entries)
          FlowNodePositionChange(id: entry.key, position: entry.value),
      ]);
      return;
    }

    if (_interaction.resizeNodeId != null) {
      final nextSize = _interaction.computeResize(
        pointer: _toLocal(event.client.x.toDouble(), event.client.y.toDouble()),
        viewport: _controller.viewport,
      );
      _controller.updateNodeDimensions(
          _interaction.resizeNodeId!, nextSize.width, nextSize.height);
      return;
    }

    if ((_interaction.hasPendingConnectionGesture ||
            _interaction.activeConnectionKind ==
                XYConnectionLifecycleKind.connect) &&
        connectOnDrag) {
      final activated = _interaction.updateConnection(
        _toWorld(event.client.x.toDouble(), event.client.y.toDouble()),
      );
      if (activated) {
        _emitConnectStart();
      }
      _changeDetectorRef.markForCheck();
      return;
    }

    if (_interaction.hasPendingReconnectGesture ||
        _interaction.activeConnectionKind ==
            XYConnectionLifecycleKind.reconnect) {
      final activated = _interaction.updateReconnect(
        _toWorld(event.client.x.toDouble(), event.client.y.toDouble()),
      );
      if (activated) {
        _emitConnectStart();
        final edge = _activeReconnectEdge;
        if (edge != null) {
          _emitReconnectStart(edge);
        }
      }
      _changeDetectorRef.markForCheck();
      return;
    }

    if (_interaction.isSelecting) {
      _interaction.updateSelection(
        _toLocal(event.client.x.toDouble(), event.client.y.toDouble()),
      );
      _changeDetectorRef.markForCheck();
      return;
    }

    if (_interaction.isPanning) {
      _controller.setViewportConstrained(
        _interaction.computePan(
          pointer:
              _toLocal(event.client.x.toDouble(), event.client.y.toDouble()),
          viewport: _controller.viewport,
        ),
      );
    }
  }

  void _onDocumentMouseUp(html.MouseEvent _) {
    if (_interaction.dragNodeId != null) {
      _controller.setNodesDragging(
        _interaction.dragStartPositions.keys.toSet(),
        false,
      );
      _interaction.stopNodeDrag();
    }

    if (_interaction.resizeNodeId != null) {
      final resizedNode = _controller.nodes
          .where((node) => node.id == _interaction.resizeNodeId)
          .firstOrNull;
      if (resizedNode != null) {
        _nodesChangeController.add([FlowNodeReplaceChange(item: resizedNode)]);
      }
    }

    if (_interaction.isSelecting) {
      _finalizeSelection();
    }

    if ((_interaction.hasPendingConnectionGesture ||
            _interaction.activeConnectionKind ==
                XYConnectionLifecycleKind.connect) &&
        connectOnDrag) {
      _emitConnectEnd(_interaction.cancelConnection());
    }

    if (_interaction.hasPendingReconnectGesture ||
        _interaction.activeConnectionKind ==
            XYConnectionLifecycleKind.reconnect) {
      final edge = _activeReconnectEdge;
      final endState = _interaction.cancelReconnect();
      _emitConnectEnd(endState);
      if (edge != null && endState != null) {
        _emitReconnectEnd(edge, endState);
      }
    }

    _interaction.finishDocumentPointer();
    _moveSubscription?.cancel();
    _upSubscription?.cancel();
    _moveSubscription = null;
    _upSubscription = null;
    _changeDetectorRef.markForCheck();
  }

  void _startPan(html.MouseEvent event) {
    _interaction.startPan(
      pointer: _toLocal(event.client.x.toDouble(), event.client.y.toDouble()),
      viewport: _controller.viewport,
      mouseButton: event.button,
    );
  }

  void _startSelection(html.MouseEvent event) {
    _interaction.startSelection(
      _toLocal(event.client.x.toDouble(), event.client.y.toDouble()),
    );
  }

  void _finalizeSelection() {
    final nodeIds = _interaction.finalizeSelection(
      _visibleNodes,
      _toWorldFromLocal,
    );

    _controller.selectNodesByIds(nodeIds);
    _selectionController.add(nodeIds);
  }

  void _cancelPointerModes() {
    _interaction.clearPointerModes();
  }

  void _resizeSelectedWithKeyboard(String key) {
    if (!nodesResizable) {
      return;
    }
    final node = selectedNode;
    if (node == null) {
      return;
    }

    const step = 16.0;
    var width = node.width;
    var height = node.height;
    switch (key) {
      case 'ArrowUp':
        height -= step;
      case 'ArrowDown':
        height += step;
      case 'ArrowLeft':
        width -= step;
      case 'ArrowRight':
        width += step;
    }
    _controller.updateNodeDimensions(node.id, width, height);
    final updatedNode = _controller.nodes
        .where((candidate) => candidate.id == node.id)
        .firstOrNull;
    if (updatedNode != null) {
      _nodesChangeController.add([FlowNodeReplaceChange(item: updatedNode)]);
    }
  }

  void _focusFirstNode() {
    if (_visibleNodes.isEmpty) {
      return;
    }
    _focusedNodeIndex = 0;
    _focusedEdgeIndex = -1;
    _changeDetectorRef.markForCheck();
  }

  void _focusLastEdgeOrNode() {
    if (_visibleEdges.isNotEmpty) {
      _focusedEdgeIndex = _visibleEdges.length - 1;
      _focusedNodeIndex = -1;
    } else if (_visibleNodes.isNotEmpty) {
      _focusedNodeIndex = _visibleNodes.length - 1;
      _focusedEdgeIndex = -1;
    }
    _changeDetectorRef.markForCheck();
  }

  void _focusNextTarget({required bool reverse}) {
    final targetCount = _visibleNodes.length + _visibleEdges.length;
    if (targetCount == 0) {
      return;
    }

    var flatIndex = _focusedNodeIndex >= 0
        ? _focusedNodeIndex
        : (_focusedEdgeIndex >= 0
            ? _visibleNodes.length + _focusedEdgeIndex
            : 0);
    flatIndex = reverse
        ? (flatIndex - 1 + targetCount) % targetCount
        : (flatIndex + 1) % targetCount;

    if (flatIndex < _visibleNodes.length) {
      _focusedNodeIndex = flatIndex;
      _focusedEdgeIndex = -1;
    } else {
      _focusedNodeIndex = -1;
      _focusedEdgeIndex = flatIndex - _visibleNodes.length;
    }
    _changeDetectorRef.markForCheck();
  }

  void _handleArrowInput(double dx, double dy) {
    final node = selectedNode;
    if (node != null) {
      final nextPosition = node.position.translate(dx, dy);
      _controller.updateNodePosition(node.id, nextPosition);
      _nodesChangeController
          .add([FlowNodePositionChange(id: node.id, position: nextPosition)]);
      return;
    }

    _controller.panBy(dx, dy);
  }

  XYPosition _toLocal(double clientX, double clientY) {
    final rect = _viewportHost?.getBoundingClientRect();
    if (rect == null) {
      return const XYPosition(x: 0, y: 0);
    }
    return XYPosition(x: clientX - rect.left, y: clientY - rect.top);
  }

  XYPosition _toWorld(double clientX, double clientY) {
    final rect = _viewportHost?.getBoundingClientRect();
    return screenToFlowPosition(
      screenPosition: XYPosition(x: clientX, y: clientY),
      viewport: _controller.viewport,
      paneOrigin: rect == null
          ? const XYPosition(x: 0, y: 0)
          : XYPosition(
              x: rect.left.toDouble(),
              y: rect.top.toDouble(),
            ),
    );
  }

  XYPosition _toWorldFromLocal(XYPosition local) {
    return XYPosition(
      x: (local.x - _controller.viewport.x) / _controller.viewport.zoom,
      y: (local.y - _controller.viewport.y) / _controller.viewport.zoom,
    );
  }

  String _connectionPreviewPath() {
    final sourceNodeId = _interaction.connectionStartNodeId;
    final target = _interaction.connectionPreviewWorld;
    if (sourceNodeId == null || target == null) {
      return '';
    }

    final sourceNode = _instance.getNode(sourceNodeId);
    if (sourceNode == null) {
      return '';
    }

    final sourceMetrics = _instance.getHandleMetrics(
      sourceNode.id,
      HandleType.source,
      _interaction.connectionStartHandleId,
    );
    final sourceHandle = sourceMetrics?.handle;
    final source = sourceMetrics?.center ??
        getNodeConnectionPoint(
          sourceNode,
          sourceHandle?.position ?? sourceNode.sourcePosition,
          handle: sourceHandle,
        );
    return getBezierPath(
      sourceX: source.x,
      sourceY: source.y,
      sourcePosition: sourceHandle?.position ?? sourceNode.sourcePosition,
      targetX: target.x,
      targetY: target.y,
      targetPosition:
          (sourceHandle?.position ?? sourceNode.sourcePosition).opposite,
    ).path;
  }

  String _reconnectPreviewPath() {
    final edgeId = _interaction.reconnectEdgeId;
    final preview = _interaction.connectionPreviewWorld;
    if (edgeId == null || preview == null) {
      return '';
    }

    final edge = _instance.getEdge(edgeId);
    if (edge == null) {
      return '';
    }

    final position = getEdgePosition(edge, _visibleNodes);
    if (position == null) {
      return '';
    }

    final sourceX =
        _interaction.reconnectSourceHandle ? preview.x : position.sourceX;
    final sourceY =
        _interaction.reconnectSourceHandle ? preview.y : position.sourceY;
    final sourcePosition = _interaction.reconnectSourceHandle
        ? position.targetPosition.opposite
        : position.sourcePosition;
    final targetX =
        _interaction.reconnectSourceHandle ? position.targetX : preview.x;
    final targetY =
        _interaction.reconnectSourceHandle ? position.targetY : preview.y;
    final targetPosition = _interaction.reconnectSourceHandle
        ? position.targetPosition
        : position.sourcePosition.opposite;

    return getBezierPath(
      sourceX: sourceX,
      sourceY: sourceY,
      sourcePosition: sourcePosition,
      targetX: targetX,
      targetY: targetY,
      targetPosition: targetPosition,
    ).path;
  }

  void _finalizeReconnect(String targetNodeId, String? targetHandleId) {
    final edgeId = _interaction.reconnectEdgeId;
    if (edgeId == null) {
      return;
    }

    final edge =
        _visibleEdges.where((candidate) => candidate.id == edgeId).firstOrNull;
    if (edge == null) {
      return;
    }

    final connection = _interaction.completeReconnect(
      edge: edge,
      nodeId: targetNodeId,
      handleId: targetHandleId,
    );
    final endState = _interaction.lastReconnectEndState;
    _emitConnectEnd(endState);
    if (endState != null) {
      _emitReconnectEnd(edge, endState);
    }
    if (connection == null) {
      return;
    }

    _reconnectController.add(connection);
    _controller.reconnectEdge(edgeId,
        source: connection.source,
        target: connection.target,
        sourceHandle: connection.sourceHandle,
        targetHandle: connection.targetHandle);
    _edgesChangeController.add([
      FlowEdgeReplaceChange(
          item: edge.copyWith(
        source: connection.source,
        target: connection.target,
        sourceHandle: connection.sourceHandle,
        targetHandle: connection.targetHandle,
      )),
    ]);
  }

  FlowEdge? get _activeReconnectEdge {
    final edgeId = _interaction.reconnectEdgeId;
    if (edgeId == null) {
      return null;
    }

    return _visibleEdges.where((edge) => edge.id == edgeId).firstOrNull;
  }

  void _emitConnectStart() {
    _connectStartController.add(
      FlowConnectionStartEvent(
        nodeId: _interaction.connectionStartNodeId,
        handleId: _interaction.connectionStartHandleId,
        handleType: _interaction.handleState.fromType,
      ),
    );
  }

  void _emitConnectEnd(XYFinalConnectionState? state) {
    if (state == null) {
      return;
    }

    _connectEndController.add(state);
  }

  void _emitReconnectStart(FlowEdge edge) {
    final handleType = _interaction.handleState.fromType;
    if (handleType == null) {
      return;
    }

    _reconnectStartController.add(
      FlowReconnectStartEvent(
        edge: edge,
        handleType: handleType,
      ),
    );
  }

  void _emitReconnectEnd(FlowEdge edge, XYFinalConnectionState state) {
    final handleType = state.fromType;
    _reconnectEndController.add(
      FlowReconnectEndEvent(
        edge: edge,
        handleType: handleType,
        connectionState: state,
      ),
    );
  }

  void _addConnectedEdge(FlowConnection connection) {
    final nextEdges = addEdge(connection, _controller.edges);
    final addedEdge = nextEdges.isNotEmpty ? nextEdges.last : null;
    _controller.setEdges(nextEdges);
    if (addedEdge != null) {
      _edgesChangeController.add([FlowEdgeAddChange(item: addedEdge)]);
    }
  }
}
