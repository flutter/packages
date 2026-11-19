// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/slider/slider.snippet.2.dart' as example;

void main() {
  testWidgets('Slider onChangeEnd prints final value after change', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: example.SliderExample())),
      ),
    );

    await expectLater(
      () => tester.tap(find.byType(Slider)),
      prints('Ended change on 5.5\n'),
    );
    await tester.pumpAndSettle();

    expect(tester.widget<Slider>(find.byType(Slider)).value, 6.0);
  });
}
