import '../comum/enums_nexus.dart';
import 'dados_no_fluxo.dart';

class DadosNoInicio extends DadosNoFluxo {
  static const tableName = 'dados_no_inicio';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const rotuloCol = 'rotulo';
  static const rotuloFqCol = '$fqtb.$rotuloCol';

  DadosNoInicio({required this.rotulo});
  String rotulo;
  DadosNoInicio clone() {
    return DadosNoInicio(
      rotulo: rotulo,
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

  factory DadosNoInicio.fromMap(Map<String, dynamic> mapa) {
    return DadosNoInicio(rotulo: mapa['rotulo'] as String);
  }

  @override
  String get tipoNo => TipoNoFluxo.inicio.val;

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{'rotulo': rotulo};
}
