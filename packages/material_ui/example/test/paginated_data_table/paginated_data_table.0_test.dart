// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui_examples/paginated_data_table/paginated_data_table.0.dart'
    as example;

void main() {
  testWidgets('PaginatedDataTable 0', (WidgetTester tester) async {
    await tester.pumpWidget(const example.DataTableExampleApp());
    expect(find.text('Associate Professor'), findsOneWidget);
  });
}
