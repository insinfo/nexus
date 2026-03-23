# Estado Atual do Port de `xyflow-main` para Dart

Data da avaliacao: 2026-03-21

## 1. Estrutura relevante

- Implementacao Dart atual concentrada em `lib`, com separacao de componentes por pasta em `lib/src/components/*`.
- Referencia principal analisada:
  - `referencias/xyflow-main/packages/system/src` com 48 arquivos.
  - `referencias/xyflow-main/packages/react/src` com 128 arquivos.
- Nucleo Dart atual:
  - API publica em `lib/dart_flow.dart`.
  - camada `system` em `lib/src/system`.
  - tipos em `lib/src/types`.
  - utilitarios em `lib/src/utils`.
  - estado em `lib/src/state`.
  - componentes em `lib/src/components`.
  - fixtures de teste AngularDart em `lib/src/testing`.

## 2. Partes ja portadas

- Tipos basicos de grafo, viewport, handles e arestas ja existem em `lib/src/types/models.dart`.
- Modelo de changes simplificado para nodes e edges ja existe em `lib/src/types/changes.dart`.
- Ha uma API de renderizacao dinamica tipada em `lib/src/types/renderers.dart`.
- Utilitarios essenciais de grafo ja foram portados:
  - `getIncomers`, `getOutgoers`, `getConnectedEdges`, `getNodesBounds`, `getViewportForBounds`, `addEdge`, `reconnectEdge` em `lib/src/utils/graph.dart`.
- Calculo de paths de edges ja foi portado em nivel utilitario:
  - `getBezierPath`, `getStraightPath`, `getSmoothStepPath`, `getSimpleBezierPath` em `lib/src/utils/edge_paths.dart`.
- Ja existe uma camada `system` inicial para aproximar `XYPanZoom` e `XYDrag`:
  - conversoes de coordenadas, zoom com ancora, pan, constrain/sync helpers, estado transitório mais explicito de panzoom e viewport em `lib/src/system/xypanzoom.dart`
  - drag com snap, extent, auto-pan, multi-drag e selecao por retangulo em `lib/src/system/xydrag.dart`
  - conexao interativa e reconnect base, com modo de conexao, validacao customizavel e estado/finalizacao de conexao mais ricos, em `lib/src/system/xyhandle.dart`
  - internals medidos de node/handle e filtragem por viewport em `lib/src/system/node_internals.dart`
- Existe um controlador de estado local com viewport, selecao, drag simples e fitView em `lib/src/state/flow_controller.dart`.
- Existe um controller de interacao transitória em `lib/src/state/ng_flow_interaction_controller.dart` para drag, pan, resize, selection, connection e reconnect.
- O lifecycle de connection e reconnect agora foi mais unificado no controller, compartilhando o mesmo estado base de `XYHandle` e aproximando melhor a semantica do fluxo original.
- O inicio real de drag-to-connect e reconnect por drag agora respeita `dragThreshold` no controller, aproximando o comportamento de `XYHandle.ts` e reduzindo decisao de ponteiro direta no componente.
- O `NgFlowComponent` agora expoe eventos de lifecycle mais proximos da referencia para conexao e reconnect por gesto: `connectStart`, `connectEnd`, `reconnectStart` e `reconnectEnd`.
- Existe uma store reativa com snapshots, lookups, internals, visibilidade, bounds, viewportRect e streams mais granulares em `lib/src/state/ng_flow_store.dart`.
- Existe uma instance API mais proxima de hooks/helpers em `lib/src/state/ng_flow_instance.dart`, incluindo helpers de lookup, internals, conversao screen/flow e helpers adicionais de viewport/sync.
- A instance API agora tambem expoe listas derivadas como `selectedNodes` e `selectedEdges`, aproximando a ergonomia da referencia.
- Existe um provider dedicado em `lib/src/components/ng_flow_provider/ng_flow_provider_component.dart`.
- Existe uma casca visual funcional de fluxo com renderizacao de nodes/edges, pan por mouse, zoom por wheel, drag de node, selection rectangle, reconnection visual, resize, toolbars e a11y/keyboard avancado em `lib/src/components/ng_flow/ng_flow_component.dart`.
- O `NgFlowComponent` ja consome a nova camada `system` para drag com snap/extent/auto-pan/multi-drag, selecao por retangulo e conexao/reconnect.
- O `NgFlowComponent` agora delega a maior parte do estado transitório de ponteiro para `NgFlowInteractionController`, reduzindo acoplamento direto no componente.
- O renderer agora suporta multiplos handles por no com ids reais em `FlowEdge.sourceHandle` e `FlowEdge.targetHandle`.
- Custom nodes e custom edges dinamicos com `ComponentFactory` e `ViewContainerRef.createComponent(...)` ja estao suportados via hosts dinamicos.
- Componentes auxiliares basicos existem:
  - background em `lib/src/components/background/background_component.dart`
  - controls em `lib/src/components/controls/controls_component.dart`
  - minimap em `lib/src/components/minimap/minimap_component.dart`
  - panel em `lib/src/components/panel/panel_component.dart`
  - handle em `lib/src/components/handle/handle_component.dart`
