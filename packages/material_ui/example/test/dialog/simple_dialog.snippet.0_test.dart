// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/dialog/simple_dialog.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'SimpleDialog returns selected Department or null when dismissed',
    (WidgetTester tester) async {
      final List<example.Department?> results = <example.Department?>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: example.SimpleDialogExample(onSelected: results.add),
          ),
        ),
      );

      // Select Treasury department.
      await tester.tap(find.text('Select assignment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Treasury department'));
      await tester.pumpAndSettle();
      expect(results, <example.Department?>[example.Department.treasury]);

      // Select State department.
      await tester.tap(find.text('Select assignment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('State department'));
      await tester.pumpAndSettle();
      expect(results, <example.Department?>[
        example.Department.treasury,
        example.Department.state,
      ]);

      // Dismiss dialog by tapping the barrier.
      await tester.tap(find.text('Select assignment'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(results, <example.Department?>[
        example.Department.treasury,
        example.Department.state,
        null,
      ]);
    },
  );
}
