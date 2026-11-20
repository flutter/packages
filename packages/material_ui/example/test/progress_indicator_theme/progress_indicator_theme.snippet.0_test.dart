// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/progress_indicator_theme/progress_indicator_theme.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'ProgressIndicatorTheme applies red color to LinearProgressIndicator',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.ExampleApp());
      await tester.pump(const Duration(milliseconds: 500));

      final Finder indicatorFinder = find.byType(LinearProgressIndicator);
      expect(indicatorFinder, findsOneWidget);

      final ProgressIndicatorThemeData themeData = ProgressIndicatorTheme.of(
        tester.element(indicatorFinder),
      );
      expect(themeData.color, Colors.red);
      expect(
        indicatorFinder,
        paints
          ..rect()
          ..rect(color: Colors.red),
      );
    },
  );
}
