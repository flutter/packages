// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/text_field/text_field.build_counter.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'TextField.buildCounter displays character count and semantics label',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: example.TextFieldBuildCounterExample()),
        ),
      );

      expect(find.text('0 of 10 characters'), findsOneWidget);
      expect(find.bySemanticsLabel('character count'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();

      expect(find.text('5 of 10 characters'), findsOneWidget);
    },
  );
}
