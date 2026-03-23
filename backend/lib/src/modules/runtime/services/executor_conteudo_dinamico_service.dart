import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:nexus_core/nexus_core.dart';

class ExecutorConteudoDinamicoService {
  const ExecutorConteudoDinamicoService();

  Future<Map<String, dynamic>> executar({
    required NoFluxoDto no,
    required Map<String, dynamic> contexto,
  }) async {
    final dados = no.dados as DadosNoConteudoDinamico;
    final cliente = HttpClient();
    final timeout = Duration(milliseconds: dados.timeoutMs ?? 10000);
    final payloadInterpolado = dados.modeloPayload == null
        ? null
        : _interpolarTexto(dados.modeloPayload!, contexto);
    final urlResolvida = _interpolarTexto(dados.url, contexto);

    try {
      final request = await cliente
          .openUrl(dados.metodo.toUpperCase(), Uri.parse(urlResolvida))
          .timeout(timeout);

      for (final entry in dados.cabecalhos.entries) {
        request.headers.set(entry.key, _interpolarTexto(entry.value, contexto));
      }

      if (payloadInterpolado != null && payloadInterpolado.trim().isNotEmpty) {
        request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        request.write(payloadInterpolado);
      }

      final response = await request.close().timeout(timeout);
      final responseBody =
          await utf8.decoder.bind(response).join().timeout(timeout);
      final cabecalhos = <String, dynamic>{};
      response.headers.forEach((nome, valores) {
        cabecalhos[nome] = valores;
      });

      return <String, dynamic>{
        'sucesso': response.statusCode >= 200 && response.statusCode < 300,
        'status_code': response.statusCode,
        'tipo_erro': null,
        'mensagem_erro': null,
        'requisicao': <String, dynamic>{
          'metodo': dados.metodo.toUpperCase(),
          'url': urlResolvida,
          'payload': _lerBodySerializado(payloadInterpolado),
          'timeout_ms': timeout.inMilliseconds,
        },
        'resposta': <String, dynamic>{
          'cabecalhos': cabecalhos,
          'corpo': _lerBodySerializado(responseBody),
        },
      };
    } on TimeoutException catch (error) {
      return _resultadoErro(
        tipoErro: 'timeout',
        mensagemErro: error.message ?? 'Tempo limite excedido na integracao.',
        urlResolvida: urlResolvida,
        metodo: dados.metodo,
        payloadInterpolado: payloadInterpolado,
        timeout: timeout,
      );
    } on SocketException catch (error) {
      return _resultadoErro(
        tipoErro: 'conexao',
        mensagemErro: error.message,
        urlResolvida: urlResolvida,
        metodo: dados.metodo,
        payloadInterpolado: payloadInterpolado,
        timeout: timeout,
      );
    } on HttpException catch (error) {
      return _resultadoErro(
        tipoErro: 'http',
        mensagemErro: error.message,
        urlResolvida: urlResolvida,
        metodo: dados.metodo,
        payloadInterpolado: payloadInterpolado,
        timeout: timeout,
      );
    } catch (error) {
      return _resultadoErro(
        tipoErro: 'execucao',
        mensagemErro: error.toString(),
        urlResolvida: urlResolvida,
        metodo: dados.metodo,
        payloadInterpolado: payloadInterpolado,
        timeout: timeout,
      );
    } finally {
      cliente.close(force: true);
    }
  }

  Map<String, dynamic> _resultadoErro({
    required String tipoErro,
    required String mensagemErro,
    required String urlResolvida,
    required String metodo,
    required String? payloadInterpolado,
    required Duration timeout,
  }) {
    return <String, dynamic>{
      'sucesso': false,
      'status_code': null,
      'tipo_erro': tipoErro,
      'mensagem_erro': mensagemErro,
      'requisicao': <String, dynamic>{
        'metodo': metodo.toUpperCase(),
        'url': urlResolvida,
        'payload': _lerBodySerializado(payloadInterpolado),
        'timeout_ms': timeout.inMilliseconds,
      },
      'resposta': const <String, dynamic>{
        'cabecalhos': <String, dynamic>{},
        'corpo': null,
      },
    };
  }

  dynamic _lerBodySerializado(String? body) {
    if (body == null || body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _interpolarTexto(String valor, Map<String, dynamic> contexto) {
    return valor.replaceAllMapped(
      RegExp(r'\{\{\s*([^}]+?)\s*\}\}'),
      (match) {
        final caminho = match.group(1);
        if (caminho == null || caminho.isEmpty) {
          return '';
        }

        final resolvido = _resolverCaminho(contexto, caminho.split('.'));
        return resolvido?.toString() ?? '';
      },
    );
  }

  dynamic _resolverCaminho(dynamic atual, List<String> partes) {
    dynamic cursor = atual;
    for (final parte in partes) {
      if (cursor is Map && cursor.containsKey(parte)) {
        cursor = cursor[parte];
        continue;
      }
      return null;
    }
    return cursor;
  }
}
