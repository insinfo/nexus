import 'package:nexus_core/nexus_core.dart';
import 'package:test/test.dart';

void main() {
  group('CanalServico', () {
    test('tryParse retorna valor conhecido e null para invalido', () {
      expect(
          CanalServico.tryParse('portal_cidadao'), CanalServico.portalCidadao);
      expect(CanalServico.tryParse('whatsapp'), CanalServico.whatsapp);
      expect(CanalServico.tryParse('invalido'), isNull);
      expect(CanalServico.tryParse(null), isNull);
    });

    test('parse retorna valor conhecido e falha para invalido', () {
      expect(CanalServico.parse('iframe'), CanalServico.iframe);
      expect(() => CanalServico.parse('invalido'), throwsArgumentError);
    });

    test('expoe label para apresentacao', () {
      expect(CanalServico.portalCidadao.label, 'Portal do cidadao');
      expect(CanalServico.whatsapp.label, 'Whatsapp');
    });
  });

  group('ModoAcesso', () {
    test('parse e tryParse funcionam para valores validos e invalidos', () {
      expect(ModoAcesso.tryParse('publico_anonimo'), ModoAcesso.publicoAnonimo);
      expect(ModoAcesso.parse('cidadao_autenticado'),
          ModoAcesso.cidadaoAutenticado);
      expect(ModoAcesso.parse('hibrido'), ModoAcesso.hibrido);
      expect(ModoAcesso.tryParse('invalido'), isNull);
      expect(() => ModoAcesso.parse('invalido'), throwsArgumentError);
    });

    test('expoe label para apresentacao', () {
      expect(ModoAcesso.publicoAnonimo.label, 'Publico anonimo');
      expect(ModoAcesso.hibrido.label, 'Cidadao e retaguarda');
    });
  });

  group('TipoFluxo', () {
    test('aceita apenas o valor canonico do enum', () {
      expect(TipoFluxo.tryParse('entrada_dados'), TipoFluxo.entradaDados);
      expect(
        TipoNoFluxo.tryParseBanco('conteudo_dinamico'),
        TipoNoFluxo.conteudoDinamico,
      );
      expect(TipoFluxo.tryParse('invalido'), isNull);
      expect(() => TipoFluxo.parse('invalido'), throwsArgumentError);
    });

    test('expoe label para apresentacao', () {
      expect(TipoFluxo.entradaDados.label, 'Entrada de dados');
      expect(TipoFluxo.interno.label, 'Interno');
    });
  });

  group('TipoNoFluxo', () {
    test('aceita apenas o valor canonico do enum', () {
      expect(TipoNoFluxo.tryParse('formulario'), TipoNoFluxo.formulario);
      expect(TipoNoFluxo.tryParseBanco('conteudo_dinamico'),
          TipoNoFluxo.conteudoDinamico);
      expect(
          TipoNoFluxo.parseBanco('tarefa_interna'), TipoNoFluxo.tarefaInterna);
      expect(TipoNoFluxo.parse('classificacao'), TipoNoFluxo.classificacao);
      expect(TipoNoFluxo.tryParse('conteudoDinamico'), isNull);
      expect(TipoNoFluxo.tryParse('TipoNoFluxo.conteudoDinamico'), isNull);
      expect(TipoNoFluxo.tryParse('invalido'), isNull);
      expect(() => TipoNoFluxo.parse('invalido'), throwsArgumentError);
      expect(() => TipoNoFluxo.parseBanco('invalido'), throwsArgumentError);
    });

    test('expoe label e val corretos', () {
      expect(TipoNoFluxo.inicio.label, 'Inicio');
      expect(TipoNoFluxo.conteudoDinamico.label, 'Conteudo dinamico');
      expect(TipoNoFluxo.tarefaInterna.label, 'Tarefa interna');
      expect(TipoNoFluxo.tarefaInterna.val, 'tarefa_interna');
      expect(TipoNoFluxo.atualizacaoStatus.val, 'atualizacao_status');
    });

    test('automatico reflete corretamente os tipos automaticos', () {
      expect(TipoNoFluxo.inicio.automatico, isFalse);
      expect(TipoNoFluxo.formulario.automatico, isFalse);
      expect(TipoNoFluxo.conteudoDinamico.automatico, isTrue);
      expect(TipoNoFluxo.tarefaInterna.automatico, isTrue);
      expect(TipoNoFluxo.atualizacaoStatus.automatico, isTrue);
      expect(TipoNoFluxo.pontuacao.automatico, isTrue);
      expect(TipoNoFluxo.classificacao.automatico, isTrue);
    });
  });

  group('TipoCampoFormulario', () {
    test('parse e tryParse funcionam para valores validos e invalidos', () {
      expect(TipoCampoFormulario.tryParse('texto_curto'),
          TipoCampoFormulario.textoCurto);
      expect(TipoCampoFormulario.parse('multipla_selecao'),
          TipoCampoFormulario.multiplaSelecao);
      expect(TipoCampoFormulario.tryParse('invalido'), isNull);
      expect(() => TipoCampoFormulario.parse('invalido'), throwsArgumentError);
    });

    test('expoe label para apresentacao', () {
      expect(TipoCampoFormulario.textoCurto.label, 'Texto curto');
      expect(TipoCampoFormulario.multiplaSelecao.label, 'Multipla selecao');
    });
  });

  group('StatusVersaoServico', () {
    test('parse e tryParse funcionam para valores validos e invalidos', () {
      expect(StatusVersaoServico.tryParse('rascunho'),
          StatusVersaoServico.rascunho);
      expect(StatusVersaoServico.parse('publicada'),
          StatusVersaoServico.publicada);
      expect(StatusVersaoServico.tryParse('invalido'), isNull);
      expect(() => StatusVersaoServico.parse('invalido'), throwsArgumentError);
    });

    test('expoe label para apresentacao', () {
      expect(StatusVersaoServico.publicada.label, 'Publicada');
    });
  });

  group('StatusVersaoConjuntoRegras', () {
    test('parse e tryParse funcionam para valores validos e invalidos', () {
      expect(
        StatusVersaoConjuntoRegras.tryParse('rascunho'),
        StatusVersaoConjuntoRegras.rascunho,
      );
      expect(
        StatusVersaoConjuntoRegras.parse('publicada'),
        StatusVersaoConjuntoRegras.publicada,
      );
      expect(StatusVersaoConjuntoRegras.tryParse('invalido'), isNull);
      expect(() => StatusVersaoConjuntoRegras.parse('invalido'),
          throwsArgumentError);
    });
  });

  group('StatusExecucao', () {
    test('aceita o valor canonico do dominio e do banco', () {
      expect(StatusExecucao.tryParse('concluida'), StatusExecucao.concluida);
      expect(StatusExecucao.tryParseBanco('em_andamento'),
          StatusExecucao.emAndamento);
      expect(StatusExecucao.parseBanco('cancelada'), StatusExecucao.cancelada);
      expect(StatusExecucao.parse('em_andamento'), StatusExecucao.emAndamento);
      expect(StatusExecucao.tryParse('invalido'), isNull);
      expect(() => StatusExecucao.parse('invalido'), throwsArgumentError);
      expect(() => StatusExecucao.parseBanco('invalido'), throwsArgumentError);
    });

    test('expoe label para apresentacao', () {
      expect(StatusExecucao.emAndamento.label, 'Em andamento');
    });
  });

  group('TipoPublicacao', () {
    test('parse e tryParse funcionam para valores validos e invalidos', () {
      expect(TipoPublicacao.tryParse('noticia'), TipoPublicacao.noticia);
      expect(TipoPublicacao.parse('pagina_institucional'),
          TipoPublicacao.paginaInstitucional);
      expect(TipoPublicacao.tryParse('invalido'), isNull);
      expect(() => TipoPublicacao.parse('invalido'), throwsArgumentError);
    });

    test('expoe label para apresentacao', () {
      expect(TipoPublicacao.paginaInstitucional.label, 'Pagina institucional');
    });
  });

  group('StatusPublicacao', () {
    test('parse e tryParse funcionam para valores validos e invalidos', () {
      expect(StatusPublicacao.tryParse('rascunho'), StatusPublicacao.rascunho);
      expect(StatusPublicacao.parse('publicada'), StatusPublicacao.publicada);
      expect(StatusPublicacao.tryParse('invalido'), isNull);
      expect(() => StatusPublicacao.parse('invalido'), throwsArgumentError);
    });

    test('expoe label para apresentacao', () {
      expect(StatusPublicacao.agendada.label, 'Agendada');
    });
  });

  group('StatusItemTrabalhoRetaguarda', () {
    test('parse e tryParse funcionam para valores validos e invalidos', () {
      expect(
        StatusItemTrabalhoRetaguarda.tryParse('pendente'),
        StatusItemTrabalhoRetaguarda.pendente,
      );
      expect(
        StatusItemTrabalhoRetaguarda.parse('aguardando_acao_externa'),
        StatusItemTrabalhoRetaguarda.aguardandoAcaoExterna,
      );
      expect(StatusItemTrabalhoRetaguarda.tryParse('invalido'), isNull);
      expect(() => StatusItemTrabalhoRetaguarda.parse('invalido'),
          throwsArgumentError);
    });

    test('expoe label para apresentacao', () {
      expect(
        StatusItemTrabalhoRetaguarda.aguardandoAcaoExterna.label,
        'Aguardando acao externa',
      );
    });
  });
}
