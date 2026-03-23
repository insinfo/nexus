import 'dart:convert';

import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class ValidacaoCampo implements SerializeBase {
  static const tableName = 'validacoes_campo';
  static const fqtn = 'public.$tableName';
  static const fqtb = fqtn;
  static const idCol = 'id';
  static const idCampoCol = 'id_campo';
  static const tipoValidacaoCol = 'tipo_validacao';
  static const configuracaoJsonCol = 'configuracao_json';
  static const mensagemCol = 'mensagem';
  static const idFqCol = '$fqtb.$idCol';
  static const idCampoFqCol = '$fqtb.$idCampoCol';
  static const tipoValidacaoFqCol = '$fqtb.$tipoValidacaoCol';
  static const configuracaoJsonFqCol = '$fqtb.$configuracaoJsonCol';
  static const mensagemFqCol = '$fqtb.$mensagemCol';
  int id;
  int idCampo;
  String tipoValidacao;
  String configuracaoJson;
  String? mensagem;

  ValidacaoCampo({
    this.id = 0,
    this.idCampo = 0,
    String? tipoValidacao,
    String? tipo,
    String? configuracaoJson,
    Map<String, dynamic>? configuracao,
    this.mensagem,
  })  : tipoValidacao = tipoValidacao ?? tipo ?? '',
        configuracaoJson = configuracaoJson ??
            jsonEncode(configuracao ?? const <String, dynamic>{});

  String get tipo => tipoValidacao;
  set tipo(String tipo) => tipoValidacao = tipo;

  Map<String, dynamic> get configuracao {
    final valor = jsonDecode(configuracaoJson);
    if (valor is Map) {
      return lerMapa(valor);
    }
    return <String, dynamic>{};
  }

  set configuracao(Map<String, dynamic> configuracao) {
    configuracaoJson = jsonEncode(configuracao);
  }

  factory ValidacaoCampo.fromMap(Map<String, dynamic> map) {
    return ValidacaoCampo(
      id: map[idCol] as int? ?? 0,
      idCampo: map[idCampoCol] as int? ?? 0,
      tipoValidacao: (map[tipoValidacaoCol] ?? map['tipo']) as String? ?? '',
      configuracaoJson: map[configuracaoJsonCol]?.toString() ??
          jsonEncode(lerMapa(map['configuracao'])),
      mensagem: map[mensagemCol] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tipo': tipoValidacao,
      'configuracao': configuracao,
      'mensagem': mensagem,
    };
  }

  Map<String, dynamic> _toPersistenciaMap() {
    return <String, dynamic>{
      idCol: id,
      idCampoCol: idCampo,
      tipoValidacaoCol: tipoValidacao,
      configuracaoJsonCol: configuracaoJson,
      mensagemCol: mensagem,
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = _toPersistenciaMap()..remove(idCol);
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    final map = _toPersistenciaMap()
      ..remove(idCol)
      ..remove(idCampoCol);
    return map;
  }

  ValidacaoCampo clone() {
    return ValidacaoCampo(
      id: id,
      idCampo: idCampo,
      tipoValidacao: tipoValidacao,
      configuracaoJson: configuracaoJson,
      mensagem: mensagem,
    );
  }
}
