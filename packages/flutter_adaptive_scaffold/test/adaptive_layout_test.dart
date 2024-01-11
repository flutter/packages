// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/src/adaptive_layout.dart';
import 'package:flutter_adaptive_scaffold/src/breakpoints.dart';
import 'package:flutter_adaptive_scaffold/src/slot_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'slot layout displays correct item of config based on screen width',
      (WidgetTester tester) async {
    MediaQuery slot(double width) {
      return MediaQuery(
        // TODO(stuartmorgan): Replace with .fromView once this package requires
        // Flutter 3.8+.
        // ignore: deprecated_member_use
        data: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
            .copyWith(size: Size(width, 800)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SlotLayout(
            config: <Breakpoint, SlotLayoutConfig>{
              TestBreakpoint0(): SlotLayout.from(
                  key: const Key('0'), builder: (_) => const SizedBox()),
              TestBreakpoint400(): SlotLayout.from(
                  key: const Key('400'), builder: (_) => const SizedBox()),
              TestBreakpoint800(): SlotLayout.from(
                  key: const Key('800'), builder: (_) => const SizedBox()),
            },
          ),
        ),
      );
    }

    await tester.pumpWidget(slot(300));
    expect(find.byKey(const Key('0')), findsOneWidget);
    expect(find.byKey(const Key('400')), findsNothing);
    expect(find.byKey(const Key('800')), findsNothing);

    await tester.pumpWidget(slot(500));
    expect(find.byKey(const Key('0')), findsNothing);
    expect(find.byKey(const Key('400')), findsOneWidget);
    expect(find.byKey(const Key('800')), findsNothing);

    await tester.pumpWidget(slot(1000));
    expect(find.byKey(const Key('0')), findsNothing);
    expect(find.byKey(const Key('400')), findsNothing);
    expect(find.byKey(const Key('800')), findsOneWidget);
  });

  testWidgets('adaptive layout displays children in correct places',
      (WidgetTester tester) async {
    await tester.pumpWidget(await layout(width: 400, tester: tester));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(topNavigation), Offset.zero);
    expect(tester.getTopLeft(secondaryNavigation), const Offset(390, 10));
    expect(tester.getTopLeft(primaryNavigation), const Offset(0, 10));
    expect(tester.getTopLeft(bottomNavigation), const Offset(0, 790));
    expect(tester.getTopLeft(testBreakpoint), const Offset(10, 10));
    expect(tester.getBottomRight(testBreakpoint), const Offset(200, 790));
    expect(tester.getTopLeft(secondaryTestBreakpoint), const Offset(200, 10));
    expect(
        tester.getBottomRight(secondaryTestBreakpoint), const Offset(390, 790));
  });

  testWidgets('adaptive layout correct layout when body vertical',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        await layout(width: 400, tester: tester, orientation: Axis.vertical));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(topNavigation), Offset.zero);
    expect(tester.getTopLeft(secondaryNavigation), const Offset(390, 10));
    expect(tester.getTopLeft(primaryNavigation), const Offset(0, 10));
    expect(tester.getTopLeft(bottomNavigation), const Offset(0, 790));
    expect(tester.getTopLeft(testBreakpoint), const Offset(10, 10));
    expect(tester.getBottomRight(testBreakpoint), const Offset(390, 400));
    expect(tester.getTopLeft(secondaryTestBreakpoint), const Offset(10, 400));
    expect(
        tester.getBottomRight(secondaryTestBreakpoint), const Offset(390, 790));
  });

  testWidgets('adaptive layout correct layout when rtl',
      (WidgetTester tester) async {
    await tester.pumpWidget(await layout(
        width: 400, tester: tester, directionality: TextDirection.rtl));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(topNavigation), Offset.zero);
    expect(tester.getTopLeft(secondaryNavigation), const Offset(0, 10));
    expect(tester.getTopLeft(primaryNavigation), const Offset(390, 10));
    expect(tester.getTopLeft(bottomNavigation), const Offset(0, 790));
    expect(tester.getTopLeft(testBreakpoint), const Offset(200, 10));
    expect(tester.getBottomRight(testBreakpoint), const Offset(390, 790));
    expect(tester.getTopLeft(secondaryTestBreakpoint), const Offset(10, 10));
    expect(
        tester.getBottomRight(secondaryTestBreakpoint), const Offset(200, 790));
  });

  testWidgets('adaptive layout correct layout when body ratio not default',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(await layout(width: 400, tester: tester, bodyRatio: 1 / 3));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(topNavigation), Offset.zero);
    expect(tester.getTopLeft(secondaryNavigation), const Offset(390, 10));
    expect(tester.getTopLeft(primaryNavigation), const Offset(0, 10));
    expect(tester.getTopLeft(bottomNavigation), const Offset(0, 790));
    expect(tester.getTopLeft(testBreakpoint), const Offset(10, 10));
    expect(tester.getBottomRight(testBreakpoint),
        offsetMoreOrLessEquals(const Offset(136.7, 790), epsilon: 1.0));
    expect(tester.getTopLeft(secondaryTestBreakpoint),
        offsetMoreOrLessEquals(const Offset(136.7, 10), epsilon: 1.0));
    expect(
        tester.getBottomRight(secondaryTestBreakpoint), const Offset(390, 790));
  });

  final Finder begin = find.byKey(const Key('0'));
  final Finder end = find.byKey(const Key('400'));
  Finder slideIn(String key) => find.byKey(Key('in-${Key(key)}'));
  Finder slideOut(String key) => find.byKey(Key('out-${Key(key)}'));
  testWidgets(
      'slot layout properly switches between items with the appropriate animation',
      (WidgetTester tester) async {
    await tester.pumpWidget(slot(300));
    expect(begin, findsOneWidget);
    expect(end, findsNothing);

    await tester.pumpWidget(slot(500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.widget<SlideTransition>(slideOut('0')).position.value,
        const Offset(-0.5, 0));
    expect(tester.widget<SlideTransition>(slideIn('400')).position.value,
        const Offset(-0.5, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.widget<SlideTransition>(slideOut('0')).position.value,
        const Offset(-1.0, 0));
    expect(tester.widget<SlideTransition>(slideIn('400')).position.value,
        Offset.zero);

    await tester.pumpAndSettle();
    expect(begin, findsNothing);
    expect(end, findsOneWidget);
  });

  testWidgets('AnimatedSwitcher does not spawn duplicate keys on rapid resize',
      (WidgetTester tester) async {
    // Populate the smaller slot layout and let the animation settle.
    await tester.pumpWidget(slot(300));
    await tester.pumpAndSettle();
    expect(begin, findsOneWidget);
    expect(end, findsNothing);

    // Jumping back between two layouts before allowing an animation to complete.
    // Produces a chain of widgets in AnimatedSwitcher that includes duplicate
    // widgets with the same global key.
    for (int i = 0; i < 2; i++) {
      // Resize between the two slot layouts, but do not pump the animation
      // until completion.
      await tester.pumpWidget(slot(500));
      await tester.pump(const Duration(milliseconds: 100));
      expect(begin, findsOneWidget);
      expect(end, findsOneWidget);

      await tester.pumpWidget(slot(300));
      await tester.pump(const Duration(milliseconds: 100));
      expect(begin, findsOneWidget);
      expect(end, findsOneWidget);
    }
  });

  testWidgets('slot layout can tolerate rapid changes in breakpoints',
      (WidgetTester tester) async {
    await tester.pumpWidget(slot(300));
    expect(begin, findsOneWidget);
    expect(end, findsNothing);

    await tester.pumpWidget(slot(500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<SlideTransition>(slideOut('0')).position.value,
        offsetMoreOrLessEquals(const Offset(-0.1, 0), epsilon: 0.05));
    expect(tester.widget<SlideTransition>(slideIn('400')).position.value,
        offsetMoreOrLessEquals(const Offset(-0.9, 0), epsilon: 0.05));
    await tester.pumpWidget(slot(300));
    await tester.pumpAndSettle();
    expect(begin, findsOneWidget);
    expect(end, findsNothing);
  });

  // This test reflects the behavior of the internal animations of both the body
  // and secondary body and also the navigational items. This is reflected in
  // the changes in LTRB offsets from all sides instead of just LR for the body
  // animations.
  testWidgets('adaptive layout handles internal animations correctly',
      (WidgetTester tester) async {
    final Finder testBreakpoint = find.byKey(const Key('Test Breakpoint'));
    final Finder secondaryTestBreakpoint =
        find.byKey(const Key('Secondary Test Breakpoint'));

    await tester.pumpWidget(await layout(width: 400, tester: tester));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getTopLeft(testBreakpoint), const Offset(1, 1));
    expect(tester.getBottomRight(testBreakpoint),
        offsetMoreOrLessEquals(const Offset(395.8, 799), epsilon: 1.0));
    expect(tester.getTopLeft(secondaryTestBreakpoint),
        offsetMoreOrLessEquals(const Offset(395.8, 1.0), epsilon: 1.0));
    expect(tester.getBottomRight(secondaryTestBreakpoint),
        offsetMoreOrLessEquals(const Offset(594.8, 799.0), epsilon: 1.0));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.getTopLeft(testBreakpoint), const Offset(5, 5));
    expect(tester.getBottomRight(testBreakpoint),
        offsetMoreOrLessEquals(const Offset(294.2, 795), epsilon: 1.0));
    expect(tester.getTopLeft(secondaryTestBreakpoint),
        offsetMoreOrLessEquals(const Offset(294.2, 5.0), epsilon: 1.0));
    expect(tester.getBottomRight(secondaryTestBreakpoint),
        offsetMoreOrLessEquals(const Offset(489.2, 795.0), epsilon: 1.0));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.getTopLeft(testBreakpoint), const Offset(9, 9));
    expect(tester.getBottomRight(testBreakpoint),
        offsetMoreOrLessEquals(const Offset(201.7, 791), epsilon: 1.0));
    expect(tester.getTopLeft(secondaryTestBreakpoint),
        offsetMoreOrLessEquals(const Offset(201.7, 9.0), epsilon: 1.0));
    expect(tester.getBottomRight(secondaryTestBreakpoint),
        offsetMoreOrLessEquals(const Offset(392.7, 791), epsilon: 1.0));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getTopLeft(testBreakpoint), const Offset(10, 10));
    expect(tester.getBottomRight(testBreakpoint), const Offset(200, 790));
    expect(tester.getTopLeft(secondaryTestBreakpoint), const Offset(200, 10));
    expect(
        tester.getBottomRight(secondaryTestBreakpoint), const Offset(390, 790));
  });

  testWidgets('adaptive layout does not animate when animations off',
      (WidgetTester tester) async {
    final Finder testBreakpoint = find.byKey(const Key('Test Breakpoint'));
    final Finder secondaryTestBreakpoint =
        find.byKey(const Key('Secondary Test Breakpoint'));

    await tester.pumpWidget(
        await layout(width: 400, tester: tester, animations: false));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getTopLeft(testBreakpoint), const Offset(10, 10));
    expect(tester.getBottomRight(testBreakpoint), const Offset(200, 790));
    expect(tester.getTopLeft(secondaryTestBreakpoint), const Offset(200, 10));
    expect(
        tester.getBottomRight(secondaryTestBreakpoint), const Offset(390, 790));
  });
}

