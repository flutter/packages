// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: deprecated_member_use

// These tests intentionally demonstrate the deprecated migration utility.
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/readme_excerpts.dart'
    show LegacyPackageWidget, MyApp, SubtreeExample;

void main() {
  group('README code excerpts', () {
    testWidgets('app-wide compatibility bridge wraps the application', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      final Finder bridge = find.byType(MaterialUiCompatibilityBridge);

      expect(bridge, findsOneWidget);
      expect(
        find.descendant(of: bridge, matching: find.text('Home')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('subtree compatibility bridge wraps legacy widgets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SubtreeExample()));

      final Finder bridge = find.byType(MaterialUiCompatibilityBridge);

      expect(find.text('Modern Screen'), findsOneWidget);
      expect(bridge, findsOneWidget);
      expect(
        find.descendant(of: bridge, matching: find.byType(LegacyPackageWidget)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: bridge, matching: find.text('Modern Screen')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  });
}