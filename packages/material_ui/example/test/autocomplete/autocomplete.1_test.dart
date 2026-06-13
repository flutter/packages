// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/autocomplete/autocomplete.1.dart'
    as example;

void main() {
  testWidgets('can search and find options by email and name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.AutocompleteExampleApp());

    expect(find.text('Alice'), findsNothing);
    expect(find.text('Bob'), findsNothing);
    expect(find.text('Charlie'), findsNothing);

    await tester.enterText(find.byType(TextFormField), 'Ali');
    await tester.pump();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);
    expect(find.text('Charlie'), findsNothing);

    await tester.enterText(find.byType(TextFormField), 'gmail');
    await tester.pump();

    expect(find.text('Alice'), findsNothing);
    expect(find.text('Bob'), findsNothing);
    expect(find.text('Charlie'), findsOneWidget);
  });
}
