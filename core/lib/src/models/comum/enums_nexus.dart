enum CanalServico {
  portalCidadao('portal_cidadao'),
  retaguarda('retaguarda'),
  iframe('iframe'),
  whatsapp('whatsapp');

  final String val;
  const CanalServico(this.val);

  String get label {
    switch (this) {
      case CanalServico.portalCidadao:
        return 'Portal do cidadao';
      case CanalServico.retaguarda:
        return 'Retaguarda';
      case CanalServico.iframe:
        return 'Iframe';
      case CanalServico.whatsapp:
        return 'Whatsapp';
    }
  }

  static CanalServico? tryParse(String? valor) {
    switch (valor) {
      case 'portal_cidadao':
        return CanalServico.portalCidadao;
      case 'retaguarda':
        return CanalServico.retaguarda;
      case 'iframe':
        return CanalServico.iframe;
      case 'whatsapp':
        return CanalServico.whatsapp;
      default:
        return null;
    }
  }

  static CanalServico parse(String valor) {
    final canal = tryParse(valor);
    if (canal != null) {
      return canal;
    }
    throw ArgumentError('CanalServico invalido: $valor');
  }
}

enum ModoAcesso {
  publicoAnonimo('publico_anonimo'),
  cidadaoAutenticado('cidadao_autenticado'),
  interno('interno'),
  hibrido('hibrido');

  final String val;
  const ModoAcesso(this.val);

  String get label {
    switch (this) {
      case ModoAcesso.publicoAnonimo:
        return 'Publico anonimo';
      case ModoAcesso.cidadaoAutenticado:
        return 'Cidadao autenticado';
      case ModoAcesso.interno:
        return 'Interno';
      case ModoAcesso.hibrido:
        return 'Cidadao e retaguarda';
    }
  }

  static ModoAcesso? tryParse(String? valor) {
    switch (valor) {
      case 'publico_anonimo':
        return ModoAcesso.publicoAnonimo;
      case 'cidadao_autenticado':
        return ModoAcesso.cidadaoAutenticado;
      case 'interno':
        return ModoAcesso.interno;
      case 'hibrido':
        return ModoAcesso.hibrido;
      default:
        return null;
    }
  }

  static ModoAcesso parse(String valor) {
    final modo = tryParse(valor);
    if (modo != null) {
      return modo;
    }
    throw ArgumentError('ModoAcesso invalido: $valor');
  }
}

enum TipoFluxo {
  entradaDados('entrada_dados'),
  interno('interno');

  final String val;
  const TipoFluxo(this.val);

  String get label {
    switch (this) {
      case TipoFluxo.entradaDados:
        return 'Entrada de dados';
      case TipoFluxo.interno:
        return 'Interno';
    }
  }

  static TipoFluxo? tryParse(String? valor) {
    switch (valor) {
      case 'entrada_dados':
        return TipoFluxo.entradaDados;
      case 'interno':
        return TipoFluxo.interno;
      default:
        return null;
    }
  }

  static TipoFluxo parse(String valor) {
    final tipo = tryParse(valor);
    if (tipo != null) {
      return tipo;
    }
    throw ArgumentError('TipoFluxo invalido: $valor');
  }
}

enum TipoNoFluxo {
  inicio('inicio'),
  apresentacao('apresentacao'),
  formulario('formulario'),
  conteudoDinamico('conteudo_dinamico'),
  condicao('condicao'),
  fim('fim'),
  tarefaInterna('tarefa_interna'),
  atualizacaoStatus('atualizacao_status'),
  pontuacao('pontuacao'),
  classificacao('classificacao');

  final String val;
  const TipoNoFluxo(this.val);

  String get label {
    switch (this) {
      case TipoNoFluxo.inicio:
        return 'Inicio';
      case TipoNoFluxo.apresentacao:
        return 'Apresentacao';
      case TipoNoFluxo.formulario:
        return 'Formulario';
      case TipoNoFluxo.conteudoDinamico:
        return 'Conteudo dinamico';
      case TipoNoFluxo.condicao:
        return 'Condicao';
      case TipoNoFluxo.fim:
        return 'Fim';
      case TipoNoFluxo.tarefaInterna:
        return 'Tarefa interna';
      case TipoNoFluxo.atualizacaoStatus:
        return 'Atualizacao de status';
      case TipoNoFluxo.pontuacao:
        return 'Pontuacao';
      case TipoNoFluxo.classificacao:
        return 'Classificacao';
    }
  }

