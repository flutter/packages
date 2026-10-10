// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/list_tile/list_tile.snippet.2.dart'
    as example;

void main() {
  testWidgets('ListTile enabled and subtitle depend on act value', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: example.ListTileExample(act: 1))),
    );

    expect(find.text("Trix's airplane"), findsOneWidget);
    expect(find.text('The airplane is only in Act II.'), findsOneWidget);
    expect(tester.widget<ListTile>(find.byType(ListTile)).enabled, isFalse);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: example.ListTileExample(act: 2))),
    );

    expect(find.text("Trix's airplane"), findsOneWidget);
    expect(find.text('The airplane is only in Act II.'), findsNothing);
    expect(tester.widget<ListTile>(find.byType(ListTile)).enabled, isTrue);
  });
}
