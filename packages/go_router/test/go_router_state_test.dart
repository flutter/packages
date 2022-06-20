// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/go_route_information_parser.dart';

void main() {
  late GoRouteInformationParser delegate;

  setUp(() {
    delegate = GoRouteInformationParser(
      routes: const <GoRoute>[],
      redirectLimit: 100,
      topRedirect: (_) => null,
    );
  });

  test('Must parser when extra is Map<String, dynamic>', () {
    const Map<String, dynamic> extra = <String, Object>{
      'key1': 'value1',
      'key2': 2,
      'test': Test('test'),
    };

    final GoRouterState state = GoRouterState(delegate,
        location: '/tests', subloc: '/subloc', name: 'Test', extra: extra);

    expect(state.parseExtra<String>('key1'), 'value1');
    expect(state.parseExtra<String>('key1'), isA<String>());
    expect(state.parseExtra<int>('key2'), 2);
    expect(state.parseExtra<int>('key2'), isA<int>());
    expect(state.parseExtra<String>('key3'), isNull);
    expect(state.parseExtra<Test>('test'), const Test('test'));
    expect(state.parseExtra<Test>('test'), isA<Test>());
  });

  test('Must parser when extra is a List<dynamic>', () {
    const List<dynamic> extra = <dynamic>[
      'value1',
      2,
      Test('test'),
    ];

    final GoRouterState state = GoRouterState(delegate,
        location: '/tests', subloc: '/subloc', name: 'Test', extra: extra);

    expect(state.parseExtra<String>(), 'value1');
    expect(state.parseExtra<String>(), isA<String>());
    expect(state.parseExtra<int>(), 2);
    expect(state.parseExtra<int>(), isA<int>());
    expect(state.parseExtra<Test>(), const Test('test'));
    expect(state.parseExtra<Test>(), isA<Test>());
  });

  test('Must parser when extra is a T', () {
    const Test extra = Test('test');

    final GoRouterState state = GoRouterState(delegate,
        location: '/tests', subloc: '/subloc', name: 'Test', extra: extra);

    expect(state.parseExtra<Test>(), const Test('test'));
    expect(state.parseExtra<Test>(), isA<Test>());
  });

  test('Must return defaultValue', () {
    final GoRouterState state = GoRouterState(delegate,
        location: '/tests', subloc: '/subloc', name: 'Test', extra: null);

    expect(state.parseExtra<Test>(), isNull);
    expect(state.parseExtra<Test>(null, const Test('test')), isA<Test>());
    expect(
        state.parseExtra<Test>(null, const Test('test')), const Test('test'));
  });
}

class Test {
  const Test(this.name);

  final String name;
}
