# Relatório Detalhado da Aplicação SALUS

## 1. Objetivo

Este documento apresenta uma análise técnica detalhada da aplicação localizada em `referencias/salus`, com foco em arquitetura, módulos, modelo de dados, fluxos principais, implantação, testes, riscos e recomendações. O objetivo é fornecer uma visão consolidada do sistema para manutenção, evolução e avaliação técnica.

## 2. Resumo Executivo

O SALUS é um monorepo Dart com separação clara entre backend, frontend, núcleo compartilhado de domínio e bibliotecas reutilizáveis. A aplicação foi estruturada como uma solução web full-stack para cadastro, análise, classificação e acompanhamento de candidatos vinculados a inscrições de auxílio emergencial.

Trata-se de um sistema desenvolvido para a Prefeitura de Rio das Ostras, com foco de atendimento à Secretaria de Bem-Estar Social, apoiando uma comissão especial responsável por receber fichas em papel oriundas dos CRAS, digitalizar esse conteúdo no sistema e executar a classificação das famílias com base nos critérios definidos em lei, decreto e pela própria comissão de análise.

Os principais pontos identificados foram:

- Arquitetura organizada em camadas, com bom reaproveitamento de código entre backend e frontend.
- Backend HTTP baseado em Shelf, com acesso a PostgreSQL via Eloquent e uso de injeção de dependência com GetIt.
- Frontend web em AngularDart, com roteamento interno, serviços REST e uso do ecossistema visual Limitless, tanto por pacote interno quanto por assets CDN no frontend web.
- Regra de negócio centralizada na classificação de candidatos, com cálculo de renda per capita, pontuação por perfil familiar e registro de motivos de desclassificação.
- Existência de testes de integração e infraestrutura no backend, mas cobertura ainda limitada para regras críticas de negócio e frontend.
- Ausência de autenticação/autorização efetiva no fluxo atual, com uso de token fixo no frontend e apenas exemplos comentados no backend.
- Forte aderência a um fluxo administrativo real: comissão especial recebe formulários físicos, cadastra famílias, consolida critérios documentais e produz classificação oficial persistida no sistema.

Em termos práticos, a base do sistema é funcional e relativamente bem modularizada, mas há riscos relevantes em segurança, cobertura de testes e robustez operacional que deveriam ser tratados antes de uma expansão maior de uso.

## 3. Estrutura Geral do Monorepo

O diretório analisado está organizado da seguinte forma:

```text
referencias/salus/
├── backend/
├── core/
├── frontend/
└── packages/
    ├── essential_core/
    ├── limitless_ui/
    └── popper/
```

### 3.1 Backend

Responsável por expor a API HTTP REST, processar regras de negócio, persistir dados no PostgreSQL e gerar respostas consumidas pelo frontend.

### 3.2 Core

Camada compartilhada com modelos, filtros, tipos e utilitários de domínio usados tanto no backend quanto no frontend.

### 3.3 Frontend

Aplicação web em AngularDart (ngdart: 8.0.0-dev.4), responsável por navegação, cadastro, consultas, classificação e visualização de dados do sistema.

Além da camada AngularDart, o frontend utiliza o design system Limitless como base visual e de componentes de interface, reforçando padronização institucional da experiência web.

### 3.4 Packages

Pacotes auxiliares reutilizáveis:

- `essential_core`: estruturas genéricas como filtros, `DataFrame` e contratos de serialização.
- `limitless_ui`: componentes AngularDart reutilizáveis para formulários, tabelas, feedback visual, carregamento e utilidades de interface.
- `popper`: pacote utilitário adicional, usado como apoio pelo ecossistema interno.

## 4. Stack Tecnológica

### 4.1 Backend

- Dart SDK 3.6.2
- PostgreSQL 16
- Shelf
- Shelf Router
- Shelf CORS Headers
- Shelf Multipart
- Eloquent para acesso a banco de dados
- GetIt para injeção de dependência
- dotenv para configuração por ambiente
- logging para observabilidade básica
- dart_excel para exportação de planilhas

### 4.2 Frontend

- AngularDart (`ngdart: 8.0.0-dev.4`)
- `ngrouter: 4.0.0-dev.3`
- `ngforms: 5.0.0-dev.3`
- SCSS
- `chartjs2: ^2.0.0`
- Pacote de UI próprio `limitless_ui`
- Assets visuais do Limitless carregados por CDN no `index.html`
- Bootstrap bundle distribuído junto ao ecossistema Limitless
- `build_web_compilers: ^4.1.1`
- `build_runner: ^2.4.15`
- `ngtest: any`
- `test: ^1.24.0`
- `sass_builder: ^2.2.1`

### 4.3 Banco de Dados

- PostgreSQL 16
- Uso de extensão `unaccent`
- Pool de conexões configurável

## 5. Arquitetura da Aplicação

## 5.1 Arquitetura de Alto Nível

O sistema segue um modelo em camadas:

1. Frontend AngularDart para interação com o usuário.
2. Serviços REST no frontend para consumo da API.
3. Backend Shelf para roteamento, validação, regras e persistência.
4. Repositórios conectados ao PostgreSQL via Eloquent.
5. Camada `core` compartilhando modelos e regras utilitárias.

Essa organização reduz duplicação entre camadas e facilita o reaproveitamento de modelos e filtros, principalmente em operações de listagem e classificação.

## 5.2 Inicialização do Backend

O backend é iniciado por `backend/bin/salus.dart`, que recebe parâmetros de endereço, porta e quantidade de isolates. A configuração do servidor ocorre em `backend/lib/src/shared/bootstrap.dart`.

Aspectos importantes da inicialização:

- Suporte a múltiplos isolates para paralelismo do servidor.
- Pipeline com `logRequests()`.
- Aplicação de CORS.
- Middleware de banco para disponibilizar conexão por requisição.
- Registro das rotas da API no `Router` principal.

Essa abordagem é simples, direta e adequada para um serviço HTTP modular em Dart.

## 5.3 Organização das Rotas do Backend

As rotas centrais estão agregadas em `backend/lib/src/shared/routes.dart`, que monta os módulos por domínio. O padrão observado é a existência de um arquivo de rotas por módulo, apontando para controllers especializados.

Os módulos expostos incluem:

- avaliadores
- bancos
- bairros
- inscrições de auxílio
- órgãos emissores de identidade
- estatísticas
- candidatos de auxílio emergencial

No caso dos candidatos, as rotas estão agrupadas em `backend/lib/src/modules/candidato_auxilio/candidato_auxilio_routes.dart`, usando o nome `grupoRoutes()`. Funcionalmente isso representa o módulo de candidatos, embora o nome do agregador não seja autoexplicativo e sugira uma nomenclatura herdada ou genérica.

## 5.4 Injeção de Dependência e Escopo por Requisição

O backend usa GetIt para resolver dependências. A extensão sobre `Request` permite obter objetos do contêiner associado à requisição, e o middleware de banco injeta uma conexão por request.

Esse desenho traz benefícios claros:

- reduz acoplamento entre controller e infraestrutura;
- facilita testes;
- permite registrar dependências específicas por request;
- evita a passagem manual de conexão por toda a cadeia de chamadas.

## 5.5 Arquitetura do Frontend

O frontend é inicializado em `frontend/web/main.dart`, configurando localidade `pt_BR` e executando o componente raiz Angular.

O componente principal está em `frontend/lib/src/modules/app/app_component.dart`, e a navegação é controlada por rotas em `frontend/lib/src/shared/routes/my_routes.dart` e `frontend/lib/src/shared/routes/route_paths.dart`.

A navegação identificada cobre:

- home
- área restrita principal
- avaliadores
- bancos
- bairros
- órgãos emissores de identidade
- inscrições de auxílio
- candidatos
- classificação de candidatos

O frontend apresenta um padrão coerente de páginas de listagem, inclusão e atualização para os domínios administrativos, além de uma área específica para classificação.

## 5.6 Comunicação Frontend-Backend

O frontend centraliza configuração de API em `frontend/lib/src/shared/rest_config.dart`.

Pontos observados:

- resolução de ambiente por hostname e protocolo;
- suporte a ambiente local, IP de teste e produção;
- base path configurável (`/api/v1`);
- suporte a alias `/backend` quando usado atrás de Nginx.

Essa camada é importante porque concentra a montagem segura de `Uri` e evita concatenações manuais de URL espalhadas pelo sistema.

## 6. Domínio de Negócio

## 6.1 Finalidade Funcional

Pelo modelo de dados, rotas e páginas presentes, o SALUS é uma aplicação voltada à gestão de inscrições e candidatos de auxílio emergencial, incluindo:

- cadastro de inscrições;
- cadastro e manutenção de candidatos;
- cadastro de entidades auxiliares de referência;
- classificação de candidatos com base em critérios normativos;
- extração de dados em planilha;
- visão estatística resumida.

