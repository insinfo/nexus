import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class ValorAtributoCadastroPessoa implements SerializeBase {
  static const tableName = 'valor_atributo_cadastro_pessoa';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idHistoricoCadastroCol = 'id_historico_cadastro';
  static const idHistoricoCadastroFqCol = '$fqtb.$idHistoricoCadastroCol';
  static const idAtributoCol = 'id_atributo';
  static const idAtributoFqCol = '$fqtb.$idAtributoCol';
  static const valorTextoCol = 'valor_texto';
  static const valorTextoFqCol = '$fqtb.$valorTextoCol';
  static const valorNumeroCol = 'valor_numero';
  static const valorNumeroFqCol = '$fqtb.$valorNumeroCol';
  static const valorBooleanoCol = 'valor_booleano';
  static const valorBooleanoFqCol = '$fqtb.$valorBooleanoCol';
  static const valorDataCol = 'valor_data';
  static const valorDataFqCol = '$fqtb.$valorDataCol';
  static const valorJsonCol = 'valor_json';
  static const valorJsonFqCol = '$fqtb.$valorJsonCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const atualizadoEmCol = 'atualizado_em';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';

  ValorAtributoCadastroPessoa({
    this.id,
    this.idHistoricoCadastro,
    this.idAtributo,
    this.valorTexto,
    this.valorNumero,
    this.valorBooleano,
    this.valorData,
    this.valorJson = const <String, dynamic>{},
    this.criadoEm,
    this.atualizadoEm,
  });
  int? id;
  int? idHistoricoCadastro;
  int? idAtributo;
  String? valorTexto;
  double? valorNumero;
  bool? valorBooleano;
  DateTime? valorData;
  Map<String, dynamic> valorJson;
  DateTime? criadoEm;
  DateTime? atualizadoEm;
  ValorAtributoCadastroPessoa clone() {
    return ValorAtributoCadastroPessoa(
      id: id,
      idHistoricoCadastro: idHistoricoCadastro,
      idAtributo: idAtributo,
      valorTexto: valorTexto,
      valorNumero: valorNumero,
      valorBooleano: valorBooleano,
      valorData: valorData,
      valorJson: valorJson,
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

  factory ValorAtributoCadastroPessoa.fromMap(Map<String, dynamic> mapa) {
    return ValorAtributoCadastroPessoa(
      id: mapa['id'] as int?,
      idHistoricoCadastro: mapa['id_historico_cadastro'] as int?,
      idAtributo: mapa['id_atributo'] as int?,
      valorTexto: mapa['valor_texto'] as String?,
      valorNumero: lerDouble(mapa['valor_numero']),
      valorBooleano: mapa['valor_booleano'] as bool?,
      valorData: lerDataHora(mapa['valor_data']),
      valorJson: lerMapa(mapa['valor_json']),
      criadoEm: lerDataHora(mapa['criado_em']),
      atualizadoEm: lerDataHora(mapa['atualizado_em']),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'id_historico_cadastro': idHistoricoCadastro,
        'id_atributo': idAtributo,
        'valor_texto': valorTexto,
        'valor_numero': valorNumero,
        'valor_booleano': valorBooleano,
        'valor_data': valorData?.toIso8601String(),
        'valor_json': valorJson,
        'criado_em': criadoEm?.toIso8601String(),
        'atualizado_em': atualizadoEm?.toIso8601String(),
      };
}
