// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/scrollbar/scrollbar.1.dart' as example;

void main() {
  testWidgets('The scrollbar thumb should be visible at all time', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.ScrollbarExampleApp());
    await tester.pump();
    await tester.pump(
      const Duration(milliseconds: 10),
    ); // Wait for the thumb to start appearing.

    expect(find.widgetWithText(AppBar, 'Scrollbar Sample'), findsOne);

    expect(find.text('item 0'), findsOne);
    expect(find.text('item 9'), findsNothing);
    expect(find.byType(Scrollbar), paints..rect());

    await tester.fling(
      find.byType(Scrollbar).last,
      const Offset(0, -300),
      10.0,
    );

    expect(find.text('item 0'), findsNothing);
    expect(find.text('item 9'), findsOne);
    expect(find.byType(Scrollbar), paints..rect());
  });
}
