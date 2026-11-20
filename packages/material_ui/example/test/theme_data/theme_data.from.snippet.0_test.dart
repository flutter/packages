// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/theme_data/theme_data.from.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'MaterialApp uses baseline ColorScheme.light and ColorScheme.dark themes',
    (WidgetTester tester) async {
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpWidget(const example.ExampleApp());

      ThemeData currentTheme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(currentTheme.brightness, Brightness.light);
      expect(currentTheme.colorScheme, const ColorScheme.light());
      expect(
        currentTheme.scaffoldBackgroundColor,
        const ColorScheme.light().surface,
      );

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();

      currentTheme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(currentTheme.brightness, Brightness.dark);
      expect(currentTheme.colorScheme, const ColorScheme.dark());
      expect(
        currentTheme.scaffoldBackgroundColor,
        const ColorScheme.dark().surface,
      );
    },
  );
}
