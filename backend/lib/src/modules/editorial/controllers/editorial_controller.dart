import 'package:nexus_core/nexus_core.dart';
import 'package:shelf/shelf.dart';

import '../../../shared/extensions/request_extension.dart';
import '../../../shared/responses.dart';
import '../repositories/editorial_repository.dart';

class EditorialController {
  static Future<Response> listarNoticias(Request req) async {
    try {
      final repo = req.make<EditorialRepository>();
      final data = await repo.listNoticias();
      return responseDataFrame(data);
    } catch (e, s) {
      print('EditorialController@listarNoticias $e $s');
      return responseError(
        'Falha ao listar noticias editoriais.',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> salvarNoticia(Request req) async {
    try {
      final corpo = await req.bodyAsMap();
      final repo = req.make<EditorialRepository>();
      final noticia = Noticia.fromMap(corpo);
      final salvo = await repo.saveNoticia(noticia);
      return responseJson(salvo.toMap(), statusCode: 201);
    } catch (e, s) {
      print('EditorialController@salvarNoticia $e $s');
      return responseError(
        'Falha ao salvar noticia editorial.',
        exception: e,
        stackTrace: s,
        statusCode: 422,
      );
    }
  }

  static Future<Response> atualizarNoticia(Request req, String id) async {
    try {
      final corpo = await req.bodyAsMap();
      final repo = req.make<EditorialRepository>();
      final noticia = Noticia.fromMap(<String, dynamic>{...corpo, 'id': id});
      final salvo = await repo.saveNoticia(noticia);
      return responseJson(salvo.toMap());
    } catch (e, s) {
      print('EditorialController@atualizarNoticia $e $s');
      return responseError(
        'Falha ao atualizar noticia editorial.',
        exception: e,
        stackTrace: s,
        statusCode: 422,
      );
    }
  }

  static Future<Response> excluirNoticia(Request req, String id) async {
    try {
      final repo = req.make<EditorialRepository>();
      await repo.deleteNoticia(id);
      return responseSuccess(mensagem: 'Noticia excluida com sucesso.');
    } catch (e, s) {
      print('EditorialController@excluirNoticia $e $s');
      return responseError(
        'Falha ao excluir noticia editorial.',
        exception: e,
        stackTrace: s,
        statusCode: 422,
      );
    }
  }

  static Future<Response> listarPublicacoesOficiais(Request req) async {
    try {
      final repo = req.make<EditorialRepository>();
      final data = await repo.listPublicacoesOficiais();
      return responseDataFrame(data);
    } catch (e, s) {
      print('EditorialController@listarPublicacoesOficiais $e $s');
      return responseError(
        'Falha ao listar publicacoes oficiais.',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> salvarPublicacaoOficial(Request req) async {
    try {
      final corpo = await req.bodyAsMap();
      final repo = req.make<EditorialRepository>();
      final publicacao = PublicacaoOficial.fromMap(corpo);
      final salvo = await repo.savePublicacaoOficial(publicacao);
      return responseJson(salvo.toMap(), statusCode: 201);
    } catch (e, s) {
      print('EditorialController@salvarPublicacaoOficial $e $s');
      return responseError(
        'Falha ao salvar publicacao oficial.',
        exception: e,
        stackTrace: s,
        statusCode: 422,
      );
    }
  }

  static Future<Response> atualizarPublicacaoOficial(
    Request req,
    String id,
  ) async {
    try {
      final corpo = await req.bodyAsMap();
      final repo = req.make<EditorialRepository>();
      final publicacao = PublicacaoOficial.fromMap(
        <String, dynamic>{...corpo, 'id': id},
      );
      final salvo = await repo.savePublicacaoOficial(publicacao);
      return responseJson(salvo.toMap());
    } catch (e, s) {
      print('EditorialController@atualizarPublicacaoOficial $e $s');
      return responseError(
        'Falha ao atualizar publicacao oficial.',
        exception: e,
        stackTrace: s,
        statusCode: 422,
      );
    }
  }

  static Future<Response> excluirPublicacaoOficial(
    Request req,
    String id,
  ) async {
    try {
      final repo = req.make<EditorialRepository>();
      await repo.deletePublicacaoOficial(id);
      return responseSuccess(
          mensagem: 'Publicacao oficial excluida com sucesso.');
    } catch (e, s) {
      print('EditorialController@excluirPublicacaoOficial $e $s');
      return responseError(
        'Falha ao excluir publicacao oficial.',
        exception: e,
        stackTrace: s,
        statusCode: 422,
      );
    }
  }

  static Future<Response> listarPaginasInstitucionais(Request req) async {
    try {
      final repo = req.make<EditorialRepository>();
      final data = await repo.listPaginasInstitucionais();
      return responseDataFrame(data);
    } catch (e, s) {
      print('EditorialController@listarPaginasInstitucionais $e $s');
      return responseError(
        'Falha ao listar paginas institucionais.',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> salvarPaginaInstitucional(Request req) async {
    try {
      final corpo = await req.bodyAsMap();
      final repo = req.make<EditorialRepository>();
      final pagina = PaginaInstitucional.fromMap(corpo);
      final salvo = await repo.savePaginaInstitucional(pagina);
      return responseJson(salvo.toMap(), statusCode: 201);
    } catch (e, s) {
      print('EditorialController@salvarPaginaInstitucional $e $s');
      return responseError(
        'Falha ao salvar pagina institucional.',
        exception: e,
        stackTrace: s,
        statusCode: 422,
      );
    }
  }

  static Future<Response> atualizarPaginaInstitucional(
    Request req,
    String id,
  ) async {
    try {
      final corpo = await req.bodyAsMap();
      final repo = req.make<EditorialRepository>();
      final pagina = PaginaInstitucional.fromMap(
        <String, dynamic>{...corpo, 'id': id},
      );
      final salvo = await repo.savePaginaInstitucional(pagina);
      return responseJson(salvo.toMap());
    } catch (e, s) {
      print('EditorialController@atualizarPaginaInstitucional $e $s');
      return responseError(
        'Falha ao atualizar pagina institucional.',
        exception: e,
        stackTrace: s,
        statusCode: 422,
      );
    }
  }

  static Future<Response> excluirPaginaInstitucional(
      Request req, String id) async {
    try {
      final repo = req.make<EditorialRepository>();
      await repo.deletePaginaInstitucional(id);
      return responseSuccess(
          mensagem: 'Pagina institucional excluida com sucesso.');
    } catch (e, s) {
      print('EditorialController@excluirPaginaInstitucional $e $s');
      return responseError(
        'Falha ao excluir pagina institucional.',
        exception: e,
        stackTrace: s,
        statusCode: 422,
      );
    }
  }
}
