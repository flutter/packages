// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_examples/table_view/infinite_table.dart';

void main() {
  testWidgets('Builds, can scroll, buttons work', (WidgetTester tester) async {
    tester.view.physicalSize = const Size.square(800.0);
    await tester.pumpWidget(const MaterialApp(home: InfiniteTableExample()));
    await tester.pump();
    expect(find.text('0:0'), findsOneWidget);

    final Finder verticalScrollable = find.byWidgetPredicate((Widget widget) {
      if (widget is Scrollable) {
        return widget.axisDirection == AxisDirection.down;
      }
      return false;
    });
    final ScrollPosition verticalPosition =
        (tester.state(verticalScrollable) as ScrollableState).position;

    final Finder horizontalScrollable = find.byWidgetPredicate((Widget widget) {
      if (widget is Scrollable) {
        return widget.axisDirection == AxisDirection.right;
      }
      return false;
    });
    final ScrollPosition horizontalPosition =
        (tester.state(horizontalScrollable) as ScrollableState).position;

    expect(verticalPosition.pixels, 0.0);
    expect(verticalPosition.maxScrollExtent, double.infinity);
    expect(horizontalPosition.pixels, 0.0);
    expect(horizontalPosition.maxScrollExtent, double.infinity);
    verticalPosition.jumpTo(300.0);
    horizontalPosition.jumpTo(20.0);
    await tester.pump();
    expect(verticalPosition.pixels, 300.0);
    expect(verticalPosition.maxScrollExtent, double.infinity);
    expect(horizontalPosition.pixels, 20.0);
    expect(horizontalPosition.maxScrollExtent, double.infinity);

    await tester.tap(find.text('Make rows fixed'));
    await tester.pump();
    expect(verticalPosition.pixels, 300.0);
    expect(verticalPosition.maxScrollExtent, lessThan(5000));
    expect(horizontalPosition.pixels, 20.0);
    expect(horizontalPosition.maxScrollExtent, double.infinity);

    await tester.tap(find.text('Make columns fixed'));
    await tester.pump();
    expect(verticalPosition.pixels, 300.0);
    expect(verticalPosition.maxScrollExtent, lessThan(5000));
    expect(horizontalPosition.pixels, 20.0);
    expect(horizontalPosition.maxScrollExtent, lessThan(4800));

    await tester.tap(find.text('Make rows infinite'));
    await tester.pump();
    expect(verticalPosition.pixels, 300.0);
    expect(verticalPosition.maxScrollExtent, double.infinity);
    expect(horizontalPosition.pixels, 20.0);
    expect(horizontalPosition.maxScrollExtent, lessThan(4800));

    await tester.tap(find.text('Make columns infinite'));
    await tester.pump();
    expect(verticalPosition.pixels, 300.0);
    expect(verticalPosition.maxScrollExtent, double.infinity);
    expect(horizontalPosition.pixels, 20.0);
    expect(horizontalPosition.maxScrollExtent, double.infinity);
  });
}