- O minimap agora ja suporta navegacao interativa basica por clique e drag.
- Ja existe uma suite inicial de testes:
  - unitarios em `test/system`, `test/state` e `test/utils`
  - browser/ngtests em `test/browser` e `test/ng`
- A suite agora tambem cobre cancelamento de connection/reconnect no browser e cenarios unitarios de `dragThreshold` no controller.
- A suite browser agora tambem cobre emissao de `connectStart/connectEnd` e `reconnectStart/reconnectEnd`, incluindo o disparo real apenas apos exceder `dragThreshold`.
- A execucao de browser/ngtests via `build_runner test` ja foi validada neste ambiente apos habilitar symlink/Developer Mode no Windows.

## 3. Lacunas e areas incompletas

- O port ja cobre uma faixa relevante do `xyflow-main`, mas ainda nao tem equivalentes para toda a arquitetura React/System.
- Ainda nao ha parity total dos modulos de sistema de interacao:
  - `XYHandle` agora existe em camada separada inicial com validacao customizavel, estado final mais rico e inicio de lifecycle por `dragThreshold`, mas ainda sem toda a semantica/event lifecycle da referencia
  - `XYPanZoom` ja ganhou helpers de constraint/sync/scale e estado transitório mais proximo da referencia, mas ainda sem a profundidade completa dela
  - `XYDrag` agora ja cobre multi-drag e parte dos internals, mas ainda sem parity total de constraints e comportamento fino da referencia
- Ha conexao interativa basica, `drag-to-connect` com linha temporaria e reconnect visual, e isso ja esta parcialmente desacoplado da UI; o inicio do gesto agora esta mais proximo da referencia, mas ainda nao existe uma camada de interacao tao completa quanto ela.
- Nao ha:
  - equivalencia completa para hooks/view helpers do ecossistema ReactFlow
  - uma store tao rica quanto o modelo interno completo da referencia
  - virtualizacao / renderizacao de elementos visiveis
  - acessibilidade no nivel completo da referencia
  - sincronizacao controlada de estado no mesmo grau de granularidade da store do React Flow
- Ainda faltam equivalentes completos dos hooks mais usados do ecossistema ReactFlow, embora a instance/store atuais ja cubram parte importante desse papel.
- O `example` principal builda e analisa, e ja demonstra dynamic node/edge, mas ainda pode ser expandido em exemplos focados por recurso.
- O fonte original em `referencias/xyflow-main` passou a ser usado diretamente como norte para o design da camada `system`, especialmente em `XYDrag.ts`, `XYHandle.ts` e `XYPanZoom.ts`.

## 3.1. O que ainda nao esta em paridade total

