import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class Municipio implements SerializeBase {
  static const tableName = 'municipio';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idUnidadeFederativaCol = 'id_unidade_federativa';
  static const idUnidadeFederativaFqCol = '$fqtb.$idUnidadeFederativaCol';
  static const codigoIbgeCol = 'codigo_ibge';
  static const codigoIbgeFqCol = '$fqtb.$codigoIbgeCol';
  static const nomeCol = 'nome';
  static const nomeFqCol = '$fqtb.$nomeCol';
  static const ativoCol = 'ativo';
  static const ativoFqCol = '$fqtb.$ativoCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const atualizadoEmCol = 'atualizado_em';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';

  Municipio({
    this.id,
    this.idUnidadeFederativa,
    this.codigoIbge,
    this.nome,
    this.ativo = true,
    this.criadoEm,
    this.atualizadoEm,
  });
  int? id;
  int? idUnidadeFederativa;
  int? codigoIbge;
  String? nome;
  bool ativo;
  DateTime? criadoEm;
  DateTime? atualizadoEm;
  Municipio clone() {
    return Municipio(
      id: id,
      idUnidadeFederativa: idUnidadeFederativa,
      codigoIbge: codigoIbge,
      nome: nome,
      ativo: ativo,
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

  factory Municipio.fromMap(Map<String, dynamic> mapa) {
    return Municipio(
      id: mapa['id'] as int?,
      idUnidadeFederativa: mapa['idUnidadeFederativa'] as int?,
      codigoIbge: mapa['codigoIbge'] as int?,
      nome: mapa['nome'] as String?,
      ativo: (mapa['ativo'] as bool?) ?? true,
      criadoEm: lerDataHora(mapa['criadoEm']),
      atualizadoEm: lerDataHora(mapa['atualizadoEm']),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'idUnidadeFederativa': idUnidadeFederativa,
        'codigoIbge': codigoIbge,
        'nome': nome,
        'ativo': ativo,
        'criadoEm': criadoEm?.toIso8601String(),
        'atualizadoEm': atualizadoEm?.toIso8601String(),
      };
}
