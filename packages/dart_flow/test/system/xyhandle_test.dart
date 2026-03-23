import 'package:dart_flow/src/system/xyhandle.dart';
import 'package:dart_flow/src/types/models.dart';
import 'package:test/test.dart';

void main() {
  group('xyhandle', () {
    test('starts and updates a connection gesture', () {
      final started = startHandleConnection(
        nodeId: 'a',
        handleType: HandleType.source,
        handleId: 'out',
        pointer: const XYPosition(x: 10, y: 20),
      );
      final updated = updateHandleConnection(
        started,
        pointer: const XYPosition(x: 30, y: 40),
      );

      expect(started.inProgress, isTrue);
      expect(updated.pointer?.x, 30);
      expect(updated.pointer?.y, 40);
    });

    test('completes a valid source to target connection', () {
      final state = startHandleConnection(
        nodeId: 'a',
        handleType: HandleType.source,
        handleId: 'out',
        pointer: const XYPosition(x: 0, y: 0),
      );

      final connection = completeHandleConnection(
        state: state,
        targetNodeId: 'b',
        targetHandleId: 'in',
        targetType: HandleType.target,
      );

      expect(connection, isNotNull);
      expect(connection!.source, 'a');
      expect(connection.target, 'b');
      expect(connection.sourceHandle, 'out');
      expect(connection.targetHandle, 'in');
    });

    test('rejects same-node and same-type connections', () {
      final state = startHandleConnection(
        nodeId: 'a',
        handleType: HandleType.source,
        handleId: 'out',
        pointer: const XYPosition(x: 0, y: 0),
      );

      expect(
        completeHandleConnection(
          state: state,
          targetNodeId: 'a',
          targetHandleId: 'in',
          targetType: HandleType.target,
        ),
        isNull,
      );

      expect(
        completeHandleConnection(
          state: state,
          targetNodeId: 'b',
          targetHandleId: 'out-2',
          targetType: HandleType.source,
        ),
        isNull,
      );
    });

    test('supports loose mode plus custom validation callback', () {
      final state = startHandleConnection(
        nodeId: 'a',
        handleType: HandleType.source,
        handleId: 'out',
        pointer: const XYPosition(x: 0, y: 0),
      );

      final accepted = completeHandleConnection(
        state: state,
        targetNodeId: 'a',
        targetHandleId: 'in',
        targetType: HandleType.source,
        connectionMode: XYConnectionMode.loose,
        validator: (connection) => connection.targetHandle == 'in',
      );

      final rejected = completeHandleConnection(
        state: state,
        targetNodeId: 'b',
        targetHandleId: 'blocked',
        targetType: HandleType.target,
        validator: (connection) => connection.targetHandle != 'blocked',
      );

      expect(accepted, isNotNull);
      expect(accepted!.source, 'a');
      expect(accepted.target, 'a');
      expect(rejected, isNull);
    });

    test('reconnectHandleConnection preserves opposite endpoint', () {
      const edge = FlowEdge(
        id: 'e1',
        source: 'a',
        target: 'b',
        sourceHandle: 's1',
        targetHandle: 't1',
      );

      final connection = reconnectHandleConnection(
        edge: edge,
        reconnectSourceHandle: true,
        targetNodeId: 'c',
        targetHandleId: 's2',
      );

      expect(connection.source, 'c');
      expect(connection.target, 'b');
      expect(connection.sourceHandle, 's2');
      expect(connection.targetHandle, 't1');
    });
  });
}
