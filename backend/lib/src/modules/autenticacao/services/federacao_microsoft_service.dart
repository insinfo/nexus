import 'package:nexus_core/nexus_core.dart';

import '../../../shared/app_config.dart';

class FederacaoMicrosoftService {
  FederacaoMicrosoftService(this.config);

  final AppConfig config;

  ResultadoIniciarFederacaoOidc iniciar(
    RequisicaoIniciarFederacaoOidc requisicao,
  ) {
    if (!config.microsoftFederacaoHabilitada) {
      return ResultadoIniciarFederacaoOidc(
        nomeProvedor: 'microsoft',
        habilitado: false,
        mensagem:
            'Federacao Microsoft Active Directory ainda nao configurada no backend.',
      );
    }

    final endpoint =
        '${config.microsoftAuthorityBase}/${config.microsoftTenantId}/oauth2/v2.0/authorize';
    final state = requisicao.state ?? '';
    final nonce = requisicao.nonce ?? '';
    final query = <String, String>{
      'client_id': config.microsoftClientId,
      'response_type': 'code',
      'redirect_uri': config.microsoftRedirectUri,
      'response_mode': 'query',
      'scope': config.microsoftEscopos.join(' '),
      if (state.isNotEmpty) 'state': state,
      if (nonce.isNotEmpty) 'nonce': nonce,
      if ((requisicao.codeChallenge ?? '').isNotEmpty)
        'code_challenge': requisicao.codeChallenge!,
      if ((requisicao.codeChallengeMethod).isNotEmpty)
        'code_challenge_method': requisicao.codeChallengeMethod,
    };

    final uri = Uri.parse(endpoint).replace(queryParameters: query);
    return ResultadoIniciarFederacaoOidc(
      nomeProvedor: 'microsoft',
      urlAutorizacao: uri.toString(),
      state: requisicao.state,
      nonce: requisicao.nonce,
      habilitado: true,
    );
  }
}
