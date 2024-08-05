// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold_example/adaptive_scaffold_demo.dart'
    as example;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final Finder smallBody = find.byKey(const Key('smallBody'));
  final Finder body = find.byKey(const Key('body'));
  final Finder expandedBody = find.byKey(const Key('expandedBody'));
  final Finder largeBody = find.byKey(const Key('largeBody'));
  final Finder extraLargeBody = find.byKey(const Key('extraLargeBody'));

  final Finder smallSBody = find.byKey(const Key('smallSBody'));
  final Finder sBody = find.byKey(const Key('sBody'));
  final Finder expandedSBody = find.byKey(const Key('expandedSBody'));
  final Finder largeSBody = find.byKey(const Key('largeSBody'));
  final Finder extraLargeSBody = find.byKey(const Key('extraLargeSBody'));

  final Finder bnav = find.byKey(const Key('bottomNavigation'));
  final Finder pnav = find.byKey(const Key('primaryNavigation'));
  final Finder pnav1 = find.byKey(const Key('primaryNavigation1'));
  final Finder pnav2 = find.byKey(const Key('primaryNavigation2'));
  final Finder pnav3 = find.byKey(const Key('primaryNavigation3'));

  Future<void> updateScreen(double width, WidgetTester tester) async {
    await tester.binding.setSurfaceSize(Size(width, 2000));
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
            data: MediaQueryData(size: Size(width, 2000)),
            child: const example.MyHomePage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dislays correct item of config based on screen width',
      (WidgetTester tester) async {
    await updateScreen(300, tester);
    expect(smallBody, findsOneWidget);
    expect(sBody, findsNothing);
    expect(expandedBody, findsNothing);
    expect(largeBody, findsNothing);
    expect(extraLargeBody, findsNothing);
    expect(smallSBody, findsNothing);
    expect(sBody, findsNothing);
    expect(expandedSBody, findsNothing);
    expect(largeSBody, findsNothing);
    expect(extraLargeSBody, findsNothing);
    expect(bnav, findsOneWidget);
    expect(body, findsNothing);
    expect(pnav, findsNothing);
    expect(pnav1, findsNothing);
    expect(pnav2, findsNothing);
    expect(pnav3, findsNothing);

    await updateScreen(800, tester);
    expect(smallBody, findsNothing);
    expect(sBody, findsOneWidget);
    expect(expandedBody, findsNothing);
    expect(largeBody, findsNothing);
    expect(extraLargeBody, findsNothing);
    expect(smallSBody, findsNothing);
    expect(sBody, findsOneWidget);
    expect(expandedSBody, findsNothing);
    expect(largeSBody, findsNothing);
    expect(extraLargeSBody, findsNothing);
    expect(bnav, findsNothing);
    expect(body, findsOneWidget);
    expect(pnav, findsOneWidget);
    expect(pnav1, findsNothing);
    expect(pnav2, findsNothing);
    expect(pnav3, findsNothing);

    await updateScreen(1100, tester);
    expect(smallBody, findsNothing);
    expect(sBody, findsNothing);
    expect(expandedBody, findsOneWidget);
    expect(largeBody, findsNothing);
    expect(extraLargeBody, findsNothing);
    expect(smallSBody, findsNothing);
    expect(sBody, findsNothing);
    expect(expandedSBody, findsOneWidget);
    expect(largeSBody, findsNothing);
    expect(extraLargeSBody, findsNothing);
    expect(bnav, findsNothing);
    expect(body, findsNothing);
    expect(pnav, findsNothing);
    expect(pnav1, findsOneWidget);
    expect(pnav2, findsNothing);
    expect(pnav3, findsNothing);

    await updateScreen(1400, tester);
    expect(smallBody, findsNothing);
    expect(sBody, findsNothing);
    expect(expandedBody, findsNothing);
    expect(largeBody, findsOneWidget);
    expect(extraLargeBody, findsNothing);
    expect(smallSBody, findsNothing);
    expect(sBody, findsNothing);
    expect(expandedSBody, findsNothing);
    expect(largeSBody, findsOneWidget);
    expect(extraLargeSBody, findsNothing);
    expect(bnav, findsNothing);
    expect(body, findsNothing);
    expect(pnav, findsNothing);
    expect(pnav1, findsNothing);
    expect(pnav2, findsOneWidget);
    expect(pnav3, findsNothing);

    await updateScreen(1800, tester);
    expect(smallBody, findsNothing);
    expect(sBody, findsNothing);
    expect(expandedBody, findsNothing);
    expect(largeBody, findsNothing);
    expect(extraLargeBody, findsOneWidget);
    expect(smallSBody, findsNothing);
    expect(sBody, findsNothing);
    expect(expandedSBody, findsNothing);
    expect(largeSBody, findsNothing);
    expect(extraLargeSBody, findsOneWidget);
    expect(bnav, findsNothing);
    expect(body, findsNothing);
    expect(pnav, findsNothing);
    expect(pnav1, findsNothing);
    expect(pnav2, findsNothing);
    expect(pnav3, findsOneWidget);
  });
}
