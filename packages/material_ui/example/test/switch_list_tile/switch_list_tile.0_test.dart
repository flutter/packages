// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/switch_list_tile/switch_list_tile.0.dart'
    as example;

void main() {
  testWidgets('SwitchListTile can be toggled', (WidgetTester tester) async {
    await tester.pumpWidget(const example.SwitchListTileApp());

    expect(find.byType(SwitchListTile), findsOneWidget);

    SwitchListTile switchListTile = tester.widget(find.byType(SwitchListTile));
    expect(switchListTile.value, isFalse);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    switchListTile = tester.widget(find.byType(SwitchListTile));
    expect(switchListTile.value, isTrue);
  });
}
