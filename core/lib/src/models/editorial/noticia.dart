import 'package:essential_core/essential_core.dart';

import '../suporte/modelo_utils.dart';

class Noticia implements SerializeBase {
  static const tableName = 'noticia';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const slugCol = 'slug';
  static const slugFqCol = '$fqtb.$slugCol';
  static const tituloCol = 'titulo';
  static const tituloFqCol = '$fqtb.$tituloCol';
  static const resumoCol = 'resumo';
  static const resumoFqCol = '$fqtb.$resumoCol';
  static const categoriaCol = 'categoria';
  static const categoriaFqCol = '$fqtb.$categoriaCol';
  static const publicadoEmCol = 'publicado_em';
  static const publicadoEmFqCol = '$fqtb.$publicadoEmCol';
  static const urlImagemCol = 'url_imagem';
  static const urlImagemFqCol = '$fqtb.$urlImagemCol';
  static const destaqueCol = 'destaque';
  static const destaqueFqCol = '$fqtb.$destaqueCol';

  Noticia({
    required this.id,
    required this.slug,
    required this.titulo,
    required this.resumo,
    required this.categoria,
    required this.publicadoEm,
    this.urlImagem,
    this.destaque = false,
  });
  String id;
  String slug;
  String titulo;
  String resumo;
  String categoria;
  DateTime publicadoEm;
  String? urlImagem;
  bool destaque;
  Noticia clone() {
    return Noticia(
      id: id,
      slug: slug,
      titulo: titulo,
      resumo: resumo,
      categoria: categoria,
      publicadoEm: publicadoEm,
      urlImagem: urlImagem,
      destaque: destaque,
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

  factory Noticia.fromMap(Map<String, dynamic> mapa) {
    return Noticia(
      id: mapa['id']?.toString() ?? '',
      slug: mapa['slug'] as String,
      titulo: mapa['titulo'] as String,
      resumo: mapa['resumo'] as String,
      categoria: mapa['categoria'] as String,
      publicadoEm: lerDataHora(mapa['publicado_em'])!,
      urlImagem: mapa['url_imagem'] as String?,
      destaque: (mapa['destaque'] as bool?) ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'slug': slug,
      'titulo': titulo,
      'resumo': resumo,
      'categoria': categoria,
      'publicado_em': publicadoEm.toIso8601String(),
      'url_imagem': urlImagem,
      'destaque': destaque,
    };
  }
}
