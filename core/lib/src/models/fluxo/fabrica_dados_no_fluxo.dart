import '../comum/enums_nexus.dart';
import 'dados_no_apresentacao.dart';
import 'dados_no_atualizacao_status.dart';
import 'dados_no_classificacao.dart';
import 'dados_no_condicao.dart';
import 'dados_no_conteudo_dinamico.dart';
import 'dados_no_fim.dart';
import 'dados_no_fluxo.dart';
import 'dados_no_formulario.dart';
import 'dados_no_inicio.dart';
import 'dados_no_pontuacao.dart';
import 'dados_no_tarefa_interna.dart';

DadosNoFluxo dadosNoFluxoFromMap({
  required TipoNoFluxo tipo,
  required Map<String, dynamic> mapa,
}) {
  switch (tipo) {
    case TipoNoFluxo.inicio:
      return DadosNoInicio.fromMap(mapa);
    case TipoNoFluxo.apresentacao:
      return DadosNoApresentacao.fromMap(mapa);
    case TipoNoFluxo.formulario:
      return DadosNoFormulario.fromMap(mapa);
    case TipoNoFluxo.conteudoDinamico:
      return DadosNoConteudoDinamico.fromMap(mapa);
    case TipoNoFluxo.condicao:
      return DadosNoCondicao.fromMap(mapa);
    case TipoNoFluxo.fim:
      return DadosNoFim.fromMap(mapa);
    case TipoNoFluxo.tarefaInterna:
      return DadosNoTarefaInterna.fromMap(mapa);
    case TipoNoFluxo.atualizacaoStatus:
      return DadosNoAtualizacaoStatus.fromMap(mapa);
    case TipoNoFluxo.pontuacao:
      return DadosNoPontuacao.fromMap(mapa);
    case TipoNoFluxo.classificacao:
      return DadosNoClassificacao.fromMap(mapa);
  }
}
