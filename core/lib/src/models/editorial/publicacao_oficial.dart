import 'package:essential_core/essential_core.dart';

import '../comum/enums_nexus.dart';
import '../suporte/modelo_utils.dart';

class PublicacaoOficial implements SerializeBase {
  static const tableName = 'publicacao_oficial';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const tituloCol = 'titulo';
  static const tituloFqCol = '$fqtb.$tituloCol';
  static const tipoCol = 'tipo';
  static const tipoFqCol = '$fqtb.$tipoCol';
  static const statusCol = 'status';
  static const statusFqCol = '$fqtb.$statusCol';
  static const codigoReferenciaCol = 'codigo_referencia';
  static const codigoReferenciaFqCol = '$fqtb.$codigoReferenciaCol';
  static const publicadoEmCol = 'publicado_em';
  static const publicadoEmFqCol = '$fqtb.$publicadoEmCol';
  static const areaEditorialCol = 'area_editorial';
  static const areaEditorialFqCol = '$fqtb.$areaEditorialCol';
  static const resumoCol = 'resumo';
  static const resumoFqCol = '$fqtb.$resumoCol';

  PublicacaoOficial({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.status,
    required this.codigoReferencia,
    required this.publicadoEm,
    required this.areaEditorial,
    this.resumo,
  });
  String id;
  String titulo;
  TipoPublicacao tipo;
  StatusPublicacao status;
  String codigoReferencia;
  DateTime publicadoEm;
  String areaEditorial;
  String? resumo;
  PublicacaoOficial clone() {
    return PublicacaoOficial(
      id: id,
      titulo: titulo,
      tipo: tipo,
      status: status,
      codigoReferencia: codigoReferencia,
      publicadoEm: publicadoEm,
      areaEditorial: areaEditorial,
      resumo: resumo,
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

  factory PublicacaoOficial.fromMap(Map<String, dynamic> mapa) {
    return PublicacaoOficial(
      id: mapa['id']?.toString() ?? '',
      titulo: mapa['titulo'] as String,
      tipo: TipoPublicacao.parse(mapa['tipo'] as String),
      status: StatusPublicacao.parse(mapa['status'] as String),
      codigoReferencia: mapa['codigo_referencia'] as String,
      publicadoEm: lerDataHora(mapa['publicado_em'])!,
      areaEditorial: mapa['area_editorial'] as String,
      resumo: mapa['resumo'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'titulo': titulo,
      'tipo': tipo.val,
      'status': status.val,
      'codigo_referencia': codigoReferencia,
      'publicado_em': publicadoEm.toIso8601String(),
      'area_editorial': areaEditorial,
      'resumo': resumo,
    };
  }
}
