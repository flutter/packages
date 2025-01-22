// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_adaptive_scaffold_example/adaptive_layout_demo.dart'
    as example;
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Color navigationRailThemeBgColor = Colors.white;
  const IconThemeData selectedIconThemeData = IconThemeData(
    color: Colors.red,
    size: 32.0,
  );
  const IconThemeData unSelectedIconThemeData = IconThemeData(
    color: Colors.black,
    size: 24.0,
  );
  final Finder body = find.byKey(const Key('Body Small'));
  final Finder bottomNavigation = find.byKey(
    const Key('Bottom Navigation Small'),
  );

  Future<void> updateScreen(double width, WidgetTester tester) async {
    await tester.binding.setSurfaceSize(Size(width, 2000));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light().copyWith(
          navigationRailTheme: const NavigationRailThemeData(
            backgroundColor: navigationRailThemeBgColor,
            selectedIconTheme: selectedIconThemeData,
            unselectedIconTheme: unSelectedIconThemeData,
          ),
        ),
        home: MediaQuery(
          data: MediaQueryData(size: Size(width, 2000)),
          child: const example.MyHomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'displays correct item of config based on screen width',
    (WidgetTester tester) async {
      await updateScreen(300, tester);
      expect(find.byKey(const Key('Body Small')), findsOneWidget);
      expect(find.byKey(const Key('Primary Navigation Medium')), findsNothing);
      expect(find.byKey(const Key('Bottom Navigation Small')), findsOneWidget);
      expect(find.byKey(const Key('Body Medium')), findsNothing);
      expect(find.byKey(const Key('Primary Navigation MediumLarge')),
          findsNothing);
      expect(find.byKey(const Key('Primary Navigation Large')), findsNothing);
      expect(
          find.byKey(const Key('Primary Navigation ExtraLarge')), findsNothing);

      await updateScreen(700, tester);
      expect(find.byKey(const Key('Body Small')), findsNothing);
      expect(find.byKey(const Key('Bottom Navigation Small')), findsNothing);
      expect(find.byKey(const Key('Body Medium')), findsOneWidget);
      expect(
          find.byKey(const Key('Primary Navigation Medium')), findsOneWidget);
      expect(find.byKey(const Key('Primary Navigation MediumLarge')),
          findsNothing);
      expect(find.byKey(const Key('Primary Navigation Large')), findsNothing);
      expect(
          find.byKey(const Key('Primary Navigation ExtraLarge')), findsNothing);

      await updateScreen(860, tester);
      expect(find.byKey(const Key('Body Small')), findsNothing);
      expect(find.byKey(const Key('Bottom Navigation Small')), findsNothing);
      expect(find.byKey(const Key('Body Medium')), findsNothing);
      expect(find.byKey(const Key('Body MediumLarge')), findsOneWidget);
      expect(find.byKey(const Key('Primary Navigation Medium')), findsNothing);
      expect(find.byKey(const Key('Primary Navigation MediumLarge')),
          findsOneWidget);
      expect(find.byKey(const Key('Primary Navigation Large')), findsNothing);
      expect(
          find.byKey(const Key('Primary Navigation ExtraLarge')), findsNothing);

      await updateScreen(1200, tester);
      expect(find.byKey(const Key('Body Small')), findsNothing);
      expect(find.byKey(const Key('Bottom Navigation Small')), findsNothing);
      expect(find.byKey(const Key('Body Medium')), findsNothing);
      expect(find.byKey(const Key('Body MediumLarge')), findsNothing);
      expect(find.byKey(const Key('Body Large')), findsOneWidget);
      expect(find.byKey(const Key('Primary Navigation Medium')), findsNothing);
      expect(find.byKey(const Key('Primary Navigation MediumLarge')),
          findsNothing);
      expect(find.byKey(const Key('Primary Navigation Large')), findsOneWidget);
      expect(
          find.byKey(const Key('Primary Navigation ExtraLarge')), findsNothing);

      await updateScreen(1600, tester);
      expect(find.byKey(const Key('Body Small')), findsNothing);
      expect(find.byKey(const Key('Bottom Navigation Small')), findsNothing);
      expect(find.byKey(const Key('Body Medium')), findsNothing);
      expect(find.byKey(const Key('Body MediumLarge')), findsNothing);
      expect(find.byKey(const Key('Body Large')), findsNothing);
      expect(find.byKey(const Key('Body ExtraLarge')), findsOneWidget);
      expect(find.byKey(const Key('Primary Navigation Medium')), findsNothing);
      expect(find.byKey(const Key('Primary Navigation MediumLarge')),
          findsNothing);
      expect(find.byKey(const Key('Primary Navigation Large')), findsNothing);
      expect(find.byKey(const Key('Primary Navigation ExtraLarge')),
          findsOneWidget);
    },
  );

  testWidgets(
    'adaptive layout bottom navigation displays with correct properties',
    (WidgetTester tester) async {
      await updateScreen(400, tester);
      final BuildContext context = tester.element(find.byType(MaterialApp));

      // Bottom Navigation Bar
      final Finder findKey = find.byKey(const Key('Bottom Navigation Small'));
      final SlotLayoutConfig slotLayoutConfig =
          tester.firstWidget<SlotLayoutConfig>(findKey);
      final WidgetBuilder? widgetBuilder = slotLayoutConfig.builder;
      final Widget Function(BuildContext) widgetFunction =
          (widgetBuilder ?? () => Container()) as Widget Function(BuildContext);
      final Builder builderWidget = widgetFunction(context) as Builder;
      expect(builderWidget, isNotNull);
    },
  );

  testWidgets(
    'adaptive layout navigation rail displays with correct properties',
    (WidgetTester tester) async {
      await updateScreen(620, tester);
      final BuildContext context = tester.element(find.byType(AdaptiveLayout));

      final Finder findKey = find.byKey(const Key('Primary Navigation Medium'));
      final SlotLayoutConfig slotLayoutConfig =
          tester.firstWidget<SlotLayoutConfig>(findKey);
      final WidgetBuilder? widgetBuilder = slotLayoutConfig.builder;
      final Widget Function(BuildContext) widgetFunction =
          (widgetBuilder ?? () => Container()) as Widget Function(BuildContext);
      final SizedBox sizedBox =
          (((widgetFunction(context) as Builder).builder(context) as Padding)
                  .child ??
              () => const SizedBox()) as SizedBox;
      expect(sizedBox.width, 72);
    },
  );

  testWidgets(
    'adaptive layout displays children in correct places',
    (WidgetTester tester) async {
      await updateScreen(400, tester);
      expect(tester.getBottomLeft(bottomNavigation), const Offset(0, 2000));
      expect(tester.getBottomRight(bottomNavigation), const Offset(400, 2000));
      expect(tester.getTopRight(body), const Offset(400, 0));
      expect(tester.getTopLeft(body), Offset.zero);
    },
  );

  testWidgets(
    'adaptive layout does not animate when animations off',
    (WidgetTester tester) async {
      final Finder bodyMedium = find.byKey(const Key('Body Medium'));
      await updateScreen(690, tester);

      expect(tester.getTopLeft(bodyMedium), const Offset(88, 0));
      expect(tester.getBottomRight(bodyMedium), const Offset(690, 2000));
    },
  );

  testWidgets(
    'when view in medium screen, navigation rail must be visible as per theme data values.',
    (WidgetTester tester) async {
      final Finder primaryNavigationMedium = find.byKey(
        const Key('Primary Navigation Medium'),
      );
      await updateScreen(690, tester);
      expect(primaryNavigationMedium, findsOneWidget);

      final Finder navigationRailFinder = find.descendant(
        of: primaryNavigationMedium,
        matching: find.byType(NavigationRail),
      );
      expect(navigationRailFinder, findsOneWidget);

      final NavigationRail navigationRailView = tester.firstWidget(
        navigationRailFinder,
      );
      expect(navigationRailView, isNotNull);
      expect(
        navigationRailView.backgroundColor,
        navigationRailThemeBgColor,
      );
      expect(
        navigationRailView.selectedIconTheme?.size,
        selectedIconThemeData.size,
      );
      expect(
        navigationRailView.selectedIconTheme?.color,
        selectedIconThemeData.color,
      );
      expect(
        navigationRailView.unselectedIconTheme?.size,
        unSelectedIconThemeData.size,
      );
      expect(
        navigationRailView.unselectedIconTheme?.color,
        unSelectedIconThemeData.color,
      );
    },
  );

  testWidgets(
    'when view in medium large screen, navigation rail must be visible as per theme data values.',
    (WidgetTester tester) async {
      final Finder primaryNavigationMediumLarge = find.byKey(
        const Key('Primary Navigation MediumLarge'),
      );
      await updateScreen(860, tester);
      expect(primaryNavigationMediumLarge, findsOneWidget);

      final Finder navigationRailFinder = find.descendant(
        of: primaryNavigationMediumLarge,
        matching: find.byType(NavigationRail),
      );
      expect(navigationRailFinder, findsOneWidget);

      final NavigationRail navigationRailView = tester.firstWidget(
        navigationRailFinder,
      );
      expect(navigationRailView, isNotNull);
      expect(
        navigationRailView.backgroundColor,
        navigationRailThemeBgColor,
      );
      expect(
        navigationRailView.selectedIconTheme?.size,
        selectedIconThemeData.size,
      );
      expect(
        navigationRailView.selectedIconTheme?.color,
        selectedIconThemeData.color,
      );
      expect(
        navigationRailView.unselectedIconTheme?.size,
        unSelectedIconThemeData.size,
      );
      expect(
        navigationRailView.unselectedIconTheme?.color,
        unSelectedIconThemeData.color,
      );
    },
  );

  testWidgets(
    'when view in large screen, navigation rail must be visible as per theme data values.',
    (WidgetTester tester) async {
      final Finder primaryNavigationLarge = find.byKey(
        const Key('Primary Navigation Large'),
      );
      await updateScreen(1200, tester);
      expect(primaryNavigationLarge, findsOneWidget);

      final Finder navigationRailFinder = find.descendant(
        of: primaryNavigationLarge,
        matching: find.byType(NavigationRail),
      );
      expect(navigationRailFinder, findsOneWidget);

      final NavigationRail navigationRailView = tester.firstWidget(
        navigationRailFinder,
      );
      expect(navigationRailView, isNotNull);
      expect(
        navigationRailView.backgroundColor,
        navigationRailThemeBgColor,
      );
      expect(
        navigationRailView.selectedIconTheme?.size,
        selectedIconThemeData.size,
      );
      expect(
        navigationRailView.selectedIconTheme?.color,
        selectedIconThemeData.color,
      );
      expect(
        navigationRailView.unselectedIconTheme?.size,
        unSelectedIconThemeData.size,
      );
      expect(
        navigationRailView.unselectedIconTheme?.color,
        unSelectedIconThemeData.color,
      );
    },
  );

  testWidgets(
    'when view in extraLarge screen, navigation rail must be visible as per theme data values.',
    (WidgetTester tester) async {
      final Finder primaryNavigationExtraLarge = find.byKey(
        const Key('Primary Navigation ExtraLarge'),
      );
      await updateScreen(1600, tester);
      expect(primaryNavigationExtraLarge, findsOneWidget);

      final Finder navigationRailFinder = find.descendant(
        of: primaryNavigationExtraLarge,
        matching: find.byType(NavigationRail),
      );
      expect(navigationRailFinder, findsOneWidget);

      final NavigationRail navigationRailView = tester.firstWidget(
        navigationRailFinder,
      );
      expect(navigationRailView, isNotNull);
      expect(
        navigationRailView.backgroundColor,
        navigationRailThemeBgColor,
      );
      expect(
        navigationRailView.selectedIconTheme?.size,
        selectedIconThemeData.size,
      );
      expect(
        navigationRailView.selectedIconTheme?.color,
        selectedIconThemeData.color,
      );
      expect(
        navigationRailView.unselectedIconTheme?.size,
        unSelectedIconThemeData.size,
      );
      expect(
        navigationRailView.unselectedIconTheme?.color,
        unSelectedIconThemeData.color,
      );
    },
  );
}
