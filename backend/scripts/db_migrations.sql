begin;

-- Este arquivo deve rodar sobre um banco nexus recem-recriado pelo create_database.sql.
-- Nao use banco temporario para validar alteracoes locais de schema; recrie o banco limpo.

create extension if not exists unaccent schema pg_catalog;
create extension if not exists pgcrypto schema public;

-- =========================================================
-- Seguranca, identidade e governanca
-- =========================================================

create table public.organograma (
  id serial primary key,
  ativo boolean not null default true
);

-- isso é vital pois um setor/secretaria pode mudar de nome ao longo do tempo
create table public.organograma_historico (
  id serial primary key,
  id_pai integer,
  id_organograma integer not null,
  data_inicio date not null,
  sigla varchar(32),
  nome varchar(128),
  tipo varchar(128),
  sub_tipo varchar(128),
  ultimo boolean not null,
  secretaria boolean default false,
  oficial boolean not null,
  recebe_processo integer not null,
  protocolo boolean,
  permissao_selecao integer,
  caixa_entrada boolean not null default false,
  cor varchar(255),
  constraint fk_organograma_historico_organograma
    foreign key (id_organograma) references public.organograma(id) on delete no action on update no action,
  constraint fk_organograma_historico_pai_organograma
    foreign key (id_pai) references public.organograma(id) on delete no action on update no action,
  constraint id_organograma_cannot_be_equal_to_id_pai_chk check (id_organograma <> id_pai)
);

create index idx_organograma_historico_id_organograma
  on public.organograma_historico using btree (id_organograma asc nulls last);

create unique index organograma_historico_sigla_ultimo_unique_idx
  on public.organograma_historico (sigla)
  where ultimo = true and sigla is not null;

create unique index organograma_historico_ultimo_por_organograma_unique_idx
  on public.organograma_historico (id_organograma)
  where ultimo = true;

comment on column public.organograma_historico.tipo is 'Pra saber se e do tipo Orgao | Unidade | Departamento | Setor';
comment on column public.organograma_historico.sub_tipo is 'Pra saber se e Autarquia | Prefeitura';
comment on column public.organograma_historico.ultimo is 'Representa sempre o ultimo no historico, ou seja, o mais atualizado';
comment on column public.organograma_historico.recebe_processo is 'Status para saber se este organograma pode receber processo, 0 = nao, 1 = sim';
comment on column public.organograma_historico.permissao_selecao is 'Enum para definir se o item do organograma ficara selecionavel em fluxos e permissoes futuras';
comment on column public.organograma_historico.caixa_entrada is 'Define se o item do organograma e uma caixa de entrada apta a receber processos';

create table public.papeis (
  id bigserial primary key,
  codigo varchar(60) not null unique,
  nome varchar(255) not null,
  escopo varchar(30) not null default 'interno',
  descricao text,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint papeis_escopo_check check (escopo in ('cidadao', 'interno', 'sistema'))
);

create table public.permissoes (
  id bigserial primary key,
  codigo varchar(80) not null unique,
  nome varchar(255) not null,
  descricao text,
  criado_em timestamp(6) not null default now()
);

create table public.usuarios (
  id bigserial primary key,
  id_publico uuid not null default gen_random_uuid(),
  nome_usuario varchar(120) not null unique,
  email varchar(255) not null unique,
  hash_senha text,
  nome_exibicao varchar(255) not null,
  tipo_conta varchar(30) not null default 'interno',
  ativo boolean not null default true,
  ultimo_login_em timestamp(6),
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint usuarios_tipo_conta_check check (tipo_conta in ('cidadao', 'interno', 'servico', 'sistema'))
);

comment on column public.usuarios.hash_senha is 'Hash da senha. Nao deve armazenar senha em texto puro.';

create table public.contas_cidadao (
  id bigserial primary key,
  id_usuario bigint not null unique references public.usuarios(id) on delete cascade,
  numero_cadastro_pessoa bigint,
  cpf varchar(20),
  cnpj varchar(20),
  nis varchar(20),
  assunto_govbr varchar(255),
  telefone varchar(30),
  data_nascimento date,
  metadados_json jsonb not null default '{}'::jsonb,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint contas_cidadao_cpf_unique unique (cpf),
  constraint contas_cidadao_cnpj_unique unique (cnpj),
  constraint contas_cidadao_nis_unique unique (nis)
);

create table public.usuarios_organograma (
  id bigserial primary key,
  id_usuario bigint not null references public.usuarios(id) on delete cascade,
  id_organograma integer not null references public.organograma(id) on delete cascade,
  principal boolean not null default false,
  criado_em timestamp(6) not null default now(),
  constraint usuarios_organograma_unique unique (id_usuario, id_organograma)
);

create unique index usuarios_organograma_principal_unique_idx
  on public.usuarios_organograma (id_usuario)
  where principal = true;

create table public.usuarios_papeis (
  id bigserial primary key,
  id_usuario bigint not null references public.usuarios(id) on delete cascade,
  id_papel bigint not null references public.papeis(id) on delete cascade,
  criado_em timestamp(6) not null default now(),
  constraint usuarios_papeis_unique unique (id_usuario, id_papel)
);

create index usuarios_papeis_id_papel_idx on public.usuarios_papeis (id_papel);

create table public.papeis_permissoes (
  id bigserial primary key,
  id_papel bigint not null references public.papeis(id) on delete cascade,
  id_permissao bigint not null references public.permissoes(id) on delete cascade,
  criado_em timestamp(6) not null default now(),
  constraint papeis_permissoes_unique unique (id_papel, id_permissao)
);

create index papeis_permissoes_id_permissao_idx on public.papeis_permissoes (id_permissao);

create table public.sessoes_autenticacao (
  id bigserial primary key,
  id_publico uuid not null default gen_random_uuid(),
  id_usuario bigint not null references public.usuarios(id) on delete cascade,
  hash_refresh_token text,
  endereco_ip inet,
  user_agent text,
  expira_em timestamp(6) not null,
  revogada_em timestamp(6),
  criado_em timestamp(6) not null default now()
);

create table public.chaves_api (
  id bigserial primary key,
  id_publico uuid not null default gen_random_uuid(),
  nome varchar(255) not null,
  hash_chave text not null,
  id_usuario_responsavel bigint references public.usuarios(id) on delete set null,
  id_organograma_responsavel integer references public.organograma(id) on delete set null,
  escopos text[] not null default '{}',
  ativo boolean not null default true,
  ultimo_uso_em timestamp(6),
  expira_em timestamp(6),
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6)
);

comment on column public.chaves_api.hash_chave is 'Hash da chave secreta usada por integracoes externas.';
comment on column public.chaves_api.nome is 'Nome da aplicacao ou integracao proprietaria da chave.';
comment on table public.chaves_api is 'Armazena chaves de API para integracoes entre o Nexus e sistemas externos.';

create table public.clientes_oidc (
  id_cliente varchar(255) primary key,
  hash_segredo_cliente varchar(255),
  nome_cliente varchar(255) not null,
  uris_redirecionamento text[] not null,
  escopos_permitidos text[] not null,
  tipo_aplicacao varchar(50) not null,
  uris_redirecionamento_pos_logout text[] not null default '{}'::text[],
  tipos_grant_suportados text[] not null default '{authorization_code,refresh_token}'::text[],
  tipos_resposta_suportados text[] not null default '{code}'::text[],
  metodo_autenticacao_token varchar(50) not null default 'none',
  ativo boolean not null default true,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6) default now(),
  constraint clientes_oidc_tipo_aplicacao_check check (
    tipo_aplicacao in ('web_spa', 'backend_confidencial', 'aplicativo_nativo')
  )
);

create index idx_clientes_oidc_tipo_aplicacao
  on public.clientes_oidc using btree (tipo_aplicacao asc nulls last);

create index idx_clientes_oidc_ativo
  on public.clientes_oidc using btree (ativo asc nulls last);

create table public.codigos_autorizacao_oidc (
  id bigserial primary key,
  hash_codigo varchar(255) not null unique,
  id_cliente varchar(255) not null references public.clientes_oidc(id_cliente) on delete cascade,
  id_usuario bigint not null references public.usuarios(id) on delete cascade,
  escopos text[] not null,
  uri_redirecionamento text not null,
  expira_em timestamp(6) not null,
  desafio_pkce varchar(255),
  metodo_desafio_pkce varchar(50),
  nonce varchar(255),
  login_govbr boolean not null default false,
  criado_em timestamp(6) not null default now()
);

