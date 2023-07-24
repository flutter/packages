// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/table_view.dart';

const TableSpan span = TableSpan(extent: FixedTableSpanExtent(50));
const TableViewCell cell = TableViewCell(child: SizedBox.shrink());

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
      expect(delegate, isNull);
    });

    test('sets max x and y index of super class', () {
      TableCellBuilderDelegate delegate = TableCellBuilderDelegate(
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
      // change column count
      // change column builder
      // change pinned column count
      // change row count
      // change row builder
      // change pinned row count
      // should rebuild
    });
  });

  group('TableCellListDelegate', () {
    test('asserts  valid counts for rows and columns', () {
      // constructor
    });

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
