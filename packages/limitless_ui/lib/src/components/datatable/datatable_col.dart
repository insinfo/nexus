import 'dart:html';

export 'datatable_style.dart';

import 'datatable_style.dart';

enum DatatableColType { normal, groupTitle }

/// Column definition and rendered value container used by the datatable.
class DatatableCol {
  /// Source key used to read the value from an item map.
  String key;
  String? sortingBy;
  String defaultSortDirection;
  dynamic id;
  String value;

  /// HTML element appended to the table cell when using [customRenderHtml].
  Element? htmlElement;
  dynamic instance;
  String title;
  DatatableFormat? format;
  String? styleCss;

  /// Whether the column is visible in table mode.
  bool visibility = true;

  /// Whether the column is visible in grid mode.
  bool visibilityOnCard = true;

  /// Whether the title should be shown in grid mode.
  bool showTitleOnCard = true;

  bool showAsFooterOnCard = false;
  bool enableSorting = false;

  /// Custom renderer for the string content shown in the cell.
  String Function(Map<String, dynamic> itemMap, dynamic itemInstance)?
      customRenderString;

  Element Function(Map<String, dynamic> itemMap, dynamic itemInstance)?
      customRenderHtml;

  /// Separator used when multiple values are rendered in the same column.
  String multiValSeparator = ' - ';

  bool enableGrouping = false;

  /// Key used to build grouping sections.
  String? groupByKey;

  /// Optional colspan used by group rows and custom cells.
  int? colspan;

  DatatableColType type = DatatableColType.normal;

  DatatableCol({
    this.id,
    required this.key,
    this.value = '',
    this.instance,
    required this.title,
    this.format,
    this.styleCss,
    this.visibility = true,
    this.enableSorting = false,
    this.customRenderString,
    this.customRenderHtml,
    this.multiValSeparator = ' - ',
    this.sortingBy,
    this.defaultSortDirection = 'asc',
    this.htmlElement,
    this.enableGrouping = false,
    this.groupByKey,
    this.colspan,
    this.visibilityOnCard = true,
    this.showTitleOnCard = true,
    this.showAsFooterOnCard = false,
    this.type = DatatableColType.normal,
  });
}
