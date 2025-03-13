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
        data: MediaQueryData.fromView(tester.view)
            .copyWith(size: Size(width, 2000)),
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
              TestBreakpoint1200(): SlotLayout.from(
                  key: const Key('1200'), builder: (_) => const SizedBox()),
              TestBreakpoint1600(): SlotLayout.from(
                  key: const Key('1600'), builder: (_) => const SizedBox()),
            },
          ),
        ),
      );
    }

    await tester.pumpWidget(slot(300));
    expect(find.byKey(const Key('0')), findsOneWidget);
    expect(find.byKey(const Key('400')), findsNothing);
    expect(find.byKey(const Key('800')), findsNothing);
    expect(find.byKey(const Key('1200')), findsNothing);
    expect(find.byKey(const Key('1600')), findsNothing);

    await tester.pumpWidget(slot(500));
    expect(find.byKey(const Key('0')), findsNothing);
    expect(find.byKey(const Key('400')), findsOneWidget);
    expect(find.byKey(const Key('800')), findsNothing);
    expect(find.byKey(const Key('1200')), findsNothing);
    expect(find.byKey(const Key('1600')), findsNothing);

    await tester.pumpWidget(slot(1000));
    expect(find.byKey(const Key('0')), findsNothing);
    expect(find.byKey(const Key('400')), findsNothing);
    expect(find.byKey(const Key('800')), findsOneWidget);
    expect(find.byKey(const Key('1200')), findsNothing);
    expect(find.byKey(const Key('1600')), findsNothing);

    await tester.pumpWidget(slot(1400));
    expect(find.byKey(const Key('0')), findsNothing);
    expect(find.byKey(const Key('400')), findsNothing);
    expect(find.byKey(const Key('800')), findsNothing);
    expect(find.byKey(const Key('1200')), findsOneWidget);
    expect(find.byKey(const Key('1600')), findsNothing);

    await tester.pumpWidget(slot(1800));
    expect(find.byKey(const Key('0')), findsNothing);
    expect(find.byKey(const Key('400')), findsNothing);
    expect(find.byKey(const Key('800')), findsNothing);
    expect(find.byKey(const Key('1200')), findsNothing);
    expect(find.byKey(const Key('1600')), findsOneWidget);
  });

  testWidgets('adaptive layout displays children in correct places',
      (WidgetTester tester) async {
    await tester.pumpWidget(await layout(width: 400, tester: tester));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(topNavigation), Offset.zero);
    expect(tester.getTopLeft(secondaryNavigation), const Offset(390, 10));
    expect(tester.getTopLeft(primaryNavigation), const Offset(0, 10));
    expect(tester.getTopLeft(bottomNavigation), const Offset(0, 1990));
    expect(tester.getTopLeft(testBreakpoint), const Offset(10, 10));
    expect(tester.getBottomRight(testBreakpoint), const Offset(200, 1990));
    expect(tester.getTopLeft(secondaryTestBreakpoint), const Offset(200, 10));
    expect(tester.getBottomRight(secondaryTestBreakpoint),
        const Offset(390, 1990));
  });

  testWidgets('adaptive layout correct layout when body vertical',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        await layout(width: 400, tester: tester, orientation: Axis.vertical));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(topNavigation), Offset.zero);
    expect(tester.getTopLeft(secondaryNavigation), const Offset(390, 10));
    expect(tester.getTopLeft(primaryNavigation), const Offset(0, 10));
    expect(tester.getTopLeft(bottomNavigation), const Offset(0, 1990));
    expect(tester.getTopLeft(testBreakpoint), const Offset(10, 10));
    expect(tester.getBottomRight(testBreakpoint), const Offset(390, 1000));
    expect(tester.getTopLeft(secondaryTestBreakpoint), const Offset(10, 1000));
    expect(tester.getBottomRight(secondaryTestBreakpoint),
        const Offset(390, 1990));
  });

  testWidgets('adaptive layout correct layout when rtl',
      (WidgetTester tester) async {
    await tester.pumpWidget(await layout(
        width: 400, tester: tester, directionality: TextDirection.rtl));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(topNavigation), Offset.zero);
    expect(tester.getTopLeft(secondaryNavigation), const Offset(0, 10));
    expect(tester.getTopLeft(primaryNavigation), const Offset(390, 10));
    expect(tester.getTopLeft(bottomNavigation), const Offset(0, 1990));
    expect(tester.getTopLeft(testBreakpoint), const Offset(200, 10));
    expect(tester.getBottomRight(testBreakpoint), const Offset(390, 1990));
    expect(tester.getTopLeft(secondaryTestBreakpoint), const Offset(10, 10));
    expect(tester.getBottomRight(secondaryTestBreakpoint),
        const Offset(200, 1990));
  });

  testWidgets('adaptive layout correct layout when body ratio not default',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(await layout(width: 400, tester: tester, bodyRatio: 1 / 3));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(topNavigation), Offset.zero);
    expect(tester.getTopLeft(secondaryNavigation), const Offset(390, 10));
    expect(tester.getTopLeft(primaryNavigation), const Offset(0, 10));
    expect(tester.getTopLeft(bottomNavigation), const Offset(0, 1990));
    expect(tester.getTopLeft(testBreakpoint), const Offset(10, 10));
    expect(tester.getBottomRight(testBreakpoint),
        offsetMoreOrLessEquals(const Offset(136.7, 1990), epsilon: 1.0));
    expect(tester.getTopLeft(secondaryTestBreakpoint),
        offsetMoreOrLessEquals(const Offset(136.7, 10), epsilon: 1.0));
    expect(tester.getBottomRight(secondaryTestBreakpoint),
        const Offset(390, 1990));
  });

  final Finder begin = find.byKey(const Key('0'));
  final Finder end = find.byKey(const Key('400'));
  final Finder large = find.byKey(const Key('1200'));
  final Finder extraLarge = find.byKey(const Key('1600'));

  Finder slideIn(String key) => find.byKey(Key('in-${Key(key)}'));
  Finder slideOut(String key) => find.byKey(Key('out-${Key(key)}'));

  testWidgets(
      'slot layout properly switches between items with the appropriate animation',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(slot(300, const Duration(milliseconds: 1000), tester));
    expect(begin, findsOneWidget);
    expect(end, findsNothing);

    await tester
        .pumpWidget(slot(500, const Duration(milliseconds: 1000), tester));
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

    await tester
        .pumpWidget(slot(1300, const Duration(milliseconds: 1000), tester));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.widget<SlideTransition>(slideOut('400')).position.value,
        const Offset(-0.5, 0));
    expect(tester.widget<SlideTransition>(slideIn('1200')).position.value,
        const Offset(-0.5, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.widget<SlideTransition>(slideOut('400')).position.value,
        const Offset(-1.0, 0));
    expect(tester.widget<SlideTransition>(slideIn('1200')).position.value,
        Offset.zero);

    await tester.pumpAndSettle();
    expect(end, findsNothing);
    expect(large, findsOneWidget);

    await tester
        .pumpWidget(slot(1700, const Duration(milliseconds: 1000), tester));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.widget<SlideTransition>(slideOut('1200')).position.value,
        const Offset(-0.5, 0));
    expect(tester.widget<SlideTransition>(slideIn('1600')).position.value,
        const Offset(-0.5, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.widget<SlideTransition>(slideOut('1200')).position.value,
        const Offset(-1.0, 0));
    expect(tester.widget<SlideTransition>(slideIn('1600')).position.value,
        Offset.zero);

    await tester.pumpAndSettle();
    expect(large, findsNothing);
    expect(extraLarge, findsOneWidget);
  });

  testWidgets('AnimatedSwitcher does not spawn duplicate keys on rapid resize',
      (WidgetTester tester) async {
    // Populate the smaller slot layout and let the animation settle.
    await tester.pumpWidget(slot(300, const Duration(seconds: 1), tester));
    await tester.pumpAndSettle();
    expect(begin, findsOneWidget);
    expect(end, findsNothing);

    // Jumping back between two layouts before allowing an animation to complete.
    // Produces a chain of widgets in AnimatedSwitcher that includes duplicate
    // widgets with the same global key.
    for (int i = 0; i < 2; i++) {
      // Resize between the two slot layouts, but do not pump the animation
      // until completion.
      await tester.pumpWidget(slot(500, const Duration(seconds: 1), tester));
      await tester.pump(const Duration(milliseconds: 100));
      expect(begin, findsOneWidget);
      expect(end, findsOneWidget);

      await tester.pumpWidget(slot(300, const Duration(seconds: 1), tester));
      await tester.pump(const Duration(milliseconds: 100));
      expect(begin, findsOneWidget);
      expect(end, findsOneWidget);
    }
  });

  testWidgets('slot layout can tolerate rapid changes in breakpoints',
      (WidgetTester tester) async {
    await tester.pumpWidget(slot(300, const Duration(seconds: 1), tester));
    expect(begin, findsOneWidget);
    expect(end, findsNothing);

    await tester.pumpWidget(slot(500, const Duration(seconds: 1), tester));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<SlideTransition>(slideOut('0')).position.value,
        offsetMoreOrLessEquals(const Offset(-0.1, 0), epsilon: 0.05));
    expect(tester.widget<SlideTransition>(slideIn('400')).position.value,
        offsetMoreOrLessEquals(const Offset(-0.9, 0), epsilon: 0.05));
    await tester.pumpWidget(slot(300, const Duration(seconds: 1), tester));
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
        offsetMoreOrLessEquals(const Offset(395.8, 1999), epsilon: 1.0));
    expect(tester.getTopLeft(secondaryTestBreakpoint),
        offsetMoreOrLessEquals(const Offset(395.8, 1.0), epsilon: 1.0));
    expect(tester.getBottomRight(secondaryTestBreakpoint),
        offsetMoreOrLessEquals(const Offset(594.8, 1999.0), epsilon: 1.0));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.getTopLeft(testBreakpoint), const Offset(5, 5));
    expect(tester.getBottomRight(testBreakpoint),
        offsetMoreOrLessEquals(const Offset(294.2, 1995), epsilon: 1.0));
    expect(tester.getTopLeft(secondaryTestBreakpoint),
        offsetMoreOrLessEquals(const Offset(294.2, 5.0), epsilon: 1.0));
    expect(tester.getBottomRight(secondaryTestBreakpoint),
        offsetMoreOrLessEquals(const Offset(489.2, 1995.0), epsilon: 1.0));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.getTopLeft(testBreakpoint), const Offset(9, 9));
    expect(tester.getBottomRight(testBreakpoint),
        offsetMoreOrLessEquals(const Offset(201.7, 1991), epsilon: 1.0));
    expect(tester.getTopLeft(secondaryTestBreakpoint),
        offsetMoreOrLessEquals(const Offset(201.7, 9.0), epsilon: 1.0));
    expect(tester.getBottomRight(secondaryTestBreakpoint),
        offsetMoreOrLessEquals(const Offset(392.7, 1991), epsilon: 1.0));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getTopLeft(testBreakpoint), const Offset(10, 10));
    expect(tester.getBottomRight(testBreakpoint), const Offset(200, 1990));
    expect(tester.getTopLeft(secondaryTestBreakpoint), const Offset(200, 10));
    expect(tester.getBottomRight(secondaryTestBreakpoint),
        const Offset(390, 1990));
  });

  testWidgets('adaptive layout can adjust animation duration',
      (WidgetTester tester) async {
    // Populate the smaller slot layout and let the animation settle.
    await tester
        .pumpWidget(slot(300, const Duration(milliseconds: 100), tester));
    await tester.pumpAndSettle();
    expect(begin, findsOneWidget);
    expect(end, findsNothing);

    // expand in 1/5 second.
    await tester
        .pumpWidget(slot(500, const Duration(milliseconds: 200), tester));

    // after 100ms, we expect both widgets to be present.
    await tester.pump(const Duration(milliseconds: 50));
    expect(begin, findsOneWidget);
    expect(end, findsOneWidget);

    // After 1/5 second, all animations should be done.
    await tester.pump(const Duration(milliseconds: 200));
    expect(begin, findsNothing);
    expect(end, findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('adaptive layout does not animate when animations off',
      (WidgetTester tester) async {
    final Finder testBreakpoint = find.byKey(const Key('Test Breakpoint'));

    await tester.pumpWidget(
        await layout(width: 400, tester: tester, animations: false));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getTopLeft(testBreakpoint), const Offset(10, 10));
    expect(tester.getBottomRight(testBreakpoint), const Offset(200, 1990));

    await tester.pumpWidget(
        await layout(width: 800, tester: tester, animations: false));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getTopLeft(testBreakpoint400), const Offset(10, 10));
    expect(tester.getBottomRight(testBreakpoint400), const Offset(400, 1990));

    await tester.pumpWidget(
        await layout(width: 1000, tester: tester, animations: false));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getTopLeft(testBreakpoint800), const Offset(10, 10));
    expect(tester.getBottomRight(testBreakpoint800), const Offset(500, 1990));

    await tester.pumpWidget(
        await layout(width: 1300, tester: tester, animations: false));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getTopLeft(testBreakpoint1200), const Offset(10, 10));
    expect(tester.getBottomRight(testBreakpoint1200), const Offset(650, 1990));

    await tester.pumpWidget(
        await layout(width: 1700, tester: tester, animations: false));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getTopLeft(testBreakpoint1600), const Offset(10, 10));
    expect(tester.getBottomRight(testBreakpoint1600), const Offset(850, 1990));
  });

  testWidgets(
      'adaptive layout handles internal animations correctly for additional breakpoints',
      (WidgetTester tester) async {
    await tester.pumpWidget(await layout(width: 800, tester: tester));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getTopLeft(testBreakpoint400), const Offset(1, 1));
    expect(tester.getBottomRight(testBreakpoint400),
        offsetMoreOrLessEquals(const Offset(792.6, 1999), epsilon: 1.0));
    expect(tester.getTopLeft(secondaryTestBreakpoint400),
        offsetMoreOrLessEquals(const Offset(792.6, 1.0), epsilon: 1.0));
    expect(tester.getBottomRight(secondaryTestBreakpoint400),
        offsetMoreOrLessEquals(const Offset(1191.6, 1999.0), epsilon: 1.0));

    await tester.pumpWidget(await layout(width: 1000, tester: tester));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.getTopLeft(testBreakpoint800), const Offset(10, 10));
    expect(tester.getBottomRight(testBreakpoint800),
        offsetMoreOrLessEquals(const Offset(855.3, 1990.0), epsilon: 1.0));
    expect(tester.getTopLeft(secondaryTestBreakpoint800),
        offsetMoreOrLessEquals(const Offset(855.3, 10.0), epsilon: 1.0));
    expect(tester.getBottomRight(secondaryTestBreakpoint800),
        offsetMoreOrLessEquals(const Offset(1345.3, 1990.0), epsilon: 1.0));

    await tester.pumpWidget(await layout(width: 1300, tester: tester));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.getTopLeft(testBreakpoint1200), const Offset(10, 10));
    expect(tester.getBottomRight(testBreakpoint1200),
        offsetMoreOrLessEquals(const Offset(1114.0, 1990.0), epsilon: 1.0));
    expect(tester.getTopLeft(secondaryTestBreakpoint1200),
        offsetMoreOrLessEquals(const Offset(1114.0, 10.0), epsilon: 1.0));
    expect(tester.getBottomRight(secondaryTestBreakpoint1200),
        offsetMoreOrLessEquals(const Offset(1754.0, 1990.0), epsilon: 1.0));

    await tester.pumpWidget(await layout(width: 1700, tester: tester));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.getTopLeft(testBreakpoint1600), const Offset(10, 10));
    expect(tester.getBottomRight(testBreakpoint1600),
        offsetMoreOrLessEquals(const Offset(1459.1, 1990.0), epsilon: 1.0));
    expect(tester.getTopLeft(secondaryTestBreakpoint1600),
        offsetMoreOrLessEquals(const Offset(1459.1, 10.0), epsilon: 1.0));
    expect(tester.getBottomRight(secondaryTestBreakpoint1600),
        offsetMoreOrLessEquals(const Offset(2299.1, 1990.0), epsilon: 1.0));
  });
}

