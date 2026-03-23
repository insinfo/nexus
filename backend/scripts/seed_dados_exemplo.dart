import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:nexus_backend/src/shared/app_config.dart';
import 'package:nexus_backend/src/shared/db_service.dart';
import 'package:nexus_backend/src/shared/extensions/eloquent.dart';
import 'package:nexus_backend/src/shared/utils/protocolo_utils.dart';
import 'package:nexus_backend/src/shared/utils/seguranca_utils.dart';
import 'package:nexus_core/nexus_core.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()..addFlag('help', abbr: 'h', negatable: false);
  final args = parser.parse(arguments);

  if (args['help'] as bool) {
    print(parser.usage);
    return;
  }

  final appConfig = AppConfig.inst();
  final databaseService = DatabaseService(appConfig);
  final db = await databaseService.connect();

  try {
    await db.execute('begin');
    await _seedClientesOidc(db);
    await _seedCategoriasEEtiquetas(db);
    final contexto = await _seedEstruturaInstitucional(db);
    final servico = await _seedServicoInstitucional(db, contexto);
    await _seedServicosPublicadosAdicionais(db, contexto);
    await _seedConteudoPortal(db);
    await _limparDadosOperacionaisServico(db, servico);
    await _seedSubmissoesInstitucionais(db, contexto, servico);
    await db.execute('commit');
    print('Seed institucional do Nexus aplicado com sucesso.');
  } catch (e, s) {
    await db.execute('rollback');
    print('Falha ao aplicar seed institucional do Nexus: $e\n$s');
    await db.disconnect();
    exit(1);
  }
  await db.disconnect();
  exit(0);
}

class _ContextoInstitucional {
  const _ContextoInstitucional({
    required this.idOrganograma,
    required this.idUsuarioInterno,
  });

  final int idOrganograma;
  final int idUsuarioInterno;
}

class _ServicoInstitucional {
  const _ServicoInstitucional({
    required this.idServico,
    required this.idVersaoServico,
    required this.idVersaoConjuntoRegras,
    required this.idsFluxo,
  });

  final int idServico;
  final int idVersaoServico;
  final int idVersaoConjuntoRegras;
  final _FluxoSeedIds idsFluxo;
}

class _FluxoSeedIds {
  const _FluxoSeedIds({
    required this.idFluxo,
    required this.idNoInicio,
    required this.idNoFormulario,
    required this.idNoFim,
  });

  final int idFluxo;
  final int idNoInicio;
  final int idNoFormulario;
  final int idNoFim;
}

class _SubmissaoSeed {
  const _SubmissaoSeed({
    required this.idSessao,
    required this.idSubmissao,
    required this.idSubmissaoPublico,
    required this.status,
    required this.numeroProtocolo,
    required this.codigoPublico,
  });

  final int idSessao;
  final int idSubmissao;
  final String idSubmissaoPublico;
  final String status;
  final String numeroProtocolo;
  final String codigoPublico;
}

class _OpcaoCampoSeed {
  const _OpcaoCampoSeed({
    required this.valor,
    required this.rotulo,
    required this.ordem,
  });

  final String valor;
  final String rotulo;
  final int ordem;
}

class _CampoServicoPublicadoSeed {
  const _CampoServicoPublicadoSeed({
    required this.chave,
    required this.rotulo,
    required this.tipo,
    required this.ordem,
    this.obrigatorio = false,
    this.opcoes = const <_OpcaoCampoSeed>[],
  });

  final String chave;
  final String rotulo;
  final String tipo;
  final int ordem;
  final bool obrigatorio;
  final List<_OpcaoCampoSeed> opcoes;
}

class _ServicoPublicadoSeed {
  const _ServicoPublicadoSeed({
    required this.codigo,
    required this.nome,
    required this.slug,
    required this.descricao,
    required this.categoriaCodigo,
    required this.responsavelServico,
    required this.etiquetas,
    required this.tituloFluxo,
    required this.rotuloFormulario,
    required this.descricaoFormulario,
    required this.campos,
  });

  final String codigo;
  final String nome;
  final String slug;
  final String descricao;
  final String categoriaCodigo;
  final String responsavelServico;
  final List<String> etiquetas;
  final String tituloFluxo;
  final String rotuloFormulario;
  final String descricaoFormulario;
  final List<_CampoServicoPublicadoSeed> campos;
}

Future<void> _seedClientesOidc(dynamic db) async {
  await _upsertClienteOidc(
    db,
    ClienteOidc(
      idCliente: 'nexus-frontend-portal',
      nomeCliente: 'Nexus Frontend Portal',
      urisRedirecionamento: const <String>[
        'http://127.0.0.1:8080/',
        'http://127.0.0.1:8080/index.html',
        'http://localhost:8080/',
        'http://localhost:8080/index.html',
        'http://127.0.0.1:8084/',
        'http://127.0.0.1:8084/index.html',
        'http://localhost:8084/',
        'http://localhost:8084/index.html',
      ],
      escoposPermitidos: const <String>[
        'openid',
        'profile',
        'email',
        'offline_access',
        'nexus.servicos',
      ],
      tipoAplicacao: 'web_spa',
      urisRedirecionamentoPosLogout: const <String>[
        'http://127.0.0.1:8080/',
        'http://localhost:8080/',
        'http://127.0.0.1:8084/',
        'http://localhost:8084/',
      ],
      tiposGrantSuportados: const <String>[
        'authorization_code',
        'refresh_token',
      ],
      tiposRespostaSuportados: const <String>['code'],
      metodoAutenticacaoToken: 'none',
      ativo: true,
      criadoEm: DateTime.now().toUtc(),
      atualizadoEm: DateTime.now().toUtc(),
    ),
  );

  await _upsertClienteOidc(
    db,
    ClienteOidc(
      idCliente: 'nexus-frontend-backoffice',
      hashSegredoCliente:
          SegurancaUtils.gerarHashSenha('nexus-backoffice-dev-secret'),
      nomeCliente: 'Nexus Frontend Backoffice',
      urisRedirecionamento: const <String>[
        'http://127.0.0.1:8081/',
        'http://localhost:8081/',
      ],
      escoposPermitidos: const <String>[
        'openid',
        'profile',
        'email',
        'offline_access',
        'nexus.servicos',
      ],
      tipoAplicacao: 'backend_confidencial',
      urisRedirecionamentoPosLogout: const <String>[
        'http://127.0.0.1:8081/',
        'http://localhost:8081/',
      ],
      tiposGrantSuportados: const <String>[
        'authorization_code',
        'refresh_token',
      ],
      tiposRespostaSuportados: const <String>['code'],
      metodoAutenticacaoToken: 'client_secret_post',
      ativo: true,
      criadoEm: DateTime.now().toUtc(),
      atualizadoEm: DateTime.now().toUtc(),
    ),
  );
}

Future<void> _upsertClienteOidc(dynamic db, ClienteOidc cliente) async {
  final existente = await db
      .table(ClienteOidc.fqtb)
      .where(ClienteOidc.idClienteCol, Operator.equal, cliente.idCliente)
      .first();
  if (existente == null) {
    await db.table(ClienteOidc.fqtb).insert(cliente.toInsertMap());
    return;
  }

  await db
      .table(ClienteOidc.fqtb)
      .where(ClienteOidc.idClienteCol, Operator.equal, cliente.idCliente)
      .update(cliente.toUpdateMap());
}

Future<void> _seedCategoriasEEtiquetas(dynamic db) async {
  await _upsertCategoria(
    db,
    CategoriaServico(
      id: 0,
      codigo: 'beneficio-social',
      nome: 'Beneficio Social',
      descricao: 'Servicos sociais e beneficios municipais.',
      ativo: true,
    ),
  );
  await _upsertCategoria(
    db,
    CategoriaServico(
      id: 0,
      codigo: 'estagio-publico',
      nome: 'Estagio Publico',
      descricao: 'Editais e processos publicos de estagio municipal.',
      ativo: true,
    ),
  );
  await _upsertCategoria(
    db,
    CategoriaServico(
      id: 0,
      codigo: 'capacitacao-profissional',
      nome: 'Capacitacao Profissional',
      descricao: 'Cursos, matriculas e certificacoes profissionalizantes.',
      ativo: true,
    ),
  );

  await _upsertEtiqueta(
    db,
    EtiquetaServico(
      id: 0,
      codigo: 'salus',
      nome: 'SALUS',
    ),
  );
  await _upsertEtiqueta(
    db,
    EtiquetaServico(
      id: 0,
      codigo: 'piloto',
      nome: 'Piloto',
    ),
  );
  await _upsertEtiqueta(
    db,
    EtiquetaServico(
      id: 0,
      codigo: 'classificacao-auditavel',
      nome: 'Classificacao Auditavel',
    ),
  );
  await _upsertEtiqueta(
    db,
    EtiquetaServico(
      id: 0,
      codigo: 'sigep',
      nome: 'SIGEP',
    ),
  );
  await _upsertEtiqueta(
    db,
    EtiquetaServico(
      id: 0,
      codigo: 'sequal',
      nome: 'SEQUAL',
    ),
  );
}

