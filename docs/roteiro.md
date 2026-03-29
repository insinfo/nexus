# Roteiro de implementação do sistema Nexus

Nexus é uma plataforma municipal de serviços digitais low-code.

## Estrutura

```text
nexus/
├── backend/
├── core/
├── frontend_backoffice/
├── frontend_portal/
├── packages/
└── docs/
```

## Objetivo

Substituir sistemas sazonais e isolados por um motor único de serviços versionados, com workflow declarativo, runtime tipado, builder visual baseado em dart_flow e governança institucional.

O Nexus é inspirado tanto no Colab, usado aqui como referência em `C:\MyDartProjects\nexus\packages\dart_flow\referencias\colab`, quanto no WordPress, pela combinação entre flexibilidade, extensibilidade e capacidade de operar experiências públicas e administrativas sobre uma base única. A proposta é entregar à Prefeitura um portal de serviços poderoso, configurável e evolutivo, sem depender de um sistema novo para cada necessidade.

Entre os sistemas que o Nexus pretende substituir estão:

- SIGEP
	Sistema de Gestão de Estágio, voltado principalmente para inscrição pública (pagina de cadastro de candidato publica sem login) de candidatos a estágio na Prefeitura, com telas internas (com login de funcionario) de classificação e exportação em XLSX para publicação em Diário Oficial.
- SEQUAL
	Sistema de inscrição de pessoas interessadas em cursos profissionalizantes (pagina de cadastro de candidato publica sem login) oferecidos pelos centros de treinamento da Prefeitura. Possui tela pública para cadastro do cidadão e telas internas para liberação de formulários, classificação, matrícula, confirmação de comparecimento e emissão de certificados. Também possui tela pública para emissão posterior de certificados por CPF.
- Pré-matrícula escolar
	Sistema utilizado para inscrição e organização de vagas escolares, com regras que variam a cada ciclo.
- SALUS
	Sistema da Secretaria de Bem-Estar Social para inscrição de pessoas desabrigadas (Auxilio emergencial), com operação predominantemente interna e cadastro realizado por comissão a partir de fichas em papel recebidas dos CRAS.

O Nexus busca eliminar a necessidade de desenvolver uma aplicação nova para cada edital, programa, campanha ou processo sazonal, permitindo configurar serviços digitais por meio de definição declarativa, versionamento e execução auditável.

## Visão da plataforma

O Nexus foi pensado como uma plataforma única para publicação, execução, operação e auditoria de serviços digitais municipais. Em vez de criar um sistema novo para cada campanha, edital ou política pública, a Prefeitura passa a operar sobre um conjunto reutilizável de blocos:

- catálogo de serviços versionados;
- workflows públicos e internos modelados no mesmo artefato;
- formulários declarativos com regras, visibilidade e cálculos;
- motor de execução com trilha auditável;
- operação interna com tarefas, comentários, transições e protocolos;
- classificação, pontuação e homologação sobre conjuntos de regras versionados.

No médio e longo prazo, a mesma fundação deve suportar também casos de uso hoje associados ao portal institucional da Prefeitura de Rio das Ostras, como portal de notícias, páginas temáticas, publicações oficiais e Diário Oficial, preservando a mesma lógica de composição low-code, governança e versionamento.

Essa abordagem reduz retrabalho, melhora governança, preserva histórico e cria base técnica para evoluir serviços digitais com menos custo operacional.

## Regras vitais
os nomes das entidades do sistema não podem ficar em ingles, em vez de listVersions, listFlows, seria listVersoes, listFluxos e etc

