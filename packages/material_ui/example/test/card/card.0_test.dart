// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/card/card.0.dart' as example;

void main() {
  testWidgets('Card Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const example.CardExampleApp());
    expect(find.byType(Card), findsOneWidget);
    expect(find.widgetWithIcon(Card, Icons.album), findsOneWidget);
    expect(
      find.widgetWithText(Card, 'The Enchanted Nightingale'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(
        Card,
        'Music by Julie Gable. Lyrics by Sidney Stein.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(Card, 'BUY TICKETS'), findsOneWidget);
    expect(find.widgetWithText(Card, 'LISTEN'), findsOneWidget);
  });
}
