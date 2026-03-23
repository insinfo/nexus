import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class Pais implements SerializeBase {
  static const tableName = 'pais';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const codigoIso2Col = 'codigo_iso2';
  static const codigoIso2FqCol = '$fqtb.$codigoIso2Col';
  static const codigoIso3Col = 'codigo_iso3';
  static const codigoIso3FqCol = '$fqtb.$codigoIso3Col';
  static const nomeCol = 'nome';
  static const nomeFqCol = '$fqtb.$nomeCol';
  static const nacionalidadeCol = 'nacionalidade';
  static const nacionalidadeFqCol = '$fqtb.$nacionalidadeCol';
  static const ativoCol = 'ativo';
  static const ativoFqCol = '$fqtb.$ativoCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const atualizadoEmCol = 'atualizado_em';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';

  Pais({
    this.id,
    this.codigoIso2,
    this.codigoIso3,
    this.nome,
    this.nacionalidade,
    this.ativo = true,
    this.criadoEm,
    this.atualizadoEm,
  });
  int? id;
  String? codigoIso2;
  String? codigoIso3;
  String? nome;
  String? nacionalidade;
  bool ativo;
  DateTime? criadoEm;
  DateTime? atualizadoEm;
  Pais clone() {
    return Pais(
      id: id,
      codigoIso2: codigoIso2,
      codigoIso3: codigoIso3,
      nome: nome,
      nacionalidade: nacionalidade,
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

  factory Pais.fromMap(Map<String, dynamic> mapa) {
    return Pais(
      id: mapa['id'] as int?,
      codigoIso2: mapa['codigoIso2'] as String?,
      codigoIso3: mapa['codigoIso3'] as String?,
      nome: mapa['nome'] as String?,
      nacionalidade: mapa['nacionalidade'] as String?,
      ativo: (mapa['ativo'] as bool?) ?? true,
      criadoEm: lerDataHora(mapa['criadoEm']),
      atualizadoEm: lerDataHora(mapa['atualizadoEm']),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'codigoIso2': codigoIso2,
        'codigoIso3': codigoIso3,
        'nome': nome,
        'nacionalidade': nacionalidade,
        'ativo': ativo,
        'criadoEm': criadoEm?.toIso8601String(),
        'atualizadoEm': atualizadoEm?.toIso8601String(),
      };
}
