// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/slider/slider.on_change_end.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'Slider onChangeEnd prints final value once drag interaction completes',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: example.SliderExample())),
        ),
      );

      final Rect sliderRect = tester.getRect(find.byType(Slider));
      final Offset trackStart = sliderRect.centerLeft.translate(24, 0);

      late TestGesture gesture;
      await expectLater(() async {
        gesture = await tester.startGesture(trackStart);
        await tester.moveByTo(gesture, sliderRect.center);
      }, prints(isEmpty));

      await expectLater(() => gesture.up(), prints('Ended change on 5.5\n'));
      await tester.pumpAndSettle();

      expect(tester.widget<Slider>(find.byType(Slider)).value, 6.0);
    },
  );
}

extension on WidgetTester {
  Future<void> moveByTo(TestGesture gesture, Offset target) async {
    await gesture.moveTo(target);
    await pump();
  }
}
