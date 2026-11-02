// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/bottom_app_bar/bottom_app_bar.snippet.0.dart'
    as example;

void main() {
  testWidgets('Scaffold renders BottomAppBar and FloatingActionButton', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: example.BottomAppBarExample(
          bottomAppBarContents: Text('Bottom Content'),
        ),
      ),
    );

    final BottomAppBar bottomAppBar = tester.widget<BottomAppBar>(
      find.byType(BottomAppBar),
    );
    expect(bottomAppBar.color, Colors.white);
    expect(find.text('Bottom Content'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
