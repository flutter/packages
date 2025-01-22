// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_examples/tree_view/simple_tree.dart';

void main() {
  testWidgets('Example builds and can be interacted with',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TreeExample()));
    await tester.pumpAndSettle();
    expect(
      find.text("It's supercalifragilisticexpialidocious"),
      findsOneWidget,
    );
    expect(
      find.text('Um-dittle-ittl-um-dittle-I'),
      findsNothing,
    );
    await tester.tap(find.byType(Icon).last);
    await tester.pumpAndSettle();
    expect(
      find.text('Um-dittle-ittl-um-dittle-I'),
      findsOneWidget,
    );
  });

  testWidgets('Can scroll ', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TreeExample()));
    await tester.pumpAndSettle();
    final Finder horizontalScrollable = find.byWidgetPredicate((Widget widget) {
      if (widget is Scrollable) {
        return widget.axisDirection == AxisDirection.right;
      }
      return false;
    });
    ScrollPosition horizontalPosition =
        (tester.state(horizontalScrollable) as ScrollableState).position;

    expect(horizontalPosition.maxScrollExtent, greaterThan(190));
    expect(horizontalPosition.pixels, 0.0);
    final TreeExampleState state = tester.state(
      find.byType(TreeExample),
    ) as TreeExampleState;

    state.treeController.expandAll();
    await tester.pumpAndSettle();
    horizontalPosition =
        (tester.state(horizontalScrollable) as ScrollableState).position;
    // Expanding all of the node increased the max extent.
    expect(horizontalPosition.maxScrollExtent, 502.0);
    expect(horizontalPosition.pixels, 0.0);
    state.horizontalController.jumpTo(10.0);
    await tester.pumpAndSettle();
    expect(horizontalPosition.maxScrollExtent, 502.0);
    expect(horizontalPosition.pixels, 10.0);
  });
}