No contexto operacional identificado, o sistema não é apenas um cadastro administrativo genérico. Ele foi concebido para apoiar a Prefeitura de Rio das Ostras, especialmente a Secretaria de Bem-Estar Social, no processamento de fichas físicas enviadas pelos CRAS, permitindo que uma comissão especial registre os dados das famílias afetadas e gere a classificação oficial do Auxílio Municipal Emergencial.

Em termos funcionais, isso significa que o sistema serve como ponte entre:

- o atendimento presencial e documental feito na ponta;
- o recebimento e digitalização das fichas em papel;
- a validação dos critérios legais e documentais;
- a aplicação das regras de classificação estabelecidas em norma;
- a consolidação do resultado oficial da análise.

## 6.2 Domínios Mapeados

Os domínios de negócio identificados são:

- Candidato de auxílio emergencial
- Inscrição de auxílio
- Regra de classificação do auxílio
- Avaliador
- Banco
- Bairro
- Órgão emissor de identidade
- Estatística agregada

## 6.3 Entidades Principais

### Candidato

É a entidade central do sistema. O modelo concentra informações pessoais, endereço, documentos, dados bancários, composição familiar, indícios de vulnerabilidade, avaliadores associados, informações de danos e resultados de classificação.

Há ainda uma coleção de dependentes/rendas vinculada ao candidato, usada para cálculo da renda familiar e da renda per capita.

### Inscrição

Representa uma janela de operação do auxílio. Possui descrição, período de vigência, tipo operacional e indicador de atividade.

### Regra de Classificação

Define os critérios objetivos usados na classificação oficial. O sistema armazena limites de renda, pontos por faixas, pontos por condição familiar e composição familiar mínima.

### Entidades de Apoio

- avaliadores: responsáveis por análise/validação;
- bancos: referência bancária;
- bairros: territorialização;
- órgãos emissores: referência documental.

### Estatísticas

O módulo de estatística expõe informações agregadas para visão geral, distribuição por status e evolução temporal.

## 7. Regras de Negócio Mais Relevantes

As regras abaixo resultam da leitura combinada do código, do schema SQL e do material normativo e operacional utilizado pela comissão, especialmente a Lei nº 3.189/2026, o formulário de cadastro e análise e a estrutura de persistência do sistema.

## 7.0 Enquadramento Normativo e Operacional

O sistema foi desenhado para operacionalizar o Auxílio Municipal Emergencial destinado a famílias residentes em Rio das Ostras afetadas pelas chuvas, com pagamento único de R$ 1.600,00, observando a diretriz de um auxílio por família.

Na prática, a comissão especial utiliza o sistema para transformar fichas físicas em registros estruturados e, a partir daí, executar a classificação oficial segundo critérios legais, técnicos e documentais.

## 7.1 Regras de Cadastro

O sistema deve permitir o cadastro de um requerente por família, vinculado ao código familiar do CadÚnico, com dados pessoais, endereço, dados bancários, critérios prioritários, perdas e danos, conferência documental e composição de renda.

Campos mínimos obrigatórios identificados pelo material funcional e pelo schema:

- data do atendimento;
- nome;
- sexo;
- data de nascimento;
- CPF válido;
- logradouro;
- bairro;
- código familiar;
- banco;
- agência bancária;
- tipo de conta;
- número da conta;
- pelo menos um item em dependentes e renda.

Restrições também visíveis na persistência:

- `nome`, `sexo`, `data_nasc`, `cpf`, `logradouro`, `id_bairro`, `data_atendimento` e `status` aparecem como obrigatórios no schema;
- há unicidade por inscrição para CPF e código familiar.

Validações de entrada esperadas:

- CPF obrigatório e válido;
- código familiar obrigatório com 11 dígitos;
- datas válidas;
- agência e número da conta apenas numéricos;
- sexo limitado a `FEM`, `MASC` ou `TRANS`;
- impossibilidade de repetição de CPF e código familiar dentro da inscrição.

## 7.2 Regras de Elegibilidade

Com base no texto legal e no fluxo de análise, a família só deve ser considerada elegível quando atender aos requisitos abaixo:

- requerente com documento de identificação;
- inscrição no CadÚnico com dados atualizados;
- renda per capita de até meio salário mínimo nacional;
- idade mínima de 18 anos ou emancipação;
- comprovação de residência no município;
- residência, no período dos desastres, em área afetada conforme mapeamento da Defesa Civil;
- apresentação de laudo ou relatório das autoridades competentes, quando aplicável;
- requerimento dentro do prazo previsto no cronograma oficial.

Também ficou claro que a avaliação de elegibilidade e priorização é compartilhada entre a Secretaria de Bem-Estar Social e a Defesa Civil, sendo esta última a referência para confirmação da localidade afetada.

## 7.3 Composição Familiar e Cálculo de Renda

A seção de dependentes e renda é a base do cálculo econômico da classificação. Cada item representa uma pessoa da composição familiar, inclusive o próprio requerente, contendo:

- nome;
- parentesco;
- tipo de renda;
- descrição da renda;
- valor.

Os valores monetários devem ser persistidos em centavos, usando `minorUnits`, e não em ponto flutuante. Exemplo: R$ 218,01 deve ser armazenado como `21801`.

As fórmulas operacionais são:

- `rendaTotalMinorUnits = soma de todos os valores em centavos`;
- `qtdPessoas = quantidade de itens em dependentes/renda`;
- `rendaPerCapita = rendaTotalMinorUnits / qtdPessoas`.

As comparações de classificação devem ocorrer em `minorUnits`, sem necessidade de conversão para `double`.

O material normativo também sugere considerar benefícios assistenciais e programas de transferência de renda federal, estadual e municipal, com exceções específicas não claramente modeladas no formulário atual. Isso indica uma lacuna de modelagem a ser endereçada futuramente.

## 7.4 Classificação de Candidatos

A regra central está em `core/lib/src/utils/candidato_auxilio_classificacao_utils.dart`.

O processamento faz, em essência, os seguintes passos:

1. Soma as rendas declaradas dos dependentes e do requerente.
2. Calcula quantidade de pessoas na composição familiar.
3. Calcula renda per capita.
4. Atribui pontuação por faixa de renda.
5. Atribui pontuação por perfil familiar e critérios prioritários.
6. Atribui pontuação por composição familiar quando aplicável.
7. Verifica motivos de desclassificação.
8. Define resultado final entre classificado e desclassificado.
9. Persiste snapshots dos cálculos e motivos no próprio candidato, quando solicitado.

Essa implementação mostra uma preocupação importante com rastreabilidade da análise, porque persiste não apenas o status final, mas também os dados intermediários que justificam a decisão.

## 7.5 Pontuação da Classificação

De acordo com a ficha de análise da comissão, a pontuação final é formada por três blocos:

- pontos por renda per capita;
- pontos por perfil familiar;
- pontos por composição familiar.

Pontuação por renda per capita:

- até R$ 218,00: 15 pontos;
- de R$ 218,01 até R$ 436,00: 10 pontos;
- de R$ 436,01 até R$ 810,50: 5 pontos.

Pontuação por perfil familiar, com soma cumulativa dos critérios marcados:

- família desabrigada e acolhida em abrigo público: 12;
- família desalojada com registro da Defesa Civil: 12;
- família cadastrada em formulário de emergência SUAS: 11;
- família monoparental: 4;
- família com pessoa idosa de 60 a 79 anos: 4;
- família com pessoa idosa a partir de 80 anos: 5;
- família com criança de 0 a 6 anos: 4;
- família com gestante: 4;
- família com pessoa com deficiência: 4.

Pontuação por composição familiar:

- família com 5 ou mais pessoas: 10 pontos.

Fórmula recomendada:

- `pontuacaoFinal = pontosRenda + pontosPerfilFamiliar + pontosComposicao`.

O sistema e o documento funcional apontam que os critérios prioritários devem ser cumulativos, já que a ficha de análise trata esses itens como componentes independentes da pontuação final.

## 7.6 Critérios de Desclassificação Identificados

Os motivos tratados na utilidade de classificação incluem:

- renda per capita acima do limite de elegibilidade;
- ausência de documentação completa;
- não residir no município no período exigido;
- informações inverídicas;
- ausência de CadÚnico com recusa de inclusão;
- requerimento fora do prazo oficial;
- residência fora da localidade afetada.

Esses critérios indicam que a aplicação não trata apenas de um cadastro simples, mas sim de um processo administrativo normatizado.

Há um detalhe importante de modelagem: o campo `entregouTodosDocumentos` está nomeado de forma positiva, mas a regra correta de impedimento é `false`, isto é, não apresentação dos documentos gera desclassificação.

## 7.7 Regras de Status do Processo

O schema e o fluxo funcional apontam três estados principais para o processo:

- `Inscrito`;
- `Classificado`;
- `Desclassificado`.

Fluxo recomendado:

- ao salvar o cadastro inicial, o candidato fica como `Inscrito`;
- ao concluir a análise, se houver qualquer motivo impeditivo, o status final deve ser `Desclassificado`;
- não havendo impedimento, o status final deve ser `Classificado`.

## 7.8 Geração de Snapshot de Resultado

Há suporte a persistência de informações como:

- status;
- renda total;
- quantidade de pessoas;
- renda per capita calculada;
- pontuação por renda;
- pontuação por perfil familiar;
- pontuação por composição familiar;
- pontuação final;
- motivo de desclassificação;
- regra aplicada.

Esse comportamento é adequado para auditoria, reprocessamento e reconstituição de decisão administrativa.

Na prática, a classificação oficial deve persistir no candidato a regra aplicada, o resultado final e os snapshots do cálculo. A tela de classificação pode exibir prévia, mas a mudança de status só deve ocorrer quando a classificação oficial for executada.

## 7.9 Parametrização Normativa

As regras normativas não devem ficar hardcoded no código-fonte. O desenho atual, com a tabela `regras_classificacao_auxilio`, é tecnicamente adequado para armazenar:

- identificação da regra;
- descrição normativa;
- vigência inicial e final;
- limite de renda para elegibilidade;
- faixas de renda e seus pontos;
- pontuação de cada critério prioritário;
- regra de composição familiar;
- indicador de regra ativa.

Isso é particularmente importante porque há tensão entre o texto legal e as faixas práticas da ficha de análise. A parametrização por vigência reduz esse risco e facilita adaptação normativa futura.

## 7.10 Ajustes de Modelagem Observados

Os seguintes pontos merecem registro explícito no relatório:

- a faixa de renda usada na ficha de análise deve permanecer parametrizada por vigência normativa, e não hardcoded;
- `entregouTodosDocumentos` é um campo semanticamente positivo com impacto negativo quando `false`;
- `sofreuEnchentesAntes` aparece como campo informativo legado e não participa da pontuação principal;
- a persistência da classificação deve continuar armazenando snapshots oficiais do cálculo para auditoria e reprocessamento.

## 8. Camada de Dados

## 8.1 Banco de Dados

O arquivo `backend/scripts/db_migrations.sql` descreve a estrutura principal do banco. O sistema utiliza PostgreSQL com estrutura relacional clara.

Tabelas principais observadas:

- `inscricoes_auxilio`
- `candidatos_auxilio_emergencial`
- `regras_classificacao_auxilio`
- `candidato_depedentes_renda`
- `orgaos_emissores_identidade`
- `avaliadores`
- `bancos`
- tabelas complementares adicionais do domínio

## 8.2 Características do Modelo Relacional

Pontos positivos do modelo:

- uso de chaves primárias e restrições de unicidade;
- enumerações tratadas por `CHECK` em campos importantes;
- comentários SQL descritivos que documentam o significado das colunas;
- unicidade de CPF por inscrição;
- unicidade de código familiar por inscrição;
- estrutura preparada para guardar histórico da classificação no próprio registro do candidato.

## 8.3 Conexão com Banco

O serviço de banco está em `backend/lib/src/db/database_service.dart`.

Características identificadas:

- driver PostgreSQL;
- suporte a pool de conexões;
- schema configurável;
- timezone `America/Sao_Paulo`;
- nome da aplicação no banco definido como `salus`.

Esse serviço é simples e suficiente para a necessidade atual, com separação clara entre configuração e uso.

## 9. Backend em Detalhe

## 9.1 Controllers

Os controllers seguem um padrão uniforme: métodos estáticos, resolução de dependências a partir da requisição e respostas padronizadas, inclusive em caso de erro.

O módulo `estatistica` exemplifica bem esse padrão, com endpoints para:

- visão geral do dashboard;
- distribuição por status;
- evolução mensal.

O módulo `candidato_auxilio` é o mais relevante da aplicação e expõe operações como:

- listagem;
- busca por ID;
- criação;
- atualização;
- exclusão em lote;
- listagem de classificação;
- processamento da classificação;
- exportação para Excel.

## 9.2 Repositórios

Os repositórios realizam a parte mais densa do acesso a dados, com joins entre entidades de referência e filtros avançados. O uso de Eloquent aproxima a experiência de consulta de ORMs conhecidos do ecossistema web tradicional.

Pelo material analisado, o repositório de candidatos é o mais complexo e concentra operações de leitura com enriquecimento dos dados, incluindo bancos, bairros, órgãos emissores e avaliadores.

## 9.3 Tratamento de Erros

O backend demonstra preocupação com respostas padronizadas de erro, incluindo respostas no estilo problem detail para vários cenários. Isso é positivo para integração e suporte operacional.

Existe, porém, uma configuração sensível em `backend/lib/src/shared/app_config.dart` que pode expor detalhes de erro se habilitada. A configuração padrão encontrada está desativada, o que é adequado.

## 10. Frontend em Detalhe

## 10.1 Organização da Interface

O frontend segue o padrão comum em AngularDart:

- componente raiz;
- páginas por domínio;
- rotas nomeadas;
- serviços para acesso à API;
- componentes e utilitários compartilhados.

Há consistência na estrutura de páginas por domínio, normalmente divididas em:

- listagem;
- inclusão;
- atualização.

No caso dos candidatos, há ainda uma página específica de classificação.

## 10.2 Camada de Serviços

Os serviços do frontend encapsulam as chamadas ao backend e preservam a responsabilidade da UI. Isso é visível especialmente no serviço de candidatos, que oferece operações CRUD, consulta de classificação e exportação de Excel.

Também existe uma base genérica para serviços REST, o que reduz duplicação e facilita padronização do consumo da API.

## 10.3 Design System e Reuso de Interface

O pacote `limitless_ui` mostra que o projeto investiu em componentes reutilizáveis para:

- entradas monetárias brasileiras;
- selects personalizados;
- tabelas;
- árvore de navegação;
- overlays de carregamento;
- toasts e diálogos;
- componentes auxiliares de interface.

Além do pacote interno, o frontend também carrega recursos do ecossistema Limitless diretamente no `frontend/web/index.html`, incluindo:

- ícones Phosphor;
- fonte Inter;
- folha de estilos global do Limitless;
- `bootstrap.bundle.min.js` distribuído pelo mesmo stack visual.

Em outras palavras, o design system efetivamente utilizado pela aplicação é o Limitless, tanto no nível do tema visual carregado via CDN quanto no nível de componentes reutilizáveis encapsulados no pacote `limitless_ui`.

Isso é um indicativo positivo de maturidade interna, porque reduz repetição de componentes visuais, acelera desenvolvimento de telas administrativas e mantém alinhamento visual com o padrão de interface adotado no projeto.

## 11. Fluxos Principais da Aplicação

## 11.1 Cadastro de Referências Administrativas

O sistema possui fluxos CRUD para avaliadores, bancos, bairros e órgãos emissores. Esses cadastros apoiam o preenchimento e enriquecimento dos registros de candidatos.

## 11.2 Gestão de Inscrições

As inscrições representam janelas operacionais do auxílio. O sistema permite cadastro, manutenção e uso de uma inscrição ativa como base para classificação e vinculação de candidatos.

## 11.3 Cadastro e Atualização de Candidatos

O fluxo mais importante da aplicação envolve:

1. seleção da inscrição ativa;
2. cadastro do candidato com dados pessoais e documentais;
3. associação a referências como bairro, banco e órgão emissor;
4. lançamento da composição familiar e rendas;
5. registro de critérios sociais e de vulnerabilidade;
6. posterior análise/classificação.

## 11.4 Processamento de Classificação

O fluxo de classificação cruza dados do candidato com a regra vigente da inscrição e produz:

- pontuação;
- elegibilidade;
- resultado final;
- motivo de desclassificação quando houver;
- exportação de dados para análise externa.

Esse é o fluxo mais crítico do ponto de vista institucional e técnico.

## 11.5 Indicadores e Estatísticas

O módulo estatístico sugere a existência de dashboard com indicadores consolidados, voltados a acompanhamento gerencial da operação.

## 12. Implantação e Operação

## 12.1 Estratégia de Deploy

O arquivo `backend/scripts/deploy.sh` indica um processo de implantação manual/scriptado com os seguintes passos:

- atualização do código via `git pull`;
- limpeza de log;
- `dart pub get` no frontend;
- build do frontend com `webdev`;
- criação de links simbólicos para Nginx e Supervisor;
- restart do Nginx;
- atualização das configurações do Supervisor;
- `dart pub upgrade` no backend;
- compilação do backend em executável nativo;
- substituição do binário e restart do serviço.

Essa abordagem é funcional, mas ainda fortemente operacional e dependente de ambiente específico do servidor.

