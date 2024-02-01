// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'table_cell.dart';
import 'table_delegate.dart';
import 'table_span.dart';

/// A widget that displays a table, which can scroll in horizontal and vertical
/// directions.
///
/// A table consists of rows and columns. Rows fill the horizontal space of
/// the table, while columns fill it vertically. If there is not enough space
/// available to display all the rows at the same time, the table will scroll
/// vertically. If there is not enough space for all the columns, it will
/// scroll horizontally.
///
/// Each child [TableViewCell] can belong to either exactly one row and one
/// column as represented by its [TableVicinity], or it can span multiple rows
/// and columns through merging. The table supports lazy rendering and will only
/// instantiate those cells that are currently visible in the table's viewport
/// and those that extend into the [cacheExtent]. Therefore, when merging cells
/// in a [TableView], the same child must be returned from every vicinity the
/// merged cell contains. The `build` method will only be called once for a
/// merged cell, but since the table's children are lazily laid out, returning
/// the same child ensures the merged cell can be built no matter which part of
/// it is visible.
///
/// The layout of the table (e.g. how many rows/columns there are and their
/// extents) as well as the content of the individual cells is defined by
/// the provided [delegate], a subclass of [TwoDimensionalChildDelegate] with
/// the [TableCellDelegateMixin]. The [TableView.builder] and [TableView.list]
/// constructors create their own delegate.
///
/// This example shows a TableView of 100 children, all sized 100 by 100
/// pixels with a few [TableSpanDecoration]s like background colors and borders.
/// The `builder` constructor is called on demand for the cells that are visible
/// in the TableView.
///
/// ```dart
/// TableView.builder(
///   cellBuilder: (BuildContext context, TableVicinity vicinity) {
///     return Center(
///       child: Text('Cell ${vicinity.column} : ${vicinity.row}'),
///     );
///   },
///   columnCount: 10,
///   columnBuilder: (int column) {
///     return TableSpan(
///       extent: FixedTableSpanExtent(100),
///       foregroundDecoration: TableSpanDecoration(
///         border: TableSpanBorder(
///           trailing: BorderSide(
///            color: Colors.black,
///            width: 2,
///            style: BorderStyle.solid,
///           ),
///         ),
///       ),
///     );
///   },
///   rowCount: 10,
///   rowBuilder: (int row) {
///     return TableSpan(
///       extent: FixedTableSpanExtent(100),
///       backgroundDecoration: TableSpanDecoration(
///         color: row.isEven? Colors.blueAccent[100] : Colors.white,
///       ),
///     );
///   },
/// );
/// ```
///
/// See also:
///
///  * [TableSpan], describes the configuration for a row or column in the
///    TableView.
///  * [TwoDimensionalScrollView], the super class that is extended by TableView.
///  * [GridView], another scrolling widget that can be used to create tables
///    that scroll in one dimension.
class TableView extends TwoDimensionalScrollView {
  /// Creates a [TableView] that scrolls in both dimensions.
  ///
  /// A non-null [delegate] must be provided.
  const TableView({
    super.key,
    super.primary,
    super.mainAxis,
    super.horizontalDetails,
    super.verticalDetails,
    super.cacheExtent,
    required TableCellDelegateMixin super.delegate,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.clipBehavior,
  });

  /// Creates a [TableView] of widgets that are created on demand.
  ///
  /// This constructor is appropriate for table views with a large
  /// number of cells because the [cellbuilder] is called only for those
  /// cells that are actually visible.
  ///
  /// This constructor generates a [TableCellBuilderDelegate] for building
  /// children on demand using the required [cellBuilder],
  /// [columnBuilder], and [rowBuilder].
  TableView.builder({
    super.key,
    super.primary,
    super.mainAxis,
    super.horizontalDetails,
    super.verticalDetails,
    super.cacheExtent,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.clipBehavior,
    int pinnedRowCount = 0,
    int pinnedColumnCount = 0,
    required int columnCount,
    required int rowCount,
    required TableSpanBuilder columnBuilder,
    required TableSpanBuilder rowBuilder,
    required TableViewCellBuilder cellBuilder,
  })  : assert(pinnedRowCount >= 0),
        assert(rowCount >= 0),
        assert(rowCount >= pinnedRowCount),
        assert(columnCount >= 0),
        assert(pinnedColumnCount >= 0),
        assert(columnCount >= pinnedColumnCount),
        super(
          delegate: TableCellBuilderDelegate(
            columnCount: columnCount,
            rowCount: rowCount,
            pinnedColumnCount: pinnedColumnCount,
            pinnedRowCount: pinnedRowCount,
            cellBuilder: cellBuilder,
            columnBuilder: columnBuilder,
            rowBuilder: rowBuilder,
          ),
        );

  /// Creates a [TableView] from an explicit two dimensional array of children.
  ///
  /// This constructor is appropriate for list views with a small number of
  /// children because constructing the [List] requires doing work for every
  /// child that could possibly be displayed in the list view instead of just
  /// those children that are actually visible.
  ///
  /// The [children] are accessed for each [TableVicinity.column] and
  /// [TableVicinity.row] of the [TwoDimensionalViewport] as
  /// `children[vicinity.column][vicinity.row]`.
  TableView.list({
    super.key,
    super.primary,
    super.mainAxis,
    super.horizontalDetails,
    super.verticalDetails,
    super.cacheExtent,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.clipBehavior,
    int pinnedRowCount = 0,
    int pinnedColumnCount = 0,
    required TableSpanBuilder columnBuilder,
    required TableSpanBuilder rowBuilder,
    List<List<TableViewCell>> cells = const <List<TableViewCell>>[],
  })  : assert(pinnedRowCount >= 0),
        assert(pinnedColumnCount >= 0),
        super(
          delegate: TableCellListDelegate(
            pinnedColumnCount: pinnedColumnCount,
            pinnedRowCount: pinnedRowCount,
            cells: cells,
            columnBuilder: columnBuilder,
            rowBuilder: rowBuilder,
          ),
        );

