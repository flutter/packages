// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:adaptive_scaffold/src/adaptive_scaffold.dart';
import 'package:adaptive_scaffold/src/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestBreakpoint0 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.of(context).size.width >= 0 &&
        MediaQuery.of(context).size.width < 800;
  }
}

class TestBreakpoint800 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.of(context).size.width >= 800 &&
        MediaQuery.of(context).size.width < 1000;
  }
}

class TestBreakpoint1000 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1000;
  }
}

class NeverOnBreakpoint extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return false;
  }
}

Future<MaterialApp> scaffold({
  required double width,
  required WidgetTester tester,
  bool animations = true,
}) async {
  await tester.binding.setSurfaceSize(Size(width, 800));
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: Size(width, 800)),
      child: AdaptiveScaffold(
        drawerBreakpoint: NeverOnBreakpoint(),
        internalAnimations: animations,
        smallBreakpoint: TestBreakpoint0(),
        mediumBreakpoint: TestBreakpoint800(),
        largeBreakpoint: TestBreakpoint1000(),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
          NavigationDestination(icon: Icon(Icons.article), label: 'Articles'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.video_call), label: 'Video'),
        ],
        smallBody: (_) => Container(color: Colors.red),
        body: (_) => Container(color: Colors.green),
        largeBody: (_) => Container(color: Colors.blue),
        smallSecondaryBody: (_) => Container(color: Colors.red),
        secondaryBody: (_) => Container(color: Colors.green),
        largeSecondaryBody: (_) => Container(color: Colors.blue),
      ),
    ),
  );
}

void main() {
  testWidgets('adaptive scaffold lays out slots as expected',
      (WidgetTester tester) async {
    final Finder smallBody = find.byKey(const Key('smallBody'));
    final Finder body = find.byKey(const Key('body'));
    final Finder largeBody = find.byKey(const Key('largeBody'));
    final Finder smallSBody = find.byKey(const Key('smallSBody'));
    final Finder sBody = find.byKey(const Key('sBody'));
    final Finder largeSBody = find.byKey(const Key('largeSBody'));
    final Finder bnav = find.byKey(const Key('bottomNavigation'));
    final Finder pnav = find.byKey(const Key('primaryNavigation'));
    final Finder pnav1 = find.byKey(const Key('primaryNavigation1'));

    await tester.pumpWidget(await scaffold(width: 300, tester: tester));
    await tester.pumpAndSettle();

    expect(smallBody, findsOneWidget);
    expect(smallSBody, findsOneWidget);
    expect(bnav, findsOneWidget);
    expect(pnav, findsNothing);

    expect(tester.getTopLeft(smallBody), Offset.zero);
    expect(tester.getTopLeft(smallSBody), const Offset(150, 0));
    expect(tester.getTopLeft(bnav), const Offset(0, 744));

    await tester.pumpWidget(await scaffold(width: 900, tester: tester));
    await tester.pumpAndSettle();

    expect(smallBody, findsNothing);
    expect(body, findsOneWidget);
    expect(smallSBody, findsNothing);
    expect(sBody, findsOneWidget);
    expect(bnav, findsNothing);
    expect(pnav, findsOneWidget);

    expect(tester.getTopLeft(body), const Offset(88, 0));
    expect(tester.getTopLeft(sBody), const Offset(450, 0));
    expect(tester.getTopLeft(pnav), Offset.zero);
    expect(tester.getBottomRight(pnav), const Offset(88, 800));

    await tester.pumpWidget(await scaffold(width: 1100, tester: tester));
    await tester.pumpAndSettle();

    expect(body, findsNothing);
    expect(largeBody, findsOneWidget);
    expect(sBody, findsNothing);
    expect(largeSBody, findsOneWidget);
    expect(pnav, findsNothing);
    expect(pnav1, findsOneWidget);

    expect(tester.getTopLeft(largeBody), const Offset(208, 0));
    expect(tester.getTopLeft(largeSBody), const Offset(550, 0));
    expect(tester.getTopLeft(pnav1), Offset.zero);
    expect(tester.getBottomRight(pnav1), const Offset(208, 800));
  });
  testWidgets('adaptive scaffold animations work correctly',
      (WidgetTester tester) async {
    final Finder b = find.byKey(const Key('body'));
    final Finder sBody = find.byKey(const Key('sBody'));

    await tester.pumpWidget(await scaffold(width: 400, tester: tester));
    await tester.pumpWidget(await scaffold(width: 800, tester: tester));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(b), const Offset(17.6, 0));
    expect(tester.getBottomRight(b),
        offsetMoreOrLessEquals(const Offset(778.2, 755.2), epsilon: 1.0));
    expect(tester.getTopLeft(sBody),
        offsetMoreOrLessEquals(const Offset(778.2, 0), epsilon: 1.0));
    expect(tester.getBottomRight(sBody),
        offsetMoreOrLessEquals(const Offset(1178.2, 755.2), epsilon: 1.0));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(tester.getTopLeft(b), const Offset(70.4, 0));
    expect(tester.getBottomRight(b),
        offsetMoreOrLessEquals(const Offset(416.0, 788.8), epsilon: 1.0));
    expect(tester.getTopLeft(sBody),
        offsetMoreOrLessEquals(const Offset(416, 0), epsilon: 1.0));
    expect(tester.getBottomRight(sBody),
        offsetMoreOrLessEquals(const Offset(816, 788.8), epsilon: 1.0));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(b), const Offset(88.0, 0));
    expect(tester.getBottomRight(b), const Offset(400, 800));
    expect(tester.getTopLeft(sBody), const Offset(400, 0));
    expect(tester.getBottomRight(sBody), const Offset(800, 800));
  });
  testWidgets('adaptive scaffold animations can be disabled',
      (WidgetTester tester) async {
    final Finder b = find.byKey(const Key('body'));
    final Finder sBody = find.byKey(const Key('sBody'));

    await tester.pumpWidget(
        await scaffold(width: 400, tester: tester, animations: false));
    await tester.pumpWidget(
        await scaffold(width: 800, tester: tester, animations: false));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(b), const Offset(88.0, 0));
    expect(tester.getBottomRight(b), const Offset(400, 800));
    expect(tester.getTopLeft(sBody), const Offset(400, 0));
    expect(tester.getBottomRight(sBody), const Offset(800, 800));
  });
}
