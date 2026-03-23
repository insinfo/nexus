Não é uma boa ideia portar literalmente todas as bibliotecas do Colab. Para o Nexus em puro Dart, o certo é separar em:

bibliotecas que você realmente precisa portar/recriar em Dart;
bibliotecas que basta encapsular por serviço/adapter;
bibliotecas que você não precisa portar de jeito nenhum.

Pelo desenho do Nexus e pela forma como o SALUS já organiza monorepo, core compartilhado, backend e frontend separados, você está no caminho certo para transformar isso em um conjunto de packages Dart coesos, e não num clone 1:1 do ecossistema React.

1. bibliotecas que eu considero essenciais portar ou recriar em Dart

Estas eu trataria como obrigatórias para o Nexus existir de verdade.

núcleo low-code
dart_flow
Seu equivalente ao React Flow / XYFlow.
Já está no caminho.
workflow_schema_dart
Modelos tipados para:
serviço
versão
fluxo
nó
aresta
handles
portas
metadados
snapshots
workflow_runtime_dart
Motor de execução dos nós:
start
presentation
form
dynamic-content
condition
end
depois internal-task, approval, notification, score, rank
workflow_validator_dart
Validação semântica do fluxo:
ciclos inválidos
nó órfão
múltiplos inícios
arestas quebradas
portas incompatíveis
variáveis inexistentes
campos referenciados que não existem
form_schema_dart
Schema declarativo de formulário:
seções
grupos
campos
repetíveis
opções
defaults
visibilidade
obrigatoriedade
layouts
form_runtime_dart
Runtime do formulário:
binding
estado
dirty/touched
validação
repetição
dependência entre campos
cálculo de campos derivados
renderização declarativa
validation_engine_dart
Engine de validação:
required
min/max
regex
CPF
CNPJ
NIS
CEP
e-mail
telefone
data
validadores assíncronos
expression_engine_dart
Uma engine para expressões seguras:
condicionais
cálculos
filtros
templates
comparação de valores
acesso a contexto
Inspirada em coisas como JsonLogic/JEXL/expr-eval, mas tipada para seu domínio.
rule_engine_dart
Regras de negócio e classificação:
elegibilidade
pontuação
desempate
ranking
homologação
justificativas
snapshots auditáveis
template_engine_dart
Para interpolação segura:
{{campo}}
{{contexto.valor}}
templates de texto
payloads dinâmicos de webhook
mensagens e documentos
2. bibliotecas de edição e conteúdo que valem muito a pena portar

Essas substituem o papel de CodeMirror, Editor.js e parte do CMS.

code_editor_dart
Seu equivalente simplificado ao CodeMirror.
Não precisa portar o CodeMirror inteiro.
Precisa ter:
editor de JSON
editor de expressões
destaque de sintaxe
autocompletar básico
erro de parse
lint simples
json_editor_dart
Editor visual + textual para JSON:
árvore
texto
validação
diff
pretty print
rich_content_schema_dart
Estrutura tipada de conteúdo em blocos:
título
parágrafo
lista
aviso
tabela
imagem
FAQ
botão
link
anexo
callout
rich_content_editor_dart
Seu equivalente ao Editor.js, mas em Dart.
Ideal para:
apresentação do serviço
instruções
conteúdo estático
páginas institucionais
notícias
Diário Oficial estruturado no futuro
markdown_blocks_dart
Conversão entre:
markdown
blocos estruturados
HTML seguro
render para portal
safe_html_dart
Sanitização/controlada de HTML, se você ainda quiser aceitar HTML em alguns pontos.
3. bibliotecas de UI que você vai precisar recriar em Dart

Aqui está o ponto importante: não vale portar o Ant Design inteiro.
O certo é criar um design system próprio, focado no que o Nexus realmente usa.

