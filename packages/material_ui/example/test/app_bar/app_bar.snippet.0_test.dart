// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/app_bar/app_bar.snippet.0.dart' as example;

void main() {
  testWidgets('AppBar leading button opens Scaffold drawer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: example.AppBarExample()));

    expect(find.text('Drawer'), findsNothing);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text('Drawer'), findsOneWidget);
  });
}
