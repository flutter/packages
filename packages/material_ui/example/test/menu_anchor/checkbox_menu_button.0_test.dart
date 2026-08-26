// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/menu_anchor/checkbox_menu_button.0.dart'
    as example;

void main() {
  testWidgets('Can open menu and show message', (WidgetTester tester) async {
    await tester.pumpWidget(const example.MenuApp());

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.text('Show Message'), findsOneWidget);
    expect(find.text(example.MenuApp.kMessage), findsNothing);

    await tester.tap(find.text('Show Message'));
    await tester.pumpAndSettle();

    expect(find.text('Show Message'), findsNothing);
    expect(find.text(example.MenuApp.kMessage), findsOneWidget);
  });

  testWidgets('MenuAnchor is wrapped in a SafeArea', (
    WidgetTester tester,
  ) async {
    const double safeAreaPadding = 100.0;
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(padding: .symmetric(vertical: safeAreaPadding)),
        child: example.MenuApp(),
      ),
    );

    expect(
      tester.getTopLeft(find.byType(MenuAnchor)),
      const Offset(0.0, safeAreaPadding),
    );
  });
}