create index idx_codigos_autorizacao_oidc_expira_em
  on public.codigos_autorizacao_oidc using btree (expira_em asc nulls last);

create index idx_codigos_autorizacao_oidc_id_usuario
  on public.codigos_autorizacao_oidc using btree (id_usuario asc nulls last);

create index idx_codigos_autorizacao_oidc_id_cliente
  on public.codigos_autorizacao_oidc using btree (id_cliente asc nulls last);

create table public.tokens_refresh_oidc (
  id bigserial primary key,
  hash_token varchar(255) not null unique,
  id_cliente varchar(255) not null references public.clientes_oidc(id_cliente) on delete cascade,
  id_usuario bigint not null references public.usuarios(id) on delete cascade,
  escopos text[] not null,
  expira_em timestamp(6) not null,
  criado_em timestamp(6) not null default now(),
  revogado boolean not null default false
);

create index idx_tokens_refresh_oidc_expira_em
  on public.tokens_refresh_oidc using btree (expira_em asc nulls last);

create index idx_tokens_refresh_oidc_id_usuario
  on public.tokens_refresh_oidc using btree (id_usuario asc nulls last);

create index idx_tokens_refresh_oidc_id_cliente
  on public.tokens_refresh_oidc using btree (id_cliente asc nulls last);

create table public.identidades_externas_usuario (
  id bigserial primary key,
  id_usuario bigint not null references public.usuarios(id) on delete cascade,
  nome_provedor varchar(50) not null,
  id_usuario_externo varchar(255) not null,
  detalhes_usuario_provedor jsonb,
  ativo boolean not null default true,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6) default now(),
  constraint identidades_externas_usuario_unique unique (nome_provedor, id_usuario_externo),
  constraint identidades_externas_usuario_usuario_provedor_unique unique (id_usuario, nome_provedor)
);

create index idx_identidades_externas_usuario_provedor_externo
  on public.identidades_externas_usuario using btree (nome_provedor asc nulls last, id_usuario_externo asc nulls last);

create index idx_identidades_externas_usuario_id_usuario
  on public.identidades_externas_usuario using btree (id_usuario asc nulls last);

create table public.redefinicoes_senha (
  id bigserial primary key,
  id_usuario bigint not null unique references public.usuarios(id) on delete cascade,
  hash_token varchar(255) not null unique,
  expira_em timestamp(6) not null,
  criado_em timestamp(6) not null default now()
);

create index idx_redefinicoes_senha_expira_em
  on public.redefinicoes_senha using btree (expira_em asc nulls last);

create table public.controle_redefinicao_senha (
  identificador_usuario text primary key,
  ultima_solicitacao_em timestamp(6) not null default now(),
  ultimo_ip text
);

create index idx_controle_redefinicao_senha_identificador
  on public.controle_redefinicao_senha using btree (identificador_usuario asc nulls last);

create table public.tokens_acesso_oidc (
  id bigserial primary key,
  jti uuid not null default gen_random_uuid(),
  hash_token varchar(255) not null unique,
  id_cliente varchar(255) not null references public.clientes_oidc(id_cliente) on delete cascade,
  id_usuario bigint not null references public.usuarios(id) on delete cascade,
  id_token_refresh bigint references public.tokens_refresh_oidc(id) on delete set null,
  escopos text[] not null,
  tipo_token varchar(30) not null default 'bearer',
  expira_em timestamp(6) not null,
  revogado boolean not null default false,
  claims_json jsonb not null default '{}'::jsonb,
  criado_em timestamp(6) not null default now(),
  constraint tokens_acesso_oidc_tipo_token_check check (tipo_token in ('bearer', 'dpop'))
);

create unique index tokens_acesso_oidc_jti_unique_idx
  on public.tokens_acesso_oidc (jti);

create index idx_tokens_acesso_oidc_expira_em
  on public.tokens_acesso_oidc using btree (expira_em asc nulls last);

create index idx_tokens_acesso_oidc_id_usuario
  on public.tokens_acesso_oidc using btree (id_usuario asc nulls last);

create index idx_tokens_acesso_oidc_id_cliente
  on public.tokens_acesso_oidc using btree (id_cliente asc nulls last);

create index idx_tokens_acesso_oidc_id_token_refresh
  on public.tokens_acesso_oidc using btree (id_token_refresh asc nulls last);

create table public.tokens_id_oidc (
  id bigserial primary key,
  jti uuid not null default gen_random_uuid(),
  hash_token varchar(255) not null unique,
  id_cliente varchar(255) not null references public.clientes_oidc(id_cliente) on delete cascade,
  id_usuario bigint not null references public.usuarios(id) on delete cascade,
  id_token_acesso bigint references public.tokens_acesso_oidc(id) on delete set null,
  nonce varchar(255),
  hash_sessao varchar(255),
  expira_em timestamp(6) not null,
  revogado boolean not null default false,
  claims_json jsonb not null default '{}'::jsonb,
  criado_em timestamp(6) not null default now()
);

create unique index tokens_id_oidc_jti_unique_idx
  on public.tokens_id_oidc (jti);

create index idx_tokens_id_oidc_expira_em
  on public.tokens_id_oidc using btree (expira_em asc nulls last);

create index idx_tokens_id_oidc_id_usuario
  on public.tokens_id_oidc using btree (id_usuario asc nulls last);

create index idx_tokens_id_oidc_id_cliente
  on public.tokens_id_oidc using btree (id_cliente asc nulls last);

create index idx_tokens_id_oidc_id_token_acesso
  on public.tokens_id_oidc using btree (id_token_acesso asc nulls last);

create table public.consentimentos_oidc (
  id bigserial primary key,
  id_cliente varchar(255) not null references public.clientes_oidc(id_cliente) on delete cascade,
  id_usuario bigint not null references public.usuarios(id) on delete cascade,
  escopos_concedidos text[] not null,
  claims_concedidas_json jsonb not null default '{}'::jsonb,
  origem_consentimento varchar(30) not null default 'tela_login',
  concedido_em timestamp(6) not null default now(),
  revogado_em timestamp(6),
  observacoes text,
  constraint consentimentos_oidc_origem_check check (
    origem_consentimento in ('tela_login', 'backoffice', 'api', 'migracao')
  )
);

create index idx_consentimentos_oidc_cliente_usuario
  on public.consentimentos_oidc using btree (id_cliente asc nulls last, id_usuario asc nulls last);

create unique index consentimentos_oidc_ativos_unique_idx
  on public.consentimentos_oidc (id_cliente, id_usuario)
  where revogado_em is null;

-- =========================================================
-- Cadastro territorial e cadastro geral de pessoas
-- =========================================================

create table public.paises (
  id bigserial primary key,
  codigo_iso2 varchar(2) not null unique,
  codigo_iso3 varchar(3) not null unique,
  nome varchar(100) not null unique,
  nacionalidade varchar(100),
  ativo boolean not null default true,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6)
);

create table public.unidades_federativas (
  id serial primary key,
  id_pais bigint not null references public.paises(id) on delete cascade,
  codigo_ibge integer,
  nome varchar(80) not null,
  sigla char(2) not null,
  ativo boolean not null default true,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint unidades_federativas_unique unique (id_pais, sigla),
  constraint unidades_federativas_ibge_unique unique (codigo_ibge)
);

create table public.municipios (
  id bigserial primary key,
  id_unidade_federativa integer not null references public.unidades_federativas(id) on delete cascade,
  codigo_ibge integer,
  nome varchar(120) not null,
  ativo boolean not null default true,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint municipios_unique unique (id_unidade_federativa, nome),
  constraint municipios_ibge_unique unique (codigo_ibge)
);

create table public.tipos_logradouro (
  id serial primary key,
  nome varchar(80) not null unique,
  abreviatura varchar(20),
  ativo boolean not null default true,
  criado_em timestamp(6) not null default now()
);

create table public.escolaridades (
  id serial primary key,
  codigo varchar(30) not null unique,
  descricao varchar(120) not null,
  ordem integer not null default 0,
  ativo boolean not null default true,
  criado_em timestamp(6) not null default now()
);

create table public.categorias_cnh (
  id serial primary key,
  codigo varchar(5) not null unique,
  descricao varchar(60) not null,
  ativo boolean not null default true,
  criado_em timestamp(6) not null default now()
);

