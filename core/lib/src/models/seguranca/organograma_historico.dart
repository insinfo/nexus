import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class OrganogramaHistorico implements SerializeBase {
  static const tableName = 'organograma_historico';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idPaiCol = 'id_pai';
  static const idPaiFqCol = '$fqtb.$idPaiCol';
  static const idOrganogramaCol = 'id_organograma';
  static const idOrganogramaFqCol = '$fqtb.$idOrganogramaCol';
  static const dataInicioCol = 'data_inicio';
  static const dataInicioFqCol = '$fqtb.$dataInicioCol';
  static const siglaCol = 'sigla';
  static const siglaFqCol = '$fqtb.$siglaCol';
  static const nomeCol = 'nome';
  static const nomeFqCol = '$fqtb.$nomeCol';
  static const tipoCol = 'tipo';
  static const tipoFqCol = '$fqtb.$tipoCol';
  static const subTipoCol = 'sub_tipo';
  static const subTipoFqCol = '$fqtb.$subTipoCol';
  static const ultimoCol = 'ultimo';
  static const ultimoFqCol = '$fqtb.$ultimoCol';
  static const secretariaCol = 'secretaria';
  static const secretariaFqCol = '$fqtb.$secretariaCol';
  static const oficialCol = 'oficial';
  static const oficialFqCol = '$fqtb.$oficialCol';
  static const recebeProcessoCol = 'recebe_processo';
  static const recebeProcessoFqCol = '$fqtb.$recebeProcessoCol';
  static const protocoloCol = 'protocolo';
  static const protocoloFqCol = '$fqtb.$protocoloCol';
  static const permissaoSelecaoCol = 'permissao_selecao';
  static const permissaoSelecaoFqCol = '$fqtb.$permissaoSelecaoCol';
  static const caixaEntradaCol = 'caixa_entrada';
  static const caixaEntradaFqCol = '$fqtb.$caixaEntradaCol';
  static const corCol = 'cor';
  static const corFqCol = '$fqtb.$corCol';

  OrganogramaHistorico({
    this.id,
    this.idPai,
    this.idOrganograma,
    this.dataInicio,
    this.sigla,
    this.nome,
    this.tipo,
    this.subTipo,
    this.ultimo = false,
    this.secretaria = false,
    this.oficial = false,
    this.recebeProcesso,
    this.protocolo,
    this.permissaoSelecao,
    this.caixaEntrada = false,
    this.cor,
  });
  int? id;
  int? idPai;
  int? idOrganograma;
  DateTime? dataInicio;
  String? sigla;
  String? nome;
  String? tipo;
  String? subTipo;
  bool ultimo;
  bool secretaria;
  bool oficial;
  int? recebeProcesso;
  bool? protocolo;
  int? permissaoSelecao;
  bool caixaEntrada;
  String? cor;
  OrganogramaHistorico clone() {
    return OrganogramaHistorico(
      id: id,
      idPai: idPai,
      idOrganograma: idOrganograma,
      dataInicio: dataInicio,
      sigla: sigla,
      nome: nome,
      tipo: tipo,
      subTipo: subTipo,
      ultimo: ultimo,
      secretaria: secretaria,
      oficial: oficial,
      recebeProcesso: recebeProcesso,
      protocolo: protocolo,
      permissaoSelecao: permissaoSelecao,
      caixaEntrada: caixaEntrada,
      cor: cor,
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

  factory OrganogramaHistorico.fromMap(Map<String, dynamic> mapa) {
    return OrganogramaHistorico(
      id: mapa['id'] as int?,
      idPai: mapa['idPai'] as int?,
      idOrganograma: mapa['idOrganograma'] as int?,
      dataInicio: lerDataHora(mapa['dataInicio']),
      sigla: mapa['sigla'] as String?,
      nome: mapa['nome'] as String?,
      tipo: mapa['tipo'] as String?,
      subTipo: mapa['subTipo'] as String?,
      ultimo: (mapa['ultimo'] as bool?) ?? false,
      secretaria: (mapa['secretaria'] as bool?) ?? false,
      oficial: (mapa['oficial'] as bool?) ?? false,
      recebeProcesso: mapa['recebeProcesso'] as int?,
      protocolo: mapa['protocolo'] as bool?,
      permissaoSelecao: mapa['permissaoSelecao'] as int?,
      caixaEntrada: (mapa['caixaEntrada'] as bool?) ?? false,
      cor: mapa['cor'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'idPai': idPai,
      'idOrganograma': idOrganograma,
      'dataInicio': dataInicio?.toIso8601String(),
      'sigla': sigla,
      'nome': nome,
      'tipo': tipo,
      'subTipo': subTipo,
      'ultimo': ultimo,
      'secretaria': secretaria,
      'oficial': oficial,
      'recebeProcesso': recebeProcesso,
      'protocolo': protocolo,
      'permissaoSelecao': permissaoSelecao,
      'caixaEntrada': caixaEntrada,
      'cor': cor,
    };
  }
}
