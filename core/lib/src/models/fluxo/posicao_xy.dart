import 'package:essential_core/essential_core.dart';

class PosicaoXY implements SerializeBase {
  static const tableName = 'posicao_xy';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const xCol = 'x';
  static const xFqCol = '$fqtb.$xCol';
  static const yCol = 'y';
  static const yFqCol = '$fqtb.$yCol';

  PosicaoXY({
    required this.x,
    required this.y,
  });
  double x;
  double y;
  PosicaoXY clone() {
    return PosicaoXY(
      x: x,
      y: y,
    );
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove(idCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap();
    map.remove(idCol);
    return map;
  }

  factory PosicaoXY.fromMap(Map<String, dynamic> mapa) {
    return PosicaoXY(
      x: (mapa['x'] as num).toDouble(),
      y: (mapa['y'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{'x': x, 'y': y};
}
