import 'package:ngdart/angular.dart';
import 'package:nexus_core/nexus_core.dart';

import 'servico_http_base.dart';

@Injectable()
class AcessoService {
  AcessoService(this._servicoHttpBase);

  final ServicoHttpBase _servicoHttpBase;

  Future<ResultadoAutenticacaoUsuario> cadastrarContaCidadao(
    RequisicaoCadastroUsuario requisicao,
  ) async {
    final jsonMap = await _servicoHttpBase.sendJsonMap(
      '/acesso/cadastro',
      metodo: 'POST',
      corpo: requisicao.toMap(),
    );
    return ResultadoAutenticacaoUsuario.fromMap(jsonMap);
  }

  Future<ResultadoSolicitacaoRedefinicaoSenha> solicitarRecuperacaoSenha(
    RequisicaoSolicitarRedefinicaoSenha requisicao,
  ) async {
    final jsonMap = await _servicoHttpBase.sendJsonMap(
      '/acesso/redefinicao/solicitar',
      metodo: 'POST',
      corpo: requisicao.toMap(),
    );
    return ResultadoSolicitacaoRedefinicaoSenha.fromMap(jsonMap);
  }

  Future<ResultadoAutenticacaoUsuario> confirmarRecuperacaoSenha(
    RequisicaoRedefinirSenha requisicao,
  ) async {
    final jsonMap = await _servicoHttpBase.sendJsonMap(
      '/acesso/redefinicao/confirmar',
      metodo: 'POST',
      corpo: requisicao.toMap(),
    );
    return ResultadoAutenticacaoUsuario.fromMap(jsonMap);
  }
}