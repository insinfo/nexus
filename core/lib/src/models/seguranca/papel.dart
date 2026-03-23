import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class Papel implements SerializeBase {
  static const tableName = 'papel';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const codigoCol = 'codigo';
  static const codigoFqCol = '$fqtb.$codigoCol';
  static const nomeCol = 'nome';
  static const nomeFqCol = '$fqtb.$nomeCol';
  static const escopoCol = 'escopo';
  static const escopoFqCol = '$fqtb.$escopoCol';
  static const descricaoCol = 'descricao';
  static const descricaoFqCol = '$fqtb.$descricaoCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const atualizadoEmCol = 'atualizado_em';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';

  Papel({
    this.id,
    this.codigo = '',
    this.nome = '',
    this.escopo = 'interno',
    this.descricao,
    this.criadoEm,
    this.atualizadoEm,
  });
  int? id;
  String codigo;
  String nome;
  String escopo;
  String? descricao;
  DateTime? criadoEm;
  DateTime? atualizadoEm;
  Papel clone() {
    return Papel(
      id: id,
      codigo: codigo,
      nome: nome,
      escopo: escopo,
      descricao: descricao,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm,
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

  factory Papel.fromMap(Map<String, dynamic> mapa) {
    return Papel(
      id: mapa['id'] as int?,
      codigo: (mapa['codigo'] as String?) ?? '',
      nome: (mapa['nome'] as String?) ?? '',
      escopo: (mapa['escopo'] as String?) ?? 'interno',
      descricao: mapa['descricao'] as String?,
      criadoEm: lerDataHora(mapa['criadoEm']),
      atualizadoEm: lerDataHora(mapa['atualizadoEm']),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'codigo': codigo,
        'nome': nome,
        'escopo': escopo,
        'descricao': descricao,
        'criadoEm': criadoEm?.toIso8601String(),
        'atualizadoEm': atualizadoEm?.toIso8601String(),
      };
}
