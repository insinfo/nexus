//datatable_component.dart
// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:html';
import 'dart:js_util' as js_util;

import 'package:essential_core/essential_core.dart';
import 'package:intl/intl.dart';
import 'package:ngdart/angular.dart';

import '../../directives/dropdown_menu_directive.dart';
import '../../directives/form_directives.dart';
import '../../directives/safe_append_html_directive.dart';
import '../../directives/safe_inner_html_directive.dart';
import '../loading/loading.dart';
import 'datatable_col.dart';
import 'datatable_row.dart';
import 'datatable_settings.dart';
import 'pagination_item.dart';

extension CssStyleDeclarationExtension on CssStyleDeclaration {
  /// rowGap
  String get gridRowGap {
    final result = js_util.getProperty(this, 'gridRowGap');
    return result.toString();
  }
}

class DatatableSearchField {
  bool selected = false;
  final String label;
  final String field;
  final String operator;

  DatatableSearchField({
    this.selected = false,
    required this.label,
    required this.field,
    required this.operator,
  });
  void select() {
    selected = true;
  }
}

/// Example:
/// ```html
/// <datatable-component [dataTableFilter]="filtros" [data]="pessoas" [settings]="datatableSettings" [searchInFields]="searchInFields"
///   (dataRequest)="onRequestData($event)"></datatable-component>
/// ```
///
/// `DataFrame<CgmFull> pessoas = DataFrame(items: [], totalRecords: 0);`
///
/// DatatableSettings datatableSettings = DatatableSettings(colsDefinitions: [
///   DatatableCol(key: 'nom_cgm', title: 'Nome'),
///   DatatableCol(key: 'numcgm', title: 'Código'),
///   DatatableCol(key: 'documento', title: 'Documento', visibility: false),
///   DatatableCol(key: 'nom_fantasia', title: 'Nome Fantasia', visibility: false),
/// ]);
///
/// `List<DatatableSearchField> searchInFields = <DatatableSearchField>[`
///   DatatableSearchField(field: 'nom_cgm', operator: 'like', label: 'Nome'),
///   DatatableSearchField(field: 'sw_cgm.numcgm', operator: '=', label: 'CGM'),
///   DatatableSearchField(field: 'cpf', operator: 'like', label: 'CPF'),
///   DatatableSearchField(field: 'cnpj', operator: 'like', label: 'CNPJ'),
///   DatatableSearchField(
///       field: 'nom_fantasia', operator: 'like', label: 'Nome Fantasia'),
/// `];`
///
/// Filters filtros = Filters(limit: 12, offset: 0);
///
/// `Future<void> load() async {`
///   try {
///     _simpleLoading.show(target: containerElement);
///     pessoas = await _cgmService.all(filtros);
///   } catch (e, s) {
///     print('ConsultarCgmPage@load $e $s');
///   } finally {
///     _simpleLoading.hide();
///   }
/// `}`
///
///
/// void onRequestData(Filters dtf) {
///   load();
/// }
@Component(
    selector: 'datatable-component',
    styleUrls: ['datatable_component.css', 'grid.css'],
    templateUrl: 'datatable_component.html',
    directives: [
      coreDirectives,
      limitlessFormDirectives,
      DropdownMenuDirective,
      SafeInnerHtmlDirective,
      SafeAppendHtmlDirective,
    ],
    //changeDetection: ChangeDetectionStrategy.OnPush,
    exports: [DatatableRowType])
class DatatableComponent implements AfterChanges, AfterViewInit, OnDestroy {
  @Input()
  Filters dataTableFilter = Filters();

  final Element rootElement;
  DatatableComponent(this.rootElement);

  InputElement? get inputSearchElement =>
      rootElement.querySelector('.data-table-search-field') as InputElement?;

  void setInputSearchFocus() {
    inputSearchElement?.focus();
  }

  @ViewChild('card')
  DivElement? card;

  @ViewChild('table')
  HtmlElement? table;

  final SimpleLoading _loading = SimpleLoading();

  void showLoading() {
    _loading.show(target: card);
  }

  void hideLoading() {
    _loading.hide();
  }

  int get getCurrentTotalItems {
    return dataTableFilter.offset! + dataTableFilter.limit!;
  }

  List<DatatableSearchField> _searchInFields = [];

  @Input('searchInFields')
  set searchInFields(List<DatatableSearchField> pFieldsS) {
    var v = pFieldsS;
    if (!(v.where((e) => e.selected == true).isNotEmpty == true)) {
      v.first.select();
    }
    var selectedSearchField = v.where((e) => e.selected == true).first;

    dataTableFilter.searchInFields = [
      FilterSearchField(
        active: true,
        field: selectedSearchField.field,
        operator: selectedSearchField.operator,
        label: selectedSearchField.label,
      )
    ];

    _searchInFields = v;
  }

  List<DatatableSearchField> get searchInFields => _searchInFields;

