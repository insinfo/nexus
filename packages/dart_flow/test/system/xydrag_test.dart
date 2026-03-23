import 'package:dart_flow/src/system/xydrag.dart';
import 'package:dart_flow/src/types/models.dart';
import 'package:test/test.dart';

void main() {
  group('xydrag', () {
    test('computeDraggedNodePosition snaps and clamps to extent', () {
      final result = computeDraggedNodePosition(
        startPosition: const XYPosition(x: 10, y: 10),
        startPointer: const XYPosition(x: 100, y: 100),
        currentPointer: const XYPosition(x: 173, y: 168),
        viewport: const Viewport(zoom: 1),
        nodeDimensions: const Dimensions(width: 80, height: 40),
        canvasWidth: 400,
        canvasHeight: 300,
        config: const XYDragConfig(
          snapToGrid: true,
          snapGrid: XYPosition(x: 20, y: 20),
          extent: Rect(x: 0, y: 0, width: 160, height: 140),
        ),
      );

      expect(result.position.x, 80);
      expect(result.position.y, 80);
      expect(result.viewportDelta.x, 0);
      expect(result.viewportDelta.y, 0);
    });

    test('computeDraggedNodePosition requests auto pan near borders', () {
      final result = computeDraggedNodePosition(
        startPosition: const XYPosition(x: 10, y: 10),
        startPointer: const XYPosition(x: 100, y: 100),
        currentPointer: const XYPosition(x: 395, y: 10),
        viewport: const Viewport(zoom: 1),
        nodeDimensions: const Dimensions(width: 80, height: 40),
        canvasWidth: 400,
        canvasHeight: 300,
        config: const XYDragConfig(
          autoPan: true,
          autoPanPadding: 24,
          autoPanStep: 18,
        ),
      );

      expect(result.viewportDelta.x, -18);
      expect(result.viewportDelta.y, 18);
    });

    test('selectionRectFromPoints normalizes coordinates', () {
      final rect = selectionRectFromPoints(
        const XYPosition(x: 120, y: 90),
        const XYPosition(x: 20, y: 10),
      );

      expect(rect.x, 20);
      expect(rect.y, 10);
      expect(rect.width, 100);
      expect(rect.height, 80);
    });

    test('selectNodesWithinRect returns intersecting nodes ids', () {
      final nodes = <FlowNode>[
        const FlowNode(id: 'a', position: XYPosition(x: 0, y: 0)),
        const FlowNode(id: 'b', position: XYPosition(x: 300, y: 0)),
        const FlowNode(id: 'c', position: XYPosition(x: 40, y: 40)),
      ];

      final ids = selectNodesWithinRect(
        nodes,
        const Rect(x: 10, y: 10, width: 200, height: 120),
      );

      expect(ids, {'a', 'c'});
    });
  });
}
