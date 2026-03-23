import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class Permissao implements SerializeBase {
  static const tableName = 'permissao';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const codigoCol = 'codigo';
  static const codigoFqCol = '$fqtb.$codigoCol';
  static const nomeCol = 'nome';
  static const nomeFqCol = '$fqtb.$nomeCol';
  static const descricaoCol = 'descricao';
  static const descricaoFqCol = '$fqtb.$descricaoCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';

  Permissao({
    this.id,
    this.codigo = '',
    this.nome = '',
    this.descricao,
    this.criadoEm,
  });
  int? id;
  String codigo;
  String nome;
  String? descricao;
  DateTime? criadoEm;
  Permissao clone() {
    return Permissao(
      id: id,
      codigo: codigo,
      nome: nome,
      descricao: descricao,
      criadoEm: criadoEm,
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

  factory Permissao.fromMap(Map<String, dynamic> mapa) {
    return Permissao(
      id: mapa['id'] as int?,
      codigo: (mapa['codigo'] as String?) ?? '',
      nome: (mapa['nome'] as String?) ?? '',
      descricao: mapa['descricao'] as String?,
      criadoEm: lerDataHora(mapa['criadoEm']),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'codigo': codigo,
        'nome': nome,
        'descricao': descricao,
        'criadoEm': criadoEm?.toIso8601String(),
      };
}
