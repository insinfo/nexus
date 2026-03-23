# dart_flow

`dart_flow` is an AngularDart/ngdart flow editor and graph visualization library inspired by `xyflow-main` / React Flow and adapted to the Dart ecosystem.

This repository currently provides a reusable `NgFlowComponent`, supporting UI components, graph utilities, viewport helpers, interaction controllers, and state primitives that allow you to build node-based editors in Dart.

The project is being developed as a reference-driven port, with behavior and architecture progressively aligned with the original `xyflow-main` source where it makes sense in Dart.

## Status

The package is already usable for interactive graph editing scenarios and includes:

- node and edge rendering
- drag and multi-drag support
- pan and zoom
- selection rectangle
- connect and reconnect gestures
- multiple handles per node
- custom node and edge component factories
- minimap, controls, background, and panel components
- graph and edge-path utilities
- store and instance APIs for programmatic control
- unit, browser, and Angular test coverage

This is not yet a full one-to-one React Flow parity layer. Some advanced behaviors and internal APIs from `xyflow-main` are still being ported incrementally.

## Why this package exists

The goal of `dart_flow` is to bring the most valuable parts of the `xyflow-main` architecture into a Dart-first environment:

- strongly typed graph models
- reusable system helpers for interaction and geometry
- a component-oriented rendering layer for AngularDart/ngdart
- a store/instance API for imperative and reactive integrations
- a path toward deeper behavioral parity with the original reference implementation

## Features

Current capabilities include:

- `FlowNode`, `FlowEdge`, `FlowHandle`, `Viewport`, `Rect`, and related core models
- graph helpers such as `addEdge`, `reconnectEdge`, `getIncomers`, `getOutgoers`, `getConnectedEdges`, `getNodesBounds`, and `getViewportForBounds`
- edge path helpers such as bezier, straight, smooth step, and simple bezier path builders
- pointer interaction logic extracted into system/state layers instead of living entirely in the UI component
- drag-to-connect and click-to-connect flows
- reconnect flows with final connection state reporting
- gesture lifecycle outputs for `connectStart`, `connectEnd`, `reconnectStart`, and `reconnectEnd`
- viewport helpers for pan, zoom, constraints, and coordinate conversions
- dynamic AngularDart component rendering for custom node and edge types
- reactive snapshots and lookups through `NgFlowStore`
- imperative graph and viewport control through `NgFlowInstance`

## Package layout

The root public entrypoint is:

```dart
import 'package:dart_flow/dart_flow.dart';
```

Public exports include:

- `NgFlowComponent`
- `NgFlowProviderComponent`
- `BackgroundComponent`
- `ControlsComponent`
- `MiniMapComponent`
- `PanelComponent`
- `FlowController`
- `NgFlowInteractionController`
- `NgFlowInstance`
- `NgFlowStore`
- system helpers such as `xyhandle`, `xydrag`, `xypanzoom`, and `node_internals`
- types from `models.dart`, `changes.dart`, and `renderers.dart`
- utility functions from `graph.dart`, `edge_paths.dart`, and `changes.dart`

At a high level the repository is organized into these layers:

- `lib/src/components`: AngularDart UI components
- `lib/src/state`: controllers, store, and instance facade
- `lib/src/system`: low-level interaction and geometry helpers
- `lib/src/types`: shared models and renderer contracts
- `lib/src/utils`: graph manipulation and path generation utilities

## Installation

`dart_flow` is currently configured with `publish_to: none`, so it is intended for local or workspace usage.

Add it as a path dependency in another Dart project:

```yaml
dependencies:
  dart_flow:
    path: ../dart_flow
```

Then install dependencies:

```bash
dart pub get
```

## Requirements

- Dart SDK `^3.2.1`
- AngularDart/ngdart environment
- `build_runner` for generated Angular code and browser test workflows

The package currently depends on:

- `ngdart`
- `ngforms`
- `ngrouter`
- `collection`
- `intl`

## Quick start

Below is the minimum shape needed to render a flow in an AngularDart component.

### Component class