  @override
  TableViewport buildViewport(
    BuildContext context,
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  ) {
    return TableViewport(
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalDetails.direction,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalDetails.direction,
      delegate: delegate as TableCellDelegateMixin,
      mainAxis: mainAxis,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }
}

/// A widget through which a portion of a Table of [Widget] children are viewed,
/// typically in combination with a [TableView].
class TableViewport extends TwoDimensionalViewport {
  /// Creates a viewport for [Widget]s that extend and scroll in both
  /// horizontal and vertical dimensions.
  const TableViewport({
    super.key,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required TableCellDelegateMixin super.delegate,
    required super.mainAxis,
    super.cacheExtent,
    super.clipBehavior,
  });

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return RenderTableViewport(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      mainAxis: mainAxis,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      delegate: delegate as TableCellDelegateMixin,
      childManager: context as TwoDimensionalChildManager,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTableViewport renderObject,
  ) {
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..mainAxis = mainAxis
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior
      ..delegate = delegate as TableCellDelegateMixin;
  }
}

/// A render object for viewing [RenderBox]es in a table format that extends in
/// both the horizontal and vertical dimensions.
///
/// [RenderTableViewport] is the visual workhorse of the [TableView]. It
/// displays a subset of its children according to its own dimensions and the
/// given [verticalOffset] and [horizontalOffset]. As the offset varies,
/// different children are visible through the viewport.
class RenderTableViewport extends RenderTwoDimensionalViewport {
  /// Creates a viewport for [RenderBox] objects in a table format of rows and
  /// columns.
  RenderTableViewport({
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required TableCellDelegateMixin super.delegate,
    required super.mainAxis,
    required super.childManager,
    super.cacheExtent,
    super.clipBehavior,
  });

  @override
  TableCellDelegateMixin get delegate =>
      super.delegate as TableCellDelegateMixin;
  @override
  set delegate(TableCellDelegateMixin value) {
    super.delegate = value;
  }

  // Skipped vicinities for the current frame based on merged cells.
  // This prevents multiple build calls for the same cell that spans multiple
  // vicinities.
  // The key represents a skipped vicinity, the value is the resolved vicinity
  // of the merged child.
  final Map<TableVicinity, TableVicinity> _mergedVicinities =
      <TableVicinity, TableVicinity>{};
  // These contain the indexes of rows/columns that contain merged cells to
  // optimize decoration drawing for rows/columns that don't contain merged
  // cells.
  final List<int> _mergedRows = <int>[];
  final List<int> _mergedColumns = <int>[];

  // Cached Table metrics
  Map<int, _Span> _columnMetrics = <int, _Span>{};
  Map<int, _Span> _rowMetrics = <int, _Span>{};
  int? _firstNonPinnedRow;
  int? _firstNonPinnedColumn;
  int? _lastNonPinnedRow;
  int? _lastNonPinnedColumn;

  TableVicinity? get _firstNonPinnedCell {
    if (_firstNonPinnedRow == null || _firstNonPinnedColumn == null) {
      return null;
    }
    return TableVicinity(
      column: _firstNonPinnedColumn!,
      row: _firstNonPinnedRow!,
    );
  }

  TableVicinity? get _lastNonPinnedCell {
    if (_lastNonPinnedRow == null || _lastNonPinnedColumn == null) {
      return null;
    }
    return TableVicinity(
      column: _lastNonPinnedColumn!,
      row: _lastNonPinnedRow!,
    );
  }

  // TODO(Piinks): Pinned rows/cols do not account for what is visible on the
  //  screen. Ostensibly, we would not want to have pinned rows/columns that
  //  extend beyond the viewport, we would never see them as they would never
  //  scroll into view. So this currently implementation is fairly assuming
  //  we will never have rows/cols that are outside of the viewport. We should
  //  maybe add an assertion for this during layout.
  // https://github.com/flutter/flutter/issues/136833
  int? get _lastPinnedRow =>
      delegate.pinnedRowCount > 0 ? delegate.pinnedRowCount - 1 : null;
  int? get _lastPinnedColumn =>
      delegate.pinnedColumnCount > 0 ? delegate.pinnedColumnCount - 1 : null;

  double get _pinnedRowsExtent => _lastPinnedRow != null
      ? _rowMetrics[_lastPinnedRow]!.trailingOffset
      : 0.0;
  double get _pinnedColumnsExtent => _lastPinnedColumn != null
      ? _columnMetrics[_lastPinnedColumn]!.trailingOffset
      : 0.0;

