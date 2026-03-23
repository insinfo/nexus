import 'models.dart';

abstract class FlowNodeChange {
  const FlowNodeChange(this.id, this.type);

  final String id;
  final String type;
}

class FlowNodePositionChange extends FlowNodeChange {
  const FlowNodePositionChange({required String id, required this.position})
      : super(id, 'position');

  final XYPosition position;
}

class FlowNodeSelectionChange extends FlowNodeChange {
  const FlowNodeSelectionChange({required String id, required this.selected})
      : super(id, 'select');

  final bool selected;
}

class FlowNodeRemoveChange extends FlowNodeChange {
  const FlowNodeRemoveChange({required String id}) : super(id, 'remove');
}

class FlowNodeAddChange extends FlowNodeChange {
  FlowNodeAddChange({required this.item}) : super(item.id, 'add');

  final FlowNode item;
}

class FlowNodeReplaceChange extends FlowNodeChange {
  FlowNodeReplaceChange({required this.item}) : super(item.id, 'replace');

  final FlowNode item;
}

abstract class FlowEdgeChange {
  const FlowEdgeChange(this.id, this.type);

  final String id;
  final String type;
}

class FlowEdgeSelectionChange extends FlowEdgeChange {
  const FlowEdgeSelectionChange({required String id, required this.selected})
      : super(id, 'select');

  final bool selected;
}

class FlowEdgeRemoveChange extends FlowEdgeChange {
  const FlowEdgeRemoveChange({required String id}) : super(id, 'remove');
}

class FlowEdgeAddChange extends FlowEdgeChange {
  FlowEdgeAddChange({required this.item}) : super(item.id, 'add');

  final FlowEdge item;
}

class FlowEdgeReplaceChange extends FlowEdgeChange {
  FlowEdgeReplaceChange({required this.item}) : super(item.id, 'replace');

  final FlowEdge item;
}
