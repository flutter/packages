// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/list_tile/list_tile.snippet.1.dart'
    as example;

void main() {
  testWidgets('Row renders two Expanded ListTiles with FlutterLogo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: example.ListTileExample())),
    );

    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.byType(FlutterLogo), findsNWidgets(2));
    expect(find.text('These ListTiles are expanded '), findsOneWidget);
    expect(find.text('to fill the available space.'), findsOneWidget);
  });
}
