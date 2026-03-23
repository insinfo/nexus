import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class SessaoAutenticacao implements SerializeBase {
  static const tableName = 'sessoes_autenticacao';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idPublicoCol = 'id_publico';
  static const idPublicoFqCol = '$fqtb.$idPublicoCol';
  static const idUsuarioCol = 'id_usuario';
  static const idUsuarioFqCol = '$fqtb.$idUsuarioCol';
  static const hashRefreshTokenCol = 'hash_refresh_token';
  static const hashRefreshTokenFqCol = '$fqtb.$hashRefreshTokenCol';
  static const enderecoIpCol = 'endereco_ip';
  static const enderecoIpFqCol = '$fqtb.$enderecoIpCol';
  static const userAgentCol = 'user_agent';
  static const userAgentFqCol = '$fqtb.$userAgentCol';
  static const expiraEmCol = 'expira_em';
  static const expiraEmFqCol = '$fqtb.$expiraEmCol';
  static const revogadaEmCol = 'revogada_em';
  static const revogadaEmFqCol = '$fqtb.$revogadaEmCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';

  SessaoAutenticacao({
    this.id,
    this.idPublico,
    this.idUsuario,
    this.hashRefreshToken,
    this.enderecoIp,
    this.userAgent,
    this.expiraEm,
    this.revogadaEm,
    this.criadoEm,
  });
  int? id;
  String? idPublico;
  int? idUsuario;
  String? hashRefreshToken;
  String? enderecoIp;
  String? userAgent;
  DateTime? expiraEm;
  DateTime? revogadaEm;
  DateTime? criadoEm;
  SessaoAutenticacao clone() {
    return SessaoAutenticacao(
      id: id,
      idPublico: idPublico,
      idUsuario: idUsuario,
      hashRefreshToken: hashRefreshToken,
      enderecoIp: enderecoIp,
      userAgent: userAgent,
      expiraEm: expiraEm,
      revogadaEm: revogadaEm,
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

  factory SessaoAutenticacao.fromMap(Map<String, dynamic> mapa) {
    return SessaoAutenticacao(
      id: mapa[idCol] as int?,
      idPublico: mapa[idPublicoCol]?.toString(),
      idUsuario: mapa[idUsuarioCol] as int?,
      hashRefreshToken: mapa[hashRefreshTokenCol] as String?,
      enderecoIp: mapa[enderecoIpCol]?.toString(),
      userAgent: mapa[userAgentCol] as String?,
      expiraEm: lerDataHora(mapa[expiraEmCol]),
      revogadaEm: lerDataHora(mapa[revogadaEmCol]),
      criadoEm: lerDataHora(mapa[criadoEmCol]),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
      idCol: id,
      idPublicoCol: idPublico,
      idUsuarioCol: idUsuario,
      hashRefreshTokenCol: hashRefreshToken,
      enderecoIpCol: enderecoIp,
      userAgentCol: userAgent,
      expiraEmCol: expiraEm?.toIso8601String(),
      revogadaEmCol: revogadaEm?.toIso8601String(),
      criadoEmCol: criadoEm?.toIso8601String(),
      };
}
