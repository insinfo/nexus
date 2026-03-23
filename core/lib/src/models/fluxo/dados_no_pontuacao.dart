import '../comum/enums_nexus.dart';
import 'dados_no_fluxo.dart';

class DadosNoPontuacao extends DadosNoFluxo {
  static const tableName = 'dados_no_pontuacao';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const rotuloCol = 'rotulo';
  static const rotuloFqCol = '$fqtb.$rotuloCol';
  static const idVersaoConjuntoRegrasCol = 'id_versao_conjunto_regras';
  static const idVersaoConjuntoRegrasFqCol = '$fqtb.$idVersaoConjuntoRegrasCol';
  static const chaveResultadoCol = 'chave_resultado';
  static const chaveResultadoFqCol = '$fqtb.$chaveResultadoCol';

  DadosNoPontuacao({
    required this.rotulo,
    this.idVersaoConjuntoRegras,
    this.chaveResultado = 'pontuacao',
  });

  String rotulo;
  String? idVersaoConjuntoRegras;
  String chaveResultado;

  DadosNoPontuacao clone() {
    return DadosNoPontuacao(
      rotulo: rotulo,
      idVersaoConjuntoRegras: idVersaoConjuntoRegras,
      chaveResultado: chaveResultado,
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

  factory DadosNoPontuacao.fromMap(Map<String, dynamic> mapa) {
    return DadosNoPontuacao(
      rotulo: mapa[rotuloCol] as String? ?? '',
      idVersaoConjuntoRegras: mapa[idVersaoConjuntoRegrasCol]?.toString(),
      chaveResultado: mapa[chaveResultadoCol] as String? ?? 'pontuacao',
    );
  }

  @override
  String get tipoNo => TipoNoFluxo.pontuacao.val;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      rotuloCol: rotulo,
      idVersaoConjuntoRegrasCol: idVersaoConjuntoRegras,
      chaveResultadoCol: chaveResultado,
    };
  }
}
