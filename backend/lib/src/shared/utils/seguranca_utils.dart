import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class SegurancaUtils {
  static const int _iteracoesPadrao = 100000;
  static const int _tamanhoSalt = 16;
  static const int _tamanhoChave = 32;
  static final Random _random = Random.secure();

  static String gerarHashSenha(String senha, {int iteracoes = _iteracoesPadrao}) {
    final salt = _gerarBytes(_tamanhoSalt);
    final derivada = _pbkdf2Sha256(
      utf8.encode(senha),
      salt,
      iteracoes,
      _tamanhoChave,
    );
    return 'pbkdf2_sha256:$iteracoes:${_base64UrlSemPadding(salt)}:${_base64UrlSemPadding(derivada)}';
  }

  static bool validarSenha(String senha, String hashPersistido) {
    final partes = hashPersistido.split(':');
    if (partes.length != 4 || partes.first != 'pbkdf2_sha256') {
      return false;
    }

    final iteracoes = int.tryParse(partes[1]);
    if (iteracoes == null || iteracoes <= 0) {
      return false;
    }

    final salt = _decodeBase64Url(partes[2]);
    final hashEsperado = _decodeBase64Url(partes[3]);
    final hashAtual = _pbkdf2Sha256(
      utf8.encode(senha),
      salt,
      iteracoes,
      hashEsperado.length,
    );
    return _comparacaoConstante(hashEsperado, hashAtual);
  }

  static String gerarTokenSeguro({int tamanho = 32}) {
    return _base64UrlSemPadding(_gerarBytes(tamanho));
  }

  static String gerarHashToken(String token) {
    return sha256.convert(utf8.encode(token)).toString();
  }

  static String gerarHashSha256Base64Url(String valor) {
    return base64Url
        .encode(sha256.convert(utf8.encode(valor)).bytes)
        .replaceAll('=', '');
  }

  static bool validarPkce({
    required String codeVerifier,
    required String codeChallenge,
    required String metodo,
  }) {
    final metodoNormalizado = metodo.trim().toUpperCase();
    if (metodoNormalizado == 'S256') {
      return gerarHashSha256Base64Url(codeVerifier) == codeChallenge;
    }
    if (metodoNormalizado == 'PLAIN') {
      return codeVerifier == codeChallenge;
    }
    return false;
  }

  static List<int> _pbkdf2Sha256(
    List<int> senha,
    List<int> salt,
    int iteracoes,
    int tamanhoChave,
  ) {
    const tamanhoHash = 32;
    final quantidadeBlocos = (tamanhoChave / tamanhoHash).ceil();
    final resultado = <int>[];
    final hmac = Hmac(sha256, senha);

    for (var bloco = 1; bloco <= quantidadeBlocos; bloco++) {
      final indiceBloco = <int>[
        (bloco >> 24) & 0xff,
        (bloco >> 16) & 0xff,
        (bloco >> 8) & 0xff,
        bloco & 0xff,
      ];

      var u = hmac.convert(<int>[...salt, ...indiceBloco]).bytes;
      final t = List<int>.from(u);

      for (var i = 1; i < iteracoes; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < t.length; j++) {
          t[j] ^= u[j];
        }
      }

      resultado.addAll(t);
    }

    return resultado.sublist(0, tamanhoChave);
  }

  static List<int> _gerarBytes(int tamanho) {
    return List<int>.generate(tamanho, (_) => _random.nextInt(256));
  }

  static String _base64UrlSemPadding(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static List<int> _decodeBase64Url(String valor) {
    final resto = valor.length % 4;
    final padding = resto == 0 ? '' : '=' * (4 - resto);
    return base64Url.decode('$valor$padding');
  }

  static bool _comparacaoConstante(List<int> a, List<int> b) {
    if (a.length != b.length) {
      return false;
    }
    var diferenca = 0;
    for (var i = 0; i < a.length; i++) {
      diferenca |= a[i] ^ b[i];
    }
    return diferenca == 0;
  }
}