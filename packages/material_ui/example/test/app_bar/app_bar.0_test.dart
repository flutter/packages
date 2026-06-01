// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/app_bar/app_bar.0.dart' as example;

void main() {
  testWidgets('Appbar updates on navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const example.AppBarApp());

    expect(find.widgetWithText(AppBar, 'AppBar Demo'), findsOneWidget);
    expect(find.text('This is the home page'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.navigate_next));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Next page'), findsOneWidget);
    expect(find.text('This is the next page'), findsOneWidget);
  });
}
