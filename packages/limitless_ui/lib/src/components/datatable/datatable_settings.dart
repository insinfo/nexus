//datatable_settings.dart
//import 'datatable_row.dart';
import 'datatable_col.dart';

typedef RowStyleResolver = String? Function(
  Map<String, dynamic> itemMap,
  dynamic itemInstance,
);

class DatatableSettings {
  /// define as colunas que vão aparecer na tabela
  List<DatatableCol> colsDefinitions = [];

  bool enableGrouping = false;

  /// exibir a coluna do número de ordem
  bool showOrderNumberColumn = false;

  /// definir índice inicial do numero de ordem
  int _ordemIndex = 1;

  /// definir índice inicial do numero de ordem
  void setOrdemStartIndex(int ordem) {
    _ordemIndex = ordem;
  }

  RowStyleResolver? rowStyleResolver;

  /// [colsDefinitions] define as colunas que vão aparecer na tabela
  /// [showOrderNumberColumn] exibe uma coluna com um numero que enumera as linhas dos dados exbidos no dataTable
  DatatableSettings({
    required this.colsDefinitions,
    this.enableGrouping = false,
    this.showOrderNumberColumn = false,
    this.rowStyleResolver,
  }) {
    if (showOrderNumberColumn) {
      final col = DatatableCol(
          key: 'ordem',
          title: 'Ordem',
          visibility: false,
          customRenderString: (itemMap, itemInstance) {
            return '${_ordemIndex++}';
          });
      colsDefinitions.insert(0, col);
    }
  }

  // Iterable<int> countDownFromSyncRecursive(int num) sync* {
  //   if (num > 0) {
  //     yield num;
  //     yield* countDownFromSyncRecursive(num - 1);
  //   }
  // }

  // Iterable<int> genSerial(int num) sync* {
  //   if (num > 0) {
  //     yield num;
  //     yield* genSerial(num + 1);
  //   }
  // }

  // Iterable<int> generateNum() sync* {
  //   int n = 0;
  //   while (true) {
  //     yield n++;
  //   }
  // }
}