create table public.cadastros_pessoa (
  numero_cadastro bigserial primary key,
  id_publico uuid not null default gen_random_uuid(),
  tipo_cadastro varchar(20) not null default 'padrao',
  tipo_pessoa_atual varchar(20) not null default 'indefinido',
  ativo boolean not null default true,
  id_usuario_vinculado bigint references public.usuarios(id) on delete set null,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint cadastros_pessoa_tipo_cadastro_check check (tipo_cadastro in ('padrao', 'interno', 'provisorio')),
  constraint cadastros_pessoa_tipo_pessoa_check check (tipo_pessoa_atual in ('fisica', 'juridica', 'indefinido'))
);

create unique index cadastros_pessoa_usuario_unique_idx
  on public.cadastros_pessoa (id_usuario_vinculado)
  where id_usuario_vinculado is not null;

create table public.cadastros_pessoa_historico (
  id bigserial primary key,
  numero_cadastro bigint not null references public.cadastros_pessoa(numero_cadastro) on delete cascade,
  versao integer not null,
  atual boolean not null default true,
  motivo_atualizacao varchar(30) not null default 'cadastro_inicial',
  justificativa text,
  alterado_por bigint references public.usuarios(id) on delete set null,
  vigente_de timestamp(6) not null default now(),
  vigente_ate timestamp(6),
  tipo_cadastro varchar(20) not null default 'padrao',
  tipo_pessoa varchar(20) not null,
  nome_civil varchar(200) not null,
  nome_social varchar(200),
  razao_social varchar(200),
  nome_fantasia varchar(200),
  cpf varchar(20),
  cnpj varchar(20),
  inscricao_estadual varchar(30),
  rg varchar(20),
  orgao_emissor varchar(40),
  id_uf_orgao_emissor integer references public.unidades_federativas(id) on delete set null,
  data_emissao_rg date,
  numero_cnh varchar(20),
  id_categoria_cnh integer references public.categorias_cnh(id) on delete set null,
  data_validade_cnh date,
  pis_pasep varchar(20),
  id_pais_nacionalidade bigint references public.paises(id) on delete set null,
  id_escolaridade integer references public.escolaridades(id) on delete set null,
  data_nascimento date,
  sexo varchar(20),
  id_tipo_logradouro integer references public.tipos_logradouro(id) on delete set null,
  logradouro varchar(120),
  numero_endereco varchar(20),
  complemento varchar(80),
  bairro varchar(80),
  cep varchar(10),
  id_pais bigint references public.paises(id) on delete set null,
  id_unidade_federativa integer references public.unidades_federativas(id) on delete set null,
  id_municipio bigint references public.municipios(id) on delete set null,
  telefone_residencial varchar(30),
  telefone_comercial varchar(30),
  ramal_comercial varchar(10),
  telefone_celular varchar(30),
  email varchar(255),
  email_adicional varchar(255),
  metadados_json jsonb not null default '{}'::jsonb,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint cadastros_pessoa_historico_unique unique (numero_cadastro, versao),
  constraint cadastros_pessoa_historico_tipo_check check (tipo_pessoa in ('fisica', 'juridica', 'indefinido')),
  constraint cadastros_pessoa_historico_tipo_cadastro_check check (tipo_cadastro in ('padrao', 'interno', 'provisorio')),
  constraint cadastros_pessoa_historico_motivo_check check (
    motivo_atualizacao in ('cadastro_inicial', 'correcao', 'atualizacao_cadastral', 'mudanca_nome', 'mudanca_endereco', 'revisao_documental', 'inativacao', 'reativacao')
  ),
  constraint cadastros_pessoa_historico_sexo_check check (sexo in ('feminino', 'masculino', 'nao_informado', 'outro') or sexo is null)
);

create unique index cadastros_pessoa_historico_atual_unique_idx
  on public.cadastros_pessoa_historico (numero_cadastro)
  where atual = true;

create unique index cadastros_pessoa_historico_cpf_atual_unique_idx
  on public.cadastros_pessoa_historico (cpf)
  where atual = true and cpf is not null;

create unique index cadastros_pessoa_historico_cnpj_atual_unique_idx
  on public.cadastros_pessoa_historico (cnpj)
  where atual = true and cnpj is not null;

comment on column public.cadastros_pessoa_historico.motivo_atualizacao is 'Use correcao para ajuste sem nova versao material e atualizacao_cadastral quando for necessario preservar historico anterior, como mudanca de nome civil ou endereco.';
comment on column public.cadastros_pessoa_historico.atual is 'Indica qual snapshot cadastral esta vigente para novos processos e consultas.';

create table public.movimentacoes_cadastro_pessoa (
  id bigserial primary key,
  numero_cadastro bigint not null references public.cadastros_pessoa(numero_cadastro) on delete cascade,
  id_historico_origem bigint references public.cadastros_pessoa_historico(id) on delete set null,
  id_historico_destino bigint references public.cadastros_pessoa_historico(id) on delete set null,
  tipo_movimentacao varchar(30) not null,
  gera_historico boolean not null default false,
  justificativa text,
  alterado_por bigint references public.usuarios(id) on delete set null,
  criado_em timestamp(6) not null default now(),
  constraint movimentacoes_cadastro_pessoa_tipo_check check (
    tipo_movimentacao in ('cadastro_inicial', 'correcao', 'atualizacao_cadastral', 'mudanca_nome', 'mudanca_endereco', 'inativacao', 'reativacao')
  )
);

create table public.atributos_cadastro_pessoa (
  id bigserial primary key,
  codigo varchar(80) not null unique,
  nome varchar(120) not null,
  tipo_valor varchar(20) not null default 'texto',
  descricao text,
  obrigatorio boolean not null default false,
  ativo boolean not null default true,
  criado_em timestamp(6) not null default now(),
  constraint atributos_cadastro_pessoa_tipo_check check (tipo_valor in ('texto', 'inteiro', 'decimal', 'booleano', 'data', 'json'))
);

create table public.valores_atributos_cadastro_pessoa (
  id bigserial primary key,
  id_historico_cadastro bigint not null references public.cadastros_pessoa_historico(id) on delete cascade,
  id_atributo bigint not null references public.atributos_cadastro_pessoa(id) on delete cascade,
  valor_texto text,
  valor_numero numeric(18,4),
  valor_booleano boolean,
  valor_data date,
  valor_json jsonb,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint valores_atributos_cadastro_pessoa_unique unique (id_historico_cadastro, id_atributo)
);

alter table public.contas_cidadao
  add constraint contas_cidadao_numero_cadastro_pessoa_fk
  foreign key (numero_cadastro_pessoa)
  references public.cadastros_pessoa(numero_cadastro)
  on delete set null;

create unique index contas_cidadao_numero_cadastro_pessoa_unique_idx
  on public.contas_cidadao (numero_cadastro_pessoa)
  where numero_cadastro_pessoa is not null;

-- =========================================================
-- Catalogo de servicos e publicacao
-- =========================================================

create table public.categorias_servico (
  id bigserial primary key,
  codigo varchar(80) not null unique,
  nome varchar(255) not null,
  descricao text,
  ativo boolean not null default true,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6)
);

create table public.etiquetas_servico (
  id bigserial primary key,
  codigo varchar(80) not null unique,
  nome varchar(255) not null,
  criado_em timestamp(6) not null default now()
);

create table public.servicos (
  id bigserial primary key,
  id_publico uuid not null default gen_random_uuid(),
  codigo varchar(80) not null unique,
  nome varchar(255) not null,
  slug varchar(255) not null unique,
  descricao text not null,
  id_categoria bigint references public.categorias_servico(id) on delete set null,
  modo_acesso varchar(40) not null,
  responsavel_servico varchar(255),
  exibir_responsavel_servico boolean not null default false,
  publico_alvo varchar(255),
  sla_horas integer,
  vigente_de timestamp(6),
  vigente_ate timestamp(6),
  ativo boolean not null default true,
  criado_por bigint references public.usuarios(id) on delete set null,
  atualizado_por bigint references public.usuarios(id) on delete set null,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint servicos_modo_acesso_check check (
    modo_acesso in ('publico_anonimo', 'cidadao_autenticado', 'interno', 'hibrido')
  )
);

comment on table public.servicos is 'Catalogo principal de servicos digitais do Nexus.';

create table public.versoes_servico (
  id bigserial primary key,
  id_publico uuid not null default gen_random_uuid(),
  id_servico bigint not null references public.servicos(id) on delete cascade,
  numero_versao integer not null,
  status varchar(20) not null default 'rascunho',
  notas text,
  snapshot_metadados_json jsonb not null default '{}'::jsonb,
  publicado_em timestamp(6),
  publicado_por bigint references public.usuarios(id) on delete set null,
  arquivado_em timestamp(6),
  criado_por bigint references public.usuarios(id) on delete set null,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint versoes_servico_id_servico_unique unique (id, id_servico),
  constraint versoes_servico_status_check check (status in ('rascunho', 'publicada', 'arquivada')),
  constraint versoes_servico_unique unique (id_servico, numero_versao)
);

