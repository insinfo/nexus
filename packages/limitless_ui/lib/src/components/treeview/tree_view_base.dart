import 'package:collection/collection.dart';
import 'package:essential_core/essential_core.dart';

class TreeViewNode {
  //late int id;
  String treeViewNodeLabel;

  int treeViewNodeLevel;
  bool treeViewNodeFilter;
  TreeViewNode? parent;
  bool treeViewNodeIsCollapse;
  bool treeViewNodeIsSelected;
  dynamic value;

  /// Children
  final List<TreeViewNode> _children = <TreeViewNode>[];

  void addChild(TreeViewNode child) {
    child.parent = this;
    _children.add(child);
  }

  /// não adicione filhos diretamente a treeViewNodes adicione usando o addChild
  List<TreeViewNode> get treeViewNodes => _children;

  TreeViewNode({
    required this.treeViewNodeLabel,
    required this.treeViewNodeLevel,
    this.treeViewNodeFilter = true,
    this.treeViewNodeIsCollapse = true,
    this.treeViewNodeIsSelected = false,
    this.value,
  }) {
    //id = 1;
  }

  /// verifica se tem filhos
  bool hasChilds() {
    return treeViewNodes.isNotEmpty;
  }

  /// se todos os filhos estão selecionados
  bool get isAllChildrenSelected {
    var filhos = getAllDescendants().toList();
    // var isSelected = filhos.where((el) => el.treeViewNodeIsSelected).toList();
    // return filhos.length == isSelected.length;
    for (var filho in filhos) {
      if (filho.treeViewNodeIsSelected == false) {
        return false;
      }
    }
    return true;
  }

  /// retorna todos os nodes filhos ou seja transforma a arvore em uma lista
  Iterable<TreeViewNode> getAllDescendants(
      [Iterable<TreeViewNode>? rootNodesP]) sync* {
    var rootNode = this;
    var rootNodes = rootNodesP ?? [rootNode];
    final descendants =
        rootNodes.expand((node) => getAllDescendants(node.treeViewNodes));
    yield* rootNodes.followedBy(descendants);
  }

  /// retorna o primeiro filho que corresponde ao childSelector
  TreeViewNode? getChild(bool Function(TreeViewNode) childSelector) {
    final allNodes = getAllDescendants();
    final parentsOfSelectedChildren =
        allNodes.where((node) => node.treeViewNodes.any(childSelector));
    return parentsOfSelectedChildren.isNotEmpty
        ? parentsOfSelectedChildren.first
        : null;
  }

  List<TreeViewNode> getParents() {
    var resuts = <TreeViewNode>[];
    var parent = this.parent;
    while (parent != null) {
      resuts.add(parent);
      parent = parent.parent;
    }
    return resuts;
  }

  bool finded(String searchQuery, TreeViewNode item) {
    final itemTitle =
        EssentialCoreUtils.removerAcentos(item.treeViewNodeLabel).toLowerCase();
    return itemTitle.contains(searchQuery);
  }

  @override
  bool operator ==(covariant TreeViewNode other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.treeViewNodeLabel == treeViewNodeLabel &&
        listEquals(other.treeViewNodes, treeViewNodes) &&
        other.treeViewNodeLevel == treeViewNodeLevel &&
        other.treeViewNodeFilter == treeViewNodeFilter &&
        other.treeViewNodeIsCollapse == treeViewNodeIsCollapse &&
        other.treeViewNodeIsSelected == treeViewNodeIsSelected &&
        other.value == value;
  }

  @override
  int get hashCode {
    return treeViewNodeLabel.hashCode ^
        treeViewNodes.hashCode ^
        treeViewNodeLevel.hashCode ^
        treeViewNodeFilter.hashCode ^
        treeViewNodeIsCollapse.hashCode ^
        treeViewNodeIsSelected.hashCode ^
        value.hashCode;
  }
}
