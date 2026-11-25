// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/range_slider/range_slider.on_change_end.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'RangeSlider onChangeEnd prints once at the end of a drag interaction',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: example.RangeSliderExample())),
        ),
      );

      final Rect sliderRect = tester.getRect(find.byType(RangeSlider));
      final Offset trackStart = sliderRect.centerLeft.translate(24, 0);
      final double trackWidth = sliderRect.width - 48;
      final Offset startThumb = trackStart.translate(trackWidth / 3, 0);

      late TestGesture gesture;
      await expectLater(() async {
        gesture = await tester.startGesture(startThumb);
        await tester.pump(kPressTimeout);
        await gesture.moveTo(trackStart.translate(trackWidth / 6, 0));
        await tester.pump();
        // Values update during drag via onChanged, before onChangeEnd is called.
        expect(
          tester.widget<RangeSlider>(find.byType(RangeSlider)).values.start,
          lessThan(4.0),
        );
        await gesture.moveTo(trackStart);
        await tester.pump();
      }, prints(isEmpty));

      await expectLater(
        () => gesture.up(),
        prints('Ended change at RangeValues(1.0, 8.0)\n'),
      );
      await tester.pumpAndSettle();

      expect(
        tester.widget<RangeSlider>(find.byType(RangeSlider)).values,
        const RangeValues(1.0, 8.0),
      );
    },
  );
}
