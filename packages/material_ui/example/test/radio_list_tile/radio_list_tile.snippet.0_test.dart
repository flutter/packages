// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/radio_list_tile/radio_list_tile.snippet.0.dart'
    as example;

void main() {
  testWidgets('RadioListTile renders with red tileColor inside Material', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: example.RadioListTileExample())),
    );

    expect(find.text('AM'), findsOneWidget);
    final RadioListTile<example.Meridiem> tile = tester
        .widget<RadioListTile<example.Meridiem>>(
          find.byType(RadioListTile<example.Meridiem>),
        );
    expect(tile.tileColor, Colors.red);
    expect(tile.value, example.Meridiem.am);
  });
}
