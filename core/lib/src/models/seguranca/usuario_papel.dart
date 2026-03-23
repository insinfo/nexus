import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class UsuarioPapel implements SerializeBase {
  static const tableName = 'usuario_papel';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idUsuarioCol = 'id_usuario';
  static const idUsuarioFqCol = '$fqtb.$idUsuarioCol';
  static const idPapelCol = 'id_papel';
  static const idPapelFqCol = '$fqtb.$idPapelCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';

  UsuarioPapel({this.id, this.idUsuario, this.idPapel, this.criadoEm});
  int? id;
  int? idUsuario;
  int? idPapel;
  DateTime? criadoEm;
  UsuarioPapel clone() {
    return UsuarioPapel(
      id: id,
      idUsuario: idUsuario,
      idPapel: idPapel,
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

  factory UsuarioPapel.fromMap(Map<String, dynamic> mapa) {
    return UsuarioPapel(
      id: mapa['id'] as int?,
      idUsuario: mapa['idUsuario'] as int?,
      idPapel: mapa['idPapel'] as int?,
      criadoEm: lerDataHora(mapa['criadoEm']),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'idUsuario': idUsuario,
        'idPapel': idPapel,
        'criadoEm': criadoEm?.toIso8601String(),
      };
}
