// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

const TableSpan span = TableSpan(extent: FixedTableSpanExtent(50));
const TableViewCell cell = TableViewCell(child: SizedBox.shrink());

void main() {
  group('TableCellBuilderDelegate', () {
    test('exposes addAutomaticKeepAlives from super class', () {
      final TableCellBuilderDelegate delegate = TableCellBuilderDelegate(
        cellBuilder: (_, __) => cell,
        columnBuilder: (_) => span,
        rowBuilder: (_) => span,
        columnCount: 5,
        rowCount: 6,
        addAutomaticKeepAlives: false,
      );
      expect(delegate.addAutomaticKeepAlives, isFalse);
    });

    test('asserts  valid counts for rows and columns', () {
      TableCellBuilderDelegate? delegate;
      expect(
        () {
          delegate = TableCellBuilderDelegate(
            cellBuilder: (_, __) => cell,
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            columnCount: 1,
            rowCount: 1,
            pinnedColumnCount: -1, // asserts
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('pinnedColumnCount >= 0'),
          ),
        ),
      );

      expect(
        () {
          delegate = TableCellBuilderDelegate(
            cellBuilder: (_, __) => cell,
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            columnCount: 1,
            rowCount: 1,
            pinnedRowCount: -1, // asserts
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('pinnedRowCount >= 0'),
          ),
        ),
      );

      expect(
        () {
          delegate = TableCellBuilderDelegate(
            cellBuilder: (_, __) => cell,
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            columnCount: 1,
            rowCount: -1, // asserts
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('rowCount >= 0'),
          ),
        ),
      );

      expect(
        () {
          delegate = TableCellBuilderDelegate(
            cellBuilder: (_, __) => cell,
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            columnCount: -1, // asserts
            rowCount: 1,
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('columnCount >= 0'),
          ),
        ),
      );

      expect(
        () {
          delegate = TableCellBuilderDelegate(
            cellBuilder: (_, __) => cell,
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            columnCount: 1,
            pinnedColumnCount: 2, // asserts
            rowCount: 1,
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('pinnedColumnCount <= columnCount'),
          ),
        ),
      );

      expect(
        () {
          delegate = TableCellBuilderDelegate(
            cellBuilder: (_, __) => cell,
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            columnCount: 1,
            pinnedRowCount: 2, // asserts
            rowCount: 1,
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('pinnedRowCount <= rowCount'),
          ),
        ),
      );

      expect(delegate, isNull);
    });

    test('sets max x and y index of super class', () {
      final TableCellBuilderDelegate delegate = TableCellBuilderDelegate(
        cellBuilder: (_, __) => cell,
        columnBuilder: (_) => span,
        rowBuilder: (_) => span,
        columnCount: 5,
        rowCount: 6,
      );
      expect(delegate.maxYIndex, 5); // rows
      expect(delegate.maxXIndex, 4); // columns
    });

    test('Respects super class default for addRepaintBoundaries', () {
      final TableCellBuilderDelegate delegate = TableCellBuilderDelegate(
        cellBuilder: (_, __) => cell,
        columnBuilder: (_) => span,
        rowBuilder: (_) => span,
        columnCount: 1,
        rowCount: 1,
      );
      expect(delegate.addRepaintBoundaries, isFalse);
      expect(cell.addRepaintBoundaries, isTrue);
    });

    test('Notifies listeners & rebuilds', () {
      int notified = 0;
      TableCellBuilderDelegate oldDelegate;
      TableSpan spanBuilder(int index) => span;
      TableViewCell cellBuilder(BuildContext context, TableVicinity vicinity) {
        return cell;
      }

      final TableCellBuilderDelegate delegate = TableCellBuilderDelegate(
        cellBuilder: cellBuilder,
        columnBuilder: spanBuilder,
        rowBuilder: spanBuilder,
        columnCount: 5,
        pinnedColumnCount: 1,
        rowCount: 6,
        pinnedRowCount: 2,
      );
      delegate.addListener(() {
        notified++;
      });

      // change column count
      oldDelegate = delegate;
      delegate.columnCount = 6;
      expect(notified, 1);
      expect(delegate.shouldRebuild(oldDelegate), isTrue);

      // change pinned column count
      oldDelegate = delegate;
      delegate.pinnedColumnCount = 2;
      expect(notified, 2);
      expect(delegate.shouldRebuild(oldDelegate), isTrue);

      // change row count
      oldDelegate = delegate;
      delegate.rowCount = 7;
      expect(notified, 3);
      expect(delegate.shouldRebuild(oldDelegate), isTrue);

      // change pinned row count
      oldDelegate = delegate;
      delegate.pinnedRowCount = 3;
      expect(notified, 4);
      expect(delegate.shouldRebuild(oldDelegate), isTrue);

      // Builder delegate always returns true.
      expect(delegate.shouldRebuild(delegate), isTrue);
    });
  });

  group('TableCellListDelegate', () {
    test('exposes addAutomaticKeepAlives from super class', () {
      final TableCellListDelegate delegate = TableCellListDelegate(
        cells: <List<TableViewCell>>[<TableViewCell>[]],
        columnBuilder: (_) => span,
        rowBuilder: (_) => span,
        addAutomaticKeepAlives: false,
      );
      expect(delegate.addAutomaticKeepAlives, isFalse);
    });

    test('asserts  valid counts for rows and columns', () {
      TableCellListDelegate? delegate;
      expect(
        () {
          delegate = TableCellListDelegate(
            cells: <List<TableViewCell>>[<TableViewCell>[]],
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            pinnedColumnCount: -1, // asserts
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('pinnedColumnCount >= 0'),
          ),
        ),
      );
      expect(
        () {
          delegate = TableCellListDelegate(
            cells: <List<TableViewCell>>[<TableViewCell>[]],
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            pinnedRowCount: -1, // asserts
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('pinnedRowCount >= 0'),
          ),
        ),
      );
      expect(
        () {
          delegate = TableCellListDelegate(
            cells: <List<TableViewCell>>[
              <TableViewCell>[cell, cell],
              <TableViewCell>[cell, cell],
            ],
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            pinnedRowCount: 3, // asserts
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('rowCount >= pinnedRowCount'),
          ),
        ),
      );
      expect(
        () {
          delegate = TableCellListDelegate(
            cells: <List<TableViewCell>>[
              <TableViewCell>[cell, cell],
              <TableViewCell>[cell, cell],
            ],
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            pinnedColumnCount: 3, // asserts
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('columnCount >= pinnedColumnCount'),
          ),
        ),
      );
      expect(delegate, isNull);
    });

    test('Asserts child lists lengths match', () {
      TableCellListDelegate? delegate;
      expect(
        () {
          delegate = TableCellListDelegate(
            cells: <List<TableViewCell>>[
              <TableViewCell>[cell, cell],
              <TableViewCell>[cell, cell, cell],
            ],
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains(
                'Each list of Widgets within cells must be of the same length.'),
          ),
        ),
      );
      expect(delegate, isNull);
    });

    test('Notifies listeners & rebuilds', () {
      int notified = 0;
      TableCellListDelegate oldDelegate;
      TableSpan spanBuilder(int index) => span;
      TableCellListDelegate delegate = TableCellListDelegate(
        cells: <List<TableViewCell>>[
          <TableViewCell>[cell, cell],
          <TableViewCell>[cell, cell],
        ],
        columnBuilder: spanBuilder,
        rowBuilder: spanBuilder,
        pinnedColumnCount: 1,
        pinnedRowCount: 1,
      );
      delegate.addListener(() {
        notified++;
      });

      // change pinned column count
      oldDelegate = delegate;
      delegate.pinnedColumnCount = 0;
      expect(notified, 1);

      // change pinned row count
      oldDelegate = delegate;
      delegate.pinnedRowCount = 0;
      expect(notified, 2);

      // shouldRebuild
      // columnCount
      oldDelegate = delegate;
      delegate = TableCellListDelegate(
        cells: <List<TableViewCell>>[
          <TableViewCell>[cell, cell, cell],
          <TableViewCell>[cell, cell, cell],
        ],
        columnBuilder: spanBuilder,
        rowBuilder: spanBuilder,
      );
      expect(delegate.shouldRebuild(oldDelegate), isTrue);

      // columnBuilder
      oldDelegate = delegate;
      delegate = TableCellListDelegate(
        cells: <List<TableViewCell>>[
          <TableViewCell>[cell, cell, cell],
          <TableViewCell>[cell, cell, cell],
        ],
        columnBuilder: (int index) => const TableSpan(
          extent: FixedTableSpanExtent(150),
        ),
        rowBuilder: spanBuilder,
      );
      expect(delegate.shouldRebuild(oldDelegate), isTrue);

      // rowCount
      oldDelegate = delegate;
      delegate = TableCellListDelegate(
        cells: <List<TableViewCell>>[
          <TableViewCell>[cell, cell, cell],
          <TableViewCell>[cell, cell, cell],
          <TableViewCell>[cell, cell, cell],
        ],
        columnBuilder: (int index) => const TableSpan(
          extent: FixedTableSpanExtent(150),
        ),
        rowBuilder: spanBuilder,
      );
      expect(delegate.shouldRebuild(oldDelegate), isTrue);

      // rowBuilder
      oldDelegate = delegate;
      delegate = TableCellListDelegate(
        cells: <List<TableViewCell>>[
          <TableViewCell>[cell, cell, cell],
          <TableViewCell>[cell, cell, cell],
          <TableViewCell>[cell, cell, cell],
        ],
        columnBuilder: (int index) => const TableSpan(
          extent: FixedTableSpanExtent(150),
        ),
        rowBuilder: (int index) => const TableSpan(
          extent: RemainingTableSpanExtent(),
        ),
      );
      expect(delegate.shouldRebuild(oldDelegate), isTrue);

      // pinned row count
      oldDelegate = delegate;
      delegate = TableCellListDelegate(
        cells: <List<TableViewCell>>[
          <TableViewCell>[cell, cell, cell],
          <TableViewCell>[cell, cell, cell],
          <TableViewCell>[cell, cell, cell],
        ],
        columnBuilder: (int index) => const TableSpan(
          extent: FixedTableSpanExtent(150),
        ),
        rowBuilder: (int index) => const TableSpan(
          extent: RemainingTableSpanExtent(),
        ),
        pinnedRowCount: 2,
      );
      expect(delegate.shouldRebuild(oldDelegate), isTrue);

      // pinned column count
      oldDelegate = delegate;
      delegate = TableCellListDelegate(
        cells: <List<TableViewCell>>[
          <TableViewCell>[cell, cell, cell],
          <TableViewCell>[cell, cell, cell],
          <TableViewCell>[cell, cell, cell],
        ],
        columnBuilder: (int index) => const TableSpan(
          extent: FixedTableSpanExtent(150),
        ),
        rowBuilder: (int index) => const TableSpan(
          extent: RemainingTableSpanExtent(),
        ),
        pinnedColumnCount: 2,
        pinnedRowCount: 2,
      );
      expect(delegate.shouldRebuild(oldDelegate), isTrue);

      // Nothing changed
      expect(delegate.shouldRebuild(delegate), isFalse);
    });

    test('Changing pinned row and column counts asserts valid values', () {
      final TableCellListDelegate delegate = TableCellListDelegate(
        cells: <List<TableViewCell>>[
          <TableViewCell>[cell, cell, cell],
          <TableViewCell>[cell, cell, cell],
          <TableViewCell>[cell, cell, cell],
        ],
        columnBuilder: (int index) => const TableSpan(
          extent: FixedTableSpanExtent(150),
        ),
        rowBuilder: (int index) => const TableSpan(
          extent: RemainingTableSpanExtent(),
        ),
        pinnedColumnCount: 2,
        pinnedRowCount: 2,
      );

      expect(
        () {
          delegate.pinnedColumnCount = -1;
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('value >= 0'),
          ),
        ),
      );

      expect(
        () {
          delegate.pinnedRowCount = -1;
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('value >= 0'),
          ),
        ),
      );

      expect(
        () {
          delegate.pinnedColumnCount = 4;
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('value <= columnCount'),
          ),
        ),
      );

      expect(
        () {
          delegate.pinnedRowCount = 4;
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('value <= rowCount'),
          ),
        ),
      );
    });
  });
}
