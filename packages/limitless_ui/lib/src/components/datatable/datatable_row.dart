//datatable_row.dart
import 'datatable_col.dart';

enum DatatableRowType { normal, groupTitle }

class DatatableRow {
  dynamic instance;
  dynamic id;
  int index;
  List<DatatableCol> columns = [];
  bool selected = false;
  String? styleCss;

  DatatableRowType type = DatatableRowType.normal;

  DatatableRow(
      {required this.columns,
      this.instance,
      this.id,
      this.index = -1,
      this.styleCss,
      this.type = DatatableRowType.normal});

  void addColumn(DatatableCol column) {
    //columns ??= [];
    columns.add(column);
  }

  List<DatatableCol> get columnsCardBody => columns
      .where((c) =>
          c.showAsFooterOnCard == false && c.type == DatatableColType.normal)
      .toList();

  List<DatatableCol> get columnsCardFooter => columns
      .where((c) =>
          c.showAsFooterOnCard == true && c.type == DatatableColType.normal)
      .toList();
}
