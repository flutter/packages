// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/list_tile/list_tile.snippet.3.dart'
    as example;

void main() {
  testWidgets('ListTile renders 48x48 leading GestureDetector with avatar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: example.ListTileExample())),
    );

    expect(find.text('title'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
    final ListTile tile = tester.widget<ListTile>(find.byType(ListTile));
    expect(tile.dense, isFalse);
    expect(tester.getSize(find.byWidget(tile.leading!)), const Size(48, 48));
  });
}
