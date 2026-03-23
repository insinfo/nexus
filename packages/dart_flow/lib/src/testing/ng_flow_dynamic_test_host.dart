import 'package:ngdart/angular.dart';

import '../components/ng_flow/ng_flow_component.dart';
import '../state/flow_controller.dart';
import '../state/ng_flow_instance.dart';
import '../state/ng_flow_store.dart';
import '../types/models.dart';
import '../types/renderers.dart';

@Component(
  selector: 'test-dynamic-node',
  template: '<div class="test-dynamic-node">{{context.node.label}}</div>',
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class TestDynamicNodeComponent implements FlowDynamicNodeComponent {
  FlowNodeRenderContext _context = FlowNodeRenderContext(
    node: const FlowNode(id: 'placeholder', position: XYPosition(x: 0, y: 0)),
    instance: _PlaceholderInstance.instance,
    selected: false,
  );

  FlowNodeRenderContext get context => _context;

  @override
  @Input()
  set context(FlowNodeRenderContext value) {
    _context = value;
  }
}

@Component(
  selector: 'test-dynamic-edge',
  template: '<div class="test-dynamic-edge">{{context.edge.label}}</div>',
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class TestDynamicEdgeComponent implements FlowDynamicEdgeComponent {
  FlowEdgeRenderContext _context = FlowEdgeRenderContext(
    edge: const FlowEdge(id: 'edge', source: 'a', target: 'b', label: 'edge'),
    position: const EdgePosition(
      sourceX: 0,
      sourceY: 0,
      targetX: 0,
      targetY: 0,
      sourcePosition: Position.right,
      targetPosition: Position.left,
    ),
    path: const EdgePathResult(
      path: '',
      labelX: 0,
      labelY: 0,
      offsetX: 0,
      offsetY: 0,
    ),
    instance: _PlaceholderInstance.instance,
    selected: false,
  );

  FlowEdgeRenderContext get context => _context;

  @override
  @Input()
  set context(FlowEdgeRenderContext value) {
    _context = value;
  }
}

@Component(
  selector: 'ng-flow-dynamic-host',
  template: '''
    <div style="width: 900px; height: 700px;">
      <ng-flow
        [fitView]="false"
        [nodes]="nodes"
        [edges]="edges"
        [nodeComponentFactories]="nodeFactories"
        [edgeComponentFactories]="edgeFactories">
      </ng-flow>
    </div>
  ''',
  directives: [
    coreDirectives,
    NgFlowComponent,
  ],
)
class NgFlowDynamicHostComponent {
  @ViewChild(NgFlowComponent)
  NgFlowComponent? flow;

  final List<FlowNode> nodes = const <FlowNode>[
    FlowNode(
      id: 'a',
      position: XYPosition(x: 40, y: 40),
      type: 'dynamic-node',
      data: <String, Object?>{'label': 'Alpha'},
    ),
    FlowNode(
      id: 'b',
      position: XYPosition(x: 340, y: 180),
      data: <String, Object?>{'label': 'Beta'},
    ),
  ];

  final List<FlowEdge> edges = const <FlowEdge>[
    FlowEdge(
      id: 'e1',
      source: 'a',
      target: 'b',
      customType: 'dynamic-edge',
      label: 'relates',
    ),
  ];

  FlowNodeComponentFactoryMap nodeFactories =
      <String, ComponentFactory<Object>>{};
  FlowEdgeComponentFactoryMap edgeFactories =
      <String, ComponentFactory<Object>>{};
}

class _PlaceholderInstance {
  static final _controller = FlowController();
  static final _store = NgFlowStore(_controller);
  static final instance = NgFlowInstance(_controller, _store);
}
