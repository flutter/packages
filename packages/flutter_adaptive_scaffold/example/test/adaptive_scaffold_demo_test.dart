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
  final Finder mediumLargeBody = find.byKey(const Key('mediumLargeBody'));
  final Finder largeBody = find.byKey(const Key('largeBody'));
  final Finder extraLargeBody = find.byKey(const Key('extraLargeBody'));
  final Finder bnav = find.byKey(const Key('bottomNavigation'));
  final Finder pnav = find.byKey(const Key('primaryNavigation'));
  final Finder pnav1 = find.byKey(const Key('primaryNavigation1'));
  final Finder pnav2 = find.byKey(const Key('primaryNavigation2'));
  final Finder pnav3 = find.byKey(const Key('primaryNavigation3'));

  Future<void> updateScreen(double width, WidgetTester tester,
      {int transitionDuration = 1000}) async {
    await tester.binding.setSurfaceSize(Size(width, 2000));
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
            data: MediaQueryData(size: Size(width, 2000)),
            child: example.MyHomePage(
              transitionDuration: transitionDuration,
            )),
      ),
    );
  }

  testWidgets('displays correct item of config based on screen width',
      (WidgetTester tester) async {
    // Small
    await updateScreen(300, tester);
    await tester.pumpAndSettle();
    expect(smallBody, findsOneWidget);
    expect(bnav, findsOneWidget);
    expect(tester.getTopLeft(smallBody), Offset.zero);
    expect(tester.getTopLeft(bnav), const Offset(0, 1920));
    expect(body, findsNothing);
    expect(mediumLargeBody, findsNothing);
    expect(largeBody, findsNothing);
    expect(extraLargeBody, findsNothing);
    expect(pnav, findsNothing);
    expect(pnav1, findsNothing);
    expect(pnav2, findsNothing);
    expect(pnav3, findsNothing);

    // Medium
    await updateScreen(800, tester);
    await tester.pumpAndSettle();
    expect(body, findsOneWidget);
    expect(pnav, findsOneWidget);
    expect(tester.getTopLeft(body), const Offset(88, 0));
    expect(tester.getTopLeft(pnav), Offset.zero);
    expect(smallBody, findsNothing);
    expect(mediumLargeBody, findsNothing);
    expect(largeBody, findsNothing);
    expect(extraLargeBody, findsNothing);
    expect(bnav, findsNothing);
    expect(pnav1, findsNothing);
    expect(pnav2, findsNothing);
    expect(pnav3, findsNothing);

    // Medium Large
    await updateScreen(1100, tester);
    await tester.pumpAndSettle();
    expect(mediumLargeBody, findsOneWidget);
    expect(pnav1, findsOneWidget);
    expect(tester.getTopLeft(mediumLargeBody), const Offset(208, 0));
    expect(tester.getTopLeft(pnav1), Offset.zero);
    expect(smallBody, findsNothing);
    expect(body, findsNothing);
    expect(largeBody, findsNothing);
    expect(extraLargeBody, findsNothing);
    expect(bnav, findsNothing);
    expect(pnav, findsNothing);
    expect(pnav2, findsNothing);
    expect(pnav3, findsNothing);

    // Large
    await updateScreen(1400, tester);
    await tester.pumpAndSettle();
    expect(largeBody, findsOneWidget);
    expect(mediumLargeBody, findsNothing);
    expect(pnav2, findsOneWidget);
    expect(tester.getTopLeft(largeBody), const Offset(208, 0));
    expect(tester.getTopLeft(pnav2), Offset.zero);
    expect(smallBody, findsNothing);
    expect(body, findsNothing);
    expect(mediumLargeBody, findsNothing);
    expect(extraLargeBody, findsNothing);
    expect(bnav, findsNothing);
    expect(pnav, findsNothing);
    expect(pnav1, findsNothing);
    expect(pnav3, findsNothing);

    // Extra Large
    await updateScreen(1700, tester);
    await tester.pumpAndSettle();
    expect(extraLargeBody, findsOneWidget);
    expect(pnav3, findsOneWidget);
    expect(tester.getTopLeft(extraLargeBody), const Offset(208, 0));
    expect(tester.getTopLeft(pnav3), Offset.zero);
    expect(smallBody, findsNothing);
    expect(body, findsNothing);
    expect(mediumLargeBody, findsNothing);
    expect(largeBody, findsNothing);
    expect(bnav, findsNothing);
    expect(pnav, findsNothing);
    expect(pnav1, findsNothing);
    expect(pnav2, findsNothing);
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
        offsetMoreOrLessEquals(const Offset(778.2, 1936), epsilon: 1.0));
    expect(tester.getTopLeft(sBody),
        offsetMoreOrLessEquals(const Offset(778.2, 0), epsilon: 1.0));
    expect(tester.getBottomRight(sBody),
        offsetMoreOrLessEquals(const Offset(1178.2, 1936), epsilon: 1.0));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(tester.getTopLeft(b), const Offset(70.4, 0));
    expect(tester.getBottomRight(b),
        offsetMoreOrLessEquals(const Offset(416.0, 1984), epsilon: 1.0));
    expect(tester.getTopLeft(sBody),
        offsetMoreOrLessEquals(const Offset(416, 0), epsilon: 1.0));
    expect(tester.getBottomRight(sBody),
        offsetMoreOrLessEquals(const Offset(816, 1984), epsilon: 1.0));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(b), const Offset(88, 0));
    expect(tester.getBottomRight(b), const Offset(400, 2000));
    expect(tester.getTopLeft(sBody), const Offset(400, 0));
    expect(tester.getBottomRight(sBody), const Offset(800, 2000));
  });

  testWidgets('animation plays correctly in declared duration',
      (WidgetTester tester) async {
    final Finder b = find.byKey(const Key('body'));
    final Finder sBody = find.byKey(const Key('sBody'));

    await updateScreen(400, tester, transitionDuration: 500);
    await updateScreen(800, tester, transitionDuration: 500);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.getTopLeft(b), const Offset(88, 0));
    expect(tester.getBottomRight(b), const Offset(400, 2000));
    expect(tester.getTopLeft(sBody), const Offset(400, 0));
    expect(tester.getBottomRight(sBody), const Offset(800, 2000));
  });
}
