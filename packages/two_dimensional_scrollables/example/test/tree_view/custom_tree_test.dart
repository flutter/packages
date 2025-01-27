// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_examples/tree_view/custom_tree.dart';

void main() {
  testWidgets('Example builds and can be interacted with',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CustomTreeExample()));
    await tester.pumpAndSettle();
    expect(find.text('README.md'), findsOneWidget);
    expect(find.text('common'), findsNothing);
    await tester.tap(find.byType(Icon).last);
    await tester.pumpAndSettle();
    expect(find.text('common'), findsOneWidget);
  });

  testWidgets('Can scroll', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CustomTreeExample()));
    await tester.pumpAndSettle();

    final Finder verticalScrollable = find.byWidgetPredicate((Widget widget) {
      if (widget is Scrollable) {
        return widget.axisDirection == AxisDirection.down;
      }
      return false;
    });
    ScrollPosition verticalPosition =
        (tester.state(verticalScrollable) as ScrollableState).position;

    expect(verticalPosition.maxScrollExtent, 0.0);
    expect(verticalPosition.pixels, 0.0);

    final CustomTreeExampleState state = tester.state(
      find.byType(CustomTreeExample),
    ) as CustomTreeExampleState;

    state.treeController.toggleNode(state.treeController.getNodeFor('lib')!);
    await tester.pumpAndSettle();
    verticalPosition =
        (tester.state(verticalScrollable) as ScrollableState).position;
    expect(verticalPosition.maxScrollExtent, 0.0);
    expect(verticalPosition.pixels, 0.0);
    state.treeController.toggleNode(state.treeController.getNodeFor('test')!);
    await tester.pumpAndSettle();

    verticalPosition =
        (tester.state(verticalScrollable) as ScrollableState).position;

    expect(verticalPosition.maxScrollExtent, 10.0);
    expect(verticalPosition.pixels, 0.0);
    state.treeController.toggleNode(state.treeController.getNodeFor('src')!);
    await tester.pumpAndSettle();

    verticalPosition =
        (tester.state(verticalScrollable) as ScrollableState).position;

    // Enough nodes expanded to allow us to scroll
    expect(verticalPosition.maxScrollExtent, 190.0);
    expect(verticalPosition.pixels, 0.0);
    state.verticalController.jumpTo(10.0);
    await tester.pumpAndSettle();
    expect(verticalPosition.maxScrollExtent, 190.0);
    expect(verticalPosition.pixels, 10.0);
  });
}
