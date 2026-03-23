import 'dart:convert';

class RegraElegibilidade {
  static const tableName = 'regras_elegibilidade';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idVersaoConjuntoRegrasCol = 'id_versao_conjunto_regras';
  static const chaveRegraCol = 'chave_regra';
  static const tituloCol = 'titulo';
  static const expressaoJsonCol = 'expressao_json';
  static const motivoFalhaCol = 'motivo_falha';
  static const ordemCol = 'ordem';
  static const idFqCol = '$fqtb.$idCol';
  static const idVersaoConjuntoRegrasFqCol = '$fqtb.$idVersaoConjuntoRegrasCol';

  RegraElegibilidade({
    required this.id,
    required this.idVersaoConjuntoRegras,
    required this.chaveRegra,
    required this.titulo,
    required this.expressaoJson,
    this.motivoFalha,
    this.ordem = 0,
  });

  int id;
  int idVersaoConjuntoRegras;
  String chaveRegra;
  String titulo;
  String expressaoJson;
  String? motivoFalha;
  int ordem;

  RegraElegibilidade clone() {
    return RegraElegibilidade(
      id: id,
      idVersaoConjuntoRegras: idVersaoConjuntoRegras,
      chaveRegra: chaveRegra,
      titulo: titulo,
      expressaoJson: expressaoJson,
      motivoFalha: motivoFalha,
      ordem: ordem,
    );
  }

  factory RegraElegibilidade.fromMap(Map<String, dynamic> map) {
    return RegraElegibilidade(
      id: map[idCol] as int? ?? 0,
      idVersaoConjuntoRegras: map[idVersaoConjuntoRegrasCol] as int? ?? 0,
      chaveRegra: map[chaveRegraCol] as String? ?? '',
      titulo: map[tituloCol] as String? ?? '',
      expressaoJson: map[expressaoJsonCol] is Map
          ? jsonEncode(Map<String, dynamic>.from(map[expressaoJsonCol] as Map))
          : map[expressaoJsonCol]?.toString() ?? '{}',
      motivoFalha: map[motivoFalhaCol] as String?,
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
      motivoFalhaCol: motivoFalha,
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
