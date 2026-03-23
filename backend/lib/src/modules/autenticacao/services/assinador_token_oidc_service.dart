import 'dart:convert';

import 'package:jose/jose.dart';
import 'package:nexus_core/nexus_core.dart';

import '../../../shared/app_config.dart';

class AssinadorTokenOidcService {
  static AssinadorTokenOidcService? _instancia;

  factory AssinadorTokenOidcService(AppConfig config) {
    _instancia ??= AssinadorTokenOidcService._(config);
    return _instancia!;
  }

  AssinadorTokenOidcService._(AppConfig config)
      : _jwkPrivada = _carregarChave(config);

  final JsonWebKey _jwkPrivada;

  ConjuntoChavesJsonWeb obterConjuntoChaves() {
    return ConjuntoChavesJsonWeb(
      chaves: <Map<String, dynamic>>[_jwkPublicaJson()],
    );
  }

  String get keyId => _jwkPrivada.keyId ?? 'nexus-rs256';

  String assinarJwt(Map<String, dynamic> claims) {
    final builder = JsonWebSignatureBuilder()
      ..jsonContent = claims
      ..setProtectedHeader('typ', 'JWT')
      ..setProtectedHeader('kid', keyId)
      ..addRecipient(_jwkPrivada, algorithm: 'RS256');
    return builder.build().toCompactSerialization();
  }

  static JsonWebKey _carregarChave(AppConfig config) {
    final jwkJson = config.jwkPrivadaOidcJson;
    if (jwkJson != null && jwkJson.trim().isNotEmpty) {
      return JsonWebKey.fromJson(
        Map<String, dynamic>.from(jsonDecode(jwkJson) as Map),
      );
    }

    final gerada = JsonWebKey.generate('RS256', keyBitLength: 2048);
    final json = gerada.toJson();
    json['kid'] = json['kid'] ?? 'nexus-rs256';
    json['use'] = json['use'] ?? 'sig';
    json['alg'] = json['alg'] ?? 'RS256';
    return JsonWebKey.fromJson(Map<String, dynamic>.from(json));
  }

  Map<String, dynamic> _jwkPublicaJson() {
    final json = Map<String, dynamic>.from(_jwkPrivada.toJson());
    json.remove('d');
    json.remove('p');
    json.remove('q');
    json.remove('dp');
    json.remove('dq');
    json.remove('qi');
    json['kid'] = keyId;
    json['use'] = json['use'] ?? 'sig';
    json['alg'] = json['alg'] ?? 'RS256';
    return json;
  }
}
