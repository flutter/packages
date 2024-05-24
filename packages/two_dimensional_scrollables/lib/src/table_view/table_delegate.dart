// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'table.dart';
import 'table_cell.dart';
import 'table_span.dart';

/// Signature for a function that creates a [TableSpan] for a given index of row
/// or column in a [TableView].
///
/// Used by the [TableCellDelegateMixin.buildColumn] and
/// [TableCellDelegateMixin.buildRow] to configure rows and columns in the
/// [TableView].
///
/// Returning null from this builder signifies the end of rows or columns being
/// built if a row or column count has not been specified for the table.
typedef TableSpanBuilder = TableSpan? Function(int index);

/// Signature for a function that creates a child [TableViewCell] for a given
/// [TableVicinity] in a [TableView], but may return null.
///
/// Used by [TableCellBuilderDelegate.builder] to build cells on demand for the
/// table.
typedef TableViewCellBuilder = TableViewCell Function(
  BuildContext context,
  TableVicinity vicinity,
);

/// A mixin that defines the model for a [TwoDimensionalChildDelegate] to be
/// used with a [TableView].
mixin TableCellDelegateMixin on TwoDimensionalChildDelegate {
  /// The number of columns that the table has content for.
  ///
  /// The [buildColumn] method will be called for indices smaller than the value
  /// provided here to learn more about the extent and visual appearance of a
  /// particular column. If null, the table will have an infinite number of
  /// columns, unless [buildColumn] returns null to signify the end.
  ///
  /// The value returned by this getter may be an estimate of the total
  /// available columns, but [buildColumn] method must provide a valid
  /// [TableSpan] for all indices smaller than this integer.
  ///
  /// The integer returned by this getter must be larger than (or equal to) the
  /// integer returned by [pinnedColumnCount].
  ///
  /// If the value returned by this getter changes throughout the lifetime of
  /// the delegate object, [notifyListeners] must be called.
  ///
  /// When null, the number of columns will be infinite in number, unless null
  /// is returned from [TableCellBuilderDelegate.columnBuilder]. The
  /// [TableCellListDelegate] does not support an infinite number of columns.
  int? get columnCount;

  /// The number of rows that the table has content for.
  ///
  /// The [buildRow] method will be called for indices smaller than the value
  /// provided here to learn more about the extent and visual appearance of a
  /// particular row. If null, the table will have an infinite number of rows,
  /// unless [buildRow] returns null to signify the end.
  ///
  /// The value returned by this getter may be an estimate of the total
  /// available rows, but [buildRow] method must provide a valid
  /// [TableSpan] for all indices smaller than this integer.
  ///
  /// The integer returned by this getter must be larger than (or equal to) the
  /// integer returned by [pinnedRowCount].
  ///
  /// If the value returned by this getter changes throughout the lifetime of
  /// the delegate object, [notifyListeners] must be called.
  ///
  /// When null, the number of rows will be infinite in number, unless null
  /// is returned from [TableCellBuilderDelegate.rowBuilder]. The
  /// [TableCellListDelegate] does not support an infinite number of rows.
  int? get rowCount;

  /// The number of columns that are permanently shown on the leading vertical
  /// edge of the viewport.
  ///
  /// If scrolling is enabled, other columns will scroll underneath the pinned
  /// columns.
  ///
  /// Just like for regular columns, [buildColumn] method will be consulted for
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
  /// Just like for regular rows, [buildRow] will be consulted for
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
  /// [columnCount]. If [columnCount] is null, the number of columns will be
  /// infinite, unless this builder returns null to signal the end of the
  /// columns.
  TableSpan? buildColumn(int index);

  /// Builds the [TableSpan] that describe the row at the provided index.
  ///
  /// The builder must return a valid [TableSpan] for all indices smaller than
  /// [rowCount]. If [rowCount] is null, the number of rows will be
  /// infinite, unless this builder returns null to signal the end of the
  /// columns.
  TableSpan? buildRow(int index);
}

