// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('GoRouter does not request focus if requestFocus is false',
      (WidgetTester tester) async {
    final GlobalKey innerKey = GlobalKey();
    final FocusScopeNode focusNode = FocusScopeNode();
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: <GoRoute>[
        GoRoute(
          path: '/',
          name: 'home',
          builder: (_, __) => const Text('A'),
        ),
        GoRoute(
          path: '/second',
          name: 'second',
          builder: (_, __) => Text('B', key: innerKey),
        ),
      ],
      requestFocus: false,
    );

    await tester.pumpWidget(Column(
      children: <Widget>[
        FocusScope(node: focusNode, child: Container()),
        Expanded(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      ],
    ));

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B', skipOffstage: false), findsNothing);
    expect(focusNode.hasFocus, false);
    focusNode.requestFocus();
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, true);

    router.pushNamed('second');
    await tester.pumpAndSettle();
    expect(find.text('A', skipOffstage: false), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(focusNode.hasFocus, true);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B', skipOffstage: false), findsNothing);
    expect(focusNode.hasFocus, true);
  });
}
