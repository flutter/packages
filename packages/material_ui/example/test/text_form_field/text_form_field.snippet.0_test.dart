// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/text_form_field/text_form_field.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'TextFormField renders InputDecoration and validates against @ character',
    (WidgetTester tester) async {
      final GlobalKey<FormState> formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: const example.TextFormFieldExample(),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('What do people call you?'), findsOneWidget);
      expect(find.text('Name *'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Alice');
      expect(formKey.currentState!.validate(), isTrue);
      await tester.pump();
      expect(find.text('Do not use the @ char.'), findsNothing);
      formKey.currentState!.save();

      await tester.enterText(find.byType(TextFormField), 'alice@example.com');
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Do not use the @ char.'), findsOneWidget);
    },
  );
}
