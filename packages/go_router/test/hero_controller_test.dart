// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Regression tests for https://github.com/flutter/flutter/issues/192043.
//
// go_router migrated its material/cupertino helpers to the material_ui /
// cupertino_ui packages. Those packages declare their own MaterialApp /
// CupertinoApp types, distinct from the ones in package:flutter. A standard
// Flutter app is built with package:flutter's MaterialApp, so app-type
// detection based on findAncestorWidgetOfExactType stopped matching and the
// navigators go_router builds (including the nested navigators of a ShellRoute /
// StatefulShellRoute) fell back to a plain HeroController. That broke Hero
// flight animations for routes nested inside a shell when the surrounding app is
// Flutter's MaterialApp.
//
// These tests build a router under a real Flutter MaterialApp and assert that
// go_router installs its Material HeroController for every navigator it creates
// (the root navigator plus the shell's nested navigator), rather than a plain
// one. go_router's Material controller is identified by the material_ui
// MaterialRectArcTween it produces, which is distinct from the arc tween used by
// Flutter's own MaterialApp.

import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:material_ui/material_ui.dart' show MaterialRectArcTween;

// Flutter's own MaterialApp / CupertinoApp (as opposed to the leak-clean
// material_ui / cupertino_ui variants) report framework-owned objects to the
// leak tracker that are outside go_router's control, so leak tracking is
// disabled for these regression tests.
final LeakTesting _ignoreLeaks = LeakTesting.settings.withIgnoredAll();

/// Counts the [HeroControllerScope]s in the tree whose controller is the one
/// created by go_router's [createMaterialHeroController], identified by the
/// [material_ui] [MaterialRectArcTween] it produces.
int _goRouterMaterialControllerCount(WidgetTester tester) {
  var count = 0;
  for (final Element element in find.byType(HeroControllerScope).evaluate()) {
    final HeroController? controller = (element.widget as HeroControllerScope).controller;
    final CreateRectTween? createRectTween = controller?.createRectTween;
    if (createRectTween != null && createRectTween(Rect.zero, Rect.zero) is MaterialRectArcTween) {
      count++;
    }
  }
  return count;
}

void main() {
  testWidgets('ShellRoute navigators get the Material HeroController under a Flutter MaterialApp', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/a',
      routes: <RouteBase>[
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) => child,
          routes: <RouteBase>[
            GoRoute(
              path: '/a',
              builder: (BuildContext context, GoRouterState state) => const SizedBox(),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(flutter_material.MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    // Both the root navigator and the shell's nested navigator must use the
    // Material HeroController. Before the fix, app-type detection failed and
    // these fell back to a plain HeroController, so the count would be 0.
    expect(_goRouterMaterialControllerCount(tester), 2);
  }, experimentalLeakTesting: _ignoreLeaks);

  testWidgets(
    'StatefulShellRoute navigators get the Material HeroController under a Flutter MaterialApp',
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/a',
        routes: <RouteBase>[
          StatefulShellRoute.indexedStack(
            builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) =>
                shell,
            branches: <StatefulShellBranch>[
              StatefulShellBranch(
                routes: <RouteBase>[
                  GoRoute(
                    path: '/a',
                    builder: (BuildContext context, GoRouterState state) => const SizedBox(),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(flutter_material.MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // The root navigator and the branch's nested navigator must both use the
      // Material HeroController. Before the fix, the count would be 0.
      expect(_goRouterMaterialControllerCount(tester), 2);
    },
    experimentalLeakTesting: _ignoreLeaks,
  );
}
