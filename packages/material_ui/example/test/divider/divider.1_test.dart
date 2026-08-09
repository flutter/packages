// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/divider/divider.1.dart' as example;

void main() {
  testWidgets('Horizontal Divider', (WidgetTester tester) async {
    await tester.pumpWidget(const example.DividerExampleApp());

    expect(find.byType(Divider), findsOneWidget);

    // Divider is positioned horizontally.
    Offset card = tester.getBottomLeft(find.byType(Card).first);
    expect(card.dy, tester.getTopLeft(find.byType(Divider)).dy);

    card = tester.getTopLeft(find.byType(Card).last);
    expect(card.dy, tester.getBottomLeft(find.byType(Divider)).dy);
  });
}
