// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/checkbox_list_tile/checkbox_list_tile.snippet.0.dart'
    as example;

void main() {
  testWidgets('CheckboxListTile renders with red tileColor inside Material', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: example.CheckboxListTileExample()),
      ),
    );

    expect(find.text('CheckboxListTile with red background'), findsOneWidget);
    final CheckboxListTile tile = tester.widget<CheckboxListTile>(
      find.byType(CheckboxListTile),
    );
    expect(tile.tileColor, Colors.red);
    expect(tile.value, isTrue);
  });
}
