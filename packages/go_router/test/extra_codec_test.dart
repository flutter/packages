// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('router rebuild with extra codec works', (
    WidgetTester tester,
  ) async {
    const initialString = 'some string';
    const empty = 'empty';
    final router = GoRouter(
      initialLocation: '/',
      extraCodec: ComplexDataCodec(),
      initialExtra: ComplexData(initialString),
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, GoRouterState state) {
            return Text((state.extra as ComplexData?)?.data ?? empty);
          },
        ),
      ],
      redirect: (BuildContext context, _) {
        // Set up dependency.
        SimpleDependencyProvider.of(context);
        return null;
      },
    );

    addTearDown(router.dispose);
    final dependency = SimpleDependency();
    addTearDown(() => dependency.dispose());

    await tester.pumpWidget(
      SimpleDependencyProvider(
        dependency: dependency,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    expect(find.text(initialString), findsOneWidget);
    dependency.boolProperty = !dependency.boolProperty;

    await tester.pumpAndSettle();
    expect(find.text(initialString), findsOneWidget);
  });

  testWidgets(
    'Restores state correctly',
    (WidgetTester tester) async {
      const initialString = 'some string';
      const empty = 'empty';
      final routes = <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, GoRouterState state) {
            return Text((state.extra as ComplexData?)?.data ?? empty);
          },
        ),
      ];

      await createRouter(
        routes,
        tester,
        initialExtra: ComplexData(initialString),
        restorationScopeId: 'test',
        extraCodec: ComplexDataCodec(),
      );
      expect(find.text(initialString), findsOneWidget);

      await tester.restartAndRestore();

      await tester.pumpAndSettle();
      expect(find.text(initialString), findsOneWidget);
    },
    // TODO(hgraceb): Remove when minimum flutter version includes
    // https://github.com/flutter/flutter/pull/176519
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      classes: const <String>['TestRestorationManager', 'RestorationBucket'],
    ),
  );
}

class ComplexData {
  ComplexData(this.data);
  final String data;
}

class ComplexDataCodec extends Codec<ComplexData?, Object?> {
  @override
  Converter<Object?, ComplexData?> get decoder => ComplexDataDecoder();
  @override
  Converter<ComplexData?, Object?> get encoder => ComplexDataEncoder();
}

class ComplexDataDecoder extends Converter<Object?, ComplexData?> {
  @override
  ComplexData? convert(Object? input) {
    if (input == null) {
      return null;
    }
    return ComplexData(input as String);
  }
}

class ComplexDataEncoder extends Converter<ComplexData?, Object?> {
  @override
  Object? convert(ComplexData? input) {
    if (input == null) {
      return null;
    }
    return input.data;
  }
}
