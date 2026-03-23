import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class Escolaridade implements SerializeBase {
  static const tableName = 'escolaridade';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const codigoCol = 'codigo';
  static const codigoFqCol = '$fqtb.$codigoCol';
  static const descricaoCol = 'descricao';
  static const descricaoFqCol = '$fqtb.$descricaoCol';
  static const ordemCol = 'ordem';
  static const ordemFqCol = '$fqtb.$ordemCol';
  static const ativoCol = 'ativo';
  static const ativoFqCol = '$fqtb.$ativoCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';

  Escolaridade({
    this.id,
    this.codigo,
    this.descricao,
    this.ordem = 0,
    this.ativo = true,
    this.criadoEm,
  });
  int? id;
  String? codigo;
  String? descricao;
  int ordem;
  bool ativo;
  DateTime? criadoEm;
  Escolaridade clone() {
    return Escolaridade(
      id: id,
      codigo: codigo,
      descricao: descricao,
      ordem: ordem,
      ativo: ativo,
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

  factory Escolaridade.fromMap(Map<String, dynamic> mapa) {
    return Escolaridade(
      id: mapa['id'] as int?,
      codigo: mapa['codigo'] as String?,
      descricao: mapa['descricao'] as String?,
      ordem: (mapa['ordem'] as int?) ?? 0,
      ativo: (mapa['ativo'] as bool?) ?? true,
      criadoEm: lerDataHora(mapa['criadoEm']),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'codigo': codigo,
        'descricao': descricao,
        'ordem': ordem,
        'ativo': ativo,
        'criadoEm': criadoEm?.toIso8601String(),
      };
}