Future<void> _seedServicosPublicadosAdicionais(
  dynamic db,
  _ContextoInstitucional contexto,
) async {
  await _seedServicoPublicadoCatalogo(
    db,
    contexto,
    const _ServicoPublicadoSeed(
      codigo: 'edital-estagio-sigep',
      nome: 'Edital de Estagio SIGEP',
      slug: 'edital-estagio-sigep',
      descricao:
          'Inscricao publica para estagio municipal com triagem e ranking publicados no Nexus.',
      categoriaCodigo: 'estagio-publico',
      responsavelServico: 'Secretaria de Gestao Publica',
      etiquetas: <String>['sigep', 'piloto', 'classificacao-auditavel'],
      tituloFluxo: 'Fluxo Publico SIGEP',
      rotuloFormulario: 'Inscricao para estagio',
      descricaoFormulario:
          'Informe os dados academicos e pessoais para participar do edital.',
      campos: <_CampoServicoPublicadoSeed>[
        _CampoServicoPublicadoSeed(
          chave: 'nome_completo',
          rotulo: 'Nome completo',
          tipo: 'texto_curto',
          ordem: 0,
          obrigatorio: true,
        ),
        _CampoServicoPublicadoSeed(
          chave: 'cpf',
          rotulo: 'CPF',
          tipo: 'cpf',
          ordem: 1,
          obrigatorio: true,
        ),
        _CampoServicoPublicadoSeed(
          chave: 'email',
          rotulo: 'Email',
          tipo: 'email',
          ordem: 2,
          obrigatorio: true,
        ),
        _CampoServicoPublicadoSeed(
          chave: 'curso',
          rotulo: 'Curso',
          tipo: 'texto_curto',
          ordem: 3,
          obrigatorio: true,
        ),
        _CampoServicoPublicadoSeed(
          chave: 'periodo_atual',
          rotulo: 'Periodo atual',
          tipo: 'inteiro',
          ordem: 4,
          obrigatorio: true,
        ),
        _CampoServicoPublicadoSeed(
          chave: 'coeficiente',
          rotulo: 'Coeficiente academico',
          tipo: 'decimal',
          ordem: 5,
          obrigatorio: true,
        ),
        _CampoServicoPublicadoSeed(
          chave: 'turno_preferencial',
          rotulo: 'Turno preferencial',
          tipo: 'selecao',
          ordem: 6,
          obrigatorio: true,
          opcoes: <_OpcaoCampoSeed>[
            _OpcaoCampoSeed(valor: 'manha', rotulo: 'Manha', ordem: 0),
            _OpcaoCampoSeed(valor: 'tarde', rotulo: 'Tarde', ordem: 1),
            _OpcaoCampoSeed(valor: 'integral', rotulo: 'Integral', ordem: 2),
          ],
        ),
      ],
    ),
  );

  await _seedServicoPublicadoCatalogo(
    db,
    contexto,
    const _ServicoPublicadoSeed(
      codigo: 'cursos-profissionalizantes-sequal',
      nome: 'Cursos Profissionalizantes SEQUAL',
      slug: 'cursos-profissionalizantes-sequal',
      descricao:
          'Inscricao publica em cursos profissionalizantes com matricula e acompanhamento no mesmo portal.',
      categoriaCodigo: 'capacitacao-profissional',
      responsavelServico: 'Secretaria de Qualificacao Profissional',
      etiquetas: <String>['sequal', 'piloto'],
      tituloFluxo: 'Fluxo Publico SEQUAL',
      rotuloFormulario: 'Inscricao em curso profissionalizante',
      descricaoFormulario:
          'Escolha curso, unidade e informe os dados basicos para a pre-inscricao.',
      campos: <_CampoServicoPublicadoSeed>[
        _CampoServicoPublicadoSeed(
          chave: 'nome_completo',
          rotulo: 'Nome completo',
          tipo: 'texto_curto',
          ordem: 0,
          obrigatorio: true,
        ),
        _CampoServicoPublicadoSeed(
          chave: 'cpf',
          rotulo: 'CPF',
          tipo: 'cpf',
          ordem: 1,
          obrigatorio: true,
        ),
        _CampoServicoPublicadoSeed(
          chave: 'telefone',
          rotulo: 'Telefone',
          tipo: 'telefone',
          ordem: 2,
          obrigatorio: true,
        ),
        _CampoServicoPublicadoSeed(
          chave: 'curso_interesse',
          rotulo: 'Curso de interesse',
          tipo: 'selecao',
          ordem: 3,
          obrigatorio: true,
          opcoes: <_OpcaoCampoSeed>[
            _OpcaoCampoSeed(
                valor: 'informatica', rotulo: 'Informatica', ordem: 0),
            _OpcaoCampoSeed(
                valor: 'gastronomia', rotulo: 'Gastronomia', ordem: 1),
            _OpcaoCampoSeed(valor: 'solda', rotulo: 'Solda', ordem: 2),
          ],
        ),
        _CampoServicoPublicadoSeed(
          chave: 'unidade_preferencial',
          rotulo: 'Unidade preferencial',
          tipo: 'selecao',
          ordem: 4,
          obrigatorio: true,
          opcoes: <_OpcaoCampoSeed>[
            _OpcaoCampoSeed(valor: 'centro', rotulo: 'Centro', ordem: 0),
            _OpcaoCampoSeed(valor: 'norte', rotulo: 'Norte', ordem: 1),
            _OpcaoCampoSeed(valor: 'sul', rotulo: 'Sul', ordem: 2),
          ],
        ),
        _CampoServicoPublicadoSeed(
          chave: 'renda_familiar',
          rotulo: 'Renda familiar',
          tipo: 'decimal',
          ordem: 5,
          obrigatorio: true,
        ),
        _CampoServicoPublicadoSeed(
          chave: 'aceita_turno_noturno',
          rotulo: 'Aceita turma noturna',
          tipo: 'caixa_marcacao',
          ordem: 6,
        ),
      ],
    ),
  );
}

Future<void> _seedServicoPublicadoCatalogo(
  dynamic db,
  _ContextoInstitucional contexto,
  _ServicoPublicadoSeed definicao,
) async {
  final idCategoria =
      await _buscarIdCategoriaPorCodigo(db, definicao.categoriaCodigo);
  final servico = Servico(
    id: 0,
    codigo: definicao.codigo,
    nome: definicao.nome,
    slug: definicao.slug,
    descricao: definicao.descricao,
    idCategoria: idCategoria,
    modoAcesso: 'publico_anonimo',
    responsavelServico: definicao.responsavelServico,
    exibirResponsavelServico: true,
    ativo: true,
  );

  final idServico = await _upsertServico(db, servico);
  for (final etiqueta in definicao.etiquetas) {
    await _vincularEtiqueta(db, idServico, etiqueta);
  }

  final versao = VersaoServico(
    id: 0,
    idServico: idServico,
    numeroVersao: 1,
    status: StatusVersaoServico.publicada.val,
    notas: 'Versao publicada para catalogo publico institucional.',
    snapshotMetadadosJson: jsonEncode(<String, dynamic>{
      'nome': servico.nome,
      'descricao': servico.descricao,
      'categoria': definicao.categoriaCodigo,
      'modo_acesso': 'publico_anonimo',
      'canais': <String>['portal_cidadao', 'retaguarda'],
      'etiquetas': definicao.etiquetas,
      'responsavel_servico': servico.responsavelServico,
      'exibir_responsavel_servico': true,
      'orgaos_permitidos': <int>[contexto.idOrganograma],
    }),
  );

  final idVersao = await _upsertVersao(db, versao);
  await _recriarCanais(db, idVersao);
  await _recriarVinculoOrganograma(db, idVersao, contexto.idOrganograma);
  await _recriarFluxoPublicoDefinido(db, idVersao, definicao);
}

