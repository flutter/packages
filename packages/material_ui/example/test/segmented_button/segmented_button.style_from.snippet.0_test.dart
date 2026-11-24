// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/segmented_button/segmented_button.style_from.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'SegmentedButton.styleFrom applies selected and unselected colors',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.ExampleApp());

      Material getMaterial(String text) {
        return tester.widget<Material>(
          find
              .ancestor(of: find.text(text), matching: find.byType(Material))
              .first,
        );
      }

      expect(getMaterial('0').color, Colors.red);
      expect(getMaterial('0').textStyle?.color, Colors.white);

      expect(getMaterial('1').color, Colors.amber);
      expect(getMaterial('1').textStyle?.color, Colors.black);
    },
  );
}
