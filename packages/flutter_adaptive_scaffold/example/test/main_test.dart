// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold_example/adaptive_scaffold_demo.dart'
    as example;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final Finder body = find.byKey(const Key('body'));
  final Finder sBody = find.byKey(const Key('sBody'));
  final Finder bnav = find.byKey(const Key('bottomNavigation'));
  final Finder pnav = find.byKey(const Key('primaryNavigation'));
  final Finder pnav1 = find.byKey(const Key('primaryNavigation1'));

  Future<void> updateScreen(double width, WidgetTester tester) async {
    await tester.binding.setSurfaceSize(Size(width, 800));
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
            data: MediaQueryData(size: Size(width, 800)),
            child: const example.MyHomePage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dislays correct item of config based on screen width',
      (WidgetTester tester) async {
    await updateScreen(300, tester);
    expect(sBody, findsNothing);
    expect(bnav, findsOneWidget);
    expect(body, findsNothing);
    expect(pnav, findsNothing);
    expect(pnav1, findsNothing);

    await updateScreen(800, tester);
    expect(body, findsOneWidget);
    expect(body, findsOneWidget);
    expect(bnav, findsNothing);
    expect(sBody, findsOneWidget);
    expect(pnav, findsOneWidget);
    expect(pnav1, findsNothing);

    await updateScreen(1100, tester);
    expect(body, findsOneWidget);
    expect(pnav, findsNothing);
    expect(pnav1, findsOneWidget);
  });
}
