// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui_examples/dropdown/dropdown_button.selected_item_builder.0.dart'
    as example;

void main() {
  testWidgets('Select an item from DropdownButton', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.DropdownButtonApp());

    expect(find.text('NYC'), findsOneWidget);

    await tester.tap(find.text('NYC'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('San Francisco').last);
    await tester.pumpAndSettle();
    expect(find.text('SF'), findsOneWidget);
  });
}
