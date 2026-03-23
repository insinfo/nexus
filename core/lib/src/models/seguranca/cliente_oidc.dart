import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class ClienteOidc implements SerializeBase {
  static const tableName = 'clientes_oidc';
  static const fqtb = 'public.$tableName';
  static const idClienteCol = 'id_cliente';
  static const idClienteFqCol = '$fqtb.$idClienteCol';
  static const hashSegredoClienteCol = 'hash_segredo_cliente';
  static const hashSegredoClienteFqCol = '$fqtb.$hashSegredoClienteCol';
  static const nomeClienteCol = 'nome_cliente';
  static const nomeClienteFqCol = '$fqtb.$nomeClienteCol';
  static const urisRedirecionamentoCol = 'uris_redirecionamento';
  static const urisRedirecionamentoFqCol = '$fqtb.$urisRedirecionamentoCol';
  static const escoposPermitidosCol = 'escopos_permitidos';
  static const escoposPermitidosFqCol = '$fqtb.$escoposPermitidosCol';
  static const tipoAplicacaoCol = 'tipo_aplicacao';
  static const tipoAplicacaoFqCol = '$fqtb.$tipoAplicacaoCol';
  static const urisRedirecionamentoPosLogoutCol =
      'uris_redirecionamento_pos_logout';
  static const urisRedirecionamentoPosLogoutFqCol =
      '$fqtb.$urisRedirecionamentoPosLogoutCol';
  static const tiposGrantSuportadosCol = 'tipos_grant_suportados';
  static const tiposGrantSuportadosFqCol = '$fqtb.$tiposGrantSuportadosCol';
  static const tiposRespostaSuportadosCol = 'tipos_resposta_suportados';
  static const tiposRespostaSuportadosFqCol =
      '$fqtb.$tiposRespostaSuportadosCol';
  static const metodoAutenticacaoTokenCol = 'metodo_autenticacao_token';
  static const metodoAutenticacaoTokenFqCol =
      '$fqtb.$metodoAutenticacaoTokenCol';
  static const ativoCol = 'ativo';
  static const ativoFqCol = '$fqtb.$ativoCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const atualizadoEmCol = 'atualizado_em';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';

  ClienteOidc({
    this.idCliente = '',
    this.hashSegredoCliente,
    this.nomeCliente = '',
    this.urisRedirecionamento = const <String>[],
    this.escoposPermitidos = const <String>[],
    this.tipoAplicacao = '',
    this.urisRedirecionamentoPosLogout = const <String>[],
    this.tiposGrantSuportados = const <String>[],
    this.tiposRespostaSuportados = const <String>[],
    this.metodoAutenticacaoToken = 'none',
    this.ativo = true,
    this.criadoEm,
    this.atualizadoEm,
  });
  String idCliente;
  String? hashSegredoCliente;
  String nomeCliente;
  List<String> urisRedirecionamento;
  List<String> escoposPermitidos;
  String tipoAplicacao;
  List<String> urisRedirecionamentoPosLogout;
  List<String> tiposGrantSuportados;
  List<String> tiposRespostaSuportados;
  String metodoAutenticacaoToken;
  bool ativo;
  DateTime? criadoEm;
  DateTime? atualizadoEm;
  ClienteOidc clone() {
    return ClienteOidc(
      idCliente: idCliente,
      hashSegredoCliente: hashSegredoCliente,
      nomeCliente: nomeCliente,
      urisRedirecionamento: List<String>.from(urisRedirecionamento),
      escoposPermitidos: List<String>.from(escoposPermitidos),
      tipoAplicacao: tipoAplicacao,
      urisRedirecionamentoPosLogout:
          List<String>.from(urisRedirecionamentoPosLogout),
      tiposGrantSuportados: List<String>.from(tiposGrantSuportados),
      tiposRespostaSuportados: List<String>.from(tiposRespostaSuportados),
      metodoAutenticacaoToken: metodoAutenticacaoToken,
      ativo: ativo,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm,
    );
  }

  Map<String, dynamic> toInsertMap() => toMap();

  Map<String, dynamic> toUpdateMap() {
    final map = toMap();
    map.remove(idClienteCol);
    map.remove(criadoEmCol);
    return map;
  }

  factory ClienteOidc.fromMap(Map<String, dynamic> mapa) {
    return ClienteOidc(
      idCliente: mapa[idClienteCol]?.toString() ?? '',
      hashSegredoCliente: mapa[hashSegredoClienteCol] as String?,
      nomeCliente: (mapa[nomeClienteCol] as String?) ?? '',
      urisRedirecionamento: lerListaTexto(mapa[urisRedirecionamentoCol]),
      escoposPermitidos: lerListaTexto(mapa[escoposPermitidosCol]),
      tipoAplicacao: (mapa[tipoAplicacaoCol] as String?) ?? '',
      urisRedirecionamentoPosLogout:
          lerListaTexto(mapa[urisRedirecionamentoPosLogoutCol]),
      tiposGrantSuportados: lerListaTexto(mapa[tiposGrantSuportadosCol]),
      tiposRespostaSuportados:
          lerListaTexto(mapa[tiposRespostaSuportadosCol]),
      metodoAutenticacaoToken:
          (mapa[metodoAutenticacaoTokenCol] as String?) ?? 'none',
      ativo: (mapa[ativoCol] as bool?) ?? true,
      criadoEm: lerDataHora(mapa[criadoEmCol]),
      atualizadoEm: lerDataHora(mapa[atualizadoEmCol]),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        idClienteCol: idCliente,
        hashSegredoClienteCol: hashSegredoCliente,
        nomeClienteCol: nomeCliente,
        urisRedirecionamentoCol: urisRedirecionamento,
        escoposPermitidosCol: escoposPermitidos,
        tipoAplicacaoCol: tipoAplicacao,
        urisRedirecionamentoPosLogoutCol: urisRedirecionamentoPosLogout,
        tiposGrantSuportadosCol: tiposGrantSuportados,
        tiposRespostaSuportadosCol: tiposRespostaSuportados,
        metodoAutenticacaoTokenCol: metodoAutenticacaoToken,
        ativoCol: ativo,
        criadoEmCol: criadoEm?.toIso8601String(),
        atualizadoEmCol: atualizadoEm?.toIso8601String(),
      };
}
