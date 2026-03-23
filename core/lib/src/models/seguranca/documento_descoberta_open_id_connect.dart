class DocumentoDescobertaOpenIdConnect {
  DocumentoDescobertaOpenIdConnect({
    this.issuer = '',
    this.endpointAutorizacao = '',
    this.endpointToken = '',
    this.endpointInformacoesUsuario = '',
    this.uriConjuntoChaves = '',
    this.endpointEncerrarSessao = '',
    this.escoposSuportados = const <String>[],
    this.metodosCodeChallengeSuportados = const <String>[],
    this.tiposRespostaSuportados = const <String>[],
    this.tiposConcessaoSuportados = const <String>[],
    this.tiposAssuntoSuportados = const <String>[],
    this.algoritmosAssinaturaIdTokenSuportados = const <String>[],
    this.metodosAutenticacaoEndpointTokenSuportados = const <String>[],
    this.claimsSuportados = const <String>[],
  });

  String issuer;
  String endpointAutorizacao;
  String endpointToken;
  String endpointInformacoesUsuario;
  String uriConjuntoChaves;
  String endpointEncerrarSessao;
  List<String> escoposSuportados;
  List<String> metodosCodeChallengeSuportados;
  List<String> tiposRespostaSuportados;
  List<String> tiposConcessaoSuportados;
  List<String> tiposAssuntoSuportados;
  List<String> algoritmosAssinaturaIdTokenSuportados;
  List<String> metodosAutenticacaoEndpointTokenSuportados;
  List<String> claimsSuportados;

  factory DocumentoDescobertaOpenIdConnect.fromMap(Map<String, dynamic> map) {
    return DocumentoDescobertaOpenIdConnect(
      issuer: map['issuer']?.toString() ?? '',
      endpointAutorizacao: map['authorization_endpoint']?.toString() ?? '',
      endpointToken: map['token_endpoint']?.toString() ?? '',
      endpointInformacoesUsuario: map['userinfo_endpoint']?.toString() ?? '',
      uriConjuntoChaves: map['jwks_uri']?.toString() ?? '',
      endpointEncerrarSessao: map['end_session_endpoint']?.toString() ?? '',
      escoposSuportados: _listaString(map['scopes_supported']),
        metodosCodeChallengeSuportados:
          _listaString(map['code_challenge_methods_supported']),
      tiposRespostaSuportados: _listaString(map['response_types_supported']),
      tiposConcessaoSuportados: _listaString(map['grant_types_supported']),
      tiposAssuntoSuportados: _listaString(map['subject_types_supported']),
      algoritmosAssinaturaIdTokenSuportados: _listaString(
        map['id_token_signing_alg_values_supported'],
      ),
      metodosAutenticacaoEndpointTokenSuportados: _listaString(
        map['token_endpoint_auth_methods_supported'],
      ),
      claimsSuportados: _listaString(map['claims_supported']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'issuer': issuer,
      'authorization_endpoint': endpointAutorizacao,
      'token_endpoint': endpointToken,
      'userinfo_endpoint': endpointInformacoesUsuario,
      'jwks_uri': uriConjuntoChaves,
      'end_session_endpoint': endpointEncerrarSessao,
      'scopes_supported': escoposSuportados,
      'code_challenge_methods_supported': metodosCodeChallengeSuportados,
      'response_types_supported': tiposRespostaSuportados,
      'grant_types_supported': tiposConcessaoSuportados,
      'subject_types_supported': tiposAssuntoSuportados,
      'id_token_signing_alg_values_supported':
          algoritmosAssinaturaIdTokenSuportados,
      'token_endpoint_auth_methods_supported':
          metodosAutenticacaoEndpointTokenSuportados,
      'claims_supported': claimsSuportados,
    };
  }

  DocumentoDescobertaOpenIdConnect clone() {
    return DocumentoDescobertaOpenIdConnect.fromMap(toMap());
  }

  static List<String> _listaString(dynamic valor) {
    if (valor is List) {
      return valor.map((dynamic item) => item.toString()).toList();
    }
    return <String>[];
  }
}
