import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class CategoriaCnh implements SerializeBase {
  static const tableName = 'categoria_cnh';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const codigoCol = 'codigo';
  static const codigoFqCol = '$fqtb.$codigoCol';
  static const descricaoCol = 'descricao';
  static const descricaoFqCol = '$fqtb.$descricaoCol';
  static const ativoCol = 'ativo';
  static const ativoFqCol = '$fqtb.$ativoCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';

  CategoriaCnh({
    this.id,
    this.codigo,
    this.descricao,
    this.ativo = true,
    this.criadoEm,
  });
  int? id;
  String? codigo;
  String? descricao;
  bool ativo;
  DateTime? criadoEm;
  CategoriaCnh clone() {
    return CategoriaCnh(
      id: id,
      codigo: codigo,
      descricao: descricao,
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

  factory CategoriaCnh.fromMap(Map<String, dynamic> mapa) {
    return CategoriaCnh(
      id: mapa['id'] as int?,
      codigo: mapa['codigo'] as String?,
      descricao: mapa['descricao'] as String?,
      ativo: (mapa['ativo'] as bool?) ?? true,
      criadoEm: lerDataHora(mapa['criadoEm']),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'codigo': codigo,
        'descricao': descricao,
        'ativo': ativo,
        'criadoEm': criadoEm?.toIso8601String(),
      };
}
