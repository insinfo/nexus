import 'package:dart_flow/src/system/xypanzoom.dart';
import 'package:dart_flow/src/types/models.dart';
import 'package:test/test.dart';

void main() {
  group('xypanzoom', () {
    test('screenToFlowPosition and flowToScreenPosition are inverse', () {
      const viewport = Viewport(x: 50, y: 20, zoom: 2);
      const paneOrigin = XYPosition(x: 10, y: 15);
      const screen = XYPosition(x: 210, y: 155);

      final flow = screenToFlowPosition(
        screenPosition: screen,
        viewport: viewport,
        paneOrigin: paneOrigin,
      );
      final roundTrip = flowToScreenPosition(
        flowPosition: flow,
        viewport: viewport,
        paneOrigin: paneOrigin,
      );

      expect(roundTrip.x, closeTo(screen.x, 0.001));
      expect(roundTrip.y, closeTo(screen.y, 0.001));
    });

    test('zoomViewportAroundPoint keeps anchor world point stable', () {
      const viewport = Viewport(x: 100, y: 60, zoom: 1);
      const anchor = XYPosition(x: 320, y: 180);

      final before = screenToFlowPosition(
        screenPosition: anchor,
        viewport: viewport,
      );

      final zoomed = zoomViewportAroundPoint(
        viewport: viewport,
        zoom: 1.5,
        anchor: anchor,
      );

      final after = screenToFlowPosition(
        screenPosition: anchor,
        viewport: zoomed,
      );

      expect(after.x, closeTo(before.x, 0.001));
      expect(after.y, closeTo(before.y, 0.001));
      expect(zoomed.zoom, 1.5);
    });

    test('viewportRectInFlow converts canvas size into world rect', () {
      const viewport = Viewport(x: -200, y: -100, zoom: 2);

      final rect = viewportRectInFlow(
        viewport: viewport,
        canvasWidth: 800,
        canvasHeight: 600,
      );

      expect(rect.x, 100);
      expect(rect.y, 50);
      expect(rect.width, 400);
      expect(rect.height, 300);
    });

    test('constrainViewport clamps translation and zoom to extents', () {
      const viewport = Viewport(x: 100, y: -500, zoom: 8);
      const viewportExtent = Rect(x: 0, y: 0, width: 400, height: 300);
      const translateExtent = Rect(x: -200, y: -150, width: 800, height: 600);

      final constrained = constrainViewport(
        viewport: viewport,
        viewportExtent: viewportExtent,
        translateExtent: translateExtent,
        minZoom: 0.5,
        maxZoom: 2.0,
      );

      expect(constrained.zoom, 2.0);
      expect(constrained.x, inInclusiveRange(-400, -200));
      expect(constrained.y, inInclusiveRange(-300, -150));
    });

    test('scaleViewportBy scales around anchor', () {
      const viewport = Viewport(x: 100, y: 40, zoom: 1);
      const anchor = XYPosition(x: 200, y: 120);
      final before = screenToFlowPosition(
        screenPosition: anchor,
        viewport: viewport,
      );

      final scaled = scaleViewportBy(
        viewport: viewport,
        factor: 1.5,
        anchor: anchor,
      );

      final after = screenToFlowPosition(
        screenPosition: anchor,
        viewport: scaled,
      );

      expect(after.x, closeTo(before.x, 0.001));
      expect(after.y, closeTo(before.y, 0.001));
      expect(viewportEquals(scaled, viewport), isFalse);
    });

    test('pan gesture tracks transient interaction state', () {
      const viewport = Viewport(x: 10, y: 20, zoom: 1.25);
      const pointer = XYPosition(x: 100, y: 120);

      final started = startPanGesture(
        viewport: viewport,
        pointer: pointer,
        mouseButton: 2,
        usedRightMouseButton: true,
      );
      final updated = updatePanGesture(
        started,
        pointer: const XYPosition(x: 140, y: 180),
        viewport: const Viewport(x: 50, y: 80, zoom: 1.25),
      );
      final ended = endPanGesture(updated);

      expect(started.isZoomingOrPanning, isTrue);
      expect(started.usedRightMouseButton, isTrue);
      expect(started.mouseButton, 2);
      expect(started.previousViewport, viewport);
      expect(updated.viewport.x, 50);
      expect(updated.lastPointer?.y, 180);
      expect(ended.isDragging, isFalse);
      expect(ended.isZoomingOrPanning, isFalse);
    });

    test('syncPanZoomState keeps previous viewport when syncing', () {
      const initial = XYPanZoomState(
        viewport: Viewport(x: 0, y: 0, zoom: 1),
        isDragging: false,
      );

      final synced = syncPanZoomState(
        initial,
        const Viewport(x: 20, y: 30, zoom: 1.5),
      );

      expect(synced.previousViewport.x, 0);
      expect(synced.viewport.x, 20);
      expect(synced.viewport.zoom, 1.5);
    });
  });
}
