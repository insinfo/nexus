import 'package:dart_flow/dart_flow.dart';
import 'package:dart_flow_example/src/components/demo_approval_node/demo_approval_node_component.template.dart'
    as demo_approval_ng;
import 'package:dart_flow_example/src/components/demo_highlight_edge/demo_highlight_edge_component.template.dart'
    as demo_edge_ng;
import 'package:ngdart/angular.dart';

@Component(
  selector: 'app-root',
  templateUrl: 'app_component.html',
  styleUrls: ['app_component.css'],
  directives: [
    coreDirectives,
    NgFlowComponent,
    BackgroundComponent,
    ControlsComponent,
    MiniMapComponent,
    PanelComponent,
  ],
)
class AppComponent {
  final List<String> eventLog = <String>[];

  late final FlowNodeComponentFactoryMap nodeComponentFactories =
      <String, ComponentFactory<Object>>{
    'approval': demo_approval_ng.DemoApprovalNodeComponentNgFactory,
  };

  late final FlowEdgeComponentFactoryMap edgeComponentFactories =
      <String, ComponentFactory<Object>>{
    'highlight': demo_edge_ng.DemoHighlightEdgeComponentNgFactory,
  };

  late final Map<String, EdgePathRenderer> edgeTypePathBuilders =
      <String, EdgePathRenderer>{
    'highlight': (FlowEdge edge, EdgePosition position) => getBezierPath(
          sourceX: position.sourceX,
          sourceY: position.sourceY,
          sourcePosition: position.sourcePosition,
          targetX: position.targetX,
          targetY: position.targetY,
          targetPosition: position.targetPosition,
          curvature: 0.42,
        ),
  };

  List<FlowNode> nodes = const <FlowNode>[
    FlowNode(
      id: '1',
      type: 'input',
      position: XYPosition(x: 40, y: 100),
      data: <String, Object?>{'label': 'Entrada'},
      sourcePosition: Position.right,
      targetPosition: Position.left,
      handles: <FlowHandle>[
        FlowHandle(
          id: 'out-main',
          type: HandleType.source,
          position: Position.right,
          x: 180,
          y: 20,
        ),
        FlowHandle(
          id: 'out-alt',
          type: HandleType.source,
          position: Position.right,
          x: 180,
          y: 40,
        ),
      ],
    ),
    FlowNode(
      id: '2',
      type: 'approval',
      position: XYPosition(x: 340, y: 80),
      data: <String, Object?>{'label': 'Validacao'},
      sourcePosition: Position.right,
      targetPosition: Position.left,
      handles: <FlowHandle>[
        FlowHandle(
          id: 'in',
          type: HandleType.target,
          position: Position.left,
          x: 0,
          y: 28,
        ),
        FlowHandle(
          id: 'approved',
          type: HandleType.source,
          position: Position.right,
          x: 180,
          y: 18,
        ),
        FlowHandle(
          id: 'rejected',
          type: HandleType.source,
          position: Position.right,
          x: 180,
          y: 40,
        ),
      ],
    ),
    FlowNode(
      id: '3',
      type: 'default',
      position: XYPosition(x: 340, y: 230),
      data: <String, Object?>{'label': 'Enriquecimento'},
      sourcePosition: Position.right,
      targetPosition: Position.left,
      handles: <FlowHandle>[
        FlowHandle(
          id: 'in',
          type: HandleType.target,
          position: Position.left,
          x: 0,
          y: 28,
        ),
        FlowHandle(
          id: 'out',
          type: HandleType.source,
          position: Position.right,
          x: 180,
          y: 28,
        ),
      ],
    ),
    FlowNode(
      id: '4',
      type: 'output',
      position: XYPosition(x: 670, y: 155),
      data: <String, Object?>{'label': 'Saida'},
      sourcePosition: Position.right,
      targetPosition: Position.left,
      handles: <FlowHandle>[
        FlowHandle(
          id: 'approved-in',
          type: HandleType.target,
          position: Position.left,
          x: 0,
          y: 18,
        ),
        FlowHandle(
          id: 'merged-in',
          type: HandleType.target,
          position: Position.left,
          x: 0,
          y: 40,
        ),
      ],
    ),
  ];

  List<FlowEdge> edges = const <FlowEdge>[
    FlowEdge(
      id: 'e1-2',
      source: '1',
      target: '2',
      sourceHandle: 'out-main',
      targetHandle: 'in',
      label: 'sync',
    ),
    FlowEdge(
      id: 'e1-3',
      source: '1',
      target: '3',
      sourceHandle: 'out-alt',
      targetHandle: 'in',
      type: ConnectionLineType.smoothStep,
      label: 'fan-out',
    ),
    FlowEdge(
      id: 'e2-4',
      source: '2',
      target: '4',
      sourceHandle: 'approved',
      targetHandle: 'approved-in',
      type: ConnectionLineType.bezier,
      customType: 'highlight',
      animated: true,
      label: 'merge A',
    ),
    FlowEdge(
      id: 'e3-4',
      source: '3',
      target: '4',
      sourceHandle: 'out',
      targetHandle: 'merged-in',
      type: ConnectionLineType.straight,
      label: 'merge B',
    ),
  ];

