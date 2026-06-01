// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/paginated_data_table/paginated_data_table.1.dart'
    as example;

void main() {
  testWidgets('PaginatedDataTable 1', (WidgetTester tester) async {
    await tester.pumpWidget(const example.DataTableExampleApp());
    expect(find.text('Strange New Worlds'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_upward).at(1));
    await tester.pump();
    expect(find.text('Strange New Worlds'), findsNothing);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pump();
    expect(find.text('Strange New Worlds'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_upward).at(1));
    await tester.pump();
    expect(find.text('Strange New Worlds'), findsNothing);
  });
}
