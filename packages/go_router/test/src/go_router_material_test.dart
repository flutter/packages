// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/go_router_material.dart';

void main() {
  group('isMaterialApp', () {
    testWidgets('returns [true] when MaterialApp is present',
        (WidgetTester tester) async {
      final GlobalKey<_DummyStatefulWidgetState> key =
          GlobalKey<_DummyStatefulWidgetState>();
      await tester.pumpWidget(
        MaterialApp(
          home: DummyStatefulWidget(key: key),
        ),
      );
      final bool isMaterial = isMaterialApp(key.currentContext! as Element);
      expect(isMaterial, true);
    });

    testWidgets('returns [false] when CupertinoApp is present',
        (WidgetTester tester) async {
      final GlobalKey<_DummyStatefulWidgetState> key =
          GlobalKey<_DummyStatefulWidgetState>();
      await tester.pumpWidget(
        CupertinoApp(
          home: DummyStatefulWidget(key: key),
        ),
      );
      final bool isMaterial = isMaterialApp(key.currentContext! as Element);
      expect(isMaterial, false);
    });
  });

  test('pageBuilderForMaterialApp creates a [MaterialPage] accordingly', () {
    final UniqueKey key = UniqueKey();
    const String name = 'name';
    const String arguments = 'arguments';
    const String restorationId = 'restorationId';
    const DummyStatefulWidget child = DummyStatefulWidget();
    final MaterialPage<void> page = pageBuilderForMaterialApp(
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      child: child,
    );
    expect(page.key, key);
    expect(page.name, name);
    expect(page.arguments, arguments);
    expect(page.restorationId, restorationId);
    expect(page.child, child);
  });

  group('GoRouterMaterialErrorScreen', () {
    testWidgets('shows "page not found" by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: GoRouterMaterialErrorScreen(null),
      ));
      expect(find.text('page not found'), findsOneWidget);
    });

    testWidgets('shows the exception message when provided',
        (WidgetTester tester) async {
      final Exception error = Exception('Something went wrong!');
      await tester.pumpWidget(MaterialApp(
        home: GoRouterMaterialErrorScreen(error),
      ));
      expect(find.text('$error'), findsOneWidget);
    });

    testWidgets('clicking the TextButton should redirect to /',
        (WidgetTester tester) async {
      final GoRouter router = GoRouter(
        initialLocation: '/error',
        routes: <GoRoute>[
          GoRoute(path: '/', builder: (_, __) => const DummyStatefulWidget()),
          GoRoute(
            path: '/error',
            builder: (_, __) => const GoRouterMaterialErrorScreen(null),
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          title: 'GoRouter Example',
        ),
      );
      final Finder textButton = find.byType(TextButton);
      await tester.tap(textButton);
      await tester.pumpAndSettle();
      expect(find.byType(DummyStatefulWidget), findsOneWidget);
    });
  });
}

class DummyStatefulWidget extends StatefulWidget {
  const DummyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<DummyStatefulWidget> createState() => _DummyStatefulWidgetState();
}

class _DummyStatefulWidgetState extends State<DummyStatefulWidget> {
  @override
  Widget build(BuildContext context) => Container();
}
