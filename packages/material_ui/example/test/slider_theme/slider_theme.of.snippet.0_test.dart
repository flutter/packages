// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/slider_theme/slider_theme.of.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'Launch copies ambient SliderThemeData with custom activeTrackColor',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            sliderTheme: const SliderThemeData(
              inactiveTrackColor: Color(0xff206040),
            ),
          ),
          home: const Scaffold(body: Center(child: example.Launch())),
        ),
      );

      expect(tester.widget<Slider>(find.byType(Slider)).value, 0.0);

      await tester.tap(find.byType(Slider));
      await tester.pumpAndSettle();

      expect(tester.widget<Slider>(find.byType(Slider)).value, 0.5);
      final MaterialInkController material = Material.of(
        tester.element(find.byType(Slider)),
      );
      expect(
        material,
        paints
          ..rrect(color: const Color(0xff206040))
          ..rrect(color: const Color(0xff804040)),
      );
    },
  );
}
