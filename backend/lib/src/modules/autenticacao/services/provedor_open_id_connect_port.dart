import 'package:nexus_core/nexus_core.dart';

abstract class ProvedorOpenIdConnectPort {
  DocumentoDescobertaOpenIdConnect obterDocumentoDescoberta();

  ConjuntoChavesJsonWeb obterConjuntoChaves();

  Future<ResultadoAutorizacaoOidc> autorizar(
    RequisicaoAutorizarOidc requisicao, {
    String? enderecoIp,
    String? userAgent,
  });

  Future<ResultadoTokenOidc> trocarToken(
    RequisicaoTokenOidc requisicao, {
    String? enderecoIp,
    String? userAgent,
  });

  Future<ResultadoUsuarioInfoOidc> obterUsuarioInfo(String accessToken);

  ResultadoIniciarFederacaoOidc iniciarFederacao(
    RequisicaoIniciarFederacaoOidc requisicao,
  );

  Future<void> encerrarSessao({
    String? sessionState,
    String? accessToken,
  });
}