  static TipoNoFluxo? tryParse(String? valor) {
    switch (valor) {
      case 'inicio':
        return TipoNoFluxo.inicio;
      case 'apresentacao':
        return TipoNoFluxo.apresentacao;
      case 'formulario':
        return TipoNoFluxo.formulario;
      case 'conteudo_dinamico':
        return TipoNoFluxo.conteudoDinamico;
      case 'condicao':
        return TipoNoFluxo.condicao;
      case 'fim':
        return TipoNoFluxo.fim;
      case 'tarefa_interna':
        return TipoNoFluxo.tarefaInterna;
      case 'atualizacao_status':
        return TipoNoFluxo.atualizacaoStatus;
      case 'pontuacao':
        return TipoNoFluxo.pontuacao;
      case 'classificacao':
        return TipoNoFluxo.classificacao;
      default:
        return null;
    }
  }

  static TipoNoFluxo? tryParseBanco(String? valor) {
    return tryParse(valor);
  }

  static TipoNoFluxo parse(String valor) {
    final tipo = tryParse(valor);
    if (tipo != null) {
      return tipo;
    }
    throw ArgumentError('TipoNoFluxo invalido: $valor');
  }

  static TipoNoFluxo parseBanco(String valor) {
    return parse(valor);
  }

  bool get automatico {
    return this == TipoNoFluxo.conteudoDinamico ||
        this == TipoNoFluxo.tarefaInterna ||
        this == TipoNoFluxo.atualizacaoStatus ||
        this == TipoNoFluxo.pontuacao ||
        this == TipoNoFluxo.classificacao;
  }
}

enum TipoCampoFormulario {
  textoCurto('texto_curto'),
  textoLongo('texto_longo'),
  inteiro('inteiro'),
  decimal('decimal'),
  moeda('moeda'),
  data('data'),
  dataHora('data_hora'),
  cpf('cpf'),
  cnpj('cnpj'),
  email('email'),
  telefone('telefone'),
  selecao('selecao'),
  multiplaSelecao('multipla_selecao'),
  caixaMarcacao('caixa_marcacao'),
  anexo('anexo');

  final String val;
  const TipoCampoFormulario(this.val);

  String get label {
    switch (this) {
      case TipoCampoFormulario.textoCurto:
        return 'Texto curto';
      case TipoCampoFormulario.textoLongo:
        return 'Texto longo';
      case TipoCampoFormulario.inteiro:
        return 'Inteiro';
      case TipoCampoFormulario.decimal:
        return 'Decimal';
      case TipoCampoFormulario.moeda:
        return 'Moeda';
      case TipoCampoFormulario.data:
        return 'Data';
      case TipoCampoFormulario.dataHora:
        return 'Data e hora';
      case TipoCampoFormulario.cpf:
        return 'Cpf';
      case TipoCampoFormulario.cnpj:
        return 'Cnpj';
      case TipoCampoFormulario.email:
        return 'Email';
      case TipoCampoFormulario.telefone:
        return 'Telefone';
      case TipoCampoFormulario.selecao:
        return 'Selecao';
      case TipoCampoFormulario.multiplaSelecao:
        return 'Multipla selecao';
      case TipoCampoFormulario.caixaMarcacao:
        return 'Caixa de marcacao';
      case TipoCampoFormulario.anexo:
        return 'Anexo';
    }
  }