Future<void> _seedConteudoPortal(dynamic db) async {
  await _limparConteudoPortal(db);

  await _inserirAtalhoPortal(
    db,
    AtalhoPortal(
      id: '0',
      rotulo: 'Servicos digitais',
      descricao: 'Acesse inscricoes, protocolos e acompanhamento do cidadao.',
      icone: 'ph-squares-four',
      rota: '/servicos',
    ),
  );
  await _inserirAtalhoPortal(
    db,
    AtalhoPortal(
      id: '0',
      rotulo: 'Editais de estagio',
      descricao: 'Inscricao, triagem e ranking anual de estagiarios.',
      icone: 'ph-student',
      rota: '/editais/estagio',
    ),
  );
  await _inserirAtalhoPortal(
    db,
    AtalhoPortal(
      id: '0',
      rotulo: 'Cursos profissionalizantes',
      descricao:
          'Inscricao, confirmacao de matricula e emissao posterior de certificados.',
      icone: 'ph-graduation-cap',
      rota: '/cursos-profissionalizantes',
    ),
  );
  await _inserirAtalhoPortal(
    db,
    AtalhoPortal(
      id: '0',
      rotulo: 'Beneficios e auxilios',
      descricao: 'Fluxos de elegibilidade, pontuacao e classificacao social.',
      icone: 'ph-hand-heart',
      rota: '/beneficios',
    ),
  );

  await _inserirNoticia(
    db,
    Noticia(
      id: '0',
      slug: 'nexus-salus-auxilio-emergencial',
      titulo: 'Auxilio emergencial passa a operar em fluxo unificado no Nexus',
      resumo:
          'Cadastro, analise documental, elegibilidade e classificacao do SALUS agora aparecem como servico versionado no catalogo da plataforma.',
      categoria: 'assistencia social',
      publicadoEm: DateTime.utc(2026, 3, 22, 10),
      destaque: true,
    ),
  );
  await _inserirNoticia(
    db,
    Noticia(
      id: '0',
      slug: 'nexus-sigep-estagio',
      titulo: 'Edital de estagio entra como template oficial do Nexus',
      resumo:
          'O SIGEP agora e tratado como servico com inscricao publica, ranking parametrizado e homologacao no mesmo motor.',
      categoria: 'gestao publica',
      publicadoEm: DateTime.utc(2026, 3, 21, 14),
    ),
  );
  await _inserirNoticia(
    db,
    Noticia(
      id: '0',
      slug: 'nexus-sequal-cursos',
      titulo:
          'SEQUAL passa a operar com inscricao, matricula e certificado no Nexus',
      resumo:
          'Cursos profissionalizantes agora entram no portal com jornada publica, operacao interna e emissao de certificados na mesma fundacao institucional.',
      categoria: 'educacao profissional',
      publicadoEm: DateTime.utc(2026, 3, 20, 16),
    ),
  );

  await _inserirPublicacaoOficial(
    db,
    PublicacaoOficial(
      id: '0',
      titulo: 'Lei 3.189/2026 - Auxilio Municipal Emergencial',
      tipo: TipoPublicacao.editalPublico,
      status: StatusPublicacao.publicada,
      codigoReferencia: 'JO-LEI-3189-2026',
      publicadoEm: DateTime.utc(2026, 3, 20, 8),
      areaEditorial: 'SEMBES',
      resumo:
          'Base normativa usada pelo template de beneficio com elegibilidade e classificacao do SALUS.',
    ),
  );
  await _inserirPublicacaoOficial(
    db,
    PublicacaoOficial(
      id: '0',
      titulo: 'Cronograma inicial da selecao de estagiarios 2026',
      tipo: TipoPublicacao.editalPublico,
      status: StatusPublicacao.publicada,
      codigoReferencia: 'EDITAL-SEGEP-ESTAGIO-2026',
      publicadoEm: DateTime.utc(2026, 3, 19, 9),
      areaEditorial: 'SEGEP',
      resumo:
          'Publicacao base do template de edital anual de estagio no Nexus.',
    ),
  );
  await _inserirPublicacaoOficial(
    db,
    PublicacaoOficial(
      id: '0',
      titulo: 'Calendario municipal dos cursos profissionalizantes 2026',
      tipo: TipoPublicacao.editalPublico,
      status: StatusPublicacao.publicada,
      codigoReferencia: 'EDITAL-SEQUAL-CURSOS-2026',
      publicadoEm: DateTime.utc(2026, 3, 18, 11),
      areaEditorial: 'SEQUAL',
      resumo:
          'Publicacao base do ciclo de inscricao, matricula e certificacao do SEQUAL dentro do Nexus.',
    ),
  );

  await _inserirPaginaInstitucional(
    db,
    PaginaInstitucional(
      id: '0',
      titulo: 'Carta de Servicos Digitais',
      slug: 'carta-de-servicos-digitais',
      secao: 'governanca',
      status: StatusPublicacao.publicada,
      resumo:
          'Compromissos da plataforma com transparencia, rastreabilidade e atendimento digital municipal.',
    ),
  );
  await _inserirPaginaInstitucional(
    db,
    PaginaInstitucional(
      id: '0',
      titulo: 'Politica de acompanhamento de protocolos',
      slug: 'politica-acompanhamento-protocolos',
      secao: 'atendimento',
      status: StatusPublicacao.publicada,
      resumo:
          'Diretrizes para consulta, devolutiva e acompanhamento publico das solicitacoes do cidadao.',
    ),
  );
  await _inserirPaginaInstitucional(
    db,
    PaginaInstitucional(
      id: '0',
      titulo: 'Programa municipal de estagio SIGEP',
      slug: 'programa-municipal-estagio-sigep',
      secao: 'selecao-publica',
      status: StatusPublicacao.publicada,
      resumo:
          'Pagina institucional do edital de estagio com orientacoes sobre inscricao, ranking e homologacao operados no Nexus.',
    ),
  );
  await _inserirPaginaInstitucional(
    db,
    PaginaInstitucional(
      id: '0',
      titulo: 'Cursos profissionalizantes SEQUAL',
      slug: 'cursos-profissionalizantes-sequal',
      secao: 'capacitacao',
      status: StatusPublicacao.publicada,
      resumo:
          'Pagina institucional para inscricao em cursos, acompanhamento de matricula e emissao publica de certificados.',
    ),
  );
}

Future<void> _limparConteudoPortal(dynamic db) async {
  await db.table(AtalhoPortal.fqtb).delete();
  await db.table(Noticia.fqtb).delete();
  await db.table(PublicacaoOficial.fqtb).delete();
  await db.table(PaginaInstitucional.fqtb).delete();
}

Future<_ContextoInstitucional> _seedEstruturaInstitucional(dynamic db) async {
  final idOrganograma = await _upsertOrganogramaInstitucional(db);
  final idUsuarioInterno = await _upsertUsuarioInterno(db);
  await _vincularUsuarioOrganograma(db, idUsuarioInterno, idOrganograma);
  return _ContextoInstitucional(
    idOrganograma: idOrganograma,
    idUsuarioInterno: idUsuarioInterno,
  );
}

Future<_ServicoInstitucional> _seedServicoInstitucional(
  dynamic db,
  _ContextoInstitucional contexto,
) async {
  final idCategoria = await _buscarIdCategoria(db);
  final servico = Servico(
    id: 0,
    codigo: 'auxilio-emergencial-salus',
    nome: 'Auxilio Emergencial SALUS',
    slug: 'auxilio-emergencial-salus',
    descricao:
        'Fluxo institucional completo de inscricao, triagem, classificacao e retorno publico.',
    idCategoria: idCategoria,
    modoAcesso: 'publico_anonimo',
    responsavelServico: 'Secretaria de Bem-Estar Social',
    exibirResponsavelServico: true,
    ativo: true,
  );

  final idServico = await _upsertServico(db, servico);
  await _vincularEtiqueta(db, idServico, 'salus');
  await _vincularEtiqueta(db, idServico, 'piloto');
  await _vincularEtiqueta(db, idServico, 'classificacao-auditavel');

  final versao = VersaoServico(
    id: 0,
    idServico: idServico,
    numeroVersao: 1,
    status: StatusVersaoServico.publicada.val,
    notas:
        'Versao institucional com operacao interna e classificacao auditavel.',
    snapshotMetadadosJson: jsonEncode(<String, dynamic>{
      'nome': servico.nome,
      'descricao': servico.descricao,
      'categoria': 'beneficio-social',
      'modo_acesso': 'publico_anonimo',
      'canais': <String>['portal_cidadao', 'retaguarda'],
      'etiquetas': <String>['salus', 'piloto', 'classificacao-auditavel'],
      'responsavel_servico': servico.responsavelServico,
      'exibir_responsavel_servico': true,
      'orgaos_permitidos': <int>[contexto.idOrganograma],
    }),
  );

  final idVersao = await _upsertVersao(db, versao);
  await _recriarCanais(db, idVersao);
  await _recriarVinculoOrganograma(db, idVersao, contexto.idOrganograma);
  final idsFluxo = await _recriarFluxoPublico(db, idVersao);
  final idVersaoConjuntoRegras = await _recriarConjuntoRegras(db, idServico);

  return _ServicoInstitucional(
    idServico: idServico,
    idVersaoServico: idVersao,
    idVersaoConjuntoRegras: idVersaoConjuntoRegras,
    idsFluxo: idsFluxo,
  );
}

