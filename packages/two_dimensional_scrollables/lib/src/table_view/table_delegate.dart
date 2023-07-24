// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'table.dart';
import 'table_cell.dart';
import 'table_span.dart';

/// Signature for a function that creates a [TableSpan] for a given index of row
/// or column in a [TableView].
typedef TableSpanBuilder = TableSpan Function(int index);

/// Signature for a function that creates a [TableViewCell] for a given
/// [TableVicinity] in a [TableView], but may return null.
///
/// Used by [TableCellBuilderDelegate.builder] to build cells on demand for the
/// table.
typedef TableViewCellBuilder = TableViewCell? Function(
  BuildContext context,
  TableVicinity vicinity,
);

/// A mixin that defines the model for a [TwoDimensionalChildDelegate] to be
/// used with a [TableView].
mixin TableCellDelegateMixin on TwoDimensionalChildDelegate {
  /// The number of columns that the table has content for.
  ///
  /// The [columnBuilder] will be called for indices smaller than the value
  /// provided here to learn more about the extent and visual appearance of a
  /// particular column.
  // TODO(Piinks): land infinite separately, <ISSUE>
  // If null, the table will have an infinite number of columns.
  ///
  /// The value returned by this getter may be an estimate of the total
  /// available columns, but [columnBuilder] must provide a valid
  /// [TableSpan] for all indices smaller than this integer.
  ///
  /// The integer returned by this getter must be larger than (or equal to) the
  /// integer returned by [pinnedColumnCount].
  ///
  /// If the value returned by this getter changes throughout the lifetime of
  /// the delegate object, [notifyListeners] must be called.
  int get columnCount;

  /// The number of rows that the table has content for.
  ///
  /// The [rowBuilder] will be called for indices smaller than the value
  /// provided here to learn more about the extent and visual appearance of a
  /// particular row.
  // TODO(Piinks): land infinite separately, <ISSUE>
  // If null, the table will have an infinite number of rows.
  ///
  /// The value returned by this getter may be an estimate of the total
  /// available rows, but [rowBuilder] must provide a valid
  /// [TableSpan] for all indices smaller than this integer.
  ///
  /// The integer returned by this getter must be larger than (or equal to) the
  /// integer returned by [pinnedRowCount].
  ///
  /// If the value returned by this getter changes throughout the lifetime of
  /// the delegate object, [notifyListeners] must be called.
  int get rowCount;

  /// The number of columns that are permanently shown on the leading vertical
  /// edge of the viewport.
  ///
  /// If scrolling is enabled, other columns will scroll underneath the pinned
  /// columns.
  ///
  /// Just like for regular columns, [columnBuilder] will be consulted for
  /// additional information about the pinned column. The indices of pinned
  /// columns start at zero and go to `pinnedColumnCount - 1`.
  ///
  /// The integer returned by this getter must be smaller than (or equal to) the
  /// integer returned by [columnCount].
  ///
  /// If the value returned by this getter changes throughout the lifetime of
  /// the delegate object, [notifyListeners] must be called.
  int get pinnedColumnCount => 0;

  /// The number of rows that are permanently shown on the leading horizontal
  /// edge of the viewport.
  ///
  /// If scrolling is enabled, other rows will scroll underneath the pinned
  /// rows.
  ///
  /// Just like for regular rows, [rowBuilder] will be consulted for
  /// additional information about the pinned row. The indices of pinned rows
  /// start at zero and go to `pinnedRowCount - 1`.
  ///
  /// The integer returned by this getter must be smaller than (or equal to) the
  /// integer returned by [rowCount].
  ///
  /// If the value returned by this getter changes throughout the lifetime of
  /// the delegate object, [notifyListeners] must be called.
  int get pinnedRowCount => 0;

  /// Builds the [TableSpan] that describes the column at the provided index.
  ///
  /// The builder must return a valid [TableSpan] for all indices smaller than
  /// [columnCount].
  ///
  /// If the value returned by this builder for a particular index changes
  /// throughout the lifetime of the delegate object, [notifyListeners] must be
  /// called.
  TableSpanBuilder get columnBuilder;

  /// Builds the [TableSpan] that describe the row at the provided index.
  ///
  /// The builder must return a valid [TableSpan] for all indices smaller than
  /// [rowCount].
  ///
  /// If the value returned by this builder for a particular index changes
  /// throughout the lifetime of the delegate object, [notifyListeners] must be
  /// called.
  TableSpanBuilder get rowBuilder;
}

