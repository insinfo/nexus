import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class UsuarioOrganograma implements SerializeBase {
  static const tableName = 'usuario_organograma';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idUsuarioCol = 'id_usuario';
  static const idUsuarioFqCol = '$fqtb.$idUsuarioCol';
  static const idOrganogramaCol = 'id_organograma';
  static const idOrganogramaFqCol = '$fqtb.$idOrganogramaCol';
  static const principalCol = 'principal';
  static const principalFqCol = '$fqtb.$principalCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';

  UsuarioOrganograma({
    this.id,
    this.idUsuario,
    this.idOrganograma,
    this.principal = false,
    this.criadoEm,
  });
  int? id;
  int? idUsuario;
  int? idOrganograma;
  bool principal;
  DateTime? criadoEm;
  UsuarioOrganograma clone() {
    return UsuarioOrganograma(
      id: id,
      idUsuario: idUsuario,
      idOrganograma: idOrganograma,
      principal: principal,
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

  factory UsuarioOrganograma.fromMap(Map<String, dynamic> mapa) {
    return UsuarioOrganograma(
      id: mapa['id'] as int?,
      idUsuario: mapa['idUsuario'] as int?,
      idOrganograma: mapa['idOrganograma'] as int?,
      principal: (mapa['principal'] as bool?) ?? false,
      criadoEm: lerDataHora(mapa['criadoEm']),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'idUsuario': idUsuario,
        'idOrganograma': idOrganograma,
        'principal': principal,
        'criadoEm': criadoEm?.toIso8601String(),
      };
}
