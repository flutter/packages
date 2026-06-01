// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/autocomplete/autocomplete.2.dart'
    as example;

void main() {
  testWidgets(
    'can search and find options after waiting for fake network delay',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.AutocompleteExampleApp());

      expect(find.text('aardvark'), findsNothing);
      expect(find.text('bobcat'), findsNothing);
      expect(find.text('chameleon'), findsNothing);

      await tester.enterText(find.byType(TextFormField), 'a');
      await tester.pump(example.fakeAPIDuration);

      expect(find.text('aardvark'), findsOneWidget);
      expect(find.text('bobcat'), findsOneWidget);
      expect(find.text('chameleon'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'aa');
      await tester.pump(example.fakeAPIDuration);

      expect(find.text('aardvark'), findsOneWidget);
      expect(find.text('bobcat'), findsNothing);
      expect(find.text('chameleon'), findsNothing);
    },
  );
}