/// A delegate that supplies children for a [TableViewport] on demand using a
/// builder callback.
class TableCellBuilderDelegate extends TwoDimensionalChildBuilderDelegate
    with TableCellDelegateMixin {
  /// Creates a lazy building delegate to use with a [TableView].
  TableCellBuilderDelegate({
    required int columnCount,
    required int rowCount,
    int pinnedColumnCount = 0,
    int pinnedRowCount = 0,
    super.addRepaintBoundaries = false,
    required TableViewCellBuilder cellBuilder,
    required TableSpanBuilder columnBuilder,
    required TableSpanBuilder rowBuilder,
  })  : assert(pinnedColumnCount >= 0),
        assert(pinnedRowCount >= 0),
        assert(rowCount >= 0),
        assert(columnCount >= 0),
        _columnCount = columnCount,
        _columnBuilder = columnBuilder,
        _pinnedColumnCount = pinnedColumnCount,
        _rowCount = rowCount,
        _rowBuilder = rowBuilder,
        _pinnedRowCount = pinnedRowCount,
        super(
          builder: (BuildContext context, ChildVicinity vicinity) =>
              cellBuilder(context, vicinity as TableVicinity),
          maxXIndex: columnCount - 1,
          maxYIndex: rowCount - 1,
        );

  @override
  int get columnCount => _columnCount;
  int _columnCount;
  set columnCount(int value) {
    assert(value >= 0);
    if (columnCount == value) {
      return;
    }
    _columnCount = value;
    notifyListeners();
  }

  @override
  TableSpanBuilder get columnBuilder => _columnBuilder;
  TableSpanBuilder _columnBuilder;
  set columnBuilder(TableSpanBuilder value) {
    if (columnBuilder == value) {
      return;
    }
    _columnBuilder = value;
    notifyListeners();
  }

  @override
  int get pinnedColumnCount => _pinnedColumnCount;
  int _pinnedColumnCount;
  set pinnedColumnCount(int value) {
    assert(value >= 0);
    if (pinnedColumnCount == value) {
      return;
    }
    _pinnedColumnCount = value;
    notifyListeners();
  }

  @override
  int get rowCount => _rowCount;
  int _rowCount;
  set rowCount(int value) {
    assert(value >= 0);
    if (rowCount == value) {
      return;
    }
    _rowCount = value;
    notifyListeners();
  }

  @override
  TableSpanBuilder get rowBuilder => _rowBuilder;
  TableSpanBuilder _rowBuilder;
  set rowBuilder(TableSpanBuilder value) {
    if (rowBuilder == value) {
      return;
    }
    _rowBuilder = value;
    notifyListeners();
  }

  @override
  int get pinnedRowCount => _pinnedRowCount;
  int _pinnedRowCount;
  set pinnedRowCount(int value) {
    assert(value >= 0);
    if (pinnedRowCount == value) {
      return;
    }
    _pinnedRowCount = value;
    notifyListeners();
  }
}

/// A delegate that supplies children for a [TableViewport] using an
/// explicit two dimensional array.
class TableCellListDelegate extends TwoDimensionalChildListDelegate
    with TableCellDelegateMixin {
  /// Creates a delegate that supplies children for a [TableView].
  TableCellListDelegate({
    int pinnedColumnCount = 0,
    int pinnedRowCount = 0,
    super.addRepaintBoundaries,
    required List<List<TableViewCell>> cells,
    required TableSpanBuilder columnBuilder,
    required TableSpanBuilder rowBuilder,
  })  : assert(pinnedColumnCount >= 0),
        assert(pinnedRowCount >= 0),
        _columnBuilder = columnBuilder,
        _pinnedColumnCount = pinnedColumnCount,
        _rowBuilder = rowBuilder,
        _pinnedRowCount = pinnedRowCount,
        super(children: cells) {
    // Even if there are merged cells, they should be represented by the same
    // child in each cell location. So all arrays of cells should have the same length.
    assert(
        children.map((List<Widget> array) => array.length).toSet().length == 1);
  }

  @override
  int get columnCount => children[0].length;

  @override
  TableSpanBuilder get columnBuilder => _columnBuilder;
  TableSpanBuilder _columnBuilder;
  set columnBuilder(TableSpanBuilder value) {
    if (columnBuilder == value) {
      return;
    }
    _columnBuilder = value;
    notifyListeners();
  }

  @override
  int get pinnedColumnCount => _pinnedColumnCount;
  int _pinnedColumnCount;
  set pinnedColumnCount(int value) {
    assert(value >= 0);
    if (pinnedColumnCount == value) {
      return;
    }
    _pinnedColumnCount = value;
    notifyListeners();
  }

  @override
  int get rowCount => children.length;

  @override
  TableSpanBuilder get rowBuilder => _rowBuilder;
  TableSpanBuilder _rowBuilder;
  set rowBuilder(TableSpanBuilder value) {
    if (rowBuilder == value) {
      return;
    }
    _rowBuilder = value;
    notifyListeners();
  }

  @override
  int get pinnedRowCount => _pinnedRowCount;
  int _pinnedRowCount;
  set pinnedRowCount(int value) {
    assert(value >= 0);
    if (pinnedRowCount == value) {
      return;
    }
    _pinnedRowCount = value;
    notifyListeners();
  }

  @override
  bool shouldRebuild(covariant TableCellListDelegate oldDelegate) {
    return columnCount != oldDelegate.columnCount ||
        columnBuilder != oldDelegate.columnBuilder ||
        pinnedColumnCount != oldDelegate.pinnedColumnCount ||
        rowCount != oldDelegate.rowCount ||
        rowBuilder != oldDelegate.rowBuilder ||
        pinnedRowCount != oldDelegate.pinnedRowCount ||
        super.shouldRebuild(oldDelegate);
  }
}
