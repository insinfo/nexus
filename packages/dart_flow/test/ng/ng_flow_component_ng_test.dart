@TestOn('browser')
library;

import 'package:dart_flow/src/testing/ng_flow_dynamic_test_host.dart';
import 'package:ngdart/angular.dart' show ComponentFactory;
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

// ignore: uri_has_not_been_generated
import 'package:dart_flow/src/testing/ng_flow_dynamic_test_host.template.dart'
    as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<NgFlowDynamicHostComponent>(
    ng.NgFlowDynamicHostComponentNgFactory,
  );

  test('renders dynamic node and dynamic edge components', () async {
    final fixture = await testBed.create(
      beforeChangeDetection: (host) {
        host.nodeFactories = <String, ComponentFactory<Object>>{
          'dynamic-node':
              ng.TestDynamicNodeComponentNgFactory as ComponentFactory<Object>,
        };
        host.edgeFactories = <String, ComponentFactory<Object>>{
          'dynamic-edge':
              ng.TestDynamicEdgeComponentNgFactory as ComponentFactory<Object>,
        };
      },
    );
    final root = fixture.rootElement;

    expect(root.querySelector('.test-dynamic-node')?.text, contains('Alpha'));
    expect(root.querySelector('.test-dynamic-edge')?.text, contains('relates'));
  });

  test('ng flow provider tree exposes the component instance', () async {
    final fixture = await testBed.create(
      beforeChangeDetection: (host) {
        host.nodeFactories = <String, ComponentFactory<Object>>{
          'dynamic-node':
              ng.TestDynamicNodeComponentNgFactory as ComponentFactory<Object>,
        };
        host.edgeFactories = <String, ComponentFactory<Object>>{
          'dynamic-edge':
              ng.TestDynamicEdgeComponentNgFactory as ComponentFactory<Object>,
        };
      },
    );
    final host = fixture.assertOnlyInstance;

    expect(host.flow, isNotNull);
    expect(host.flow!.visibleNodes.length, 2);
    expect(host.flow!.visibleEdges.length, 1);
  });
}
