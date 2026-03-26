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

      // Pinned columns extent = 300, viewport width = 200.
      expect(
        log,
        contains(
          contains(
            'TableView has pinned columns with a total width of 300.0, which exceeds the viewport width of 200.0',
          ),
        ),
      );
      debugPrint = oldDebugPrint;
    });

    testWidgets('Warns when pinned rows exceed viewport height', (
      WidgetTester tester,
    ) async {
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

      // Pinned rows extent = 300, viewport height = 200.
      expect(
        log,
        contains(
          contains(
            'TableView has pinned rows with a total height of 300.0, which exceeds the viewport height of 200.0',
          ),
        ),
      );
      debugPrint = oldDebugPrint;
    });

    testWidgets(
      'Warns when pinned columns fully consume viewport width and there are unpinned columns',
      (WidgetTester tester) async {
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

        // Pinned columns extent = 200, viewport width = 200. Unpinned columns = 1.
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

        // Pinned rows extent = 200, viewport height = 200. Unpinned rows = 1.
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

        expect(
          log,
          isNot(contains(contains('Unpinned columns will not be visible'))),
        );
        debugPrint = oldDebugPrint;
      },
    );
  });
}