Future<void> _limparDadosOperacionaisServico(
  dynamic db,
  _ServicoInstitucional servico,
) async {
  final submissoes = await db
      .table(Submissao.fqtn)
      .select([Submissao.idCol])
      .where(Submissao.idServicoCol, Operator.equal, servico.idServico)
      .get();
  final idsSubmissao = submissoes
      .map<int>((item) => item[Submissao.idCol] as int)
      .toList(growable: false);

  if (idsSubmissao.isNotEmpty) {
    await db
        .table(ResultadoClassificacao.fqtn)
        .whereIn(ResultadoClassificacao.idSubmissaoCol, idsSubmissao)
        .delete();
    await db
        .table('public.transicoes_tarefa')
        .whereIn(
            'id_tarefa',
            db
                .table('public.tarefas_internas')
                .select(['id']).whereIn('id_submissao', idsSubmissao))
        .delete();
    await db
        .table('public.comentarios_tarefa')
        .whereIn(
            'id_tarefa',
            db
                .table('public.tarefas_internas')
                .select(['id']).whereIn('id_submissao', idsSubmissao))
        .delete();
    await db
        .table('public.atribuicoes_tarefa')
        .whereIn(
            'id_tarefa',
            db
                .table('public.tarefas_internas')
                .select(['id']).whereIn('id_submissao', idsSubmissao))
        .delete();
    await db
        .table('public.tarefas_internas')
        .whereIn('id_submissao', idsSubmissao)
        .delete();
    await db
        .table(HistoricoStatusSubmissao.fqtn)
        .whereIn(HistoricoStatusSubmissao.idSubmissaoCol, idsSubmissao)
        .delete();
    await db
        .table(Protocolo.fqtn)
        .whereIn(Protocolo.idSubmissaoCol, idsSubmissao)
        .delete();
    await db
        .table(Submissao.fqtn)
        .whereIn(Submissao.idCol, idsSubmissao)
        .delete();
  }

  await db
      .table(ExecucaoClassificacao.fqtn)
      .where(ExecucaoClassificacao.idVersaoServicoCol, Operator.equal,
          servico.idVersaoServico)
      .delete();
  await db
      .table(SessaoExecucao.fqtn)
      .where(SessaoExecucao.idServicoCol, Operator.equal, servico.idServico)
      .delete();
}

Future<void> _seedSubmissoesInstitucionais(
  dynamic db,
  _ContextoInstitucional contexto,
  _ServicoInstitucional servico,
) async {
  final submetida = await _criarSessaoESubmissao(
    db,
    servico: servico,
    status: 'submetida',
    indice: 1,
    respostas: const <String, dynamic>{
      'nome_completo': 'Maria da Silva',
      'cpf': '11111111111',
      'renda_familiar': 980,
      'possui_criancas': true,
      'situacao_moradia': 'aluguel',
      'prioridade_social': true,
    },
    variaveis: const <String, dynamic>{
      'bairro': 'Centro',
    },
    sessaoConcluida: false,
  );

  final emAnalise = await _criarSessaoESubmissao(
    db,
    servico: servico,
    status: 'em_analise',
    indice: 2,
    respostas: const <String, dynamic>{
      'nome_completo': 'Joao Pereira',
      'cpf': '22222222222',
      'renda_familiar': 1350,
      'possui_criancas': true,
      'situacao_moradia': 'cedida',
      'prioridade_social': false,
    },
    variaveis: const <String, dynamic>{
      'bairro': 'Nova Esperanca',
    },
  );

  final homologada = await _criarSessaoESubmissao(
    db,
    servico: servico,
    status: 'homologada',
    indice: 3,
    respostas: const <String, dynamic>{
      'nome_completo': 'Ana Costa',
      'cpf': '33333333333',
      'renda_familiar': 820,
      'possui_criancas': true,
      'situacao_moradia': 'aluguel',
      'prioridade_social': true,
    },
    variaveis: const <String, dynamic>{
      'bairro': 'Residencial Verde',
    },
  );

  final inelegivel = await _criarSessaoESubmissao(
    db,
    servico: servico,
    status: 'inelegivel',
    indice: 4,
    respostas: const <String, dynamic>{
      'nome_completo': 'Carlos Lima',
      'cpf': '44444444444',
      'renda_familiar': 4200,
      'possui_criancas': false,
      'situacao_moradia': 'imovel_proprio',
      'prioridade_social': false,
    },
    variaveis: const <String, dynamic>{
      'bairro': 'Jardim Norte',
    },
  );

  await _registrarHistoricoStatus(
    db,
    idSubmissao: emAnalise.idSubmissao,
    statusAnterior: 'submetida',
    novoStatus: 'em_analise',
    motivo: 'Triagem institucional iniciada.',
  );
  await _criarTarefaAnalise(
    db,
    submissao: emAnalise,
    contexto: contexto,
    titulo: 'Triagem documental inicial',
    descricao:
        'Conferir informacoes cadastrais e validar a composicao familiar.',
  );

  await _registrarHistoricoStatus(
    db,
    idSubmissao: homologada.idSubmissao,
    statusAnterior: 'submetida',
    novoStatus: 'em_analise',
    motivo: 'Inscricao elegivel para avaliacao prioritaria.',
  );
  await _registrarHistoricoStatus(
    db,
    idSubmissao: homologada.idSubmissao,
    statusAnterior: 'em_analise',
    novoStatus: 'ranqueada',
    motivo: 'Pontuacao consolidada na classificacao institucional.',
  );
  await _registrarHistoricoStatus(
    db,
    idSubmissao: homologada.idSubmissao,
    statusAnterior: 'ranqueada',
    novoStatus: 'homologada',
    motivo: 'Resultado homologado pela secretaria responsavel.',
  );

  await _registrarHistoricoStatus(
    db,
    idSubmissao: inelegivel.idSubmissao,
    statusAnterior: 'submetida',
    novoStatus: 'em_analise',
    motivo: 'Encaminhada para avaliacao tecnica.',
  );
  await _registrarHistoricoStatus(
    db,
    idSubmissao: inelegivel.idSubmissao,
    statusAnterior: 'em_analise',
    novoStatus: 'inelegivel',
    motivo: 'Regra de renda e elegibilidade nao atendida.',
  );

  final idExecucao = await db.table(ExecucaoClassificacao.fqtn).insertGetId(
        ExecucaoClassificacao(
          id: 0,
          idVersaoServico: servico.idVersaoServico,
          idVersaoConjuntoRegras: servico.idVersaoConjuntoRegras,
          status: 'concluida',
          snapshotDatasetJson: jsonEncode(<String, dynamic>{
            'origem': 'seed_institucional',
            'submissoes': <String>[
              homologada.idSubmissaoPublico,
              inelegivel.idSubmissaoPublico,
            ],
          }),
          notas: 'Execucao auditavel inicial do seed institucional.',
        ).toInsertMap(),
        ExecucaoClassificacao.idCol,
      ) as int;

  await _salvarResultadoClassificacao(
    db,
    idExecucao: idExecucao,
    idSubmissao: homologada.idSubmissao,
    pontuacaoFinal: 110,
    posicaoFinal: 1,
    elegivel: true,
    justificativa: const <String, dynamic>{
      'pontuacoes_aplicadas': <Map<String, dynamic>>[
        <String, dynamic>{
          'chave_regra': 'renda_muito_baixa',
          'valor_pontuacao': 40
        },
        <String, dynamic>{
          'chave_regra': 'familia_com_criancas',
          'valor_pontuacao': 30
        },
        <String, dynamic>{
          'chave_regra': 'prioridade_social',
          'valor_pontuacao': 25
        },
        <String, dynamic>{
          'chave_regra': 'moradia_aluguel',
          'valor_pontuacao': 15
        },
      ],
      'falhas_elegibilidade': <dynamic>[],
    },
    numeroProtocolo: homologada.numeroProtocolo,
    idVersaoConjuntoRegras: servico.idVersaoConjuntoRegras,
    statusFinal: 'homologada',
  );

  await _salvarResultadoClassificacao(
    db,
    idExecucao: idExecucao,
    idSubmissao: inelegivel.idSubmissao,
    pontuacaoFinal: 0,
    posicaoFinal: null,
    elegivel: false,
    justificativa: const <String, dynamic>{
      'pontuacoes_aplicadas': <dynamic>[],
      'falhas_elegibilidade': <Map<String, dynamic>>[
        <String, dynamic>{
          'chave_regra': 'renda_maxima',
          'motivo_falha': 'Renda familiar acima do limite municipal.'
        },
        <String, dynamic>{
          'chave_regra': 'moradia_prioritaria',
          'motivo_falha': 'Beneficio direcionado a familias sem imovel proprio.'
        },
      ],
    },
    numeroProtocolo: inelegivel.numeroProtocolo,
    idVersaoConjuntoRegras: servico.idVersaoConjuntoRegras,
    statusFinal: 'inelegivel',
  );

  await _criarTarefaAnalise(
    db,
    submissao: submetida,
    contexto: contexto,
    titulo: 'Aguardar triagem automatica',
    descricao: 'Solicitacao recem-recebida aguardando distribuicao interna.',
    status: 'aberta',
  );
}