  @override
  TableViewParentData parentDataOf(RenderBox child) =>
      super.parentDataOf(child) as TableViewParentData;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TableViewParentData) {
      child.parentData = TableViewParentData();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? cell = firstChild;
    while (cell != null) {
      final TableViewParentData cellParentData = parentDataOf(cell);
      if (!cellParentData.isVisible) {
        // This cell is not visible, so it cannot be hit.
        cell = childAfter(cell);
        continue;
      }
      final Rect cellRect = cellParentData.paintOffset! & cell.size;
      if (cellRect.contains(position)) {
        result.addWithPaintOffset(
          offset: cellParentData.paintOffset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformed) {
            assert(transformed == position - cellParentData.paintOffset!);
            return cell!.hitTest(result, position: transformed);
          },
        );
        switch (mainAxis) {
          case Axis.vertical:
            // Row major order, rows go first.
            result.add(
              HitTestEntry(_rowMetrics[cellParentData.tableVicinity.row]!),
            );
            result.add(
              HitTestEntry(
                  _columnMetrics[cellParentData.tableVicinity.column]!),
            );
          case Axis.horizontal:
            // Column major order, columns go first.
            result.add(
              HitTestEntry(
                  _columnMetrics[cellParentData.tableVicinity.column]!),
            );
            result.add(
              HitTestEntry(_rowMetrics[cellParentData.tableVicinity.row]!),
            );
        }
        return true;
      }
      cell = childAfter(cell);
    }
    return false;
  }

  // Updates the cached metrics for the table.
  //
  // Will iterate through all columns and rows to define the layout pattern of
  // the cells of the table.
  //
  // TODO(Piinks): Add back infinite separately for easier review, https://github.com/flutter/flutter/issues/131226
  // Only relevant when the number of rows and columns is finite
  void _updateAllMetrics() {
    assert(needsDelegateRebuild || didResize);

    _firstNonPinnedColumn = null;
    _lastNonPinnedColumn = null;
    double startOfRegularColumn = 0;
    double startOfPinnedColumn = 0;

    final Map<int, _Span> newColumnMetrics = <int, _Span>{};
    for (int column = 0; column < delegate.columnCount; column++) {
      final bool isPinned = column < delegate.pinnedColumnCount;
      final double leadingOffset =
          isPinned ? startOfPinnedColumn : startOfRegularColumn;
      _Span? span = _columnMetrics.remove(column);
      assert(needsDelegateRebuild || span != null);
      final TableSpan configuration = needsDelegateRebuild
          ? delegate.buildColumn(column)
          : span!.configuration;
      span ??= _Span();
      span.update(
        isPinned: isPinned,
        configuration: configuration,
        leadingOffset: leadingOffset,
        extent: configuration.extent.calculateExtent(
          TableSpanExtentDelegate(
            viewportExtent: viewportDimension.width,
            precedingExtent: leadingOffset,
          ),
        ),
      );
      newColumnMetrics[column] = span;
      if (!isPinned) {
        if (span.trailingOffset >= horizontalOffset.pixels &&
            _firstNonPinnedColumn == null) {
          _firstNonPinnedColumn = column;
        }
        final double targetColumnPixel = cacheExtent +
            horizontalOffset.pixels +
            viewportDimension.width -
            startOfPinnedColumn;
        if (span.trailingOffset >= targetColumnPixel &&
            _lastNonPinnedColumn == null) {
          _lastNonPinnedColumn = column;
        }
        startOfRegularColumn = span.trailingOffset;
      } else {
        startOfPinnedColumn = span.trailingOffset;
      }
    }
    assert(newColumnMetrics.length >= delegate.pinnedColumnCount);
    for (final _Span span in _columnMetrics.values) {
      span.dispose();
    }
    _columnMetrics = newColumnMetrics;

    _firstNonPinnedRow = null;
    _lastNonPinnedRow = null;
    double startOfRegularRow = 0;
    double startOfPinnedRow = 0;

    final Map<int, _Span> newRowMetrics = <int, _Span>{};
    for (int row = 0; row < delegate.rowCount; row++) {
      final bool isPinned = row < delegate.pinnedRowCount;
      final double leadingOffset =
          isPinned ? startOfPinnedRow : startOfRegularRow;
      _Span? span = _rowMetrics.remove(row);
      assert(needsDelegateRebuild || span != null);
      final TableSpan configuration =
          needsDelegateRebuild ? delegate.buildRow(row) : span!.configuration;
      span ??= _Span();
      span.update(
        isPinned: isPinned,
        configuration: configuration,
        leadingOffset: leadingOffset,
        extent: configuration.extent.calculateExtent(
          TableSpanExtentDelegate(
            viewportExtent: viewportDimension.height,
            precedingExtent: leadingOffset,
          ),
        ),
      );
      newRowMetrics[row] = span;
      if (!isPinned) {
        if (span.trailingOffset >= verticalOffset.pixels &&
            _firstNonPinnedRow == null) {
          _firstNonPinnedRow = row;
        }
        final double targetRowPixel = cacheExtent +
            verticalOffset.pixels +
            viewportDimension.height -
            startOfPinnedRow;
        if (span.trailingOffset >= targetRowPixel &&
            _lastNonPinnedRow == null) {
          _lastNonPinnedRow = row;
        }
        startOfRegularRow = span.trailingOffset;
      } else {
        startOfPinnedRow = span.trailingOffset;
      }
    }
    assert(newRowMetrics.length >= delegate.pinnedRowCount);
    for (final _Span span in _rowMetrics.values) {
      span.dispose();
    }
    _rowMetrics = newRowMetrics;

    final double maxVerticalScrollExtent;
    if (_rowMetrics.length <= delegate.pinnedRowCount) {
      assert(_firstNonPinnedRow == null && _lastNonPinnedRow == null);
      maxVerticalScrollExtent = 0.0;
    } else {
      final int lastRow = _rowMetrics.length - 1;
      if (_firstNonPinnedRow != null) {
        _lastNonPinnedRow ??= lastRow;
      }
      maxVerticalScrollExtent = math.max(
        0.0,
        _rowMetrics[lastRow]!.trailingOffset -
            viewportDimension.height +
            startOfPinnedRow,
      );
    }

    final double maxHorizontalScrollExtent;
    if (_columnMetrics.length <= delegate.pinnedColumnCount) {
      assert(_firstNonPinnedColumn == null && _lastNonPinnedColumn == null);
      maxHorizontalScrollExtent = 0.0;
    } else {
      final int lastColumn = _columnMetrics.length - 1;
      if (_firstNonPinnedColumn != null) {
        _lastNonPinnedColumn ??= lastColumn;
      }
      maxHorizontalScrollExtent = math.max(
        0.0,
        _columnMetrics[lastColumn]!.trailingOffset -
            viewportDimension.width +
            startOfPinnedColumn,
      );
    }

    final bool acceptedDimension = horizontalOffset.applyContentDimensions(
            0.0, maxHorizontalScrollExtent) &&
        verticalOffset.applyContentDimensions(0.0, maxVerticalScrollExtent);
    if (!acceptedDimension) {
      _updateFirstAndLastVisibleCell();
    }
  }

  // Uses the cached metrics to update the currently visible cells
  //
  // TODO(Piinks): Add back infinite separately for easier review, https://github.com/flutter/flutter/issues/131226
  // Only relevant when the number of rows and columns is finite
  void _updateFirstAndLastVisibleCell() {
    _firstNonPinnedColumn = null;
    _lastNonPinnedColumn = null;
    final double targetColumnPixel = cacheExtent +
        horizontalOffset.pixels +
        viewportDimension.width -
        _pinnedColumnsExtent;
    for (int column = 0; column < _columnMetrics.length; column++) {
      if (_columnMetrics[column]!.isPinned) {
        continue;
      }
      final double endOfColumn = _columnMetrics[column]!.trailingOffset;
      if (endOfColumn >= horizontalOffset.pixels &&
          _firstNonPinnedColumn == null) {
        _firstNonPinnedColumn = column;
      }
      if (endOfColumn >= targetColumnPixel && _lastNonPinnedColumn == null) {
        _lastNonPinnedColumn = column;
        break;
      }
    }
    if (_firstNonPinnedColumn != null) {
      _lastNonPinnedColumn ??= _columnMetrics.length - 1;
    }

    _firstNonPinnedRow = null;
    _lastNonPinnedRow = null;
    final double targetRowPixel = cacheExtent +
        verticalOffset.pixels +
        viewportDimension.height -
        _pinnedRowsExtent;
    for (int row = 0; row < _rowMetrics.length; row++) {
      if (_rowMetrics[row]!.isPinned) {
        continue;
      }
      final double endOfRow = _rowMetrics[row]!.trailingOffset;
      if (endOfRow >= verticalOffset.pixels && _firstNonPinnedRow == null) {
        _firstNonPinnedRow = row;
      }
      if (endOfRow >= targetRowPixel && _lastNonPinnedRow == null) {
        _lastNonPinnedRow = row;
        break;
      }
    }
    if (_firstNonPinnedRow != null) {
      _lastNonPinnedRow ??= _rowMetrics.length - 1;
    }
  }

  @override
  void layoutChildSequence() {
    // Reset for a new frame
    _mergedVicinities.clear();
    _mergedRows.clear();
    _mergedColumns.clear();

    if (needsDelegateRebuild || didResize) {
      // Recomputes the table metrics, invalidates any cached information.
      _updateAllMetrics();
    } else {
      // Updates the visible cells based on cached table metrics.
      _updateFirstAndLastVisibleCell();
    }

    if (_firstNonPinnedCell == null &&
        _lastPinnedRow == null &&
        _lastPinnedColumn == null) {
      assert(_lastNonPinnedCell == null);
      return;
    }

    final double? offsetIntoColumn = _firstNonPinnedColumn != null
        ? horizontalOffset.pixels -
            _columnMetrics[_firstNonPinnedColumn]!.leadingOffset -
            _pinnedColumnsExtent
        : null;
    final double? offsetIntoRow = _firstNonPinnedRow != null
        ? verticalOffset.pixels -
            _rowMetrics[_firstNonPinnedRow]!.leadingOffset -
            _pinnedRowsExtent
        : null;

    if (_lastPinnedRow != null && _lastPinnedColumn != null) {
      // Layout cells that are contained in both pinned rows and columns
      _layoutCells(
        start: TableVicinity.zero,
        end: TableVicinity(column: _lastPinnedColumn!, row: _lastPinnedRow!),
        offset: Offset.zero,
      );
    }

    if (_lastPinnedRow != null && _firstNonPinnedColumn != null) {
      // Layout cells of pinned rows - those that do not intersect with pinned
      // columns above
      assert(_lastNonPinnedColumn != null);
      assert(offsetIntoColumn != null);
      _layoutCells(
        start: TableVicinity(column: _firstNonPinnedColumn!, row: 0),
        end: TableVicinity(column: _lastNonPinnedColumn!, row: _lastPinnedRow!),
        offset: Offset(offsetIntoColumn!, 0),
      );
    }
    if (_lastPinnedColumn != null && _firstNonPinnedRow != null) {
      // Layout cells of pinned columns - those that do not intersect with
      // pinned rows above
      assert(_lastNonPinnedRow != null);
      assert(offsetIntoRow != null);
      _layoutCells(
        start: TableVicinity(column: 0, row: _firstNonPinnedRow!),
        end: TableVicinity(column: _lastPinnedColumn!, row: _lastNonPinnedRow!),
        offset: Offset(0, offsetIntoRow!),
      );
    }
    if (_firstNonPinnedCell != null) {
      // Layout all other cells.
      assert(_lastNonPinnedCell != null);
      assert(offsetIntoColumn != null);
      assert(offsetIntoRow != null);
      _layoutCells(
        start: _firstNonPinnedCell!,
        end: _lastNonPinnedCell!,
        offset: Offset(offsetIntoColumn!, offsetIntoRow!),
      );
    }
  }

  bool _debugCheckMergeBounds({
    required String spanOrientation,
    required int currentSpan,
    required int spanMergeStart,
    required int spanMergeEnd,
    required int spanCount,
    required int pinnedSpanCount,
    required TableVicinity currentVicinity,
  }) {
    if (spanMergeStart == spanMergeEnd) {
      // Not merged
      return true;
    }

    final String lowerSpanOrientation = spanOrientation.toLowerCase();
    assert(
      spanMergeStart <= currentSpan,
      'The ${lowerSpanOrientation}MergeStart of $spanMergeStart is greater '
      'than the current $lowerSpanOrientation at $currentVicinity.',
    );
    assert(
      spanMergeEnd < spanCount,
      '$spanOrientation merge configuration exceeds number of '
      '${lowerSpanOrientation}s in the table. $spanOrientation merge '
      'containing $currentVicinity starts at $spanMergeStart, and ends at '
      '$spanMergeEnd. The TableView contains $spanCount.',
    );
    if (spanMergeStart < pinnedSpanCount) {
      // Merged cells cannot span pinned and unpinned cells.
      assert(
        spanMergeEnd < pinnedSpanCount,
        'Merged cells cannot span pinned and unpinned cells. $spanOrientation '
        'merge containing $currentVicinity starts at $spanMergeStart, and ends '
        'at $spanMergeEnd. ${spanOrientation}s are currently pinned up to '
        '$lowerSpanOrientation ${pinnedSpanCount - 1}.',
      );
    }
    return true;
  }

  void _layoutCells({
    required TableVicinity start,
    required TableVicinity end,
    required Offset offset,
  }) {
    _Span colSpan, rowSpan;
    double rowOffset = -offset.dy;
    for (int row = start.row; row <= end.row; row += 1) {
      double columnOffset = -offset.dx;
      rowSpan = _rowMetrics[row]!;
      final double standardRowHeight = rowSpan.extent;
      double? mergedRowHeight;
      double? mergedRowOffset;
      rowOffset += rowSpan.configuration.padding.leading;

      for (int column = start.column; column <= end.column; column += 1) {
        colSpan = _columnMetrics[column]!;
        final double standardColumnWidth = colSpan.extent;
        double? mergedColumnWidth;
        double? mergedColumnOffset;
        columnOffset += colSpan.configuration.padding.leading;

        final TableVicinity vicinity = TableVicinity(column: column, row: row);
        final RenderBox? cell = _mergedVicinities.keys.contains(vicinity)
            ? null
            : buildOrObtainChildFor(vicinity);

        if (cell != null) {
          final TableViewParentData cellParentData = parentDataOf(cell);

          // Merged cell handling
          if (cellParentData.rowMergeStart != null ||
              cellParentData.columnMergeStart != null) {
            final int firstRow = cellParentData.rowMergeStart ?? row;
            final int lastRow = cellParentData.rowMergeStart == null
                ? row
                : firstRow + cellParentData.rowMergeSpan! - 1;
            assert(_debugCheckMergeBounds(
              spanOrientation: 'Row',
              currentSpan: row,
              spanMergeStart: firstRow,
              spanMergeEnd: lastRow,
              spanCount: delegate.rowCount,
              pinnedSpanCount: delegate.pinnedRowCount,
              currentVicinity: vicinity,
            ));

            final int firstColumn = cellParentData.columnMergeStart ?? column;
            final int lastColumn = cellParentData.columnMergeStart == null
                ? column
                : firstColumn + cellParentData.columnMergeSpan! - 1;
            assert(_debugCheckMergeBounds(
              spanOrientation: 'Column',
              currentSpan: column,
              spanMergeStart: firstColumn,
              spanMergeEnd: lastColumn,
              spanCount: delegate.columnCount,
              pinnedSpanCount: delegate.pinnedColumnCount,
              currentVicinity: vicinity,
            ));

            // Leading padding on the leading cell, and trailing padding on the
            // trailing cell should be excluded. Interim leading/trailing
            // paddings are consumed by the merged cell.
            // Example: This is one whole cell spanning 2 merged columns.
            // l indicates leading padding, t trailing padding
            // +---------------------------------------------------------+
            // |  l  |  column extent  |  t  |  l  | column extent |  t  |
            // +---------------------------------------------------------+
            //       | <--------- extent of merged cell ---------> |

            // Compute height and layout offset for merged rows.
            mergedRowOffset = -verticalOffset.pixels +
                _rowMetrics[firstRow]!.leadingOffset +
                _rowMetrics[firstRow]!.configuration.padding.leading;
            mergedRowHeight = _rowMetrics[lastRow]!.trailingOffset -
                _rowMetrics[firstRow]!.leadingOffset -
                _rowMetrics[lastRow]!.configuration.padding.trailing -
                _rowMetrics[firstRow]!.configuration.padding.leading;
            // Compute width and layout offset for merged columns.
            mergedColumnOffset = -horizontalOffset.pixels +
                _columnMetrics[firstColumn]!.leadingOffset +
                _columnMetrics[firstColumn]!.configuration.padding.leading;
            mergedColumnWidth = _columnMetrics[lastColumn]!.trailingOffset -
                _columnMetrics[firstColumn]!.leadingOffset -
                _columnMetrics[lastColumn]!.configuration.padding.trailing -
                _columnMetrics[firstColumn]!.configuration.padding.leading;

            // Collect all of the vicinities that will not need to be built now.
            int currentRow = firstRow;
            while (currentRow <= lastRow) {
              if (cellParentData.rowMergeStart != null) {
                _mergedRows.add(currentRow);
              }
              int currentColumn = firstColumn;
              while (currentColumn <= lastColumn) {
                if (cellParentData.columnMergeStart != null) {
                  _mergedColumns.add(currentColumn);
                }
                final TableVicinity key = TableVicinity(
                  row: currentRow,
                  column: currentColumn,
                );
                _mergedVicinities[key] = vicinity;
                currentColumn++;
              }
              currentRow++;
            }
          }

          final BoxConstraints cellConstraints = BoxConstraints.tightFor(
            width: mergedColumnWidth ?? standardColumnWidth,
            height: mergedRowHeight ?? standardRowHeight,
          );
          cell.layout(cellConstraints);
          cellParentData.layoutOffset = Offset(
            mergedColumnOffset ?? columnOffset,
            mergedRowOffset ?? rowOffset,
          );
          mergedRowOffset = null;
          mergedRowHeight = null;
          mergedColumnOffset = null;
          mergedColumnWidth = null;
        }
        columnOffset += standardColumnWidth +
            _columnMetrics[column]!.configuration.padding.trailing;
      }
      rowOffset +=
          standardRowHeight + _rowMetrics[row]!.configuration.padding.trailing;
    }
  }

  final LayerHandle<ClipRectLayer> _clipPinnedRowsHandle =
      LayerHandle<ClipRectLayer>();
  final LayerHandle<ClipRectLayer> _clipPinnedColumnsHandle =
      LayerHandle<ClipRectLayer>();
  final LayerHandle<ClipRectLayer> _clipCellsHandle =
      LayerHandle<ClipRectLayer>();

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_firstNonPinnedCell == null &&
        _lastPinnedRow == null &&
        _lastPinnedColumn == null) {
      assert(_lastNonPinnedCell == null);
      return;
    }

    // Subclasses of RenderTwoDimensionalViewport will typically use
    // firstChild to traverse children in a standard paint order that
    // follows row or column major ordering. Here is slightly different
    // as we break the cells up into 4 main paint passes to clip for overlap.

    if (_firstNonPinnedCell != null) {
      // Paint all visible un-pinned cells
      assert(_lastNonPinnedCell != null);
      _clipCellsHandle.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Rect.fromLTWH(
          axisDirectionIsReversed(horizontalAxisDirection)
              ? 0.0
              : _pinnedColumnsExtent,
          axisDirectionIsReversed(verticalAxisDirection)
              ? 0.0
              : _pinnedRowsExtent,
          viewportDimension.width - _pinnedColumnsExtent,
          viewportDimension.height - _pinnedRowsExtent,
        ),
        (PaintingContext context, Offset offset) {
          _paintCells(
            context: context,
            offset: offset,
            leadingVicinity: _firstNonPinnedCell!,
            trailingVicinity: _lastNonPinnedCell!,
          );
        },
        clipBehavior: clipBehavior,
        oldLayer: _clipCellsHandle.layer,
      );
    } else {
      _clipCellsHandle.layer = null;
    }

    if (_lastPinnedColumn != null && _firstNonPinnedRow != null) {
      // Paint all visible pinned column cells that do not intersect with pinned
      // row cells.
      _clipPinnedColumnsHandle.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Rect.fromLTWH(
          axisDirectionIsReversed(horizontalAxisDirection)
              ? viewportDimension.width - _pinnedColumnsExtent
              : 0.0,
          axisDirectionIsReversed(verticalAxisDirection)
              ? 0.0
              : _pinnedRowsExtent,
          _pinnedColumnsExtent,
          viewportDimension.height - _pinnedRowsExtent,
        ),
        (PaintingContext context, Offset offset) {
          _paintCells(
            context: context,
            offset: offset,
            leadingVicinity: TableVicinity(column: 0, row: _firstNonPinnedRow!),
            trailingVicinity: TableVicinity(
                column: _lastPinnedColumn!, row: _lastNonPinnedRow!),
          );
        },
        clipBehavior: clipBehavior,
        oldLayer: _clipPinnedColumnsHandle.layer,
      );
    } else {
      _clipPinnedColumnsHandle.layer = null;
    }

    if (_lastPinnedRow != null && _firstNonPinnedColumn != null) {
      // Paint all visible pinned row cells that do not intersect with pinned
      // column cells.
      _clipPinnedRowsHandle.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Rect.fromLTWH(
          axisDirectionIsReversed(horizontalAxisDirection)
              ? 0.0
              : _pinnedColumnsExtent,
          axisDirectionIsReversed(verticalAxisDirection)
              ? viewportDimension.height - _pinnedRowsExtent
              : 0.0,
          viewportDimension.width - _pinnedColumnsExtent,
          _pinnedRowsExtent,
        ),
        (PaintingContext context, Offset offset) {
          _paintCells(
            context: context,
            offset: offset,
            leadingVicinity:
                TableVicinity(column: _firstNonPinnedColumn!, row: 0),
            trailingVicinity: TableVicinity(
                column: _lastNonPinnedColumn!, row: _lastPinnedRow!),
          );
        },
        clipBehavior: clipBehavior,
        oldLayer: _clipPinnedRowsHandle.layer,
      );
    } else {
      _clipPinnedRowsHandle.layer = null;
    }

    if (_lastPinnedRow != null && _lastPinnedColumn != null) {
      // Paint remaining visible pinned cells that represent the intersection of
      // both pinned rows and columns.
      _paintCells(
        context: context,
        offset: offset,
        leadingVicinity: TableVicinity.zero,
        trailingVicinity:
            TableVicinity(column: _lastPinnedColumn!, row: _lastPinnedRow!),
      );
    }
  }

  // If mapMergedVicinityToCanonicalChild is true, it will return the canonical
  // child for the merged cell, if false, it will return whatever value in the
  // underlying child data structure is, which could be null if the given
  // vicinity is covered by a merged cell.
  // This is relevant for scenarios like painting, where we only want to paint
  // one merged cell.
  @override
  RenderBox? getChildFor(
    ChildVicinity vicinity, {
    bool mapMergedVicinityToCanonicalChild = true,
  }) {
    return super.getChildFor(vicinity) ??
        (mapMergedVicinityToCanonicalChild
            ? _getMergedChildFor(vicinity as TableVicinity)
            : null);
  }

  RenderBox _getMergedChildFor(TableVicinity vicinity) {
    // A merged cell spans multiple vicinities, but only lays out one child for
    // the full area. Returns the child that has been laid out to span the given
    // vicinity.
    assert(_mergedVicinities.keys.contains(vicinity));
    final TableVicinity mergedVicinity = _mergedVicinities[vicinity]!;
    // This vicinity must resolve to a child, unless something has gone wrong!
    return getChildFor(
      mergedVicinity,
      mapMergedVicinityToCanonicalChild: false,
    )!;
  }

  void _paintCells({
    required PaintingContext context,
    required TableVicinity leadingVicinity,
    required TableVicinity trailingVicinity,
    required Offset offset,
  }) {
    // Column decorations
    final LinkedHashMap<Rect, TableSpanDecoration> foregroundColumns =
        LinkedHashMap<Rect, TableSpanDecoration>();
    final LinkedHashMap<Rect, TableSpanDecoration> backgroundColumns =
        LinkedHashMap<Rect, TableSpanDecoration>();

    final TableSpan rowSpan = _rowMetrics[leadingVicinity.row]!.configuration;
    for (int column = leadingVicinity.column;
        column <= trailingVicinity.column;
        column++) {
      TableSpan columnSpan = _columnMetrics[column]!.configuration;
      if (columnSpan.backgroundDecoration != null ||
          columnSpan.foregroundDecoration != null ||
          _mergedColumns.contains(column)) {
        final List<({RenderBox leading, RenderBox trailing})> decorationCells =
            <({RenderBox leading, RenderBox trailing})>[];
        if (_mergedColumns.isEmpty || !_mergedColumns.contains(column)) {
          // One decoration across the whole column.
          decorationCells.add((
            leading: getChildFor(TableVicinity(
              column: column,
              row: leadingVicinity.row,
            ))!,
            trailing: getChildFor(TableVicinity(
              column: column,
              row: trailingVicinity.row,
            ))!,
          ));
        } else {
          // Walk through the rows to separate merged cells for decorating. A
          // merged column takes the decoration of its leading column.
          // +---------+-------+-------+
          // |         |       |       |
          // | 1 rect  |       |       |
          // +---------+-------+-------+
          // | merged          |       |
          // | 1 rect          |       |
          // +---------+-------+-------+
          // | 1 rect  |       |       |
          // |         |       |       |
          // +---------+-------+-------+
          late RenderBox leadingCell;
          late RenderBox trailingCell;
          int currentRow = leadingVicinity.row;
          while (currentRow <= trailingVicinity.row) {
            TableVicinity vicinity = TableVicinity(
              column: column,
              row: currentRow,
            );
            leadingCell = getChildFor(vicinity)!;
            if (parentDataOf(leadingCell).columnMergeStart != null) {
              // Merged portion decorated individually since it exceeds the
              // single column width.
              decorationCells.add((
                leading: leadingCell,
                trailing: leadingCell,
              ));
              currentRow++;
              continue;
            }
            // If this is not a merged cell, collect up all of the cells leading
            // up to, or following after, the merged cell so we can decorate
            // efficiently with as few rects as possible.
            RenderBox? nextCell = leadingCell;
            while (nextCell != null &&
                parentDataOf(nextCell).columnMergeStart == null) {
              final TableViewParentData parentData = parentDataOf(nextCell);
              if (parentData.rowMergeStart != null) {
                currentRow =
                    parentData.rowMergeStart! + parentData.rowMergeSpan!;
              } else {
                currentRow += 1;
              }
              trailingCell = nextCell;
              vicinity = vicinity.copyWith(row: currentRow);
              nextCell = getChildFor(
                vicinity,
                mapMergedVicinityToCanonicalChild: false,
              );
            }
            decorationCells.add((
              leading: leadingCell,
              trailing: trailingCell,
            ));
          }
        }

        Rect getColumnRect({
          required RenderBox leadingCell,
          required RenderBox trailingCell,
          required bool consumePadding,
        }) {
          final ({double leading, double trailing}) offsetCorrection =
              axisDirectionIsReversed(verticalAxisDirection)
                  ? (
                      leading: leadingCell.size.height,
                      trailing: trailingCell.size.height,
                    )
                  : (leading: 0.0, trailing: 0.0);
          return Rect.fromPoints(
            parentDataOf(leadingCell).paintOffset! +
                offset -
                Offset(
                  consumePadding ? columnSpan.padding.leading : 0.0,
                  rowSpan.padding.leading - offsetCorrection.leading,
                ),
            parentDataOf(trailingCell).paintOffset! +
                offset +
                Offset(trailingCell.size.width, trailingCell.size.height) +
                Offset(
                  consumePadding ? columnSpan.padding.trailing : 0.0,
                  rowSpan.padding.trailing - offsetCorrection.trailing,
                ),
          );
        }

        for (final ({RenderBox leading, RenderBox trailing}) cell
            in decorationCells) {
          // If this was a merged cell, the decoration is defined by the leading
          // cell, which may come from a different column.
          final int columnIndex = parentDataOf(cell.leading).columnMergeStart ??
              parentDataOf(cell.leading).tableVicinity.column;
          columnSpan = _columnMetrics[columnIndex]!.configuration;
          if (columnSpan.backgroundDecoration != null) {
            final Rect rect = getColumnRect(
              leadingCell: cell.leading,
              trailingCell: cell.trailing,
              consumePadding:
                  columnSpan.backgroundDecoration!.consumeSpanPadding,
            );
            backgroundColumns[rect] = columnSpan.backgroundDecoration!;
          }
          if (columnSpan.foregroundDecoration != null) {
            final Rect rect = getColumnRect(
              leadingCell: cell.leading,
              trailingCell: cell.trailing,
              consumePadding:
                  columnSpan.foregroundDecoration!.consumeSpanPadding,
            );
            foregroundColumns[rect] = columnSpan.foregroundDecoration!;
          }
        }
      }
    }

    // Row decorations
    final LinkedHashMap<Rect, TableSpanDecoration> foregroundRows =
        LinkedHashMap<Rect, TableSpanDecoration>();
    final LinkedHashMap<Rect, TableSpanDecoration> backgroundRows =
        LinkedHashMap<Rect, TableSpanDecoration>();
    final TableSpan columnSpan =
        _columnMetrics[leadingVicinity.column]!.configuration;
    for (int row = leadingVicinity.row; row <= trailingVicinity.row; row++) {
      TableSpan rowSpan = _rowMetrics[row]!.configuration;
      if (rowSpan.backgroundDecoration != null ||
          rowSpan.foregroundDecoration != null ||
          _mergedRows.contains(row)) {
        final List<({RenderBox leading, RenderBox trailing})> decorationCells =
            <({RenderBox leading, RenderBox trailing})>[];
        if (_mergedRows.isEmpty || !_mergedRows.contains(row)) {
          // One decoration across the whole row.
          decorationCells.add((
            leading: getChildFor(TableVicinity(
              column: leadingVicinity.column,
              row: row,
            ))!, // leading
            trailing: getChildFor(TableVicinity(
              column: trailingVicinity.column,
              row: row,
            ))!, // trailing
          ));
        } else {
          // Walk through the columns to separate merged cells for decorating. A
          // merged row takes the decoration of its leading row.
          // +---------+--------+--------+
          // | 1 rect  | merged | 1 rect |
          // |         | 1 rect |        |
          // +---------+        +--------+
          // |         |        |        |
          // |         |        |        |
          // +---------+--------+--------+
          // |         |        |        |
          // |         |        |        |
          // +---------+--------+--------+
          late RenderBox leadingCell;
          late RenderBox trailingCell;
          int currentColumn = leadingVicinity.column;
          while (currentColumn <= trailingVicinity.column) {
            TableVicinity vicinity = TableVicinity(
              column: currentColumn,
              row: row,
            );
            leadingCell = getChildFor(vicinity)!;
            if (parentDataOf(leadingCell).rowMergeStart != null) {
              // Merged portion decorated individually since it exceeds the
              // single row height.
              decorationCells.add((
                leading: leadingCell,
                trailing: leadingCell,
              ));
              currentColumn++;
              continue;
            }
            // If this is not a merged cell, collect up all of the cells leading
            // up to, or following after, the merged cell so we can decorate
            // efficiently with as few rects as possible.
            RenderBox? nextCell = leadingCell;
            while (nextCell != null &&
                parentDataOf(nextCell).rowMergeStart == null) {
              final TableViewParentData parentData = parentDataOf(nextCell);
              if (parentData.columnMergeStart != null) {
                currentColumn =
                    parentData.columnMergeStart! + parentData.columnMergeSpan!;
              } else {
                currentColumn += 1;
              }
              trailingCell = nextCell;
              vicinity = vicinity.copyWith(column: currentColumn);
              nextCell = getChildFor(
                vicinity,
                mapMergedVicinityToCanonicalChild: false,
              );
            }
            decorationCells.add((
              leading: leadingCell,
              trailing: trailingCell,
            ));
          }
        }

        Rect getRowRect({
          required RenderBox leadingCell,
          required RenderBox trailingCell,
          required bool consumePadding,
        }) {
          final ({double leading, double trailing}) offsetCorrection =
              axisDirectionIsReversed(horizontalAxisDirection)
                  ? (
                      leading: leadingCell.size.width,
                      trailing: trailingCell.size.width,
                    )
                  : (leading: 0.0, trailing: 0.0);
          return Rect.fromPoints(
            parentDataOf(leadingCell).paintOffset! +
                offset -
                Offset(
                  columnSpan.padding.leading - offsetCorrection.leading,
                  consumePadding ? rowSpan.padding.leading : 0.0,
                ),
            parentDataOf(trailingCell).paintOffset! +
                offset +
                Offset(trailingCell.size.width, trailingCell.size.height) +
                Offset(
                  columnSpan.padding.leading - offsetCorrection.trailing,
                  consumePadding ? rowSpan.padding.trailing : 0.0,
                ),
          );
        }

        for (final ({RenderBox leading, RenderBox trailing}) cell
            in decorationCells) {
          // If this was a merged cell, the decoration is defined by the leading
          // cell, which may come from a different row.
          final int rowIndex = parentDataOf(cell.leading).rowMergeStart ??
              parentDataOf(cell.trailing).tableVicinity.row;
          rowSpan = _rowMetrics[rowIndex]!.configuration;
          if (rowSpan.backgroundDecoration != null) {
            final Rect rect = getRowRect(
              leadingCell: cell.leading,
              trailingCell: cell.trailing,
              consumePadding: rowSpan.backgroundDecoration!.consumeSpanPadding,
            );
            backgroundRows[rect] = rowSpan.backgroundDecoration!;
          }
          if (rowSpan.foregroundDecoration != null) {
            final Rect rect = getRowRect(
              leadingCell: cell.leading,
              trailingCell: cell.trailing,
              consumePadding: rowSpan.foregroundDecoration!.consumeSpanPadding,
            );
            foregroundRows[rect] = rowSpan.foregroundDecoration!;
          }
        }
      }
    }

    // Get to painting.
    // Painting is done in row or column major ordering according to the main
    // axis, with background decorations first, cells next, and foreground
    // decorations last.

    // Background decorations
    switch (mainAxis) {
      // Default, row major order. Rows go first.
      case Axis.vertical:
        backgroundRows.forEach((Rect rect, TableSpanDecoration decoration) {
          final TableSpanDecorationPaintDetails paintingDetails =
              TableSpanDecorationPaintDetails(
            canvas: context.canvas,
            rect: rect,
            axisDirection: horizontalAxisDirection,
          );
          decoration.paint(paintingDetails);
        });
        backgroundColumns.forEach((Rect rect, TableSpanDecoration decoration) {
          final TableSpanDecorationPaintDetails paintingDetails =
              TableSpanDecorationPaintDetails(
            canvas: context.canvas,
            rect: rect,
            axisDirection: verticalAxisDirection,
          );
          decoration.paint(paintingDetails);
        });
      // Column major order. Columns go first.
      case Axis.horizontal:
        backgroundColumns.forEach((Rect rect, TableSpanDecoration decoration) {
          final TableSpanDecorationPaintDetails paintingDetails =
              TableSpanDecorationPaintDetails(
            canvas: context.canvas,
            rect: rect,
            axisDirection: verticalAxisDirection,
          );
          decoration.paint(paintingDetails);
        });
        backgroundRows.forEach((Rect rect, TableSpanDecoration decoration) {
          final TableSpanDecorationPaintDetails paintingDetails =
              TableSpanDecorationPaintDetails(
            canvas: context.canvas,
            rect: rect,
            axisDirection: horizontalAxisDirection,
          );
          decoration.paint(paintingDetails);
        });
    }

    // Cells
    for (int column = leadingVicinity.column;
        column <= trailingVicinity.column;
        column++) {
      for (int row = leadingVicinity.row; row <= trailingVicinity.row; row++) {
        final TableVicinity vicinity = TableVicinity(column: column, row: row);
        final RenderBox? cell = getChildFor(
          vicinity,
          mapMergedVicinityToCanonicalChild: false,
        );
        if (cell == null) {
          // Covered by a merged cell
          assert(
            _mergedVicinities.keys.contains(vicinity),
            'TableViewCell for $vicinity could not be found. If merging '
            'cells, the same TableViewCell must be returned for every '
            'TableVicinity that is contained in the merged area of the '
            'TableView.',
          );
          continue;
        }
        final TableViewParentData cellParentData = parentDataOf(cell);
        if (cellParentData.isVisible) {
          context.paintChild(cell, offset + cellParentData.paintOffset!);
        }
      }
    }

    // Foreground decorations
    switch (mainAxis) {
      // Default, row major order. Rows go first.
      case Axis.vertical:
        foregroundRows.forEach((Rect rect, TableSpanDecoration decoration) {
          final TableSpanDecorationPaintDetails paintingDetails =
              TableSpanDecorationPaintDetails(
            canvas: context.canvas,
            rect: rect,
            axisDirection: horizontalAxisDirection,
          );
          decoration.paint(paintingDetails);
        });
        foregroundColumns.forEach((Rect rect, TableSpanDecoration decoration) {
          final TableSpanDecorationPaintDetails paintingDetails =
              TableSpanDecorationPaintDetails(
            canvas: context.canvas,
            rect: rect,
            axisDirection: verticalAxisDirection,
          );
          decoration.paint(paintingDetails);
        });
      // Column major order. Columns go first.
      case Axis.horizontal:
        foregroundColumns.forEach((Rect rect, TableSpanDecoration decoration) {
          final TableSpanDecorationPaintDetails paintingDetails =
              TableSpanDecorationPaintDetails(
            canvas: context.canvas,
            rect: rect,
            axisDirection: verticalAxisDirection,
          );
          decoration.paint(paintingDetails);
        });
        foregroundRows.forEach((Rect rect, TableSpanDecoration decoration) {
          final TableSpanDecorationPaintDetails paintingDetails =
              TableSpanDecorationPaintDetails(
            canvas: context.canvas,
            rect: rect,
            axisDirection: horizontalAxisDirection,
          );
          decoration.paint(paintingDetails);
        });
    }
  }

  @override
  void dispose() {
    _clipPinnedRowsHandle.layer = null;
    _clipPinnedColumnsHandle.layer = null;
    _clipCellsHandle.layer = null;
    super.dispose();
  }
}

