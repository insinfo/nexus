import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;

import 'package:ngdart/angular.dart';

import '../../state/flow_controller.dart';
import '../../types/models.dart';
import '../../utils/graph.dart';

@Component(
  selector: 'rf-minimap',
  directives: [coreDirectives],
  templateUrl: 'minimap_component.html',
  styleUrls: ['minimap_component.css'],
)
class MiniMapComponent implements OnInit, OnDestroy {
  MiniMapComponent(this._controller, this._changeDetectorRef);

  final FlowController _controller;
  final ChangeDetectorRef _changeDetectorRef;

  StreamSubscription<int>? _subscription;
  StreamSubscription<html.MouseEvent>? _moveSubscription;
  StreamSubscription<html.MouseEvent>? _upSubscription;
  html.Element? _host;
  bool _isDragging = false;

  List<FlowNode> nodes = const <FlowNode>[];
  Rect _bounds = const Rect(x: 0, y: 0, width: 1, height: 1);
  double _scaleX = 220;
  double _scaleY = 140;

  String get viewBox => '0 0 220 140';

  String nodeX(FlowNode node) => '${(node.position.x - _bounds.x) * _scaleX}';
  String nodeY(FlowNode node) => '${(node.position.y - _bounds.y) * _scaleY}';
  String nodeWidth(FlowNode node) => '${node.width * _scaleX}';
  String nodeHeight(FlowNode node) => '${node.height * _scaleY}';

  double get _viewportRectX =>
      (-_controller.viewport.x / _controller.viewport.zoom - _bounds.x) *
      _scaleX;
  double get _viewportRectY =>
      (-_controller.viewport.y / _controller.viewport.zoom - _bounds.y) *
      _scaleY;
  double get _viewportRectWidth =>
      (_controller.canvasWidth / _controller.viewport.zoom) * _scaleX;
  double get _viewportRectHeight =>
      (_controller.canvasHeight / _controller.viewport.zoom) * _scaleY;

  String get viewportRectX => '$_viewportRectX';
  String get viewportRectY => '$_viewportRectY';
  String get viewportRectWidth => '$_viewportRectWidth';
  String get viewportRectHeight => '$_viewportRectHeight';

  Object? trackByNodeId(int index, dynamic node) => (node as FlowNode).id;

  @ViewChild('minimapHost')
  set minimapHost(html.Element? value) {
    _host = value;
  }

  @override
  void ngOnInit() {
    _syncSnapshot();
    _subscription = _controller.changes.listen((_) {
      _syncSnapshot();
      _changeDetectorRef.markForCheck();
    });
  }

  @override
  void ngOnDestroy() {
    _subscription?.cancel();
    _moveSubscription?.cancel();
    _upSubscription?.cancel();
  }

  void _syncSnapshot() {
    nodes =
        _controller.nodes.where((node) => !node.hidden).toList(growable: false);
    _bounds = getNodesBounds(nodes).inflate(40);
    _scaleX = 220 / math.max(1, _bounds.width);
    _scaleY = 140 / math.max(1, _bounds.height);
  }

  void onClick(html.MouseEvent event) {
    _moveViewportTo(event);
  }

  void onMouseDown(html.MouseEvent event) {
    event.preventDefault();
    _isDragging = true;
    _moveViewportTo(event);
    _moveSubscription ??= html.document.onMouseMove.listen((nextEvent) {
      if (_isDragging) {
        _moveViewportTo(nextEvent);
      }
    });
    _upSubscription ??= html.document.onMouseUp.listen((_) {
      _isDragging = false;
      _moveSubscription?.cancel();
      _upSubscription?.cancel();
      _moveSubscription = null;
      _upSubscription = null;
    });
  }

  void _moveViewportTo(html.MouseEvent event) {
    final host = _host;
    if (host == null) {
      return;
    }

    final rect = host.getBoundingClientRect();
    final localX = (event.client.x - rect.left).toDouble();
    final localY = (event.client.y - rect.top).toDouble();
    final worldX = _bounds.x + (localX / _scaleX);
    final worldY = _bounds.y + (localY / _scaleY);
    final nextX =
        _controller.canvasWidth / 2 - (worldX * _controller.viewport.zoom);
    final nextY =
        _controller.canvasHeight / 2 - (worldY * _controller.viewport.zoom);
    _controller.setViewport(
      Viewport(x: nextX, y: nextY, zoom: _controller.viewport.zoom),
    );
  }
}
