// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/app/app.snippet.2.dart' as example;

void main() {
  testWidgets('MaterialApp applies custom ThemeData', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.MaterialAppExample());

    expect(find.widgetWithText(AppBar, 'MaterialApp Theme'), findsOneWidget);

    final BuildContext context = tester.element(find.text('MaterialApp Theme'));
    final ThemeData theme = Theme.of(context);
    expect(theme.brightness, Brightness.dark);
    expect(theme.primaryColor, Colors.blueGrey);
  });
}
