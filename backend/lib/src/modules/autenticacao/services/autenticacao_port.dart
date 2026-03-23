import 'package:nexus_core/nexus_core.dart';

abstract class AutenticacaoPort {
  Future<ResultadoAutenticacaoUsuario> cadastrar(
    RequisicaoCadastroUsuario requisicao, {
    String? enderecoIp,
    String? userAgent,
  });

  Future<ResultadoAutenticacaoUsuario> login(
    RequisicaoLoginUsuario requisicao, {
    String? enderecoIp,
    String? userAgent,
  });

  Future<ResultadoSolicitacaoRedefinicaoSenha> solicitarRedefinicaoSenha(
    RequisicaoSolicitarRedefinicaoSenha requisicao, {
    String? enderecoIp,
  });

  Future<ResultadoAutenticacaoUsuario> redefinirSenha(
    RequisicaoRedefinirSenha requisicao, {
    String? enderecoIp,
    String? userAgent,
  });
}