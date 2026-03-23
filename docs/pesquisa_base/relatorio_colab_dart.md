# Relatorio Tecnico: Como o Colab Estrutura Servicos e Como Reproduzir em Dart

## 1. Conclusao principal

O arquivo `referencias/colab/Andamento dos Processos.json` mostra o contrato mais importante do produto: o Colab salva um servico como um **documento de workflow**, nao como uma pagina estatica nem como um formulario solto.

Na pratica, cada servico e composto por:

- um conjunto de **fluxos**;
- cada fluxo possui **nodes** e **edges**;
- cada node tem um **tipo funcional**;
- o node carrega uma estrutura `data` especializada conforme o tipo;
- existe um bloco `metadata` com informacoes de publicacao, permissao, canal e governanca.

Isso indica que o produto e um **orquestrador low-code de servicos digitais**, e nao apenas um construtor de formularios.

## 2. O que exatamente esse JSON prova

O arquivo mostra dois fluxos distintos dentro do mesmo servico:

- `flows.internal`
- `flows.dataEntry`

Essa separacao e crucial.

### 2.1 Fluxo interno

O fluxo `internal` representa o caminho administrativo interno do processo. No exemplo ele contem:

- node `start`
- node `status`
- node `end-internal-flow`

Isso indica que o Colab trata o servico em duas camadas:

- camada publica de coleta/consulta do cidadao;
- camada interna de tramitacao e estado administrativo.

Mesmo quando o exemplo interno esta simples, a modelagem ja deixa claro que o motor suporta workflow interno separado do frontend publico.

### 2.2 Fluxo de entrada de dados

O fluxo `dataEntry` representa a experiencia do usuario final. No exemplo ele contem:

- `presentation`
- `form`
- `dynamic-content`
- `end-data-entry-flow`

Ou seja, o Colab encadeia etapas orientadas por grafo.

Nao e um CRUD de paginas. E um runtime que interpreta um pipeline declarativo.

## 3. Estrutura semantica dos nodes

O valor real do JSON esta em como cada tipo de node define comportamento.

### 3.1 Node `presentation`

Esse node funciona como etapa introdutoria do servico.

Campos observados:

- `data.label`
- `data.presentationContent`
- `data.additionalInfoContent`

Os campos `presentationContent` e `additionalInfoContent` usam a estrutura do Editor.js:

- `time`
- `blocks`
- `version`

Isso mostra que o Colab persiste conteudo editorial estruturado, nao HTML bruto. Isso e importante porque:

- facilita edicao visual;
- facilita renderizacao em varios canais;
- reduz acoplamento com um frontend especifico;
- permite validacao de blocos por tipo.

### 3.2 Node `form`

Esse node representa uma etapa de entrada de dados.

Campos observados:

- `data.label`
- `data.description`
- `data.questions`

Cada pergunta possui contrato proprio. No exemplo:

- `id`
- `question`
- `isMandatory`
- `field`
- `answerType`
- `description`
- `mask`
- `useMaxLength`
- `maxCharacterCount`

O ponto mais importante aqui e `field`.

No exemplo:

- `field: numero_barra_ano_do_processo_CeNEdeKY`

Esse nome vira a chave semantica do dado coletado e depois e reutilizado em outras etapas, especialmente em integracoes.

Ou seja, o formulario nao salva apenas rótulos visuais. Ele define um **namespace de variaveis de workflow**.

### 3.3 Node `dynamic-content`

Esse e o node mais revelador do sistema.

Ele mostra que o Colab nao apenas coleta dados: ele executa uma chamada HTTP dinamica e renderiza o resultado.

Campos observados:

- `method: POST`
- `url`
- `payload`
- `headers`
- `bearerTokenRequestConfig`
- `content`
- `finishFlow`

No exemplo:

- a URL aponta para um backend municipal externo;
- o payload usa interpolacao de variavel coletada no formulario;
- o conteudo renderizado usa placeholders do retorno da API.

Payload observado:

```json
{"codigo": "$numero_barra_ano_do_processo_CeNEdeKY"}
```

Template de saida observado:

