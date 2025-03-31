// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_examples/tree_view/custom_tree.dart';
import 'package:two_dimensional_examples/tree_view/simple_tree.dart';
import 'package:two_dimensional_examples/tree_view/tree_explorer.dart';

void main() {
  testWidgets('Tree explorer switches between samples',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TreeExplorer()));
    await tester.pumpAndSettle();
    // The first example
    expect(find.byType(TreeExample), findsOneWidget);
    expect(find.byType(CustomTreeExample), findsNothing);
    expect(find.byType(Radio<TreeType>), findsNWidgets(2));
    await tester.tap(find.byType(Radio<TreeType>).last);
    await tester.pumpAndSettle();
    expect(find.byType(TreeExample), findsNothing);
    expect(find.byType(CustomTreeExample), findsOneWidget);
    await tester.tap(find.byType(Radio<TreeType>).first);
    await tester.pumpAndSettle();
    expect(find.byType(TreeExample), findsOneWidget);
    expect(find.byType(CustomTreeExample), findsNothing);
  });
}
