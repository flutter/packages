// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/loading_indicator/loading_indicator.0.dart'
    as example;

void main() {
  testWidgets('Shows indeterminate and determinate loading indicators', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.LoadingIndicatorExampleApp());

    expect(find.text('Loading Indicator Sample'), findsOne);
    expect(find.text('Indeterminate'), findsOne);
    expect(find.text('Determinate'), findsOne);

    final Iterable<LoadingIndicator> indicators = tester
        .widgetList<LoadingIndicator>(find.byType(LoadingIndicator));
    expect(indicators, hasLength(4));
    expect(
      indicators.map((LoadingIndicator indicator) => indicator.value),
      <double?>[null, null, 0.5, 0.5],
    );
  });

  testWidgets('The slider drives the determinate loading indicators', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.LoadingIndicatorExampleApp());

    final Finder slider = find.byType(Slider);
    final Rect sliderRect = tester.getRect(slider);
    await tester.tapAt(sliderRect.centerRight - const Offset(1, 0));
    await tester.pump();

    final Iterable<LoadingIndicator> determinate = tester
        .widgetList<LoadingIndicator>(find.byType(LoadingIndicator))
        .where((LoadingIndicator indicator) => indicator.value != null);
    expect(determinate, hasLength(2));
    for (final indicator in determinate) {
      expect(indicator.value, tester.widget<Slider>(slider).value);
      expect(indicator.value, greaterThan(0.9));
    }
  });
}