Future<int> _upsertOrganogramaInstitucional(dynamic db) async {
  final existente = await db
      .table('public.organograma_historico')
      .where('sigla', Operator.equal, 'SEBES')
      .where('ultimo', Operator.equal, true)
      .first();
  if (existente != null) {
    return existente['id_organograma'] as int;
  }

  final idOrganograma = await db.table('public.organograma').insertGetId(
    <String, dynamic>{'ativo': true},
    'id',
  ) as int;
  await db.table('public.organograma_historico').insert(<String, dynamic>{
    'id_organograma': idOrganograma,
    'data_inicio': DateTime.utc(2026, 1, 1).toIso8601String().substring(0, 10),
    'sigla': 'SEBES',
    'nome': 'Secretaria de Bem-Estar Social',
    'tipo': 'Secretaria',
    'sub_tipo': 'Prefeitura',
    'ultimo': true,
    'secretaria': true,
    'oficial': true,
    'recebe_processo': 1,
    'protocolo': true,
    'permissao_selecao': 1,
    'caixa_entrada': true,
    'cor': '#0d6efd',
  });
  return idOrganograma;
}

Future<int> _upsertUsuarioInterno(dynamic db) async {
  final existente = await db
      .table('public.usuarios')
      .where('nome_usuario', Operator.equal, 'analista.salus')
      .first();
  if (existente != null) {
    await db
        .table('public.usuarios')
        .where('id', Operator.equal, existente['id'])
        .update(<String, dynamic>{
      'email': 'analista.salus@nexus.local',
      'nome_exibicao': 'Analista SALUS',
      'tipo_conta': 'interno',
      'ativo': true,
      'atualizado_em': DateTime.now().toIso8601String(),
    });
    return existente['id'] as int;
  }

  return await db.table('public.usuarios').insertGetId(
    <String, dynamic>{
      'nome_usuario': 'analista.salus',
      'email': 'analista.salus@nexus.local',
      'nome_exibicao': 'Analista SALUS',
      'tipo_conta': 'interno',
      'ativo': true,
    },
    'id',
  ) as int;
}

Future<void> _vincularUsuarioOrganograma(
  dynamic db,
  int idUsuario,
  int idOrganograma,
) async {
  final existente = await db
      .table('public.usuarios_organograma')
      .where('id_usuario', Operator.equal, idUsuario)
      .where('id_organograma', Operator.equal, idOrganograma)
      .first();
  if (existente != null) {
    return;
  }

  await db.table('public.usuarios_organograma').insert(<String, dynamic>{
    'id_usuario': idUsuario,
    'id_organograma': idOrganograma,
    'principal': true,
  });
}

Future<int> _buscarIdCategoria(dynamic db) async {
  final row = await db
      .table(CategoriaServico.fqtn)
      .where(CategoriaServico.codigoCol, Operator.equal, 'beneficio-social')
      .first();
  return CategoriaServico.fromMap(row).id;
}

Future<int> _buscarIdCategoriaPorCodigo(
    dynamic db, String codigoCategoria) async {
  final row = await db
      .table(CategoriaServico.fqtn)
      .where(CategoriaServico.codigoCol, Operator.equal, codigoCategoria)
      .first();
  return CategoriaServico.fromMap(row).id;
}

Future<int> _upsertCategoria(dynamic db, CategoriaServico categoria) async {
  final existente = await db
      .table(CategoriaServico.fqtn)
      .where(CategoriaServico.codigoCol, Operator.equal, categoria.codigo)
      .first();

  if (existente != null) {
    await db
        .table(CategoriaServico.fqtn)
        .where(CategoriaServico.idCol, Operator.equal,
            existente[CategoriaServico.idCol])
        .update(categoria.toUpdateMap());
    return existente[CategoriaServico.idCol] as int;
  }

  return await db.table(CategoriaServico.fqtn).insertGetId(
        categoria.toInsertMap(),
        CategoriaServico.idCol,
      ) as int;
}

Future<int> _upsertEtiqueta(dynamic db, EtiquetaServico etiqueta) async {
  final existente = await db
      .table(EtiquetaServico.fqtn)
      .where(EtiquetaServico.codigoCol, Operator.equal, etiqueta.codigo)
      .first();

  if (existente != null) {
    await db
        .table(EtiquetaServico.fqtn)
        .where(EtiquetaServico.idCol, Operator.equal,
            existente[EtiquetaServico.idCol])
        .update(etiqueta.toUpdateMap());
    return existente[EtiquetaServico.idCol] as int;
  }

  return await db.table(EtiquetaServico.fqtn).insertGetId(
        etiqueta.toInsertMap(),
        EtiquetaServico.idCol,
      ) as int;
}

Future<int> _upsertServico(dynamic db, Servico servico) async {
  final existente = await db
      .table(Servico.fqtn)
      .where(Servico.codigoCol, Operator.equal, servico.codigo)
      .first();

  if (existente != null) {
    await db
        .table(Servico.fqtn)
        .where(Servico.idCol, Operator.equal, existente[Servico.idCol])
        .update(servico.toUpdateMap());
    return existente[Servico.idCol] as int;
  }

  return await db.table(Servico.fqtn).insertGetId(
        servico.toInsertMap(),
        Servico.idCol,
      ) as int;
}

Future<void> _vincularEtiqueta(
    dynamic db, int idServico, String codigoEtiqueta) async {
  final etiqueta = await db
      .table(EtiquetaServico.fqtn)
      .where(EtiquetaServico.codigoCol, Operator.equal, codigoEtiqueta)
      .first();
  if (etiqueta == null) {
    return;
  }

  final existente = await db
      .table(ServicoEtiqueta.fqtn)
      .where(ServicoEtiqueta.idServicoCol, Operator.equal, idServico)
      .where(ServicoEtiqueta.idEtiquetaCol, Operator.equal,
          etiqueta[EtiquetaServico.idCol])
      .first();

  if (existente == null) {
    await db.table(ServicoEtiqueta.fqtn).insert(
          ServicoEtiqueta(
            id: 0,
            idServico: idServico,
            idEtiqueta: etiqueta[EtiquetaServico.idCol] as int,
          ).toInsertMap(),
        );
  }
}

Future<int> _upsertVersao(dynamic db, VersaoServico versao) async {
  final existente = await db
      .table(VersaoServico.fqtn)
      .where(VersaoServico.idServicoCol, Operator.equal, versao.idServico)
      .where(VersaoServico.numeroVersaoCol, Operator.equal, versao.numeroVersao)
      .first();

  if (existente != null) {
    await db
        .table(VersaoServico.fqtn)
        .where(
            VersaoServico.idCol, Operator.equal, existente[VersaoServico.idCol])
        .update(versao.toUpdateMap());
    return existente[VersaoServico.idCol] as int;
  }

  return await db.table(VersaoServico.fqtn).insertGetId(
        versao.toInsertMap(),
        VersaoServico.idCol,
      ) as int;
}

Future<int> _inserirAtalhoPortal(dynamic db, AtalhoPortal atalho) async {
  return await db.table(AtalhoPortal.fqtb).insertGetId(
        atalho.toInsertMap(),
        AtalhoPortal.idCol,
      ) as int;
}

Future<int> _inserirNoticia(dynamic db, Noticia noticia) async {
  return await db.table(Noticia.fqtb).insertGetId(
        noticia.toInsertMap(),
        Noticia.idCol,
      ) as int;
}

Future<int> _inserirPublicacaoOficial(
  dynamic db,
  PublicacaoOficial publicacao,
) async {
  return await db.table(PublicacaoOficial.fqtb).insertGetId(
        publicacao.toInsertMap(),
        PublicacaoOficial.idCol,
      ) as int;
}

Future<int> _inserirPaginaInstitucional(
  dynamic db,
  PaginaInstitucional pagina,
) async {
  return await db.table(PaginaInstitucional.fqtb).insertGetId(
        pagina.toInsertMap(),
        PaginaInstitucional.idCol,
      ) as int;
}

