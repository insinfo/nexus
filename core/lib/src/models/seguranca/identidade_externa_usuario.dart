import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class IdentidadeExternaUsuario implements SerializeBase {
  static const tableName = 'identidades_externas_usuario';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const idUsuarioCol = 'id_usuario';
  static const idUsuarioFqCol = '$fqtb.$idUsuarioCol';
  static const nomeProvedorCol = 'nome_provedor';
  static const nomeProvedorFqCol = '$fqtb.$nomeProvedorCol';
  static const idUsuarioExternoCol = 'id_usuario_externo';
  static const idUsuarioExternoFqCol = '$fqtb.$idUsuarioExternoCol';
  static const detalhesUsuarioProvedorCol = 'detalhes_usuario_provedor';
  static const detalhesUsuarioProvedorFqCol =
      '$fqtb.$detalhesUsuarioProvedorCol';
  static const ativoCol = 'ativo';
  static const ativoFqCol = '$fqtb.$ativoCol';
  static const criadoEmCol = 'criado_em';
  static const criadoEmFqCol = '$fqtb.$criadoEmCol';
  static const atualizadoEmCol = 'atualizado_em';
  static const atualizadoEmFqCol = '$fqtb.$atualizadoEmCol';

  IdentidadeExternaUsuario({
    this.id,
    this.idUsuario,
    this.nomeProvedor,
    this.idUsuarioExterno,
    this.detalhesUsuarioProvedor = const <String, dynamic>{},
    this.ativo = true,
    this.criadoEm,
    this.atualizadoEm,
  });
  int? id;
  int? idUsuario;
  String? nomeProvedor;
  String? idUsuarioExterno;
  Map<String, dynamic> detalhesUsuarioProvedor;
  bool ativo;
  DateTime? criadoEm;
  DateTime? atualizadoEm;
  IdentidadeExternaUsuario clone() {
    return IdentidadeExternaUsuario(
      id: id,
      idUsuario: idUsuario,
      nomeProvedor: nomeProvedor,
      idUsuarioExterno: idUsuarioExterno,
      detalhesUsuarioProvedor: Map<String, dynamic>.from(detalhesUsuarioProvedor),
      ativo: ativo,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm,
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

  factory IdentidadeExternaUsuario.fromMap(Map<String, dynamic> mapa) {
    return IdentidadeExternaUsuario(
      id: mapa[idCol] as int?,
      idUsuario: mapa[idUsuarioCol] as int?,
      nomeProvedor: mapa[nomeProvedorCol] as String?,
      idUsuarioExterno: mapa[idUsuarioExternoCol] as String?,
      detalhesUsuarioProvedor: lerMapa(mapa[detalhesUsuarioProvedorCol]),
      ativo: (mapa[ativoCol] as bool?) ?? true,
      criadoEm: lerDataHora(mapa[criadoEmCol]),
      atualizadoEm: lerDataHora(mapa[atualizadoEmCol]),
    );
  }

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        idCol: id,
        idUsuarioCol: idUsuario,
        nomeProvedorCol: nomeProvedor,
        idUsuarioExternoCol: idUsuarioExterno,
        detalhesUsuarioProvedorCol: detalhesUsuarioProvedor,
        ativoCol: ativo,
        criadoEmCol: criadoEm?.toIso8601String(),
        atualizadoEmCol: atualizadoEm?.toIso8601String(),
      };
}
