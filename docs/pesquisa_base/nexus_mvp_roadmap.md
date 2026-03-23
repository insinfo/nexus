# Nexus MVP Roadmap

## 1. Visao do produto

Nexus deve ser a plataforma municipal unica para criacao, publicacao e operacao de servicos digitais.
O foco nao e gerar formularios soltos, mas orquestrar servicos versionados com fluxos publicos,
fluxos internos, regras de negocio, classificacao, anexos, auditoria e multiplos canais.

### Cenarios que o produto precisa cobrir

1. Formulario publico anonimo.
2. Formulario publico autenticado.
3. Formulario interno administrativo.
4. Fluxo hibrido com etapas do cidadao e etapas da comissao.

## 2. Arquitetura alvo

```text
nexus/
├── backend/
├── frontend_portal/
├── frontend_backoffice/
├── core/
└── packages/
```

### backend

Responsavel por:

- catalogo de servicos
- versionamento e publicacao
- runtime de execucao
- anexos
- autenticacao e autorizacao
- tarefas internas
- integracoes externas
- auditoria e observabilidade
- ranking e classificacao

### frontend_portal

Responsavel por:

- catalogo de servicos do cidadao
- login quando necessario
- execucao do fluxo publico
- consulta de protocolo e pendencias
- acompanhamento e resultado

### frontend_backoffice

Responsavel por:

- catalogo e governanca
- builder visual
- editor de formulario
- editor de regras
- monitor operacional
- classificacao, homologacao e relatorios

### core

Responsavel por:

- modelos compartilhados
- serializacao
- enums e contratos
- validadores de schema
- templates e contexto de execucao
- exemplos de servico e tipos de node

### packages

Pacotes previstos:

- `rich_content`
- `form_runtime`
- `rule_engine`
- `auth_client`
- `ui_kit`

## 3. Agregados principais do dominio

### Catalogo

- `ServiceDefinition`
- `ServiceMetadata`
- `ServiceVersionDefinition`
- `AccessPolicy`

### Workflow

- `FlowDefinition`
- `FlowNodeDefinition`
- `FlowEdgeDefinition`
- `NodePortDefinition`

### Formulario

- `QuestionDefinition`
- `FieldValidationRule`
- `FieldVisibilityRule`

### Runtime

- `ExecutionContext`
- `ExecutionSession`
- `SubmissionRecord`
- `ProtocolRecord`

### Operacao interna

- `InternalTask`
- `TaskTransition`
- `TaskAssignment`

### Classificacao

- `RuleSetDefinition`
- `RankingRun`
- `RankingResult`

## 4. Tipos de node do MVP

Obrigatorios na fase inicial:

- `start`
- `presentation`
- `form`
- `dynamic-content`
- `condition`
- `end`

## 5. Fluxo de execucao do runtime

1. Carregar `ServiceDefinition` e resolver a versao publicada.
2. Escolher o fluxo inicial por canal e modo de acesso.
3. Criar `ExecutionSession`.
4. Resolver o primeiro node.
5. Renderizar o node no portal ou backoffice.
6. Coletar respostas e atualizar `ExecutionContext.answers`.
7. Executar integracoes do node, quando houver.
8. Resolver edges e handles compativeis.
9. Persistir progresso e auditoria.
10. Encerrar com `SubmissionRecord`, `ProtocolRecord` e tarefas internas, se aplicavel.

## 6. Roadmap detalhado

### Fase 1 - Fundacao do motor

Entregas:

- monorepo Nexus criado
- `core` com contratos tipados
- endpoint de catalogo
- shell do portal
- shell do backoffice
- exemplo de servico piloto em memoria

Critero de saida:

- carregar e serializar um servico completo em Dart
- expor o catalogo por HTTP

### Fase 2 - Validacao e preview

Entregas:

- validador de workflow
- validacao de handles e conectividade
- preview simples de runtime
- integracao do builder com `dart_flow`

Critero de saida:

- salvar um grafo valido e impedir publicacao de grafo quebrado

### Fase 3 - Runtime publico

Entregas:

- renderer de `presentation`, `form` e `end`
- sessoes de execucao
- salvamento de rascunho
- protocolo basico

Critero de saida:

- abrir um servico, preencher campos e concluir submissao

### Fase 4 - Integracoes e condicionais

Entregas:

- `dynamic-content`
- `condition`
- engine de template para `$campo` e `{{campo}}`
- whitelist de dominios externos
- auditoria basica de integracao

Critero de saida:

- consultar API externa e exibir retorno no fluxo

### Fase 5 - Operacao interna

Entregas:

- inbox por etapa
- atribuicao por departamento
- comentarios internos
- transicoes de status

Critero de saida:

- comissao consegue receber e processar submissao no backoffice

### Fase 6 - Classificacao e ranking

Entregas:

- `rule_engine`
- `score` e `rank`
- ranking batch
- snapshot do calculo
- homologacao e publicacao

Critero de saida:

- piloto SEQUAL ou edital equivalente consegue classificar candidatos

## 7. Piloto recomendado

Escolher um edital de inscricao com classificacao moderada, preferencialmente SEQUAL.
Esse piloto exige as capacidades centrais do produto sem a complexidade extrema de pre-matricula
ou de beneficios emergenciais com alta carga documental.

## 8. Regras nao negociaveis

- nada de `Map<String, dynamic>` como contrato principal do dominio
- versao publicada e imutavel
- integracoes sigilosas executam no backend
- toda decisao de classificacao gera snapshot auditavel
- acesso a dados sensiveis respeita RBAC e escopo por etapa

## 9. Implementacao inicial presente nesta pasta

Esta base ja contem:

- modelos compartilhados em `core/`
- um servico piloto em memoria
- API minima em `backend/`
- shells iniciais de `frontend_backoffice/` e `frontend_portal/`

O proximo incremento natural e ligar o `dart_flow` ao backoffice para editar os `FlowDefinition` do `core`.