so pare quando a aplicaçõo estiver concluida , e siga estritamente o padrão 
seguir o padrão ouro de projeto do C:\MyDartProjects\dart_flow\referencias\salus
usar eloquent 
seguir orientação a objetos
seguir principios SOLID
nada de replicação burra de codigo 
nada de varios models no mesmo arquivo
nada de um monte de funções utilitarias replicadas e espalhadas pelos arquivos coloque funções utilitarias na pasta shared/utils se possivel na classe Utils como metodo estatico ou crie extensões
implementar testes unitarios e de integração
padrão MVC
não deixar arquivo não utilizado no projeto
somente nomes em portugues nas entidades ou seja nade de "catalog_repository" tem que ser "catalogo_repository"
C:\MyDartProjects\dart_flow\referencias\salus que você não esta seguindo, veja os models, controller,repositories, services e paginas do C:\MyDartProjects\dart_flow\referencias\salus seu burro 
as classes de modelos tem que ter static const tableName e static const fqtb (fully qualificd table name)
as classes de modelos tem que ter from e toMap e toInsertMap e toUpdateMap
as classes de modelos tem que ter idealmente o clone metodo (não obrigatorio em tudo)
as classes de modelos tem que ter static consts para as keys dos maps exemplo static const idCol
as classes de modelos tem que ter static consts para nomes de colunas qualificados static const idFqCol = table.colname
não use final nas propriedades dos models
seguir o principio single responsibility o maximo possivel
todo os models devem estar em C:\MyDartProjects\dart_flow\nexus\core\lib\src\models a não ser se for um model que tenhas funções especificas do frontend ou do backend por exemplo dart:io e dart:html
eviar ao maximo alias nas queries dentro dos repositories
sempre usar transação do eloquent para alterações no banco de dados que envolva varias tabelas
nos controllers e repositories tem que usar o DataFrame para os metodos listar C:\MyDartProjects\dart_flow\packages\essential_core\lib\src\models\data_frame.dart
nos controllers usar nos metodos listar   return responseDataFrame(data); exemlo
C:\MyDartProjects\dart_flow\referencias\salus\backend\lib\src\modules\avaliador\controllers\avaliador_controller.dart
 C:\MyDartProjects\dart_flow\referencias\salus\backend\lib\src\extensions\request_extension_shelf.dart
não se preocupe com retrocompatibilidade ou fallback a aplicação ainda não foi lançada então tudo é possivel
não criar views no banco de dados

aqui  .table('${ServicoPersistencia.fqtn} as s') e .leftJoin('public.categorias_servico as cat', 'cat.id', '=', 's.${ServicoPersistencia.idCategoriaCol}') não precisa de alias use o nome da tabela sempre que possivel so use alias em nomes de colunas se necessario

em ves de   .selectRaw(
          '${NoFluxoPersistencia.chaveNoCol}, '
          '${NoFluxoPersistencia.tipoNoCol}, '
          '${NoFluxoPersistencia.posicaoXCol}, '
          '${NoFluxoPersistencia.posicaoYCol}, '
          '${NoFluxoPersistencia.larguraCol}, '
          '${NoFluxoPersistencia.alturaCol}, '
          '${NoFluxoPersistencia.dadosJsonCol}',
        )
        use  .select([
          NoFluxoPersistencia.chaveNoCol,
          NoFluxoPersistencia.tipoNoCol,
          NoFluxoPersistencia.posicaoXCol,
          NoFluxoPersistencia.posicaoYCol,
          NoFluxoPersistencia.larguraCol,
          NoFluxoPersistencia.alturaCol,
          NoFluxoPersistencia.dadosJsonCol,]
        
        )


não faça isso
 // 6. Criar sessão
    final contextoJson = jsonEncode({
      'respostas': <String, dynamic>{},
      'variaveis': contextoInicial,
      'resultados_integracao': <String, dynamic>{},
      'contexto_usuario': <String, dynamic>{},
      'contexto_servico': <String, dynamic>{},
      'contexto_edicao': <String, dynamic>{},
    });

    final sessaoPk = await db.table(SessaoExecucaoPersistencia.fqtn).insertGetId(
      {
        SessaoExecucaoPersistencia.idServicoCol: servicoPk,
        SessaoExecucaoPersistencia.idVersaoServicoCol: versaoPk,
        SessaoExecucaoPersistencia.idFluxoAtualCol: fluxoPk,
        SessaoExecucaoPersistencia.idNoAtualCol: idNoPrimeiro,
        SessaoExecucaoPersistencia.canalCol: canal,
        SessaoExecucaoPersistencia.statusCol: 'em_andamento',
        SessaoExecucaoPersistencia.contextoJsonCol: contextoJson,
        SessaoExecucaoPersistencia.snapshotFluxoJsonCol: '{}',
      },
      SessaoExecucaoPersistencia.idCol,
    ) as int;
    implemente models com toInsertMap ou toUpdateMap para ser usando no db.table(SessaoExecucaoPersistencia.fqtn).insertGetId

