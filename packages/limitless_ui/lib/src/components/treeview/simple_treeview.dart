import 'dart:async';

import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';

import 'tree_view_base.dart';

import 'dart:html' as html;

@Component(
  selector: 'simple-treeview',
  styleUrls: ['simple_treeview.css'],
  templateUrl: 'simple_treeview.html',
  directives: [
    coreDirectives,
    // NgTemplateOutlet,
  ],
)
class SimpleTreeViewComponent {
  @ViewChild('treeContainer')
  html.DivElement? treeContainer;

  @Input('searchPlaceholder')
  String searchPlaceholder = 'Digite e pressione enter para buscar';

  @Input('data')
  List<TreeViewNode> list = <TreeViewNode>[];

  @Input('isMultiSelectable')
  bool isMultiSelectable = false;

  @Input('isDisableEnter')
  bool isDisableEnter = false;

  TreeViewNode? itemSelected;

  void searchKeydownEnter(inputsearch) {
    search(inputsearch.value);
  }

  void search(String value) {
    search2(value, list);
  }

  void search2(String searchQueryRaw, List<TreeViewNode> jsonTree,
      [TreeViewNode? parent]) {
    final searchQuery =
        EssentialCoreUtils.removerAcentos(searchQueryRaw).toLowerCase();

    for (var i = 0; i < jsonTree.length; i++) {
      final menuItem = jsonTree[i];

      menuItem.parent = parent;

      if (searchQuery.isNotEmpty) {
        menuItem.treeViewNodeFilter = false;
      } else {
        menuItem.treeViewNodeFilter = true;
      }

      if (menuItem.hasChilds()) {
        search2(searchQuery, menuItem.treeViewNodes, menuItem);
      } else {
        // volta do extremo para o topo da árvore
        var itemEndPoint = menuItem;

        while (itemEndPoint.parent != null) {
          if (!itemEndPoint.treeViewNodeFilter) {
            if (itemEndPoint.finded(searchQuery, itemEndPoint)) {
              itemEndPoint.treeViewNodeFilter = true;
              itemEndPoint.parent?.treeViewNodeFilter = true;
              itemEndPoint.parent?.treeViewNodeIsCollapse = false;
            }
          } else {
            itemEndPoint.parent?.treeViewNodeFilter = true;
            itemEndPoint.parent?.treeViewNodeIsCollapse = false;
          }

          itemEndPoint = itemEndPoint.parent!;
        }

        if (itemEndPoint.parent == null && !itemEndPoint.treeViewNodeFilter) {
          if (itemEndPoint.finded(searchQuery, itemEndPoint)) {
            itemEndPoint.treeViewNodeFilter = true;
            itemEndPoint.parent?.treeViewNodeIsCollapse = false;
          }
        }
      }
    }

    if (searchQuery.isEmpty) {
      closeAllTree(jsonTree);
    }
  }

  void closeAllTree(List<TreeViewNode> jsonTree) {
    for (final element in jsonTree) {
      element.treeViewNodeIsCollapse = true;
      closeAllTree(element.treeViewNodes);
    }
  }

  void unselectAllTreeModel(List<TreeViewNode> jsonTree) {
    for (final node in jsonTree) {
      node.treeViewNodeIsSelected = false;
      unselectAllTreeModel(node.treeViewNodes);
    }
  }

  void selectAllTreeModel(List<TreeViewNode> tree) {
    for (final node in tree) {
      node.treeViewNodeIsSelected = true;
      if (node.treeViewNodeLevel < 1) {
        node.treeViewNodeIsCollapse = false;
      }
      selectAllTreeModel(node.treeViewNodes);
    }
  }

  ///define all node of tree as treeViewNodeIsCollapse = false
  void expandAllTreeModel(List<TreeViewNode> tree) {
    for (var node in tree) {
      node.treeViewNodeIsCollapse = false;
      if (node.treeViewNodes.isNotEmpty) {
        expandAllTreeModel(node.treeViewNodes);
      }
    }
  }

  ///define all node of tree as treeViewNodeIsCollapse = true
  void collapseAllTreeModel(List<TreeViewNode> tree) {
    for (var node in tree) {
      node.treeViewNodeIsCollapse = true;
      if (node.treeViewNodes.isNotEmpty) {
        expandAllTreeModel(node.treeViewNodes);
      }
    }
  }

  bool isSelectAll = false;
  void selectAllToogleAction() {
    if (isSelectAll) {
      isSelectAll = false;
      unselectAllAction();
    } else {
      isSelectAll = true;
      selectAllAction();
    }
  }

  void selectAllAction() {
    selectAllTreeModel(list);
  }

  void unselectAllAction() {
    unselectAllTreeModel(list);
  }

  bool isExpandAll = false;

  void expandAllToogleAction() {
    if (isExpandAll) {
      isExpandAll = false;
      collapseAllTreeModel(list);
    } else {
      isExpandAll = true;
      expandAllTreeModel(list);
    }
  }

  /// retorna a propriedade value de cada node selecionado da arvore ignorando os value null
  /// [onlyNoChild] se true retorna apenas os selecionados que não tem filhos
  List<T> getAllSelected<T>({bool onlyNoChild = true}) {
    return _getAllSelectedRecursive(list, onlyNoChild: onlyNoChild);
  }

  /// retorna os itens selcionados da arvore recursivamente
  /// [onlyNoChild] se true retorna apenas os selecionados que não tem filhos
  List<T> _getAllSelectedRecursive<T>(List<TreeViewNode> tree,
      {bool onlyNoChild = true}) {
    final result = <T>[];
    for (final node in tree) {
      if (node.treeViewNodeIsSelected) {
        if (onlyNoChild) {
          if (!node.hasChilds() && node.value != null) {
            result.add(node.value as T);
          }
        } else {
          if (node.value != null) {
            result.add(node.value as T);
          }
        }
      }
      if (node.treeViewNodes.isNotEmpty) {
        result.addAll(_getAllSelectedRecursive(node.treeViewNodes));
      }
    }
    return result;
  }

  StreamController<List<dynamic>> onSelectStreamController =
      StreamController<List<dynamic>>();

  @Output('onSelect')
  Stream get onSelect => onSelectStreamController.stream;

  void selectItem(TreeViewNode node) {
    node.treeViewNodeIsSelected = !node.treeViewNodeIsSelected;
    if (node.treeViewNodeIsSelected) {
      itemSelected = node;
    }

    // verifica se é um pai de varios filhos ou um filho
    final isPai = node.hasChilds();
    if (isPai) {
      for (final el in node.getAllDescendants()) {
        el.treeViewNodeIsSelected = node.treeViewNodeIsSelected;
      }
    }

    // pega os pais para selecionalos quando o filho é selecionado
    final parents = node.getParents();
    for (final parent in parents) {
      //pega o primeiro filho que esta selecionado
      final childSelected = parent.getChild((n) => n.treeViewNodeIsSelected);
      if (node.treeViewNodeIsSelected) {
        if (childSelected != null) {
          parent.treeViewNodeIsSelected = true;
        }
      } else {
        if (childSelected == null) {
          parent.treeViewNodeIsSelected = false;
        }
      }
    }

    // n.treeViewNodeIsSelected = node.treeViewNodeIsSelected == true ? true : false;
    //onSelectStreamController.add(getAllSelected());
  }
}
