import 'package:ngdart/angular.dart';

import '../state/ng_flow_instance.dart';
import 'models.dart';

class FlowNodeRenderContext {
  const FlowNodeRenderContext({
    required this.node,
    required this.instance,
    required this.selected,
  });

  final FlowNode node;
  final NgFlowInstance instance;
  final bool selected;
}

abstract class FlowDynamicNodeComponent {
  set context(FlowNodeRenderContext value);
}

class FlowEdgeRenderContext {
  const FlowEdgeRenderContext({
    required this.edge,
    required this.position,
    required this.path,
    required this.instance,
    required this.selected,
  });

  final FlowEdge edge;
  final EdgePosition position;
  final EdgePathResult path;
  final NgFlowInstance instance;
  final bool selected;
}

abstract class FlowDynamicEdgeComponent {
  set context(FlowEdgeRenderContext value);
}

typedef FlowNodeComponentFactoryMap = Map<String, ComponentFactory<Object>>;
typedef FlowEdgeComponentFactoryMap = Map<String, ComponentFactory<Object>>;
