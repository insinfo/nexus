import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class ConsentimentoOidc implements SerializeBase {
  static const tableName = 'consentimentos_oidc';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idClienteCol = 'id_cliente';
  static const idClienteFqCol = '$fqtb.$idClienteCol';
  static const idUsuarioCol = 'id_usuario';
  static const idUsuarioFqCol = '$fqtb.$idUsuarioCol';
  static const escoposConcedidosCol = 'escopos_concedidos';
  static const escoposConcedidosFqCol = '$fqtb.$escoposConcedidosCol';
  static const claimsConcedidasCol = 'claims_concedidas_json';
  static const claimsConcedidasFqCol = '$fqtb.$claimsConcedidasCol';
  static const origemConsentimentoCol = 'origem_consentimento';
  static const origemConsentimentoFqCol = '$fqtb.$origemConsentimentoCol';
  static const concedidoEmCol = 'concedido_em';
  static const concedidoEmFqCol = '$fqtb.$concedidoEmCol';
  static const revogadoEmCol = 'revogado_em';
  static const revogadoEmFqCol = '$fqtb.$revogadoEmCol';
  static const observacoesCol = 'observacoes';
  static const observacoesFqCol = '$fqtb.$observacoesCol';

  ConsentimentoOidc({
    this.id,
    this.idCliente,
    this.idUsuario,
    this.escoposConcedidos = const <String>[],
    this.claimsConcedidas = const <String, dynamic>{},
    this.origemConsentimento = 'tela_login',
    this.concedidoEm,
    this.revogadoEm,
    this.observacoes,
  });
  int? id;
  String? idCliente;
  int? idUsuario;
  List<String> escoposConcedidos;
  Map<String, dynamic> claimsConcedidas;
  String origemConsentimento;
  DateTime? concedidoEm;
  DateTime? revogadoEm;
  String? observacoes;
  ConsentimentoOidc clone() {
    return ConsentimentoOidc(
      id: id,
      idCliente: idCliente,
      idUsuario: idUsuario,
      escoposConcedidos: escoposConcedidos,
      claimsConcedidas: Map<String, dynamic>.from(claimsConcedidas),
      origemConsentimento: origemConsentimento,
      concedidoEm: concedidoEm,
      revogadoEm: revogadoEm,
      observacoes: observacoes,
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

  factory ConsentimentoOidc.fromMap(Map<String, dynamic> mapa) {
    return ConsentimentoOidc(
      id: mapa[idCol] as int?,
      idCliente: mapa[idClienteCol]?.toString(),
      idUsuario: mapa[idUsuarioCol] as int?,
      escoposConcedidos: lerListaTexto(mapa[escoposConcedidosCol]),
      claimsConcedidas: lerMapa(mapa[claimsConcedidasCol]),
      origemConsentimento:
          (mapa[origemConsentimentoCol] as String?) ?? 'tela_login',
      concedidoEm: lerDataHora(mapa[concedidoEmCol]),
      revogadoEm: lerDataHora(mapa[revogadoEmCol]),
      observacoes: mapa[observacoesCol] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        idCol: id,
        idClienteCol: idCliente,
        idUsuarioCol: idUsuario,
        escoposConcedidosCol: escoposConcedidos,
        claimsConcedidasCol: claimsConcedidas,
        origemConsentimentoCol: origemConsentimento,
        concedidoEmCol: concedidoEm?.toIso8601String(),
        revogadoEmCol: revogadoEm?.toIso8601String(),
        observacoesCol: observacoes,
      };
}
