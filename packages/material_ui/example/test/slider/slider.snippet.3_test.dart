// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/slider/slider.snippet.3.dart' as example;

void main() {
  testWidgets(
    'Slider semanticFormatterCallback formats semantics value with currency',
    (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: example.SliderExample())),
        ),
      );

      expect(find.semantics.byValue('20 dollars'), findsOne);

      await tester.tap(find.byType(Slider));
      await tester.pumpAndSettle();

      expect(find.semantics.byValue('175 dollars'), findsOne);
      handle.dispose();
    },
  );
}