class _Span
    with Diagnosticable
    implements HitTestTarget, MouseTrackerAnnotation {
  double get leadingOffset => _leadingOffset;
  late double _leadingOffset;

  double get extent => _extent;
  late double _extent;

  TableSpan get configuration => _configuration!;
  TableSpan? _configuration;

  bool get isPinned => _isPinned;
  late bool _isPinned;

  double get trailingOffset {
    return leadingOffset +
        extent +
        configuration.padding.leading +
        configuration.padding.trailing;
  }

  // ---- Span Management ----

  void update({
    required TableSpan configuration,
    required double leadingOffset,
    required double extent,
    required bool isPinned,
  }) {
    _leadingOffset = leadingOffset;
    _extent = extent;
    _isPinned = isPinned;
    if (configuration == _configuration) {
      return;
    }
    _configuration = configuration;
    // Only sync recognizers if they are in use already.
    if (_recognizers != null) {
      _syncRecognizers();
    }
  }

  void dispose() {
    _disposeRecognizers();
  }

  // ---- Recognizers management ----

  Map<Type, GestureRecognizer>? _recognizers;

  void _syncRecognizers() {
    if (configuration.recognizerFactories.isEmpty) {
      _disposeRecognizers();
      return;
    }
    final Map<Type, GestureRecognizer> newRecognizers =
        <Type, GestureRecognizer>{};
    for (final Type type in configuration.recognizerFactories.keys) {
      assert(!newRecognizers.containsKey(type));
      newRecognizers[type] = _recognizers?.remove(type) ??
          configuration.recognizerFactories[type]!.constructor();
      assert(
        newRecognizers[type].runtimeType == type,
        'GestureRecognizerFactory of type $type created a GestureRecognizer of '
        'type ${newRecognizers[type].runtimeType}. The '
        'GestureRecognizerFactory must be specialized with the type of the '
        'class that it returns from its constructor method.',
      );
      configuration.recognizerFactories[type]!
          .initializer(newRecognizers[type]!);
    }
    _disposeRecognizers(); // only disposes the ones that where not re-used above.
    _recognizers = newRecognizers;
  }

  void _disposeRecognizers() {
    if (_recognizers != null) {
      for (final GestureRecognizer recognizer in _recognizers!.values) {
        recognizer.dispose();
      }
      _recognizers = null;
    }
  }

  // ---- HitTestTarget ----

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    if (event is PointerDownEvent &&
        configuration.recognizerFactories.isNotEmpty) {
      if (_recognizers == null) {
        _syncRecognizers();
      }
      assert(_recognizers != null);
      for (final GestureRecognizer recognizer in _recognizers!.values) {
        recognizer.addPointer(event);
      }
    }
  }

  // ---- MouseTrackerAnnotation ----

  @override
  MouseCursor get cursor => configuration.cursor;

  @override
  PointerEnterEventListener? get onEnter => configuration.onEnter;

  @override
  PointerExitEventListener? get onExit => configuration.onExit;

  @override
  bool get validForMouseTracker => true;
}
