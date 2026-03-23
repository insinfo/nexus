import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class TokenAcessoOidc implements SerializeBase {
  static const tableName = 'tokens_acesso_oidc';
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
  static const idTokenRefreshCol = 'id_token_refresh';
  static const idTokenRefreshFqCol = '$fqtb.$idTokenRefreshCol';
  static const escoposCol = 'escopos';
  static const escoposFqCol = '$fqtb.$escoposCol';
  static const tipoTokenCol = 'tipo_token';
  static const tipoTokenFqCol = '$fqtb.$tipoTokenCol';
  static const expiraEmCol = 'expira_em';
  static const expiraEmFqCol = '$fqtb.$expiraEmCol';
  static const revogadoCol = 'revogado';
  static const revogadoFqCol = '$fqtb.$revogadoCol';
  static const claimsCol = 'claims_json';
  static const claimsFqCol = '$fqtb.$claimsCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';

  TokenAcessoOidc({
    this.id,
    this.jti,
    this.hashToken,
    this.idCliente,
    this.idUsuario,
    this.idTokenRefresh,
    this.escopos = const <String>[],
    this.tipoToken = 'bearer',
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
  int? idTokenRefresh;
  List<String> escopos;
  String tipoToken;
  DateTime? expiraEm;
  bool revogado;
  Map<String, dynamic> claims;
  DateTime? criadoEm;
  TokenAcessoOidc clone() {
    return TokenAcessoOidc(
      id: id,
      jti: jti,
      hashToken: hashToken,
      idCliente: idCliente,
      idUsuario: idUsuario,
      idTokenRefresh: idTokenRefresh,
      escopos: escopos,
      tipoToken: tipoToken,
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

  factory TokenAcessoOidc.fromMap(Map<String, dynamic> mapa) {
    return TokenAcessoOidc(
      id: mapa[idCol] as int?,
      jti: mapa[jtiCol]?.toString(),
      hashToken: mapa[hashTokenCol] as String?,
      idCliente: mapa[idClienteCol]?.toString(),
      idUsuario: mapa[idUsuarioCol] as int?,
      idTokenRefresh: mapa[idTokenRefreshCol] as int?,
      escopos: lerListaTexto(mapa[escoposCol]),
      tipoToken: (mapa[tipoTokenCol] as String?) ?? 'bearer',
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
        idTokenRefreshCol: idTokenRefresh,
        escoposCol: escopos,
        tipoTokenCol: tipoToken,
        expiraEmCol: expiraEm?.toIso8601String(),
        revogadoCol: revogado,
        claimsCol: claims,
        criadoEmCol: criadoEm?.toIso8601String(),
      };
}
