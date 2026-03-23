import 'package:nexus_core/nexus_core.dart';

import '../../runtime/services/avaliador_condicao_service.dart';

class ValidadorFluxoService {
  ValidadorFluxoService(this._avaliadorCondicaoService);

  final AvaliadorCondicaoService _avaliadorCondicaoService;

  ResultadoValidacaoFluxo validar(FluxoDto fluxo) {
    final erros = <ErroValidacaoFluxo>[];
    final nosPorId = <String, NoFluxoDto>{};
    final arestasPorId = <String, ArestaFluxoDto>{};
    final entradasPorNo = <String, List<ArestaFluxoDto>>{};
    final saidasPorNo = <String, List<ArestaFluxoDto>>{};

    for (final no in fluxo.nos) {
      if (nosPorId.containsKey(no.id)) {
        erros.add(
          ErroValidacaoFluxo(
            codigo: 'no_duplicado',
            mensagem: 'Existe mais de um no com o identificador ${no.id}.',
            idNo: no.id,
          ),
        );
        continue;
      }
      nosPorId[no.id] = no;
    }

    for (final aresta in fluxo.arestas) {
      if (arestasPorId.containsKey(aresta.id)) {
        erros.add(
          ErroValidacaoFluxo(
            codigo: 'aresta_duplicada',
            mensagem:
                'Existe mais de uma aresta com o identificador ${aresta.id}.',
            idAresta: aresta.id,
          ),
        );
        continue;
      }

      arestasPorId[aresta.id] = aresta;

      final origem = nosPorId[aresta.origem];
      final destino = nosPorId[aresta.destino];
      if (origem == null) {
        erros.add(
          ErroValidacaoFluxo(
            codigo: 'aresta_origem_inexistente',
            mensagem:
                'A aresta ${aresta.id} aponta para um no de origem inexistente.',
            idAresta: aresta.id,
          ),
        );
      }
      if (destino == null) {
        erros.add(
          ErroValidacaoFluxo(
            codigo: 'aresta_destino_inexistente',
            mensagem:
                'A aresta ${aresta.id} aponta para um no de destino inexistente.',
            idAresta: aresta.id,
          ),
        );
      }

      if (origem != null && destino != null) {
        saidasPorNo
            .putIfAbsent(origem.id, () => <ArestaFluxoDto>[])
            .add(aresta);
        entradasPorNo
            .putIfAbsent(destino.id, () => <ArestaFluxoDto>[])
            .add(aresta);
      }
    }

    final nosInicio = fluxo.nos
        .where((no) => no.tipo == TipoNoFluxo.inicio)
        .toList(growable: false);
    final nosFim = fluxo.nos
        .where((no) => no.tipo == TipoNoFluxo.fim)
        .toList(growable: false);

    if (nosInicio.length != 1) {
      erros.add(
        ErroValidacaoFluxo(
          codigo: 'quantidade_inicio_invalida',
          mensagem: 'O fluxo deve possuir exatamente um no de inicio.',
        ),
      );
    }

    if (nosFim.isEmpty) {
      erros.add(
        ErroValidacaoFluxo(
          codigo: 'fim_obrigatorio',
          mensagem: 'O fluxo deve possuir ao menos um no de fim.',
        ),
      );
    }

    for (final no in fluxo.nos) {
      final entradas = entradasPorNo[no.id] ?? const <ArestaFluxoDto>[];
      final saidas = saidasPorNo[no.id] ?? const <ArestaFluxoDto>[];
      _validarNo(no, entradas, saidas, erros);
    }

    if (nosInicio.length == 1) {
      final idsAlcancados =
          _coletarNosAlcancados(nosInicio.single.id, saidasPorNo);
      for (final no
          in fluxo.nos.where((item) => !idsAlcancados.contains(item.id))) {
        erros.add(
          ErroValidacaoFluxo(
            codigo: 'no_inacessivel',
            mensagem:
                'O no ${no.id} nao e alcancavel a partir do inicio do fluxo.',
            idNo: no.id,
          ),
        );
      }
    }

    return ResultadoValidacaoFluxo(
      valido: erros.isEmpty,
      erros: erros,
    );
  }

