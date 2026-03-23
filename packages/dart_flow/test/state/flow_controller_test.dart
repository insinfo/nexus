import 'package:dart_flow/src/state/flow_controller.dart';
import 'package:dart_flow/src/system/xypanzoom.dart';
import 'package:dart_flow/src/types/models.dart';
import 'package:test/test.dart';

void main() {
  group('FlowController', () {
    test('zoomTo preserves anchored world point', () {
      final controller = FlowController();
      controller.setViewport(const Viewport(x: 100, y: 50, zoom: 1));

      final before = screenToFlowPosition(
        screenPosition: const XYPosition(x: 320, y: 210),
        viewport: controller.viewport,
      );

      controller.zoomTo(1.5, anchorX: 320, anchorY: 210);

      final after = screenToFlowPosition(
        screenPosition: const XYPosition(x: 320, y: 210),
        viewport: controller.viewport,
      );

      expect(after.x, closeTo(before.x, 0.001));
      expect(after.y, closeTo(before.y, 0.001));
    });

    test('fitView centers visible nodes and ignores hidden ones', () {
      final controller = FlowController()
        ..setCanvasSize(800, 600)
        ..setNodes(const <FlowNode>[
          FlowNode(id: 'a', position: XYPosition(x: 0, y: 0)),
          FlowNode(id: 'b', position: XYPosition(x: 400, y: 200)),
          FlowNode(
            id: 'hidden',
            position: XYPosition(x: 4000, y: 4000),
            hidden: true,
          ),
        ]);

      controller.fitView();

      expect(
          controller.viewport.zoom, inInclusiveRange(0.2, controller.maxZoom));
      expect(controller.graphBounds.x2, lessThan(700));
      expect(controller.graphBounds.y2, lessThan(400));
    });

    test('setViewportConstrained and syncViewport respect translate extent',
        () {
      final controller = FlowController()
        ..setCanvasSize(400, 300)
        ..setTranslateExtent(
          const Rect(x: -200, y: -150, width: 800, height: 600),
        );

      controller.setViewportConstrained(
        const Viewport(x: 100, y: 80, zoom: 8),
      );

      expect(controller.viewport.zoom, 2.0);
      expect(controller.viewport.x, inInclusiveRange(-400, -200));
      expect(controller.viewport.y, inInclusiveRange(-300, -150));

      final firstViewport = controller.viewport;
      controller.syncViewport(const Viewport(x: 999, y: -999, zoom: 0.1));

      expect(controller.viewport.zoom, 0.2);
      expect(viewportEquals(firstViewport, controller.viewport), isFalse);
    });
  });
}