create unique index versoes_servico_publicada_unique_idx
  on public.versoes_servico (id_servico)
  where status = 'publicada';

create table public.canais_servico (
  id bigserial primary key,
  id_versao_servico bigint not null references public.versoes_servico(id) on delete cascade,
  canal varchar(30) not null,
  visivel boolean not null default true,
  configuracao_json jsonb not null default '{}'::jsonb,
  criado_em timestamp(6) not null default now(),
  constraint canais_servico_canal_check check (
    canal in ('portal_cidadao', 'retaguarda', 'iframe', 'whatsapp')
  ),
  constraint canais_servico_unique unique (id_versao_servico, canal)
);

create table public.servicos_organograma (
  id bigserial primary key,
  id_versao_servico bigint not null references public.versoes_servico(id) on delete cascade,
  id_organograma integer not null references public.organograma(id) on delete cascade,
  criado_em timestamp(6) not null default now(),
  constraint servicos_organograma_unique unique (id_versao_servico, id_organograma)
);

create table public.politicas_acesso_servico (
  id bigserial primary key,
  id_versao_servico bigint not null references public.versoes_servico(id) on delete cascade,
  id_papel bigint references public.papeis(id) on delete cascade,
  codigo_permissao varchar(80) not null,
  permitido boolean not null default true,
  visibilidade_etapas text[] not null default '{}',
  criado_em timestamp(6) not null default now()
);

create unique index politicas_acesso_servico_com_papel_unique_idx
  on public.politicas_acesso_servico (id_versao_servico, id_papel, codigo_permissao)
  where id_papel is not null;

create unique index politicas_acesso_servico_sem_papel_unique_idx
  on public.politicas_acesso_servico (id_versao_servico, codigo_permissao)
  where id_papel is null;

create table public.servicos_etiquetas (
  id bigserial primary key,
  id_servico bigint not null references public.servicos(id) on delete cascade,
  id_etiqueta bigint not null references public.etiquetas_servico(id) on delete cascade,
  criado_em timestamp(6) not null default now(),
  constraint servicos_etiquetas_unique unique (id_servico, id_etiqueta)
);

-- =========================================================
-- Workflows e builder
-- =========================================================

create table public.definicoes_fluxo (
  id bigserial primary key,
  id_publico uuid not null default gen_random_uuid(),
  id_versao_servico bigint not null references public.versoes_servico(id) on delete cascade,
  chave_fluxo varchar(80) not null,
  tipo_fluxo varchar(20) not null,
  titulo varchar(255),
  ponto_entrada boolean not null default false,
  metadados_json jsonb not null default '{}'::jsonb,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint definicoes_fluxo_tipo_check check (tipo_fluxo in ('entrada_dados', 'interno')),
  constraint definicoes_fluxo_unique unique (id_versao_servico, chave_fluxo)
);

create unique index definicoes_fluxo_ponto_entrada_unique_idx
  on public.definicoes_fluxo (id_versao_servico, tipo_fluxo)
  where ponto_entrada = true;

create table public.nos_fluxo (
  id bigserial primary key,
  id_publico uuid not null default gen_random_uuid(),
  id_definicao_fluxo bigint not null references public.definicoes_fluxo(id) on delete cascade,
  chave_no varchar(120) not null,
  tipo_no varchar(40) not null,
  rotulo varchar(255),
  posicao_x numeric(12,2) not null default 0,
  posicao_y numeric(12,2) not null default 0,
  largura numeric(12,2),
  altura numeric(12,2),
  dados_json jsonb not null default '{}'::jsonb,
  versao_schema varchar(20) not null default '1.0.0',
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint nos_fluxo_tipo_check check (
    tipo_no in (
      'inicio',
      'apresentacao',
      'formulario',
      'conteudo_dinamico',
      'condicao',
      'fim',
      'tarefa_interna',
      'atualizacao_status',
      'pontuacao',
      'classificacao'
    )
  ),
  constraint nos_fluxo_unique unique (id_definicao_fluxo, chave_no)
);

create index nos_fluxo_tipo_idx on public.nos_fluxo (tipo_no);

create table public.arestas_fluxo (
  id bigserial primary key,
  id_publico uuid not null default gen_random_uuid(),
  id_definicao_fluxo bigint not null references public.definicoes_fluxo(id) on delete cascade,
  chave_aresta varchar(120) not null,
  id_no_origem bigint not null references public.nos_fluxo(id) on delete cascade,
  id_no_destino bigint not null references public.nos_fluxo(id) on delete cascade,
  handle_origem varchar(80),
  handle_destino varchar(80),
  rotulo varchar(255),
  metadados_json jsonb not null default '{}'::jsonb,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint arestas_fluxo_unique unique (id_definicao_fluxo, chave_aresta),
  constraint arestas_fluxo_nos_distintos_check check (id_no_origem <> id_no_destino)
);

create index arestas_fluxo_origem_idx on public.arestas_fluxo (id_no_origem);
create index arestas_fluxo_destino_idx on public.arestas_fluxo (id_no_destino);

-- =========================================================
-- Estrutura de formulario
-- =========================================================

create table public.secoes_formulario (
  id bigserial primary key,
  id_no_fluxo bigint not null references public.nos_fluxo(id) on delete cascade,
  chave_secao varchar(120) not null,
  titulo varchar(255) not null,
  descricao text,
  ordem integer not null default 0,
  repetivel boolean not null default false,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint secoes_formulario_unique unique (id_no_fluxo, chave_secao)
);

create table public.campos_formulario (
  id bigserial primary key,
  id_no_fluxo bigint not null references public.nos_fluxo(id) on delete cascade,
  id_secao bigint references public.secoes_formulario(id) on delete set null,
  chave_campo varchar(120) not null,
  rotulo varchar(255) not null,
  tipo_campo varchar(40) not null,
  descricao text,
  placeholder varchar(255),
  mascara varchar(80),
  obrigatorio boolean not null default false,
  valor_padrao_json jsonb,
  origem_dados_json jsonb,
  participa_ranking boolean not null default false,
  ordem integer not null default 0,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint campos_formulario_tipo_check check (
    tipo_campo in (
      'texto_curto', 'texto_longo', 'inteiro', 'decimal', 'moeda', 'data', 'data_hora',
      'cpf', 'cnpj', 'email', 'telefone', 'selecao', 'multipla_selecao', 'caixa_marcacao', 'anexo'
    )
  ),
  constraint campos_formulario_unique unique (id_no_fluxo, chave_campo)
);

create table public.opcoes_campo (
  id bigserial primary key,
  id_campo bigint not null references public.campos_formulario(id) on delete cascade,
  valor_opcao varchar(255) not null,
  rotulo_opcao varchar(255) not null,
  ordem integer not null default 0,
  criado_em timestamp(6) not null default now(),
  constraint opcoes_campo_unique unique (id_campo, valor_opcao)
);

create table public.validacoes_campo (
  id bigserial primary key,
  id_campo bigint not null references public.campos_formulario(id) on delete cascade,
  tipo_validacao varchar(60) not null,
  configuracao_json jsonb not null default '{}'::jsonb,
  mensagem varchar(255),
  criado_em timestamp(6) not null default now()
);

create table public.regras_visibilidade_campo (
  id bigserial primary key,
  id_campo bigint not null references public.campos_formulario(id) on delete cascade,
  expressao_json jsonb not null,
  criado_em timestamp(6) not null default now()
);

create index regras_visibilidade_campo_id_campo_idx on public.regras_visibilidade_campo (id_campo);

create table public.calculos_campo (
  id bigserial primary key,
  id_campo bigint not null references public.campos_formulario(id) on delete cascade,
  expressao_json jsonb not null,
  escopo_destino varchar(30) not null default 'campo',
  criado_em timestamp(6) not null default now(),
  constraint calculos_campo_escopo_check check (escopo_destino in ('campo', 'contexto', 'ranking'))
);

create index campos_formulario_id_no_fluxo_idx on public.campos_formulario (id_no_fluxo);
create index validacoes_campo_id_campo_idx on public.validacoes_campo (id_campo);
create index calculos_campo_id_campo_idx on public.calculos_campo (id_campo);

-- =========================================================
-- Runtime, sessoes e protocolos
-- =========================================================

