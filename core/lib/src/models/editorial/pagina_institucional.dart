import 'package:essential_core/essential_core.dart';

import '../comum/enums_nexus.dart';

class PaginaInstitucional implements SerializeBase {
  static const tableName = 'pagina_institucional';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const tituloCol = 'titulo';
  static const tituloFqCol = '$fqtb.$tituloCol';
  static const slugCol = 'slug';
  static const slugFqCol = '$fqtb.$slugCol';
  static const secaoCol = 'secao';
  static const secaoFqCol = '$fqtb.$secaoCol';
  static const statusCol = 'status';
  static const statusFqCol = '$fqtb.$statusCol';
  static const resumoCol = 'resumo';
  static const resumoFqCol = '$fqtb.$resumoCol';

  PaginaInstitucional({
    required this.id,
    required this.titulo,
    required this.slug,
    required this.secao,
    required this.status,
    this.resumo,
  });
  String id;
  String titulo;
  String slug;
  String secao;
  StatusPublicacao status;
  String? resumo;
  PaginaInstitucional clone() {
    return PaginaInstitucional(
      id: id,
      titulo: titulo,
      slug: slug,
      secao: secao,
      status: status,
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

  factory PaginaInstitucional.fromMap(Map<String, dynamic> mapa) {
    return PaginaInstitucional(
      id: mapa['id']?.toString() ?? '',
      titulo: mapa['titulo'] as String,
      slug: mapa['slug'] as String,
      secao: mapa['secao'] as String,
      status: StatusPublicacao.parse(mapa['status'] as String),
      resumo: mapa['resumo'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'titulo': titulo,
      'slug': slug,
      'secao': secao,
      'status': status.val,
      'resumo': resumo,
    };
  }
}