## 12.2 Infraestrutura Inferida

Pelos arquivos presentes, a aplicação em produção tende a operar com:

- Nginx como proxy reverso;
- Supervisor para ciclo de vida do processo backend;
- backend compilado como executável Dart nativo;
- frontend servido como aplicação web estática;
- rota `/backend` como alias de acesso à API.

## 13. Testes e Qualidade

## 13.1 Testes Existentes

Foram identificados testes no backend para:

- integração do módulo de candidatos;
- serviço de banco;
- configuração de injeção de dependência;
- middleware de banco.

Também há benchmark de inserção REST para candidatos.

## 13.2 Avaliação da Cobertura

A cobertura observada ainda é limitada frente à criticidade do sistema.

Pontos de atenção:

- não foi encontrada cobertura visível para frontend;
- a regra de classificação não aparenta ter testes unitários dedicados;
- módulos administrativos adicionais não demonstram cobertura equivalente ao módulo de candidatos;
- o comportamento da exportação e das estatísticas mereceria testes específicos.

## 13.3 Qualidade da Base

Há sinais positivos de engenharia:

- modularização clara;
- uso de testes de integração no backend;
- reaproveitamento de modelos e filtros;
- componentes compartilhados de UI;
- configuração via ambiente;
- preocupação com erros estruturados.

Ao mesmo tempo, ainda existem fragilidades que impactam maturidade de produção, sobretudo em segurança e cobertura de regras críticas.

## 14. Riscos Técnicos Identificados

## 14.1 Segurança

O risco mais sério observado é a ausência de autenticação efetiva no fluxo atual.

Evidências:

- o frontend envia `Authorization: Bearer 123` em `frontend/lib/src/shared/rest_config.dart`;
- o backend contém apenas exemplo comentado de middleware de autenticação em `backend/lib/src/extensions/request_extension_shelf.dart`;
- não foi identificada integração real de autenticação/autorização no bootstrap das rotas.

Impactos possíveis:

- acesso indevido a dados pessoais sensíveis;
- exportação não controlada de dados de candidatos;
- fragilidade grave sob perspectiva de segurança e conformidade.

## 14.2 LGPD e Dados Sensíveis

O sistema manipula dados pessoais e potencialmente sensíveis, como:

- nome;
- CPF;
- renda familiar;
- composição familiar;
- endereço;
- informações sociais e de vulnerabilidade.

Sem autenticação robusta, trilha de auditoria mais explícita e controles de permissão, o risco regulatório é alto.

## 14.3 Cobertura de Testes Insuficiente

A lógica mais crítica do sistema está na classificação, mas a cobertura observada não demonstra proteção proporcional ao risco funcional dessa regra.

## 14.4 Robustez Operacional

Itens que merecem atenção:

- `db_pool_size=1` no arquivo de exemplo, o que pode ser insuficiente com mais de um isolate;
- pipeline sem rate limiting;
- exportação potencialmente pesada sem controles claros de limite;
- dependência de script manual de deploy;
- forte acoplamento operacional a paths fixos do servidor de produção.

## 14.5 Consistência e Nomeação

Embora não seja um problema funcional grave, há pontos de nomenclatura e clareza que dificultam manutenção:

- nome `grupoRoutes()` para o módulo de candidatos;
- pequena inconsistência de ortografia em campos e arquivos históricos, como `depedentes`;
- propriedade `verion` no `pubspec.yaml` do frontend em vez de `version`.

Esses pontos não inviabilizam o sistema, mas aumentam ruído técnico e podem gerar confusão futura.

## 15. Pontos Fortes da Aplicação

- Separação clara entre frontend, backend, core e pacotes reutilizáveis.
- Boa reutilização de código compartilhado.
- Modelo de domínio relativamente rico e aderente ao problema tratado.
- Estrutura de banco bem documentada por comentários SQL.
- Existência de lógica de classificação centralizada e rastreável.
- Uso de design system interno para acelerar o frontend.
- Suporte a exportação e estatísticas, agregando valor operacional.

## 16. Recomendações Prioritárias

## 16.1 Prioridade Alta

1. Implementar autenticação real no backend.
2. Remover token fixo do frontend e introduzir fluxo seguro de sessão ou token.
3. Implementar autorização por perfil/permissão para operações críticas, principalmente exportação e manutenção cadastral.
4. Criar testes unitários da lógica de classificação.
5. Criar testes de integração adicionais para inscrições, estatísticas e cadastros auxiliares.

## 16.2 Prioridade Média

1. Revisar pool de conexões e comportamento com múltiplos isolates.
2. Introduzir limites e paginação defensiva em exportações e consultas pesadas.
3. Melhorar padronização de nomenclaturas em rotas, arquivos e propriedades.
4. Separar melhor configurações por ambiente e formalizar pipeline de deploy.
5. Adicionar trilha de auditoria para ações sensíveis.

## 16.3 Prioridade Estrutural

1. Expandir documentação funcional e técnica do sistema.
2. Formalizar versionamento de API e estratégia de evolução contratual.
3. Adicionar testes de frontend para fluxos principais.
4. Avaliar observabilidade mais robusta com métricas e logs estruturados.

## 17. Conclusão

O SALUS apresenta uma base técnica consistente para uma aplicação administrativa full-stack em Dart, com organização modular, compartilhamento de domínio entre camadas e uma regra de negócio central claramente modelada para classificação de candidatos ao auxílio.

O projeto demonstra boa intenção arquitetural e boa produtividade interna, especialmente pelo uso de pacotes compartilhados e pela separação entre domínio, API e interface. Ao mesmo tempo, ainda há fragilidades importantes que precisam ser enfrentadas para elevar a maturidade operacional da solução, em especial segurança, testes e governança técnica.

Se a intenção for manter e evoluir essa aplicação no médio e longo prazo, o caminho mais urgente é fortalecer autenticação, autorização, testes das regras críticas e padronização operacional. Com esses ajustes, a base atual tem potencial para sustentar evolução com risco significativamente menor.

## 18. Arquivos-Chave Consultados

- `referencias/salus/backend/bin/salus.dart`
- `referencias/salus/backend/lib/src/shared/bootstrap.dart`
- `referencias/salus/backend/lib/src/shared/routes.dart`
- `referencias/salus/backend/lib/src/modules/candidato_auxilio/candidato_auxilio_routes.dart`
- `referencias/salus/backend/lib/src/modules/estatistica/controllers/estatistica_controller.dart`
- `referencias/salus/backend/lib/src/db/database_service.dart`
- `referencias/salus/backend/lib/src/extensions/request_extension_shelf.dart`
- `referencias/salus/backend/.env.example`
- `referencias/salus/backend/scripts/db_migrations.sql`
- `referencias/salus/backend/scripts/deploy.sh`
- `referencias/salus/backend/test/candidato_auxilio_integration_test.dart`
- `referencias/salus/core/lib/src/utils/candidato_auxilio_classificacao_utils.dart`
- `referencias/salus/frontend/web/main.dart`
- `referencias/salus/frontend/lib/src/modules/app/app_component.dart`
- `referencias/salus/frontend/lib/src/shared/routes/my_routes.dart`
- `referencias/salus/frontend/lib/src/shared/rest_config.dart`
- `referencias/salus/packages/limitless_ui/README.md`
- `referencias/salus/packages/essential_core/README.md`

## 19. Estrutura de Diretórios e Finalidade dos Arquivos

Esta seção descreve a estrutura do projeto com foco em manutenção. Em vez de apenas listar pastas, ela explica a finalidade dos arquivos principais e a convenção usada nos conjuntos `.dart`, `.html` e `.scss`.

## 19.1 Convenção Geral de Arquivos

Em boa parte do frontend e dos pacotes de UI, os arquivos seguem a convenção abaixo:

- arquivo `.dart`: lógica do componente, página, serviço, diretiva ou classe de domínio;
- arquivo `.html`: template visual associado ao componente ou página;
- arquivo `.scss`: estilos específicos do componente ou página.

Quando um diretório contém um trio com o mesmo prefixo, isso normalmente significa uma unidade coesa de interface: comportamento, marcação e estilo.

## 19.2 Estrutura do Backend

```text
referencias/salus/backend/
├── benchmark/
├── bin/
├── doc/
├── lib/
│   ├── salus_backend.dart
│   └── src/
│       ├── db/
│       ├── di/
│       ├── extensions/
│       ├── modules/
│       └── shared/
├── scripts/
├── test/
├── pubspec.yaml
├── salus_nginx_production.conf
└── salus_supervisor_production.conf
```

Arquivos e diretórios principais do backend:

- `backend/pubspec.yaml`: manifesto do pacote backend, com dependências de servidor, ORM, DI, Excel e testes.
- `backend/bin/salus.dart`: ponto de entrada do backend; lê argumentos e inicia o servidor.
- `backend/lib/salus_backend.dart`: barrel file do backend; centraliza exports públicos de controllers, repositórios e configuração.
- `backend/salus_nginx_production.conf`: configuração de proxy reverso para produção.
- `backend/salus_supervisor_production.conf`: configuração de execução do backend sob Supervisor.

### 19.2.1 `backend/lib/src/db/`

- `backend/lib/src/db/database_service.dart`: configuração e criação de conexões PostgreSQL via Eloquent.
- `backend/lib/src/db/with_database_middleware.dart`: middleware que injeta conexão de banco por requisição.

### 19.2.2 `backend/lib/src/di/`

- `backend/lib/src/di/dependency_injector.dart`: registro das dependências do backend no contêiner GetIt.

### 19.2.3 `backend/lib/src/extensions/`

- `backend/lib/src/extensions/request_extension_shelf.dart`: extensões de `Request`, utilidades de body parsing, resolução de dependência por request e helpers para grupos de rotas.
- `backend/lib/src/extensions/response_extension.dart`: helpers para padronizar respostas HTTP JSON e problemas de API.

### 19.2.4 `backend/lib/src/shared/`

- `backend/lib/src/shared/app_config.dart`: leitura de variáveis de ambiente e configuração global do backend.
- `backend/lib/src/shared/app_logger.dart`: configuração de logging da aplicação.
- `backend/lib/src/shared/bootstrap.dart`: inicialização do servidor, pipeline de middlewares, CORS e serve HTTP.
- `backend/lib/src/shared/routes.dart`: agregador central das rotas dos módulos.
- `backend/lib/src/shared/cache/memory_ttl_cache.dart`: cache em memória com expiração por tempo.

### 19.2.5 `backend/lib/src/modules/`

Cada módulo segue majoritariamente o padrão:

- arquivo `*_routes.dart`: declara endpoints do módulo;
- `controllers/*_controller.dart`: recebe requisições, valida fluxo e produz respostas;
- `repositories/*_repository.dart`: encapsula queries e persistência.

#### Módulo `avaliador/`

- `backend/lib/src/modules/avaliador/avaliador_routes.dart`: endpoints REST de avaliadores.
- `backend/lib/src/modules/avaliador/controllers/avaliador_controller.dart`: regras de entrada/saída para avaliadores.
- `backend/lib/src/modules/avaliador/repositories/avaliador_repository.dart`: acesso a dados de avaliadores.

#### Módulo `banco/`

- `backend/lib/src/modules/banco/banco_routes.dart`: endpoints REST de bancos.
- `backend/lib/src/modules/banco/controllers/banco_controller.dart`: operações HTTP do módulo banco.
- `backend/lib/src/modules/banco/repositories/banco_repository.dart`: consultas e gravações de bancos.

#### Módulo `bairro/`

- `backend/lib/src/modules/bairro/bairro_routes.dart`: endpoints REST de bairros.
- `backend/lib/src/modules/bairro/controllers/bairro_controller.dart`: camada de controller para bairros.
- `backend/lib/src/modules/bairro/repositories/bairro_repository.dart`: persistência e busca de bairros.

#### Módulo `candidato_auxilio/`

- `backend/lib/src/modules/candidato_auxilio/candidato_auxilio_routes.dart`: rotas de cadastro, classificação, exportação e exclusão de candidatos.
- `backend/lib/src/modules/candidato_auxilio/controllers/candidato_auxilio_controller.dart`: fluxo principal do sistema no backend.
- `backend/lib/src/modules/candidato_auxilio/repositories/candidato_auxilio_repository.dart`: consultas complexas, joins, filtros e escrita de candidatos.

#### Módulo `estatistica/`

- `backend/lib/src/modules/estatistica/estatistica_routes.dart`: endpoints de visão geral e indicadores.
- `backend/lib/src/modules/estatistica/controllers/estatistica_controller.dart`: controller do dashboard estatístico.
- `backend/lib/src/modules/estatistica/repositories/estatistica_repository.dart`: consultas agregadas para indicadores.

#### Módulo `inscricao_auxilio/`

- `backend/lib/src/modules/inscricao_auxilio/inscricao_auxilio_routes.dart`: rotas de inscrições de auxílio.
- `backend/lib/src/modules/inscricao_auxilio/controllers/inscricao_auxilio_controller.dart`: operações HTTP do módulo inscrição.
- `backend/lib/src/modules/inscricao_auxilio/repositories/inscricao_auxilio_repository.dart`: acesso ao banco para inscrições e regras associadas.

#### Módulo `orgao_emissor_identidade/`

- `backend/lib/src/modules/orgao_emissor_identidade/orgao_emissor_identidade_routes.dart`: rotas de órgãos emissores.
- `backend/lib/src/modules/orgao_emissor_identidade/controllers/orgao_emissor_identidade_controller.dart`: camada de entrada do módulo.
- `backend/lib/src/modules/orgao_emissor_identidade/repositories/orgao_emissor_identidade_repository.dart`: persistência do cadastro auxiliar.

### 19.2.6 `backend/scripts/`

- `backend/scripts/db_migrations.sql`: schema SQL principal da aplicação.
- `backend/scripts/deploy.sh`: automação de deploy, build e restart dos serviços.
- `backend/scripts/popular_candidatos_classificacao.dart`: script de geração de massa de dados para classificação.

### 19.2.7 `backend/test/`

- `backend/test/candidato_auxilio_integration_test.dart`: teste de integração do fluxo principal de candidatos.
- `backend/test/database_service_test.dart`: teste do serviço de banco.
- `backend/test/dependency_injector_test.dart`: teste da configuração de DI.
- `backend/test/with_database_middleware_test.dart`: teste do middleware de conexão por requisição.

### 19.2.8 `backend/benchmark/`

- `backend/benchmark/README.md`: orientação do benchmark do backend.
- `backend/benchmark/candidato_insert_rest_benchmark.dart`: benchmark de inserção REST de candidatos.

### 19.2.9 `backend/doc/`

- `backend/doc/doc.md`: documentação auxiliar do domínio ou do projeto.
- `backend/doc/doc_2.md`: consolidação normativa e funcional sobre cadastro, elegibilidade e classificação.
- `backend/doc/formularios_regras.pdf`: material de apoio da comissão e formulários.
- `backend/doc/logo.cdr`: arte vetorial ou material gráfico institucional.

## 19.3 Estrutura do Core

```text
referencias/salus/core/
├── lib/
│   ├── core.dart
│   └── src/
│       ├── exceptions/
│       ├── extensions/
│       ├── models/
│       └── utils/
├── test/
└── pubspec.yaml
```

Arquivos principais do core:

- `core/pubspec.yaml`: manifesto do pacote compartilhado de domínio.
- `core/lib/core.dart`: barrel file do domínio compartilhado.

### 19.3.1 `core/lib/src/models/`

- `core/lib/src/models/serialize_base.dart`: contrato base de serialização.
- `core/lib/src/models/filters.dart`: filtros de listagem e consulta do domínio SALUS.
- `core/lib/src/models/avaliador.dart`: modelo de avaliador.
- `core/lib/src/models/banco.dart`: modelo de banco.
- `core/lib/src/models/bairro.dart`: modelo de bairro.
- `core/lib/src/models/candidato_auxilio.dart`: modelo central do candidato ao auxílio emergencial.
- `core/lib/src/models/candidato_depedente_renda.dart`: modelo de dependentes e composição de renda.
- `core/lib/src/models/export_column_definition.dart`: definição de colunas exportáveis.
- `core/lib/src/models/inscricao_auxilio.dart`: modelo da inscrição do auxílio.
- `core/lib/src/models/orgao_emissor_identidade.dart`: modelo de órgão emissor de identidade.
- `core/lib/src/models/regra_classificacao_auxilio.dart`: modelo parametrizado da regra de classificação.
- `core/lib/src/models/status_message.dart`: mensagens e constantes de status usadas pelo sistema.

### 19.3.2 `core/lib/src/utils/`

- `core/lib/src/utils/brl_money_utils.dart`: utilitários monetários em centavos e cálculos de renda per capita.
- `core/lib/src/utils/candidato_auxilio_classificacao_utils.dart`: regra principal de classificação do auxílio.
- `core/lib/src/utils/core_utils.dart`: utilitários gerais do pacote core.

### 19.3.3 `core/lib/src/exceptions/`

- `core/lib/src/exceptions/api_problem_exception.dart`: exceção base para problemas de API.
- `core/lib/src/exceptions/duplicate_field_exception.dart`: exceção para campos duplicados.
- `core/lib/src/exceptions/not_found_exception.dart`: exceção para recurso não encontrado.
- `core/lib/src/exceptions/unauthorized_exception.dart`: exceção de acesso não autorizado.

### 19.3.4 `core/lib/src/extensions/`