create table public.sessoes_execucao (
  id bigserial primary key,
  id_publico uuid not null default gen_random_uuid(),
  id_servico bigint not null references public.servicos(id) on delete restrict,
  id_versao_servico bigint not null references public.versoes_servico(id) on delete restrict,
  id_fluxo_atual bigint references public.definicoes_fluxo(id) on delete set null,
  id_no_atual bigint references public.nos_fluxo(id) on delete set null,
  id_usuario_cidadao bigint references public.usuarios(id) on delete set null,
  id_usuario_interno bigint references public.usuarios(id) on delete set null,
  canal varchar(30) not null,
  status varchar(20) not null default 'em_andamento',
  iniciada_em timestamp(6) not null default now(),
  finalizada_em timestamp(6),
  cancelada_em timestamp(6),
  contexto_json jsonb not null default '{}'::jsonb,
  snapshot_fluxo_json jsonb not null default '{}'::jsonb,
  constraint sessoes_execucao_servico_versao_fk
    foreign key (id_versao_servico, id_servico)
    references public.versoes_servico(id, id_servico)
    on delete restrict,
  constraint sessoes_execucao_canal_check check (
    canal in ('portal_cidadao', 'retaguarda', 'iframe', 'whatsapp')
  ),
  constraint sessoes_execucao_status_check check (
    status in ('em_andamento', 'concluida', 'cancelada')
  )
);

create index sessoes_execucao_servico_idx on public.sessoes_execucao (id_servico, id_versao_servico);

create unique index sessoes_execucao_id_servico_versao_unique_idx
  on public.sessoes_execucao (id, id_servico, id_versao_servico);

create table public.respostas_sessao (
  id bigserial primary key,
  id_sessao_execucao bigint not null references public.sessoes_execucao(id) on delete cascade,
  id_campo bigint not null references public.campos_formulario(id) on delete restrict,
  chave_campo varchar(120) not null,
  indice_repeticao integer not null default 0,
  valor_json jsonb,
  id_no_origem bigint references public.nos_fluxo(id) on delete set null,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint respostas_sessao_unique unique (id_sessao_execucao, id_campo, indice_repeticao),
  constraint respostas_sessao_indice_repeticao_check check (indice_repeticao >= 0)
);

create index respostas_sessao_sessao_no_idx on public.respostas_sessao (id_sessao_execucao, id_no_origem);

create table public.variaveis_sessao (
  id bigserial primary key,
  id_sessao_execucao bigint not null references public.sessoes_execucao(id) on delete cascade,
  chave_variavel varchar(120) not null,
  valor_json jsonb,
  origem varchar(60),
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint variaveis_sessao_unique unique (id_sessao_execucao, chave_variavel)
);

create index variaveis_sessao_sessao_origem_idx on public.variaveis_sessao (id_sessao_execucao, origem);

create table public.resultados_nos_sessao (
  id bigserial primary key,
  id_sessao_execucao bigint not null references public.sessoes_execucao(id) on delete cascade,
  id_no_fluxo bigint not null references public.nos_fluxo(id) on delete restrict,
  status varchar(30) not null default 'concluido',
  payload_requisicao_json jsonb,
  payload_resposta_json jsonb,
  mensagem_erro text,
  executado_em timestamp(6) not null default now(),
  constraint resultados_nos_sessao_status_check check (status in ('concluido', 'falhou', 'ignorado'))
);

create index resultados_nos_sessao_sessao_status_idx on public.resultados_nos_sessao (id_sessao_execucao, status, executado_em);

create table public.submissoes (
  id bigserial primary key,
  id_publico uuid not null default gen_random_uuid(),
  id_servico bigint not null references public.servicos(id) on delete restrict,
  id_versao_servico bigint not null references public.versoes_servico(id) on delete restrict,
  id_versao_conjunto_regras bigint,
  id_sessao_execucao bigint not null references public.sessoes_execucao(id) on delete restrict,
  id_usuario_cidadao bigint references public.usuarios(id) on delete set null,
  status varchar(30) not null default 'submetida',
  submetida_em timestamp(6) not null default now(),
  snapshot_json jsonb not null default '{}'::jsonb,
  snapshot_ranking_json jsonb,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint submissoes_servico_versao_fk
    foreign key (id_versao_servico, id_servico)
    references public.versoes_servico(id, id_servico)
    on delete restrict,
  constraint submissoes_sessao_servico_versao_fk
    foreign key (id_sessao_execucao, id_servico, id_versao_servico)
    references public.sessoes_execucao(id, id_servico, id_versao_servico)
    on delete restrict,
  constraint submissoes_status_check check (
    status in ('submetida', 'em_analise', 'pendente_documentos', 'elegivel', 'inelegivel', 'ranqueada', 'homologada', 'arquivada')
  )
);

create index submissoes_servico_idx on public.submissoes (id_servico, id_versao_servico, status);
create index submissoes_id_sessao_execucao_idx on public.submissoes (id_sessao_execucao);

create table public.historico_status_submissao (
  id bigserial primary key,
  id_submissao bigint not null references public.submissoes(id) on delete cascade,
  status_anterior varchar(30),
  novo_status varchar(30) not null,
  alterado_por bigint references public.usuarios(id) on delete set null,
  motivo text,
  metadados_json jsonb not null default '{}'::jsonb,
  criado_em timestamp(6) not null default now()
);

create index historico_status_submissao_submissao_criado_idx on public.historico_status_submissao (id_submissao, criado_em);

create table public.protocolos (
  id bigserial primary key,
  id_submissao bigint not null unique references public.submissoes(id) on delete cascade,
  numero_protocolo varchar(40) not null unique,
  codigo_publico varchar(80) not null unique,
  criado_em timestamp(6) not null default now()
);

-- =========================================================
-- Operacao interna
-- =========================================================

create table public.tarefas_internas (
  id bigserial primary key,
  id_publico uuid not null default gen_random_uuid(),
  id_submissao bigint not null references public.submissoes(id) on delete cascade,
  id_no_fluxo bigint references public.nos_fluxo(id) on delete set null,
  titulo varchar(255) not null,
  descricao text,
  id_organograma integer references public.organograma(id) on delete set null,
  status varchar(30) not null default 'aberta',
  prioridade varchar(20) not null default 'normal',
  prazo_em timestamp(6),
  criado_por bigint references public.usuarios(id) on delete set null,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  concluido_em timestamp(6),
  constraint tarefas_internas_status_check check (status in ('aberta', 'em_andamento', 'bloqueada', 'concluida', 'cancelada')),
  constraint tarefas_internas_prioridade_check check (prioridade in ('baixa', 'normal', 'alta', 'critica'))
);

create index tarefas_internas_submissao_status_idx on public.tarefas_internas (id_submissao, status, prazo_em);

create index tarefas_internas_organograma_status_prazo_idx on public.tarefas_internas (id_organograma, status, prazo_em);

create table public.atribuicoes_tarefa (
  id bigserial primary key,
  id_tarefa bigint not null references public.tarefas_internas(id) on delete cascade,
  id_usuario_atribuido bigint references public.usuarios(id) on delete set null,
  id_organograma_atribuido integer references public.organograma(id) on delete set null,
  atribuido_por bigint references public.usuarios(id) on delete set null,
  atribuido_em timestamp(6) not null default now(),
  aceito_em timestamp(6)
);

create index atribuicoes_tarefa_usuario_idx on public.atribuicoes_tarefa (id_usuario_atribuido, atribuido_em);
create index atribuicoes_tarefa_organograma_idx on public.atribuicoes_tarefa (id_organograma_atribuido, atribuido_em);

create table public.comentarios_tarefa (
  id bigserial primary key,
  id_tarefa bigint not null references public.tarefas_internas(id) on delete cascade,
  id_autor bigint references public.usuarios(id) on delete set null,
  corpo text not null,
  interno boolean not null default true,
  criado_em timestamp(6) not null default now()
);

create index comentarios_tarefa_tarefa_criado_idx on public.comentarios_tarefa (id_tarefa, criado_em);

create table public.transicoes_tarefa (
  id bigserial primary key,
  id_tarefa bigint not null references public.tarefas_internas(id) on delete cascade,
  status_anterior varchar(30),
  novo_status varchar(30) not null,
  transitado_por bigint references public.usuarios(id) on delete set null,
  motivo text,
  criado_em timestamp(6) not null default now()
);

create index transicoes_tarefa_tarefa_criado_idx on public.transicoes_tarefa (id_tarefa, criado_em);

-- =========================================================
-- Regras, ranking e classificacao
-- =========================================================

