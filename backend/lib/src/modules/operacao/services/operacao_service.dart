import 'package:essential_core/essential_core.dart';
import 'package:nexus_core/nexus_core.dart';

import '../repositories/operacao_repository.dart';
import 'operacao_port.dart';

class OperacaoService implements OperacaoPort {
  OperacaoService(this._repository);

  final OperacaoRepository _repository;

  @override
  Future<Map<String, dynamic>?> detalharSubmissao(String idSubmissao) {
    return _repository.findSubmissaoById(idSubmissao);
  }

  @override
  Future<ResumoExecucaoClassificacao> executarClassificacao(
    RequisicaoExecutarClassificacao requisicao,
  ) {
    return _repository.runClassificacao(requisicao);
  }

  @override
  Future<DataFrame<ResumoResultadoClassificacao>> listarResultadosClassificacao(
    String idServico,
  ) {
    return _repository.listResultadosClassificacao(idServico);
  }

  @override
  Future<DataFrame<ResumoSubmissaoOperacao>> listarSubmissoes() {
    return _repository.listSubmissoes();
  }

  @override
  Future<ResumoSubmissaoOperacao> transicionarSubmissao(
    RequisicaoTransicaoSubmissao requisicao,
  ) {
    return _repository.transitionSubmissao(requisicao);
  }
}