/// A delegate that supplies children for a [TableViewport] on demand using a
/// builder callback.
///
/// Unlike the base [TwoDimensionalChildBuilderDelegate] this delegate does not
/// automatically insert repaint boundaries. Instead, repaint boundaries are
/// controlled by [TableViewCell.addRepaintBoundaries].
///
/// If the [rowCount] or [columnCount] is not provided, the number of rows
/// and/or columns will be infinite. Returning null from the [columnBuilder]
/// and/or [rowBuilder] in this case can terminate the number of rows and
/// columns at the given index.
class TableCellBuilderDelegate extends TwoDimensionalChildBuilderDelegate
    with TableCellDelegateMixin {
  /// Creates a lazy building delegate to use with a [TableView].
  TableCellBuilderDelegate({
    int? columnCount,
    int? rowCount,
    int pinnedColumnCount = 0,
    int pinnedRowCount = 0,
    super.addAutomaticKeepAlives,
    required TableViewCellBuilder cellBuilder,
    required TableSpanBuilder columnBuilder,
    required TableSpanBuilder rowBuilder,
  })  : assert(pinnedColumnCount >= 0),
        assert(pinnedRowCount >= 0),
        assert(rowCount == null || rowCount >= 0),
        assert(columnCount == null || columnCount >= 0),
        assert(columnCount == null || pinnedColumnCount <= columnCount),
        assert(rowCount == null || pinnedRowCount <= rowCount),
        _rowBuilder = rowBuilder,
        _columnBuilder = columnBuilder,
        _pinnedColumnCount = pinnedColumnCount,
        _pinnedRowCount = pinnedRowCount,
        super(
          builder: (BuildContext context, ChildVicinity vicinity) =>
              cellBuilder(context, vicinity as TableVicinity),
          maxXIndex: columnCount == null ? columnCount : columnCount - 1,
          maxYIndex: rowCount == null ? rowCount : rowCount - 1,
          // repaintBoundaries handled by TableViewCell
          addRepaintBoundaries: false,
        );

  @override
  int? get columnCount => maxXIndex == null ? null : maxXIndex! + 1;

  set columnCount(int? value) {
    assert(value == null || pinnedColumnCount <= value);
    maxXIndex = value == null ? null : value - 1;
  }

  /// Builds the [TableSpan] that describes the column at the provided index.
  ///
  /// The builder must return a valid [TableSpan] for all indices smaller than
  /// [columnCount]. If [columnCount] is null, the number of columns will be
  /// infinite, unless this builder returns null to signal the end of the
  /// columns.
  final TableSpanBuilder _columnBuilder;
  @override
  TableSpan? buildColumn(int index) => _columnBuilder(index);

  @override
  int get pinnedColumnCount => _pinnedColumnCount;
  int _pinnedColumnCount;
  set pinnedColumnCount(int value) {
    assert(value >= 0);
    assert(columnCount == null || value <= columnCount!);
    if (pinnedColumnCount == value) {
      return;
    }
    _pinnedColumnCount = value;
    notifyListeners();
  }

  @override
  int? get rowCount => maxYIndex == null ? null : maxYIndex! + 1;

  set rowCount(int? value) {
    assert(value == null || pinnedRowCount <= value);
    maxYIndex = value == null ? null : value - 1;
  }

  /// Builds the [TableSpan] that describes the row at the provided index.
  ///
  /// The builder must return a valid [TableSpan] for all indices smaller than
  /// [rowCount]. If [rowCount] is null, the number of rows will be
  /// infinite, unless this builder returns null to signal the end of the
  /// rows.
  final TableSpanBuilder _rowBuilder;
  @override
  TableSpan? buildRow(int index) => _rowBuilder(index);

  @override
  int get pinnedRowCount => _pinnedRowCount;
  int _pinnedRowCount;
  set pinnedRowCount(int value) {
    assert(value >= 0);
    assert(rowCount == null || value <= rowCount!);
    if (pinnedRowCount == value) {
      return;
    }
    _pinnedRowCount = value;
    notifyListeners();
  }
}