Future<void> _recriarCanais(dynamic db, int idVersao) async {
  await db
      .table(CanalVersaoServico.fqtn)
      .where(CanalVersaoServico.idVersaoServicoCol, Operator.equal, idVersao)
      .delete();

  await db.table(CanalVersaoServico.fqtn).insert(
        CanalVersaoServico(
          id: 0,
          idVersaoServico: idVersao,
          canal: 'portal_cidadao',
          visivel: true,
          configuracaoJson: '{}',
        ).toInsertMap(),
      );

  await db.table(CanalVersaoServico.fqtn).insert(
        CanalVersaoServico(
          id: 0,
          idVersaoServico: idVersao,
          canal: 'retaguarda',
          visivel: true,
          configuracaoJson: '{}',
        ).toInsertMap(),
      );
}

Future<void> _recriarVinculoOrganograma(
  dynamic db,
  int idVersao,
  int idOrganograma,
) async {
  await db
      .table('public.servicos_organograma')
      .where('id_versao_servico', Operator.equal, idVersao)
      .delete();
  await db.table('public.servicos_organograma').insert(<String, dynamic>{
    'id_versao_servico': idVersao,
    'id_organograma': idOrganograma,
  });
}

Future<_FluxoSeedIds> _recriarFluxoPublico(dynamic db, int idVersao) async {
  final fluxos = await db
      .table(DefinicaoFluxo.fqtn)
      .where(DefinicaoFluxo.idVersaoServicoCol, Operator.equal, idVersao)
      .get();

  for (final fluxo in fluxos) {
    final idFluxo = fluxo[DefinicaoFluxo.idCol] as int;
    final idsNos = await _idsNosPorFluxo(db, idFluxo);

    await db
        .table(ArestaFluxo.fqtn)
        .where(ArestaFluxo.idDefinicaoFluxoCol, Operator.equal, idFluxo)
        .delete();

    if (idsNos.isNotEmpty) {
      await db
          .table(CampoFormulario.fqtn)
          .whereIn(CampoFormulario.idNoFluxoCol, idsNos)
          .delete();
    }

    await db
        .table(NoFluxo.fqtn)
        .where(NoFluxo.idDefinicaoFluxoCol, Operator.equal, idFluxo)
        .delete();
  }

  await db
      .table(DefinicaoFluxo.fqtn)
      .where(DefinicaoFluxo.idVersaoServicoCol, Operator.equal, idVersao)
      .delete();

  final fluxo = DefinicaoFluxo(
    id: 0,
    idVersaoServico: idVersao,
    chaveFluxo: 'entrada_dados',
    tipoFluxo: 'entrada_dados',
    titulo: 'Fluxo Publico SALUS',
    pontoEntrada: true,
  );

  final idFluxo = await db.table(DefinicaoFluxo.fqtn).insertGetId(
        fluxo.toInsertMap(),
        DefinicaoFluxo.idCol,
      ) as int;

  final noInicio = NoFluxo(
    id: 0,
    idDefinicaoFluxo: idFluxo,
    chaveNo: 'inicio_1',
    tipoNo: 'inicio',
    rotulo: 'Inicio',
    posicaoX: 0,
    posicaoY: 0,
    dadosJson: jsonEncode(<String, dynamic>{'rotulo': 'Inicio'}),
  );

  final noFormulario = NoFluxo(
    id: 0,
    idDefinicaoFluxo: idFluxo,
    chaveNo: 'formulario_1',
    tipoNo: 'formulario',
    rotulo: 'Formulario Inicial',
    posicaoX: 240,
    posicaoY: 0,
    largura: 420,
    altura: 260,
    dadosJson: jsonEncode(<String, dynamic>{
      'rotulo': 'Inscricao inicial',
      'descricao': 'Informe seus dados para abrir a solicitacao.',
    }),
  );

  final noFim = NoFluxo(
    id: 0,
    idDefinicaoFluxo: idFluxo,
    chaveNo: 'fim_1',
    tipoNo: 'fim',
    rotulo: 'Concluido',
    posicaoX: 720,
    posicaoY: 0,
    dadosJson: jsonEncode(
        <String, dynamic>{'rotulo': 'Concluido', 'finaliza_fluxo': true}),
  );

  final idNoInicio = await db.table(NoFluxo.fqtn).insertGetId(
        noInicio.toInsertMap(),
        NoFluxo.idCol,
      ) as int;
  final idNoFormulario = await db.table(NoFluxo.fqtn).insertGetId(
        noFormulario.toInsertMap(),
        NoFluxo.idCol,
      ) as int;
  final idNoFim = await db.table(NoFluxo.fqtn).insertGetId(
        noFim.toInsertMap(),
        NoFluxo.idCol,
      ) as int;

  await _criarCampo(
      db, idNoFormulario, 'nome_completo', 'Nome completo', 'texto_curto', 0,
      obrigatorio: true);
  await _criarCampo(db, idNoFormulario, 'cpf', 'CPF', 'cpf', 1,
      obrigatorio: true);
  await _criarCampo(
      db, idNoFormulario, 'renda_familiar', 'Renda familiar', 'decimal', 2,
      obrigatorio: true);
  await _criarCampo(db, idNoFormulario, 'possui_criancas', 'Possui criancas',
      'caixa_marcacao', 3);
  await _criarCampo(db, idNoFormulario, 'situacao_moradia',
      'Situacao de moradia', 'selecao', 4,
      obrigatorio: true);
  await _criarCampo(db, idNoFormulario, 'prioridade_social',
      'Prioridade social', 'caixa_marcacao', 5);

  await db.table(ArestaFluxo.fqtn).insert(
        ArestaFluxo(
          id: 0,
          idDefinicaoFluxo: idFluxo,
          chaveAresta: 'aresta_inicio_formulario',
          idNoOrigem: idNoInicio,
          idNoDestino: idNoFormulario,
        ).toInsertMap(),
      );

  await db.table(ArestaFluxo.fqtn).insert(
        ArestaFluxo(
          id: 0,
          idDefinicaoFluxo: idFluxo,
          chaveAresta: 'aresta_formulario_fim',
          idNoOrigem: idNoFormulario,
          idNoDestino: idNoFim,
        ).toInsertMap(),
      );

  return _FluxoSeedIds(
    idFluxo: idFluxo,
    idNoInicio: idNoInicio,
    idNoFormulario: idNoFormulario,
    idNoFim: idNoFim,
  );
}

Future<void> _recriarFluxoPublicoDefinido(
  dynamic db,
  int idVersao,
  _ServicoPublicadoSeed definicao,
) async {
  final fluxos = await db
      .table(DefinicaoFluxo.fqtn)
      .where(DefinicaoFluxo.idVersaoServicoCol, Operator.equal, idVersao)
      .get();

  for (final fluxo in fluxos) {
    final idFluxo = fluxo[DefinicaoFluxo.idCol] as int;
    final idsNos = await _idsNosPorFluxo(db, idFluxo);

    await db
        .table(ArestaFluxo.fqtn)
        .where(ArestaFluxo.idDefinicaoFluxoCol, Operator.equal, idFluxo)
        .delete();

    if (idsNos.isNotEmpty) {
      await db
          .table(CampoFormulario.fqtn)
          .whereIn(CampoFormulario.idNoFluxoCol, idsNos)
          .delete();
    }

    await db
        .table(NoFluxo.fqtn)
        .where(NoFluxo.idDefinicaoFluxoCol, Operator.equal, idFluxo)
        .delete();
  }

  await db
      .table(DefinicaoFluxo.fqtn)
      .where(DefinicaoFluxo.idVersaoServicoCol, Operator.equal, idVersao)
      .delete();

  final fluxo = DefinicaoFluxo(
    id: 0,
    idVersaoServico: idVersao,
    chaveFluxo: 'entrada_dados',
    tipoFluxo: 'entrada_dados',
    titulo: definicao.tituloFluxo,
    pontoEntrada: true,
  );

  final idFluxo = await db.table(DefinicaoFluxo.fqtn).insertGetId(
        fluxo.toInsertMap(),
        DefinicaoFluxo.idCol,
      ) as int;

  final noInicio = NoFluxo(
    id: 0,
    idDefinicaoFluxo: idFluxo,
    chaveNo: 'inicio_1',
    tipoNo: 'inicio',
    rotulo: 'Inicio',
    posicaoX: 0,
    posicaoY: 0,
    dadosJson: jsonEncode(<String, dynamic>{'rotulo': 'Inicio'}),
  );
  final noFormulario = NoFluxo(
    id: 0,
    idDefinicaoFluxo: idFluxo,
    chaveNo: 'formulario_1',
    tipoNo: 'formulario',
    rotulo: definicao.rotuloFormulario,
    posicaoX: 240,
    posicaoY: 0,
    largura: 420,
    altura: 260,
    dadosJson: jsonEncode(<String, dynamic>{
      'rotulo': definicao.rotuloFormulario,
      'descricao': definicao.descricaoFormulario,
    }),
  );
  final noFim = NoFluxo(
    id: 0,
    idDefinicaoFluxo: idFluxo,
    chaveNo: 'fim_1',
    tipoNo: 'fim',
    rotulo: 'Concluido',
    posicaoX: 720,
    posicaoY: 0,
    dadosJson: jsonEncode(<String, dynamic>{
      'rotulo': 'Concluido',
      'finaliza_fluxo': true,
    }),
  );

  final idNoInicio = await db.table(NoFluxo.fqtn).insertGetId(
        noInicio.toInsertMap(),
        NoFluxo.idCol,
      ) as int;
  final idNoFormulario = await db.table(NoFluxo.fqtn).insertGetId(
        noFormulario.toInsertMap(),
        NoFluxo.idCol,
      ) as int;
  final idNoFim = await db.table(NoFluxo.fqtn).insertGetId(
        noFim.toInsertMap(),
        NoFluxo.idCol,
      ) as int;

  for (final campo in definicao.campos) {
    await _criarCampoDefinido(db, idNoFormulario, campo);
  }

  await db.table(ArestaFluxo.fqtn).insert(
        ArestaFluxo(
          id: 0,
          idDefinicaoFluxo: idFluxo,
          chaveAresta: 'aresta_inicio_formulario',
          idNoOrigem: idNoInicio,
          idNoDestino: idNoFormulario,
        ).toInsertMap(),
      );
  await db.table(ArestaFluxo.fqtn).insert(
        ArestaFluxo(
          id: 0,
          idDefinicaoFluxo: idFluxo,
          chaveAresta: 'aresta_formulario_fim',
          idNoOrigem: idNoFormulario,
          idNoDestino: idNoFim,
        ).toInsertMap(),
      );
}

