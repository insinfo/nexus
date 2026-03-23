import 'package:essential_core/essential_core.dart';

import '../editorial/noticia.dart';
import '../editorial/pagina_institucional.dart';
import '../editorial/publicacao_oficial.dart';
import '../suporte/modelo_utils.dart';
import 'atalho_portal.dart';
import 'item_catalogo_servico.dart';

class DadosPaginaInicialPortal implements SerializeBase {
  static const tableName = 'dados_pagina_inicial_portal';
  static const fqtb = 'public.$tableName';
  static const idCol = 'id';
  static const idFqCol = '$fqtb.$idCol';
  static const tituloPortalCol = 'titulo_portal';
  static const tituloPortalFqCol = '$fqtb.$tituloPortalCol';
  static const subtituloPortalCol = 'subtitulo_portal';
  static const subtituloPortalFqCol = '$fqtb.$subtituloPortalCol';
  static const servicoDestaqueCol = 'servico_destaque';
  static const servicoDestaqueFqCol = '$fqtb.$servicoDestaqueCol';
  static const atalhosCol = 'atalhos';
  static const atalhosFqCol = '$fqtb.$atalhosCol';
  static const catalogoServicosCol = 'catalogo_servicos';
  static const catalogoServicosFqCol = '$fqtb.$catalogoServicosCol';
  static const noticiasCol = 'noticias';
  static const noticiasFqCol = '$fqtb.$noticiasCol';
  static const paginasInstitucionaisCol = 'paginas_institucionais';
  static const paginasInstitucionaisFqCol = '$fqtb.$paginasInstitucionaisCol';
  static const publicacoesOficiaisCol = 'publicacoes_oficiais';
  static const publicacoesOficiaisFqCol = '$fqtb.$publicacoesOficiaisCol';

  DadosPaginaInicialPortal({
    required this.tituloPortal,
    required this.subtituloPortal,
    required this.servicoDestaque,
    this.atalhos = const <AtalhoPortal>[],
    this.catalogoServicos = const <ItemCatalogoServico>[],
    this.noticias = const <Noticia>[],
    this.paginasInstitucionais = const <PaginaInstitucional>[],
    this.publicacoesOficiais = const <PublicacaoOficial>[],
  });
  String tituloPortal;
  String subtituloPortal;
  ItemCatalogoServico servicoDestaque;
  List<AtalhoPortal> atalhos;
  List<ItemCatalogoServico> catalogoServicos;
  List<Noticia> noticias;
  List<PaginaInstitucional> paginasInstitucionais;
  List<PublicacaoOficial> publicacoesOficiais;
  DadosPaginaInicialPortal clone() {
    return DadosPaginaInicialPortal(
      tituloPortal: tituloPortal,
      subtituloPortal: subtituloPortal,
      servicoDestaque: servicoDestaque,
      atalhos: atalhos,
      catalogoServicos: catalogoServicos,
      noticias: noticias,
      paginasInstitucionais: paginasInstitucionais,
      publicacoesOficiais: publicacoesOficiais,
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

  factory DadosPaginaInicialPortal.fromMap(Map<String, dynamic> mapa) {
    return DadosPaginaInicialPortal(
      tituloPortal: mapa['titulo_portal'] as String,
      subtituloPortal: mapa['subtitulo_portal'] as String,
      servicoDestaque:
          ItemCatalogoServico.fromMap(lerMapa(mapa['servico_destaque'])),
      atalhos: mapearLista(mapa['atalhos'], AtalhoPortal.fromMap),
      catalogoServicos:
          mapearLista(mapa['catalogo_servicos'], ItemCatalogoServico.fromMap),
      noticias: mapearLista(mapa['noticias'], Noticia.fromMap),
      paginasInstitucionais: mapearLista(
        mapa['paginas_institucionais'],
        PaginaInstitucional.fromMap,
      ),
      publicacoesOficiais: mapearLista(
        mapa['publicacoes_oficiais'],
        PublicacaoOficial.fromMap,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'titulo_portal': tituloPortal,
      'subtitulo_portal': subtituloPortal,
      'servico_destaque': servicoDestaque.toMap(),
      'atalhos': serializarLista(atalhos),
      'catalogo_servicos': serializarLista(catalogoServicos),
      'noticias': serializarLista(noticias),
      'paginas_institucionais': serializarLista(paginasInstitucionais),
      'publicacoes_oficiais': serializarLista(publicacoesOficiais),
    };
  }
}
