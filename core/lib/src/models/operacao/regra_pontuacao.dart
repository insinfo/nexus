import 'dart:convert';

class RegraPontuacao {
  static const tableName = 'regras_pontuacao';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idVersaoConjuntoRegrasCol = 'id_versao_conjunto_regras';
  static const chaveRegraCol = 'chave_regra';
  static const tituloCol = 'titulo';
  static const expressaoJsonCol = 'expressao_json';
  static const valorPontuacaoCol = 'valor_pontuacao';
  static const ordemCol = 'ordem';
  static const idFqCol = '$fqtb.$idCol';
  static const idVersaoConjuntoRegrasFqCol = '$fqtb.$idVersaoConjuntoRegrasCol';

  RegraPontuacao({
    required this.id,
    required this.idVersaoConjuntoRegras,
    required this.chaveRegra,
    required this.titulo,
    required this.expressaoJson,
    this.valorPontuacao,
    this.ordem = 0,
  });

  int id;
  int idVersaoConjuntoRegras;
  String chaveRegra;
  String titulo;
  String expressaoJson;
  double? valorPontuacao;
  int ordem;

  RegraPontuacao clone() {
    return RegraPontuacao(
      id: id,
      idVersaoConjuntoRegras: idVersaoConjuntoRegras,
      chaveRegra: chaveRegra,
      titulo: titulo,
      expressaoJson: expressaoJson,
      valorPontuacao: valorPontuacao,
      ordem: ordem,
    );
  }

  factory RegraPontuacao.fromMap(Map<String, dynamic> map) {
    return RegraPontuacao(
      id: map[idCol] as int? ?? 0,
      idVersaoConjuntoRegras: map[idVersaoConjuntoRegrasCol] as int? ?? 0,
      chaveRegra: map[chaveRegraCol] as String? ?? '',
      titulo: map[tituloCol] as String? ?? '',
      expressaoJson: map[expressaoJsonCol] is Map
          ? jsonEncode(Map<String, dynamic>.from(map[expressaoJsonCol] as Map))
          : map[expressaoJsonCol]?.toString() ?? '{}',
      valorPontuacao: map[valorPontuacaoCol] is num
          ? (map[valorPontuacaoCol] as num).toDouble()
          : double.tryParse(map[valorPontuacaoCol]?.toString() ?? ''),
      ordem: map[ordemCol] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idCol: id,
      idVersaoConjuntoRegrasCol: idVersaoConjuntoRegras,
      chaveRegraCol: chaveRegra,
      tituloCol: titulo,
      expressaoJsonCol: expressaoJson,
      valorPontuacaoCol: valorPontuacao,
      ordemCol: ordem,
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove(idCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toMap();
    map.remove(idCol);
    map.remove(idVersaoConjuntoRegrasCol);
    return map;
  }
}
