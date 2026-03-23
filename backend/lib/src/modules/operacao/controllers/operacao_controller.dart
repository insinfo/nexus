import 'package:nexus_core/nexus_core.dart';
import 'package:shelf/shelf.dart';

import '../../../shared/extensions/request_extension.dart';
import '../../../shared/responses.dart';
import '../services/operacao_port.dart';

class OperacaoController {
  static Future<Response> listarSubmissoes(Request req) async {
    try {
      final service = req.make<OperacaoPort>();
      final data = await service.listarSubmissoes();
      return responseDataFrame(data);
    } catch (e, s) {
      print('OperacaoController@listarSubmissoes $e $s');
      return responseError(
        'Falha ao listar a fila operacional',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> detalharSubmissao(
      Request req, String idSubmissao) async {
    try {
      final service = req.make<OperacaoPort>();
      final item = await service.detalharSubmissao(idSubmissao);
      if (item == null) {
        return responseError('Submissão não encontrada: $idSubmissao',
            statusCode: 404);
      }
      return responseJson(item);
    } catch (e, s) {
      print('OperacaoController@detalharSubmissao $e $s');
      return responseError(
        'Falha ao detalhar a submissão operacional',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> transicionarSubmissao(Request req) async {
    try {
      final corpo = await req.bodyAsMap();
      final requisicao = RequisicaoTransicaoSubmissao.fromMap(corpo);
      final service = req.make<OperacaoPort>();
      final resultado = await service.transicionarSubmissao(requisicao);
      return responseJson(resultado.toMap());
    } catch (e, s) {
      print('OperacaoController@transicionarSubmissao $e $s');
      return responseError(
        'Falha ao atualizar o status da submissão',
        exception: e,
        stackTrace: s,
        statusCode: 422,
      );
    }
  }

  static Future<Response> executarClassificacao(Request req) async {
    try {
      final corpo = await req.bodyAsMap();
      final requisicao = RequisicaoExecutarClassificacao.fromMap(corpo);
      final service = req.make<OperacaoPort>();
      final resultado = await service.executarClassificacao(requisicao);
      return responseJson(resultado.toMap(), statusCode: 201);
    } catch (e, s) {
      print('OperacaoController@executarClassificacao $e $s');
      return responseError(
        'Falha ao executar a classificação auditável',
        exception: e,
        stackTrace: s,
        statusCode: 422,
      );
    }
  }

  static Future<Response> listarResultadosClassificacao(
      Request req, String idServico) async {
    try {
      final service = req.make<OperacaoPort>();
      final data = await service.listarResultadosClassificacao(idServico);
      return responseDataFrame(data);
    } catch (e, s) {
      print('OperacaoController@listarResultadosClassificacao $e $s');
      return responseError(
        'Falha ao listar os resultados de classificação',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }
}
