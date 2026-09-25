// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/switch_list_tile/switch_list_tile.snippet.0.dart'
    as example;

void main() {
  testWidgets('SwitchListTile renders with red tileColor inside Material', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: example.SwitchListTileExample())),
    );

    expect(find.text('SwitchListTile with red background'), findsOneWidget);
    final SwitchListTile tile = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(tile.tileColor, Colors.red);
    expect(tile.value, isTrue);
  });
}
