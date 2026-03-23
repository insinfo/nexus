import 'package:dart_flow/src/types/models.dart';
import 'package:dart_flow/src/utils/graph.dart';
import 'package:test/test.dart';

void main() {
  group('graph utils', () {
    test('getNodesBounds ignores hidden nodes', () {
      final bounds = getNodesBounds(const <FlowNode>[
        FlowNode(id: 'a', position: XYPosition(x: 10, y: 20)),
        FlowNode(
          id: 'hidden',
          position: XYPosition(x: 1000, y: 1000),
          hidden: true,
        ),
      ]);

      expect(bounds.x, 10);
      expect(bounds.y, 20);
      expect(bounds.width, 180);
      expect(bounds.height, 56);
    });

    test('addEdge preserves source and target handles', () {
      final edges = addEdge(
        const FlowConnection(
          source: 'source',
          target: 'target',
          sourceHandle: 'out-1',
          targetHandle: 'in-1',
        ),
        const <FlowEdge>[],
        id: 'e1',
      );

      expect(edges.single.id, 'e1');
      expect(edges.single.sourceHandle, 'out-1');
      expect(edges.single.targetHandle, 'in-1');
    });

    test('reconnectEdge updates endpoints and handles', () {
      const edge = FlowEdge(
        id: 'e1',
        source: 'a',
        target: 'b',
        sourceHandle: 'old-source',
        targetHandle: 'old-target',
      );

      final updated = reconnectEdge(
        edge,
        const FlowConnection(
          source: 'x',
          target: 'y',
          sourceHandle: 'new-source',
          targetHandle: 'new-target',
        ),
        const <FlowEdge>[edge],
      );

      expect(updated.single.source, 'x');
      expect(updated.single.target, 'y');
      expect(updated.single.sourceHandle, 'new-source');
      expect(updated.single.targetHandle, 'new-target');
    });
  });
}
