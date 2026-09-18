// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:cupertino_ui/cupertino_ui.dart' as cupertino_ui;
import 'package:flutter/cupertino.dart' as flutter_cupertino;
import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' as material_ui;

void main() {
  testWidgets('GoRoute.builder uses SDK Material configuration for SDK MaterialApp', (
    WidgetTester tester,
  ) async {
    final result = await _pumpApp(
      tester,
      (GoRouter router) => flutter_material.MaterialApp.router(routerConfig: router),
    );

    expect(result.settings, isA<flutter_material.MaterialPage<void>>());
    final controller = result.heroController!;
    final tween = controller.createRectTween!(
      const Rect.fromLTRB(0.0, 0.0, 10.0, 10.0),
      const Rect.fromLTRB(10.0, 10.0, 20.0, 20.0),
    );
    expect(tween, isA<flutter_material.MaterialRectArcTween>());
  });

  testWidgets('GoRoute.builder keeps material_ui configuration for material_ui MaterialApp', (
    WidgetTester tester,
  ) async {
    final result = await _pumpApp(
      tester,
      (GoRouter router) => material_ui.MaterialApp.router(routerConfig: router),
    );

    expect(result.settings, isA<material_ui.MaterialPage<void>>());
    final controller = result.heroController!;
    final tween = controller.createRectTween!(
      const Rect.fromLTRB(0.0, 0.0, 10.0, 10.0),
      const Rect.fromLTRB(10.0, 10.0, 20.0, 20.0),
    );
    expect(tween, isA<material_ui.MaterialRectArcTween>());
  });

  testWidgets('GoRoute.builder uses SDK CupertinoPage for SDK CupertinoApp', (
    WidgetTester tester,
  ) async {
    final result = await _pumpApp(
      tester,
      (GoRouter router) => flutter_cupertino.CupertinoApp.router(routerConfig: router),
    );

    expect(result.settings, isA<flutter_cupertino.CupertinoPage<void>>());
  });

  testWidgets('GoRoute.builder keeps cupertino_ui CupertinoPage for cupertino_ui CupertinoApp', (
    WidgetTester tester,
  ) async {
    final result = await _pumpApp(
      tester,
      (GoRouter router) => cupertino_ui.CupertinoApp.router(routerConfig: router),
    );

    expect(result.settings, isA<cupertino_ui.CupertinoPage<void>>());
  });

  testWidgets('GoRoute.builder uses the closest supported app when Cupertino is nested in Material', (
    WidgetTester tester,
  ) async {
    final result = await _pumpApp(
      tester,
      (GoRouter router) => flutter_material.MaterialApp(
        home: flutter_cupertino.CupertinoApp.router(routerConfig: router),
      ),
    );

    expect(result.settings, isA<flutter_cupertino.CupertinoPage<void>>());
  });

  testWidgets('GoRoute.builder uses the closest supported app when Material is nested in Cupertino', (
    WidgetTester tester,
  ) async {
    final result = await _pumpApp(
      tester,
      (GoRouter router) => flutter_cupertino.CupertinoApp(
        home: flutter_material.MaterialApp.router(routerConfig: router),
      ),
    );

    expect(result.settings, isA<flutter_material.MaterialPage<void>>());
  });

  testWidgets('SDK MaterialApp uses the SDK Material error screen', (WidgetTester tester) async {
    final router = _errorRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(flutter_material.MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.byType(flutter_material.Scaffold), findsOneWidget);
    expect(find.byType(material_ui.Scaffold), findsNothing);
  });

  testWidgets('material_ui MaterialApp keeps the material_ui error screen', (
    WidgetTester tester,
  ) async {
    final router = _errorRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(material_ui.MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.byType(material_ui.Scaffold), findsOneWidget);
    expect(find.byType(flutter_material.Scaffold), findsNothing);
  });

  testWidgets('SDK CupertinoApp uses the SDK Cupertino error screen', (WidgetTester tester) async {
    final router = _errorRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(flutter_cupertino.CupertinoApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.byType(flutter_cupertino.CupertinoPageScaffold), findsOneWidget);
    expect(find.byType(cupertino_ui.CupertinoPageScaffold), findsNothing);
  });

  testWidgets('cupertino_ui CupertinoApp keeps the cupertino_ui error screen', (
    WidgetTester tester,
  ) async {
    final router = _errorRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(cupertino_ui.CupertinoApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.byType(cupertino_ui.CupertinoPageScaffold), findsOneWidget);
    expect(find.byType(flutter_cupertino.CupertinoPageScaffold), findsNothing);
  });
}

typedef _AppBuilder = Widget Function(GoRouter router);

Future<({RouteSettings? settings, HeroController? heroController})> _pumpApp(
  WidgetTester tester,
  _AppBuilder appBuilder,
) async {
  RouteSettings? settings;
  HeroController? heroController;
  final router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => Builder(
          builder: (BuildContext context) {
            settings = ModalRoute.of(context)?.settings;
            heroController = HeroControllerScope.maybeOf(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(appBuilder(router));
  await tester.pumpAndSettle();

  return (settings: settings, heroController: heroController);
}

GoRouter _errorRouter() => GoRouter(
  initialLocation: '/missing',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
    ),
  ],
);
