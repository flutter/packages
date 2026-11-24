// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/app/app.snippet.1.dart' as example;

void main() {
  testWidgets('MaterialApp routes map navigates between Home and About', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.MaterialAppExample());

    expect(find.widgetWithText(AppBar, 'Home Route'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'About Route'), findsNothing);

    final BuildContext context = tester.element(find.text('Home Route'));
    Navigator.of(context).pushNamed('/about');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'About Route'), findsOneWidget);
  });
}
