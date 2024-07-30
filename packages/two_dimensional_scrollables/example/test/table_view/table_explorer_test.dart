// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_examples/table_view/infinite_table.dart';
import 'package:two_dimensional_examples/table_view/merged_table.dart';
import 'package:two_dimensional_examples/table_view/simple_table.dart';
import 'package:two_dimensional_examples/table_view/table_explorer.dart';

void main() {
  testWidgets('Table explorer switches between samples',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TableExplorer()));
    await tester.pumpAndSettle();
    // The first example
    expect(find.byType(TableExample), findsOneWidget);
    expect(find.byType(MergedTableExample), findsNothing);
    expect(find.byType(InfiniteTableExample), findsNothing);
    expect(find.byType(Radio<TableType>), findsNWidgets(3));
    final Finder buttons = find.byType(Radio<TableType>);
    await tester.tap(buttons.at(1));
    await tester.pumpAndSettle();
    expect(find.byType(TableExample), findsNothing);
    expect(find.byType(MergedTableExample), findsOneWidget);
    expect(find.byType(InfiniteTableExample), findsNothing);
    await tester.tap(buttons.at(2));
    await tester.pumpAndSettle();
    expect(find.byType(TableExample), findsNothing);
    expect(find.byType(MergedTableExample), findsNothing);
    expect(find.byType(InfiniteTableExample), findsOneWidget);
    await tester.tap(buttons.at(0));
    await tester.pumpAndSettle();
    expect(find.byType(TableExample), findsOneWidget);
    expect(find.byType(MergedTableExample), findsNothing);
    expect(find.byType(InfiniteTableExample), findsNothing);
  });
}
