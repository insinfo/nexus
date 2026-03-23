import 'dart:async';

import 'package:dart_flow/src/state/flow_controller.dart';
import 'package:dart_flow/src/state/ng_flow_instance.dart';
import 'package:dart_flow/src/state/ng_flow_store.dart';
import 'package:dart_flow/src/types/models.dart';
import 'package:test/test.dart';

void main() {
  group('NgFlowStore', () {
    test('snapshot exposes lookups, visibility, selection and bounds', () {
      final controller = FlowController()
        ..setCanvasSize(640, 480)
        ..setNodes(const <FlowNode>[
          FlowNode(
            id: 'a',
            position: XYPosition(x: 0, y: 0),
            selected: true,
            handles: <FlowHandle>[
              FlowHandle(
                id: 'out',
                type: HandleType.source,
                position: Position.right,
              ),
            ],
          ),
          FlowNode(
            id: 'b',
            position: XYPosition(x: 300, y: 0),
            hidden: true,
          ),
        ])
        ..setEdges(const <FlowEdge>[
          FlowEdge(id: 'e1', source: 'a', target: 'b'),
        ]);

      final store = NgFlowStore(controller);
      final snapshot = store.snapshot;

      expect(snapshot.nodeLookup['a']?.id, 'a');
      expect(snapshot.edgeLookup['e1']?.id, 'e1');
      expect(snapshot.handleLookup['a:source:out']?.id, 'out');
      expect(snapshot.handleMetricsLookup['a:source:out']?.center.x, 180);
      expect(snapshot.nodeInternalsLookup['a'], isNotNull);
      expect(snapshot.visibleNodes.map((node) => node.id), ['a']);
      expect(snapshot.nodesInsideViewport.map((node) => node.id), ['a']);
      expect(snapshot.selectedNodeIds, {'a'});
      expect(snapshot.selectedNodes.map((node) => node.id), ['a']);
      expect(snapshot.hasSelection, isTrue);
      expect(snapshot.visibleBounds.x, 0);
      expect(snapshot.visibleBounds.width, 180);
      expect(snapshot.viewportRect.width, greaterThan(0));
    });

    test('selection streams emit changes from controller', () async {
      final controller = FlowController()
        ..setNodes(const <FlowNode>[
          FlowNode(id: 'a', position: XYPosition(x: 0, y: 0)),
          FlowNode(id: 'b', position: XYPosition(x: 200, y: 0)),
        ]);
      final store = NgFlowStore(controller);

      final selectedNodeIds = <Set<String>>[];
      final hasSelectionValues = <bool>[];
      final selectedNodes = <List<FlowNode>>[];
      final nodeSub = store.selectedNodeIdsChanges.listen(selectedNodeIds.add);
      final selectionSub =
          store.hasSelectionChanges.listen(hasSelectionValues.add);
      final selectedNodesSub =
          store.selectedNodesChanges.listen(selectedNodes.add);

      controller.selectNode('b');
      await Future<void>.delayed(Duration.zero);

      expect(selectedNodeIds.last, {'b'});
      expect(hasSelectionValues.last, isTrue);
      expect(selectedNodes.last.single.id, 'b');

      await nodeSub.cancel();
      await selectionSub.cancel();
      await selectedNodesSub.cancel();
    });

    test('instance proxies store helpers', () {
      final controller = FlowController()
        ..setNodes(const <FlowNode>[
          FlowNode(id: 'a', position: XYPosition(x: 0, y: 0), selected: true),
        ]);
      final store = NgFlowStore(controller);
      final instance = NgFlowInstance(controller, store);

      expect(instance.getNode('a')?.id, 'a');
      expect(instance.getHandle('a', HandleType.source), isNotNull);
      expect(instance.nodesInsideViewport.single.id, 'a');
      expect(instance.visibleNodes.single.id, 'a');
      expect(instance.hasSelection, isTrue);
      expect(instance.selectedNodes.single.id, 'a');
    });

    test('getHandle resolves by node id, type and handle id', () {
      final controller = FlowController()
        ..setNodes(const <FlowNode>[
          FlowNode(
            id: 'a',
            position: XYPosition(x: 0, y: 0),
            handles: <FlowHandle>[
              FlowHandle(
                id: 'out',
                type: HandleType.source,
                position: Position.right,
              ),
              FlowHandle(
                id: 'in',
                type: HandleType.target,
                position: Position.left,
              ),
            ],
          ),
        ]);
      final store = NgFlowStore(controller);

      expect(store.getHandle('a', HandleType.source, 'out')?.id, 'out');
      expect(store.getHandle('a', HandleType.target, 'in')?.id, 'in');
      expect(
          store.getHandleMetrics('a', HandleType.source, 'out')?.center.x, 180);
      expect(store.getNodeInternals('a')?.sourceHandles, hasLength(1));
    });
  });
}