class TestBreakpoint0 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.of(context).size.width >= 0;
  }
}

class TestBreakpoint400 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.of(context).size.width > 400;
  }
}

class TestBreakpoint800 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.of(context).size.width > 800;
  }
}

final Finder topNavigation = find.byKey(const Key('Top Navigation'));
final Finder secondaryNavigation =
    find.byKey(const Key('Secondary Navigation Small'));
final Finder primaryNavigation =
    find.byKey(const Key('Primary Navigation Small'));
final Finder bottomNavigation =
    find.byKey(const Key('Bottom Navigation Small'));
final Finder testBreakpoint = find.byKey(const Key('Test Breakpoint'));
final Finder secondaryTestBreakpoint =
    find.byKey(const Key('Secondary Test Breakpoint'));

Widget on(BuildContext _) {
  return const SizedBox(width: 10, height: 10);
}

Future<MediaQuery> layout({
  required double width,
  required WidgetTester tester,
  Axis orientation = Axis.horizontal,
  TextDirection directionality = TextDirection.ltr,
  double? bodyRatio,
  bool animations = true,
}) async {
  await tester.binding.setSurfaceSize(Size(width, 800));
  return MediaQuery(
    data: MediaQueryData(size: Size(width, 800)),
    child: Directionality(
      textDirection: directionality,
      child: AdaptiveLayout(
        bodyOrientation: orientation,
        bodyRatio: bodyRatio,
        internalAnimations: animations,
        primaryNavigation: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            TestBreakpoint0(): SlotLayout.from(
                key: const Key('Primary Navigation Small'), builder: on),
            TestBreakpoint400(): SlotLayout.from(
                key: const Key('Primary Navigation Medium'), builder: on),
            TestBreakpoint800(): SlotLayout.from(
                key: const Key('Primary Navigation Large'), builder: on),
          },
        ),
        secondaryNavigation: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            TestBreakpoint0(): SlotLayout.from(
                key: const Key('Secondary Navigation Small'), builder: on),
            TestBreakpoint400(): SlotLayout.from(
                key: const Key('Secondary Navigation Medium'), builder: on),
            TestBreakpoint800(): SlotLayout.from(
                key: const Key('Secondary Navigation Large'), builder: on),
          },
        ),
        topNavigation: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            TestBreakpoint0():
                SlotLayout.from(key: const Key('Top Navigation'), builder: on),
            TestBreakpoint400():
                SlotLayout.from(key: const Key('Top Navigation1'), builder: on),
            TestBreakpoint800():
                SlotLayout.from(key: const Key('Top Navigation2'), builder: on),
          },
        ),
        bottomNavigation: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            TestBreakpoint0(): SlotLayout.from(
                key: const Key('Bottom Navigation Small'), builder: on),
            TestBreakpoint400():
                SlotLayout.from(key: const Key('bnav1'), builder: on),
            TestBreakpoint800():
                SlotLayout.from(key: const Key('bnav2'), builder: on),
          },
        ),
        body: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            TestBreakpoint0(): SlotLayout.from(
              key: const Key('Test Breakpoint'),
              builder: (_) => Container(color: Colors.red),
            ),
            TestBreakpoint400(): SlotLayout.from(
              key: const Key('Test Breakpoint 1'),
              builder: (_) => Container(color: Colors.red),
            ),
            TestBreakpoint800(): SlotLayout.from(
              key: const Key('Test Breakpoint 2'),
              builder: (_) => Container(color: Colors.red),
            ),
          },
        ),
        secondaryBody: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            TestBreakpoint0(): SlotLayout.from(
              key: const Key('Secondary Test Breakpoint'),
              builder: (_) => Container(color: Colors.blue),
            ),
            TestBreakpoint400(): SlotLayout.from(
              key: const Key('Secondary Test Breakpoint 1'),
              builder: (_) => Container(color: Colors.blue),
            ),
            TestBreakpoint800(): SlotLayout.from(
              key: const Key('Secondary Test Breakpoint 2'),
              builder: (_) => Container(color: Colors.blue),
            ),
          },
        ),
      ),
    ),
  );
}

AnimatedWidget leftOutIn(Widget child, Animation<double> animation) {
  return SlideTransition(
    key: Key('in-${child.key}'),
    position: Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(animation),
    child: child,
  );
}

AnimatedWidget leftInOut(Widget child, Animation<double> animation) {
  return SlideTransition(
    key: Key('out-${child.key}'),
    position: Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1, 0),
    ).animate(animation),
    child: child,
  );
}

MediaQuery slot(double width) {
  return MediaQuery(
    // TODO(stuartmorgan): Replace with .fromView once this package requires
    // Flutter 3.8+.
    // ignore: deprecated_member_use
    data: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
        .copyWith(size: Size(width, 800)),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: SlotLayout(
        config: <Breakpoint, SlotLayoutConfig>{
          TestBreakpoint0(): SlotLayout.from(
            inAnimation: leftOutIn,
            outAnimation: leftInOut,
            key: const Key('0'),
            builder: (_) => const SizedBox(width: 10, height: 10),
          ),
          TestBreakpoint400(): SlotLayout.from(
            inAnimation: leftOutIn,
            outAnimation: leftInOut,
            key: const Key('400'),
            builder: (_) => const SizedBox(width: 10, height: 10),
          ),
        },
      ),
    ),
  );
}
