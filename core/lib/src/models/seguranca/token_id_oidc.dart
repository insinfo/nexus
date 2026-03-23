import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class TokenIdOidc implements SerializeBase {
  static const tableName = 'tokens_id_oidc';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const jtiCol = 'jti';
  static const jtiFqCol = '$fqtb.$jtiCol';
  static const hashTokenCol = 'hash_token';
  static const hashTokenFqCol = '$fqtb.$hashTokenCol';
  static const idClienteCol = 'id_cliente';
  static const idClienteFqCol = '$fqtb.$idClienteCol';
  static const idUsuarioCol = 'id_usuario';
  static const idUsuarioFqCol = '$fqtb.$idUsuarioCol';
  static const idTokenAcessoCol = 'id_token_acesso';
  static const idTokenAcessoFqCol = '$fqtb.$idTokenAcessoCol';
  static const nonceCol = 'nonce';
  static const nonceFqCol = '$fqtb.$nonceCol';
  static const hashSessaoCol = 'hash_sessao';
  static const hashSessaoFqCol = '$fqtb.$hashSessaoCol';
  static const expiraEmCol = 'expira_em';
  static const expiraEmFqCol = '$fqtb.$expiraEmCol';
  static const revogadoCol = 'revogado';
  static const revogadoFqCol = '$fqtb.$revogadoCol';
  static const claimsCol = 'claims_json';
  static const claimsFqCol = '$fqtb.$claimsCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';

  TokenIdOidc({
    this.id,
    this.jti,
    this.hashToken,
    this.idCliente,
    this.idUsuario,
    this.idTokenAcesso,
    this.nonce,
    this.hashSessao,
    this.expiraEm,
    this.revogado = false,
    this.claims = const <String, dynamic>{},
    this.criadoEm,
  });
  int? id;
  String? jti;
  String? hashToken;
  String? idCliente;
  int? idUsuario;
  int? idTokenAcesso;
  String? nonce;
  String? hashSessao;
  DateTime? expiraEm;
  bool revogado;
  Map<String, dynamic> claims;
  DateTime? criadoEm;
  TokenIdOidc clone() {
    return TokenIdOidc(
      id: id,
      jti: jti,
      hashToken: hashToken,
      idCliente: idCliente,
      idUsuario: idUsuario,
      idTokenAcesso: idTokenAcesso,
      nonce: nonce,
      hashSessao: hashSessao,
      expiraEm: expiraEm,
      revogado: revogado,
      claims: Map<String, dynamic>.from(claims),
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

  factory TokenIdOidc.fromMap(Map<String, dynamic> mapa) {
    return TokenIdOidc(
      id: mapa[idCol] as int?,
      jti: mapa[jtiCol]?.toString(),
      hashToken: mapa[hashTokenCol] as String?,
      idCliente: mapa[idClienteCol]?.toString(),
      idUsuario: mapa[idUsuarioCol] as int?,
      idTokenAcesso: mapa[idTokenAcessoCol] as int?,
      nonce: mapa[nonceCol] as String?,
      hashSessao: mapa[hashSessaoCol] as String?,
      expiraEm: lerDataHora(mapa[expiraEmCol]),
      revogado: (mapa[revogadoCol] as bool?) ?? false,
      claims: lerMapa(mapa[claimsCol]),
      criadoEm: lerDataHora(mapa[criadoEmCol]),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        idCol: id,
        jtiCol: jti,
        hashTokenCol: hashToken,
        idClienteCol: idCliente,
        idUsuarioCol: idUsuario,
        idTokenAcessoCol: idTokenAcesso,
        nonceCol: nonce,
        hashSessaoCol: hashSessao,
        expiraEmCol: expiraEm?.toIso8601String(),
        revogadoCol: revogado,
        claimsCol: claims,
        criadoEmCol: criadoEm?.toIso8601String(),
      };
}
