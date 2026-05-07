// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/page_transitions_theme/page_transitions_theme.3.dart'
    as example;

void main() {
  testWidgets('Page transition', (WidgetTester tester) async {
    await tester.pumpWidget(const example.PageTransitionsThemeApp());

    final Finder homePage = find.byType(example.HomePage);
    expect(homePage, findsOneWidget);

    final Finder kitten0 = find.widgetWithText(ListTile, 'Kitten 0');
    expect(kitten0, findsOneWidget);

    await tester.tap(kitten0);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Kitten 0'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, 'Kitten 0'), findsOneWidget);
  });
}
