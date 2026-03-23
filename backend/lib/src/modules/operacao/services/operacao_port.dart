import 'package:essential_core/essential_core.dart';
import 'package:nexus_core/nexus_core.dart';

abstract class OperacaoPort {
  Future<DataFrame<ResumoSubmissaoOperacao>> listarSubmissoes();

  Future<Map<String, dynamic>?> detalharSubmissao(String idSubmissao);

  Future<ResumoSubmissaoOperacao> transicionarSubmissao(
    RequisicaoTransicaoSubmissao requisicao,
  );

  Future<ResumoExecucaoClassificacao> executarClassificacao(
    RequisicaoExecutarClassificacao requisicao,
  );

  Future<DataFrame<ResumoResultadoClassificacao>> listarResultadosClassificacao(
    String idServico,
  );
}
