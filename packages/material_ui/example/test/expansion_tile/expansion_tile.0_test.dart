// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/expansion_tile/expansion_tile.0.dart'
    as example;

void main() {
  testWidgets('When expansion tiles are expanded tile numbers are revealed', (
    WidgetTester tester,
  ) async {
    const int totalTiles = 3;

    await tester.pumpWidget(const example.ExpansionTileApp());

    expect(find.byType(ExpansionTile), findsNWidgets(totalTiles));

    const String tileOne = 'This is tile number 1';
    expect(find.text(tileOne), findsNothing);

    await tester.tap(find.text('ExpansionTile 1'));
    await tester.pumpAndSettle();
    expect(find.text(tileOne), findsOneWidget);

    const String tileTwo = 'This is tile number 2';
    expect(find.text(tileTwo), findsNothing);

    await tester.tap(find.text('ExpansionTile 2'));
    await tester.pumpAndSettle();
    expect(find.text(tileTwo), findsOneWidget);

    const String tileThree = 'This is tile number 3';
    expect(find.text(tileThree), findsNothing);

    await tester.tap(find.text('ExpansionTile 3'));
    await tester.pumpAndSettle();
    expect(find.text(tileThree), findsOneWidget);
  });
}