  @Input('limitPerPageOptions')
  List<int> limitPerPageOptions = [1, 5, 10, 12, 20, 24, 25];

  DatatableSettings _settings = DatatableSettings(colsDefinitions: []);

  @Input('settings')
  set settings(DatatableSettings d) {
    _settings = d;
  }

  DatatableSettings get settings {
    return _settings;
  }

  List<DatatableRow> rows = [];

  DataFrame _data = DataFrame(items: [], totalRecords: 0);

  @Input('data')
  set data(DataFrame d) {
    _data = d;
    totalRecords = _data.totalRecords;
    draw();
  }

  @Input()
  bool nullIsEmpty = true;

  @Input('gridMode')
  bool gridMode = false;

  /// remove one element of DatatableComponent and return index of this element
  int removeItem(dynamic element) {
    var idx = _data.removeItem(element);
    rows.remove(rows[idx]);
    return idx;
  }

  void update() {
    draw();
  }

  void draw() {
    //print('draw');
    rows.clear();

    if (settings.colsDefinitions.isEmpty == true) {
      print(
          'DataTable settings is null. Define settings like: <datatable-component [settings]="datatableSettings"');
      return;
    }

    String? anterior;
    for (var i = 0; i < _data.itemsAsMap.length; i++) {
      final itemMap = _data.itemsAsMap[i];
      final itemInstance = _data[i];
      final row = DatatableRow(index: i, instance: itemInstance, columns: []);

      for (var j = 0; j < _settings.colsDefinitions.length; j++) {
        final colDefinition = _settings.colsDefinitions[j];
        dynamic value;
        // pega o valor de forma recursiva caso haja um separador
        if (colDefinition.key.contains('||')) {
          var keys =
              colDefinition.key.split('||').map((k) => k.trim()).toList();
          value = keys
              .map((key) => itemMap[key])
              .join(colDefinition.multiValSeparator);
        } else {
          if (colDefinition.key.contains('.')) {
            var keys = colDefinition.key.split('.');
            value = getValRecursive(itemMap, keys);
          } else {
            value = itemMap[colDefinition.key];
          }
        }
        if (colDefinition.customRenderString != null) {
          value = colDefinition.customRenderString!(itemMap, itemInstance);
        } else if (colDefinition.format != null) {
          switch (colDefinition.format) {
            case DatatableFormat.boolHighlightedBadge:
              if (value is bool) {
                value =
                    value ? '<span class="badge bg-primary">Sim</span>' : 'Não';
              }
              break;
            case DatatableFormat.bool:
              if (value is bool) {
                value = value ? 'Sim' : 'Não';
              }
              break;
            case DatatableFormat.date:
              if (value != null) {
                value = value is DateTime
                    ? value
                    : DateTime.tryParse(value!.toString());
                final formatter = DateFormat('dd/MM/yyyy');
                value = value is DateTime ? formatter.format(value) : null;
              }
              break;
            case DatatableFormat.dateTime:
              if (value != null) {
                value = value is DateTime
                    ? value
                    : DateTime.tryParse(value!.toString());
                final formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
                value = value is DateTime ? formatter.format(value) : null;
              }
              break;
            case DatatableFormat.dateTimeShort:
              if (value != null) {
                value = value is DateTime
                    ? value
                    : DateTime.tryParse(value!.toString());
                final formatter = DateFormat('dd/MM/yyyy HH:mm');
                value = value is DateTime ? formatter.format(value) : null;
              }
              break;
            case DatatableFormat.text:
              value = value?.toString();
              break;
            case null:
              value = '';
              break;
          }
        }
        if (nullIsEmpty == true) {
          value = value == null ? '' : value.toString();
        }

        Element? htmlElement;
        if (colDefinition.customRenderHtml != null) {
          htmlElement = colDefinition.customRenderHtml!(itemMap, itemInstance);
          value = '';
        }

        final column = DatatableCol(
          value: value,
          key: colDefinition.key,
          title: colDefinition.title,
          visibility: colDefinition.visibility,
          htmlElement: htmlElement,
          enableGrouping: colDefinition.enableGrouping,
          groupByKey: colDefinition.groupByKey,
          visibilityOnCard: colDefinition.visibilityOnCard,
          showTitleOnCard: colDefinition.showTitleOnCard,
          showAsFooterOnCard: colDefinition.showAsFooterOnCard,
        );

        row.addColumn(column);
      }
      // implementação do agrupamento
      if (settings.enableGrouping) {
        var groupingColumns = row.columns
            .where((el) => el.enableGrouping && el.groupByKey != null);

        var groupBys = groupingColumns.map((e) => e.groupByKey!).toList();

        if (groupBys.isNotEmpty) {
          var atual = _data.itemsAsMap[i].entries
              .where((map) => groupBys.contains(map.key))
              .map((m) => m.value)
              .join('.');
          if ((i - 1) >= 0) {
            anterior = _data.itemsAsMap[i - 1].entries
                .where((map) => groupBys.contains(map.key))
                .map((m) => m.value)
                .join('.');
          }

          //print(' separador $atual | $anterior');
          if (atual != anterior) {
            var divTitle = DivElement();
            divTitle.text =
                groupingColumns.map((e) => e.value).join('      /     ');
            rows.add(DatatableRow(type: DatatableRowType.groupTitle, columns: [
              DatatableCol(
                type: DatatableColType.groupTitle,
                htmlElement: divTitle,
                key: '',
                title: '',
                visibility: true,
                colspan: row.columns.length,
                styleCss: 'text-align: center;',
              )
            ]));
            rows.add(row);
          } else {
            if (_settings.rowStyleResolver != null) {
              try {
                row.styleCss =
                    _settings.rowStyleResolver!(itemMap, itemInstance);
              } catch (e) {
                // evita quebrar a tabela caso algo dê errado
                print('rowStyleResolver error: $e');
              }
            }
            rows.add(row);
          }
        }
      } else {
        if (_settings.rowStyleResolver != null) {
          try {
            row.styleCss = _settings.rowStyleResolver!(itemMap, itemInstance);
          } catch (e) {
            // evita quebrar a tabela caso algo dê errado
            print('rowStyleResolver error: $e');
          }
        }
        rows.add(row);
      }
    }
  }

