@TestOn('browser')
library;

import 'dart:html';
import 'dart:js_util' as js_util;

import 'package:dart_flow/src/testing/ng_flow_keyboard_test_host.dart';
import 'package:dart_flow/src/types/models.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

// ignore: uri_has_not_been_generated
import 'package:dart_flow/src/testing/ng_flow_keyboard_test_host.template.dart'
    as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<NgFlowKeyboardHostComponent>(
    ng.NgFlowKeyboardHostComponentNgFactory,
  );

  test('ctrl+a selects visible nodes through keyboard a11y', () async {
    final fixture = await testBed.create();
    final root = fixture.rootElement;
    final shell = root.querySelector('.rf-shell')! as HtmlElement;
    final event = createKeyboardEvent(
      'keydown',
      key: 'a',
      ctrlKey: true,
    );

    shell.focus();
    shell.dispatchEvent(event);

    await fixture.update();
    await Future<void>.delayed(Duration.zero);

    final selected = root.querySelectorAll('.rf-node.is-selected');
    expect(selected, hasLength(2));
  });

  test('page up zooms the canvas', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;
    final root = fixture.rootElement;
    final shell = root.querySelector('.rf-shell')! as HtmlElement;
    final event = createKeyboardEvent(
      'keydown',
      key: 'PageUp',
    );

    final before = host.flow!.viewportTransform;

    shell.focus();
    shell.dispatchEvent(event);

    await fixture.update();
    await Future<void>.delayed(Duration.zero);

    expect(host.flow!.viewportTransform, isNot(before));
  });

  test('cancelling a dragged connection does not emit connect or add edges',
      () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;
    final flow = host.flow!;
    final node = flow.visibleNodes.first;
    final sourceHandle = flow.sourceHandlesForNode(node).first;

    flow.onSourceHandleMouseDown(
      createMouseEvent('mousedown', clientX: 180, clientY: 28, button: 0),
      node,
      sourceHandle,
    );
    document.dispatchEvent(
      createMouseEvent('mousemove', clientX: 520, clientY: 320, button: 0),
    );
    document.dispatchEvent(
      createMouseEvent('mouseup', clientX: 520, clientY: 320, button: 0),
    );

    await fixture.update();
    await Future<void>.delayed(Duration.zero);

    expect(host.connectStartEvents, hasLength(1));
    expect(host.connectStartEvents.single.nodeId, 'a');
    expect(host.connectStartEvents.single.handleType, HandleType.source);
    expect(host.connectEndEvents, hasLength(1));
    expect(host.connectEndEvents.single.connection, isNull);
    expect(host.connectEvents, isEmpty);
    expect(flow.visibleEdges, hasLength(1));
    expect(flow.hasConnectionPreview, isFalse);
    expect(flow.lastConnectionEndState, isNotNull);
    expect(flow.lastConnectionEndState?.connection, isNull);
  });

  test('cancelling a reconnect does not emit reconnect or mutate edge',
      () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;
    final flow = host.flow!;
    final edge = flow.visibleEdges.single;

    flow.onEdgeClick(
      edge,
      createMouseEvent('click', clientX: 120, clientY: 40, button: 0),
    );

    await fixture.update();
    await Future<void>.delayed(Duration.zero);

    flow.onReconnectAnchorMouseDown(
      createMouseEvent('mousedown', clientX: 180, clientY: 28, button: 0),
      edge,
      true,
    );
    document.dispatchEvent(
      createMouseEvent('mousemove', clientX: 640, clientY: 420, button: 0),
    );
    document.dispatchEvent(
      createMouseEvent('mouseup', clientX: 640, clientY: 420, button: 0),
    );

    await fixture.update();
    await Future<void>.delayed(Duration.zero);

    expect(host.connectStartEvents, hasLength(1));
    expect(host.connectStartEvents.single.nodeId, 'b');
    expect(host.connectStartEvents.single.handleType, HandleType.target);
    expect(host.connectEndEvents, hasLength(1));
    expect(host.connectEndEvents.single.connection, isNull);
    expect(host.reconnectStartEvents, hasLength(1));
    expect(host.reconnectStartEvents.single.edge.id, 'e1');
    expect(host.reconnectStartEvents.single.handleType, HandleType.target);
    expect(host.reconnectEndEvents, hasLength(1));
    expect(host.reconnectEndEvents.single.edge.id, 'e1');
    expect(host.reconnectEndEvents.single.connectionState.connection, isNull);
    expect(host.reconnectEvents, isEmpty);
    expect(flow.visibleEdges.single.source, 'a');
    expect(flow.visibleEdges.single.target, 'b');
    expect(flow.hasReconnectPreview, isFalse);
    expect(flow.lastReconnectEndState, isNotNull);
    expect(flow.lastReconnectEndState?.connection, isNull);
  });

  test('connect start only fires after drag threshold is exceeded', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;
    final flow = host.flow!;
    final node = flow.visibleNodes.first;
    final sourceHandle = flow.sourceHandlesForNode(node).first;

    flow.connectionDragThreshold = 20;
    flow.onSourceHandleMouseDown(
      createMouseEvent('mousedown', clientX: 180, clientY: 28, button: 0),
      node,
      sourceHandle,
    );

    await fixture.update();
    await Future<void>.delayed(Duration.zero);

    expect(host.connectStartEvents, isEmpty);

    document.dispatchEvent(
      createMouseEvent('mousemove', clientX: 230, clientY: 70, button: 0),
    );

    await fixture.update();
    await Future<void>.delayed(Duration.zero);

    expect(host.connectStartEvents, hasLength(1));
    expect(host.connectStartEvents.single.nodeId, 'a');
    expect(host.connectEndEvents, isEmpty);
  });
}

KeyboardEvent createKeyboardEvent(
  String type, {
  required String key,
  bool ctrlKey = false,
}) {
  final jsKeyboardEvent = js_util.callConstructor(
    js_util.getProperty(window, 'KeyboardEvent'),
    <Object?>[
      type,
      js_util.jsify(<String, Object?>{
        'key': key,
        'ctrlKey': ctrlKey,
        'bubbles': true,
      }),
    ],
  );
  return jsKeyboardEvent as KeyboardEvent;
}

MouseEvent createMouseEvent(
  String type, {
  required num clientX,
  required num clientY,
  int button = 0,
}) {
  final jsMouseEvent = js_util.callConstructor(
    js_util.getProperty(window, 'MouseEvent'),
    <Object?>[
      type,
      js_util.jsify(<String, Object?>{
        'clientX': clientX,
        'clientY': clientY,
        'button': button,
        'buttons': 1,
        'bubbles': true,
      }),
    ],
  );
  return jsMouseEvent as MouseEvent;
}
