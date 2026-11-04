// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/list_tile/list_tile.snippet.0.dart'
    as example;

void main() {
  testWidgets('ListTile renders with red tileColor inside Material', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: example.ListTileExample())),
    );

    expect(find.text('ListTile with red background'), findsOneWidget);
    expect(
      find.byType(example.ListTileExample),
      paints
        ..rect(color: Colors.green.shade500)
        ..rect(color: Colors.red.shade500),
    );
  });
}