```dart
import 'package:dart_flow/dart_flow.dart';
import 'package:ngdart/angular.dart';

@Component(
  selector: 'app-root',
  templateUrl: 'app_component.html',
  directives: [
    coreDirectives,
    NgFlowComponent,
    BackgroundComponent,
    ControlsComponent,
    MiniMapComponent,
    PanelComponent,
  ],
)
class AppComponent {
  List<FlowNode> nodes = const <FlowNode>[
    FlowNode(
      id: 'a',
      position: XYPosition(x: 40, y: 120),
      data: <String, Object?>{'label': 'Source'},
      handles: <FlowHandle>[
        FlowHandle(
          id: 'out',
          type: HandleType.source,
          position: Position.right,
          x: 180,
          y: 28,
        ),
      ],
    ),
    FlowNode(
      id: 'b',
      position: XYPosition(x: 320, y: 120),
      data: <String, Object?>{'label': 'Target'},
      handles: <FlowHandle>[
        FlowHandle(
          id: 'in',
          type: HandleType.target,
          position: Position.left,
          x: 0,
          y: 28,
        ),
      ],
    ),
  ];

  List<FlowEdge> edges = const <FlowEdge>[];

  void onConnect(FlowConnection connection) {
    edges = addEdge(connection, edges);
  }
}
```

### Template

```html
<ng-flow
  [nodes]="nodes"
  [edges]="edges"
  [fitView]="true"
  [connectOnDrag]="true"
  [connectOnClick]="true"
  [autoAddConnectedEdge]="false"
  (connect)="onConnect($event)">
  <rf-background variant="dots"></rf-background>
  <rf-controls></rf-controls>
  <rf-minimap></rf-minimap>
</ng-flow>
```

## Core data model

### `FlowNode`

Represents a node rendered in the canvas.

Important fields:

- `id`: unique node identifier
- `position`: top-left position in flow coordinates
- `data`: arbitrary metadata used by renderers
- `type`: custom node type key
- `selected`, `dragging`, `hidden`
- `draggable`, `selectable`, `connectable`, `deletable`
- `width`, `height`
- `sourcePosition`, `targetPosition`
- `parentId`
- `handles`: explicit list of `FlowHandle`

### `FlowHandle`

Represents a source or target connection point on a node.

Important fields:

- `id`: optional but recommended when a node exposes multiple handles of the same type
- `type`: `HandleType.source` or `HandleType.target`
- `position`: logical side of the node
- `x`, `y`, `width`, `height`: layout metrics used by rendering and path calculations

### `FlowEdge`

Represents an edge between two nodes.

Important fields:

- `id`
- `source`, `target`
- `sourceHandle`, `targetHandle`
- `type`: built-in line type
- `customType`: key for custom edge rendering
- `animated`, `hidden`, `selected`
- `markerStart`, `markerEnd`
- `interactionWidth`
- `label`

### `FlowConnection`

Represents a connection payload emitted by connect and reconnect events.

Fields:

- `source`
- `target`
- `sourceHandle`
- `targetHandle`

### `Viewport`

Represents the current transform of the canvas.

Fields:

- `x`
- `y`
- `zoom`

## `NgFlowComponent`

`NgFlowComponent` is the main interactive canvas. It receives nodes and edges, handles interaction, and emits change and gesture events.

### Main inputs

Behavior and interaction:

- `fitView`
- `nodesDraggable`
- `selectionOnDrag`
- `keyboardA11y`
- `rovingFocus`
- `connectOnClick`
- `connectOnDrag`
- `connectionDragThreshold`
- `autoAddConnectedEdge`

Viewport and movement:

- `minZoom`
- `maxZoom`
- `snapToGrid`
- `snapGridX`
- `snapGridY`
- `autoPanOnNodeDrag`
- `autoPanPadding`
- `autoPanSpeed`
- `nodeExtent`

Keyboard configuration:

- `deleteKey`
- `panActivationKey`
- `selectAllKey`

Rendering hooks:

- `nodeTitleBuilder`
- `nodeSubtitleBuilder`
- `nodeHtmlBuilder`
- `nodeTypeTitleBuilders`
- `nodeTypeSubtitleBuilders`
- `nodeTypeHtmlBuilders`
- `nodeComponentFactories`
- `edgeLabelBuilder`
- `edgeTypeLabelBuilders`
- `edgeTypePathBuilders`
- `edgeComponentFactories`

Graph state:

- `nodes`
- `edges`

### Outputs

Change streams:

- `nodesChange`: emits `List<FlowNodeChange>`
- `edgesChange`: emits `List<FlowEdgeChange>`
- `viewportChange`: emits `Viewport`
- `selectionChange`: emits `Set<String>`

Click streams:

- `nodeClick`: emits `FlowNode`
- `edgeClick`: emits `FlowEdge`

Connection streams:

- `connect`: emits `FlowConnection`
- `reconnect`: emits `FlowConnection`

Gesture lifecycle streams:

- `connectStart`: emits `FlowConnectionStartEvent`
- `connectEnd`: emits `XYFinalConnectionState`
- `reconnectStart`: emits `FlowReconnectStartEvent`
- `reconnectEnd`: emits `FlowReconnectEndEvent`

### Lifecycle event semantics

The component distinguishes between pending and active gestures.

- drag gestures do not become active immediately
- the actual connection lifecycle begins only after the pointer crosses `connectionDragThreshold`
- `connectStart` and `reconnectStart` are emitted when the gesture becomes active, not merely on mouse down
- `connectEnd` and `reconnectEnd` are emitted when the gesture finishes, including cancellation scenarios

This behavior is intentionally closer to the original `XYHandle.ts` semantics from `xyflow-main`.

## Built-in supporting components

### `BackgroundComponent`

Renders a background for the canvas. Useful for grid or dotted backgrounds.

### `ControlsComponent`

Provides basic viewport controls.

### `MiniMapComponent`

Displays a small overview of the graph and already supports basic interactive navigation.

### `PanelComponent`

Allows overlaying custom content on the flow canvas at common positions.

### `NgFlowProviderComponent`

Provides a dedicated wrapper/provider abstraction aligned with the internal state model.

## Custom nodes and custom edges

The package supports dynamic rendering through Angular component factories.

Types are declared in `renderers.dart`:

- `FlowNodeComponentFactoryMap`
- `FlowEdgeComponentFactoryMap`
- `FlowDynamicNodeComponent`
- `FlowDynamicEdgeComponent`
- `FlowNodeRenderContext`
- `FlowEdgeRenderContext`

### Custom node example

```dart
late final FlowNodeComponentFactoryMap nodeComponentFactories =
    <String, ComponentFactory<Object>>{
  'approval': DemoApprovalNodeComponentNgFactory,
};
```

Assign the node type in your graph:

```dart
FlowNode(
  id: 'approval-1',
  type: 'approval',
  position: XYPosition(x: 320, y: 120),
)
```

### Custom edge example

```dart
late final FlowEdgeComponentFactoryMap edgeComponentFactories =
    <String, ComponentFactory<Object>>{
  'highlight': DemoHighlightEdgeComponentNgFactory,
};
```

You can also override the path builder independently from the component:

```dart
late final Map<String, EdgePathRenderer> edgeTypePathBuilders =
    <String, EdgePathRenderer>{
  'highlight': (FlowEdge edge, EdgePosition position) => getBezierPath(
        sourceX: position.sourceX,
        sourceY: position.sourceY,
        sourcePosition: position.sourcePosition,
        targetX: position.targetX,
        targetY: position.targetY,
        targetPosition: position.targetPosition,
        curvature: 0.42,
      ),
};
```

## State and imperative APIs

### `FlowController`

The lower-level mutable controller that owns the graph and viewport state used by the component.

Typical responsibilities:

- set and update nodes
- set and update edges
- selection handling
- viewport transforms
- fit view, zoom, and pan
- reconnecting edges

### `NgFlowInstance`

The higher-level imperative API intended to feel closer to the helper/hook ergonomics of the original React Flow ecosystem.

Capabilities include:

- access to current nodes, edges, selected items, and viewport
- coordinate conversion between screen and flow space
- viewport control through `zoomIn`, `zoomOut`, `zoomTo`, `scaleBy`, `panBy`, `fitView`, `syncViewport`, and `setTranslateExtent`
- graph updates through `setNodes`, `setEdges`, `updateNodePosition`, `updateNodeDimensions`, `addConnection`, `reconnect`, and `reconnectById`
- selection management through `selectNode`, `selectEdge`, `selectNodesByIds`, `clearSelection`, and `deleteSelected`
- lookup helpers such as `getNode`, `getEdge`, `getHandle`, `getNodeInternals`, and `getHandleMetrics`

### `NgFlowStore`