- `core/lib/src/extensions/map_extension.dart`: extensões utilitárias para manipulação de mapas.

### 19.3.5 `core/test/`

- `core/test/candidato_auxilio_classificacao_utils_test.dart`: testes da lógica de classificação.
- `core/test/core_utils_test.dart`: testes de utilitários.
- `core/test/data_frame_test.dart`: testes de estruturas de dados compartilhadas.

## 19.4 Estrutura do Frontend

```text
referencias/salus/frontend/
├── lib/
│   ├── salus_frontend.dart
│   └── src/
│       ├── modules/
│       └── shared/
├── test/
├── web/
├── analysis_options.yaml
├── build.yaml
└── pubspec.yaml
```

Arquivos de base do frontend:

- `frontend/pubspec.yaml`: manifesto da aplicação web.
- `frontend/analysis_options.yaml`: regras de análise estática do frontend.
- `frontend/build.yaml`: configuração de build do ecossistema AngularDart.
- `frontend/lib/salus_frontend.dart`: barrel file do frontend; centraliza exports de Angular, serviços, diretivas e pacotes compartilhados.

### 19.4.1 `frontend/web/`

- `frontend/web/index.html`: shell HTML da aplicação, com carga do Limitless via CDN, Chart.js e `main.dart.js`.
- `frontend/web/main.dart`: bootstrap AngularDart do frontend.
- `frontend/web/style.scss`: estilos globais da aplicação web.
- `frontend/web/site.webmanifest`: manifesto PWA.
- `frontend/web/favicon.svg`, `favicon.ico`, `favicon-96x96.png`: ícones da aplicação.
- `frontend/web/apple-touch-icon.png`, `web-app-manifest-192x192.png`, `web-app-manifest-512x512.png`: ícones e assets para instalação/atalho.
- `frontend/web/assets/js/chart.js`: biblioteca de gráficos usada no dashboard.
- `frontend/web/assets/images/logo_icon.svg`, `logo_text.svg`: identidade visual usada na interface.

### 19.4.2 `frontend/lib/src/shared/`

#### Configuração, DI e rotas

- `frontend/lib/src/shared/rest_config.dart`: configuração central de endpoints e cabeçalhos do backend.
- `frontend/lib/src/shared/di/di.dart`: configuração do injetor do frontend.
- `frontend/lib/src/shared/routes/my_routes.dart`: mapa de rotas da aplicação.
- `frontend/lib/src/shared/routes/route_paths.dart`: definição dos caminhos nomeados.

#### Serviços compartilhados

- `frontend/lib/src/shared/services/rest_service_base.dart`: base genérica para consumo da API.
- `frontend/lib/src/shared/services/bairro_service.dart`: serviço compartilhado para bairros.
- `frontend/lib/src/shared/services/orgao_emissor_identidade_service.dart`: serviço compartilhado para órgãos emissores.

#### Diretivas e validações

- `frontend/lib/src/shared/directives/custom_form_directives.dart`: barrel de diretivas de formulário.
- `frontend/lib/src/shared/directives/cpf_mask_directive.dart`: máscara de CPF.
- `frontend/lib/src/shared/directives/codigo_familiar_mask_directive.dart`: máscara do código familiar.
- `frontend/lib/src/shared/directives/form_validators/custom_cpf_validator.dart`: validação de CPF.
- `frontend/lib/src/shared/directives/form_validators/custom_codigo_familiar_validator.dart`: validação do código familiar.
- `frontend/lib/src/shared/directives/form_validators/custom_date_validator.dart`: validação de data.
- `frontend/lib/src/shared/directives/form_validators/custom_email_validator.dart`: validação de e-mail.
- `frontend/lib/src/shared/directives/form_validators/custom_numeric_validator.dart`: validação de campos numéricos.
- `frontend/lib/src/shared/directives/form_validators/custom_required_validator.dart`: validação de obrigatoriedade.
- `frontend/lib/src/shared/directives/form_validators/custom_validator_directive.dart`: base ou diretiva agregadora de validação customizada.

#### Componentes, pipes, extensões e utilidades

- `frontend/lib/src/shared/components/simple_popover/simple_popover.dart`: componente auxiliar de popover.
- `frontend/lib/src/shared/components/simple_toast/simple_toast.dart`: toast simples do frontend.
- `frontend/lib/src/shared/pipes/date_pipe.dart`: pipe de formatação de data.
- `frontend/lib/src/shared/extensions/http_response_extension.dart`: extensões utilitárias para respostas HTTP.
- `frontend/lib/src/shared/exceptions/invalid_pipe_argument_exception.dart`: exceção de pipe inválido.
- `frontend/lib/src/shared/utils/frontend_utils.dart`: utilidades diversas do frontend.

### 19.4.3 `frontend/lib/src/modules/app/`

- `frontend/lib/src/modules/app/app_component.dart`: componente raiz da aplicação.
- `frontend/lib/src/modules/app/app_component.html`: template do root com `router-outlet`.
- `frontend/lib/src/modules/app/app_component.scss`: estilos do shell principal.

### 19.4.4 `frontend/lib/src/modules/home/`

- `frontend/lib/src/modules/home/services/estatistica_service.dart`: consome endpoints de estatística.
- `frontend/lib/src/modules/home/pages/home/home_page.dart`: lógica da página inicial interna.
- `frontend/lib/src/modules/home/pages/home/home_page.html`: template da home.
- `frontend/lib/src/modules/home/pages/home/home_page.scss`: estilos da home.
- `frontend/lib/src/modules/home/pages/main/main_page.dart`: shell principal da área restrita.
- `frontend/lib/src/modules/home/pages/main/main_page.html`: navegação, menus e outlet interno.
- `frontend/lib/src/modules/home/pages/main/main_page.scss`: estilos do layout principal.

### 19.4.5 `frontend/lib/src/modules/avaliador/`

- `frontend/lib/src/modules/avaliador/services/avaliador_service.dart`: serviço REST de avaliadores.
- `frontend/lib/src/modules/avaliador/components/avaliador_form/avaliador_form_component.dart`: lógica do formulário de avaliador.
- `frontend/lib/src/modules/avaliador/components/avaliador_form/avaliador_form_component.html`: template do formulário de avaliador.
- `frontend/lib/src/modules/avaliador/components/avaliador_form/avaliador_form_component.scss`: estilos do formulário.
- `frontend/lib/src/modules/avaliador/pages/lista_avaliador/lista_avaliador_page.dart`: tela de listagem.
- `frontend/lib/src/modules/avaliador/pages/lista_avaliador/lista_avaliador_page.html`: template de listagem.
- `frontend/lib/src/modules/avaliador/pages/lista_avaliador/lista_avaliador_page.scss`: estilos da listagem.
- `frontend/lib/src/modules/avaliador/pages/incluir_avaliador/incluir_avaliador_page.dart`: tela de inclusão.
- `frontend/lib/src/modules/avaliador/pages/incluir_avaliador/incluir_avaliador_page.html`: template de inclusão.
- `frontend/lib/src/modules/avaliador/pages/incluir_avaliador/incluir_avaliador_page.scss`: estilos de inclusão.
- `frontend/lib/src/modules/avaliador/pages/atualizar_avaliador/atualizar_avaliador_page.dart`: tela de atualização.
- `frontend/lib/src/modules/avaliador/pages/atualizar_avaliador/atualizar_avaliador_page.html`: template de edição.
- `frontend/lib/src/modules/avaliador/pages/atualizar_avaliador/atualizar_avaliador_page.scss`: estilos de edição.

### 19.4.6 `frontend/lib/src/modules/banco/`

- `frontend/lib/src/modules/banco/services/banco_service.dart`: serviço REST de bancos.
- `frontend/lib/src/modules/banco/components/banco_form/banco_form_component.dart`: lógica do formulário de banco.
- `frontend/lib/src/modules/banco/components/banco_form/banco_form_component.html`: template do formulário.
- `frontend/lib/src/modules/banco/components/banco_form/banco_form_component.scss`: estilos do formulário.
- `frontend/lib/src/modules/banco/pages/lista_banco/lista_banco_page.dart`: tela de listagem de bancos.
- `frontend/lib/src/modules/banco/pages/lista_banco/lista_banco_page.html`: template da listagem.
- `frontend/lib/src/modules/banco/pages/lista_banco/lista_banco_page.scss`: estilos da listagem.
- `frontend/lib/src/modules/banco/pages/incluir_banco/incluir_banco_page.dart`: tela de inclusão.
- `frontend/lib/src/modules/banco/pages/incluir_banco/incluir_banco_page.html`: template de inclusão.
- `frontend/lib/src/modules/banco/pages/incluir_banco/incluir_banco_page.scss`: estilos de inclusão.
- `frontend/lib/src/modules/banco/pages/atualizar_banco/atualizar_banco_page.dart`: tela de edição.
- `frontend/lib/src/modules/banco/pages/atualizar_banco/atualizar_banco_page.html`: template de edição.
- `frontend/lib/src/modules/banco/pages/atualizar_banco/atualizar_banco_page.scss`: estilos da edição.