  void gridMasonry(String selector) {
    var gridItems = document.querySelectorAll(selector);

    if (gridItems.isNotEmpty &&
        gridItems[0].getComputedStyle().gridTemplateRows != 'masonry') {
      var grids = gridItems.map((grid) {
        var items = grid.childNodes
            .where((child) {
              return child.nodeType == Node.ELEMENT_NODE &&
                  double.tryParse((child as Element)
                          .getComputedStyle()
                          .gridColumnEnd) !=
                      -1;
            })
            .map((e) => e as Element)
            .toList();

        var rowGap =
            double.parse(grid.getComputedStyle().gap.replaceFirst('px', ''));

        return {
          '_el': grid,
          'gap': rowGap,
          'items': items,
          'ncol': 0,
        };
      }).toList();

      for (final grid in grids) {
        // get the post relayout number of columns
        int ncol = (grid['_el'] as Element)
            .getComputedStyle()
            .gridTemplateColumns
            .split(' ')
            .length;

        // if the number of columns has changed
        if (grid['ncol'] != ncol) {
          // update number of columns
          grid['ncol'] = ncol;

          // revert to initial positioning, no margin
          for (final column in (grid['items'] as List<Element>)) {
            column.style.removeProperty('margin-top');
          }

          // if we have more than one column
          if ((grid['ncol'] as int) > 1) {
            var items = (grid['items'] as List<Element>);
            var sublist = items.sublist(ncol);
            for (var i = 0; i < sublist.length; i++) {
              var c = sublist[i];
              // bottom edge of item above | borda inferior do item acima
              var prevFin = items[i].getBoundingClientRect().bottom;
              // top edge of current item
              var currIni = c.getBoundingClientRect().top;

              var marginTop =
                  '${prevFin + (grid['gap'] as double) - currIni}px';

              c.style.marginTop = marginTop;
            }
          }
        }
      }
    }
  }

  dynamic getValRecursive(Map<String, dynamic> itemMap, List<String> keys) {
    var k = keys[0];
    if (keys.length > 1) {
      keys.remove(k);
      var map = itemMap[k];
      if (map is Map<String, dynamic>) {
        return getValRecursive(map, keys);
      } else {
        return map;
      }
    } else {
      return itemMap[k];
    }
  }

  DataFrame get data {
    return _data;
  }

  @Input('searchLabel')
  String searchLabel = 'Busca';

  @Input('searchPlaceholder')
  String searchPlaceholder = 'Digite para buscar';

  @Input()
  String totalRecordsLabel = 'Total:';

// -------------------------------- pagination --------------------------------
  int totalRecords = 0;
  int _currentPage = 1;

  int get getCurrentPage => _currentPage;

  final int _btnQuantity = 5;
  PaginationType paginationType = PaginationType.carousel;
  List<PaginationItem> paginationItems = <PaginationItem>[];

  @override
  void ngAfterViewInit() {
    drawPagination();
    _syncSortingIndicators();
    //print('DatatableComponent@ngAfterViewInit');
  }

  /// muda de modo lista ou grade
  void changeViewMode() {
    gridMode = !gridMode;
    // if (gridMode) {
    //   Future.delayed(Duration(milliseconds: 200), () {
    //     gridMasonry('.grid-layout');
    //   });
    // }
  }

  @override
  void ngAfterChanges() {
    //draw();
    drawPagination();
    _syncSortingIndicators();
    // print('DatatableComponent@ngAfterChanges');
  }

  /// total de paginas
  int get numPages {
    final totalPages = (totalRecords / dataTableFilter.limit!).ceil();
    return totalPages;
  }

