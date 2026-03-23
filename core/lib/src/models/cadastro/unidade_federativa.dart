import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class UnidadeFederativa implements SerializeBase {
  static const tableName = 'unidade_federativa';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idPaisCol = 'id_pais';
  static const idPaisFqCol = '$fqtb.$idPaisCol';
  static const codigoIbgeCol = 'codigo_ibge';
  static const codigoIbgeFqCol = '$fqtb.$codigoIbgeCol';
  static const nomeCol = 'nome';
  static const nomeFqCol = '$fqtb.$nomeCol';
  static const siglaCol = 'sigla';
  static const siglaFqCol = '$fqtb.$siglaCol';
  static const ativoCol = 'ativo';
  static const ativoFqCol = '$fqtb.$ativoCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const atualizadoEmCol = 'atualizado_em';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';

  UnidadeFederativa({
    this.id,
    this.idPais,
    this.codigoIbge,
    this.nome,
    this.sigla,
    this.ativo = true,
    this.criadoEm,
    this.atualizadoEm,
  });
  int? id;
  int? idPais;
  int? codigoIbge;
  String? nome;
  String? sigla;
  bool ativo;
  DateTime? criadoEm;
  DateTime? atualizadoEm;
  UnidadeFederativa clone() {
    return UnidadeFederativa(
      id: id,
      idPais: idPais,
      codigoIbge: codigoIbge,
      nome: nome,
      sigla: sigla,
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

  factory UnidadeFederativa.fromMap(Map<String, dynamic> mapa) {
    return UnidadeFederativa(
      id: mapa['id'] as int?,
      idPais: mapa['id_pais'] as int?,
      codigoIbge: mapa['codigo_ibge'] as int?,
      nome: mapa['nome'] as String?,
      sigla: mapa['sigla'] as String?,
      ativo: (mapa['ativo'] as bool?) ?? true,
      criadoEm: lerDataHora(mapa['criado_em']),
      atualizadoEm: lerDataHora(mapa['atualizado_em']),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'id_pais': idPais,
        'codigo_ibge': codigoIbge,
        'nome': nome,
        'sigla': sigla,
        'ativo': ativo,
        'criado_em': criadoEm?.toIso8601String(),
        'atualizado_em': atualizadoEm?.toIso8601String(),
      };
}
