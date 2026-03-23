import 'package:dart_flow/src/types/models.dart';
import 'package:dart_flow/src/utils/edge_paths.dart';
import 'package:test/test.dart';

void main() {
  group('edge paths', () {
    test('getNodeHandle resolves exact handle id', () {
      const node = FlowNode(
        id: 'node',
        position: XYPosition(x: 0, y: 0),
        handles: <FlowHandle>[
          FlowHandle(
              id: 'a', type: HandleType.source, position: Position.right),
          FlowHandle(
              id: 'b', type: HandleType.source, position: Position.bottom),
        ],
      );

      final handle = getNodeHandle(node, HandleType.source, 'b');

      expect(handle?.id, 'b');
      expect(handle?.position, Position.bottom);
    });

    test('getEdgePosition uses explicit handle coordinates', () {
      const source = FlowNode(
        id: 'source',
        position: XYPosition(x: 10, y: 20),
        handles: <FlowHandle>[
          FlowHandle(
            id: 'out',
            type: HandleType.source,
            position: Position.right,
            x: 90,
            y: 15,
            width: 20,
            height: 10,
          ),
        ],
      );
      const target = FlowNode(
        id: 'target',
        position: XYPosition(x: 300, y: 200),
        handles: <FlowHandle>[
          FlowHandle(
            id: 'in',
            type: HandleType.target,
            position: Position.left,
            x: 0,
            y: 25,
            width: 10,
            height: 20,
          ),
        ],
      );
      const edge = FlowEdge(
        id: 'edge',
        source: 'source',
        target: 'target',
        sourceHandle: 'out',
        targetHandle: 'in',
      );

      final position = getEdgePosition(edge, const <FlowNode>[source, target]);

      expect(position, isNotNull);
      expect(position!.sourceX, 110);
      expect(position.sourceY, 40);
      expect(position.targetX, 305);
      expect(position.targetY, 235);
    });

    test('getBezierPath returns path and label coordinates', () {
      final result = getBezierPath(
        sourceX: 0,
        sourceY: 0,
        targetX: 100,
        targetY: 80,
      );

      expect(result.path, startsWith('M0.0,0.0 C'));
      expect(result.labelX, greaterThan(0));
      expect(result.labelY, greaterThan(0));
    });
  });
}
