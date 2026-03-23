import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class TipoLogradouro implements SerializeBase {
  static const tableName = 'tipo_logradouro';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const nomeCol = 'nome';
  static const nomeFqCol = '$fqtb.$nomeCol';
  static const abreviaturaCol = 'abreviatura';
  static const abreviaturaFqCol = '$fqtb.$abreviaturaCol';
  static const ativoCol = 'ativo';
  static const ativoFqCol = '$fqtb.$ativoCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';

  TipoLogradouro({
    this.id,
    this.nome,
    this.abreviatura,
    this.ativo = true,
    this.criadoEm,
  });
  int? id;
  String? nome;
  String? abreviatura;
  bool ativo;
  DateTime? criadoEm;
  TipoLogradouro clone() {
    return TipoLogradouro(
      id: id,
      nome: nome,
      abreviatura: abreviatura,
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

  factory TipoLogradouro.fromMap(Map<String, dynamic> mapa) {
    return TipoLogradouro(
      id: mapa['id'] as int?,
      nome: mapa['nome'] as String?,
      abreviatura: mapa['abreviatura'] as String?,
      ativo: (mapa['ativo'] as bool?) ?? true,
      criadoEm: lerDataHora(mapa['criadoEm']),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'nome': nome,
        'abreviatura': abreviatura,
        'ativo': ativo,
        'criadoEm': criadoEm?.toIso8601String(),
      };
}