- equivalentes completos dos hooks do ecossistema ReactFlow
- internals/store com paridade mais proxima do modelo completo do React Flow
- viewport helpers e store APIs de maior granularidade
- `XYHandle` com paridade mais completa de validacao/semantica
- drag/pan/selection com parity mais profunda em relacao a `XYDrag` e `XYPanZoom`
- lifecycle/eventos de conexao e pan/zoom ainda menos ricos que no fonte original, embora o gate por `dragThreshold`, a unificacao de connection/reconnect e os outputs de start/end por gesto ja estejam mais proximos dele
- a11y avancado no mesmo nivel de refinamento da referencia
- fechamento da API publica restante do ReactFlow com helpers/streams equivalentes aos hooks mais usados
- documentacao de uso e exemplos focados por recurso

## 4. Riscos tecnicos evidentes

- O estado atual mistura "API parecida" com "comportamento bem mais simples". Isso cria risco de falsa compatibilidade com exemplos e expectativas do `xyflow`.
- O `NgFlowComponent` ainda concentra parte importante da renderizacao e de alguns fluxos de interacao, embora o estado transitório ja tenha sido bastante extraido.
- O `NgFlowComponent` ainda concentra parte importante da renderizacao e de alguns fluxos de interacao, embora o gate de `dragThreshold` e mais decisao de lifecycle ja tenham sido movidos para o controller.
- O algoritmo atual de edge positioning ja respeita `sourceHandle` e `targetHandle`, mas a camada de medicao/layout ainda e muito mais simples do que a referencia.
- A store atual ja oferece snapshot/lookups/streams/bounds/visibilidade/internals medidos, mas ainda nao possui caches e granularidade comparaveis ao modelo interno completo da referencia.
- A store atual ja oferece snapshot/lookups/streams/bounds/visibilidade/internals medidos e `viewportRect`, mas ainda nao possui caches e granularidade comparaveis ao modelo interno completo da referencia.
- A superficie publica ficou mais forte com `NgFlowInstance`, `NgFlowStore` e `ng-flow-provider`, mas ainda nao fecha toda a ergonomia dos hooks do ReactFlow.
- A camada `system` nova melhora testabilidade e separacao, e agora ja segue mais de perto o fonte original em helpers de drag/connect/panzoom, inclusive no inicio real de connection/reconnect por threshold e no estado transitório de pan, mas ainda cobre apenas uma parte da profundidade de `XYHandle`, `XYPanZoom` e `XYDrag`.
- O `analysis_options.yaml` ja ignora `packages` e `referencias`, e o `example` principal ja foi corrigido; o risco agora e mais de cobertura funcional do que de build basico.
- A validacao browser ja esta funcionando no ambiente atual, mas ainda falta ampliar essa cobertura para cenarios de interacao mais profundos.

## 5. Sugestoes de proximos passos

1. Continuar expandindo a camada `system` Dart ja criada, separando ainda mais `XYHandle`, `XYPanZoom` e `XYDrag` do `NgFlowComponent`.
2. Separar o port em duas camadas, espelhando a referencia:
   - uma camada `system` Dart para geometria/interacao
   - uma camada de componentes AngularDart/ngdart
3. Priorizar parity funcional na ordem de maior impacto:
  - lifecycle completo de `XYHandle` com eventos/semantica mais proximos da referencia, agora partindo da base ja alinhada com `dragThreshold`
   - pan/zoom robusto e mais proximo de `XYPanZoom`
   - drag com constraints/snap/auto-pan/multi-select e refinamentos do `XYDrag`
   - lookup interno de nodes/handles medidos
   - store interna mais proxima do modelo da referencia
4. Expandir `NgFlowStore` e `NgFlowInstance` com mais helpers equivalentes aos hooks mais usados do ReactFlow.
5. Refatorar o nucleo interativo para reduzir responsabilidade remanescente do `NgFlowComponent` e aproximar a arquitetura de `XYHandle`, `XYDrag` e `XYPanZoom`.
6. Ampliar a suite atual de testes com cenarios de interacao mais profundos agora que a validacao browser esta estabilizada.
7. So depois expandir adicionais como virtualizacao, a11y ainda mais refinado e refinamentos de UX.
8. Polir o `example` e empacotar a biblioteca com documentacao e exemplos focados por recurso.