Future<void> _criarCampoDefinido(
  dynamic db,
  int idNoFormulario,
  _CampoServicoPublicadoSeed campo,
) async {
  final idCampo = await db.table(CampoFormulario.fqtn).insertGetId(
        CampoFormulario(
          id: 0,
          idNoFluxo: idNoFormulario,
          chaveCampo: campo.chave,
          rotulo: campo.rotulo,
          tipoCampo: campo.tipo,
          obrigatorio: campo.obrigatorio,
          ordem: campo.ordem,
        ).toInsertMap(),
        CampoFormulario.idCol,
      ) as int;

  for (final opcao in campo.opcoes) {
    await db.table(OpcaoCampo.fqtn).insert(
          OpcaoCampo(
            id: 0,
            idCampo: idCampo,
            valorOpcao: opcao.valor,
            rotuloOpcao: opcao.rotulo,
            ordem: opcao.ordem,
          ).toInsertMap(),
        );
  }
}

Future<void> _criarCampo(
  dynamic db,
  int idNoFormulario,
  String chave,
  String rotulo,
  String tipo,
  int ordem, {
  bool obrigatorio = false,
}) async {
  final idCampo = await db.table(CampoFormulario.fqtn).insertGetId(
        CampoFormulario(
          id: 0,
          idNoFluxo: idNoFormulario,
          chaveCampo: chave,
          rotulo: rotulo,
          tipoCampo: tipo,
          obrigatorio: obrigatorio,
          ordem: ordem,
        ).toInsertMap(),
        CampoFormulario.idCol,
      ) as int;

  if (tipo != 'selecao') {
    return;
  }

  final opcoes = <Map<String, dynamic>>[
    <String, dynamic>{'valor': 'aluguel', 'rotulo': 'Aluguel', 'ordem': 0},
    <String, dynamic>{'valor': 'cedida', 'rotulo': 'Cedida', 'ordem': 1},
    <String, dynamic>{
      'valor': 'imovel_proprio',
      'rotulo': 'Imovel proprio',
      'ordem': 2
    },
  ];
  for (final opcao in opcoes) {
    await db.table(OpcaoCampo.fqtn).insert(
          OpcaoCampo(
            id: 0,
            idCampo: idCampo,
            valorOpcao: opcao['valor'] as String,
            rotuloOpcao: opcao['rotulo'] as String,
            ordem: opcao['ordem'] as int,
          ).toInsertMap(),
        );
  }
}

Future<int> _recriarConjuntoRegras(dynamic db, int idServico) async {
  final existente = await db
      .table('public.conjuntos_regras')
      .where('id_servico', Operator.equal, idServico)
      .where('codigo', Operator.equal, 'auxilio-emergencial')
      .first();

  final idConjunto = existente == null
      ? await db.table('public.conjuntos_regras').insertGetId(
          <String, dynamic>{
            'id_servico': idServico,
            'codigo': 'auxilio-emergencial',
            'nome': 'Classificacao Auxilio Emergencial',
            'descricao':
                'Regras institucionais de elegibilidade e pontuacao do beneficio.',
            'ativo': true,
          },
          'id',
        ) as int
      : existente['id'] as int;

  if (existente != null) {
    await db
        .table('public.conjuntos_regras')
        .where('id', Operator.equal, idConjunto)
        .update(<String, dynamic>{
      'nome': 'Classificacao Auxilio Emergencial',
      'descricao':
          'Regras institucionais de elegibilidade e pontuacao do beneficio.',
      'ativo': true,
      'atualizado_em': DateTime.now().toIso8601String(),
    });
  }

  final versoesExistentes = await db
      .table(VersaoConjuntoRegras.fqtn)
      .where(
          VersaoConjuntoRegras.idConjuntoRegrasCol, Operator.equal, idConjunto)
      .get();
  for (final versao in versoesExistentes) {
    final idVersao = versao[VersaoConjuntoRegras.idCol] as int;
    await db
        .table(RegraPontuacao.fqtn)
        .where(
            RegraPontuacao.idVersaoConjuntoRegrasCol, Operator.equal, idVersao)
        .delete();
    await db
        .table(RegraElegibilidade.fqtn)
        .where(RegraElegibilidade.idVersaoConjuntoRegrasCol, Operator.equal,
            idVersao)
        .delete();
  }
  await db
      .table(VersaoConjuntoRegras.fqtn)
      .where(
          VersaoConjuntoRegras.idConjuntoRegrasCol, Operator.equal, idConjunto)
      .delete();

  final definicao = <String, dynamic>{
    'codigo': 'auxilio-emergencial',
    'descricao':
        'Versao publicada com pesos sociais e travas de elegibilidade.',
  };
  final idVersao = await db.table(VersaoConjuntoRegras.fqtn).insertGetId(
        VersaoConjuntoRegras(
          id: 0,
          idConjuntoRegras: idConjunto,
          numeroVersao: 1,
          status: StatusVersaoConjuntoRegras.publicada.val,
          descricao: 'Versao publicada do seed institucional.',
          definicaoJson: jsonEncode(definicao),
          publicadoEm: DateTime.now(),
        ).toInsertMap(),
        VersaoConjuntoRegras.idCol,
      ) as int;

  final regrasPontuacao = <RegraPontuacao>[
    RegraPontuacao(
      id: 0,
      idVersaoConjuntoRegras: idVersao,
      chaveRegra: 'renda_muito_baixa',
      titulo: 'Renda familiar ate 1200',
      expressaoJson: jsonEncode(<String, dynamic>{
        'tipo': 'comparacao',
        'campo': 'renda_familiar',
        'operador': 'lte',
        'valor': 1200,
      }),
      valorPontuacao: 40,
      ordem: 0,
    ),
    RegraPontuacao(
      id: 0,
      idVersaoConjuntoRegras: idVersao,
      chaveRegra: 'familia_com_criancas',
      titulo: 'Familia com criancas',
      expressaoJson: jsonEncode(<String, dynamic>{
        'tipo': 'comparacao',
        'campo': 'possui_criancas',
        'operador': 'eq',
        'valor': true,
      }),
      valorPontuacao: 30,
      ordem: 1,
    ),
    RegraPontuacao(
      id: 0,
      idVersaoConjuntoRegras: idVersao,
      chaveRegra: 'prioridade_social',
      titulo: 'Marcador social prioritario',
      expressaoJson: jsonEncode(<String, dynamic>{
        'tipo': 'comparacao',
        'campo': 'prioridade_social',
        'operador': 'eq',
        'valor': true,
      }),
      valorPontuacao: 25,
      ordem: 2,
    ),
    RegraPontuacao(
      id: 0,
      idVersaoConjuntoRegras: idVersao,
      chaveRegra: 'moradia_aluguel',
      titulo: 'Moradia em aluguel',
      expressaoJson: jsonEncode(<String, dynamic>{
        'tipo': 'comparacao',
        'campo': 'situacao_moradia',
        'operador': 'eq',
        'valor': 'aluguel',
      }),
      valorPontuacao: 15,
      ordem: 3,
    ),
  ];

  final regrasElegibilidade = <RegraElegibilidade>[
    RegraElegibilidade(
      id: 0,
      idVersaoConjuntoRegras: idVersao,
      chaveRegra: 'renda_maxima',
      titulo: 'Renda familiar ate 2500',
      expressaoJson: jsonEncode(<String, dynamic>{
        'tipo': 'comparacao',
        'campo': 'renda_familiar',
        'operador': 'lte',
        'valor': 2500,
      }),
      motivoFalha: 'Renda familiar acima do limite municipal.',
      ordem: 0,
    ),
    RegraElegibilidade(
      id: 0,
      idVersaoConjuntoRegras: idVersao,
      chaveRegra: 'moradia_prioritaria',
      titulo: 'Sem imovel proprio',
      expressaoJson: jsonEncode(<String, dynamic>{
        'tipo': 'comparacao',
        'campo': 'situacao_moradia',
        'operador': 'neq',
        'valor': 'imovel_proprio',
      }),
      motivoFalha: 'Beneficio direcionado a familias sem imovel proprio.',
      ordem: 1,
    ),
  ];

  for (final regra in regrasPontuacao) {
    await db.table(RegraPontuacao.fqtn).insert(regra.toInsertMap());
  }
  for (final regra in regrasElegibilidade) {
    await db.table(RegraElegibilidade.fqtn).insert(regra.toInsertMap());
  }

  return idVersao;
}

