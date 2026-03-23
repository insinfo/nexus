import 'package:eloquent/eloquent.dart';
import 'package:essential_core/essential_core.dart';
import 'package:nexus_core/nexus_core.dart';

import '../../../shared/extensions/eloquent.dart';
import '../../../shared/utils/identificador_binding_utils.dart';

class EditorialRepository {
  EditorialRepository(this.db);

  final Connection db;

  Future<DataFrame<Noticia>> listNoticias() async {
    final rows = await db
        .table(Noticia.fqtb)
        .select([
          Noticia.idCol,
          Noticia.slugCol,
          Noticia.tituloCol,
          Noticia.resumoCol,
          Noticia.categoriaCol,
          Noticia.publicadoEmCol,
          Noticia.urlImagemCol,
          Noticia.destaqueCol,
        ])
        .orderBy(Noticia.publicadoEmCol, OrderDir.desc)
        .get();

    final items = rows
        .map((item) => Noticia.fromMap(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    return DataFrame<Noticia>(items: items, totalRecords: items.length);
  }

  Future<Noticia> saveNoticia(Noticia noticia) async {
    final int? id = IdentificadorBindingUtils.inteiroOuNull(noticia.id);
    if (id == null || id <= 0) {
      final novoId = await db.table(Noticia.fqtb).insertGetId(
            noticia.toInsertMap(),
            Noticia.idCol,
          ) as int;
      return _findNoticiaById(novoId);
    }

    await db
        .table(Noticia.fqtb)
        .where(Noticia.idCol, Operator.equal, id)
        .update(noticia.toUpdateMap());
    return _findNoticiaById(id);
  }

  Future<void> deleteNoticia(String id) async {
    final noticiaId = _parseIdObrigatorio(id, 'noticia');
    await db
        .table(Noticia.fqtb)
        .where(Noticia.idCol, Operator.equal, noticiaId)
        .delete();
  }

  Future<DataFrame<PublicacaoOficial>> listPublicacoesOficiais() async {
    final rows = await db
        .table(PublicacaoOficial.fqtb)
        .select([
          PublicacaoOficial.idCol,
          PublicacaoOficial.tituloCol,
          PublicacaoOficial.tipoCol,
          PublicacaoOficial.statusCol,
          PublicacaoOficial.codigoReferenciaCol,
          PublicacaoOficial.publicadoEmCol,
          PublicacaoOficial.areaEditorialCol,
          PublicacaoOficial.resumoCol,
        ])
        .orderBy(PublicacaoOficial.publicadoEmCol, OrderDir.desc)
        .get();

    final items = rows
        .map(
          (item) => PublicacaoOficial.fromMap(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
    return DataFrame<PublicacaoOficial>(
      items: items,
      totalRecords: items.length,
    );
  }

  Future<PublicacaoOficial> savePublicacaoOficial(
    PublicacaoOficial publicacao,
  ) async {
    final int? id = IdentificadorBindingUtils.inteiroOuNull(publicacao.id);
    if (id == null || id <= 0) {
      final novoId = await db.table(PublicacaoOficial.fqtb).insertGetId(
            publicacao.toInsertMap(),
            PublicacaoOficial.idCol,
          ) as int;
      return _findPublicacaoOficialById(novoId);
    }

    await db
        .table(PublicacaoOficial.fqtb)
        .where(PublicacaoOficial.idCol, Operator.equal, id)
        .update(publicacao.toUpdateMap());
    return _findPublicacaoOficialById(id);
  }

  Future<void> deletePublicacaoOficial(String id) async {
    final publicacaoId = _parseIdObrigatorio(id, 'publicacao oficial');
    await db
        .table(PublicacaoOficial.fqtb)
        .where(PublicacaoOficial.idCol, Operator.equal, publicacaoId)
        .delete();
  }

  Future<DataFrame<PaginaInstitucional>> listPaginasInstitucionais() async {
    final rows = await db
        .table(PaginaInstitucional.fqtb)
        .select([
          PaginaInstitucional.idCol,
          PaginaInstitucional.tituloCol,
          PaginaInstitucional.slugCol,
          PaginaInstitucional.secaoCol,
          PaginaInstitucional.statusCol,
          PaginaInstitucional.resumoCol,
        ])
        .orderBy(PaginaInstitucional.secaoCol, OrderDir.asc)
        .orderBy(PaginaInstitucional.tituloCol, OrderDir.asc)
        .get();

    final items = rows
        .map(
          (item) => PaginaInstitucional.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
    return DataFrame<PaginaInstitucional>(
      items: items,
      totalRecords: items.length,
    );
  }

  Future<PaginaInstitucional> savePaginaInstitucional(
    PaginaInstitucional pagina,
  ) async {
    final int? id = IdentificadorBindingUtils.inteiroOuNull(pagina.id);
    if (id == null || id <= 0) {
      final novoId = await db.table(PaginaInstitucional.fqtb).insertGetId(
            pagina.toInsertMap(),
            PaginaInstitucional.idCol,
          ) as int;
      return _findPaginaInstitucionalById(novoId);
    }

    await db
        .table(PaginaInstitucional.fqtb)
        .where(PaginaInstitucional.idCol, Operator.equal, id)
        .update(pagina.toUpdateMap());
    return _findPaginaInstitucionalById(id);
  }

  Future<void> deletePaginaInstitucional(String id) async {
    final paginaId = _parseIdObrigatorio(id, 'pagina institucional');
    await db
        .table(PaginaInstitucional.fqtb)
        .where(PaginaInstitucional.idCol, Operator.equal, paginaId)
        .delete();
  }

  Future<Noticia> _findNoticiaById(int id) async {
    final row = await db
        .table(Noticia.fqtb)
        .where(Noticia.idCol, Operator.equal, id)
        .first();
    if (row == null) {
      throw StateError('Noticia nao encontrada: $id');
    }
    return Noticia.fromMap(Map<String, dynamic>.from(row));
  }

  Future<PublicacaoOficial> _findPublicacaoOficialById(int id) async {
    final row = await db
        .table(PublicacaoOficial.fqtb)
        .where(PublicacaoOficial.idCol, Operator.equal, id)
        .first();
    if (row == null) {
      throw StateError('Publicacao oficial nao encontrada: $id');
    }
    return PublicacaoOficial.fromMap(Map<String, dynamic>.from(row));
  }

  Future<PaginaInstitucional> _findPaginaInstitucionalById(int id) async {
    final row = await db
        .table(PaginaInstitucional.fqtb)
        .where(PaginaInstitucional.idCol, Operator.equal, id)
        .first();
    if (row == null) {
      throw StateError('Pagina institucional nao encontrada: $id');
    }
    return PaginaInstitucional.fromMap(Map<String, dynamic>.from(row));
  }

  int _parseIdObrigatorio(String valor, String entidade) {
    final id = IdentificadorBindingUtils.inteiroOuNull(valor);
    if (id == null || id <= 0) {
      throw ArgumentError('Identificador invalido para $entidade: $valor');
    }
    return id;
  }
}
