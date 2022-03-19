// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'go_router_test.dart';

void testPageNotFound(String testName, {required Widget widget}) {
  testWidgets(testName, (WidgetTester tester) async {
    await tester.pumpWidget(widget);
    expect(find.text('page not found'), findsOneWidget);
  });
}

void testPageShowsExceptionMessage(
  String testName, {
  required Exception exception,
  required Widget widget,
}) {
  testWidgets(testName, (WidgetTester tester) async {
    await tester.pumpWidget(widget);
    expect(find.text('$exception'), findsOneWidget);
  });
}

void testClickingTheButtonRedirectsToRoot(
  String testName, {
  required Finder buttonFinder,
  required Widget widget,
  Widget Function(GoRouter router) appRouterBuilder = materialAppRouterBuilder,
}) {
  testWidgets(testName, (WidgetTester tester) async {
    final GoRouter router = GoRouter(
      initialLocation: '/error',
      routes: <GoRoute>[
        GoRoute(path: '/', builder: (_, __) => const DummyStatefulWidget()),
        GoRoute(
          path: '/error',
          builder: (_, __) => widget,
        ),
      ],
    );
    await tester.pumpWidget(appRouterBuilder(router));
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
    expect(find.byType(DummyStatefulWidget), findsOneWidget);
  });
}

Widget materialAppRouterBuilder(GoRouter router) {
  return MaterialApp.router(
    routeInformationParser: router.routeInformationParser,
    routerDelegate: router.routerDelegate,
    title: 'GoRouter Example',
  );
}

Widget cupertinoAppRouterBuilder(GoRouter router) {
  return CupertinoApp.router(
    routeInformationParser: router.routeInformationParser,
    routerDelegate: router.routerDelegate,
    title: 'GoRouter Example',
  );
}
