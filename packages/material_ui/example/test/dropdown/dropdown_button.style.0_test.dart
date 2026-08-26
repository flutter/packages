// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui_examples/dropdown/dropdown_button.style.0.dart'
    as example;

void main() {
  testWidgets('Select an item from DropdownButton', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.DropdownButtonApp());

    expect(find.text('One'), findsOneWidget);
    expect(find.text('One', skipOffstage: false), findsNWidgets(4));

    await tester.tap(find.text('One').first);
    await tester.pumpAndSettle();
    expect(find.text('Two'), findsOneWidget);
    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();
    expect(find.text('Two'), findsOneWidget);
    expect(find.text('Two', skipOffstage: false), findsNWidgets(4));
  });
}
