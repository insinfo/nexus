import 'package:dart_flow/src/state/ng_flow_interaction_controller.dart';
import 'package:dart_flow/src/system/xydrag.dart';
import 'package:dart_flow/src/types/models.dart';
import 'package:test/test.dart';

void main() {
  group('NgFlowInteractionController', () {
    test('tracks node drag lifecycle', () {
      final controller = NgFlowInteractionController();

      controller.startNodeDrag(
        nodeId: 'a',
        pointer: const XYPosition(x: 100, y: 120),
        startPosition: const XYPosition(x: 10, y: 20),
        viewport: const Viewport(),
      );

      final drag = controller.computeNodeDrag(
        pointer: const XYPosition(x: 132, y: 148),
        dimensions: const <String, Dimensions>{
          'a': Dimensions(width: 180, height: 56),
        },
        canvasWidth: 800,
        canvasHeight: 600,
        config: const XYDragConfig(),
      );

      expect(controller.dragNodeId, 'a');
      expect(drag.positions['a']?.x, 42);
      expect(drag.positions['a']?.y, 48);

      controller.stopNodeDrag();
      expect(controller.dragNodeId, isNull);
    });

    test('tracks multi-drag lifecycle preserving relative offsets', () {
      final controller = NgFlowInteractionController();

      controller.startNodeDrag(
        nodeId: 'a',
        pointer: const XYPosition(x: 100, y: 100),
        startPosition: const XYPosition(x: 10, y: 20),
        viewport: const Viewport(),
        startPositions: const <String, XYPosition>{
          'a': XYPosition(x: 10, y: 20),
          'b': XYPosition(x: 110, y: 70),
        },
      );

      final drag = controller.computeNodeDrag(
        pointer: const XYPosition(x: 140, y: 130),
        dimensions: const <String, Dimensions>{
          'a': Dimensions(width: 180, height: 56),
          'b': Dimensions(width: 180, height: 56),
        },
        canvasWidth: 800,
        canvasHeight: 600,
        config: const XYDragConfig(),
      );

      expect(drag.positions['a'], isNotNull);
      expect(drag.positions['b'], isNotNull);
      expect(drag.positions['a']?.x, 50);
      expect(drag.positions['a']?.y, 50);
      expect(drag.positions['b']?.x, 150);
      expect(drag.positions['b']?.y, 100);
    });

    test('tracks pan lifecycle', () {
      final controller = NgFlowInteractionController();
      controller.startPan(
        pointer: const XYPosition(x: 200, y: 100),
        viewport: const Viewport(x: 10, y: 20, zoom: 1.5),
        mouseButton: 2,
      );

      final viewport = controller.computePan(
        pointer: const XYPosition(x: 240, y: 160),
        viewport: const Viewport(x: 10, y: 20, zoom: 1.5),
      );

      expect(controller.isPanning, isTrue);
      expect(controller.panZoomState.isZoomingOrPanning, isTrue);
      expect(controller.panZoomState.usedRightMouseButton, isTrue);
      expect(viewport.x, 50);
      expect(viewport.y, 80);

      controller.stopPan();
      expect(controller.isPanning, isFalse);
      expect(controller.panZoomState.isZoomingOrPanning, isFalse);
    });

    test('tracks selection lifecycle', () {
      final controller = NgFlowInteractionController();
      final nodes = const <FlowNode>[
        FlowNode(id: 'a', position: XYPosition(x: 0, y: 0)),
        FlowNode(id: 'b', position: XYPosition(x: 300, y: 0)),
      ];

      controller.startSelection(const XYPosition(x: 0, y: 0));
      controller.updateSelection(const XYPosition(x: 260, y: 120));

      final selected = controller.finalizeSelection(nodes, (point) => point);

      expect(selected, {'a'});
      expect(controller.isSelecting, isFalse);
      expect(controller.selectionStartLocal, isNull);
    });

    test('tracks connection and reconnect lifecycle', () {
      final controller = NgFlowInteractionController();
      final connectStarted = controller.startConnection(
        nodeId: 'a',
        handleType: HandleType.source,
        handleId: 'out',
        pointer: const XYPosition(x: 10, y: 10),
        dragThreshold: 0,
      );
      expect(connectStarted, isTrue);
      controller.previewConnectionTarget(
        pointer: const XYPosition(x: 40, y: 40),
        nodeId: 'b',
        handleId: 'in',
        handleType: HandleType.target,
      );

      final connection = controller.completeConnection(
        nodeId: 'b',
        handleId: 'in',
        handleType: HandleType.target,
      );

      expect(connection, isNotNull);
      expect(connection!.source, 'a');
      expect(connection.target, 'b');
      expect(controller.lastConnectionEndState?.isValid, isTrue);
      expect(controller.lastConnectionEndState?.connection?.target, 'b');
      expect(controller.connectionStartNodeId, isNull);

      final reconnectStarted = controller.startReconnect(
        edge: const FlowEdge(
          id: 'e1',
          source: 'a',
          target: 'b',
          sourceHandle: 'old-out',
          targetHandle: 'old-in',
        ),
        sourceHandle: true,
        pointer: const XYPosition(x: 0, y: 0),
        dragThreshold: 0,
      );
      expect(reconnectStarted, isTrue);

      final reconnect = controller.completeReconnect(
        edge: const FlowEdge(
          id: 'e1',
          source: 'a',
          target: 'b',
          sourceHandle: 'old-out',
          targetHandle: 'old-in',
        ),
        nodeId: 'c',
        handleId: 'new-out',
      );

      expect(reconnect, isNotNull);
      expect(reconnect!.source, 'c');
      expect(reconnect.target, 'b');
      expect(controller.lastReconnectEndState?.fromNodeId, 'b');
      expect(controller.lastReconnectEndState?.fromType, HandleType.target);
      expect(controller.lastReconnectEndState?.connection?.source, 'c');
      expect(controller.reconnectEdgeId, isNull);
    });

    test('records terminal state when connection is cancelled', () {
      final controller = NgFlowInteractionController();

      final started = controller.startConnection(
        nodeId: 'a',
        handleType: HandleType.source,
        handleId: 'out',
        pointer: const XYPosition(x: 10, y: 10),
        dragThreshold: 0,
      );
      expect(started, isTrue);
      controller.updateConnection(const XYPosition(x: 25, y: 30));

      final endState = controller.cancelConnection();

      expect(endState, isNotNull);
      expect(endState?.fromNodeId, 'a');
      expect(endState?.fromHandleId, 'out');
      expect(endState?.pointer.x, 25);
      expect(endState?.pointer.y, 30);
      expect(endState?.connection, isNull);
      expect(controller.connectionStartNodeId, isNull);
      expect(controller.lastConnectionEndState?.pointer.x, 25);
    });

    test('records terminal state when reconnect is cancelled', () {
      final controller = NgFlowInteractionController();

      final started = controller.startReconnect(
        edge: const FlowEdge(
          id: 'e1',
          source: 'a',
          target: 'b',
          sourceHandle: 'old-out',
          targetHandle: 'old-in',
        ),
        sourceHandle: false,
        pointer: const XYPosition(x: 5, y: 6),
        dragThreshold: 0,
      );
      expect(started, isTrue);
      controller.updateReconnect(const XYPosition(x: 15, y: 16));

      final endState = controller.cancelReconnect();

      expect(endState, isNotNull);
      expect(endState?.fromNodeId, 'a');
      expect(endState?.fromHandleId, 'old-out');
      expect(endState?.fromType, HandleType.source);
      expect(endState?.startPointer.x, 5);
      expect(endState?.pointer.x, 15);
      expect(endState?.isValid, isFalse);
      expect(endState?.connection, isNull);
      expect(controller.reconnectEdgeId, isNull);
      expect(controller.lastReconnectEndState?.pointer.y, 16);
    });

    test('clearPointerModes resets transient state', () {
      final controller = NgFlowInteractionController();
      controller.startSelection(const XYPosition(x: 1, y: 1));
      controller.startConnection(
        nodeId: 'a',
        handleType: HandleType.source,
        pointer: const XYPosition(x: 1, y: 1),
        dragThreshold: 0,
      );
      controller.startResize(
        nodeId: 'a',
        pointer: const XYPosition(x: 2, y: 2),
        width: 100,
        height: 50,
      );
      controller.startPan(
        pointer: const XYPosition(x: 0, y: 0),
        viewport: const Viewport(),
      );

      controller.clearPointerModes();

      expect(controller.connectionStartNodeId, isNull);
      expect(controller.resizeNodeId, isNull);
      expect(controller.isSelecting, isFalse);
      expect(controller.isPanning, isFalse);
    });

    test('does not activate drag connection before threshold is exceeded', () {
      final controller = NgFlowInteractionController();

      final started = controller.startConnection(
        nodeId: 'a',
        handleType: HandleType.source,
        handleId: 'out',
        pointer: const XYPosition(x: 10, y: 10),
        dragThreshold: 8,
      );
      expect(started, isFalse);
      final stillPending =
          controller.updateConnection(const XYPosition(x: 14, y: 14));

      expect(stillPending, isFalse);

      expect(controller.activeConnectionKind, isNull);
      expect(controller.hasPendingConnectionGesture, isTrue);
      expect(controller.hasConnectionPreview, isFalse);

      final activated =
          controller.updateConnection(const XYPosition(x: 20, y: 20));

      expect(activated, isTrue);

      expect(
          controller.activeConnectionKind, XYConnectionLifecycleKind.connect);
      expect(controller.hasPendingConnectionGesture, isFalse);
      expect(controller.hasConnectionPreview, isTrue);
      expect(controller.connectionStartNodeId, 'a');
    });

    test('does not activate reconnect before threshold is exceeded', () {
      final controller = NgFlowInteractionController();

      final started = controller.startReconnect(
        edge: const FlowEdge(
          id: 'e1',
          source: 'a',
          target: 'b',
          sourceHandle: 'old-out',
          targetHandle: 'old-in',
        ),
        sourceHandle: true,
        pointer: const XYPosition(x: 5, y: 5),
        dragThreshold: 10,
      );
      expect(started, isFalse);
      final stillPending =
          controller.updateReconnect(const XYPosition(x: 10, y: 10));

      expect(stillPending, isFalse);

      expect(controller.activeConnectionKind, isNull);
      expect(controller.hasPendingReconnectGesture, isTrue);
      expect(controller.hasReconnectPreview, isFalse);

      final activated =
          controller.updateReconnect(const XYPosition(x: 20, y: 20));

      expect(activated, isTrue);

      expect(
        controller.activeConnectionKind,
        XYConnectionLifecycleKind.reconnect,
      );
      expect(controller.hasPendingReconnectGesture, isFalse);
      expect(controller.hasReconnectPreview, isTrue);
      expect(controller.reconnectEdgeId, 'e1');
    });
  });
}
