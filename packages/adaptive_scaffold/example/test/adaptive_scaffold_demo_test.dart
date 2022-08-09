// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:adaptive_scaffold_example/adaptive_scaffold_demo.dart'
    as example;
import 'package:adaptive_scaffold/adaptive_scaffold.dart';
import 'package:flutter/material.dart';
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
    await tester.pumpAndSettle();
  }

  Future<MaterialApp> scaffold({
    required double width,
    required WidgetTester tester,
    bool animations = true,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 800));
    final List<Widget> children = <Widget>[
      for (int i = 0; i < 10; i++)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: const Color.fromARGB(255, 255, 201, 197),
            height: 400,
          ),
        )
    ];
    return MaterialApp(
      home: BottomNavigationBarTheme(
        data: const BottomNavigationBarThemeData(
            unselectedItemColor: Colors.black, selectedItemColor: Colors.black),
        child: AdaptiveScaffold(
          // An option to override the default breakpoints used for small, medium,
          // and large.
          smallBreakpoint: const WidthPlatformBreakpoint(end: 700),
          mediumBreakpoint:
              const WidthPlatformBreakpoint(begin: 700, end: 1000),
          largeBreakpoint: const WidthPlatformBreakpoint(begin: 1000),
          useDrawer: false,
          destinations: const <NavigationDestination>[
            NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
            NavigationDestination(icon: Icon(Icons.article), label: 'Articles'),
            NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
            NavigationDestination(icon: Icon(Icons.video_call), label: 'Video'),
          ],
          body: (_) => GridView.count(crossAxisCount: 2, children: children),
          smallBody: (_) => ListView.builder(
              itemCount: 10, itemBuilder: (_, int idx) => children[idx]),
          // Define a default secondaryBody.
          secondaryBody: (_) =>
              Container(color: const Color.fromARGB(255, 234, 158, 192)),
          // Override the default secondaryBody during the smallBreakpoint to be
          // empty. Must use AdaptiveScaffold.emptyBuilder to ensure it is properly
          // overriden.
          smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
        ),
      ),
    );
  }

  testWidgets('dislays correct item of config based on screen width',
      (WidgetTester tester) async {
    await updateScreen(300, tester);
    expect(smallBody, findsOneWidget);
    expect(bnav, findsOneWidget);
    expect(tester.getTopLeft(smallBody), Offset.zero);
    expect(tester.getTopLeft(bnav), const Offset(0, 744));
    expect(body, findsNothing);
    expect(largeBody, findsNothing);
    expect(pnav, findsNothing);
    expect(pnav1, findsNothing);

    await updateScreen(800, tester);
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

    await tester.pumpWidget(await scaffold(width: 400, tester: tester));
    await tester.pumpWidget(await scaffold(width: 800, tester: tester));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(b), const Offset(17.6, 0));
    expect(tester.getBottomRight(b),
        offsetMoreOrLessEquals(const Offset(778.2, 800), epsilon: 1.0));
    expect(tester.getTopLeft(sBody),
        offsetMoreOrLessEquals(const Offset(778.2, 0), epsilon: 1.0));
    expect(tester.getBottomRight(sBody),
        offsetMoreOrLessEquals(const Offset(1178.2, 800), epsilon: 1.0));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(tester.getTopLeft(b), const Offset(70.4, 0));
    expect(tester.getBottomRight(b),
        offsetMoreOrLessEquals(const Offset(416.0, 800), epsilon: 1.0));
    expect(tester.getTopLeft(sBody),
        offsetMoreOrLessEquals(const Offset(416, 0), epsilon: 1.0));
    expect(tester.getBottomRight(sBody),
        offsetMoreOrLessEquals(const Offset(816, 800), epsilon: 1.0));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(b), const Offset(88, 0));
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

    expect(tester.getTopLeft(b),
        offsetMoreOrLessEquals(const Offset(17.6, 0), epsilon: 0.1));
    expect(tester.getBottomRight(b),
        offsetMoreOrLessEquals(const Offset(778.2, 800.0), epsilon: 0.1));
    expect(tester.getTopLeft(sBody),
        offsetMoreOrLessEquals(const Offset(778.2, 0), epsilon: 0.1));
  });
}
