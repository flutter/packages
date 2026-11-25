// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/popup_menu/popup_menu_item.snippet.0.dart'
    as example;

void main() {
  testWidgets('PopupMenuItem displays child text and returns Menu.itemOne', (
    WidgetTester tester,
  ) async {
    example.Menu? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: example.PopupMenuItemExample(
            onSelected: (example.Menu value) {
              selected = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PopupMenuButton<example.Menu>));
    await tester.pumpAndSettle();

    expect(find.text('Item 1'), findsOneWidget);

    await tester.tap(find.text('Item 1'));
    await tester.pumpAndSettle();

    expect(selected, example.Menu.itemOne);
  });
}
