// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
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

  group('Landscape Layout Tests', () {
    testWidgets('Desktop breakpoints do not show on mobile device (landscape)',
        (WidgetTester tester) async {
      // Small landscape layout on a mobile device.
      await tester.pumpWidget(SimulatedLayout.smallLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.smallMobile')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.smallDesktop')), findsNothing);

      // Medium landscape layout on a mobile.
      await tester.pumpWidget(SimulatedLayout.mediumLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.mediumMobile')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.mediumDesktop')), findsNothing);

      // MediumLarge landscape layout on a mobile.
      await tester
          .pumpWidget(SimulatedLayout.mediumLargeLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.mediumLargeMobile')),
          findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.mediumLargeDesktop')),
          findsNothing);

      // Large landscape layout on a mobile.
      await tester.pumpWidget(SimulatedLayout.largeLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.largeMobile')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.largeDesktop')), findsNothing);

      // ExtraLarge landscape layout on a mobile.
      await tester.pumpWidget(SimulatedLayout.extraLargeLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.extraLargeMobile')),
          findsOneWidget);
      expect(
          find.byKey(const Key('Breakpoints.extraLargeDesktop')), findsNothing);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('Mobile breakpoints do not show on desktop device (landscape)',
        (WidgetTester tester) async {
      // Small landscape layout on a desktop device.
      await tester.pumpWidget(SimulatedLayout.smallLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.smallDesktop')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.smallMobile')), findsNothing);

      // Medium landscape layout on a desktop.
      await tester.pumpWidget(SimulatedLayout.mediumLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(
          find.byKey(const Key('Breakpoints.mediumDesktop')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.mediumMobile')), findsNothing);

      // MediumLarge landscape layout on a desktop.
      await tester
          .pumpWidget(SimulatedLayout.mediumLargeLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.mediumLargeDesktop')),
          findsOneWidget);
      expect(
          find.byKey(const Key('Breakpoints.mediumLargeMobile')), findsNothing);

      // Large landscape layout on a desktop.
      await tester.pumpWidget(SimulatedLayout.largeLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.largeDesktop')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.largeMobile')), findsNothing);

      await tester.pumpWidget(SimulatedLayout.extraLargeLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.extraLargeDesktop')),
          findsOneWidget);
      expect(
          find.byKey(const Key('Breakpoints.extraLargeMobile')), findsNothing);
    }, variant: TargetPlatformVariant.desktop());

    // Additional landscape tests for `maybeActiveBreakpointFromSlotLayout`.
    testWidgets(
        'maybeActiveBreakpointFromSlotLayout returns correct breakpoint on mobile (landscape)',
        (WidgetTester tester) async {
      // Small landscape layout on mobile.
      await tester.pumpWidget(SimulatedLayout.smallLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.maybeActiveBreakpointFromSlotLayout(
              tester.element(find.byKey(const Key('Breakpoints.smallMobile')))),
          Breakpoints.smallMobile);

      // Medium landscape layout on mobile.
      await tester.pumpWidget(SimulatedLayout.mediumLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.maybeActiveBreakpointFromSlotLayout(tester
              .element(find.byKey(const Key('Breakpoints.mediumMobile')))),
          Breakpoints.mediumMobile);

      // Large landscape layout on mobile.
      await tester.pumpWidget(SimulatedLayout.largeLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.maybeActiveBreakpointFromSlotLayout(
              tester.element(find.byKey(const Key('Breakpoints.largeMobile')))),
          Breakpoints.largeMobile);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets(
        'maybeActiveBreakpointFromSlotLayout returns correct breakpoint on desktop (landscape)',
        (WidgetTester tester) async {
      // Small landscape layout on desktop.
      await tester.pumpWidget(SimulatedLayout.smallLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.maybeActiveBreakpointFromSlotLayout(tester
              .element(find.byKey(const Key('Breakpoints.smallDesktop')))),
          Breakpoints.smallDesktop);

      // Medium landscape layout on desktop.
      await tester.pumpWidget(SimulatedLayout.mediumLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.maybeActiveBreakpointFromSlotLayout(tester
              .element(find.byKey(const Key('Breakpoints.mediumDesktop')))),
          Breakpoints.mediumDesktop);

      // Large landscape layout on desktop.
      await tester.pumpWidget(SimulatedLayout.largeLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.maybeActiveBreakpointFromSlotLayout(tester
              .element(find.byKey(const Key('Breakpoints.largeDesktop')))),
          Breakpoints.largeDesktop);
    }, variant: TargetPlatformVariant.desktop());

    // Additional landscape tests for `defaultBreakpointOf`.
    testWidgets(
        'defaultBreakpointOf returns correct default breakpoint on mobile (landscape)',
        (WidgetTester tester) async {
      // Small landscape layout on mobile.
      await tester.pumpWidget(SimulatedLayout.smallLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(Breakpoint.defaultBreakpointOf(tester.element(find.byType(Theme))),
          Breakpoints.smallMobile);

      // Medium landscape layout on mobile.
      await tester.pumpWidget(SimulatedLayout.mediumLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(Breakpoint.defaultBreakpointOf(tester.element(find.byType(Theme))),
          Breakpoints.mediumMobile);

      // Large landscape layout on mobile.
      await tester.pumpWidget(SimulatedLayout.largeLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(Breakpoint.defaultBreakpointOf(tester.element(find.byType(Theme))),
          Breakpoints.largeMobile);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets(
        'defaultBreakpointOf returns correct default breakpoint on desktop (landscape)',
        (WidgetTester tester) async {
      // Small landscape layout on desktop.
      await tester.pumpWidget(SimulatedLayout.smallLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.defaultBreakpointOf(
              tester.element(find.byType(Directionality))),
          Breakpoints.smallDesktop);

      // Medium landscape layout on desktop.
      await tester.pumpWidget(SimulatedLayout.mediumLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.defaultBreakpointOf(
              tester.element(find.byType(Directionality))),
          Breakpoints.mediumDesktop);

      // Large landscape layout on desktop.
      await tester.pumpWidget(SimulatedLayout.largeLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.defaultBreakpointOf(
              tester.element(find.byType(Directionality))),
          Breakpoints.largeDesktop);
    }, variant: TargetPlatformVariant.desktop());

    // Additional landscape tests for `activeBreakpointOf`.
    testWidgets(
        'activeBreakpointOf returns correct active breakpoint on mobile (landscape)',
        (WidgetTester tester) async {
      // Small landscape layout on mobile.
      await tester.pumpWidget(SimulatedLayout.smallLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(
              tester.element(find.byKey(const Key('Breakpoints.smallMobile')))),
          Breakpoints.smallMobile);

      // Medium landscape layout on mobile.
      await tester.pumpWidget(SimulatedLayout.mediumLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
              .element(find.byKey(const Key('Breakpoints.mediumMobile')))),
          Breakpoints.mediumMobile);

      // Large landscape layout on mobile.
      await tester.pumpWidget(SimulatedLayout.largeLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(
              tester.element(find.byKey(const Key('Breakpoints.largeMobile')))),
          Breakpoints.largeMobile);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets(
        'activeBreakpointOf returns correct active breakpoint on desktop (landscape)',
        (WidgetTester tester) async {
      // Small landscape layout on desktop.
      await tester.pumpWidget(SimulatedLayout.smallLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
              .element(find.byKey(const Key('Breakpoints.smallDesktop')))),
          Breakpoints.smallDesktop);

      // Medium landscape layout on desktop.
      await tester.pumpWidget(SimulatedLayout.mediumLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
              .element(find.byKey(const Key('Breakpoints.mediumDesktop')))),
          Breakpoints.mediumDesktop);

      // Large landscape layout on desktop.
      await tester.pumpWidget(SimulatedLayout.largeLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
              .element(find.byKey(const Key('Breakpoints.largeDesktop')))),
          Breakpoints.largeDesktop);
    }, variant: TargetPlatformVariant.desktop());
  });

  group('Portrait and Landscape Mixed Layout Tests', () {
    testWidgets(
        'Layout for smallPortraitMediumLandscape shows correct slot configuration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          SimulatedLayout.smallPortraitMediumLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.smallMobile')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.mediumMobile')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.small')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.smallDesktop')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.medium')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumDesktop')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumLarge')), findsNothing);
      expect(
          find.byKey(const Key('Breakpoints.mediumLargeMobile')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumLargeDesktop')),
          findsNothing);
      expect(find.byKey(const Key('Breakpoints.large')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.largeMobile')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.largeDesktop')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.extraLarge')), findsNothing);
      expect(
          find.byKey(const Key('Breakpoints.extraLargeMobile')), findsNothing);
      expect(
          find.byKey(const Key('Breakpoints.extraLargeDesktop')), findsNothing);
    });

    testWidgets(
        'Layout for smallLandscapeMediumPortrait shows correct slot configuration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          SimulatedLayout.smallLandscapeMediumPortrait.slot(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.smallMobile')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumMobile')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.small')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.smallDesktop')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.medium')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumDesktop')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumLarge')), findsNothing);
      expect(
          find.byKey(const Key('Breakpoints.mediumLargeMobile')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumLargeDesktop')),
          findsNothing);
      expect(find.byKey(const Key('Breakpoints.large')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.largeMobile')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.largeDesktop')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.extraLarge')), findsNothing);
      expect(
          find.byKey(const Key('Breakpoints.extraLargeMobile')), findsNothing);
      expect(
          find.byKey(const Key('Breakpoints.extraLargeDesktop')), findsNothing);
    });

    testWidgets(
        'Layout for smallPortraitMediumLargeLandscape shows correct slot configuration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          SimulatedLayout.smallPortraitMediumLargeLandscape.slot(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.smallMobile')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.largeMobile')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.small')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.smallDesktop')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.medium')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumDesktop')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumLarge')), findsNothing);
      expect(
          find.byKey(const Key('Breakpoints.mediumLargeMobile')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumLargeDesktop')),
          findsNothing);
      expect(find.byKey(const Key('Breakpoints.large')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.largeDesktop')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.extraLarge')), findsNothing);
      expect(
          find.byKey(const Key('Breakpoints.extraLargeMobile')), findsNothing);
      expect(
          find.byKey(const Key('Breakpoints.extraLargeDesktop')), findsNothing);
    });

    testWidgets(
        'Layout for smallLandscapeMediumLargePortrait shows correct slot configuration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          SimulatedLayout.smallLandscapeMediumLargePortrait.slot(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.smallMobile')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.largeMobile')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.small')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.smallDesktop')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.medium')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumDesktop')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumLarge')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumLargeMobile')),
          findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.mediumLargeDesktop')),
          findsNothing);
      expect(find.byKey(const Key('Breakpoints.large')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.largeDesktop')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.extraLarge')), findsNothing);
      expect(
          find.byKey(const Key('Breakpoints.extraLargeMobile')), findsNothing);
      expect(
          find.byKey(const Key('Breakpoints.extraLargeDesktop')), findsNothing);
    });

    testWidgets(
        'Layout for mediumLargeLandscapeMediumPortrait shows correct slot configuration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          SimulatedLayout.mediumLargeLandscapeMediumPortrait.slot(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.smallMobile')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.largeMobile')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.small')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.smallDesktop')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.medium')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumDesktop')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumLarge')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumLargeMobile')),
          findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.mediumLargeDesktop')),
          findsNothing);
      expect(find.byKey(const Key('Breakpoints.large')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.largeDesktop')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.extraLarge')), findsNothing);
      expect(
          find.byKey(const Key('Breakpoints.extraLargeMobile')), findsNothing);
      expect(
          find.byKey(const Key('Breakpoints.extraLargeDesktop')), findsNothing);
    });
  });

  group('Slot And Up Layout Tests', () {
    testWidgets('slotAndUp shows correct slot for small layout',
        (WidgetTester tester) async {
      // Small layout should only show the small slot.
      await tester.pumpWidget(SimulatedLayout.small.slotAndUp(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.small')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.mediumAndUp')), findsNothing);
    });

    testWidgets('slotAndUp shows correct slot for medium layout and up',
        (WidgetTester tester) async {
      // Medium layout should show the mediumAndUp slot.
      await tester.pumpWidget(SimulatedLayout.medium.slotAndUp(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.mediumAndUp')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.small')), findsNothing);

      // MediumLarge layout should also show the mediumAndUp slot.
      await tester.pumpWidget(SimulatedLayout.mediumLarge.slotAndUp(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.mediumAndUp')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.small')), findsNothing);

      // Large layout should also show the mediumAndUp slot.
      await tester.pumpWidget(SimulatedLayout.large.slotAndUp(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.mediumAndUp')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.small')), findsNothing);

      // ExtraLarge layout should also show the mediumAndUp slot.
      await tester.pumpWidget(SimulatedLayout.extraLarge.slotAndUp(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.mediumAndUp')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.small')), findsNothing);
    });

    testWidgets('slotAndUp shows correct slot for small landscape layout',
        (WidgetTester tester) async {
      // Small landscape layout should only show the small slot.
      await tester.pumpWidget(SimulatedLayout.smallLandscape.slotAndUp(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.small')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.mediumAndUp')), findsNothing);
    });

    testWidgets(
        'slotAndUp shows correct slot for medium and larger landscape layouts',
        (WidgetTester tester) async {
      // Medium landscape layout should show the mediumAndUp slot.
      await tester
          .pumpWidget(SimulatedLayout.mediumLandscape.slotAndUp(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.mediumAndUp')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.small')), findsNothing);

      // MediumLarge landscape layout should also show the mediumAndUp slot.
      await tester
          .pumpWidget(SimulatedLayout.mediumLargeLandscape.slotAndUp(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.mediumAndUp')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.small')), findsNothing);

      // Large landscape layout should also show the mediumAndUp slot.
      await tester.pumpWidget(SimulatedLayout.largeLandscape.slotAndUp(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.mediumAndUp')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.small')), findsNothing);

      // ExtraLarge landscape layout should also show the mediumAndUp slot.
      await tester
          .pumpWidget(SimulatedLayout.extraLargeLandscape.slotAndUp(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.mediumAndUp')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.small')), findsNothing);
    });
  });

  group('Slot And Up Layout Tests with Portrait and Landscape Mixed Layout',
      () {
    testWidgets(
        'slotAndUp shows correct slot for smallPortraitMediumLandscape layout',
        (WidgetTester tester) async {
      // smallPortraitMediumLandscape layout should only show the small slot.
      await tester.pumpWidget(
          SimulatedLayout.smallPortraitMediumLandscape.slotAndUp(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.small')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.mediumAndUp')), findsNothing);
    });

    testWidgets(
        'slotAndUp shows correct slot for smallLandscapeMediumPortrait layout',
        (WidgetTester tester) async {
      // smallLandscapeMediumPortrait layout should show the small slot.
      await tester.pumpWidget(
          SimulatedLayout.smallLandscapeMediumPortrait.slotAndUp(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.small')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumAndUp')), findsOneWidget);
    });

    testWidgets(
        'slotAndUp shows correct slot for smallPortraitMediumLargeLandscape layout',
        (WidgetTester tester) async {
      // smallPortraitMediumLargeLandscape layout should show the small slot.
      await tester.pumpWidget(
          SimulatedLayout.smallPortraitMediumLargeLandscape.slotAndUp(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.small')), findsOneWidget);
      expect(find.byKey(const Key('Breakpoints.mediumAndUp')), findsNothing);
    });

    testWidgets(
        'slotAndUp shows correct slot for smallLandscapeMediumLargePortrait layout',
        (WidgetTester tester) async {
      // smallLandscapeMediumLargePortrait layout should show the small slot.
      await tester.pumpWidget(
          SimulatedLayout.smallLandscapeMediumLargePortrait.slotAndUp(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.small')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumAndUp')), findsOneWidget);
    });

    testWidgets(
        'slotAndUp shows correct slot for mediumLargeLandscapeMediumPortrait layout',
        (WidgetTester tester) async {
      // mediumLargeLandscapeMediumPortrait layout should show the mediumAndUp slot.
      await tester.pumpWidget(
          SimulatedLayout.mediumLargeLandscapeMediumPortrait.slotAndUp(tester));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Breakpoints.small')), findsNothing);
      expect(find.byKey(const Key('Breakpoints.mediumAndUp')), findsOneWidget);
    });
  });

  // Test for `spacing`.
  group('spacing property', () {
    testWidgets('returns kMaterialCompactSpacing for small breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.small.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
                  .element(find.byKey(const Key('Breakpoints.smallMobile'))))
              .spacing,
          kMaterialCompactSpacing);
    });

    testWidgets('returns kMaterialMediumAndUpSpacing for medium breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.medium.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
                  .element(find.byKey(const Key('Breakpoints.mediumMobile'))))
              .spacing,
          kMaterialMediumAndUpSpacing);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets(
        'returns kMaterialMediumAndUpSpacing for mediumLarge breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.mediumLarge.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester.element(
                  find.byKey(const Key('Breakpoints.mediumLargeMobile'))))
              .spacing,
          kMaterialMediumAndUpSpacing);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns kMaterialMediumAndUpSpacing for large breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.large.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
                  .element(find.byKey(const Key('Breakpoints.largeMobile'))))
              .spacing,
          kMaterialMediumAndUpSpacing);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns kMaterialMediumAndUpSpacing for extraLarge breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.extraLarge.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester.element(
                  find.byKey(const Key('Breakpoints.extraLargeMobile'))))
              .spacing,
          kMaterialMediumAndUpSpacing);
    }, variant: TargetPlatformVariant.mobile());
  });

  // Test for `margin`.
  group('margin property', () {
    testWidgets('returns kMaterialCompactMargin for small breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.small.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
                  .element(find.byKey(const Key('Breakpoints.smallMobile'))))
              .margin,
          kMaterialCompactMargin);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns kMaterialMediumAndUpMargin for medium breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.medium.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
                  .element(find.byKey(const Key('Breakpoints.mediumMobile'))))
              .margin,
          kMaterialMediumAndUpMargin);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns kMaterialMediumAndUpMargin for mediumLarge breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.mediumLarge.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester.element(
                  find.byKey(const Key('Breakpoints.mediumLargeMobile'))))
              .margin,
          kMaterialMediumAndUpMargin);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns kMaterialMediumAndUpMargin for large breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.large.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
                  .element(find.byKey(const Key('Breakpoints.largeMobile'))))
              .margin,
          kMaterialMediumAndUpMargin);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns kMaterialMediumAndUpMargin for extraLarge breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.extraLarge.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester.element(
                  find.byKey(const Key('Breakpoints.extraLargeMobile'))))
              .margin,
          kMaterialMediumAndUpMargin);
    }, variant: TargetPlatformVariant.mobile());
  });

  // Test for `padding`.
  group('padding property', () {
    testWidgets('returns kMaterialPadding for small breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.small.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
                  .element(find.byKey(const Key('Breakpoints.smallMobile'))))
              .padding,
          kMaterialPadding);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns kMaterialPadding * 2 for medium breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.medium.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
                  .element(find.byKey(const Key('Breakpoints.mediumMobile'))))
              .padding,
          kMaterialPadding * 2);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns kMaterialPadding * 3 for mediumLarge breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.mediumLarge.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester.element(
                  find.byKey(const Key('Breakpoints.mediumLargeMobile'))))
              .padding,
          kMaterialPadding * 3);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns kMaterialPadding * 4 for large breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.large.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
                  .element(find.byKey(const Key('Breakpoints.largeMobile'))))
              .padding,
          kMaterialPadding * 4);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns kMaterialPadding * 5 for extraLarge breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.extraLarge.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester.element(
                  find.byKey(const Key('Breakpoints.extraLargeMobile'))))
              .padding,
          kMaterialPadding * 5);
    }, variant: TargetPlatformVariant.mobile());
  });

  // Test for `recommendedPanes`.
  group('recommendedPanes property', () {
    testWidgets('returns 1 for small breakpoint', (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.small.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
                  .element(find.byKey(const Key('Breakpoints.smallMobile'))))
              .recommendedPanes,
          1);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns 1 for medium breakpoint', (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.medium.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
                  .element(find.byKey(const Key('Breakpoints.mediumMobile'))))
              .recommendedPanes,
          1);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns 2 for mediumLarge breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.mediumLarge.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester.element(
                  find.byKey(const Key('Breakpoints.mediumLargeMobile'))))
              .recommendedPanes,
          2);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns 2 for large breakpoint', (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.large.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
                  .element(find.byKey(const Key('Breakpoints.largeMobile'))))
              .recommendedPanes,
          2);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns 2 for extraLarge breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.extraLarge.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester.element(
                  find.byKey(const Key('Breakpoints.extraLargeMobile'))))
              .recommendedPanes,
          2);
    }, variant: TargetPlatformVariant.mobile());
  });

  // Test for `maxPanes`.
  group('maxPanes property', () {
    testWidgets('returns 1 for small breakpoint', (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.small.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
                  .element(find.byKey(const Key('Breakpoints.smallMobile'))))
              .maxPanes,
          1);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns 2 for medium breakpoint', (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.medium.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
                  .element(find.byKey(const Key('Breakpoints.mediumMobile'))))
              .maxPanes,
          2);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns 2 for mediumLarge breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.mediumLarge.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester.element(
                  find.byKey(const Key('Breakpoints.mediumLargeMobile'))))
              .maxPanes,
          2);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns 2 for large breakpoint', (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.large.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester
                  .element(find.byKey(const Key('Breakpoints.largeMobile'))))
              .maxPanes,
          2);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('returns 3 for extraLarge breakpoint',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.extraLarge.slot(tester));
      await tester.pumpAndSettle();
      expect(
          Breakpoint.activeBreakpointOf(tester.element(
                  find.byKey(const Key('Breakpoints.extraLargeMobile'))))
              .maxPanes,
          3);
    }, variant: TargetPlatformVariant.mobile());
  });

  group('Breakpoint method tests', () {
    testWidgets('isMobile returns true on mobile platforms',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.medium.scaffold(tester));
      await tester.pumpAndSettle();

      expect(Breakpoint.isMobile(tester.element(find.byType(TestScaffold))),
          isTrue);

      expect(Breakpoint.isDesktop(tester.element(find.byType(TestScaffold))),
          isFalse);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('isDesktop returns true on desktop platforms',
        (WidgetTester tester) async {
      await tester.pumpWidget(SimulatedLayout.medium.scaffold(tester));
      await tester.pumpAndSettle();

      expect(Breakpoint.isDesktop(tester.element(find.byType(TestScaffold))),
          isTrue);

      expect(Breakpoint.isMobile(tester.element(find.byType(TestScaffold))),
          isFalse);
    }, variant: TargetPlatformVariant.desktop());

    test('Breakpoint comparison operators work correctly', () {
      const Breakpoint small = Breakpoints.small;
      const Breakpoint medium = Breakpoints.medium;
      const Breakpoint large = Breakpoints.large;

      expect(small < medium, isTrue);
      expect(large > medium, isTrue);
      expect(small <= Breakpoints.small, isTrue);
      expect(large >= medium, isTrue);
    });

    test('Breakpoint equality and hashCode', () {
      const Breakpoint small1 = Breakpoints.small;
      const Breakpoint small2 = Breakpoints.small;
      const Breakpoint medium = Breakpoints.medium;

      expect(small1 == small2, isTrue);
      expect(small1 == medium, isFalse);
      expect(small1.hashCode == small2.hashCode, isTrue);
      expect(small1.hashCode == medium.hashCode, isFalse);
    });

    test('Breakpoint between method works correctly', () {
      const Breakpoint small = Breakpoints.small;
      const Breakpoint medium = Breakpoints.medium;
      const Breakpoint large = Breakpoints.large;

      expect(medium.between(small, large), isTrue);
      expect(small.between(medium, large), isFalse);
      expect(large.between(small, medium), isFalse);
    });
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