### 19.4.7 `frontend/lib/src/modules/bairro/`

- `frontend/lib/src/modules/bairro/components/bairro_form/bairro_form_component.dart`: lógica do formulário de bairro.
- `frontend/lib/src/modules/bairro/components/bairro_form/bairro_form_component.html`: template do formulário.
- `frontend/lib/src/modules/bairro/components/bairro_form/bairro_form_component.scss`: estilos do formulário.
- `frontend/lib/src/modules/bairro/pages/lista_bairro/lista_bairro_page.dart`: tela de listagem de bairros.
- `frontend/lib/src/modules/bairro/pages/lista_bairro/lista_bairro_page.html`: template da listagem.
- `frontend/lib/src/modules/bairro/pages/lista_bairro/lista_bairro_page.scss`: estilos da listagem.
- `frontend/lib/src/modules/bairro/pages/incluir_bairro/incluir_bairro_page.dart`: tela de inclusão.
- `frontend/lib/src/modules/bairro/pages/incluir_bairro/incluir_bairro_page.html`: template de inclusão.
- `frontend/lib/src/modules/bairro/pages/incluir_bairro/incluir_bairro_page.scss`: estilos da inclusão.
- `frontend/lib/src/modules/bairro/pages/atualizar_bairro/atualizar_bairro_page.dart`: tela de edição.
- `frontend/lib/src/modules/bairro/pages/atualizar_bairro/atualizar_bairro_page.html`: template de edição.
- `frontend/lib/src/modules/bairro/pages/atualizar_bairro/atualizar_bairro_page.scss`: estilos da edição.

### 19.4.8 `frontend/lib/src/modules/inscricao_auxilio/`

- `frontend/lib/src/modules/inscricao_auxilio/services/inscricao_auxilio_service.dart`: serviço REST de inscrições e regras relacionadas.
- `frontend/lib/src/modules/inscricao_auxilio/components/inscricao_auxilio_form/inscricao_auxilio_form_component.dart`: lógica do formulário de inscrição.
- `frontend/lib/src/modules/inscricao_auxilio/components/inscricao_auxilio_form/inscricao_auxilio_form_component.html`: template do formulário.
- `frontend/lib/src/modules/inscricao_auxilio/components/inscricao_auxilio_selector/inscricao_auxilio_selector_component.dart`: seletor de inscrição ativa ou contextual.
- `frontend/lib/src/modules/inscricao_auxilio/components/inscricao_auxilio_selector/inscricao_auxilio_selector_component.html`: template do seletor.
- `frontend/lib/src/modules/inscricao_auxilio/pages/lista_inscricao_auxilio/lista_inscricao_auxilio_page.dart`: listagem de inscrições.
- `frontend/lib/src/modules/inscricao_auxilio/pages/lista_inscricao_auxilio/lista_inscricao_auxilio_page.html`: template da listagem.
- `frontend/lib/src/modules/inscricao_auxilio/pages/incluir_inscricao_auxilio/incluir_inscricao_auxilio_page.dart`: tela de criação.
- `frontend/lib/src/modules/inscricao_auxilio/pages/incluir_inscricao_auxilio/incluir_inscricao_auxilio_page.html`: template da criação.
- `frontend/lib/src/modules/inscricao_auxilio/pages/atualizar_inscricao_auxilio/atualizar_inscricao_auxilio_page.dart`: tela de atualização.
- `frontend/lib/src/modules/inscricao_auxilio/pages/atualizar_inscricao_auxilio/atualizar_inscricao_auxilio_page.html`: template da edição.

### 19.4.9 `frontend/lib/src/modules/orgao_emissor_identidade/`

- `frontend/lib/src/modules/orgao_emissor_identidade/components/orgao_emissor_identidade_form/orgao_emissor_identidade_form_component.dart`: lógica do formulário de órgão emissor.
- `frontend/lib/src/modules/orgao_emissor_identidade/components/orgao_emissor_identidade_form/orgao_emissor_identidade_form_component.html`: template do formulário.
- `frontend/lib/src/modules/orgao_emissor_identidade/components/orgao_emissor_identidade_form/orgao_emissor_identidade_form_component.scss`: estilos do formulário.
- `frontend/lib/src/modules/orgao_emissor_identidade/pages/lista_orgao_emissor_identidade/lista_orgao_emissor_identidade_page.dart`: listagem do cadastro.
- `frontend/lib/src/modules/orgao_emissor_identidade/pages/lista_orgao_emissor_identidade/lista_orgao_emissor_identidade_page.html`: template da listagem.
- `frontend/lib/src/modules/orgao_emissor_identidade/pages/lista_orgao_emissor_identidade/lista_orgao_emissor_identidade_page.scss`: estilos da listagem.
- `frontend/lib/src/modules/orgao_emissor_identidade/pages/incluir_orgao_emissor_identidade/incluir_orgao_emissor_identidade_page.dart`: tela de inclusão.
- `frontend/lib/src/modules/orgao_emissor_identidade/pages/incluir_orgao_emissor_identidade/incluir_orgao_emissor_identidade_page.html`: template de inclusão.
- `frontend/lib/src/modules/orgao_emissor_identidade/pages/incluir_orgao_emissor_identidade/incluir_orgao_emissor_identidade_page.scss`: estilos de inclusão.
- `frontend/lib/src/modules/orgao_emissor_identidade/pages/atualizar_orgao_emissor_identidade/atualizar_orgao_emissor_identidade_page.dart`: tela de edição.
- `frontend/lib/src/modules/orgao_emissor_identidade/pages/atualizar_orgao_emissor_identidade/atualizar_orgao_emissor_identidade_page.html`: template de edição.
- `frontend/lib/src/modules/orgao_emissor_identidade/pages/atualizar_orgao_emissor_identidade/atualizar_orgao_emissor_identidade_page.scss`: estilos da edição.

### 19.4.10 `frontend/lib/src/modules/candidato_auxilio/`

- `frontend/lib/src/modules/candidato_auxilio/services/candidato_auxilio_service.dart`: serviço principal de candidatos, incluindo classificação e exportação.
- `frontend/lib/src/modules/candidato_auxilio/services/candidato_catalogos_cache_service.dart`: cache de catálogos auxiliares do módulo de candidatos.
- `frontend/lib/src/modules/candidato_auxilio/components/candidato_form/candidato_form_component.dart`: lógica do formulário central de candidato.
- `frontend/lib/src/modules/candidato_auxilio/components/candidato_form/candidato_form_component.html`: template do formulário de candidato.
- `frontend/lib/src/modules/candidato_auxilio/components/candidato_form/candidato_form_component.scss`: estilos do formulário de candidato.
- `frontend/lib/src/modules/candidato_auxilio/pages/lista_candidato/lista_candidato_page.dart`: tela de listagem e navegação para edição.
- `frontend/lib/src/modules/candidato_auxilio/pages/lista_candidato/lista_candidato_page.html`: template da listagem.
- `frontend/lib/src/modules/candidato_auxilio/pages/lista_candidato/lista_candidato_page.scss`: estilos da listagem.
- `frontend/lib/src/modules/candidato_auxilio/pages/incluir_candidato/incluir_candidato_page.dart`: tela de criação.
- `frontend/lib/src/modules/candidato_auxilio/pages/incluir_candidato/incluir_candidato_page.html`: template de criação.
- `frontend/lib/src/modules/candidato_auxilio/pages/incluir_candidato/incluir_candidato_page.scss`: estilos da criação.
- `frontend/lib/src/modules/candidato_auxilio/pages/atualizar_candidato/atualizar_candidato_page.dart`: tela de atualização de cadastro.
- `frontend/lib/src/modules/candidato_auxilio/pages/atualizar_candidato/atualizar_candidato_page.html`: template da edição.
- `frontend/lib/src/modules/candidato_auxilio/pages/atualizar_candidato/atualizar_candidato_page.scss`: estilos da edição.
- `frontend/lib/src/modules/candidato_auxilio/pages/classificacao_candidato/classificacao_candidato_page.dart`: tela de classificação e análise dos candidatos.
- `frontend/lib/src/modules/candidato_auxilio/pages/classificacao_candidato/classificacao_candidato_page.html`: template da classificação.
- `frontend/lib/src/modules/candidato_auxilio/pages/classificacao_candidato/classificacao_candidato_page.scss`: estilos da tela de classificação.

### 19.4.11 `frontend/test/`

- `frontend/test/components/br_currency_input/br_currency_input_component_test.dart`: testes do componente de entrada monetária.
- `frontend/test/components/br_currency_input/br_currency_input_formatter_test.dart`: testes do formatador monetário.

