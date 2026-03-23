import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class CodigoAutorizacaoOidc implements SerializeBase {
  static const tableName = 'codigos_autorizacao_oidc';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const hashCodigoCol = 'hash_codigo';
  static const hashCodigoFqCol = '$fqtb.$hashCodigoCol';
  static const idClienteCol = 'id_cliente';
  static const idClienteFqCol = '$fqtb.$idClienteCol';
  static const idUsuarioCol = 'id_usuario';
  static const idUsuarioFqCol = '$fqtb.$idUsuarioCol';
  static const escoposCol = 'escopos';
  static const escoposFqCol = '$fqtb.$escoposCol';
  static const uriRedirecionamentoCol = 'uri_redirecionamento';
  static const uriRedirecionamentoFqCol = '$fqtb.$uriRedirecionamentoCol';
  static const expiraEmCol = 'expira_em';
  static const expiraEmFqCol = '$fqtb.$expiraEmCol';
  static const desafioPkceCol = 'desafio_pkce';
  static const desafioPkceFqCol = '$fqtb.$desafioPkceCol';
  static const metodoDesafioPkceCol = 'metodo_desafio_pkce';
  static const metodoDesafioPkceFqCol = '$fqtb.$metodoDesafioPkceCol';
  static const nonceCol = 'nonce';
  static const nonceFqCol = '$fqtb.$nonceCol';
  static const loginGovbrCol = 'login_govbr';
  static const loginGovbrFqCol = '$fqtb.$loginGovbrCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';

  CodigoAutorizacaoOidc({
    this.id,
    this.hashCodigo,
    this.idCliente,
    this.idUsuario,
    this.escopos = const <String>[],
    this.uriRedirecionamento,
    this.expiraEm,
    this.desafioPkce,
    this.metodoDesafioPkce,
    this.nonce,
    this.loginGovbr = false,
    this.criadoEm,
  });
  int? id;
  String? hashCodigo;
  String? idCliente;
  int? idUsuario;
  List<String> escopos;
  String? uriRedirecionamento;
  DateTime? expiraEm;
  String? desafioPkce;
  String? metodoDesafioPkce;
  String? nonce;
  bool loginGovbr;
  DateTime? criadoEm;
  CodigoAutorizacaoOidc clone() {
    return CodigoAutorizacaoOidc(
      id: id,
      hashCodigo: hashCodigo,
      idCliente: idCliente,
      idUsuario: idUsuario,
      escopos: escopos,
      uriRedirecionamento: uriRedirecionamento,
      expiraEm: expiraEm,
      desafioPkce: desafioPkce,
      metodoDesafioPkce: metodoDesafioPkce,
      nonce: nonce,
      loginGovbr: loginGovbr,
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

  factory CodigoAutorizacaoOidc.fromMap(Map<String, dynamic> mapa) {
    return CodigoAutorizacaoOidc(
      id: mapa[idCol] as int?,
      hashCodigo: mapa[hashCodigoCol] as String?,
      idCliente: mapa[idClienteCol]?.toString(),
      idUsuario: mapa[idUsuarioCol] as int?,
      escopos: lerListaTexto(mapa[escoposCol]),
      uriRedirecionamento: mapa[uriRedirecionamentoCol] as String?,
      expiraEm: lerDataHora(mapa[expiraEmCol]),
      desafioPkce: mapa[desafioPkceCol] as String?,
      metodoDesafioPkce: mapa[metodoDesafioPkceCol] as String?,
      nonce: mapa[nonceCol] as String?,
      loginGovbr: (mapa[loginGovbrCol] as bool?) ?? false,
      criadoEm: lerDataHora(mapa[criadoEmCol]),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        idCol: id,
        hashCodigoCol: hashCodigo,
        idClienteCol: idCliente,
        idUsuarioCol: idUsuario,
        escoposCol: escopos,
        uriRedirecionamentoCol: uriRedirecionamento,
        expiraEmCol: expiraEm?.toIso8601String(),
        desafioPkceCol: desafioPkce,
        metodoDesafioPkceCol: metodoDesafioPkce,
        nonceCol: nonce,
        loginGovbrCol: loginGovbr,
        criadoEmCol: criadoEm?.toIso8601String(),
      };
}