class TestBreakpoint0 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 0;
  }
}

class TestBreakpoint400 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.sizeOf(context).width > 400;
  }
}

class TestBreakpoint800 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.sizeOf(context).width > 800;
  }
}

class TestBreakpoint1200 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.sizeOf(context).width > 1200;
  }
}

class TestBreakpoint1600 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.sizeOf(context).width > 1600;
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
final Finder testBreakpoint400 = find.byKey(const Key('Test Breakpoint 400'));
final Finder testBreakpoint800 = find.byKey(const Key('Test Breakpoint 800'));
final Finder testBreakpoint1200 = find.byKey(const Key('Test Breakpoint 1200'));
final Finder testBreakpoint1600 = find.byKey(const Key('Test Breakpoint 1600'));

final Finder secondaryTestBreakpoint =
    find.byKey(const Key('Secondary Test Breakpoint'));
final Finder secondaryTestBreakpoint400 =
    find.byKey(const Key('Secondary Test Breakpoint 400'));
final Finder secondaryTestBreakpoint800 =
    find.byKey(const Key('Secondary Test Breakpoint 800'));
final Finder secondaryTestBreakpoint1200 =
    find.byKey(const Key('Secondary Test Breakpoint 1200'));
final Finder secondaryTestBreakpoint1600 =
    find.byKey(const Key('Secondary Test Breakpoint 1600'));

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
  int durationMs = 1000,
}) async {
  await tester.binding.setSurfaceSize(Size(width, 2000));
  return MediaQuery(
    data: MediaQueryData(size: Size(width, 2000)),
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
                key: const Key('Primary Navigation MediumLarge'), builder: on),
            TestBreakpoint1200(): SlotLayout.from(
                key: const Key('Primary Navigation Large'), builder: on),
            TestBreakpoint1600(): SlotLayout.from(
                key: const Key('Primary Navigation ExtraLarge'), builder: on),
          },
        ),
        secondaryNavigation: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            TestBreakpoint0(): SlotLayout.from(
                key: const Key('Secondary Navigation Small'), builder: on),
            TestBreakpoint400(): SlotLayout.from(
                key: const Key('Secondary Navigation Medium'), builder: on),
            TestBreakpoint800(): SlotLayout.from(
                key: const Key('Secondary Navigation MediumLarge'),
                builder: on),
            TestBreakpoint1200(): SlotLayout.from(
                key: const Key('Secondary Navigation Large'), builder: on),
            TestBreakpoint1600(): SlotLayout.from(
                key: const Key('Secondary Navigation ExtraLarge'), builder: on),
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
            TestBreakpoint1200():
                SlotLayout.from(key: const Key('Top Navigation3'), builder: on),
            TestBreakpoint1600():
                SlotLayout.from(key: const Key('Top Navigation4'), builder: on),
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
            TestBreakpoint1200():
                SlotLayout.from(key: const Key('bnav3'), builder: on),
            TestBreakpoint1600():
                SlotLayout.from(key: const Key('bnav4'), builder: on),
          },
        ),
        body: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            TestBreakpoint0(): SlotLayout.from(
              key: const Key('Test Breakpoint'),
              builder: (_) => Container(color: Colors.red),
            ),
            TestBreakpoint400(): SlotLayout.from(
              key: const Key('Test Breakpoint 400'),
              builder: (_) => Container(color: Colors.red),
            ),
            TestBreakpoint800(): SlotLayout.from(
              key: const Key('Test Breakpoint 800'),
              builder: (_) => Container(color: Colors.red),
            ),
            TestBreakpoint1200(): SlotLayout.from(
              key: const Key('Test Breakpoint 1200'),
              builder: (_) => Container(color: Colors.red),
            ),
            TestBreakpoint1600(): SlotLayout.from(
              key: const Key('Test Breakpoint 1600'),
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
              key: const Key('Secondary Test Breakpoint 400'),
              builder: (_) => Container(color: Colors.blue),
            ),
            TestBreakpoint800(): SlotLayout.from(
              key: const Key('Secondary Test Breakpoint 800'),
              builder: (_) => Container(color: Colors.blue),
            ),
            TestBreakpoint1200(): SlotLayout.from(
              key: const Key('Secondary Test Breakpoint 1200'),
              builder: (_) => Container(color: Colors.blue),
            ),
            TestBreakpoint1600(): SlotLayout.from(
              key: const Key('Secondary Test Breakpoint 1600'),
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

MediaQuery slot(double width, Duration duration, WidgetTester tester) {
  return MediaQuery(
    data:
        MediaQueryData.fromView(tester.view).copyWith(size: Size(width, 2000)),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: SlotLayout(
        config: <Breakpoint, SlotLayoutConfig>{
          TestBreakpoint0(): SlotLayout.from(
            inAnimation: leftOutIn,
            outAnimation: leftInOut,
            inDuration: duration,
            key: const Key('0'),
            builder: (_) => const SizedBox(width: 10, height: 10),
          ),
          TestBreakpoint400(): SlotLayout.from(
            inAnimation: leftOutIn,
            outAnimation: leftInOut,
            inDuration: duration,
            key: const Key('400'),
            builder: (_) => const SizedBox(width: 10, height: 10),
          ),
          TestBreakpoint800(): SlotLayout.from(
            inAnimation: leftOutIn,
            outAnimation: leftInOut,
            inDuration: duration,
            key: const Key('800'),
            builder: (_) => const SizedBox(width: 10, height: 10),
          ),
          TestBreakpoint1200(): SlotLayout.from(
            inAnimation: leftOutIn,
            outAnimation: leftInOut,
            inDuration: duration,
            key: const Key('1200'),
            builder: (_) => const SizedBox(width: 10, height: 10),
          ),
          TestBreakpoint1600(): SlotLayout.from(
            inAnimation: leftOutIn,
            outAnimation: leftInOut,
            inDuration: duration,
            key: const Key('1600'),
            builder: (_) => const SizedBox(width: 10, height: 10),
          ),
        },
      ),
    ),
  );
}