  static TipoCampoFormulario? tryParse(String? valor) {
    switch (valor) {
      case 'texto_curto':
        return TipoCampoFormulario.textoCurto;
      case 'texto_longo':
        return TipoCampoFormulario.textoLongo;
      case 'inteiro':
        return TipoCampoFormulario.inteiro;
      case 'decimal':
        return TipoCampoFormulario.decimal;
      case 'moeda':
        return TipoCampoFormulario.moeda;
      case 'data':
        return TipoCampoFormulario.data;
      case 'data_hora':
        return TipoCampoFormulario.dataHora;
      case 'cpf':
        return TipoCampoFormulario.cpf;
      case 'cnpj':
        return TipoCampoFormulario.cnpj;
      case 'email':
        return TipoCampoFormulario.email;
      case 'telefone':
        return TipoCampoFormulario.telefone;
      case 'selecao':
        return TipoCampoFormulario.selecao;
      case 'multipla_selecao':
        return TipoCampoFormulario.multiplaSelecao;
      case 'caixa_marcacao':
        return TipoCampoFormulario.caixaMarcacao;
      case 'anexo':
        return TipoCampoFormulario.anexo;
      default:
        return null;
    }
  }

  static TipoCampoFormulario parse(String valor) {
    final tipo = tryParse(valor);
    if (tipo != null) {
      return tipo;
    }
    throw ArgumentError('TipoCampoFormulario invalido: $valor');
  }
}

enum StatusVersaoServico {
  rascunho('rascunho'),
  publicada('publicada'),
  arquivada('arquivada');

  final String val;
  const StatusVersaoServico(this.val);

  String get label {
    switch (this) {
      case StatusVersaoServico.rascunho:
        return 'Rascunho';
      case StatusVersaoServico.publicada:
        return 'Publicada';
      case StatusVersaoServico.arquivada:
        return 'Arquivada';
    }
  }

  static StatusVersaoServico? tryParse(String? valor) {
    switch (valor) {
      case 'rascunho':
        return StatusVersaoServico.rascunho;
      case 'publicada':
        return StatusVersaoServico.publicada;
      case 'arquivada':
        return StatusVersaoServico.arquivada;
      default:
        return null;
    }
  }

  static StatusVersaoServico parse(String valor) {
    final status = tryParse(valor);
    if (status != null) {
      return status;
    }
    throw ArgumentError('StatusVersaoServico invalido: $valor');
  }
}

enum StatusVersaoConjuntoRegras {
  rascunho('rascunho'),
  publicada('publicada'),
  arquivada('arquivada');

  final String val;
  const StatusVersaoConjuntoRegras(this.val);

  String get label {
    switch (this) {
      case StatusVersaoConjuntoRegras.rascunho:
        return 'Rascunho';
      case StatusVersaoConjuntoRegras.publicada:
        return 'Publicada';
      case StatusVersaoConjuntoRegras.arquivada:
        return 'Arquivada';
    }
  }

  static StatusVersaoConjuntoRegras? tryParse(String? valor) {
    switch (valor) {
      case 'rascunho':
        return StatusVersaoConjuntoRegras.rascunho;
      case 'publicada':
        return StatusVersaoConjuntoRegras.publicada;
      case 'arquivada':
        return StatusVersaoConjuntoRegras.arquivada;
      default:
        return null;
    }
  }

  static StatusVersaoConjuntoRegras parse(String valor) {
    final status = tryParse(valor);
    if (status != null) {
      return status;
    }
    throw ArgumentError('StatusVersaoConjuntoRegras invalido: $valor');
  }
}

enum StatusExecucao {
  emAndamento('em_andamento'),
  concluida('concluida'),
  cancelada('cancelada');

  final String val;
  const StatusExecucao(this.val);

  String get label {
    switch (this) {
      case StatusExecucao.emAndamento:
        return 'Em andamento';
      case StatusExecucao.concluida:
        return 'Concluida';
      case StatusExecucao.cancelada:
        return 'Cancelada';
    }
  }

  static StatusExecucao? tryParse(String? valor) {
    switch (valor) {
      case 'em_andamento':
        return StatusExecucao.emAndamento;
      case 'concluida':
        return StatusExecucao.concluida;
      case 'cancelada':
        return StatusExecucao.cancelada;
      default:
        return null;
    }
  }

  static StatusExecucao? tryParseBanco(String? valor) {
    return tryParse(valor);
  }

