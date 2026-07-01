// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/divider/vertical_divider.1.dart'
    as example;

void main() {
  testWidgets('Vertical Divider', (WidgetTester tester) async {
    await tester.pumpWidget(const example.VerticalDividerExampleApp());

    expect(find.byType(VerticalDivider), findsOneWidget);

    // Divider is positioned vertically.
    Offset card = tester.getTopRight(find.byType(Card).first);
    expect(card.dx, tester.getTopLeft(find.byType(VerticalDivider)).dx);

    card = tester.getTopLeft(find.byType(Card).last);
    expect(card.dx, tester.getTopRight(find.byType(VerticalDivider)).dx);
  });
}