- `{{cod_processo}}`
- `{{ano_exercicio}}`
- `{{nom_situacao}}`
- `{{nome_organograma_ultimo_andamento}}`
- `{{data_ultimo_andamento_fmt}}`

Isso comprova que o Colab implementa pelo menos estes mecanismos:

- resolucao de variaveis de contexto do workflow;
- execucao de requisicao HTTP parametrizada;
- parse do retorno;
- injecao de dados em template de conteudo rico;
- finalizacao opcional do fluxo.

Em outras palavras, esse node ja equivale a um pequeno bloco de integracao low-code.

### 3.4 Nodes de termino

Existem dois finais distintos:

- `end-data-entry-flow`
- `end-internal-flow`

No fluxo publico, o final tambem pode conter conteudo rico e `finishFlow: true`.

Isso indica que finalizar um fluxo nao e apenas encerrar navegacao. Pode significar:

- encerrar atendimento;
- mostrar conteudo de conclusao;
- registrar estado final de jornada;
- preparar transicao para uma etapa posterior.

## 4. Estrutura dos edges

Os edges nao sao apenas decorativos. Eles tambem carregam contrato de execucao.

Campos observados:

- `id`
- `type`
- `source`
- `target`
- `sourceHandle`
- `targetHandle`
- `markerEnd`

Exemplos:

- `presentation_out -> form_in`
- `form_out -> dynamic_content_in`
- `dynamic_content_out -> end_in`

Isso mostra que o runtime nao liga so um node ao outro; ele liga **portas semanticas**.

Essa decisao permite no futuro:

- multiplas saidas por node;
- condicoes;
- ramificacoes;
- erros e caminhos alternativos;
- validacao de compatibilidade entre portas.

## 5. O papel do bloco `metadata`

O `metadata` revela a camada de produto e governanca.

Campos observados:

- `name`
- `creatorId`
- `filesRequestInteractionDeadline`
- `category`
- `availableOrigins`
- `segment`
- `allowedDepartments`
- `serviceResponsible`
- `showServiceResponsible`
- `citizenRequest`
- `visibilities`

### 5.1 Canais de publicacao

O array `availableOrigins` contem:

- `citizenPortal`
- `socialApp`
- `whatsapp`
- `iframe`

Isso e decisivo para entender o produto.

O Colab nao foi desenhado para um unico frontend. Ele foi modelado para **publicacao omnichannel**. O mesmo workflow pode ser exposto em multiplos canais com o mesmo contrato.

### 5.2 Segmentacao e governanca

Os campos `allowedDepartments`, `serviceResponsible` e `visibilities` mostram que o sistema tambem e um produto de governanca institucional.

Ou seja, alem do workflow, o servico precisa guardar:

- quem pode administrar;
- qual orgao e responsavel;
- onde ele pode aparecer;
- para quem ele fica visivel.

Isso muda totalmente a arquitetura do backend. Nao basta salvar JSON. E preciso um dominio de autorizacao e catalogo de servicos.

## 6. Como o Colab provavelmente funciona por dentro

Combinando esse JSON com os artefatos do frontend salvos em `referencias/colab`, a arquitetura mais provavel do Colab e a seguinte.

### 6.1 Modelagem de produto

O servico e um agregado principal com:

- identidade;
- metadados;
- definicao de fluxos;
- conteudo editorial;
- contratos de integracao;
- regras de visibilidade e canal.

### 6.2 Builder visual

O editor visual provavelmente manipula esse documento diretamente:

- cria nodes com schemas por tipo;
- cria edges conectando handles;
- atualiza `position`, `width`, `height`;
- serializa o resultado em JSON;
- persiste o documento no backend.

### 6.3 Runtime de execucao

Na hora de executar o servico, existe um motor que:

1. carrega o documento do servico;
2. escolhe o fluxo inicial;
3. renderiza o primeiro node;
4. coleta respostas do usuario;
5. atualiza o contexto de variaveis;
6. executa nodes dinamicos quando necessario;
7. resolve o proximo edge;
8. renderiza a proxima etapa.

### 6.4 Conteudo rico estruturado

O uso de blocos do Editor.js indica que a plataforma trabalha com conteudo fortemente tipado. Isso e melhor que HTML salvo em string porque:

- permite renderers diferentes por canal;
- permite saneamento e validacao;
- permite exportacao e transformacoes;
- evita acoplamento com um editor unico.

## 7. O que esse JSON exige de um sistema Dart semelhante

Se a ideia e criar um sistema semelhante em Dart, o ponto correto nao e comecar pela tela. O ponto correto e criar o **modelo de documento e o runtime de workflow**.

### 7.1 Dominio minimo

Voce precisa de entidades equivalentes a:

- `ServiceDefinition`
- `FlowDefinition`
- `FlowNode`
- `FlowEdge`
- `NodePort`
- `ServiceMetadata`
- `QuestionDefinition`
- `RichContentDocument`
- `IntegrationDefinition`
- `ExecutionContext`
- `ExecutionSession`

### 7.2 Node types como contrato de dominio

Cada `type` de node precisa ter schema proprio.

Exemplo de familias:

- `start`
- `presentation`
- `form`
- `dynamic-content`
- `status`
- `condition`
- `end-*`

O erro comum seria modelar tudo como `Map<String, dynamic>`. Isso acelera o prototipo, mas destrói validacao e manutencao.

O caminho correto em Dart e:

- um tipo base `FlowNodeData`;
- subclasses por tipo de node;
- serializacao/deserializacao explicita;
- validador por schema.

### 7.3 Contexto de execucao

O campo `field` da pergunta e os placeholders do node dinamico provam que o runtime precisa manter um contexto semelhante a:

```text
context.answers[fieldName]
context.integrationResults[nodeId]
context.variables[name]
```

Sem isso nao ha interpolacao confiavel.

### 7.4 Engine de template

E necessario um resolvedor de templates para:

- payloads HTTP;
- headers;
- blocos de conteudo;
- mensagens finais;
- possiveis condicoes futuras.

Esse resolvedor deve suportar pelo menos:

- variaveis simples: `$campo`
- placeholders de template: `{{campo}}`
- modo seguro para valor ausente
- escaping previsivel

## 8. Proposta de arquitetura full stack Dart inspirada no Salus

O projeto `referencias/salus` sugere uma organizacao muito adequada para isso:

- `backend/`
- `frontend/`
- `core/`
- `packages/`

Essa separacao e boa e deveria ser mantida.

### 8.1 Estrutura recomendada

- `backend/`: API, autenticacao, persistencia, execucao de workflow, integracoes externas
- `frontend/`: builder visual, catalogo de servicos, console administrativo, runtime web
- `core/`: modelos compartilhados, enums, contratos de serializacao, validadores, tipos de node
- `packages/`: bibliotecas reutilizaveis como UI kit, grafo visual, editor de blocos, auth client

### 8.2 Backend Dart

Baseando no `salus_backend`, o backend pode continuar em Shelf + Shelf Router inicialmente.

Camadas recomendadas:

- `src/domain/`
- `src/application/`
- `src/infrastructure/`
- `src/http/`

Servicos principais:

- `ServiceDefinitionRepository`
- `WorkflowValidationService`
- `WorkflowExecutionService`
- `TemplateRenderService`
- `ExternalIntegrationService`
- `PublicationService`
- `AuthorizationService`
- `ExecutionSessionRepository`

### 8.3 Frontend Dart

Como o `salus_frontend` usa `ngdart`, voce pode manter AngularDart se quiser coerencia com o workspace atual. A composicao natural seria:

- tela de catalogo de servicos;
- tela de edicao visual de fluxo;
- painel de propriedades do node;
- preview de execucao;
- runtime de atendimento publico.

O proprio `dart_flow` pode servir como base do editor visual.

A melhor aplicacao dele aqui e:

- canvas do builder;
- node editor;
- conexoes entre handles;
- zoom/pan/selecionar;
- hosts dinamicos por tipo de node.

## 9. Modelo de dados recomendado em Dart

### 9.1 Documento principal

```text
ServiceDefinition
  id
  metadata
  flows
  version
  createdAt
  updatedAt
```

### 9.2 Fluxos

```text
FlowDefinition
  id
  key
  kind
  nodes
  edges
```

### 9.3 Nodes

