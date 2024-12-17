// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('router rebuild with extra codec works',
      (WidgetTester tester) async {
    const String initialString = 'some string';
    const String empty = 'empty';
    final GoRouter router = GoRouter(
      initialLocation: '/',
      extraCodec: ComplexDataCodec(),
      initialExtra: ComplexData(initialString),
      routes: <RouteBase>[
        GoRoute(
            path: '/',
            builder: (_, GoRouterState state) {
              return Text((state.extra as ComplexData?)?.data ?? empty);
            }),
      ],
      redirect: (BuildContext context, _) {
        // Set up dependency.
        SimpleDependencyProvider.of(context);
        return null;
      },
    );

    addTearDown(router.dispose);
    final SimpleDependency dependency = SimpleDependency();
    addTearDown(() => dependency.dispose());

    await tester.pumpWidget(
      SimpleDependencyProvider(
        dependency: dependency,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    expect(find.text(initialString), findsOneWidget);
    dependency.boolProperty = !dependency.boolProperty;

    await tester.pumpAndSettle();
    expect(find.text(initialString), findsOneWidget);
  });

  testWidgets('Restores state correctly', (WidgetTester tester) async {
    const String initialString = 'some string';
    const String empty = 'empty';
    final List<RouteBase> routes = <RouteBase>[
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
    addTearDown(tester.binding.restorationManager.dispose);

    await tester.pumpAndSettle();
    expect(find.text(initialString), findsOneWidget);
  });
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
