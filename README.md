# Nexus

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

O Nexus é inspirado tanto no Colab, usado aqui como referência em `../referencias/colab`, quanto no WordPress, pela combinação entre flexibilidade, extensibilidade e capacidade de operar experiências públicas e administrativas sobre uma base única. A proposta é entregar à Prefeitura um portal de serviços poderoso, configurável e evolutivo, sem depender de um sistema novo para cada necessidade.

Entre os sistemas que o Nexus pretende substituir estão:

- SIGEP
	Sistema de Gestão de Estágio, voltado principalmente para inscrição pública de candidatos a estágio na Prefeitura, com telas internas de classificação e exportação em XLSX para publicação em Diário Oficial.
- SEQUAL
	Sistema de inscrição de pessoas interessadas em cursos profissionalizantes oferecidos pelos centros de treinamento da Prefeitura. Possui tela pública para cadastro do cidadão e telas internas para liberação de formulários, classificação, matrícula, confirmação de comparecimento e emissão de certificados. Também possui tela pública para emissão posterior de certificados por CPF.
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
seguir o principio single responsibility o maximo possivel
todo os models devem estar em C:\MyDartProjects\dart_flow\nexus\core\lib\src\models a não ser se for um model que tenhas funções especificas do frontend ou do backend por exemplo dart:io e dart:html
eviar ao maximo alias nas queries dentro dos repositories
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

## Casos de uso prioritários

- inscrições públicas para estágio, cursos, benefícios e programas sociais;
- triagem interna e análise documental por comissão ou secretaria responsável;
- classificação e ranking com critérios auditáveis e reproduzíveis;
- emissão de protocolos, acompanhamento de status e consulta pública de resultados;
- integração com autenticação externa, inclusive login federado e identidades institucionais;
- manutenção de cadastro territorial, organograma e cadastro geral de pessoas com histórico.

## Princípios arquiteturais

- Um serviço é um documento versionado, não uma tela fixa.
- Workflow público e workflow interno coexistem no mesmo artefato.
- Runtime, builder e contratos de domínio compartilham o mesmo schema em Dart.
- Publicação, execução e classificação devem ser auditáveis e reproduzíveis.
- Toda submissão deve apontar para `id_servico`, `id_versao_servico`, `id_versao_conjunto_regras` e `snapshot_fluxo`.

## Arquitetura-alvo

- `core/`: contratos compartilhados entre backend, builder e runtime, incluindo modelos tipados de serviço, fluxo, formulário, regras e execução.
- `backend/`: APIs, autenticação, catálogo de serviços, execução de workflows, operação interna, auditoria e integração com PostgreSQL.
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
- `docs/nexus_mvp_roadmap.md` com especificação e plano detalhado.

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

- extensões necessárias, como `unaccent` e `pgcrypto`;
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

- Concluído: estrutura monorepo, modelos centrais em Dart, shells iniciais de backend e frontends, schema relacional inicial e seeds institucionais.
- Em andamento: persistência real de definições de serviço, validação semântica de workflow e integração do builder com armazenamento.
- Próximo ciclo: execução ponta a ponta de formulários, preview de runtime, autenticação integrada e monitor operacional.

## Módulos 

- builder visual completo com edição de nós, arestas, regras e pré-visualização;
- runtime declarativo com execução de nós públicos e internos;
- catálogo público com busca, filtros, protocolos e histórico do cidadão;
- portal institucional low-code com páginas, notícias, campanhas e conteúdo administrável;
- publicação estruturada de atos oficiais e Diário Oficial com fluxo editorial e trilha auditável;
- governança institucional com permissões finas, organograma e políticas por serviço;
- conectores com sistemas municipais e APIs externas;
- observabilidade operacional, métricas e trilhas de auditoria ampliadas.

## Próxima etapa recomendada

Implementar persistência de definições de serviço, validação de workflow e preview de runtime para os nodes `start`, `presentation`, `form`, `dynamic-content`, `condition` e `end`.