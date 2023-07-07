// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('updateShouldNotify', () {
    test('does not update when goRouter does not change', () {
      final GoRouter goRouter = GoRouter(
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            builder: (_, __) => const Page1(),
          ),
        ],
      );
      final bool shouldNotify = setupInheritedGoRouterChange(
        oldGoRouter: goRouter,
        newGoRouter: goRouter,
      );
      expect(shouldNotify, false);
    });

    test('does not update even when goRouter changes', () {
      final GoRouter oldGoRouter = GoRouter(
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            builder: (_, __) => const Page1(),
          ),
        ],
      );
      final GoRouter newGoRouter = GoRouter(
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            builder: (_, __) => const Page2(),
          ),
        ],
      );
      final bool shouldNotify = setupInheritedGoRouterChange(
        oldGoRouter: oldGoRouter,
        newGoRouter: newGoRouter,
      );
      expect(shouldNotify, false);
    });
  });

  test('adds [goRouter] as a diagnostics property', () {
    final GoRouter goRouter = GoRouter(
      routes: <GoRoute>[
        GoRoute(
          path: '/',
          builder: (_, __) => const Page1(),
        ),
      ],
    );
    final InheritedGoRouter inheritedGoRouter = InheritedGoRouter(
      goRouter: goRouter,
      child: Container(),
    );
    final DiagnosticPropertiesBuilder properties =
        DiagnosticPropertiesBuilder();
    inheritedGoRouter.debugFillProperties(properties);
    expect(properties.properties.length, 1);
    expect(properties.properties.first, isA<DiagnosticsProperty<GoRouter>>());
    expect(properties.properties.first.value, goRouter);
  });

  testWidgets("mediates Widget's access to GoRouter.",
      (WidgetTester tester) async {
    final MockGoRouter router = MockGoRouter();
    await tester.pumpWidget(MaterialApp(
        home: InheritedGoRouter(goRouter: router, child: const _MyWidget())));
    await tester.tap(find.text('My Page'));
    expect(router.latestPushedName, 'my_page');
  });
}

bool setupInheritedGoRouterChange({
  required GoRouter oldGoRouter,
  required GoRouter newGoRouter,
}) {
  final InheritedGoRouter oldInheritedGoRouter = InheritedGoRouter(
    goRouter: oldGoRouter,
    child: Container(),
  );
  final InheritedGoRouter newInheritedGoRouter = InheritedGoRouter(
    goRouter: newGoRouter,
    child: Container(),
  );
  return newInheritedGoRouter.updateShouldNotify(
    oldInheritedGoRouter,
  );
}

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) => Container();
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) => Container();
}

class _MyWidget extends StatelessWidget {
  const _MyWidget();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () => context.pushNamed('my_page'),
        child: const Text('My Page'));
  }
}

class MockGoRouter extends GoRouter {
  MockGoRouter() : super(routes: <GoRoute>[]);

  late String latestPushedName;

  @override
  Future<T?> pushNamed<T extends Object?>(String name,
      {Map<String, String> pathParameters = const <String, String>{},
      Map<String, dynamic> queryParameters = const <String, dynamic>{},
      Object? extra}) {
    latestPushedName = name;
    return Future<T?>.value();
  }

  @override
  BackButtonDispatcher get backButtonDispatcher => RootBackButtonDispatcher();
}