Reactive snapshot and lookup layer for consumers that need derived graph state.

Provided data includes:

- `snapshot`
- `nodeLookup`
- `edgeLookup`
- `nodeInternalsLookup`
- `handleMetricsLookup`
- `handleLookup`
- `visibleNodes`
- `visibleEdges`
- `nodesInsideViewport`
- `selectedNodes`
- `selectedEdges`
- `nodesBounds`
- `visibleBounds`
- `viewportRect`

The store also exposes broadcast streams for these derived values.

## System modules

The `system` layer is where parity work with `xyflow-main` is concentrated.

### `xyhandle.dart`

Handles connection and reconnect lifecycle semantics.

Current direction:

- explicit `XYHandleState`
- final connection state reporting
- custom connection validation
- threshold-gated activation for drag gestures
- closer alignment with the original `XYHandle.ts`

### `xydrag.dart`

Encapsulates node dragging, multi-drag, snapping, extents, auto-pan, and selection helpers.

### `xypanzoom.dart`

Provides viewport transforms, pan/zoom helpers, constraint logic, and coordinate conversion utilities.

### `node_internals.dart`

Builds measured internals and handle lookup information used by derived state and rendering calculations.

## Utility functions

### Graph utilities

Available helpers include:

- `addEdge`
- `reconnectEdge`
- `getIncomers`
- `getOutgoers`
- `getConnectedEdges`
- `getNodesBounds`
- `getViewportForBounds`

### Edge path utilities

Available helpers include:

- `getBezierPath`
- `getStraightPath`
- `getSmoothStepPath`
- `getSimpleBezierPath`

These utilities are useful independently from the UI component when you want to preprocess graph data or render custom edge presentations.

## Example application

The repository includes a runnable example under `example/`.

The example demonstrates:

- multiple source and target handles
- custom node components
- custom edge components
- custom edge path builders
- connect and reconnect flows
- panels, controls, background, and minimap
- event logging

Important example files:

- `example/lib/src/app_component.dart`
- `example/lib/src/app_component.html`
- `example/web/main.dart`

## Development workflow

Install dependencies:

```bash
dart pub get
```

Run analysis:

```bash
dart analyze
```

Run unit tests:

```bash
dart test
```

Run browser and Angular-generated tests:

```bash
dart run build_runner test --delete-conflicting-outputs -- -p chrome test/browser/ng_flow_browser_test.dart
```

Build generated files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Testing

The repository already contains coverage across multiple levels:

- utility tests for graph and edge path helpers
- system tests for handle, pan/zoom, drag, and node internals logic
- state tests for the controller, store, and interaction controller
- browser tests for keyboard accessibility and interaction lifecycle behavior
- Angular/ng tests for component integration

Recent interaction coverage includes:

- cancellation of connection and reconnect gestures
- `dragThreshold` activation semantics
- lifecycle outputs for connect and reconnect gestures

## Keyboard and accessibility notes

The component already includes keyboard-oriented behaviors such as:

- roving focus support
- selection via keyboard
- viewport actions such as fit view
- delete handling
- resize helpers for the selected node

The package is usable today, but accessibility parity with the original React Flow ecosystem is still incomplete.

## Current limitations

This project is intentionally honest about its current stage.

Still incomplete or evolving:

- full React Flow hook parity
- deeper store granularity compared to the original internal model
- complete `XYHandle` event and validation semantics
- deeper `XYPanZoom` parity
- deeper `XYDrag` parity
- virtualization and visible-element rendering optimizations
- fully mature accessibility behavior at the same level as the original reference

If you are migrating examples from React Flow, expect partial API similarity but not complete behavioral compatibility yet.

## Architecture direction

The long-term direction is to keep the codebase split across two major concerns:

- a reusable Dart system layer for geometry and interaction semantics
- an AngularDart rendering layer for components and templates

This direction keeps the port testable and makes behavior easier to compare with `xyflow-main` during ongoing parity work.

## Reference-driven porting policy

Behavioral changes in this repository are intentionally guided by the original source under `referencias/xyflow-main` rather than by ad hoc approximations.

That matters most in:

- connection lifecycle semantics
- pan/zoom behavior
- drag behavior
- state derivation and internal lookups

## Version

Current package version:

- `1.0.0`

## License

See `LICENSE`.