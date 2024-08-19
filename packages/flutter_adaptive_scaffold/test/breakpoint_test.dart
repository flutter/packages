// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/src/breakpoints.dart';
import 'package:flutter_test/flutter_test.dart';
import 'simulated_layout.dart';

void main() {
  testWidgets('Desktop breakpoints do not show on mobile device',
      (WidgetTester tester) async {
    // Pump a small layout on a mobile device. The small slot
    // should give the mobile slot layout, not the desktop layout.
    await tester.pumpWidget(SimulatedLayout.small.slot(tester));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('Breakpoints.smallMobile')), findsOneWidget);
    expect(find.byKey(const Key('Breakpoints.smallDesktop')), findsNothing);

    // Do the same with a medium layout on a mobile.
    await tester.pumpWidget(SimulatedLayout.medium.slot(tester));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('Breakpoints.mediumMobile')), findsOneWidget);
    expect(find.byKey(const Key('Breakpoints.mediumDesktop')), findsNothing);

    // Do the same with an mediumLarge layout on a mobile.
    await tester.pumpWidget(SimulatedLayout.mediumLarge.slot(tester));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const Key('Breakpoints.mediumLargeMobile')), findsOneWidget);
    expect(
        find.byKey(const Key('Breakpoints.mediumLargeDesktop')), findsNothing);

    // Do the same with an large layout on a mobile.
    await tester.pumpWidget(SimulatedLayout.large.slot(tester));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('Breakpoints.largeMobile')), findsOneWidget);
    expect(find.byKey(const Key('Breakpoints.largeDesktop')), findsNothing);

    // Do the same with an extraLarge layout on a mobile.
    await tester.pumpWidget(SimulatedLayout.extraLarge.slot(tester));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const Key('Breakpoints.extraLargeMobile')), findsOneWidget);
    expect(
        find.byKey(const Key('Breakpoints.extraLargeDesktop')), findsNothing);
  }, variant: TargetPlatformVariant.mobile());

  testWidgets('Mobile breakpoints do not show on desktop device',
      (WidgetTester tester) async {
    // Pump a small layout on a desktop device. The small slot
    // should give the mobile slot layout, not the desktop layout.
    await tester.pumpWidget(SimulatedLayout.small.slot(tester));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('Breakpoints.smallDesktop')), findsOneWidget);
    expect(find.byKey(const Key('Breakpoints.smallMobile')), findsNothing);

    // Do the same with a medium layout on a desktop
    await tester.pumpWidget(SimulatedLayout.medium.slot(tester));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('Breakpoints.mediumDesktop')), findsOneWidget);
    expect(find.byKey(const Key('Breakpoints.mediumMobile')), findsNothing);

    // Do the same with an mediumLarge layout on a desktop.
    await tester.pumpWidget(SimulatedLayout.mediumLarge.slot(tester));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('Breakpoints.mediumLargeDesktop')),
        findsOneWidget);
    expect(
        find.byKey(const Key('Breakpoints.mediumLargeMobile')), findsNothing);

    // Large layout on desktop
    await tester.pumpWidget(SimulatedLayout.large.slot(tester));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('Breakpoints.largeDesktop')), findsOneWidget);
    expect(find.byKey(const Key('Breakpoints.largeMobile')), findsNothing);

    await tester.pumpWidget(SimulatedLayout.extraLarge.slot(tester));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const Key('Breakpoints.extraLargeDesktop')), findsOneWidget);
    expect(find.byKey(const Key('Breakpoints.extraLargeMobile')), findsNothing);
  }, variant: TargetPlatformVariant.desktop());

  testWidgets('Breakpoint.isActive should not trigger unnecessary rebuilds',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DummyWidget());
    expect(find.byKey(const Key('button')), findsOneWidget);

    // First build.
    expect(DummyWidget.built, isTrue);

    // Invoke `isActive` method.
    await tester.tap(find.byKey(const Key('button')));
    DummyWidget.built = false;

    // Should not rebuild after modifying any property in `MediaQuery`.
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.pumpAndSettle();
    expect(DummyWidget.built, isFalse);
  });

