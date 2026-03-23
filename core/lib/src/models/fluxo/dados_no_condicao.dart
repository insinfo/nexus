import '../comum/enums_nexus.dart';
import 'dados_no_fluxo.dart';

class DadosNoCondicao extends DadosNoFluxo {
  static const tableName = 'dados_no_condicao';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const rotuloCol = 'rotulo';
  static const rotuloFqCol = '$fqtb.$rotuloCol';
  static const expressaoCol = 'expressao';
  static const expressaoFqCol = '$fqtb.$expressaoCol';
  static const handleVerdadeiroCol = 'handle_verdadeiro';
  static const handleVerdadeiroFqCol = '$fqtb.$handleVerdadeiroCol';
  static const handleFalsoCol = 'handle_falso';
  static const handleFalsoFqCol = '$fqtb.$handleFalsoCol';

  DadosNoCondicao({
    required this.rotulo,
    required this.expressao,
    this.handleVerdadeiro = 'true',
    this.handleFalso = 'false',
  });
  String rotulo;
  String expressao;
  String handleVerdadeiro;
  String handleFalso;
  DadosNoCondicao clone() {
    return DadosNoCondicao(
      rotulo: rotulo,
      expressao: expressao,
      handleVerdadeiro: handleVerdadeiro,
      handleFalso: handleFalso,
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

  factory DadosNoCondicao.fromMap(Map<String, dynamic> mapa) {
    return DadosNoCondicao(
      rotulo: mapa['rotulo'] as String,
      expressao: mapa['expressao'] as String,
      handleVerdadeiro: (mapa['handle_verdadeiro'] as String?) ?? 'true',
      handleFalso: (mapa['handle_falso'] as String?) ?? 'false',
    );
  }

  @override
  String get tipoNo => TipoNoFluxo.condicao.val;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rotulo': rotulo,
      'expressao': expressao,
      'handle_verdadeiro': handleVerdadeiro,
      'handle_falso': handleFalso,
    };
  }
}
