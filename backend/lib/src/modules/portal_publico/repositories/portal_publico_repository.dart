import 'package:eloquent/eloquent.dart';
import 'package:essential_core/essential_core.dart';
import 'package:nexus_core/nexus_core.dart';

import '../../catalogo_servicos/repositories/catalogo_servicos_repository.dart';
import '../../../shared/extensions/eloquent.dart';

class PortalPublicoRepository {
  PortalPublicoRepository(this.db, this._catalogoServicosRepository);

  final Connection db;
  final CatalogoServicosRepository _catalogoServicosRepository;

  Future<DadosPaginaInicialPortal> buscarPaginaInicial() async {
    final catalogoFrame = await _catalogoServicosRepository.list();
    final catalogo = catalogoFrame.items
        .map(
          (item) => ItemCatalogoServico.fromResumo(
            item,
            tempoEstimado: _tempoEstimado(item.codigo),
          ),
        )
        .toList(growable: false);

    final noticias = (await listarNoticias()).items;
    final publicacoes = (await listarPublicacoesOficiais()).items;
    final paginas = (await listarPaginasInstitucionais()).items;
    final atalhos = await _listarAtalhos();

    return DadosPaginaInicialPortal(
      tituloPortal: 'Portal Nexus Rio das Ostras',
      subtituloPortal:
          'Servicos digitais, conteudo institucional e publicacoes oficiais sobre a mesma base versionada do municipio.',
      servicoDestaque: _selecionarServicoDestaque(catalogo),
      atalhos: atalhos,
      catalogoServicos: catalogo,
      noticias: noticias,
      paginasInstitucionais: paginas,
      publicacoesOficiais: publicacoes,
    );
  }

  Future<DataFrame<Noticia>> listarNoticias() async {
    final rows = await db
        .table(Noticia.fqtb)
        .orderBy(Noticia.destaqueCol, OrderDir.desc)
        .orderBy(Noticia.publicadoEmCol, OrderDir.desc)
        .get();
    final itens =
        rows.map((row) => Noticia.fromMap(row)).toList(growable: false);
    return DataFrame<Noticia>(items: itens, totalRecords: itens.length);
  }

  Future<DataFrame<PublicacaoOficial>> listarPublicacoesOficiais() async {
    final rows = await db
        .table(PublicacaoOficial.fqtb)
        .where(
          PublicacaoOficial.statusCol,
          Operator.equal,
          StatusPublicacao.publicada.val,
        )
        .orderBy(PublicacaoOficial.publicadoEmCol, OrderDir.desc)
        .get();
    final itens = rows
        .map((row) => PublicacaoOficial.fromMap(row))
        .toList(growable: false);
    return DataFrame<PublicacaoOficial>(
        items: itens, totalRecords: itens.length);
  }

  Future<DataFrame<PaginaInstitucional>> listarPaginasInstitucionais() async {
    final rows = await db
        .table(PaginaInstitucional.fqtb)
        .where(
          PaginaInstitucional.statusCol,
          Operator.equal,
          StatusPublicacao.publicada.val,
        )
        .orderBy(PaginaInstitucional.secaoCol, OrderDir.asc)
        .orderBy(PaginaInstitucional.tituloCol, OrderDir.asc)
        .get();
    final itens = rows
        .map((row) => PaginaInstitucional.fromMap(row))
        .toList(growable: false);
    return DataFrame<PaginaInstitucional>(
        items: itens, totalRecords: itens.length);
  }

  Future<List<AtalhoPortal>> _listarAtalhos() async {
    final rows = await db
        .table(AtalhoPortal.fqtb)
        .orderBy(AtalhoPortal.idCol, OrderDir.asc)
        .get();
    return rows.map((row) => AtalhoPortal.fromMap(row)).toList(growable: false);
  }

  ItemCatalogoServico _selecionarServicoDestaque(
      List<ItemCatalogoServico> catalogo) {
    for (final item in catalogo) {
      if (item.codigo.toLowerCase().contains('salus')) {
        return item;
      }
    }
    if (catalogo.isNotEmpty) {
      return catalogo.first;
    }
    return ItemCatalogoServico(
      id: 'portal-indisponivel',
      codigo: 'INDISPONIVEL',
      titulo: 'Catalogo indisponivel',
      resumo: 'Nenhum servico publicado foi encontrado no momento.',
      categoria: 'plataforma',
      publico: ModoAcesso.interno.label,
    );
  }

  String _tempoEstimado(String codigoServico) {
    if (codigoServico.toLowerCase().contains('salus')) {
      return '15 minutos';
    }
    if (codigoServico.toLowerCase().contains('sigep')) {
      return '10 minutos';
    }
    if (codigoServico.toLowerCase().contains('sequal')) {
      return '12 minutos';
    }
    return '5 a 10 minutos';
  }
}