```text
FlowNode
  id
  type
  position
  selectable
  deletable
  width
  height
  data
```

### 9.4 Integracoes

```text
DynamicContentNodeData
  label
  method
  url
  headers
  payloadTemplate
  bearerTokenRequestConfig
  contentTemplate
  finishFlow
```

## 10. Endpoints minimos para um MVP

### 10.1 Catalogo e definicao

- `GET /api/services`
- `POST /api/services`
- `GET /api/services/:id`
- `PUT /api/services/:id`
- `POST /api/services/:id/publish`

### 10.2 Execucao

- `POST /api/runtime/services/:id/start`
- `POST /api/runtime/sessions/:sessionId/submit`
- `GET /api/runtime/sessions/:sessionId/current`

### 10.3 Builder

- `POST /api/services/:id/validate`
- `POST /api/services/:id/preview`

## 11. Regras de validacao que o sistema precisa ter

Esse JSON deixa claro que o backend nao pode aceitar qualquer grafo.

Validacoes minimas:

- ids unicos de nodes e edges;
- `source` e `target` devem existir;
- `sourceHandle` e `targetHandle` devem ser compativeis com o tipo do node;
- deve haver pelo menos um caminho valido do inicio ao fim;
- campos obrigatorios de cada node devem existir;
- variaveis usadas em payload/template devem ser resolviveis;
- canais e visibilidades devem respeitar permissoes institucionais.

## 12. Seguranca e riscos tecnicos

O node `dynamic-content` traz o maior risco do produto.

Voce vai precisar controlar:

- whitelist de dominios externos;
- secrets por integracao;
- bearer token seguro e nao serializado para o cliente;
- timeouts, retry e observabilidade;
- auditoria de chamadas externas;
- mascaramento de dados sensiveis;
- validacao de payload interpolado.

O frontend nao deve ser a fonte da verdade para execucao dessas integracoes. O certo e executar do lado do backend sempre que houver segredo, autorizacao ou trilha de auditoria relevante.

## 13. Roadmap recomendado para construir isso em Dart

### Fase 1: nucleo

- definir modelos compartilhados em `core/`
- implementar serializacao do documento de servico
- criar validadores de workflow
- criar runtime simples com `presentation`, `form` e `end`

### Fase 2: builder

- usar `dart_flow` como canvas
- criar nodes customizados por tipo
- criar painel lateral de propriedades
- salvar e carregar JSON do servico

### Fase 3: execucao dinamica

- implementar `dynamic-content`
- resolver templates de entrada e saida
- persistir sessoes de execucao

### Fase 4: governanca

- categorias
- departamentos
- responsavel pelo servico
- visibilidade por canal
- publicacao e versionamento

### Fase 5: omnichannel

- runtime web
- embed em `iframe`
- adaptacao para chat/WhatsApp

## 14. Decisao arquitetural mais importante

O mais importante para reproduzir o Colab nao e copiar a interface React deles.

O essencial e implementar estes tres pilares:

- **documento declarativo de servico**;
- **engine de execucao de workflow**;
- **builder visual sobre esse documento**.

Se esses tres pilares estiverem corretos, o frontend pode ser AngularDart e o sistema ainda sera conceitualmente equivalente.

## 15. Leitura final do arquivo `Andamento dos Processos.json`

Esse arquivo mostra que o servico salvo pelo Colab e, ao mesmo tempo:

- um formulario;
- uma jornada guiada;
- um integrador HTTP;
- um documento editorial;
- um artefato de governanca institucional;
- um asset publicavel em multiplos canais.

Essa e a melhor definicao operacional do produto observada ate aqui.

## 16. Recomendacao pratica para o seu projeto atual

Como voce ja possui `dart_flow`, a melhor estrategia e:

1. transformar `dart_flow` no editor visual do builder;
2. criar um pacote `core` com o schema do documento Colab-like;
3. usar um backend estilo `salus_backend` para validacao, persistencia e runtime;
4. implementar primeiro os nodes `presentation`, `form`, `dynamic-content` e `end`;
5. deixar canais, analytics e recursos mais avancados para a segunda fase.

Essa ordem ataca o nucleo real do produto, que esse JSON deixou exposto com bastante clareza.