## Arquivos-chave

- `C:\MyDartProjects\dart_flow\analysis_options.yaml`
- `C:\MyDartProjects\dart_flow\lib\dart_flow.dart`
- `C:\MyDartProjects\dart_flow\lib\src\types\models.dart`
- `C:\MyDartProjects\dart_flow\lib\src\types\changes.dart`
- `C:\MyDartProjects\dart_flow\lib\src\types\renderers.dart`
- `C:\MyDartProjects\dart_flow\lib\src\system\xyhandle.dart`
- `C:\MyDartProjects\dart_flow\lib\src\system\node_internals.dart`
- `C:\MyDartProjects\dart_flow\lib\src\system\xypanzoom.dart`
- `C:\MyDartProjects\dart_flow\lib\src\system\xydrag.dart`
- `C:\MyDartProjects\dart_flow\lib\src\utils\graph.dart`
- `C:\MyDartProjects\dart_flow\lib\src\utils\edge_paths.dart`
- `C:\MyDartProjects\dart_flow\lib\src\state\flow_controller.dart`
- `C:\MyDartProjects\dart_flow\lib\src\state\ng_flow_interaction_controller.dart`
- `C:\MyDartProjects\dart_flow\lib\src\state\ng_flow_instance.dart`
- `C:\MyDartProjects\dart_flow\lib\src\state\ng_flow_store.dart`
- `C:\MyDartProjects\dart_flow\lib\src\components\ng_flow\ng_flow_component.dart`
- `C:\MyDartProjects\dart_flow\lib\src\components\ng_flow_provider\ng_flow_provider_component.dart`
- `C:\MyDartProjects\dart_flow\lib\src\components\minimap\minimap_component.dart`
- `C:\MyDartProjects\dart_flow\lib\src\testing\ng_flow_dynamic_test_host.dart`
- `C:\MyDartProjects\dart_flow\lib\src\testing\ng_flow_keyboard_test_host.dart`
- `C:\MyDartProjects\dart_flow\test\system\xypanzoom_test.dart`
- `C:\MyDartProjects\dart_flow\test\system\xydrag_test.dart`
- `C:\MyDartProjects\dart_flow\test\system\xyhandle_test.dart`
- `C:\MyDartProjects\dart_flow\test\system\node_internals_test.dart`
- `C:\MyDartProjects\dart_flow\test\state\flow_controller_test.dart`
- `C:\MyDartProjects\dart_flow\test\state\ng_flow_interaction_controller_test.dart`
- `C:\MyDartProjects\dart_flow\test\state\ng_flow_store_test.dart`
- `C:\MyDartProjects\dart_flow\test\utils\graph_test.dart`
- `C:\MyDartProjects\dart_flow\test\utils\edge_paths_test.dart`
- `C:\MyDartProjects\dart_flow\test\ng\ng_flow_component_ng_test.dart`
- `C:\MyDartProjects\dart_flow\test\browser\ng_flow_browser_test.dart`
- `C:\MyDartProjects\dart_flow\example\lib\src\app_component.dart`
- `C:\MyDartProjects\dart_flow\example\web\main.dart`
- `C:\MyDartProjects\dart_flow\referencias\xyflow-main\packages\system\src\utils\graph.ts`
- `C:\MyDartProjects\dart_flow\referencias\xyflow-main\packages\system\src\xyhandle\XYHandle.ts`
- `C:\MyDartProjects\dart_flow\referencias\xyflow-main\packages\system\src\xypanzoom\XYPanZoom.ts`
- `C:\MyDartProjects\dart_flow\referencias\xyflow-main\packages\system\src\xydrag\XYDrag.ts`
- `C:\MyDartProjects\dart_flow\referencias\xyflow-main\packages\react\src\container\ReactFlow\index.tsx`
- `C:\MyDartProjects\dart_flow\referencias\xyflow-main\packages\react\src\additional-components\MiniMap\MiniMap.tsx`