nexus_ui
Biblioteca base de UI:
botões
inputs
dropdowns
checkboxes
radios
tabs
cards
badges
alerts
drawers
modais
breadcrumbs
paginação
steps
empty states
skeletons
loading
toasts
nexus_forms_ui
Componentes visuais específicos de formulário:
input moeda BR
CPF/CNPJ
data/hora
upload
select
multiselect
repetível
tabela editável
endereço
autocomplete territorial
datatable_dart
Grid/tabela robusta:
paginação
ordenação
filtros
colunas customizadas
seleção em lote
exportação
virtualização
treeview_dart
Para organograma, catálogo, permissões, blocos, navegação.
tabs_workspace_dart
Área de trabalho com abas, painéis e shells internos do backoffice.
split_view_dart
Layout com painéis redimensionáveis, essencial para builder visual.
overlay_popper_dart
Popovers, menus, tooltips, dropdowns, painéis flutuantes.
Você já tem base no popper, então isso provavelmente vira evolução do que já fez.
drag_drop_sortable_dart
Reordenação de listas, blocos, seções, campos, menus.
command_stack_dart
Undo/redo, histórico de ações do builder.
focus_shortcuts_dart
Atalhos de teclado, foco, navegação por teclado, acessibilidade.
4. bibliotecas de portal/cms/publicação que você provavelmente vai precisar

Se o Nexus também vai absorver portal, notícias e publicações oficiais, isso já entra no escopo.

cms_schema_dart
Modelos de:
página
notícia
campanha
banner
categoria
menu
bloco
publicação oficial
cms_editor_dart
Builder de páginas e conteúdo institucional.
menu_builder_dart
Construção de menus e navegação hierárquica.
publication_workflow_dart
Fluxo editorial:
rascunho
revisão
aprovado
publicado
arquivado
official_diary_dart
Se quiser Diário Oficial estruturado:
edição
seções
atos
numeração
fechamento de edição
geração de PDF/publicação
5. bibliotecas de operação interna e auditoria

Essas são essenciais para o backoffice administrativo de verdade.

task_runtime_dart
Tarefas internas:
fila
atribuição
prazo
status
transferência
comentários
histórico
kanban_board_dart
Visualização operacional por etapa/status.
comments_timeline_dart
Linha do tempo de eventos, comentários, despachos e anexos.
audit_trail_dart
Trilha auditável:
quem fez
quando fez
antes/depois
origem
snapshot
diff_viewer_dart
Comparação de versões:
serviço
formulário
regra
conteúdo
publicação
protocol_tracking_dart
Número de protocolo, acompanhamento, timeline pública.
6. bibliotecas de autenticação, identidade e segurança
auth_session_dart
Sessão, tokens, refresh, logout, storage seguro.
oidc_client_dart
Cliente OIDC/OAuth2 para login federado.
Não precisa reinventar o protocolo inteiro, mas precisa de uma lib/adapter forte no seu stack.
rbac_dart
Perfis, permissões, escopo por órgão/setor/serviço/etapa.
policy_engine_dart
Regras finas de acesso:
quem vê
quem edita
quem analisa
quem homologa
visibilidade por etapa
masking_privacy_dart
Mascaramento LGPD:
CPF parcial
telefone parcial
renda controlada
campos sensíveis por permissão
7. bibliotecas de dados territoriais, cadastro e integrações municipais
address_territory_dart
Endereço, bairro, loteamento, distrito, CEP, normalização territorial.
person_registry_dart
Cadastro geral de pessoas com histórico.
organization_chart_dart
Organograma, secretarias, setores, equipes, cargos.
integration_connector_dart
Conectores com sistemas externos:
webhook
REST
autenticação
retry
timeout
mapeamento de payload
webhook_builder_dart
Configuração declarativa de chamadas:
método
headers
payload template
parser de resposta
fallback
import_export_dart
CSV, XLSX, JSON, talvez DOCX/PDF depois.
certificate_issue_dart
Emissão de certificados, comprovantes, declarações.
document_generation_dart
Geração de PDFs, protocolos, relatórios e recibos.
8. bibliotecas de analytics e observabilidade
charts_dashboard_dart
Gráficos e dashboards.
metrics_events_dart
Eventos operacionais e métricas de uso.
session_replay_adapter_dart
Adapter para analytics externo, se quiser algo tipo PostHog.
error_tracking_dart
Erros de frontend/backoffice/portal com contexto.
9. bibliotecas utilitárias de alto valor
mask_formatter_br_dart
Máscaras BR:
CPF
CNPJ
CEP
telefone
processo
protocolo
moeda
date_time_utils_br_dart
Datas, horários, fuso, calendário BR, formatação pt-BR.
search_filter_builder_dart
Busca avançada, filtros compostos, chips, operadores.
file_upload_runtime_dart
Upload robusto:
múltiplos arquivos
validação
progresso
previews
restrição por tipo/tamanho
file_preview_dart
Preview de PDF, imagem, texto e anexos simples.
print_export_dart
Impressão amigável de protocolos, listas, relatórios.
o que você não precisa portar integralmente