create table public.conjuntos_regras (
  id bigserial primary key,
  id_publico uuid not null default gen_random_uuid(),
  id_servico bigint not null references public.servicos(id) on delete cascade,
  codigo varchar(80) not null,
  nome varchar(255) not null,
  descricao text,
  ativo boolean not null default true,
  criado_por bigint references public.usuarios(id) on delete set null,
  criado_em timestamp(6) not null default now(),
  atualizado_em timestamp(6),
  constraint conjuntos_regras_unique unique (id_servico, codigo)
);

create table public.versoes_conjunto_regras (
  id bigserial primary key,
  id_publico uuid not null default gen_random_uuid(),
  id_conjunto_regras bigint not null references public.conjuntos_regras(id) on delete cascade,
  numero_versao integer not null,
  status varchar(20) not null default 'rascunho',
  descricao text,
  definicao_json jsonb not null default '{}'::jsonb,
  criado_por bigint references public.usuarios(id) on delete set null,
  criado_em timestamp(6) not null default now(),
  publicado_em timestamp(6),
  constraint versoes_conjunto_regras_status_check check (status in ('rascunho', 'publicada', 'arquivada')),
  constraint versoes_conjunto_regras_unique unique (id_conjunto_regras, numero_versao)
);

create unique index versoes_conjunto_regras_publicada_unique_idx
  on public.versoes_conjunto_regras (id_conjunto_regras)
  where status = 'publicada';

create table public.regras_pontuacao (
  id bigserial primary key,
  id_versao_conjunto_regras bigint not null references public.versoes_conjunto_regras(id) on delete cascade,
  chave_regra varchar(120) not null,
  titulo varchar(255) not null,
  expressao_json jsonb not null,
  valor_pontuacao numeric(14,2),
  ordem integer not null default 0,
  criado_em timestamp(6) not null default now(),
  constraint regras_pontuacao_unique unique (id_versao_conjunto_regras, chave_regra)
);

create table public.regras_elegibilidade (
  id bigserial primary key,
  id_versao_conjunto_regras bigint not null references public.versoes_conjunto_regras(id) on delete cascade,
  chave_regra varchar(120) not null,
  titulo varchar(255) not null,
  expressao_json jsonb not null,
  motivo_falha text,
  ordem integer not null default 0,
  criado_em timestamp(6) not null default now(),
  constraint regras_elegibilidade_unique unique (id_versao_conjunto_regras, chave_regra)
);

create table public.execucoes_classificacao (
  id bigserial primary key,
  id_publico uuid not null default gen_random_uuid(),
  id_versao_servico bigint not null references public.versoes_servico(id) on delete restrict,
  id_versao_conjunto_regras bigint not null references public.versoes_conjunto_regras(id) on delete restrict,
  status varchar(20) not null default 'pendente',
  snapshot_dataset_json jsonb not null default '{}'::jsonb,
  executado_por bigint references public.usuarios(id) on delete set null,
  iniciado_em timestamp(6) not null default now(),
  finalizado_em timestamp(6),
  notas text,
  constraint execucoes_classificacao_status_check check (status in ('pendente', 'executando', 'concluida', 'falhou', 'cancelada'))
);

create table public.resultados_classificacao (
  id bigserial primary key,
  id_execucao_classificacao bigint not null references public.execucoes_classificacao(id) on delete cascade,
  id_submissao bigint not null references public.submissoes(id) on delete cascade,
  pontuacao_final numeric(14,2) not null default 0,
  posicao_final integer,
  elegivel boolean not null default true,
  snapshot_desempate_json jsonb,
  justificativa_json jsonb,
  criado_em timestamp(6) not null default now(),
  constraint resultados_classificacao_unique unique (id_execucao_classificacao, id_submissao)
);

create index resultados_classificacao_id_submissao_idx on public.resultados_classificacao (id_submissao);

-- =========================================================
-- Anexos e evidencias
-- =========================================================

create table public.anexos (
  id bigserial primary key,
  id_publico uuid not null default gen_random_uuid(),
  provedor_armazenamento varchar(30) not null default 'local',
  caminho_armazenamento text not null,
  nome_original varchar(255) not null,
  tipo_mime varchar(120) not null,
  tamanho_bytes bigint not null,
  checksum_sha256 varchar(128),
  enviado_por bigint references public.usuarios(id) on delete set null,
  criado_em timestamp(6) not null default now(),
  constraint anexos_provedor_check check (provedor_armazenamento in ('local', 's3', 'minio', 'gcs'))
);

create table public.vinculos_anexos (
  id bigserial primary key,
  id_anexo bigint not null references public.anexos(id) on delete cascade,
  tipo_entidade varchar(40) not null,
  id_entidade bigint not null,
  chave_campo varchar(120),
  criado_em timestamp(6) not null default now()
);

create index vinculos_anexos_entidade_idx on public.vinculos_anexos (tipo_entidade, id_entidade);

create table public.verificacoes_anexos (
  id bigserial primary key,
  id_anexo bigint not null references public.anexos(id) on delete cascade,
  verificado_por bigint references public.usuarios(id) on delete set null,
  status varchar(20) not null,
  notas text,
  criado_em timestamp(6) not null default now(),
  constraint verificacoes_anexos_status_check check (status in ('pendente', 'aprovado', 'rejeitado'))
);

create table public.versoes_anexos (
  id bigserial primary key,
  id_anexo bigint not null references public.anexos(id) on delete cascade,
  numero_versao integer not null,
  caminho_armazenamento text not null,
  checksum_sha256 varchar(128),
  criado_em timestamp(6) not null default now(),
  constraint versoes_anexos_unique unique (id_anexo, numero_versao)
);

-- =========================================================
-- Auditoria e observabilidade
-- =========================================================

create table public.logs_auditoria (
  id bigserial primary key,
  id_publico uuid not null default gen_random_uuid(),
  id_usuario_ator bigint references public.usuarios(id) on delete set null,
  tipo_ator varchar(30) not null default 'usuario',
  acao varchar(120) not null,
  tipo_entidade varchar(60) not null,
  id_entidade bigint,
  id_correlacao uuid,
  endereco_ip inet,
  payload_json jsonb not null default '{}'::jsonb,
  criado_em timestamp(6) not null default now(),
  constraint logs_auditoria_tipo_ator_check check (tipo_ator in ('usuario', 'sistema', 'chave_api'))
);

create index logs_auditoria_entidade_idx on public.logs_auditoria (tipo_entidade, id_entidade);
create index logs_auditoria_acao_idx on public.logs_auditoria (acao);

-- =========================================================
-- Chaves estrangeiras tardias e relacionamentos circulares
-- =========================================================

alter table public.submissoes
  add constraint submissoes_versao_conjunto_regras_fk
  foreign key (id_versao_conjunto_regras)
  references public.versoes_conjunto_regras(id)
  on delete set null;

-- =========================================================
-- Seeds iniciais
-- =========================================================

insert into public.paises (codigo_iso2, codigo_iso3, nome, nacionalidade) values
  ('BR', 'BRA', 'Brasil', 'Brasileira');

insert into public.unidades_federativas (id_pais, codigo_ibge, nome, sigla)
select pais.id, dados.codigo_ibge, dados.nome, dados.sigla
from public.paises pais
cross join (
  values
    (12, 'Acre', 'AC'),
    (27, 'Alagoas', 'AL'),
    (16, 'Amapa', 'AP'),
    (13, 'Amazonas', 'AM'),
    (29, 'Bahia', 'BA'),
    (23, 'Ceara', 'CE'),
    (53, 'Distrito Federal', 'DF'),
    (32, 'Espirito Santo', 'ES'),
    (52, 'Goias', 'GO'),
    (21, 'Maranhao', 'MA'),
    (51, 'Mato Grosso', 'MT'),
    (50, 'Mato Grosso do Sul', 'MS'),
    (31, 'Minas Gerais', 'MG'),
    (15, 'Para', 'PA'),
    (25, 'Paraiba', 'PB'),
    (41, 'Parana', 'PR'),
    (26, 'Pernambuco', 'PE'),
    (22, 'Piaui', 'PI'),
    (33, 'Rio de Janeiro', 'RJ'),
    (24, 'Rio Grande do Norte', 'RN'),
    (43, 'Rio Grande do Sul', 'RS'),
    (11, 'Rondonia', 'RO'),
    (14, 'Roraima', 'RR'),
    (42, 'Santa Catarina', 'SC'),
    (35, 'Sao Paulo', 'SP'),
    (28, 'Sergipe', 'SE'),
    (17, 'Tocantins', 'TO')
) as dados(codigo_ibge, nome, sigla)
where pais.codigo_iso2 = 'BR';