  void drawPagination() {
    // print('drawPagination');
    //quantidade total de paginas
    final totalPages = numPages;

    //quantidade de botões de paginação exibidos
    final btnQuantity = _btnQuantity > totalPages ? totalPages : _btnQuantity;
    final currentPage = _currentPage; //pagina atual
    //clear paginateContainer for new draws
    paginationItems.clear();
    if (totalRecords < dataTableFilter.limit!) {
      return;
    }

    if (btnQuantity == 1) {
      return;
    }

    var paginatePrevBtn = PaginationItem(
      //id: 'DataTables_Table_0_previous',
      cssClasses: ['paginate_button', 'page-item', 'previous'],
      label: '←',
      paginationButtonType: PaginationButtonType.prev,
      action: prevPage,
    );

    if (currentPage == 1) {
      paginatePrevBtn.removeClass('disabled');
      paginatePrevBtn.addClass('disabled');
    }
    paginationItems.add(paginatePrevBtn);

    final paginateNextBtn = PaginationItem(
      //id: 'DataTables_Table_0_next',
      cssClasses: ['paginate_button', 'page-item', 'next'],
      label: '→',
      paginationButtonType: PaginationButtonType.next,
      action: nextPage,
    );

    if (currentPage == totalPages) {
      paginateNextBtn.removeClass('disabled');
      paginateNextBtn.addClass('disabled');
    }

    var idx = 0;
    var loopEnd = 0;

    switch (paginationType) {
      case PaginationType.carousel:
        idx = (currentPage - (btnQuantity / 2)).toInt();
        if (idx <= 0) {
          idx = 1;
        }
        loopEnd = idx + btnQuantity;
        if (loopEnd > totalPages) {
          loopEnd = totalPages + 1;
          idx = loopEnd - btnQuantity;
        }
        while (idx < loopEnd) {
          final paginateBtn = PaginationItem(
            action: () {},
            cssClasses: [
              'paginate_button',
              'page-item',
              if (idx == currentPage) 'active'
            ],
            label: idx.toString(),
          );

          paginateBtn.action = () {
            final index = int.parse(paginateBtn.label);
            if (_currentPage != index) {
              _currentPage = index;
              changePage(_currentPage);
            }
          };
          paginationItems.add(paginateBtn);

          idx++;
        }
        break;
      case PaginationType.cube:
        final facePosition = (currentPage % btnQuantity) == 0
            ? btnQuantity
            : currentPage % btnQuantity;
        loopEnd = btnQuantity - facePosition + currentPage;
        idx = currentPage - facePosition;
        while (idx < loopEnd) {
          idx++;
          if (idx <= totalPages) {
            final paginateBtn = PaginationItem(
              action: () {},
              cssClasses: [
                'paginate_button',
                'page-item',
                if (idx == currentPage) 'active'
              ],
              label: idx.toString(),
            );

            paginateBtn.action = () {
              final index = int.parse(paginateBtn.label);
              if (_currentPage != index) {
                _currentPage = index;
                changePage(_currentPage);
              }
            };

            paginationItems.add(paginateBtn);
          }
        }
        break;
    }
    paginationItems.add(paginateNextBtn);
  }

  void prevPage() {
    if (_currentPage == 0) {
      return;
    }
    if (_currentPage > 1) {
      _currentPage--;
      changePage(_currentPage);
    }
  }

  void nextPage() {
    if (_currentPage == numPages) {
      return;
    }
    if (_currentPage < numPages) {
      _currentPage++;
      changePage(_currentPage);
    }
  }

  void changePage(int page) {
    onRequestData();
    if (page != _currentPage) {
      _currentPage = page;
    }
  }

  void irParaUltimaPagina() {
    final lastPage = numPages;
    _currentPage = lastPage;
    changePage(lastPage);
  }

  void irParaPrimeiraPagina() {
    _currentPage = 1;
    changePage(1);
  }

// -------------------------------- fim /pagination --------------------------------

  final _dataRequest = StreamController<Filters>();

  //evento dataRequest
  @Output()
  Stream<Filters> get dataRequest => _dataRequest.stream;

  bool isLoading = true;

  void onRequestData() {
    isLoading = true;
    var currentPage = _currentPage == 1 ? 0 : _currentPage - 1;
    dataTableFilter.offset = currentPage * dataTableFilter.limit!;
    //esperimental
    _settings.setOrdemStartIndex(dataTableFilter.offset!);

    _dataRequest.add(dataTableFilter);
  }

// ---------------- event to change the amount of items displayed per page ----------------
  final _limitChangeRequest = StreamController<Filters>();

  @Output()
  Stream<Filters> get limitChange => _limitChangeRequest.stream;

  void changeItemsPerPageHandler(SelectElement select) {
    var li = int.tryParse(select.selectedOptions.first.value);
    _currentPage = 1;
    dataTableFilter.limit = li;
    _limitChangeRequest.add(dataTableFilter);
    //onRequestData();
  }

// ---------------- evento de busca ----------------
  final _searchRequest = StreamController<Filters>();

