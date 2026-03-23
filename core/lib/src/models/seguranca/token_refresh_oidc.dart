import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class TokenRefreshOidc implements SerializeBase {
  static const tableName = 'tokens_refresh_oidc';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const hashTokenCol = 'hash_token';
  static const hashTokenFqCol = '$fqtb.$hashTokenCol';
  static const idClienteCol = 'id_cliente';
  static const idClienteFqCol = '$fqtb.$idClienteCol';
  static const idUsuarioCol = 'id_usuario';
  static const idUsuarioFqCol = '$fqtb.$idUsuarioCol';
  static const escoposCol = 'escopos';
  static const escoposFqCol = '$fqtb.$escoposCol';
  static const expiraEmCol = 'expira_em';
  static const expiraEmFqCol = '$fqtb.$expiraEmCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const revogadoCol = 'revogado';
  static const revogadoFqCol = '$fqtb.$revogadoCol';

  TokenRefreshOidc({
    this.id,
    this.hashToken,
    this.idCliente,
    this.idUsuario,
    this.escopos = const <String>[],
    this.expiraEm,
    this.criadoEm,
    this.revogado = false,
  });
  int? id;
  String? hashToken;
  String? idCliente;
  int? idUsuario;
  List<String> escopos;
  DateTime? expiraEm;
  DateTime? criadoEm;
  bool revogado;
  TokenRefreshOidc clone() {
    return TokenRefreshOidc(
      id: id,
      hashToken: hashToken,
      idCliente: idCliente,
      idUsuario: idUsuario,
      escopos: escopos,
      expiraEm: expiraEm,
      criadoEm: criadoEm,
      revogado: revogado,
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

  factory TokenRefreshOidc.fromMap(Map<String, dynamic> mapa) {
    return TokenRefreshOidc(
      id: mapa[idCol] as int?,
      hashToken: mapa[hashTokenCol] as String?,
      idCliente: mapa[idClienteCol]?.toString(),
      idUsuario: mapa[idUsuarioCol] as int?,
      escopos: lerListaTexto(mapa[escoposCol]),
      expiraEm: lerDataHora(mapa[expiraEmCol]),
      criadoEm: lerDataHora(mapa[criadoEmCol]),
      revogado: (mapa[revogadoCol] as bool?) ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        idCol: id,
        hashTokenCol: hashToken,
        idClienteCol: idCliente,
        idUsuarioCol: idUsuario,
        escoposCol: escopos,
        expiraEmCol: expiraEm?.toIso8601String(),
        criadoEmCol: criadoEm?.toIso8601String(),
        revogadoCol: revogado,
      };
}
