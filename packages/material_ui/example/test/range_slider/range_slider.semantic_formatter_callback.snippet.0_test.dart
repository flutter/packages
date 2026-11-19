// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/range_slider/range_slider.semantic_formatter_callback.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'RangeSlider semanticFormatterCallback formats thumb semantics with currency',
    (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: example.RangeSliderExample())),
        ),
      );

      expect(find.semantics.byValue('100 dollars'), findsOne);
      expect(find.semantics.byValue('250 dollars'), findsOne);

      final Offset trackStart = tester
          .getRect(find.byType(RangeSlider))
          .centerLeft
          .translate(24, 0);
      await tester.tapAt(trackStart);
      await tester.pumpAndSettle();

      expect(find.semantics.byValue('20 dollars'), findsOne);
      expect(find.semantics.byValue('250 dollars'), findsOne);
      handle.dispose();
    },
  );
}
