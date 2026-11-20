// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/material_state/material_state_mixin.update_material_state.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'MyWidget updates pressed color and invokes onPressed via updateMaterialState',
    (WidgetTester tester) async {
      int pressCount = 0;
      await tester.pumpWidget(
        example.ExampleApp(onPressed: () => pressCount++),
      );

      Finder coloredBoxFinder() => find
          .descendant(
            of: find.byType(example.MyWidget),
            matching: find.byType(ColoredBox),
          )
          .first;

      expect(tester.widget<ColoredBox>(coloredBoxFinder()).color, Colors.white);
      expect(pressCount, 0);

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(example.MyWidget)),
      );
      await tester.pump();

      expect(tester.widget<ColoredBox>(coloredBoxFinder()).color, Colors.black);
      expect(pressCount, 1);

      await gesture.up();
      await tester.pumpAndSettle();

      expect(tester.widget<ColoredBox>(coloredBoxFinder()).color, Colors.white);
      expect(pressCount, 1);
    },
  );
}
