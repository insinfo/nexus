import 'package:ngdart/angular.dart';

import '../components/ng_flow/ng_flow_component.dart';
import '../system/xyhandle.dart';
import '../types/models.dart';

@Component(
  selector: 'ng-flow-keyboard-host',
  template: '''
    <div style="width: 900px; height: 700px;">
      <ng-flow
        [fitView]="false"
        [nodes]="nodes"
        [edges]="edges"
        (connectStart)="onConnectStart(\$event)"
        (connectEnd)="onConnectEnd(\$event)"
        (connect)="onConnect(\$event)"
        (reconnectStart)="onReconnectStart(\$event)"
        (reconnectEnd)="onReconnectEnd(\$event)"
        (reconnect)="onReconnect(\$event)">
      </ng-flow>
    </div>
  ''',
  directives: [
    coreDirectives,
    NgFlowComponent,
  ],
)
class NgFlowKeyboardHostComponent {
  @ViewChild(NgFlowComponent)
  NgFlowComponent? flow;

  final List<FlowConnection> connectEvents = <FlowConnection>[];
  final List<FlowConnection> reconnectEvents = <FlowConnection>[];
  final List<FlowConnectionStartEvent> connectStartEvents =
      <FlowConnectionStartEvent>[];
  final List<XYFinalConnectionState> connectEndEvents =
      <XYFinalConnectionState>[];
  final List<FlowReconnectStartEvent> reconnectStartEvents =
      <FlowReconnectStartEvent>[];
  final List<FlowReconnectEndEvent> reconnectEndEvents =
      <FlowReconnectEndEvent>[];

  final List<FlowNode> nodes = const <FlowNode>[
    FlowNode(id: 'a', position: XYPosition(x: 0, y: 0)),
    FlowNode(id: 'b', position: XYPosition(x: 240, y: 120)),
  ];

  final List<FlowEdge> edges = const <FlowEdge>[
    FlowEdge(id: 'e1', source: 'a', target: 'b'),
  ];

  void onConnect(FlowConnection connection) {
    connectEvents.add(connection);
  }

  void onConnectStart(FlowConnectionStartEvent event) {
    connectStartEvents.add(event);
  }

  void onConnectEnd(XYFinalConnectionState event) {
    connectEndEvents.add(event);
  }

  void onReconnect(FlowConnection connection) {
    reconnectEvents.add(connection);
  }

  void onReconnectStart(FlowReconnectStartEvent event) {
    reconnectStartEvents.add(event);
  }

  void onReconnectEnd(FlowReconnectEndEvent event) {
    reconnectEndEvents.add(event);
  }
}
