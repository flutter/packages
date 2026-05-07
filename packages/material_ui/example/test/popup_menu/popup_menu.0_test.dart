// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/popup_menu/popup_menu.0.dart' as example;

void main() {
  testWidgets('Can open popup menu', (WidgetTester tester) async {
    const String menuItem = 'Item 1';

    await tester.pumpWidget(const example.PopupMenuApp());

    expect(find.text(menuItem), findsNothing);

    // Open popup menu.
    await tester.tap(find.byIcon(Icons.adaptive.more));
    await tester.pumpAndSettle();
    expect(find.text(menuItem), findsOneWidget);

    // Close popup menu.
    await tester.tapAt(const Offset(1, 1));
    await tester.pumpAndSettle();
    expect(find.text(menuItem), findsNothing);
  });
}
