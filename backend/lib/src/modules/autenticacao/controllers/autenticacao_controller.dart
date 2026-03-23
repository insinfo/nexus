import 'package:shelf/shelf.dart';
import 'package:nexus_core/nexus_core.dart';

import '../../../shared/extensions/request_extension.dart';
import '../../../shared/responses.dart';
import '../services/autenticacao_exception.dart';
import '../services/autenticacao_port.dart';

class AutenticacaoController {
  static Future<Response> cadastrar(Request req) async {
    try {
      final corpo = await req.bodyAsMap();
      final service = req.make<AutenticacaoPort>();
      final resultado = await service.cadastrar(
        RequisicaoCadastroUsuario.fromMap(corpo),
        enderecoIp: _enderecoIp(req),
        userAgent: req.headers['user-agent'],
      );
      return responseJson(resultado.toMap(), statusCode: 201);
    } on AutenticacaoException catch (e) {
      return responseError(e.mensagem, statusCode: e.statusCode);
    } catch (e, s) {
      print('AutenticacaoController@cadastrar $e $s');
      return responseError(
        'Falha ao cadastrar usuario.',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> login(Request req) async {
    try {
      final corpo = await req.bodyAsMap();
      final service = req.make<AutenticacaoPort>();
      final resultado = await service.login(
        RequisicaoLoginUsuario.fromMap(corpo),
        enderecoIp: _enderecoIp(req),
        userAgent: req.headers['user-agent'],
      );
      return responseJson(resultado.toMap());
    } on AutenticacaoException catch (e) {
      return responseError(e.mensagem, statusCode: e.statusCode);
    } catch (e, s) {
      print('AutenticacaoController@login $e $s');
      return responseError(
        'Falha ao autenticar usuario.',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> solicitarRedefinicaoSenha(Request req) async {
    try {
      final corpo = await req.bodyAsMap();
      final service = req.make<AutenticacaoPort>();
      final resultado = await service.solicitarRedefinicaoSenha(
        RequisicaoSolicitarRedefinicaoSenha.fromMap(corpo),
        enderecoIp: _enderecoIp(req),
      );
      return responseJson(resultado.toMap());
    } on AutenticacaoException catch (e) {
      return responseError(e.mensagem, statusCode: e.statusCode);
    } catch (e, s) {
      print('AutenticacaoController@solicitarRedefinicaoSenha $e $s');
      return responseError(
        'Falha ao solicitar redefinicao de senha.',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static Future<Response> redefinirSenha(Request req) async {
    try {
      final corpo = await req.bodyAsMap();
      final service = req.make<AutenticacaoPort>();
      final resultado = await service.redefinirSenha(
        RequisicaoRedefinirSenha.fromMap(corpo),
        enderecoIp: _enderecoIp(req),
        userAgent: req.headers['user-agent'],
      );
      return responseJson(resultado.toMap());
    } on AutenticacaoException catch (e) {
      return responseError(e.mensagem, statusCode: e.statusCode);
    } catch (e, s) {
      print('AutenticacaoController@redefinirSenha $e $s');
      return responseError(
        'Falha ao redefinir a senha.',
        exception: e,
        stackTrace: s,
        statusCode: 500,
      );
    }
  }

  static String? _enderecoIp(Request req) {
    final forwarded = req.headers['x-forwarded-for'];
    if (forwarded != null && forwarded.trim().isNotEmpty) {
      return forwarded.split(',').first.trim();
    }
    final realIp = req.headers['x-real-ip'];
    if (realIp != null && realIp.trim().isNotEmpty) {
      return realIp.trim();
    }
    return null;
  }
}