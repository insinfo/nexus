import 'package:dart_flow/src/system/node_internals.dart';
import 'package:dart_flow/src/types/models.dart';
import 'package:test/test.dart';

void main() {
  group('node internals', () {
    test('buildNodeInternals creates fallback handles when absent', () {
      const node = FlowNode(
        id: 'a',
        position: XYPosition(x: 20, y: 30),
        sourcePosition: Position.right,
        targetPosition: Position.left,
      );

      final internals = buildNodeInternals(node);

      expect(internals.sourceHandles, hasLength(1));
      expect(internals.targetHandles, hasLength(1));
      expect(internals.sourceHandles.single.center.x, 200);
      expect(internals.targetHandles.single.center.x, 20);
    });

    test('buildNodeInternals keeps explicit handle coordinates', () {
      const node = FlowNode(
        id: 'a',
        position: XYPosition(x: 20, y: 30),
        handles: <FlowHandle>[
          FlowHandle(
            id: 'out',
            type: HandleType.source,
            position: Position.right,
            x: 90,
            y: 10,
            width: 20,
            height: 20,
          ),
        ],
      );

      final internals = buildNodeInternals(node);
      final handle = internals.getHandle(HandleType.source, 'out');

      expect(handle, isNotNull);
      expect(handle!.center.x, 120);
      expect(handle.center.y, 50);
      expect(handle.bounds.width, 20);
    });

    test('getNodesInsideViewport filters by current viewport window', () {
      final nodes = <FlowNode>[
        const FlowNode(id: 'a', position: XYPosition(x: 0, y: 0)),
        const FlowNode(id: 'b', position: XYPosition(x: 700, y: 500)),
        const FlowNode(id: 'c', position: XYPosition(x: 1200, y: 900)),
      ];

      final visible = getNodesInsideViewport(
        nodes,
        viewport: const Viewport(x: 0, y: 0, zoom: 1),
        canvasWidth: 900,
        canvasHeight: 700,
      );

      expect(visible.map((node) => node.id), ['a', 'b']);
    });
  });
}