## 19.5 Estrutura dos Pacotes Compartilhados

### 19.5.1 `packages/essential_core/`

```text
referencias/salus/packages/essential_core/
├── lib/
│   ├── essential_core.dart
│   └── src/
│       ├── extensions/
│       ├── models/
│       └── utils/
├── test/
└── pubspec.yaml
```

Arquivos principais:

- `packages/essential_core/pubspec.yaml`: manifesto do pacote.
- `packages/essential_core/lib/essential_core.dart`: barrel file do pacote.
- `packages/essential_core/lib/src/models/data_frame.dart`: estrutura genérica de resposta paginada.
- `packages/essential_core/lib/src/models/filter.dart`: filtro básico.
- `packages/essential_core/lib/src/models/filter_search_field.dart`: definição de campo pesquisável.
- `packages/essential_core/lib/src/models/filters.dart`: conjunto genérico de filtros.
- `packages/essential_core/lib/src/models/serialize_base.dart`: contrato de serialização.
- `packages/essential_core/lib/src/extensions/iterable_extension.dart`: extensões para iteráveis.
- `packages/essential_core/lib/src/extensions/string_extensions.dart`: extensões para strings.
- `packages/essential_core/lib/src/utils/core_utils.dart` e `essential_core_utils.dart`: utilidades compartilhadas.
- `packages/essential_core/test/data_frame_test.dart`: teste de `DataFrame`.
- `packages/essential_core/test/filters_test.dart`: teste dos filtros.

### 19.5.2 `packages/limitless_ui/`

```text
referencias/salus/packages/limitless_ui/
├── lib/
│   ├── limitless_ui.dart
│   └── src/
│       ├── components/
│       ├── directives/
│       ├── exceptions/
│       ├── extensions/
│       └── pipes/
├── README.md
└── pubspec.yaml
```

Arquivos de base:

- `packages/limitless_ui/pubspec.yaml`: manifesto do design system em Dart.
- `packages/limitless_ui/lib/limitless_ui.dart`: barrel file de exportação pública.
- `packages/limitless_ui/README.md`: documentação de uso dos componentes.

Pipes, exceções, extensões e diretivas:

- `packages/limitless_ui/lib/src/pipes/date_pipe.dart`: pipe de data.
- `packages/limitless_ui/lib/src/pipes/hide_string_pipe.dart`: pipe para ocultação parcial de texto.
- `packages/limitless_ui/lib/src/exceptions/invalid_argument_exception.dart`: exceção para argumento inválido.
- `packages/limitless_ui/lib/src/exceptions/invalid_pipe_argument_exception.dart`: exceção para uso incorreto de pipe.
- `packages/limitless_ui/lib/src/extensions/selection_api_extension.dart`: extensões ligadas a seleção e DOM.
- `packages/limitless_ui/lib/src/directives/click_outside.dart`: diretiva de clique externo.
- `packages/limitless_ui/lib/src/directives/dropdown_menu_directive.dart`: diretiva de menu dropdown.
- `packages/limitless_ui/lib/src/directives/form_directives.dart`: agregador de diretivas de formulário.
- `packages/limitless_ui/lib/src/directives/indexed_name_directive.dart`: diretiva utilitária para nomes indexados.
- `packages/limitless_ui/lib/src/directives/safe_append_html_directive.dart`: inserção segura de HTML.
- `packages/limitless_ui/lib/src/directives/safe_inner_html_directive.dart`: renderização segura de HTML.
- `packages/limitless_ui/lib/src/directives/value_accessors/custom_checkbox_control_value_accessor.dart`: integração de checkbox com formulários.
- `packages/limitless_ui/lib/src/directives/value_accessors/custom_select_control_value_acessor.dart`: integração de select customizado com formulários.
- `packages/limitless_ui/lib/src/directives/value_accessors/date_value_accessor.dart`: integração de datas com formulários.

Componentes do design system:

- `packages/limitless_ui/lib/src/components/loading/loading.dart`: overlay de carregamento.
- `packages/limitless_ui/lib/src/components/simple_toast/simple_toast.dart`: toast simples.
- `packages/limitless_ui/lib/src/components/simple_popover/simple_popover.dart`: popover simples.
- `packages/limitless_ui/lib/src/components/simple_dialog/simple_dialog.dart`: diálogo simples.
- `packages/limitless_ui/lib/src/components/modal_component/modal_component.dart`, `.html`, `.scss`: modal genérico.
- `packages/limitless_ui/lib/src/components/notification_toast/notification_toast.dart`, `.html`, `.scss` e `notification_toast_service.dart`: notificações visuais e serviço associado.
- `packages/limitless_ui/lib/src/components/sweet_alert/sweet_alert_popover.dart` e `sweet_alert_toast.dart`: wrappers de alertas visuais.
- `packages/limitless_ui/lib/src/components/br_currency_input/br_currency_input_component.dart`, `.html`, `.scss` e `br_currency_input_formatter.dart`: input monetário brasileiro e seu formatador.
- `packages/limitless_ui/lib/src/components/custom_select/custom_select.dart`, `.html`, `.scss`, `custom_option.dart` e `custom_option.html`: select customizado e opção individual.
- `packages/limitless_ui/lib/src/components/custom_multi_select/custom_multi_select.dart`, `.html`, `.scss`, `custom_multi_option.dart` e `custom_multi_option.html`: multiselect customizado.
- `packages/limitless_ui/lib/src/components/date_range_picker/date_range_picker_component.dart`, `.html`, `.scss`: seletor de intervalo de datas.
- `packages/limitless_ui/lib/src/components/dynamic_tabs/dynamic_tabs.dart`, `.html`, `dynamic_tab_directive.dart` e `dynamic_tab_header_directive.dart`: navegação por abas dinâmicas.
- `packages/limitless_ui/lib/src/components/treeview/simple_treeview.dart`, `.html`, `.scss` e `tree_view_base.dart`: árvore hierárquica de dados.
- `packages/limitless_ui/lib/src/components/datatable/datatable_component.dart`, `.html`, `.scss`, `datatable_col.dart`, `datatable_row.dart`, `datatable_settings.dart`, `datatable_style.dart`, `pagination_item.dart` e `grid.scss`: tabela reutilizável com paginação e configuração.

### 19.5.3 `packages/popper/`

```text
referencias/salus/packages/popper/
├── lib/
│   ├── popper.dart
│   └── src/
│       ├── middleware/
│       └── utils/
├── example/
├── test/
└── pubspec.yaml
```

Arquivos principais:

- `packages/popper/pubspec.yaml`: manifesto do pacote.
- `packages/popper/lib/popper.dart`: barrel file do pacote popper.
- `packages/popper/lib/src/controller.dart`: controlador central do posicionamento.
- `packages/popper/lib/src/compute_position.dart`: cálculo de posicionamento do elemento flutuante.
- `packages/popper/lib/src/constants.dart`: constantes internas do pacote.
- `packages/popper/lib/src/detect_overflow.dart`: detecção de overflow.
- `packages/popper/lib/src/portal.dart`: mecanismo de portal para elementos sobrepostos.
- `packages/popper/lib/src/types.dart`: tipos do pacote.
- `packages/popper/lib/src/middleware/arrow.dart`: ajuste de seta do popover.
- `packages/popper/lib/src/middleware/auto_placement.dart`: posicionamento automático.
- `packages/popper/lib/src/middleware/flip.dart`: inversão de lado quando necessário.
- `packages/popper/lib/src/middleware/hide.dart`: ocultação em cenários específicos.
- `packages/popper/lib/src/middleware/inline.dart`: suporte a posicionamento inline.
- `packages/popper/lib/src/middleware/offset.dart`: deslocamento de posicionamento.
- `packages/popper/lib/src/middleware/shift.dart`: correção de deslocamento na viewport.
- `packages/popper/lib/src/middleware/size.dart`: ajuste por tamanho disponível.
- `packages/popper/lib/src/utils/debug_rects.dart`: utilitário de debug visual.
- `packages/popper/lib/src/utils/dom.dart`: utilidades de DOM.
- `packages/popper/lib/src/utils/placement.dart`: regras e parsing de placement.
- `packages/popper/example/popper_example.dart`: exemplo de uso.
- `packages/popper/test/popper_test.dart`: teste do pacote.

## 19.6 Observação de Manutenção

Para o frontend e para o `limitless_ui`, a forma mais eficiente de leitura da estrutura é por unidade funcional. Sempre que houver um diretório com nomes como `*_component.dart`, `*.html` e `*.scss`, a interpretação correta é:

- o `.dart` concentra comportamento e integração com serviços;
- o `.html` materializa a interface;
- o `.scss` define o acabamento visual local.

Isso ajuda a navegar pelo projeto sem precisar reinterpretar manualmente cada pasta a cada manutenção.