  static StatusExecucao parse(String valor) {
    final status = tryParse(valor);
    if (status != null) {
      return status;
    }
    throw ArgumentError('StatusExecucao invalido: $valor');
  }

  static StatusExecucao parseBanco(String valor) {
    return parse(valor);
  }
}

enum TipoPublicacao {
  noticia('noticia'),
  diarioOficial('diario_oficial'),
  editalPublico('edital_publico'),
  paginaInstitucional('pagina_institucional');

  final String val;
  const TipoPublicacao(this.val);

  String get label {
    switch (this) {
      case TipoPublicacao.noticia:
        return 'Noticia';
      case TipoPublicacao.diarioOficial:
        return 'Diario oficial';
      case TipoPublicacao.editalPublico:
        return 'Edital publico';
      case TipoPublicacao.paginaInstitucional:
        return 'Pagina institucional';
    }
  }

  static TipoPublicacao? tryParse(String? valor) {
    switch (valor) {
      case 'noticia':
        return TipoPublicacao.noticia;
      case 'diario_oficial':
        return TipoPublicacao.diarioOficial;
      case 'edital_publico':
        return TipoPublicacao.editalPublico;
      case 'pagina_institucional':
        return TipoPublicacao.paginaInstitucional;
      default:
        return null;
    }
  }

  static TipoPublicacao parse(String valor) {
    final tipo = tryParse(valor);
    if (tipo != null) {
      return tipo;
    }
    throw ArgumentError('TipoPublicacao invalido: $valor');
  }
}

enum StatusPublicacao {
  rascunho('rascunho'),
  agendada('agendada'),
  publicada('publicada'),
  arquivada('arquivada');

  final String val;

  const StatusPublicacao(this.val);

  String get label {
    switch (this) {
      case StatusPublicacao.rascunho:
        return 'Rascunho';
      case StatusPublicacao.agendada:
        return 'Agendada';
      case StatusPublicacao.publicada:
        return 'Publicada';
      case StatusPublicacao.arquivada:
        return 'Arquivada';
    }
  }

  static StatusPublicacao? tryParse(String? valor) {
    switch (valor) {
      case 'rascunho':
        return StatusPublicacao.rascunho;
      case 'agendada':
        return StatusPublicacao.agendada;
      case 'publicada':
        return StatusPublicacao.publicada;
      case 'arquivada':
        return StatusPublicacao.arquivada;
      default:
        return null;
    }
  }

  static StatusPublicacao parse(String valor) {
    final status = tryParse(valor);
    if (status != null) {
      return status;
    }
    throw ArgumentError('StatusPublicacao invalido: $valor');
  }
}

enum StatusItemTrabalhoRetaguarda {
  pendente('pendente'),
  emAnalise('em_analise'),
  aguardandoAcaoExterna('aguardando_acao_externa'),
  concluido('concluido');

  final String val;
  const StatusItemTrabalhoRetaguarda(this.val);

  String get label {
    switch (this) {
      case StatusItemTrabalhoRetaguarda.pendente:
        return 'Pendente';
      case StatusItemTrabalhoRetaguarda.emAnalise:
        return 'Em analise';
      case StatusItemTrabalhoRetaguarda.aguardandoAcaoExterna:
        return 'Aguardando acao externa';
      case StatusItemTrabalhoRetaguarda.concluido:
        return 'Concluido';
    }
  }

  static StatusItemTrabalhoRetaguarda? tryParse(String? valor) {
    switch (valor) {
      case 'pendente':
        return StatusItemTrabalhoRetaguarda.pendente;
      case 'em_analise':
        return StatusItemTrabalhoRetaguarda.emAnalise;
      case 'aguardando_acao_externa':
        return StatusItemTrabalhoRetaguarda.aguardandoAcaoExterna;
      case 'concluido':
        return StatusItemTrabalhoRetaguarda.concluido;
      default:
        return null;
    }
  }

  static StatusItemTrabalhoRetaguarda parse(String valor) {
    final status = tryParse(valor);
    if (status != null) {
      return status;
    }
    throw ArgumentError('StatusItemTrabalhoRetaguarda invalido: $valor');
  }
}
