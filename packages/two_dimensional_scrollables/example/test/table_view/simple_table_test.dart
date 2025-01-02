// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_examples/table_view/simple_table.dart';

void main() {
  testWidgets('Example app builds & scrolls', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TableExample()));
    await tester.pump();

    expect(find.text('Jump to Top'), findsOneWidget);
    expect(find.text('Jump to Bottom'), findsOneWidget);
    expect(find.text('Add 10 Rows'), findsOneWidget);

    final Finder scrollable = find.byWidgetPredicate((Widget widget) {
      if (widget is Scrollable) {
        return widget.axisDirection == AxisDirection.down;
      }
      return false;
    });
    final ScrollPosition position =
        (tester.state(scrollable) as ScrollableState).position;
    expect(position.axis, Axis.vertical);
    expect(position.pixels, 0.0);
    position.jumpTo(10);
    await tester.pump();
    expect(position.pixels, 10.0);
  });

  testWidgets('Example app buttons work', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TableExample()));
    await tester.pump();

    final Finder scrollable = find.byWidgetPredicate((Widget widget) {
      if (widget is Scrollable) {
        return widget.axisDirection == AxisDirection.down;
      }
      return false;
    });
    final ScrollPosition position =
        (tester.state(scrollable) as ScrollableState).position;

    expect(position.maxScrollExtent, greaterThan(750));
    await tester.tap(find.text('Add 10 Rows'));
    await tester.pump();
    expect(position.maxScrollExtent, greaterThan(1380));
    await tester.tap(find.text('Jump to Bottom'));
    await tester.pump();
    expect(position.pixels, greaterThan(1380));
    await tester.tap(find.text('Jump to Top'));
    await tester.pump();
    expect(position.pixels, 0.0);
  });
}
