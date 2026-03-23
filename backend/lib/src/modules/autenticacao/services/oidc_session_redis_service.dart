import 'dart:convert';

import 'package:redis/redis.dart';

import '../../../shared/app_config.dart';
import 'autenticacao_exception.dart';

class OidcSessionRedisService {
  OidcSessionRedisService(this.config);

  final AppConfig config;

  Command? _command;

  Future<void> salvarSessao({
    required String sessionState,
    required Map<String, dynamic> dados,
    required Duration ttl,
  }) async {
    final command = await _obterCommand();
    await command.send_object(<Object?>[
      'SETEX',
      _chave(sessionState),
      ttl.inSeconds,
      jsonEncode(dados),
    ]);
  }

  Future<Map<String, dynamic>?> obterSessao(String sessionState) async {
    final command = await _obterCommand();
    final resposta = await command.send_object(<Object?>[
      'GET',
      _chave(sessionState),
    ]);
    if (resposta == null) {
      return null;
    }
    if (resposta is! String || resposta.trim().isEmpty) {
      return null;
    }
    return Map<String, dynamic>.from(jsonDecode(resposta) as Map);
  }

  Future<void> removerSessao(String sessionState) async {
    final command = await _obterCommand();
    await command.send_object(<Object?>['DEL', _chave(sessionState)]);
  }

  String _chave(String sessionState) {
    return '${config.redisOidcSessionPrefix}${sessionState.trim()}';
  }

  Future<Command> _obterCommand() async {
    if (_command != null) {
      return _command!;
    }

    try {
      final connection = RedisConnection();
      final command = config.redisUseTls
          ? await connection.connectSecure(config.redisHost, config.redisPort)
          : await connection.connect(config.redisHost, config.redisPort);

      if (config.redisUsername.isNotEmpty && config.redisPassword.isNotEmpty) {
        await command.send_object(<Object?>[
          'AUTH',
          config.redisUsername,
          config.redisPassword,
        ]);
      } else if (config.redisPassword.isNotEmpty) {
        await command.send_object(<Object?>['AUTH', config.redisPassword]);
      }

      if (config.redisDatabase > 0) {
        await command.send_object(<Object?>['SELECT', config.redisDatabase]);
      }

      _command = command;
      return command;
    } catch (e) {
      _command = null;
      throw AutenticacaoException(
        'Falha ao conectar no Redis para compartilhar sessoes OIDC entre isolados: $e',
        statusCode: 503,
      );
    }
  }
}
