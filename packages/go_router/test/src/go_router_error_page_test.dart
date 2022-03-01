// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/go_router_error_page.dart';

void main() {
  testWidgets('shows "page not found" by default', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      color: Color(0xFFFFFFFF),
      home: GoRouterErrorScreen(null),
    ));
    expect(find.text('page not found'), findsOneWidget);
  });

  testWidgets('shows the exception message when provided', (tester) async {
    final error = Exception('Something went wrong!');
    await tester.pumpWidget(MaterialApp(
      color: const Color(0xFFFFFFFF),
      home: GoRouterErrorScreen(error),
    ));
    expect(find.text('$error'), findsOneWidget);
  });

  testWidgets('clicking the button should redirect to /', (tester) async {
    final router = GoRouter(
      initialLocation: '/error',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const DummyStatefulWidget()),
        GoRoute(
          path: '/error',
          builder: (_, __) => const GoRouterErrorScreen(null),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        color: const Color(0xFFFFFFFF),
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
        title: 'GoRouter Example',
      ),
    );
    final button =
        find.byWidgetPredicate((widget) => widget is GestureDetector);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byType(DummyStatefulWidget), findsOneWidget);
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