  int _counter = 5;

  void onConnect(FlowConnection connection) {
    eventLog.insert(0, 'connect ${connection.source} -> ${connection.target}');
    if (eventLog.length > 8) {
      eventLog.removeLast();
    }
  }

  void onReconnect(FlowConnection connection) {
    eventLog.insert(
        0, 'reconnect ${connection.source} -> ${connection.target}');
    if (eventLog.length > 8) {
      eventLog.removeLast();
    }
  }

  void onSelectionChange(Set<String> ids) {
    eventLog.insert(0, 'selection ${ids.join(', ')}');
    if (eventLog.length > 8) {
      eventLog.removeLast();
    }
  }

  void addNode() {
    final id = '${_counter++}';
    nodes = List<FlowNode>.from(nodes)
      ..add(
        FlowNode(
          id: id,
          type: nodes.length.isEven ? 'approval' : 'default',
          position: XYPosition(x: 160 + (nodes.length * 60), y: 320),
          data: <String, Object?>{'label': 'No $id'},
          handles: <FlowHandle>[
            FlowHandle(
              id: 'in',
              type: HandleType.target,
              position: Position.left,
              x: 0,
              y: 28,
            ),
            FlowHandle(
              id: 'out',
              type: HandleType.source,
              position: Position.right,
              x: 180,
              y: 28,
            ),
          ],
        ),
      );

    edges = addEdge(
      FlowConnection(
        source: '4',
        target: id,
        sourceHandle: null,
        targetHandle: 'in',
      ),
      edges,
      id: 'e4-$id',
      type: ConnectionLineType.simpleBezier,
    );
  }

  void resetGraph() {
    _counter = 5;
    nodes = const <FlowNode>[
      FlowNode(
        id: '1',
        type: 'input',
        position: XYPosition(x: 40, y: 100),
        data: <String, Object?>{'label': 'Entrada'},
        handles: <FlowHandle>[
          FlowHandle(
            id: 'out-main',
            type: HandleType.source,
            position: Position.right,
            x: 180,
            y: 20,
          ),
          FlowHandle(
            id: 'out-alt',
            type: HandleType.source,
            position: Position.right,
            x: 180,
            y: 40,
          ),
        ],
      ),
      FlowNode(
        id: '2',
        type: 'approval',
        position: XYPosition(x: 340, y: 80),
        data: <String, Object?>{'label': 'Validacao'},
        handles: <FlowHandle>[
          FlowHandle(
            id: 'in',
            type: HandleType.target,
            position: Position.left,
            x: 0,
            y: 28,
          ),
          FlowHandle(
            id: 'approved',
            type: HandleType.source,
            position: Position.right,
            x: 180,
            y: 18,
          ),
          FlowHandle(
            id: 'rejected',
            type: HandleType.source,
            position: Position.right,
            x: 180,
            y: 40,
          ),
        ],
      ),
      FlowNode(
        id: '3',
        type: 'default',
        position: XYPosition(x: 340, y: 230),
        data: <String, Object?>{'label': 'Enriquecimento'},
        handles: <FlowHandle>[
          FlowHandle(
            id: 'in',
            type: HandleType.target,
            position: Position.left,
            x: 0,
            y: 28,
          ),
          FlowHandle(
            id: 'out',
            type: HandleType.source,
            position: Position.right,
            x: 180,
            y: 28,
          ),
        ],
      ),
      FlowNode(
        id: '4',
        type: 'output',
        position: XYPosition(x: 670, y: 155),
        data: <String, Object?>{'label': 'Saida'},
        handles: <FlowHandle>[
          FlowHandle(
            id: 'approved-in',
            type: HandleType.target,
            position: Position.left,
            x: 0,
            y: 18,
          ),
          FlowHandle(
            id: 'merged-in',
            type: HandleType.target,
            position: Position.left,
            x: 0,
            y: 40,
          ),
        ],
      ),
    ];

    edges = const <FlowEdge>[
      FlowEdge(
        id: 'e1-2',
        source: '1',
        target: '2',
        sourceHandle: 'out-main',
        targetHandle: 'in',
        label: 'sync',
      ),
      FlowEdge(
        id: 'e1-3',
        source: '1',
        target: '3',
        sourceHandle: 'out-alt',
        targetHandle: 'in',
        type: ConnectionLineType.smoothStep,
        label: 'fan-out',
      ),
      FlowEdge(
        id: 'e2-4',
        source: '2',
        target: '4',
        sourceHandle: 'approved',
        targetHandle: 'approved-in',
        customType: 'highlight',
        animated: true,
        label: 'merge A',
      ),
      FlowEdge(
        id: 'e3-4',
        source: '3',
        target: '4',
        sourceHandle: 'out',
        targetHandle: 'merged-in',
        type: ConnectionLineType.straight,
        label: 'merge B',
      ),
    ];

    eventLog.clear();
  }
}