// Test the `maybeActiveBreakpointFromSlotLayout` method.
  group('maybeActiveBreakpointFromSlotLayout', () {
    testWidgets('returns correct breakpoint from SlotLayout on mobile devices',
        (WidgetTester tester) async {
      // Small layout on mobile.
      await tester.pumpWidget(SimulatedLayout.small.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.maybeActiveBreakpointFromSlotLayout(
              tester.element(find.byKey(const Key('Breakpoints.smallMobile')))),
          Breakpoints.smallMobile);

      // Medium layout on mobile.
      await tester.pumpWidget(SimulatedLayout.medium.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.maybeActiveBreakpointFromSlotLayout(tester
              .element(find.byKey(const Key('Breakpoints.mediumMobile')))),
          Breakpoints.mediumMobile);

      // Large layout on mobile.
      await tester.pumpWidget(SimulatedLayout.large.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.maybeActiveBreakpointFromSlotLayout(
              tester.element(find.byKey(const Key('Breakpoints.largeMobile')))),
          Breakpoints.largeMobile);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns correct breakpoint from SlotLayout on desktop devices',
        (WidgetTester tester) async {
      // Small layout on desktop.
      await tester.pumpWidget(SimulatedLayout.small.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.maybeActiveBreakpointFromSlotLayout(tester
              .element(find.byKey(const Key('Breakpoints.smallDesktop')))),
          Breakpoints.smallDesktop);

      // Medium layout on desktop.
      await tester.pumpWidget(SimulatedLayout.medium.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.maybeActiveBreakpointFromSlotLayout(tester
              .element(find.byKey(const Key('Breakpoints.mediumDesktop')))),
          Breakpoints.mediumDesktop);

      // Large layout on desktop.
      await tester.pumpWidget(SimulatedLayout.large.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.maybeActiveBreakpointFromSlotLayout(tester
              .element(find.byKey(const Key('Breakpoints.largeDesktop')))),
          Breakpoints.largeDesktop);
    }, variant: TargetPlatformVariant.desktop());
  });

  // Test the `defaultBreakpointOf` method.
  group('defaultBreakpointOf', () {
    testWidgets('returns correct default breakpoint on mobile devices',
        (WidgetTester tester) async {
      // Small layout on mobile.
      await tester.pumpWidget(SimulatedLayout.small.slot(tester));
      await tester.pumpAndSettle();
      expect(Breakpoint.defaultBreakpointOf(tester.element(find.byType(Theme))),
          Breakpoints.smallMobile);

      // Medium layout on mobile.
      await tester.pumpWidget(SimulatedLayout.medium.slot(tester));
      await tester.pumpAndSettle();
      expect(Breakpoint.defaultBreakpointOf(tester.element(find.byType(Theme))),
          Breakpoints.mediumMobile);

      // Large layout on mobile.
      await tester.pumpWidget(SimulatedLayout.large.slot(tester));
      await tester.pumpAndSettle();
      expect(Breakpoint.defaultBreakpointOf(tester.element(find.byType(Theme))),
          Breakpoints.largeMobile);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns correct default breakpoint on desktop devices',
        (WidgetTester tester) async {
      // Small layout on desktop.
      await tester.pumpWidget(SimulatedLayout.small.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.defaultBreakpointOf(
              tester.element(find.byType(Directionality))),
          Breakpoints.smallDesktop);

      // Medium layout on desktop.
      await tester.pumpWidget(SimulatedLayout.medium.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.defaultBreakpointOf(
              tester.element(find.byType(Directionality))),
          Breakpoints.mediumDesktop);

      // Large layout on desktop.
      await tester.pumpWidget(SimulatedLayout.large.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.defaultBreakpointOf(
              tester.element(find.byType(Directionality))),
          Breakpoints.largeDesktop);
    }, variant: TargetPlatformVariant.desktop());
  });

  // Test the `activeBreakpointOf` method.
  group('activeBreakpointOf', () {
    testWidgets('returns correct active breakpoint on mobile devices',
        (WidgetTester tester) async {
      // Small layout on mobile.
      await tester.pumpWidget(SimulatedLayout.small.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(
              tester.element(find.byKey(const Key('Breakpoints.smallMobile')))),
          Breakpoints.smallMobile);

      // Medium layout on mobile.
      await tester.pumpWidget(SimulatedLayout.medium.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
              .element(find.byKey(const Key('Breakpoints.mediumMobile')))),
          Breakpoints.mediumMobile);

      // Large layout on mobile.
      await tester.pumpWidget(SimulatedLayout.large.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(
              tester.element(find.byKey(const Key('Breakpoints.largeMobile')))),
          Breakpoints.largeMobile);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns correct active breakpoint on desktop devices',
        (WidgetTester tester) async {
      // Small layout on desktop.
      await tester.pumpWidget(SimulatedLayout.small.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
              .element(find.byKey(const Key('Breakpoints.smallDesktop')))),
          Breakpoints.smallDesktop);

      // Medium layout on desktop.
      await tester.pumpWidget(SimulatedLayout.medium.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
              .element(find.byKey(const Key('Breakpoints.mediumDesktop')))),
          Breakpoints.mediumDesktop);

      // Large layout on desktop.
      await tester.pumpWidget(SimulatedLayout.large.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
              .element(find.byKey(const Key('Breakpoints.largeDesktop')))),
          Breakpoints.largeDesktop);
    }, variant: TargetPlatformVariant.desktop());
  });
}

class DummyWidget extends StatelessWidget {
  const DummyWidget({super.key});

  static bool built = false;
  @override
  Widget build(BuildContext context) {
    built = true;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ElevatedButton(
        key: const Key('button'),
        onPressed: () {
          Breakpoints.small.isActive(context);
        },
        child: const SizedBox(),
      ),
    );
  }
}