  void _validarNo(
    NoFluxoDto no,
    List<ArestaFluxoDto> entradas,
    List<ArestaFluxoDto> saidas,
    List<ErroValidacaoFluxo> erros,
  ) {
    switch (no.tipo) {
      case TipoNoFluxo.inicio:
        final dados = no.dados as DadosNoInicio;
        if (dados.rotulo.trim().isEmpty) {
          _adicionarErroNo(erros, no.id, 'inicio_sem_rotulo',
              'O no de inicio deve possuir rotulo.');
        }
        if (entradas.isNotEmpty) {
          _adicionarErroNo(erros, no.id, 'inicio_com_entrada',
              'O no de inicio nao pode possuir arestas de entrada.');
        }
        if (saidas.length != 1) {
          _adicionarErroNo(erros, no.id, 'inicio_saida_invalida',
              'O no de inicio deve possuir exatamente uma aresta de saida.');
        }
        break;
      case TipoNoFluxo.apresentacao:
        final dados = no.dados as DadosNoApresentacao;
        if (dados.rotulo.trim().isEmpty) {
          _adicionarErroNo(erros, no.id, 'apresentacao_sem_rotulo',
              'O no de apresentacao deve possuir rotulo.');
        }
        if (dados.conteudoApresentacao.vazio) {
          _adicionarErroNo(erros, no.id, 'apresentacao_sem_conteudo',
              'O no de apresentacao deve possuir conteudo principal.');
        }
        _validarSaidaLinear(no.id, saidas, erros);
        break;
      case TipoNoFluxo.formulario:
        final dados = no.dados as DadosNoFormulario;
        if (dados.rotulo.trim().isEmpty) {
          _adicionarErroNo(erros, no.id, 'formulario_sem_rotulo',
              'O no de formulario deve possuir rotulo.');
        }
        if (dados.perguntas.isEmpty) {
          _adicionarErroNo(erros, no.id, 'formulario_sem_perguntas',
              'O no de formulario deve possuir ao menos uma pergunta.');
        }
        final campos = <String>{};
        for (final pergunta in dados.perguntas) {
          if (pergunta.campo.trim().isEmpty) {
            _adicionarErroNo(erros, no.id, 'pergunta_sem_campo',
                'Todas as perguntas do formulario devem possuir um campo.');
          }
          if (!campos.add(pergunta.campo)) {
            _adicionarErroNo(erros, no.id, 'pergunta_campo_duplicado',
                'O formulario possui campos duplicados.');
          }
          if (_tipoCampoExigeOpcoes(pergunta.tipo) && pergunta.opcoes.isEmpty) {
            _adicionarErroNo(erros, no.id, 'pergunta_sem_opcoes',
                'Perguntas de selecao devem possuir opcoes configuradas.');
          }
        }
        _validarSaidaLinear(no.id, saidas, erros);
        break;
      case TipoNoFluxo.conteudoDinamico:
        final dados = no.dados as DadosNoConteudoDinamico;
        if (dados.rotulo.trim().isEmpty) {
          _adicionarErroNo(erros, no.id, 'conteudo_dinamico_sem_rotulo',
              'O no de conteudo dinamico deve possuir rotulo.');
        }
        if (dados.metodo.trim().isEmpty || dados.url.trim().isEmpty) {
          _adicionarErroNo(erros, no.id, 'conteudo_dinamico_incompleto',
              'O no de conteudo dinamico deve possuir metodo e URL.');
        }
        if (dados.modeloConteudo.vazio) {
          _adicionarErroNo(erros, no.id, 'conteudo_dinamico_sem_modelo',
              'O no de conteudo dinamico deve possuir modelo de conteudo.');
        }
        if (dados.finalizaFluxo) {
          if (saidas.isNotEmpty) {
            _adicionarErroNo(
                erros,
                no.id,
                'conteudo_dinamico_finaliza_com_saida',
                'Um no de conteudo dinamico que finaliza o fluxo nao deve possuir saidas.');
          }
        } else {
          _validarSaidaLinear(no.id, saidas, erros);
        }
        break;
      case TipoNoFluxo.condicao:
        final dados = no.dados as DadosNoCondicao;
        if (dados.rotulo.trim().isEmpty) {
          _adicionarErroNo(erros, no.id, 'condicao_sem_rotulo',
              'O no de condicao deve possuir rotulo.');
        }
        if (dados.expressao.trim().isEmpty ||
            !_avaliadorCondicaoService.expressaoJsonValida(dados.expressao)) {
          _adicionarErroNo(erros, no.id, 'condicao_expressao_invalida',
              'O no de condicao deve possuir uma expressao JSON valida.');
        }
        if (dados.handleVerdadeiro.trim().isEmpty ||
            dados.handleFalso.trim().isEmpty) {
          _adicionarErroNo(erros, no.id, 'condicao_handles_obrigatorios',
              'O no de condicao deve possuir handles verdadeiro e falso.');
        }
        if (dados.handleVerdadeiro == dados.handleFalso) {
          _adicionarErroNo(erros, no.id, 'condicao_handles_duplicados',
              'Os handles verdadeiro e falso devem ser diferentes.');
        }
        final saidasVerdadeiras = saidas
            .where((item) => item.handleOrigem == dados.handleVerdadeiro)
            .length;
        final saidasFalsas = saidas
            .where((item) => item.handleOrigem == dados.handleFalso)
            .length;
        if (saidasVerdadeiras != 1 || saidasFalsas != 1) {
          _adicionarErroNo(erros, no.id, 'condicao_saidas_invalidas',
              'O no de condicao deve possuir exatamente uma saida para verdadeiro e uma para falso.');
        }
        break;
      case TipoNoFluxo.fim:
        final dados = no.dados as DadosNoFim;
        if (dados.rotulo.trim().isEmpty) {
          _adicionarErroNo(erros, no.id, 'fim_sem_rotulo',
              'O no de fim deve possuir rotulo.');
        }
        if (saidas.isNotEmpty) {
          _adicionarErroNo(erros, no.id, 'fim_com_saida',
              'O no de fim nao pode possuir arestas de saida.');
        }
        break;
      case TipoNoFluxo.tarefaInterna:
        final dados = no.dados as DadosNoTarefaInterna;
        if (dados.rotulo.trim().isEmpty) {
          _adicionarErroNo(erros, no.id, 'tarefa_interna_sem_rotulo',
              'O no de tarefa interna deve possuir rotulo.');
        }
        if (dados.titulo.trim().isEmpty) {
          _adicionarErroNo(erros, no.id, 'tarefa_interna_sem_titulo',
              'O no de tarefa interna deve possuir titulo.');
        }
        _validarSaidaLinear(no.id, saidas, erros);
        break;
      case TipoNoFluxo.atualizacaoStatus:
        final dados = no.dados as DadosNoAtualizacaoStatus;
        if (dados.rotulo.trim().isEmpty) {
          _adicionarErroNo(erros, no.id, 'atualizacao_status_sem_rotulo',
              'O no de atualizacao de status deve possuir rotulo.');
        }
        if (!_statusSubmissaoValido(dados.novoStatus)) {
          _adicionarErroNo(erros, no.id, 'atualizacao_status_invalido',
              'O no de atualizacao de status deve apontar para um status de submissao valido.');
        }
        _validarSaidaLinear(no.id, saidas, erros);
        break;
      case TipoNoFluxo.pontuacao:
        final dados = no.dados as DadosNoPontuacao;
        if (dados.rotulo.trim().isEmpty) {
          _adicionarErroNo(erros, no.id, 'pontuacao_sem_rotulo',
              'O no de pontuacao deve possuir rotulo.');
        }
        if (dados.chaveResultado.trim().isEmpty) {
          _adicionarErroNo(erros, no.id, 'pontuacao_sem_chave',
              'O no de pontuacao deve possuir chave de resultado.');
        }
        _validarSaidaLinear(no.id, saidas, erros);
        break;
      case TipoNoFluxo.classificacao:
        final dados = no.dados as DadosNoClassificacao;
        if (dados.rotulo.trim().isEmpty) {
          _adicionarErroNo(erros, no.id, 'classificacao_sem_rotulo',
              'O no de classificacao deve possuir rotulo.');
        }
        _validarSaidaLinear(no.id, saidas, erros);
        break;
    }
  }