insert into public.municipios (id_unidade_federativa, codigo_ibge, nome)
select uf.id, dados.codigo_ibge, dados.nome
from public.unidades_federativas uf
join (
  values
    ('RJ', 3304557, 'Rio de Janeiro'),
    ('RJ', 3303302, 'Niteroi'),
    ('RJ', 3304524, 'Rio das Ostras'),
    ('SP', 3550308, 'Sao Paulo'),
    ('DF', 5300108, 'Brasilia')
) as dados(sigla_uf, codigo_ibge, nome)
  on dados.sigla_uf = uf.sigla;

insert into public.tipos_logradouro (nome, abreviatura) values
  ('Acesso', 'ACS'),
  ('Alameda', 'AL'),
  ('Avenida', 'AV'),
  ('Beco', 'BCO'),
  ('Distrito', 'DST'),
  ('Estrada', 'EST'),
  ('Ladeira', 'LAD'),
  ('Largo', 'LRG'),
  ('Nao Informado', 'NI'),
  ('Povoado', 'POV'),
  ('Praca', 'PCA'),
  ('Quadra', 'QDA'),
  ('Rodovia', 'ROD'),
  ('Rua', 'R'),
  ('Sitio', 'SIT'),
  ('Travessa', 'TRV');

insert into public.escolaridades (codigo, descricao, ordem) values
  ('nao_informado', 'Nao Informado', 0),
  ('fundamental_incompleto', 'Ensino Fundamental Incompleto', 10),
  ('fundamental_completo', 'Ensino Fundamental Completo', 20),
  ('medio_incompleto', 'Ensino Medio Incompleto', 30),
  ('medio_completo', 'Ensino Medio Completo', 40),
  ('superior_incompleto', 'Ensino Superior Incompleto', 50),
  ('superior_completo', 'Ensino Superior Completo', 60),
  ('pos_graduacao', 'Pos-graduacao', 70),
  ('mestrado', 'Mestrado', 80),
  ('doutorado', 'Doutorado', 90);

insert into public.categorias_cnh (codigo, descricao) values
  ('A', 'Categoria A'),
  ('AB', 'Categoria AB'),
  ('AC', 'Categoria AC'),
  ('AD', 'Categoria AD'),
  ('AE', 'Categoria AE'),
  ('B', 'Categoria B'),
  ('C', 'Categoria C'),
  ('D', 'Categoria D'),
  ('E', 'Categoria E');

insert into public.atributos_cadastro_pessoa (codigo, nome, tipo_valor, descricao) values
  ('observacao_geral', 'Observacao Geral', 'texto', 'Campo livre para observacoes administrativas do cadastro.'),
  ('cadastro_origem', 'Cadastro de Origem', 'texto', 'Identifica o sistema ou fluxo que originou o cadastro.'),
  ('aceite_lgpd', 'Aceite LGPD', 'booleano', 'Marca se houve aceite de termos de privacidade no ato do cadastro.');

with organogramas_iniciais as (
  select *
  from (values
    (1, null, 'NAO-INFORMADO', 'Nao Informado', 'Orgao', 'Sistema', false, true, 0, false, -1, false, '#6b7280'),
    (2, null, 'FMS', 'Fundo Municipal de Saude', 'Orgao', 'Fundo', false, true, 0, false, -1, false, '#0f766e'),
    (3, null, 'FMHIS', 'Fundo Municipal de Habitacao de Interesse Social', 'Orgao', 'Fundo', false, true, 0, false, -1, false, '#0ea5e9'),
    (4, null, 'PMRO', 'Prefeitura Municipal de Rio das Ostras', 'Orgao', 'Prefeitura', true, true, 0, false, -1, false, '#1d4ed8'),
    (5, null, 'FROC', 'Fundacao Rio das Ostras de Cultura', 'Orgao', 'Fundacao', false, true, 0, false, -1, false, '#7c3aed'),
    (6, null, 'SAAE-RO', 'Servico Autonomo de Agua e Esgoto', 'Orgao', 'Autarquia', false, true, 0, false, -1, false, '#0891b2'),
    (7, null, 'OSTRASPREV', 'Rio das Ostras Previdencia', 'Orgao', 'Autarquia', false, true, 0, false, -1, false, '#4f46e5'),
    (8, null, 'FMAS', 'Fundo Municipal de Assistencia Social', 'Orgao', 'Fundo', false, true, 0, false, -1, false, '#a16207'),
    (9, 4, 'GAB', 'Gabinete do Prefeito', 'Unidade', 'Gabinete', true, true, 0, false, -1, false, '#1e40af'),
    (10, 4, 'SEGEP', 'Secretaria Municipal de Gestao Publica', 'Unidade', 'Secretaria', true, true, 1, false, 1, false, '#0f766e'),
    (11, 4, 'SEMUSA', 'Secretaria Municipal de Saude', 'Unidade', 'Secretaria', true, true, 1, false, 1, false, '#059669'),
    (12, 4, 'SEMFAZ', 'Secretaria Municipal de Fazenda', 'Unidade', 'Secretaria', true, true, 1, false, 1, false, '#b45309'),
    (13, 4, 'PGM', 'Procuradoria Geral do Municipio', 'Unidade', 'Procuradoria', true, true, 1, false, 1, false, '#7c2d12'),
    (14, 4, 'SEMED', 'Secretaria Municipal de Educacao', 'Unidade', 'Secretaria', true, true, 1, false, 1, false, '#2563eb'),
    (15, 4, 'SECOM', 'Secretaria Municipal de Comunicacao Social', 'Unidade', 'Secretaria', true, true, 0, false, 1, false, '#9333ea'),
    (16, 4, 'SEMAD', 'Secretaria Municipal de Administracao Publica', 'Unidade', 'Secretaria', true, true, 1, false, 1, false, '#475569'),
    (17, 4, 'SEMOP', 'Secretaria Municipal de Obras', 'Unidade', 'Secretaria', true, true, 1, false, 1, false, '#b91c1c'),
    (18, 4, 'SEMBES', 'Secretaria Municipal de Bem Estar Social', 'Unidade', 'Secretaria', true, true, 1, false, 1, false, '#c2410c'),
    (19, 4, 'SESEP', 'Secretaria Municipal de Seguranca Publica', 'Unidade', 'Secretaria', true, true, 1, false, 1, false, '#0f172a'),
    (20, 11, 'COGA', 'Coordenadoria de Gestao, Avaliacao e Auditoria', 'Departamento', 'Coordenadoria', false, true, 1, false, 1, false, '#047857'),
    (21, 11, 'COAB', 'Coordenadoria de Atencao Basica', 'Departamento', 'Coordenadoria', false, true, 1, false, 1, false, '#0d9488'),
    (22, 12, 'DEAT', 'Departamento de Administracao Tributaria', 'Departamento', 'Departamento', false, true, 1, false, 1, false, '#92400e'),
    (23, 12, 'DECMIT', 'Departamento de Fiscalizacao, Cadastro Mobiliario e Taxas', 'Departamento', 'Departamento', false, true, 1, false, 1, false, '#a16207'),
    (24, 13, 'ASSEJUR', 'Assessoria Juridica', 'Departamento', 'Assessoria', false, true, 1, false, 1, false, '#7c2d12'),
    (25, 13, 'PLC', 'Procuradoria de Licitacoes e Contratos', 'Departamento', 'Procuradoria', false, true, 1, false, 1, false, '#92400e'),
    (26, 14, 'GAB-SEMED', 'Gabinete do Secretario de Educacao', 'Departamento', 'Gabinete', false, true, 1, false, 1, false, '#1d4ed8'),
    (27, 16, 'COGEP', 'Coordenadoria de Gestao de Pessoas', 'Departamento', 'Coordenadoria', false, true, 1, false, 1, false, '#334155'),
    (28, 17, 'DEOB', 'Departamento de Obras Publicas', 'Departamento', 'Departamento', false, true, 1, false, 1, false, '#991b1b'),
    (29, 18, 'CRAS', 'Centro de Referencia de Assistencia Social', 'Departamento', 'Centro', false, true, 1, false, 1, false, '#ea580c'),
    (30, 20, 'OUVIDORIA-SAUDE', 'Ouvidoria', 'Setor', 'Ouvidoria', false, true, 1, true, 1, true, '#065f46'),
    (31, 22, 'ATENDIMENTO-SEMFAZ', 'Atendimento', 'Setor', 'Atendimento', false, true, 1, true, 1, true, '#78350f'),
    (32, 22, 'PROTOCOLO-SEMFAZ', 'Protocolo', 'Setor', 'Protocolo', false, true, 1, true, 1, true, '#92400e'),
    (33, 28, 'DIPROJ', 'Divisao de Projetos', 'Setor', 'Divisao', false, true, 1, false, 1, true, '#7f1d1d'),
    (34, 29, 'CREAS', 'Centro de Referencia Especializado de Assistencia Social', 'Setor', 'Centro', false, true, 1, true, 1, true, '#9a3412')
  ) as dados(codigo_seed, codigo_pai_seed, sigla, nome, tipo, sub_tipo, secretaria, oficial, recebe_processo, protocolo, permissao_selecao, caixa_entrada, cor)
), organogramas_criados as (
  insert into public.organograma (ativo)
  select true
  from organogramas_iniciais
  order by codigo_seed
  returning id
), organogramas_mapeados as (
  select
    oi.codigo_seed,
    oi.codigo_pai_seed,
    oi.sigla,
    oi.nome,
    oi.tipo,
    oi.sub_tipo,
    oi.secretaria,
    oi.oficial,
    oi.recebe_processo,
    oi.protocolo,
    oi.permissao_selecao,
    oi.caixa_entrada,
    oi.cor,
    oc.id as id_organograma
  from organogramas_iniciais oi
  join (
    select row_number() over (order by id) as codigo_seed, id
    from organogramas_criados
  ) oc on oc.codigo_seed = oi.codigo_seed
)
insert into public.organograma_historico (
  id_pai,
  id_organograma,
  data_inicio,
  sigla,
  nome,
  tipo,
  sub_tipo,
  ultimo,
  secretaria,
  oficial,
  recebe_processo,
  protocolo,
  permissao_selecao,
  caixa_entrada,
  cor
)
select
  pai.id_organograma,
  atual.id_organograma,
  date '2000-01-01',
  atual.sigla,
  atual.nome,
  atual.tipo,
  atual.sub_tipo,
  true,
  atual.secretaria,
  atual.oficial,
  atual.recebe_processo,
  atual.protocolo,
  atual.permissao_selecao,
  atual.caixa_entrada,
  atual.cor