  @Output()
  Stream<Filters> get searchRequest => _searchRequest.stream;

  void onSearch() {
    _currentPage = 1;
    _searchRequest.add(dataTableFilter);
    onRequestData();
  }

  @Input()
  bool disableSearchEvent = false;

  @Input()
  bool disableHeaderPadding = false;

  @Input()
  bool disableRowClick = false;

  void handleSearchInputKeypress(e) {
    //e.preventDefault();
    if (disableSearchEvent != true) {
      e.stopPropagation();
      if (e.keyCode == KeyCode.ENTER) {
        onSearch();
      }
    }
  }

  void handleSearchFieldSelectChange(event, String? index) {
    if (index != null) {
      var selectedSearchField = _searchInFields[int.parse(index)];
      //print('handleSearchFieldSelectChange $selectedSearchField');
      dataTableFilter.searchInFields = [
        FilterSearchField(
          active: true,
          field: selectedSearchField.field,
          operator: selectedSearchField.operator,
          label: selectedSearchField.label,
        )
      ];
    }
  }

// ---------------- evento quando clicar em uma row ----------------
  final _onRowClickStreamController = StreamController<dynamic>();

  /// event dispatched on row click
  /// ```html
  /// <datatable-component
  ///      [settings]="datatableSettings"
  ///      [data]="procedimentos"
  ///      (dataRequest)="onDataRequest($event)"
  ///       (onRowClick)="onRowClick($event)">
  /// </datatable-component>
  /// ```
  @Output()
  Stream<dynamic> get onRowClick => _onRowClickStreamController.stream;

  void rowClickHandler(DatatableRow row) {
    if (disableRowClick == false) {
      if (_onRowClickStreamController.isClosed == false) {
        if (row.type == DatatableRowType.normal) {
          _onRowClickStreamController.add(row.instance);
        }
      }
    }
  }

// ---------------- evento de selecionar items ----------------

  /// if true not show Checkbox on each row
  /// ```html
  /// <datatable-component
  ///      [settings]="datatableSettings"
  ///      [data]="procedimentos"
  ///      (dataRequest)="onDataRequest($event)"
  ///       (onRowClick)="onRowClick($event)"
  ///     [showCheckboxToSelectRow]="true">
  /// </datatable-component>
  /// ```
  @Input()
  bool showCheckboxToSelectRow = true;

  final _selectAllStreamController = StreamController<List<dynamic>>();

  @Output()
  Stream<List<dynamic>> get selectAll => _selectAllStreamController.stream;

  /// obter todos os selecionados
  List<T> getAllSelected<T>() => rows
      .where((e) => e.selected)
      .toList()
      .map<T>((e) => e.instance as T)
      .toList();

  //quando selecionar tudos os items
  bool isSelectAll = false;
  // void onSelectAll(event) {
  //   isSelectAll = !isSelectAll;
  //   if (isSelectAll == true) {
  //     rows.forEach((row) {
  //       row.selected = true;
  //     });
  //   } else {
  //     unSelectAll();
  //   }
  //   _selectAllStreamController.add(
  //       rows.where((e) => e.selected).toList().map((e) => e.instance).toList());
  // }
  void onSelectAll(Event event) {
    // Mudança para Event genérico para pegar o estado do input
    // Se estiver no modo de seleção única, não faça nada. O checkbox deve estar desabilitado.
    if (allowSingleSelectionOnly) {
      event
          .preventDefault(); // Impede a mudança visual do checkbox se clicado por algum motivo
      return;
    }

    // Lógica original (adaptada para ler o estado do checkbox)
    InputElement checkbox = event.target as InputElement;
    isSelectAll = checkbox.checked ?? false;

    for (final row in rows) {
      row.selected = isSelectAll;
    }

    // Emitir todos os selecionados (ou lista vazia se desmarcou todos)
    _selectAllStreamController
        .add(rows.where((e) => e.selected).map((e) => e.instance).toList());
  }

  void unSelectAll() {
    for (final row in rows) {
      row.selected = false;
    }
  }

  void unSelectItemInstance(item) {
    for (final row in rows) {
      if (row.instance == item) {
        row.selected = false;
      }
    }
  }

  final _selectStreamController = StreamController<dynamic>();

  @Output()
  Stream<dynamic> get select => _selectAllStreamController.stream;

