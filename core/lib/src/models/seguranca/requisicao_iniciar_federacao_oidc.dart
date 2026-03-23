import 'package:essential_core/essential_core.dart';

class RequisicaoIniciarFederacaoOidc implements SerializeBase {
  RequisicaoIniciarFederacaoOidc({
    this.nomeProvedor = 'microsoft',
    this.clientId = '',
    this.redirectUri = '',
    this.escopos = const <String>[],
    this.state,
    this.nonce,
    this.codeChallenge,
    this.codeChallengeMethod = 'S256',
  });

  String nomeProvedor;
  String clientId;
  String redirectUri;
  List<String> escopos;
  String? state;
  String? nonce;
  String? codeChallenge;
  String codeChallengeMethod;

  factory RequisicaoIniciarFederacaoOidc.fromMap(Map<String, dynamic> map) {
    final scope = map['scope']?.toString();
    final escopos = map['escopos'];
    return RequisicaoIniciarFederacaoOidc(
      nomeProvedor: map['nome_provedor']?.toString() ?? 'microsoft',
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
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nome_provedor': nomeProvedor,
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': escopos.join(' '),
      'escopos': escopos,
      'state': state,
      'nonce': nonce,
      'code_challenge': codeChallenge,
      'code_challenge_method': codeChallengeMethod,
    };
  }

  RequisicaoIniciarFederacaoOidc clone() {
    return RequisicaoIniciarFederacaoOidc.fromMap(toMap());
  }
}
