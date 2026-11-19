// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/slider/slider.snippet.0.dart' as example;

void main() {
  testWidgets('Slider onChanged updates rounded value and label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: example.SliderExample())),
      ),
    );

    Slider slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.value, 1.0);
    expect(slider.label, '1');

    await tester.tap(find.byType(Slider));
    await tester.pumpAndSettle();

    slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.value, 6.0);
    expect(slider.label, '6');
  });
}