  // quando selecionar um item
  // void onSelect(MouseEvent event, DatatableRow item) {
  //   event.stopPropagation();
  //   item.selected = !item.selected;
  //   if (item.selected) {
  //     _selectStreamController.add(item.instance);
  //   }
  // }
  void onSelect(MouseEvent event, DatatableRow item) {
    event.stopPropagation();

    // Estado que o checkbox *deveria* ter após o clique
    bool intendedSelectionState = !item.selected;

    if (allowSingleSelectionOnly) {
      if (intendedSelectionState == true) {
        // Se a intenção é MARCAR este item
        // 1. Desmarcar TODOS os outros itens primeiro
        for (var row in rows) {
          if (row != item) {
            // Não desmarcar o próprio item que estamos prestes a marcar
            row.selected = false;
          }
        }
        // 2. Marcar o item atual
        item.selected = true;
        isSelectAll =
            false; // Garante que o 'Select All' não fique marcado inconsistentemente
        _selectStreamController.add(item.instance); // Emitir o item selecionado
      } else {
        // Se a intenção é DESMARCAR este item
        item.selected = false;
        // Opcional: emitir um evento de deseleção ou null se necessário
        // _selectStreamController.add(null); // Exemplo, se desejar notificar a deseleção
      }
    } else {
      // Lógica original para seleção múltipla
      item.selected = intendedSelectionState;
      if (item.selected) {
        _selectStreamController.add(item.instance);
        // Verificar se todos estão selecionados após esta ação
        isSelectAll = rows.every((row) => row.selected);
      } else {
        isSelectAll =
            false; // Se um foi desmarcado, 'Select All' não pode ser verdadeiro
        // Opcional: emitir evento de deseleção
      }
    }
  }

  /// Se true, permite que apenas um item seja selecionado por vez.
  /// O checkbox "Selecionar Todos" será desabilitado.
  /// O padrão é false (permitir seleção múltipla).
  @Input()
  bool allowSingleSelectionOnly = false;

// ---------------- evento de ordenação ----------------
  @Input()
  bool enableGlobalSorting = true;

  @Input()
  bool enableMultiColumnSorting = false;

  void onOrder(DatatableCol colDefinition) {
    if (enableGlobalSorting != true) {
      return;
    }

    final sortingBy = colDefinition.sortingBy;
    if (colDefinition.enableSorting != true || sortingBy == null) {
      return;
    }

    final nextDirection = _nextSortDirection(
      sortingBy,
      colDefinition.defaultSortDirection,
    );
    if (enableMultiColumnSorting) {
      final orderFields = _resolvedOrderFields().toList(growable: true);
      final existingIndex = orderFields.indexWhere(
        (field) => field.field == sortingBy,
      );

      if (existingIndex >= 0) {
        orderFields[existingIndex] = FilterOrderField(
          field: sortingBy,
          direction: nextDirection,
        );
      } else {
        orderFields.add(
          FilterOrderField(
            field: sortingBy,
            direction: colDefinition.defaultSortDirection,
          ),
        );
      }

      dataTableFilter.setOrderFields(orderFields);
    } else {
      dataTableFilter.setSingleOrder(
        sortingBy,
        direction: nextDirection,
      );
    }

    _syncSortingIndicators();
    onRequestData();
  }

  List<FilterOrderField> _resolvedOrderFields() {
    if (dataTableFilter.orderFields.isNotEmpty) {
      return List<FilterOrderField>.from(dataTableFilter.orderFields);
    }

    final orderBy = dataTableFilter.orderBy;
    if (orderBy == null || orderBy.trim().isEmpty) {
      return <FilterOrderField>[];
    }

    return <FilterOrderField>[
      FilterOrderField(
        field: orderBy,
        direction: dataTableFilter.orderDir ?? 'desc',
      ),
    ];
  }

  String _nextSortDirection(
    String sortingBy,
    String defaultSortDirection,
  ) {
    for (final orderField in _resolvedOrderFields()) {
      if (orderField.field == sortingBy) {
        return orderField.direction == 'asc' ? 'desc' : 'asc';
      }
    }

    return defaultSortDirection;
  }

  void _syncSortingIndicators() {
    final headerElements = table?.querySelectorAll('th[data-sort-key]');
    if (headerElements == null) {
      return;
    }

    final orderFields = _resolvedOrderFields();
    for (final element in headerElements) {
      if (element is! HtmlElement) {
        continue;
      }

      element.classes.removeAll(['sorting_asc', 'sorting_desc']);

      final sortKey = element.getAttribute('data-sort-key');
      if (sortKey == null || sortKey.isEmpty) {
        continue;
      }

      FilterOrderField? currentOrder;
      var sortIndex = 0;
      for (final orderField in orderFields) {
        if (orderField.field == sortKey) {
          currentOrder = orderField;
          break;
        }
        sortIndex++;
      }

      if (currentOrder == null) {
        element.attributes.remove('title');
        continue;
      }

      element.classes.add(
        currentOrder.direction == 'asc' ? 'sorting_asc' : 'sorting_desc',
      );

      if (enableMultiColumnSorting && orderFields.length > 1) {
        final title = element.text?.trim() ?? '';
        element.title = '$title (${sortIndex + 1}o criterio)';
      } else {
        element.attributes.remove('title');
      }
    }
  }

