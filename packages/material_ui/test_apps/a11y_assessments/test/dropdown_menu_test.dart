// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:a11y_assessments/use_cases/dropdown_menu.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_utils.dart';

double _contrastRatio(Color a, Color b) {
  final double lumA = a.computeLuminance();
  final double lumB = b.computeLuminance();
  return (math.max(lumA, lumB) + 0.05) / (math.min(lumA, lumB) + 0.05);
}

void main() {
  testWidgets('dropdown menu can run', (WidgetTester tester) async {
    await pumpsUseCase(tester, DropdownMenuUseCase());
    expect(find.byType(DropdownMenu<String>), findsExactly(2));

    // Test the enabled dropdown menu
    {
      final Finder finder = find.byKey(const Key('enabled dropdown menu'));
      await tester.tap(
        find.descendant(of: finder, matching: find.byIcon(Icons.arrow_drop_down)).first,
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(MenuItemButton, 'banana'), findsWidgets);
      await tester.tap(find.widgetWithText(MenuItemButton, 'banana').last, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    // Test the disabled dropdown menu
    {
      final Finder finder = find.byKey(const Key('disabled dropdown menu'));
      final DropdownMenu<String> dropdownMenu = tester.widget<DropdownMenu<String>>(finder);
      expect(dropdownMenu.enabled, isFalse);
    }
  });

  testWidgets('dropdown menu demo page has one h1 tag', (WidgetTester tester) async {
    await pumpsUseCase(tester, DropdownMenuUseCase());
    final Finder findHeadingLevelOnes = find.bySemanticsLabel('DropdownMenu Demo');
    await tester.pumpAndSettle();
    expect(findHeadingLevelOnes, findsOne);
  });

  // Under standard contrast, tertiaryContainer against surfaceContainerLow does
  // not reach a 3:1 contrast ratio. Medium contrast (contrastLevel: 0.5) is
  // required to satisfy WCAG 2.1 Success Criterion 1.4.11 (Non-text Contrast).
  for (final Brightness brightness in Brightness.values) {
    testWidgets('dropdown menu active option has at least 3:1 contrast ratio in '
        'medium contrast ${brightness.name} mode', (WidgetTester tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearAllTestValues);

      await pumpsUseCase(tester, DropdownMenuUseCase());
      await tester.pumpAndSettle();

      final Finder enabledDropdown = find.byKey(const Key('enabled dropdown menu'));
      await tester.tap(
        find.descendant(of: enabledDropdown, matching: find.byIcon(Icons.arrow_drop_down)).first,
      );
      await tester.pumpAndSettle();

      final ColorScheme colorScheme = Theme.of(tester.element(enabledDropdown)).colorScheme;
      final Finder menuPanel = find.byWidgetPredicate(
        (Widget w) => '${w.runtimeType}' == '_MenuPanel',
      );
      final Material menuMaterial = tester.widget<Material>(
        find.descendant(of: menuPanel, matching: find.byType(Material)).first,
      );
      expect(menuMaterial.color, colorScheme.surfaceContainerLow);

      final Finder selectedItem = find.widgetWithText(MenuItemButton, 'apple').last;
      final Material selectedMaterial = tester.widget<Material>(
        find.descendant(of: selectedItem, matching: find.byType(Material)),
      );
      expect(selectedMaterial.color, colorScheme.tertiaryContainer);
      expect(selectedMaterial.textStyle?.color, colorScheme.onTertiaryContainer);

      expect(
        _contrastRatio(selectedMaterial.color!, menuMaterial.color!),
        greaterThanOrEqualTo(3.0),
      );
      expect(
        _contrastRatio(selectedMaterial.textStyle!.color!, selectedMaterial.color!),
        greaterThanOrEqualTo(4.5),
      );
    });
  }
}
