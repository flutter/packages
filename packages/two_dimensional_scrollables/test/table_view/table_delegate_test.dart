// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/table_view.dart';

const TableSpan span = TableSpan(extent: FixedTableSpanExtent(50));
const Widget cell = SizedBox.shrink();

void main() {
  group('TableCellBuilderDelegate', () {
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

    test('Notifies listeners & rebuilds', () {
      int notified = 0;
      TableCellBuilderDelegate oldDelegate;
      TableSpan spanBuilder(int index) => span;
      Widget cellBuilder(BuildContext context, TableVicinity vicinity) => cell;
      TableCellBuilderDelegate delegate = TableCellBuilderDelegate(
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
      delegate = TableCellBuilderDelegate(
        cellBuilder: cellBuilder,
        columnBuilder: spanBuilder,
        rowBuilder: spanBuilder,
        columnCount: 6,
        pinnedColumnCount: 1,
        rowCount: 6,
        pinnedRowCount: 2,
      );
      expect(notified, 1);
      expect(oldDelegate.shouldRebuild(oldDelegate), isTrue);

      // change column builder
      oldDelegate = delegate;
      delegate = TableCellBuilderDelegate(
        cellBuilder: cellBuilder,
        columnBuilder: (_) =>
            const TableSpan(extent: FixedTableSpanExtent(100)),
        rowBuilder: spanBuilder,
        columnCount: 6,
        pinnedColumnCount: 1,
        rowCount: 6,
        pinnedRowCount: 2,
      );
      expect(notified, 2);
      expect(oldDelegate.shouldRebuild(oldDelegate), isTrue);

      // change pinned column count
      oldDelegate = delegate;
      delegate = TableCellBuilderDelegate(
        cellBuilder: cellBuilder,
        columnBuilder: (_) =>
            const TableSpan(extent: FixedTableSpanExtent(100)),
        rowBuilder: spanBuilder,
        columnCount: 6,
        pinnedColumnCount: 2,
        rowCount: 6,
        pinnedRowCount: 2,
      );
      expect(notified, 3);
      expect(oldDelegate.shouldRebuild(oldDelegate), isTrue);

      // change row count
      oldDelegate = delegate;
      delegate = TableCellBuilderDelegate(
        cellBuilder: cellBuilder,
        columnBuilder: (_) =>
            const TableSpan(extent: FixedTableSpanExtent(100)),
        rowBuilder: spanBuilder,
        columnCount: 6,
        pinnedColumnCount: 2,
        rowCount: 7,
        pinnedRowCount: 2,
      );
      expect(notified, 4);
      expect(oldDelegate.shouldRebuild(oldDelegate), isTrue);

      // change row builder
      oldDelegate = delegate;
      delegate = TableCellBuilderDelegate(
        cellBuilder: cellBuilder,
        columnBuilder: (_) =>
            const TableSpan(extent: FixedTableSpanExtent(100)),
        rowBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(100)),
        columnCount: 6,
        pinnedColumnCount: 2,
        rowCount: 7,
        pinnedRowCount: 2,
      );
      expect(notified, 5);
      expect(oldDelegate.shouldRebuild(oldDelegate), isTrue);

      // change pinned row count
      oldDelegate = delegate;
      delegate = TableCellBuilderDelegate(
        cellBuilder: cellBuilder,
        columnBuilder: (_) =>
            const TableSpan(extent: FixedTableSpanExtent(100)),
        rowBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(100)),
        columnCount: 6,
        pinnedColumnCount: 2,
        rowCount: 7,
        pinnedRowCount: 3,
      );
      expect(notified, 6);
      expect(oldDelegate.shouldRebuild(oldDelegate), isTrue);

      // change cell builder
      oldDelegate = delegate;
      delegate = TableCellBuilderDelegate(
        cellBuilder: (_, __) => Container(),
        columnBuilder: (_) =>
            const TableSpan(extent: FixedTableSpanExtent(100)),
        rowBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(100)),
        columnCount: 6,
        pinnedColumnCount: 2,
        rowCount: 7,
        pinnedRowCount: 3,
      );
      expect(notified, 7);
      expect(oldDelegate.shouldRebuild(oldDelegate), isTrue);
    });
  });

  group('TableCellListDelegate', () {
    test('asserts  valid counts for rows and columns', () {});

    test('Asserts child lists lengths match', () {});

    test('Notifies listeners & rebuilds', () {
      // change column count
      // change column builder
      // change pinned column count
      // change row count
      // change row builder
      // change pinned row count
      // should rebuild
    });
  });
}