Future<_SubmissaoSeed> _criarSessaoESubmissao(
  dynamic db, {
  required _ServicoInstitucional servico,
  required String status,
  required int indice,
  required Map<String, dynamic> respostas,
  required Map<String, dynamic> variaveis,
  bool sessaoConcluida = true,
}) async {
  final contexto = <String, dynamic>{
    'respostas': respostas,
    'variaveis': variaveis,
    'resultados_integracao': <String, dynamic>{},
  };
  final idSessao = await db.table(SessaoExecucao.fqtn).insertGetId(
        SessaoExecucao(
          id: 0,
          idServico: servico.idServico,
          idVersaoServico: servico.idVersaoServico,
          idFluxoAtual: servico.idsFluxo.idFluxo,
          idNoAtual: sessaoConcluida
              ? servico.idsFluxo.idNoFim
              : servico.idsFluxo.idNoFormulario,
          canal: 'portal_cidadao',
          status: sessaoConcluida ? 'concluida' : 'em_andamento',
          contextoJson: jsonEncode(contexto),
          snapshotFluxoJson: jsonEncode(<String, dynamic>{
            'fluxo': 'entrada_dados',
            'versao': 1,
          }),
          finalizadaEm: sessaoConcluida ? DateTime.now() : null,
        ).toInsertMap(),
        SessaoExecucao.idCol,
      ) as int;

  final idSubmissao = await db.table(Submissao.fqtn).insertGetId(
        Submissao(
          id: 0,
          idServico: servico.idServico,
          idVersaoServico: servico.idVersaoServico,
          idVersaoConjuntoRegras: null,
          idSessaoExecucao: idSessao,
          status: status,
          snapshotJson: jsonEncode(contexto),
        ).toInsertMap(),
        Submissao.idCol,
      ) as int;

  final submissaoRow = await db
      .table(Submissao.fqtn)
      .where(Submissao.idCol, Operator.equal, idSubmissao)
      .first();
  final submissao = Submissao.fromMap(submissaoRow!);
  final numeroProtocolo = ProtocoloUtils.gerarNumeroProtocolo(
    idSubmissao,
    DateTime.utc(2026, 3, 22).add(Duration(minutes: indice)),
  );
  final codigoPublico = 'NEXUS-SALUS-${indice.toString().padLeft(3, '0')}';

  await db.table(Protocolo.fqtn).insert(
        Protocolo(
          id: 0,
          idSubmissao: idSubmissao,
          numeroProtocolo: numeroProtocolo,
          codigoPublico: codigoPublico,
        ).toInsertMap(),
      );

  await _registrarHistoricoStatus(
    db,
    idSubmissao: idSubmissao,
    statusAnterior: null,
    novoStatus: 'submetida',
    motivo: 'Solicitacao recebida pelo portal do cidadao.',
  );

  return _SubmissaoSeed(
    idSessao: idSessao,
    idSubmissao: idSubmissao,
    idSubmissaoPublico: submissao.idPublico ?? '$idSubmissao',
    status: status,
    numeroProtocolo: numeroProtocolo,
    codigoPublico: codigoPublico,
  );
}

Future<void> _registrarHistoricoStatus(
  dynamic db, {
  required int idSubmissao,
  required String? statusAnterior,
  required String novoStatus,
  required String motivo,
}) async {
  await db.table(HistoricoStatusSubmissao.fqtn).insert(
        HistoricoStatusSubmissao(
          id: 0,
          idSubmissao: idSubmissao,
          statusAnterior: statusAnterior,
          novoStatus: novoStatus,
          motivo: motivo,
          metadadosJson:
              jsonEncode(<String, dynamic>{'origem': 'seed_institucional'}),
        ).toInsertMap(),
      );
}

Future<void> _criarTarefaAnalise(
  dynamic db, {
  required _SubmissaoSeed submissao,
  required _ContextoInstitucional contexto,
  required String titulo,
  required String descricao,
  String status = 'em_andamento',
}) async {
  final idTarefa = await db.table('public.tarefas_internas').insertGetId(
    <String, dynamic>{
      'id_submissao': submissao.idSubmissao,
      'titulo': titulo,
      'descricao': descricao,
      'id_organograma': contexto.idOrganograma,
      'status': status,
      'prioridade': 'alta',
      'prazo_em': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      'criado_por': contexto.idUsuarioInterno,
      'atualizado_em': DateTime.now().toIso8601String(),
    },
    'id',
  ) as int;

  await db.table('public.atribuicoes_tarefa').insert(<String, dynamic>{
    'id_tarefa': idTarefa,
    'id_usuario_atribuido': contexto.idUsuarioInterno,
    'id_organograma_atribuido': contexto.idOrganograma,
    'atribuido_por': contexto.idUsuarioInterno,
    'aceito_em': DateTime.now().toIso8601String(),
  });
  await db.table('public.comentarios_tarefa').insert(<String, dynamic>{
    'id_tarefa': idTarefa,
    'id_autor': contexto.idUsuarioInterno,
    'corpo':
        'Tarefa criada pelo seed institucional para simular a esteira operacional real.',
    'interno': true,
  });
  await db.table('public.transicoes_tarefa').insert(<String, dynamic>{
    'id_tarefa': idTarefa,
    'status_anterior': null,
    'novo_status': status,
    'transitado_por': contexto.idUsuarioInterno,
    'motivo': 'Seed institucional.',
  });
}

Future<void> _salvarResultadoClassificacao(
  dynamic db, {
  required int idExecucao,
  required int idSubmissao,
  required double pontuacaoFinal,
  required int? posicaoFinal,
  required bool elegivel,
  required Map<String, dynamic> justificativa,
  required String numeroProtocolo,
  required int idVersaoConjuntoRegras,
  required String statusFinal,
}) async {
  await db.table(ResultadoClassificacao.fqtn).insert(
        ResultadoClassificacao(
          id: 0,
          idExecucaoClassificacao: idExecucao,
          idSubmissao: idSubmissao,
          pontuacaoFinal: pontuacaoFinal,
          posicaoFinal: posicaoFinal,
          elegivel: elegivel,
          snapshotDesempateJson: jsonEncode(<String, dynamic>{
            'numero_protocolo': numeroProtocolo,
          }),
          justificativaJson: jsonEncode(justificativa),
        ).toInsertMap(),
      );

  await db
      .table(Submissao.fqtn)
      .where(Submissao.idCol, Operator.equal, idSubmissao)
      .update(<String, dynamic>{
    Submissao.idVersaoConjuntoRegrasCol: idVersaoConjuntoRegras,
    Submissao.statusCol: statusFinal,
    Submissao.snapshotRankingJsonCol: jsonEncode(<String, dynamic>{
      'pontuacao_final': pontuacaoFinal,
      'posicao_final': posicaoFinal,
      'elegivel': elegivel,
      'justificativa': justificativa,
    }),
    'atualizado_em': DateTime.now().toIso8601String(),
  });
}

Future<List<int>> _idsNosPorFluxo(dynamic db, int idFluxo) async {
  final rows = await db
      .table(NoFluxo.fqtn)
      .selectRaw(NoFluxo.idCol)
      .where(NoFluxo.idDefinicaoFluxoCol, Operator.equal, idFluxo)
      .get();

  return rows
      .map<int>((item) => item[NoFluxo.idCol] as int)
      .toList(growable: false);
}