  void _validarSaidaLinear(
    String idNo,
    List<ArestaFluxoDto> saidas,
    List<ErroValidacaoFluxo> erros,
  ) {
    if (saidas.length != 1) {
      _adicionarErroNo(erros, idNo, 'saida_linear_invalida',
          'O no deve possuir exatamente uma aresta de saida.');
    }
  }

  Set<String> _coletarNosAlcancados(
    String idNoInicial,
    Map<String, List<ArestaFluxoDto>> saidasPorNo,
  ) {
    final visitados = <String>{};
    final pendentes = <String>[idNoInicial];

    while (pendentes.isNotEmpty) {
      final atual = pendentes.removeLast();
      if (!visitados.add(atual)) {
        continue;
      }
      for (final aresta in saidasPorNo[atual] ?? const <ArestaFluxoDto>[]) {
        if (!visitados.contains(aresta.destino)) {
          pendentes.add(aresta.destino);
        }
      }
    }

    return visitados;
  }

  void _adicionarErroNo(
    List<ErroValidacaoFluxo> erros,
    String idNo,
    String codigo,
    String mensagem,
  ) {
    erros.add(
      ErroValidacaoFluxo(
        codigo: codigo,
        mensagem: mensagem,
        idNo: idNo,
      ),
    );
  }

  bool _tipoCampoExigeOpcoes(TipoCampoFormulario tipo) {
    return tipo == TipoCampoFormulario.selecao ||
        tipo == TipoCampoFormulario.multiplaSelecao;
  }

  bool _statusSubmissaoValido(String status) {
    return const <String>{
      'submetida',
      'em_analise',
      'pendente_documentos',
      'elegivel',
      'inelegivel',
      'ranqueada',
      'homologada',
      'arquivada',
    }.contains(status);
  }
}
