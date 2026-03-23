import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class PapelPermissao implements SerializeBase {
  static const tableName = 'papel_permissao';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idPapelCol = 'id_papel';
  static const idPapelFqCol = '$fqtb.$idPapelCol';
  static const idPermissaoCol = 'id_permissao';
  static const idPermissaoFqCol = '$fqtb.$idPermissaoCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';

  PapelPermissao({this.id, this.idPapel, this.idPermissao, this.criadoEm});
  int? id;
  int? idPapel;
  int? idPermissao;
  DateTime? criadoEm;
  PapelPermissao clone() {
    return PapelPermissao(
      id: id,
      idPapel: idPapel,
      idPermissao: idPermissao,
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

  factory PapelPermissao.fromMap(Map<String, dynamic> mapa) {
    return PapelPermissao(
      id: mapa['id'] as int?,
      idPapel: mapa['idPapel'] as int?,
      idPermissao: mapa['idPermissao'] as int?,
      criadoEm: lerDataHora(mapa['criadoEm']),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'idPapel': idPapel,
        'idPermissao': idPermissao,
        'criadoEm': criadoEm?.toIso8601String(),
      };
}
