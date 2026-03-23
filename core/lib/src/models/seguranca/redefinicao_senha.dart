import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class RedefinicaoSenha implements SerializeBase {
  static const tableName = 'redefinicoes_senha';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idUsuarioCol = 'id_usuario';
  static const idUsuarioFqCol = '$fqtb.$idUsuarioCol';
  static const hashTokenCol = 'hash_token';
  static const hashTokenFqCol = '$fqtb.$hashTokenCol';
  static const expiraEmCol = 'expira_em';
  static const expiraEmFqCol = '$fqtb.$expiraEmCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';

  RedefinicaoSenha({
    this.id,
    this.idUsuario,
    this.hashToken,
    this.expiraEm,
    this.criadoEm,
  });
  int? id;
  int? idUsuario;
  String? hashToken;
  DateTime? expiraEm;
  DateTime? criadoEm;
  RedefinicaoSenha clone() {
    return RedefinicaoSenha(
      id: id,
      idUsuario: idUsuario,
      hashToken: hashToken,
      expiraEm: expiraEm,
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

  factory RedefinicaoSenha.fromMap(Map<String, dynamic> mapa) {
    return RedefinicaoSenha(
      id: mapa[idCol] as int?,
      idUsuario: mapa[idUsuarioCol] as int?,
      hashToken: mapa[hashTokenCol] as String?,
      expiraEm: lerDataHora(mapa[expiraEmCol]),
      criadoEm: lerDataHora(mapa[criadoEmCol]),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
      idCol: id,
      idUsuarioCol: idUsuario,
      hashTokenCol: hashToken,
      expiraEmCol: expiraEm?.toIso8601String(),
      criadoEmCol: criadoEm?.toIso8601String(),
      };
}