nunca execute testes sem antes o dart analize esta limpo
nunca deixe codigo quebrado sempre use dart analize para checar
evite isso '${DefinicaoFluxoPersistencia.idPublicoFqCol}::text as id_publico',
prefira fazer o toString no dart
evite casts inuteis se você sabe o tipo certo que vem do banco para que fazer isso  row['chave_fluxo'] as String
o frontend tem que seguir o padrão visual do limitless exemplo em C:\MyDartProjects\dart_flow\referencias\salus\frontend\lib\src\modules
coisas pertencentes a enums devem ficar no proprio enum, nao em helpers soltos dentro de repository, service ou page
todo enum  deve expor tryParse e parse no proprio enum
quando o enum tiver valor canonico persistido, usar somente o campo `val` para esse valor e usar getter como `label` para texto de aplicação
nao usar values.byName espalhado pelo projeto quando o proprio enum puder centralizar o parse
quando a origem for banco, request, json ou canvas, o parse deve consumir o valor canonico definido no enum
padronizar todos os enums para um unico formato canonico no dominio, preferencialmente via `val`, e proibir conversoes ad hoc como `snakeParaCamel`, `camelParaSnake` ou equivalentes espalhadas no codigo
repository, service, page, controller, seed e model nao devem converter formato de enum manualmente; se houver necessidade de conversao, a responsabilidade e do proprio enum
evitar codigo final com ternario pesado, `await`, lookup em mapa e coalescencia tudo na mesma expressao; quebrar em variaveis intermediarias tipadas ou extrair helper privado do repository/service
metodos publicos de repository devem seguir o padrao do Salus, com verbos curtos e consistentes; quando houver entidade do dominio no nome do metodo, a entidade deve ficar em portugues, como `listVersoes`, `listFluxos`, `findByCodigo`, `saveRascunho`, `publishVersao`, `listSubmissoes`, `findSubmissaoById`, `runClassificacao`; nao colocar entidades do sistema em ingles 
nao criar model paralelo so para mudar nome de campo ou camada quando um unico model do dominio puder atender builder, request, response e persistencia sem ambiguidade real
nao montar tela com dado sintetico no frontend se o backend puder e dever entregar esse dado; portal e backoffice devem consumir endpoint real e persistido sempre que o modulo existir

o backend sera um OpenID Connect Provider, com autenticacao seguindo o padrao OpenID Connect e evolucao planejada para federacao com Gov.br, Google, Microsoft Active Directory e outros provedores externos

no frontend use as classes do limitless sempre
    <link href="https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/icons/phosphor/2.0.3/styles.min.css"
        rel="stylesheet" type="text/css">
    <link href="https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/fonts/inter/inter.min.css" rel="stylesheet"
        type="text/css">
    <link href="https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/css/all.min.css" rel="stylesheet"
        type="text/css">
  <link href="https://www.riodasostras.rj.gov.br/cdn/Vendor/limitless/4.0/bs5/template/html/layout_1/full/assets/css/ltr/all.min.css" rel="stylesheet"
    type="text/css">
    <script src="https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/js/bootstrap/bootstrap.bundle.min.js"></script>

https://www.riodasostras.rj.gov.br/cdn/Vendor/limitless/4.0/bs5/template/html/layout_1/full/service_sitemap.html
nunca deixe uma pagina angulardart ficar grande de mais subdivida em varias paginas ou componentes menores mais tambem não é para criar milhares de paginas com menos de 100 linhas ou seja uma pagina com menos de 2000 linhas é aceitavel ou seja tem que ter um meio termo
não usar comando dart format
use sempre o comando dart analyze 

outra regra vital no frontend nãu use data-bs-toggle="collapse" faça assim [attr.data-bs-toggle]="'collapse'"
 
## Casos de uso prioritários

- inscrições públicas para estágio, cursos, benefícios e programas sociais;
- triagem interna e análise documental por comissão ou secretaria responsável;
- classificação e ranking com critérios auditáveis e reproduzíveis;
- emissão de protocolos, acompanhamento de status e consulta pública de resultados;
- integração com autenticação externa, inclusive login federado e identidades institucionais;
- backend atuando como OpenID Connect Provider do Nexus, preparado para federacao com Gov.br e provedores corporativos;
- manutenção de cadastro territorial, organograma e cadastro geral de pessoas com histórico.

## Princípios arquiteturais

- Um serviço é um documento versionado, não uma tela fixa.
- Workflow público e workflow interno coexistem no mesmo artefato.
- Runtime, builder e contratos de domínio compartilham o mesmo schema em Dart.
- Publicação, execução e classificação devem ser auditáveis e reproduzíveis.
- Toda submissão deve apontar para `id_servico`, `id_versao_servico`, `id_versao_conjunto_regras` e `snapshot_fluxo`.

## Arquitetura-alvo

