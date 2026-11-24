// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/range_slider/range_slider.on_changed.snippet.0.dart'
    as example;

void main() {
  testWidgets('RangeSlider onChanged updates selected RangeValues', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: example.RangeSliderExample())),
      ),
    );

    expect(
      tester.widget<RangeSlider>(find.byType(RangeSlider)).values,
      const RangeValues(4.0, 8.0),
    );

    final Offset trackStart = tester
        .getRect(find.byType(RangeSlider))
        .centerLeft
        .translate(24, 0);
    await tester.tapAt(trackStart);
    await tester.pumpAndSettle();

    expect(
      tester.widget<RangeSlider>(find.byType(RangeSlider)).values,
      const RangeValues(1.0, 8.0),
    );
  });
}
