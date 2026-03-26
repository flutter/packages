// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

void main() {
  group('TableView pinned extent warnings', () {
    testWidgets('Warns when pinned columns exceed viewport width', (
      WidgetTester tester,
    ) async {
      // Regression test for https://github.com/flutter/flutter/issues/136833
      final log = <String>[];
      final DebugPrintCallback oldDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        log.add(message!);
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 400,
              child: TableView.builder(
                columnCount: 5,
                rowCount: 5,
                pinnedColumnCount: 3,
                columnBuilder: (int index) =>
                    const TableSpan(extent: FixedTableSpanExtent(100)),
                rowBuilder: (int index) =>
                    const TableSpan(extent: FixedTableSpanExtent(100)),
                cellBuilder: (BuildContext context, TableVicinity vicinity) =>
                    const TableViewCell(child: SizedBox.shrink()),
              ),
            ),
          ),
        ),
      );

      // Pinned columns extent = 300 (3 * 100), viewport width = 200.
      // A warning is expected because the pinned columns are wider than the
      // viewport, meaning even the pinned content cannot be fully displayed.
      expect(
        log,
        contains(
          matches(
            r'TableView has pinned columns with a total width of 300(\.0)?, which exceeds the viewport width of 200(\.0)?',
          ),
        ),
      );
      debugPrint = oldDebugPrint;
    });

    testWidgets('Warns when pinned rows exceed viewport height', (
      WidgetTester tester,
    ) async {
      // Regression test for https://github.com/flutter/flutter/issues/136833
      final log = <String>[];
      final DebugPrintCallback oldDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        log.add(message!);
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 200,
              child: TableView.builder(
                columnCount: 5,
                rowCount: 5,
                pinnedRowCount: 3,
                columnBuilder: (int index) =>
                    const TableSpan(extent: FixedTableSpanExtent(100)),
                rowBuilder: (int index) =>
                    const TableSpan(extent: FixedTableSpanExtent(100)),
                cellBuilder: (BuildContext context, TableVicinity vicinity) =>
                    const TableViewCell(child: SizedBox.shrink()),
              ),
            ),
          ),
        ),
      );

      // Pinned rows extent = 300 (3 * 100), viewport height = 200.
      // A warning is expected because the pinned rows are taller than the
      // viewport, meaning even the pinned content cannot be fully displayed.
      expect(
        log,
        contains(
          matches(
            r'TableView has pinned rows with a total height of 300(\.0)?, which exceeds the viewport height of 200(\.0)?',
          ),
        ),
      );
      debugPrint = oldDebugPrint;
    });

    testWidgets(
      'Warns when pinned columns fully consume viewport width and there are unpinned columns',
      (WidgetTester tester) async {
        // Regression test for https://github.com/flutter/flutter/issues/136833
        final log = <String>[];
        final DebugPrintCallback oldDebugPrint = debugPrint;
        debugPrint = (String? message, {int? wrapWidth}) {
          log.add(message!);
        };

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 400,
                child: TableView.builder(
                  columnCount: 3,
                  rowCount: 5,
                  pinnedColumnCount: 2,
                  columnBuilder: (int index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  rowBuilder: (int index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  cellBuilder: (BuildContext context, TableVicinity vicinity) =>
                      const TableViewCell(child: SizedBox.shrink()),
                ),
              ),
            ),
          ),
        );

        // Pinned columns extent = 200 (2 * 100), viewport width = 200.
        // There is 1 unpinned column (columnCount: 3, pinnedColumnCount: 2).
        // Since the pinned columns take up the entire viewport width, the
        // unpinned column will never be visible during scrolling.
        expect(
          log,
          contains(
            'TableView has pinned columns that fully consume the viewport width. Unpinned columns will not be visible.',
          ),
        );
        debugPrint = oldDebugPrint;
      },
    );

    testWidgets(
      'Warns when pinned rows fully consume viewport height and there are unpinned rows',
      (WidgetTester tester) async {
        // Regression test for https://github.com/flutter/flutter/issues/136833
        final log = <String>[];
        final DebugPrintCallback oldDebugPrint = debugPrint;
        debugPrint = (String? message, {int? wrapWidth}) {
          log.add(message!);
        };

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 200,
                child: TableView.builder(
                  columnCount: 5,
                  rowCount: 3,
                  pinnedRowCount: 2,
                  columnBuilder: (int index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  rowBuilder: (int index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  cellBuilder: (BuildContext context, TableVicinity vicinity) =>
                      const TableViewCell(child: SizedBox.shrink()),
                ),
              ),
            ),
          ),
        );

        // Pinned rows extent = 200 (2 * 100), viewport height = 200.
        // There is 1 unpinned row (rowCount: 3, pinnedRowCount: 2).
        // Since the pinned rows take up the entire viewport height, the
        // unpinned row will never be visible during scrolling.
        expect(
          log,
          contains(
            'TableView has pinned rows that fully consume the viewport height. Unpinned rows will not be visible.',
          ),
        );
        debugPrint = oldDebugPrint;
      },
    );

    testWidgets(
      'Does not warn when all columns are pinned even if they consume viewport',
      (WidgetTester tester) async {
        // Regression test for https://github.com/flutter/flutter/issues/136833
        final log = <String>[];
        final DebugPrintCallback oldDebugPrint = debugPrint;
        debugPrint = (String? message, {int? wrapWidth}) {
          log.add(message!);
        };

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 400,
                child: TableView.builder(
                  columnCount: 2,
                  rowCount: 5,
                  pinnedColumnCount: 2,
                  columnBuilder: (int index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  rowBuilder: (int index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  cellBuilder: (BuildContext context, TableVicinity vicinity) =>
                      const TableViewCell(child: SizedBox.shrink()),
                ),
              ),
            ),
          ),
        );

        // Pinned columns extent = 200 (2 * 100), viewport width = 200.
        // Although the pinned columns fully consume the viewport width,
        // ALL columns are pinned (columnCount: 2, pinnedColumnCount: 2).
        // Since there are no unpinned columns, no warning is issued about
        // unpinned columns being hidden.
        expect(
          log,
          isNot(contains(contains('Unpinned columns will not be visible'))),
        );
        debugPrint = oldDebugPrint;
      },
    );
  });
}
