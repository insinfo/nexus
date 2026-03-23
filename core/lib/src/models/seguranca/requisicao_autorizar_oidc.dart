import 'package:essential_core/essential_core.dart';

class RequisicaoAutorizarOidc implements SerializeBase {
  RequisicaoAutorizarOidc({
    this.responseType = 'code',
    this.clientId = '',
    this.redirectUri = '',
    this.escopos = const <String>[],
    this.state,
    this.nonce,
    this.codeChallenge,
    this.codeChallengeMethod = 'S256',
    this.identificador = '',
    this.senha = '',
  });

  String responseType;
  String clientId;
  String redirectUri;
  List<String> escopos;
  String? state;
  String? nonce;
  String? codeChallenge;
  String codeChallengeMethod;
  String identificador;
  String senha;

  factory RequisicaoAutorizarOidc.fromMap(Map<String, dynamic> map) {
    final scope = map['scope']?.toString();
    final escopos = map['escopos'];
    return RequisicaoAutorizarOidc(
      responseType: map['response_type']?.toString() ?? 'code',
      clientId: map['client_id']?.toString() ?? '',
      redirectUri: map['redirect_uri']?.toString() ?? '',
      escopos: escopos is List
          ? escopos.map((dynamic item) => item.toString()).toList()
          : scope == null || scope.trim().isEmpty
              ? const <String>[]
              : scope
                  .split(' ')
                  .where((String item) => item.trim().isNotEmpty)
                  .toList(),
      state: map['state']?.toString(),
      nonce: map['nonce']?.toString(),
      codeChallenge: map['code_challenge']?.toString(),
      codeChallengeMethod:
          map['code_challenge_method']?.toString() ?? 'S256',
      identificador: map['identificador']?.toString() ?? '',
      senha: map['senha']?.toString() ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'response_type': responseType,
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': escopos.join(' '),
      'escopos': escopos,
      'state': state,
      'nonce': nonce,
      'code_challenge': codeChallenge,
      'code_challenge_method': codeChallengeMethod,
      'identificador': identificador,
      'senha': senha,
    };
  }

  RequisicaoAutorizarOidc clone() {
    return RequisicaoAutorizarOidc.fromMap(toMap());
  }
}
