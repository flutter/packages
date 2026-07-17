// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/list_tile/list_tile.1.dart' as example;

void main() {
  testWidgets('ListTiles wrapped in Card widgets', (WidgetTester tester) async {
    const int totalTiles = 7;

    await tester.pumpWidget(const example.ListTileApp());

    expect(find.byType(ListTile), findsNWidgets(totalTiles));

    // The ListTile widget is wrapped in a Card widget.
    for (int i = 0; i < totalTiles; i++) {
      expect(
        find.ancestor(
          of: find.byType(ListTile).at(i),
          matching: find.byType(Card).at(i),
        ),
        findsOneWidget,
      );
    }
  });
}