  // ----------------------
  void changeVisibilityOfCol(DatatableCol col) {
    col.visibility = !col.visibility;
    col.visibilityOnCard = col.visibility;

    for (final row in rows) {
      for (final column in row.columns) {
        if (column.key == col.key) {
          column.visibility = col.visibility;
          column.visibilityOnCard = col.visibilityOnCard;
        }
      }
    }
  }

  /// exportar para Excel
  void exportXlsx() {
    // // Create a new Excel document.
    // final workbook = Workbook();
    // final sheet = workbook.worksheets[0];
    // if (rows.isNotEmpty) {
    //   sheet.importList(
    //       rows.first.columns.map((e) => e.title).toList(), 1, 1, false);

    //   for (var i = 1; i < rows.length + 1; i++) {
    //     final col = rows[i - 1];

    //     int firstRow = i + 1;
    //     int firstColumn = 1;

    //     sheet.importList(col.columns.map((e) => e.valueNormalizado).toList(),
    //         firstRow, firstColumn, false);
    //   }

    //   sheet
    //       .getRangeByIndex(1, 1, rows.length, rows.first.columns.length)
    //       .autoFitColumns();
    // }
    // // sheet.getRangeByName('A1').setText('Hello World');
    // // sheet.getRangeByName('A3').setNumber(44);
    // // sheet.getRangeByName('A5').setDateTime(DateTime(2020, 12, 12, 1, 10, 20));

    // // Save doc.
    // final List<int> bytes = workbook.saveAsStream();
    // FrontUtils.download(
    //   bytes,
    //   'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    //   'teste.xlsx',
    // );
    // //Dispose workbook
    // workbook.dispose();
  }

