// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

const TableSpan span = TableSpan(extent: FixedTableSpanExtent(100));

void main() {
  test('TableVicinity converts ChildVicinity', () {
    const TableVicinity vicinity = TableVicinity(column: 5, row: 10);
    expect(vicinity.xIndex, 5);
    expect(vicinity.yIndex, 10);
    expect(vicinity.row, 10);
    expect(vicinity.column, 5);
    expect(vicinity.toString(), '(row: 10, column: 5)');
  });

  test('TableVicinity.zero', () {
    const TableVicinity vicinity = TableVicinity.zero;
    expect(vicinity.xIndex, 0);
    expect(vicinity.yIndex, 0);
    expect(vicinity.row, 0);
    expect(vicinity.column, 0);
    expect(vicinity.toString(), '(row: 0, column: 0)');
  });

  test('TableVicinity.copyWith', () {
    TableVicinity vicinity = TableVicinity.zero;
    vicinity = vicinity.copyWith(column: 10);
    expect(vicinity.xIndex, 10);
    expect(vicinity.yIndex, 0);
    expect(vicinity.row, 0);
    expect(vicinity.column, 10);
    expect(vicinity.toString(), '(row: 0, column: 10)');
    vicinity = vicinity.copyWith(row: 20);
    expect(vicinity.xIndex, 10);
    expect(vicinity.yIndex, 20);
    expect(vicinity.row, 20);
    expect(vicinity.column, 10);
    expect(vicinity.toString(), '(row: 20, column: 10)');
  });

  group('Merged cells', () {
    group('Valid merge assertions', () {
      test('TableViewCell asserts nonsensical merge configurations', () {
        TableViewCell? cell;
        const Widget child = SizedBox.shrink();
        expect(
          () {
            cell = TableViewCell(rowMergeStart: 0, child: child);
          },
          throwsA(
            isA<AssertionError>().having(
              (AssertionError error) => error.toString(),
              'description',
              contains(
                  'Row merge start and span must both be set, or both unset.'),
            ),
          ),
        );
        expect(
          () {
            cell = TableViewCell(rowMergeSpan: 0, child: child);
          },
          throwsA(
            isA<AssertionError>().having(
              (AssertionError error) => error.toString(),
              'description',
              contains(
                  'Row merge start and span must both be set, or both unset.'),
            ),
          ),
        );
        expect(
          () {
            cell = TableViewCell(
              rowMergeStart: -1,
              rowMergeSpan: 2,
              child: child,
            );
          },
          throwsA(
            isA<AssertionError>().having(
              (AssertionError error) => error.toString(),
              'description',
              contains('rowMergeStart == null || rowMergeStart >= 0'),
            ),
          ),
        );
        expect(
          () {
            cell = TableViewCell(
              rowMergeStart: 0,
              rowMergeSpan: 0,
              child: child,
            );
          },
          throwsA(
            isA<AssertionError>().having(
              (AssertionError error) => error.toString(),
              'description',
              contains('rowMergeSpan == null || rowMergeSpan > 0'),
            ),
          ),
        );
        expect(
          () {
            cell = TableViewCell(columnMergeStart: 0, child: child);
          },
          throwsA(
            isA<AssertionError>().having(
              (AssertionError error) => error.toString(),
              'description',
              contains(
                  'Column merge start and span must both be set, or both unset.'),
            ),
          ),
        );
        expect(
          () {
            cell = TableViewCell(columnMergeSpan: 0, child: child);
          },
          throwsA(
            isA<AssertionError>().having(
              (AssertionError error) => error.toString(),
              'description',
              contains(
                  'Column merge start and span must both be set, or both unset.'),
            ),
          ),
        );
        expect(
          () {
            cell = TableViewCell(
              columnMergeStart: -1,
              columnMergeSpan: 2,
              child: child,
            );
          },
          throwsA(
            isA<AssertionError>().having(
              (AssertionError error) => error.toString(),
              'description',
              contains('columnMergeStart == null || columnMergeStart >= 0'),
            ),
          ),
        );
        expect(
          () {
            cell = TableViewCell(
              columnMergeStart: 0,
              columnMergeSpan: 0,
              child: child,
            );
          },
          throwsA(
            isA<AssertionError>().having(
              (AssertionError error) => error.toString(),
              'description',
              contains('columnMergeSpan == null || columnMergeSpan > 0'),
            ),
          ),
        );
        expect(cell, isNull);
      });

      testWidgets('Merge start cannot exceed current index',
          (WidgetTester tester) async {
        // Merge span start is greater than given index, ex: column 10 has merge
        // start at 20.
        final List<Object> exceptions = <Object>[];
        final FlutterExceptionHandler? oldHandler = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          exceptions.add(details.exception);
        };
        // Row
        // +---------+
        // |  X err  |
        // |         |
        // +---------+
        // |  merge  |
        // |         |
        // +         +
        // |         |
        // |         |
        // +---------+
        // This cell should only be built for (0, 1) and (0, 2), not (0,0).
        TableViewCell cell = const TableViewCell(
          rowMergeStart: 1,
          rowMergeSpan: 2,
          child: SizedBox.shrink(),
        );
        await tester.pumpWidget(TableView.builder(
          cellBuilder: (_, __) => cell,
          columnBuilder: (_) => span,
          rowBuilder: (_) => span,
          columnCount: 1,
          rowCount: 3,
        ));
        FlutterError.onError = oldHandler;
        expect(exceptions.length, 2);
        expect(
          exceptions.first.toString(),
          contains('spanMergeStart <= currentSpan'),
        );

        await tester.pumpWidget(Container());
        exceptions.clear();
        FlutterError.onError = (FlutterErrorDetails details) {
          exceptions.add(details.exception);
        };
        // Column
        // +---------+---------+---------+
        // |  X err  | merged            |
        // |         |                   |
        // +---------+---------+---------+
        // This cell should only be returned for (1, 0) and (2, 0), not (0,0).
        cell = const TableViewCell(
          columnMergeStart: 1,
          columnMergeSpan: 2,
          child: SizedBox.shrink(),
        );
        await tester.pumpWidget(TableView.builder(
          cellBuilder: (_, __) => cell,
          columnBuilder: (_) => span,
          rowBuilder: (_) => span,
          columnCount: 3,
          rowCount: 1,
        ));
        FlutterError.onError = oldHandler;
        expect(exceptions.length, 2);
        expect(
          exceptions.first.toString(),
          contains('spanMergeStart <= currentSpan'),
        );
      });

      testWidgets('Merge cannot exceed table contents',
          (WidgetTester tester) async {
        // Merge exceeds table content, ex: at column 10, cell spans 4 columns,
        // but table only has 12 columns.
        final List<Object> exceptions = <Object>[];
        final FlutterExceptionHandler? oldHandler = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          exceptions.add(details.exception);
        };
        // Row
        TableViewCell cell = const TableViewCell(
          rowMergeStart: 0,
          rowMergeSpan: 10, // Exceeds the number of rows
          child: SizedBox.shrink(),
        );
        await tester.pumpWidget(TableView.builder(
          cellBuilder: (_, __) => cell,
          columnBuilder: (_) => span,
          rowBuilder: (_) => span,
          columnCount: 1,
          rowCount: 3,
        ));
        FlutterError.onError = oldHandler;
        expect(exceptions.length, 2);
        expect(
          exceptions.first.toString(),
          contains('spanMergeEnd <= spanCount'),
        );

        await tester.pumpWidget(Container());
        exceptions.clear();
        FlutterError.onError = (FlutterErrorDetails details) {
          exceptions.add(details.exception);
        };
        // Column
        cell = const TableViewCell(
          columnMergeStart: 0,
          columnMergeSpan: 10, // Exceeds the number of columns
          child: SizedBox.shrink(),
        );
        await tester.pumpWidget(TableView.builder(
          cellBuilder: (_, __) => cell,
          columnBuilder: (_) => span,
          rowBuilder: (_) => span,
          columnCount: 3,
          rowCount: 1,
        ));
        FlutterError.onError = oldHandler;
        expect(exceptions.length, 2);
        expect(
          exceptions.first.toString(),
          contains('spanMergeEnd <= spanCount'),
        );
      });

      testWidgets('Merge cannot contain pinned and unpinned cells',
          (WidgetTester tester) async {
        // Merge spans pinned and unpinned cells, ex: column 0 is pinned, 0-2
        // expected merge.
        final List<Object> exceptions = <Object>[];
        final FlutterExceptionHandler? oldHandler = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          exceptions.add(details.exception);
        };
        // Row
        TableViewCell cell = const TableViewCell(
          rowMergeStart: 0,
          rowMergeSpan: 3,
          child: SizedBox.shrink(),
        );
        await tester.pumpWidget(TableView.builder(
          cellBuilder: (_, __) => cell,
          columnBuilder: (_) => span,
          rowBuilder: (_) => span,
          columnCount: 1,
          rowCount: 3,
          pinnedRowCount: 1,
        ));
        FlutterError.onError = oldHandler;
        expect(exceptions.length, 2);
        expect(
          exceptions.first.toString(),
          contains('spanMergeEnd < pinnedSpanCount'),
        );

        await tester.pumpWidget(Container());
        exceptions.clear();
        FlutterError.onError = (FlutterErrorDetails details) {
          exceptions.add(details.exception);
        };
        // Column
        cell = const TableViewCell(
          columnMergeStart: 0,
          columnMergeSpan: 3,
          child: SizedBox.shrink(),
        );
        await tester.pumpWidget(TableView.builder(
          cellBuilder: (_, __) => cell,
          columnBuilder: (_) => span,
          rowBuilder: (_) => span,
          columnCount: 3,
          rowCount: 1,
          pinnedColumnCount: 1,
        ));
        FlutterError.onError = oldHandler;
        expect(exceptions.length, 2);
        expect(
          exceptions.first.toString(),
          contains('spanMergeEnd < pinnedSpanCount'),
        );
      });
    });
    group('layout', () {
      // Cluster of merged cells (M) surrounded by regular cells (...).
      // +---------+--------+--------+
      // | M(0,0)  | M(0, 1)         | ....
      // |         |                 |
      // +         +--------+--------+
      // |         | M(1,1)          | ....
      // |         |                 |
      // +---------+                 +
      // | (2,0)   |                 | ....
      // |         |                 |
      // +---------+--------+--------+
      //   ...       ...      ...
      final Map<TableVicinity, (int, int)> mergedColumns =
          <TableVicinity, (int, int)>{
        const TableVicinity(row: 0, column: 1): (1, 2), // M(0, 1)
        const TableVicinity(row: 0, column: 2): (1, 2), // M(0, 1)
        const TableVicinity(row: 1, column: 1): (1, 2), // M(1, 1)
        const TableVicinity(row: 1, column: 2): (1, 2), // M(1, 1)
        const TableVicinity(row: 2, column: 1): (1, 2), // M(1, 1)
        const TableVicinity(row: 2, column: 2): (1, 2), // M(1, 1)
      };
      final Map<TableVicinity, (int, int)> mergedRows =
          <TableVicinity, (int, int)>{
        TableVicinity.zero: (0, 2), // M(0, 0)
        TableVicinity.zero.copyWith(row: 1): (0, 2), // M(0,0)
        const TableVicinity(row: 1, column: 1): (1, 2), // M(1, 1)
        const TableVicinity(row: 1, column: 2): (1, 2), // M(1, 1)
        const TableVicinity(row: 2, column: 1): (1, 2), // M(1, 1)
        const TableVicinity(row: 2, column: 2): (1, 2), // M(1, 1)
      };

      testWidgets('natural main axis and scroll directions',
          (WidgetTester tester) async {
        // Verifies the right constraints for merged cells, and that extra calls
        // to build are not made for merged cells.
        final Map<TableVicinity, BoxConstraints> layoutConstraints = <TableVicinity, BoxConstraints>{};

        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: TableView.builder(
            cellBuilder: (_, TableVicinity vicinity) {
              if (mergedColumns.keys.contains(vicinity) ||
                  mergedRows.keys.contains(vicinity)) {
                return TableViewCell(
                  rowMergeStart: mergedRows[vicinity]?.$1,
                  rowMergeSpan: mergedRows[vicinity]?.$2,
                  columnMergeStart: mergedColumns[vicinity]?.$1,
                  columnMergeSpan: mergedColumns[vicinity]?.$2,
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      layoutConstraints[vicinity] = constraints;
                      return Text(
                        'M(${mergedRows[vicinity]?.$1 ?? vicinity.row},'
                        '${mergedColumns[vicinity]?.$1 ?? vicinity.column})',
                      );
                    }
                  ),
                );
              }
              return TableViewCell(
                child: Text('M(${vicinity.row},${vicinity.column})'),
              );
            },
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            columnCount: 10,
            rowCount: 10,
          ),
        ));
        await tester.pumpAndSettle();
        expect(find.text('M(0,0)'), findsOneWidget);
        expect(find.text('M(0,1)'), findsOneWidget);
        expect(find.text('M(0,2)'), findsNothing); // Merged
        expect(layoutConstraints[const TableVicinity(row: 0, column: 2)], isNull,);
        expect(find.text('M(1,0)'), findsNothing); // Merged
        expect(layoutConstraints[const TableVicinity(row: 1, column: 0)], isNull,);
        expect(find.text('M(1,1)'), findsOneWidget);
        expect(find.text('M(1,2)'), findsNothing); // Merged
        expect(layoutConstraints[const TableVicinity(row: 1, column: 2)], isNull,);
        expect(find.text('M(2,0)'), findsOneWidget);
        expect(find.text('M(2,1)'), findsNothing); // Merged
        expect(layoutConstraints[const TableVicinity(row: 2, column: 1)], isNull,);
        expect(find.text('M(2,2)'), findsNothing); // Merged
        expect(layoutConstraints[const TableVicinity(row: 2, column: 2)], isNull,);

        expect(tester.getTopLeft(find.text('M(0,0)')), Offset.zero);
        print(layoutConstraints[TableVicinity.zero]);
        // expect(tester.getSize(find.text('M(0,0)')), const Size(100.0, 200.0)); // 300?
        expect(tester.getTopLeft(find.text('M(0,1)')), const Offset(100.0, 0.0),);
        // expect(tester.getSize(find.text('M(0,1)')), const Size(200.0, 100.0));
        expect(tester.getTopLeft(find.text('M(1,1)')), const Offset(100.0, 100.0),);
        // expect(tester.getSize(find.text('M(1,1)')), const Size(200.0, 200.0));
        expect(tester.getTopLeft(find.text('M(2,0)')), const Offset(0.0, 200.0),);
        // expect(tester.getSize(find.text('M(2,0)')), const Size(100.0, 100.0));
      });
    });
  });
}
