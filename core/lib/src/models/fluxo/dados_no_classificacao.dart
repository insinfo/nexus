import '../comum/enums_nexus.dart';
import 'dados_no_fluxo.dart';

class DadosNoClassificacao extends DadosNoFluxo {
  static const tableName = 'dados_no_classificacao';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const rotuloCol = 'rotulo';
  static const rotuloFqCol = '$fqtb.$rotuloCol';
  static const idVersaoConjuntoRegrasCol = 'id_versao_conjunto_regras';
  static const idVersaoConjuntoRegrasFqCol = '$fqtb.$idVersaoConjuntoRegrasCol';
  static const notasCol = 'notas';
  static const notasFqCol = '$fqtb.$notasCol';

  DadosNoClassificacao({
    required this.rotulo,
    this.idVersaoConjuntoRegras,
    this.notas,
  });

  String rotulo;
  String? idVersaoConjuntoRegras;
  String? notas;

  DadosNoClassificacao clone() {
    return DadosNoClassificacao(
      rotulo: rotulo,
      idVersaoConjuntoRegras: idVersaoConjuntoRegras,
      notas: notas,
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

  factory DadosNoClassificacao.fromMap(Map<String, dynamic> mapa) {
    return DadosNoClassificacao(
      rotulo: mapa[rotuloCol] as String? ?? '',
      idVersaoConjuntoRegras: mapa[idVersaoConjuntoRegrasCol]?.toString(),
      notas: mapa[notasCol] as String?,
    );
  }

  @override
  String get tipoNo => TipoNoFluxo.classificacao.val;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      rotuloCol: rotulo,
      idVersaoConjuntoRegrasCol: idVersaoConjuntoRegras,
      notasCol: notas,
    };
  }
}