Essas do ecossistema Colab/React não merecem port completo:

não portar 1:1
React
ReactDOM
React Router
Ant Design inteiro
Axios
Editor.js inteiro
CodeMirror inteiro
PostHog inteiro
Zendesk Widget
Hand Talk
Google Maps API
o que fazer no lugar
React / Router → usar seu stack Dart web.
Axios → usar cliente HTTP Dart.
Ant Design → criar seu próprio limitles_ui. baseado em 
 <link href="https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/icons/phosphor/2.0.3/styles.min.css"
        rel="stylesheet" type="text/css">
    <link href="https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/fonts/inter/inter.min.css" rel="stylesheet"
        type="text/css">
    <link href="https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/css/all.min.css" rel="stylesheet"
        type="text/css">
    <script src="https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/js/bootstrap/bootstrap.bundle.min.js"></script>


Editor.js → criar editor por blocos focado no seu domínio.
CodeMirror → criar editor menor para JSON/expressões.
PostHog / Zendesk / Hand Talk → integrar por adapter, não portar.
MapBox/leeflet → wrapper/adapter, não recriar engine de mapas.
resumo mais honesto

Se você me perguntar “todas as bibliotecas que eu vou ter que portar?”, a resposta honesta é:

não são 60 ports literais
são cerca de 12 a 18 bibliotecas-base realmente críticas
e umas 20 a 30 abstrações/pacotes internos que você vai acabar criando para manter o Nexus modular
ordem ideal de implementação

Eu faria nesta ordem:

fase 1 — absolutamente essencial
dart_flow
workflow_schema_dart
workflow_runtime_dart
workflow_validator_dart
form_schema_dart
form_runtime_dart
validation_engine_dart
expression_engine_dart
rule_engine_dart
template_engine_dart
nexus_ui
overlay_popper_dart
fase 2 — builder profissional
code_editor_dart
json_editor_dart
datatable_dart
drag_drop_sortable_dart
command_stack_dart
tabs_workspace_dart
split_view_dart
fase 3 — operação e portal real
task_runtime_dart
audit_trail_dart
protocol_tracking_dart
auth_session_dart
oidc_client_dart
rbac_dart
masking_privacy_dart
file_upload_runtime_dart
fase 4 — expansão para CMS e Diário Oficial
rich_content_schema_dart
rich_content_editor_dart
cms_schema_dart
cms_editor_dart
publication_workflow_dart
official_diary_dart
minha recomendação direta

Se eu estivesse desenhando o Nexus com você, eu não falaria em “portar todas as bibliotecas do Colab”.
Eu bateria o martelo nestes 15 packages-base como núcleo real do produto:

dart_flow
workflow_schema_dart
workflow_runtime_dart
workflow_validator_dart
form_schema_dart
form_runtime_dart
validation_engine_dart
expression_engine_dart
rule_engine_dart
template_engine_dart
nexus_ui
code_editor_dart
rich_content_editor_dart
datatable_dart
auth_session_dart

Se isso existir bem feito, o resto vira evolução natural.