- `core/`: contratos compartilhados entre backend, builder e runtime, incluindo modelos tipados de serviço, fluxo, formulário, regras e execução.
- `backend/`: APIs, provedor OpenID Connect do Nexus, catálogo de serviços, execução de workflows, operação interna, auditoria e integração com PostgreSQL.
- `frontend_backoffice/`: builder visual, gestão de versões, configuração de regras, operação e acompanhamento interno.
- `frontend_portal/`: experiência pública do cidadão para inscrição, autenticação, consulta e emissão de comprovantes.
- `packages/`: bibliotecas reutilizáveis, componentes compartilhados e futuras abstrações isoladas da plataforma.
- `docs/`: documentação funcional, técnica e relatórios de referência para evolução do produto.

O desenho alvo é de uma plataforma modular, mas com domínio centralizado. O backend concentra consistência de negócio e auditoria; o `core/` mantém contratos alinhados; as duas frentes web consomem o mesmo modelo conceitual.

## Primeiros entregáveis implementados nesta base

- `core/` com modelos tipados de serviço, fluxo, node, formulário e execução.
- `backend/` com endpoints mínimos de health check e catálogo de serviços.
- `frontend_backoffice/` com shell inicial do builder e módulos previstos.
- `frontend_portal/` com shell inicial do portal do cidadão.


## Banco de dados inicial

O projeto já possui scripts SQL para bootstrap local do PostgreSQL e criação da estrutura inicial do Nexus.

Criar ou ajustar o usuário `dart` e os bancos `salus` e `nexus`:

```bash
psql -U postgres -d postgres -f nexus/backend/scripts/create_database.sql
```

Esse bootstrap local agora encerra conexoes abertas, apaga `salus`, `nexus` e qualquer base `nexus_tmp*`, e recria tudo do zero para evitar acumulo de bancos temporarios e lixo de schema.

Aplicar a migration principal do Nexus:

```bash
psql -U dart -d nexus -f nexus/backend/scripts/db_migrations.sql
```

Carregar dados de exemplo e teste pelo script Dart do backend:

```bash
cd nexus/backend
dart run scripts/seed_dados_exemplo.dart
```

Os scripts cobrem:

- extensões necessárias, como `unaccent`, sem depender de `pgcrypto` para hash de senha;
- segurança, identidade, OIDC e governança;
- cadastro territorial e cadastro geral de pessoas com histórico;
- catálogo de serviços, publicação, workflows, formulários e runtime;
- operação interna, classificação, anexos e auditoria.

Os dados de exemplo não ficam mais em `core/`. A carga de teste passa a viver em `backend/scripts/seed_dados_exemplo.dart`, mantendo o pacote compartilhado restrito a contratos e modelos. Os dois exemplos iniciais desse seed sao o SALUS, para beneficio com elegibilidade e classificacao, e o SIGEP, para edital de estagio com ranking e homologacao.

## Comandos iniciais

Backend:

```bash
cd nexus/backend
dart pub get
dart run bin/nexus.dart
```

Core:

```bash
cd nexus/core
dart pub get
dart analyze
```

Frontends:

```bash
cd nexus/frontend_backoffice
dart pub get
dart run build_runner build --delete-conflicting-outputs

cd ../frontend_portal
dart pub get
dart run build_runner build --delete-conflicting-outputs
```

## Status do MVP

- Concluído: estrutura monorepo, schema relacional inicial, seeds institucionais, catálogo mínimo, preview de fluxos, persistência de rascunho de serviço, publicação de versão e módulo inicial de consulta pública de protocolo no backend.
- Concluído também: padronização estrutural dos models do `core/` para o padrão exigido no roteiro, com propriedades mutáveis, constantes de tabela e colunas, `fromMap`, `toMap`, `toInsertMap`, `toUpdateMap` e `clone` onde aplicável.
- Concluído também: reorganização do `frontend_backoffice/` para o padrão de shell com rotas e página principal separada, no mesmo direcionamento arquitetural do Salus.
- Concluído também: centralização da semântica de enums no `core/`, com `tryParse` e `parse` no próprio enum, remoção dos `values.byName(...)` remanescentes e padronização do valor canonico em `val` com `label` para exibição quando necessário.
- Em andamento: fechamento do builder visual completo sobre `dart_flow` e execução pública ponta a ponta sobre versões publicadas, agora já com edição estrutural de seções, campos, opções, validações, regras de visibilidade e cálculos no inspector do backoffice.
- Em andamento também: consolidação do backend para leitura prioritária de formulários pelas tabelas relacionais em todo o ciclo de catálogo, builder e runtime.
- Falta implementar para o sistema ficar pronto: fechamento do workflow institucional no mesmo artefato de fluxo com suporte nativo aos nós internos avançados, expansão do módulo editorial/publicações oficiais e consolidação de cenários adicionais como SIGEP e SEQUAL sobre a mesma fundação já validada.

