// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold_example/adaptive_scaffold_demo.dart'
    as example;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final Finder smallBody = find.byKey(const Key('smallBody'));
  final Finder body = find.byKey(const Key('body'));
  final Finder largeBody = find.byKey(const Key('largeBody'));
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
  }

  testWidgets('dislays correct item of config based on screen width',
      (WidgetTester tester) async {
    await updateScreen(300, tester);
    await tester.pumpAndSettle();
    expect(smallBody, findsOneWidget);
    expect(bnav, findsOneWidget);
    expect(tester.getTopLeft(smallBody), Offset.zero);
    expect(tester.getTopLeft(bnav), const Offset(0, 720));
    expect(body, findsNothing);
    expect(largeBody, findsNothing);
    expect(pnav, findsNothing);
    expect(pnav1, findsNothing);

    await updateScreen(800, tester);
    await tester.pumpAndSettle();
    expect(body, findsOneWidget);
    expect(tester.getTopLeft(body), const Offset(88, 0));
    expect(body, findsOneWidget);
    expect(bnav, findsNothing);
    expect(largeBody, findsNothing);
    expect(pnav, findsOneWidget);
    expect(tester.getTopLeft(pnav), Offset.zero);
    expect(tester.getBottomRight(pnav), const Offset(88, 800));
    expect(pnav1, findsNothing);

    await updateScreen(1100, tester);
    await tester.pumpAndSettle();
    expect(body, findsOneWidget);
    expect(pnav, findsNothing);
    expect(pnav1, findsOneWidget);
    expect(tester.getTopLeft(pnav1), Offset.zero);
    expect(tester.getBottomRight(pnav1), const Offset(208, 800));
  });

  testWidgets('adaptive scaffold animations work correctly',
      (WidgetTester tester) async {
    final Finder b = find.byKey(const Key('body'));
    final Finder sBody = find.byKey(const Key('sBody'));

    await updateScreen(400, tester);
    await updateScreen(800, tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(b), const Offset(17.6, 0));
    expect(tester.getBottomRight(b),
        offsetMoreOrLessEquals(const Offset(778.2, 736), epsilon: 1.0));
    expect(tester.getTopLeft(sBody),
        offsetMoreOrLessEquals(const Offset(778.2, 0), epsilon: 1.0));
    expect(tester.getBottomRight(sBody),
        offsetMoreOrLessEquals(const Offset(1178.2, 736), epsilon: 1.0));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(tester.getTopLeft(b), const Offset(70.4, 0));
    expect(tester.getBottomRight(b),
        offsetMoreOrLessEquals(const Offset(416.0, 784), epsilon: 1.0));
    expect(tester.getTopLeft(sBody),
        offsetMoreOrLessEquals(const Offset(416, 0), epsilon: 1.0));
    expect(tester.getBottomRight(sBody),
        offsetMoreOrLessEquals(const Offset(816, 784), epsilon: 1.0));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(b), const Offset(88, 0));
    expect(tester.getBottomRight(b), const Offset(400, 800));
    expect(tester.getTopLeft(sBody), const Offset(400, 0));
    expect(tester.getBottomRight(sBody), const Offset(800, 800));
  });
}