/// A delegate that supplies children for a [TableViewport] using an
/// explicit two dimensional array.
///
/// The [children] are accessed for each [TableVicinity.row] and
/// [TableVicinity.column] of the [TwoDimensionalViewport] as
/// `children[vicinity.row][vicinity.column]`.
///
/// Unlike the base [TwoDimensionalChildBuilderDelegate] this delegate does not
/// automatically insert repaint boundaries. Instead, repaint boundaries are
/// controlled by [TableViewCell.addRepaintBoundaries].
class TableCellListDelegate extends TwoDimensionalChildListDelegate
    with TableCellDelegateMixin {
  /// Creates a delegate that supplies children for a [TableView].
  TableCellListDelegate({
    int pinnedColumnCount = 0,
    int pinnedRowCount = 0,
    super.addAutomaticKeepAlives,
    required List<List<TableViewCell>> cells,
    required TableSpanBuilder columnBuilder,
    required TableSpanBuilder rowBuilder,
  })  : assert(pinnedColumnCount >= 0),
        assert(pinnedRowCount >= 0),
        _columnBuilder = columnBuilder,
        _rowBuilder = rowBuilder,
        _pinnedColumnCount = pinnedColumnCount,
        _pinnedRowCount = pinnedRowCount,
        super(
          children: cells,
          // repaintBoundaries handled by TableViewCell
          addRepaintBoundaries: false,
        ) {
    // Even if there are merged cells, they should be represented by the same
    // child in each cell location. This ensures that no matter which direction
    // the merged cell scrolls into view from, we can build the correct child
    // without having to explore all possible vicinities of the merged cell
    // area. So all arrays of cells should have the same length.
    assert(
      children.map((List<Widget> array) => array.length).toSet().length == 1,
      'Each list of Widgets within cells must be of the same length.',
    );
    assert(rowCount >= pinnedRowCount);
    assert(columnCount >= pinnedColumnCount);
  }

  @override
  int get columnCount => children.isEmpty ? 0 : children[0].length;

  /// Builds the [TableSpan] that describes the column at the provided index.
  ///
  /// The builder must return a valid [TableSpan] for all indices smaller than
  /// [columnCount].
  final TableSpanBuilder _columnBuilder;
  @override
  TableSpan? buildColumn(int index) {
    if (index >= columnCount) {
      // The list delegate has a finite number of columns.
      return null;
    }
    return _columnBuilder(index);
  }

  @override
  int get pinnedColumnCount => _pinnedColumnCount;
  int _pinnedColumnCount;
  set pinnedColumnCount(int value) {
    assert(value >= 0);
    assert(value <= columnCount);
    if (pinnedColumnCount == value) {
      return;
    }
    _pinnedColumnCount = value;
    notifyListeners();
  }

  @override
  int get rowCount => children.length;

  /// Builds the [TableSpan] that describes the row at the provided index.
  ///
  /// The builder must return a valid [TableSpan] for all indices smaller than
  /// [rowCount].
  final TableSpanBuilder _rowBuilder;
  @override
  TableSpan? buildRow(int index) {
    if (index >= rowCount) {
      // The list deleagte has a finite number of rows.
      return null;
    }
    return _rowBuilder(index);
  }

  @override
  int get pinnedRowCount => _pinnedRowCount;
  int _pinnedRowCount;
  set pinnedRowCount(int value) {
    assert(value >= 0);
    assert(value <= rowCount);
    if (pinnedRowCount == value) {
      return;
    }
    _pinnedRowCount = value;
    notifyListeners();
  }

  @override
  bool shouldRebuild(covariant TableCellListDelegate oldDelegate) {
    return columnCount != oldDelegate.columnCount ||
        _columnBuilder != oldDelegate._columnBuilder ||
        pinnedColumnCount != oldDelegate.pinnedColumnCount ||
        rowCount != oldDelegate.rowCount ||
        _rowBuilder != oldDelegate._rowBuilder ||
        pinnedRowCount != oldDelegate.pinnedRowCount ||
        super.shouldRebuild(oldDelegate);
  }
}
