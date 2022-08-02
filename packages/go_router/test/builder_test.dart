// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/src/builder.dart';
import 'package:go_router/src/configuration.dart';
import 'package:go_router/src/match.dart';
import 'package:go_router/src/matching.dart';

void main() {
  group('RouteBuilder', () {
    testWidgets('Builds StackedRoute', (WidgetTester tester) async {
      final config = RouteConfiguration(
        routes: [
          StackedRoute(
            path: '/',
            builder: (context, state) {
              return _HomeScreen();
            },
          ),
        ],
        redirectLimit: 10,
        topRedirect: (state) {
          return null;
        },
      );

      final matches = RouteMatchList([
        RouteMatch(
          route: config.routes.first,
          subloc: '/',
          fullpath: '/',
          encodedParams: {},
          queryParams: {},
          extra: null,
          error: null,
        ),
      ]);

      await tester.pumpWidget(
        _BuilderTestWidget(
          routeConfiguration: config,
          matches: matches,
        ),
      );

      expect(find.byType(_HomeScreen), findsOneWidget);
    });

    testWidgets('Builds ShellRoute', (WidgetTester tester) async {
      final config = RouteConfiguration(
        routes: [
          ShellRoute(
            path: '/',
            builder: (context, state, child) {
              return _HomeScreen();
            },
          ),
        ],
        redirectLimit: 10,
        topRedirect: (state) {
          return null;
        },
      );

      final matches = RouteMatchList([
        RouteMatch(
          route: config.routes.first,
          subloc: '/',
          fullpath: '/',
          encodedParams: {},
          queryParams: {},
          extra: null,
          error: null,
        ),
      ]);

      await tester.pumpWidget(
        _BuilderTestWidget(
          routeConfiguration: config,
          matches: matches,
        ),
      );

      expect(find.byType(_HomeScreen), findsOneWidget);
    });
  });
}

class _HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Home Screen'),
    );
  }
}

class _BuilderTestWidget extends StatelessWidget {
  final RouteConfiguration routeConfiguration;
  final RouteBuilder builder;
  final RouteMatchList matches;
  final ValueKey<NavigatorState> navigatorKey;

  _BuilderTestWidget({
    required this.routeConfiguration,
    required this.matches,
    Key? key,
  })  : navigatorKey = ValueKey<NavigatorState>(NavigatorState()),
        builder = _routeBuilder(routeConfiguration),
        super(key: key);

  /// Builds a [RouteBuilder] for tests
  static RouteBuilder _routeBuilder(RouteConfiguration configuration) {
    return RouteBuilder(
      configuration: configuration,
      builderWithNav: (
        BuildContext context,
        GoRouterState state,
        Navigator navigator,
      ) {
        return navigator;
      },
      errorPageBuilder: (
        BuildContext context,
        GoRouterState state,
      ) {
        return MaterialPage(
          child: Text('Error: ${state.error}'),
        );
      },
      errorBuilder: (
        BuildContext context,
        GoRouterState state,
      ) {
        return Text('Error: ${state.error}');
      },
      restorationScopeId: null,
      observers: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: builder.tryBuild(
        context,
        matches,
        () {},
        navigatorKey,
        false,
      ),
      // builder: (context, child) => ,
    );
  }
}
