// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/card/card.1.dart' as example;

void main() {
  testWidgets('Card has clip applied', (WidgetTester tester) async {
    await tester.pumpWidget(const example.CardExampleApp());

    final Card card = tester.firstWidget(find.byType(Card));
    expect(card.clipBehavior, Clip.hardEdge);
  });
}