from organogramas_mapeados atual
left join organogramas_mapeados pai on pai.codigo_seed = atual.codigo_pai_seed;

select setval(pg_get_serial_sequence('public.organograma', 'id'), coalesce((select max(id) from public.organograma), 1), true);
select setval(pg_get_serial_sequence('public.organograma_historico', 'id'), coalesce((select max(id) from public.organograma_historico), 1), true);

insert into public.papeis (codigo, nome, escopo, descricao) values
  ('cidadao', 'Cidadao', 'cidadao', 'Usuario externo autenticado para inscricoes e acompanhamento.'),
  ('atendente', 'Atendente', 'interno', 'Usuario interno com acesso a monitor operacional.'),
  ('avaliador', 'Avaliador', 'interno', 'Usuario interno que analisa documentos e criterios.'),
  ('supervisor', 'Supervisor', 'interno', 'Usuario interno com poder de homologacao.'),
  ('gestor-servico', 'Gestor do Servico', 'interno', 'Responsavel por editar, publicar e acompanhar servicos.'),
  ('administrador-plataforma', 'Administrador da Plataforma', 'sistema', 'Acesso completo a retaguarda e a governanca do Nexus.');

insert into public.permissoes (codigo, nome, descricao) values
  ('servicos.visualizar', 'Visualizar servicos', 'Permite listar e consultar servicos.'),
  ('servicos.editar', 'Editar servicos', 'Permite criar e editar servicos e versoes em rascunho.'),
  ('servicos.publicar', 'Publicar servicos', 'Permite publicar e arquivar versoes de servicos.'),
  ('runtime.executar', 'Executar runtime', 'Permite iniciar e continuar sessoes do runtime.'),
  ('tarefas.gerenciar', 'Gerenciar tarefas', 'Permite atuar na caixa de entrada, comentar e transicionar tarefas.'),
  ('ranking.executar', 'Executar ranking', 'Permite iniciar processamentos de ranking e classificacao.'),
  ('resultados.homologar', 'Homologar resultados', 'Permite homologar e publicar resultados oficiais.'),
  ('auditoria.visualizar', 'Visualizar auditoria', 'Permite acesso a trilhas de auditoria e logs.');

insert into public.papeis_permissoes (id_papel, id_permissao)
select p.id, pm.id
from public.papeis p
join public.permissoes pm on pm.codigo in ('servicos.visualizar', 'runtime.executar')
where p.codigo = 'cidadao';

insert into public.papeis_permissoes (id_papel, id_permissao)
select p.id, pm.id
from public.papeis p
join public.permissoes pm on pm.codigo in ('servicos.visualizar', 'tarefas.gerenciar')
where p.codigo = 'atendente';

insert into public.papeis_permissoes (id_papel, id_permissao)
select p.id, pm.id
from public.papeis p
join public.permissoes pm on pm.codigo in ('servicos.visualizar', 'tarefas.gerenciar', 'ranking.executar')
where p.codigo = 'avaliador';

insert into public.papeis_permissoes (id_papel, id_permissao)
select p.id, pm.id
from public.papeis p
join public.permissoes pm on pm.codigo in ('servicos.visualizar', 'tarefas.gerenciar', 'ranking.executar', 'resultados.homologar')
where p.codigo = 'supervisor';

insert into public.papeis_permissoes (id_papel, id_permissao)
select p.id, pm.id
from public.papeis p
join public.permissoes pm on pm.codigo in ('servicos.visualizar', 'servicos.editar', 'servicos.publicar', 'tarefas.gerenciar', 'auditoria.visualizar')
where p.codigo = 'gestor-servico';

insert into public.papeis_permissoes (id_papel, id_permissao)
select p.id, pm.id
from public.papeis p
cross join public.permissoes pm
where p.codigo = 'administrador-plataforma';

insert into public.categorias_servico (codigo, nome, descricao) values
  ('qualificacao-profissional', 'Qualificacao Profissional', 'Servicos de inscricao, selecao e classificacao para cursos e programas.'),
  ('estagio', 'Selecao de Estagio', 'Servicos de inscricao e classificacao de estagiarios.'),
  ('beneficio-social', 'Beneficio Social', 'Servicos de elegibilidade, triagem e classificacao para beneficios.'),
  ('consulta-publica', 'Consulta Publica', 'Servicos de consulta de protocolo, andamento e resultado.');

insert into public.etiquetas_servico (codigo, nome) values
  ('piloto', 'Piloto'),
  ('inscricao', 'Inscricao'),
  ('classificacao', 'Classificacao'),
  ('fluxo', 'Fluxo');

-- =========================================================
-- Editorial e portal institucional
-- =========================================================

create table public.atalho_portal (
  id bigserial primary key,
  rotulo varchar(120) not null,
  descricao text not null,
  icone varchar(120) not null,
  rota varchar(255) not null
);

create table public.noticia (
  id bigserial primary key,
  slug varchar(160) not null unique,
  titulo varchar(255) not null,
  resumo text not null,
  categoria varchar(120) not null,
  publicado_em timestamp(6) not null,
  url_imagem text,
  destaque boolean not null default false
);

create index noticia_publicado_em_idx on public.noticia (publicado_em desc);

create table public.publicacao_oficial (
  id bigserial primary key,
  titulo varchar(255) not null,
  tipo varchar(60) not null,
  status varchar(40) not null,
  codigo_referencia varchar(120) not null unique,
  publicado_em timestamp(6) not null,
  area_editorial varchar(120) not null,
  resumo text,
  constraint publicacao_oficial_tipo_check check (
    tipo in ('noticia', 'diario_oficial', 'edital_publico', 'pagina_institucional')
  ),
  constraint publicacao_oficial_status_check check (
    status in ('rascunho', 'agendada', 'publicada', 'arquivada')
  )
);

create index publicacao_oficial_publicado_em_idx
  on public.publicacao_oficial (publicado_em desc);

create table public.pagina_institucional (
  id bigserial primary key,
  titulo varchar(255) not null,
  slug varchar(160) not null unique,
  secao varchar(120) not null,
  status varchar(40) not null,
  resumo text,
  constraint pagina_institucional_status_check check (
    status in ('rascunho', 'agendada', 'publicada', 'arquivada')
  )
);

create index pagina_institucional_secao_idx on public.pagina_institucional (secao);

-- Dados de exemplo e teste devem ser carregados por scripts Dart em backend/scripts.

commit;
