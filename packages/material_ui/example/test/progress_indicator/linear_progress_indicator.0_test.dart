// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/progress_indicator/linear_progress_indicator.0.dart'
    as example;

void main() {
  testWidgets('Determinate LinearProgressIndicator uses the provided value', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.ProgressIndicatorExampleApp());
    await tester.pump(const Duration(milliseconds: 2500));

    final Finder indicatorFinder = find.byType(LinearProgressIndicator).first;
    final LinearProgressIndicator progressIndicator = tester.widget(
      indicatorFinder,
    );
    expect(progressIndicator.value, equals(0.5));
  });

  testWidgets('Indeterminate LinearProgressIndicator does not have a value', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.ProgressIndicatorExampleApp());
    await tester.pump(const Duration(milliseconds: 2500));

    final Finder indicatorFinder = find.byType(LinearProgressIndicator).last;
    final LinearProgressIndicator progressIndicator = tester.widget(
      indicatorFinder,
    );
    expect(progressIndicator.value, null);
  });

  testWidgets('Progress indicators year2023 flag can be toggled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.ProgressIndicatorExampleApp());

    LinearProgressIndicator determinateIndicator = tester
        .widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator).first,
        );
    // ignore: deprecated_member_use
    expect(determinateIndicator.year2023, true);
    LinearProgressIndicator indeterminateIndicator = tester
        .widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator).last,
        );
    // ignore: deprecated_member_use
    expect(indeterminateIndicator.year2023, true);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    determinateIndicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator).first,
    );
    // ignore: deprecated_member_use
    expect(determinateIndicator.year2023, false);
    indeterminateIndicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator).last,
    );
    // ignore: deprecated_member_use
    expect(indeterminateIndicator.year2023, false);
  });
}