  Future<void> exportPdf([bool isPrint = false, bool isDownload = true]) async {
    // final loading = SimpleLoading();
    // loading.show();
    // try {
    //   final logoUrlSvg = '/assets/images/brasao_editado_1.svg';
    //   final svgRaw = await FrontUtils.getNetworkTextFile(logoUrlSvg);
    //   final svgImageLogo = pdf.SvgImage(svg: svgRaw);
    //   final docPdf = pdf.Document();
    //   final now = DateTime.now();
    //   final headerTextStyle =
    //       pdf.TextStyle(fontSize: 10, color: pdf.PdfColor.fromInt(0xff2c3e50));

    //   final tableItems = <List<String>>[];
    //   //adiciona os Titulos das colunas
    //   tableItems.add(settings.colsDefinitions
    //       .where((c) => c.visibility)
    //       .map((e) => e.title)
    //       .toList());

    //   String? anterior;

    //   for (var i = 0; i < rows.length; i++) {
    //     final stringCols = <String>[];
    //     // se tiver habilitado o agrupamanto colocar as divisoes de grupo
    //     if (settings.enableGrouping) {
    //       var groupingColumns = rows[i]
    //           .columns
    //           .where((el) => el.enableGrouping && el.groupByKey != null);
    //       var groupBys = groupingColumns.map((e) => e.groupByKey!).toList();

    //       if (groupBys.isNotEmpty) {
    //         var atual = rows[i]
    //             .columns
    //             .where((map) => groupBys.contains(map.key))
    //             .map((m) => m.valueNormalizado)
    //             .join('.');

    //         if ((i - 1) >= 0) {
    //           anterior = rows[i - 1]
    //               .columns
    //               .where((map) => groupBys.contains(map.key))
    //               .map((m) => m.valueNormalizado)
    //               .join('.');
    //         }

    //         if (atual != anterior) {
    //           //print('separador');
    //           tableItems.add([
    //             groupingColumns
    //                 .map((e) => e.valueNormalizado)
    //                 .join('      /     ')
    //           ]);
    //         }
    //         //print('sem separador');
    //         for (final col in rows[i].columns) {
    //           if (col.visibility) {
    //             stringCols.add(col.valueNormalizado);
    //           }
    //         }
    //         tableItems.add(stringCols);
    //       }
    //     } else {
    //       for (final col in rows[i].columns) {
    //         if (col.visibility) {
    //           stringCols.add(col.valueNormalizado);
    //         }
    //       }
    //       tableItems.add(stringCols);
    //     }
    //   }

    //   // define o tamanho da pagina para A3
    //   const double inch = 72.0;
    //   const double cm = inch / 2.54;
    //   final a3 = pdf.PdfPageFormat(29.7 * cm, 42 * cm, marginAll: 1.0 * cm);
    //   final pageFormat = a3;
    //   // INICIO DOS CALCULOS DA LARGURA DA COLUNA

    //   // Defina o tamanho da fonte
    //   const defaultFontSize = 12.0 * pdf.PdfPageFormat.point;
    //   // Fator para calcular largura mínima por caractere
    //   const charWidthFactor = defaultFontSize * 0.5;

    //   final colsStr =
    //       (tableItems.length > 1 ? tableItems[1] : tableItems.first);
    //   final totalCols = colsStr.length;

    //   // Inicializa uma lista para armazenar a largura máxima de cada coluna
    //   final maxColumnWidths = List<double>.filled(totalCols, 0);
    //   // Percorre todas as linhas da tabela para calcular a largura máxima de cada coluna
    //   for (var row in tableItems) {
    //     for (int i = 0; i < row.length; i++) {
    //       var width = row[i].length * charWidthFactor;
    //       // Verifica se o comprimento atual da célula é maior que o valor anterior
    //       if (width > maxColumnWidths[i]) {
    //         maxColumnWidths[i] = width;
    //       }
    //     }
    //   }
    //   // armazena os TableColumnWidth para cada coluna
    //   final columnWidths = <int, pdf.TableColumnWidth>{};
    //   // Ajusta as larguras das colunas com base na maior largura encontrada e o tamanho da página
    //   for (int i = 0; i < maxColumnWidths.length; i++) {
    //     var width = maxColumnWidths[i];
    //     // if (width < 30) {
    //     //   width = 30;
    //     // }
    //     // verifica se a lagura é maior que a largura da pagina dividito para total de colunas
    //     if (width > (pageFormat.width / totalCols)) {
    //       width = (pageFormat.width / totalCols);
    //     }
    //     columnWidths[i] = pdf.FixedColumnWidth(width);
    //   }
    //   // FIM DOS CALCULOS DA LARGURA DA COLUNA

    //   docPdf.addPage(
    //     pdf.MultiPage(
    //       orientation: pdf.PageOrientation.landscape,
    //       pageFormat: pageFormat,
    //       crossAxisAlignment: pdf.CrossAxisAlignment.start,
    //       header: (pdf.Context context) {
    //         return pdf.Row(
    //           mainAxisAlignment: pdf.MainAxisAlignment.spaceBetween,
    //           children: [
    //             pdf.Column(
    //               children: [
    //                 pdf.Text('Prefeitura Municipal de Rio das Ostras',
    //                     style: headerTextStyle),
    //                 pdf.Text(
    //                     'Rua Campo do Albacora, nº 75 - Loteamento Atlântica',
    //                     style: headerTextStyle),
    //                 pdf.Text('CEP: 28895-664 | Tel.: (22) 2771-1515',
    //                     style: headerTextStyle),
    //                 pdf.Text('E-mail: suporte@riodasostras.rj.gov.br',
    //                     style: headerTextStyle),
    //                 pdf.Text(
    //                     '''Emissão: ${DateFormat("dd/MM/yyyy 'às' HH:mm").format(now)}   |   Página: ${context.pageNumber} de ${context.pagesCount}''',
    //                     style: headerTextStyle),
    //               ],
    //               crossAxisAlignment: pdf.CrossAxisAlignment.start,
    //             ),
    //             pdf.SizedBox(
    //               height: 80,
    //               width: 150,
    //               child: svgImageLogo, //svgImage, //Image(imageLogo),
    //             )
    //           ],
    //         );
    //       },
    //       build: (pdf.Context context) => <pdf.Widget>[
    //         pdf.Header(
    //           level: 1,
    //           text: 'Relatório',
    //           margin: pdf.EdgeInsets.only(bottom: 1.0 * pdf.PdfPageFormat.mm),
    //           padding: pdf.EdgeInsets.only(bottom: 0.0 * pdf.PdfPageFormat.mm),
    //           decoration: pdf.BoxDecoration(),
    //         ),
    //         pdf.TableHelper.fromTextArray(
    //             context: context, data: tableItems, columnWidths: columnWidths),
    //       ],
    //       footer: (pdf.Context context) {
    //         return pdf.Container(
    //           width: double.infinity,
    //           decoration: pdf.BoxDecoration(
    //               border: pdf.Border(
    //                   top: pdf.BorderSide(color: pdf.PdfColors.grey))),
    //           child: pdf.Padding(
    //             padding: pdf.EdgeInsets.only(top: 5),
    //             child: pdf.Text('Sistema NewSali - ${DateTime.now().year}',
    //                 style:
    //                     pdf.TextStyle(fontSize: 9, color: pdf.PdfColors.grey)),
    //           ),
    //         );
    //       },
    //     ),
    //   );

    //   //save PDF
    //   final bytes = await docPdf.save();
    //   if (isDownload) {
    //     FrontUtils.download(bytes, 'application/pdf', 'Relatório.pdf');
    //   }
    //   if (isPrint) {
    //     await FrontUtils.printFileBytes(bytes, 'application/pdf');
    //   }
    // } catch (e, s) {
    //   print('Erro ao gerar PDF $e $s');
    // } finally {
    //   loading.hide();
    // }
  }

  @override
  void ngOnDestroy() {
    _selectStreamController.close();
    _selectAllStreamController.close();
    _onRowClickStreamController.close();
    _searchRequest.close();
    _limitChangeRequest.close();
    _dataRequest.close();
  }
}