## Avanços recentes

- `backend/` ganhou o módulo `editor_fluxos` com endpoints de validação e pré-visualização para fluxos do builder.
- `backend/` passou a compartilhar a execução HTTP de nós `conteudo_dinamico` entre preview e runtime, com timeout por nó e persistência de auditoria em `resultados_nos_sessao`.
- `backend/` ganhou o endpoint `POST /api/v1/editor/servicos/salvar-rascunho` para persistência de rascunho de serviço e versão via transação.
- `core/` recebeu contratos para validação, pré-visualização, timeout de conteúdo dinâmico e persistência de resultados de nós em sessão.
- `backend/` recebeu reconstrução prioritária de nós de formulário a partir das tabelas relacionais e módulo próprio de consulta pública de protocolo.
- `core/` teve os models padronizados para o padrão estrutural exigido no projeto, reduzindo divergência entre contratos de domínio.
- `frontend_backoffice/` deixou de concentrar tudo no `app_component` e passou a usar shell de rota e página principal separada, alinhando o desenho ao padrão ouro do Salus.
- `frontend_backoffice/` já consome os endpoints do builder para validar, pré-visualizar e salvar rascunhos, e agora também edita no inspector as estruturas completas do formulário persistido: seções, perguntas, opções, validações, regras de visibilidade e cálculos.
- `frontend_portal/` passou a consultar o catálogo no endpoint correto em português, ganhou consulta pública de protocolo conectada ao backend e agora exibe resumo de respostas, métricas e linha de andamento público do protocolo, inclusive após submissão concluída no runtime.
- `backend/` passou a expor o runtime por porta de serviço própria, alinhando o controller ao padrão mais próximo do Salus e facilitando cobertura de integração isolada das rotas.
- `backend/` ganhou módulo próprio de operação institucional e classificação auditável, com listagens em `DataFrame`, transição de status, detalhamento de submissões e resultados de ranking auditáveis.
- `backend/` passou a expor a base do provedor OpenID Connect do Nexus com discovery e JWKS, preparando a convergência do login local para o padrão federável.
- `frontend_backoffice/` deixou de usar fila estática na seção de operação e passou a consumir o backend real, mostrando fila institucional, histórico, tarefas internas, ações de status e ranking de classificação.
- `backend/scripts/seed_dados_exemplo.dart` foi ampliado para um seed institucional completo, com organograma, usuário interno, serviço publicado, conjunto de regras publicado, tarefas internas, histórico de status e resultados de classificação persistidos.
- `core/`, `backend/`, `frontend_backoffice/` e `frontend_portal/` foram revalidados com `dart analyze`, e a suíte relevante de testes de integração do backend passou após a rodada, incluindo editor de serviços, consulta pública de protocolos, runtime, operação institucional e cenário real com PostgreSQL seedado.
- `core/` passou a concentrar também o parse canonico dos enums institucionais, com valor persistido em `val`, `label` para apresentação e cobertura unitária dedicada para os contratos de parse.
- `backend/`, `core/` e `frontend_backoffice/` deixaram de depender de `values.byName(...)` para `TipoNoFluxo` e outros enums centrais, passando a consumir o parse do próprio domínio de forma consistente entre banco, runtime, serialização e builder visual.
- `frontend_portal/` passou a carregar explicitamente os assets do Limitless pelo CDN adotado no projeto e pela folha oficial hospedada no ambiente de referencia, mantendo o shell publico no mesmo idioma visual do template.

## Módulos 

- builder visual completo com edição de nós, arestas, seções, perguntas, opções, validações, regras e pré-visualização;
- runtime declarativo com execução de nós públicos e internos;
- catálogo público com busca, filtros, protocolos e histórico do cidadão;
- portal institucional low-code com páginas, notícias, campanhas e conteúdo administrável;
- publicação estruturada de atos oficiais e Diário Oficial com fluxo editorial e trilha auditável;
- governança institucional com permissões finas, organograma e políticas por serviço;
- conectores com sistemas municipais e APIs externas;
- observabilidade operacional, métricas e trilhas de auditoria ampliadas.

## Próxima etapa recomendada

Fechar o ciclo funcional ainda aberto no artefato único de workflow: suportar nós internos avançados diretamente no runtime/validador, levar o mesmo padrão institucional completo para SIGEP e SEQUAL e integrar a camada editorial ao mesmo modelo operacional já validado entre builder, backend, seed real e acompanhamento público.