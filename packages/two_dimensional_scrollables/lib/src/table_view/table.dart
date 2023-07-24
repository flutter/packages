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
/// The content displayed by the table is organized in [TableViewCell]s. Each
/// cell can belong to exactly one row and one column. The table supports lazy
/// rendering and will only instantiate those cells that are currently visible
/// in the table's viewport and those that extend into the [cacheExtent]
///
/// The layout of the table (e.g. how many rows/columns there are and their
/// extents) as well as the content of the individual cells is defined by
/// the provided [delegate], a subclass of [TwoDimensionalChildDelegate] with
/// the [TableCellDelegateMixin]. The [TableView.builder] and [TableView.list]
/// constructors create their own delegate.
///
/// This example shows a TableView of 100 [TableViewCell]s, all sized 100 by 100
/// pixels with a few [TableSpanDecoration]s like background colors and borders.
/// The `builder` constructor is called on demand for the cells that are visible
/// in the TableView.
///
/// ```dart
/// TableView.builder(
///   cellBuilder: (BuildContext context, TableVicinity vicinity) {
///     return TableViewCell(
///       child: Center(
///         child: Text('Cell ${vicinity.column} : ${vicinity.row}'),
///       ),
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
    required TableCellDelegateMixin delegate,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.clipBehavior,
  }) : super(delegate: delegate);

  /// Creates a [TableView] of widgets that are created on demand.
  ///
  /// This constructor is appropriate for table views with a large
  /// number of cells because the [cellbuilder] is called only for those
  /// cells that are actually visible.
  ///
  /// This constructor generates a [TableCellBuilderDelegate] for building
  /// [TableViewCell]s on demand using the required [cellBuilder],
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
        assert(columnCount >= 0),
        assert(pinnedColumnCount >= 0),
        super(
            delegate: TableCellBuilderDelegate(
          columnCount: columnCount,
          rowCount: rowCount,
          pinnedColumnCount: pinnedColumnCount,
          pinnedRowCount: pinnedRowCount,
          cellBuilder: cellBuilder,
          columnBuilder: columnBuilder,
          rowBuilder: rowBuilder,
        ));

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
        ));

  @override
  Widget buildViewport(BuildContext context, ViewportOffset verticalOffset,
      ViewportOffset horizontalOffset) {
    return TableViewport(
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalDetails.direction,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalDetails.direction,
      delegate: delegate,
      mainAxis: mainAxis,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }
}

/// A widget through which a portion of a Table of [TableViewCell]s are viewed,
/// typically in combination with a [TableView].
class TableViewport extends TwoDimensionalViewport {
  /// Creates a viewport for [TableViewCell]s that extend and scroll in both
  /// horizontal and vertical dimensions.
  const TableViewport({
    super.key,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.delegate,
    required super.mainAxis,
    super.cacheExtent,
    super.clipBehavior,
  });

  @override
  TableCellDelegateMixin get delegate =>
      super.delegate as TableCellDelegateMixin;

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
      delegate: delegate,
      childManager: context as TwoDimensionalChildManager,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderTableViewport renderObject) {
    renderObject
      ..horizontalOffset = horizontalOffset
      ..verticalOffset = verticalOffset
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior
      ..delegate = delegate;
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
    required super.delegate,
    required super.mainAxis,
    required super.childManager,
    super.cacheExtent,
    super.clipBehavior,
  });

  TableCellDelegateMixin get _delegate => delegate as TableCellDelegateMixin;

  // Cached Table metrics
  Map<int, _Span> _columnMetrics = <int, _Span>{};
  Map<int, _Span> _rowMetrics = <int, _Span>{};
  int? _firstRegularRow;
  int? _firstRegularColumn;
  int? _lastRegularRow;
  int? _lastRegularColumn;

  TableVicinity? get _firstRegularCell {
    if (_firstRegularRow == null || _firstRegularColumn == null) {
      return null;
    }
    return TableVicinity(column: _firstRegularColumn!, row: _firstRegularRow!);
  }

  TableVicinity? get _lastRegularCell {
    if (_lastRegularRow == null || _lastRegularColumn == null) {
      return null;
    }
    return TableVicinity(column: _lastRegularColumn!, row: _lastRegularRow!);
  }

  int? get _lastPinnedRow =>
      _delegate.pinnedRowCount > 0 ? _delegate.pinnedRowCount - 1 : null;
  int? get _lastPinnedColumn =>
      _delegate.pinnedColumnCount > 0 ? _delegate.pinnedColumnCount - 1 : null;

  double get _pinnedRowsExtent => _lastPinnedRow != null
      ? _rowMetrics[_lastPinnedRow]!.trailingOffset
      : 0.0;
  double get _pinnedColumnsExtent => _lastPinnedColumn != null
      ? _columnMetrics[_lastPinnedColumn]!.trailingOffset
      : 0.0;

  @override
  TableViewParentData parentDataOf(RenderBox child) =>
      child.parentData! as TableViewParentData;

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
                HitTestEntry(_rowMetrics[cellParentData.tableVicinity.row]!));
            result.add(HitTestEntry(
                _columnMetrics[cellParentData.tableVicinity.column]!));
            break;
          case Axis.horizontal:
            // Column major order, columns go first.
            result.add(HitTestEntry(
                _columnMetrics[cellParentData.tableVicinity.column]!));
            result.add(
                HitTestEntry(_rowMetrics[cellParentData.tableVicinity.row]!));
            break;
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
  // TODO(Piinks): Add back infinite separately for easier review, <ISSUE>
  // Only relevant when the number of rows and columns is finite
  void _updateAllMetrics() {
    assert(needsDelegateRebuild || didResize);

    _firstRegularColumn = null;
    _lastRegularColumn = null;
    double startOfRegularColumn = 0;
    double startOfPinnedColumn = 0;

    final Map<int, _Span> newColumnMetrics = <int, _Span>{};
    for (int column = 0; column < _delegate.columnCount; column++) {
      final bool isPinned = column < _delegate.pinnedColumnCount;
      final double leadingOffset =
          isPinned ? startOfPinnedColumn : startOfRegularColumn;
      _Span? span = _columnMetrics.remove(column);
      assert(needsDelegateRebuild || span != null);
      final TableSpan configuration = needsDelegateRebuild
          ? _delegate.columnBuilder(column)
          : span!.configuration;
      span ??= _Span();
      span.update(
        isPinned: isPinned,
        configuration: configuration,
        leadingOffset: leadingOffset,
        extent: configuration.extent.calculateExtent(TableSpanExtentDelegate(
          viewportExtent: viewportDimension.width,
          precedingExtent: leadingOffset,
        )),
      );
      newColumnMetrics[column] = span;
      if (!isPinned) {
        if (span.trailingOffset >= horizontalOffset.pixels &&
            _firstRegularColumn == null) {
          _firstRegularColumn = column;
        }
        final double targetColumnPixel = cacheExtent +
            horizontalOffset.pixels +
            viewportDimension.width -
            startOfPinnedColumn;
        if (span.trailingOffset >= targetColumnPixel &&
            _lastRegularColumn == null) {
          _lastRegularColumn = column;
        }
        startOfRegularColumn = span.trailingOffset;
      } else {
        startOfPinnedColumn = span.trailingOffset;
      }
    }
    assert(newColumnMetrics.length >= _delegate.pinnedColumnCount);
    for (final _Span span in _columnMetrics.values) {
      span.dispose();
    }
    _columnMetrics = newColumnMetrics;

    _firstRegularRow = null;
    _lastRegularRow = null;
    double startOfRegularRow = 0;
    double startOfPinnedRow = 0;

    final Map<int, _Span> newRowMetrics = <int, _Span>{};
    for (int row = 0; row < _delegate.rowCount; row++) {
      final bool isPinned = row < _delegate.pinnedRowCount;
      final double leadingOffset =
          isPinned ? startOfPinnedRow : startOfRegularRow;
      _Span? span = _rowMetrics.remove(row);
      assert(needsDelegateRebuild || span != null);
      final TableSpan configuration = needsDelegateRebuild
          ? _delegate.rowBuilder(row)
          : span!.configuration;
      span ??= _Span();
      span.update(
        isPinned: isPinned,
        configuration: configuration,
        leadingOffset: leadingOffset,
        extent: configuration.extent.calculateExtent(TableSpanExtentDelegate(
          viewportExtent: viewportDimension.height,
          precedingExtent: leadingOffset,
        )),
      );
      newRowMetrics[row] = span;
      if (!isPinned) {
        if (span.trailingOffset >= verticalOffset.pixels &&
            _firstRegularRow == null) {
          _firstRegularRow = row;
        }
        final double targetRowPixel = cacheExtent +
            verticalOffset.pixels +
            viewportDimension.height -
            startOfPinnedRow;
        if (span.trailingOffset >= targetRowPixel && _lastRegularRow == null) {
          _lastRegularRow = row;
        }
        startOfRegularRow = span.trailingOffset;
      } else {
        startOfPinnedRow = span.trailingOffset;
      }
    }
    assert(newRowMetrics.length >= _delegate.pinnedRowCount);
    for (final _Span span in _rowMetrics.values) {
      span.dispose();
    }
    _rowMetrics = newRowMetrics;

    final double maxVerticalScrollExtent;
    if (_rowMetrics.length <= _delegate.pinnedRowCount) {
      assert(_firstRegularRow == null && _lastRegularRow == null);
      maxVerticalScrollExtent = 0.0;
    } else {
      final int lastRow = _rowMetrics.length - 1;
      if (_firstRegularRow != null) {
        _lastRegularRow ??= lastRow;
      }
      maxVerticalScrollExtent = math.max(
        0.0,
        _rowMetrics[lastRow]!.trailingOffset -
            viewportDimension.height +
            startOfPinnedRow,
      );
    }

    final double maxHorizontalScrollExtent;
    if (_columnMetrics.length <= _delegate.pinnedColumnCount) {
      assert(_firstRegularColumn == null && _lastRegularColumn == null);
      maxHorizontalScrollExtent = 0.0;
    } else {
      final int lastColumn = _columnMetrics.length - 1;
      if (_firstRegularColumn != null) {
        _lastRegularColumn ??= lastColumn;
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
  // TODO(Piinks): Add back infinite separately for easier review, <ISSUE>
  // Only relevant when the number of rows and columns is finite
  void _updateFirstAndLastVisibleCell() {
    _firstRegularColumn = null;
    _lastRegularColumn = null;
    // Cache
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
          _firstRegularColumn == null) {
        _firstRegularColumn = column;
      }
      if (endOfColumn >= targetColumnPixel && _lastRegularColumn == null) {
        _lastRegularColumn = column;
        break;
      }
    }
    if (_firstRegularColumn != null) {
      _lastRegularColumn ??= _columnMetrics.length - 1;
    }

    _firstRegularRow = null;
    _lastRegularRow = null;
    final double targetRowPixel = cacheExtent +
        verticalOffset.pixels +
        viewportDimension.height -
        _pinnedRowsExtent;
    for (int row = 0; row < _rowMetrics.length; row++) {
      if (_rowMetrics[row]!.isPinned) {
        continue;
      }
      final double endOfRow = _rowMetrics[row]!.trailingOffset;
      if (endOfRow >= verticalOffset.pixels && _firstRegularRow == null) {
        _firstRegularRow = row;
      }
      if (endOfRow >= targetRowPixel && _lastRegularRow == null) {
        _lastRegularRow = row;
        break;
      }
    }
    if (_firstRegularRow != null) {
      _lastRegularRow ??= _rowMetrics.length - 1;
    }
  }

  @override
  void layoutChildSequence() {
    if (needsDelegateRebuild || didResize) {
      // Recomputes the table metrics, invalidates any cached information.
      _updateAllMetrics();
    } else {
      // Updates the visible cells based on cached table metrics.
      _updateFirstAndLastVisibleCell();
    }

    if (_firstRegularCell == null &&
        _lastPinnedRow == null &&
        _lastPinnedColumn == null) {
      assert(_lastRegularCell == null);
      return;
    }

    final double? offsetIntoColumn = _firstRegularColumn != null
        ? horizontalOffset.pixels -
            _columnMetrics[_firstRegularColumn]!.leadingOffset -
            _pinnedColumnsExtent
        : null;
    final double? offsetIntoRow = _firstRegularRow != null
        ? verticalOffset.pixels -
            _rowMetrics[_firstRegularRow]!.leadingOffset -
            _pinnedRowsExtent
        : null;

    if (_lastPinnedRow != null && _lastPinnedColumn != null) {
      // Layout cells that are contained in both pinned rows and columns
      _layoutCells(
        start: const TableVicinity(column: 0, row: 0),
        end: TableVicinity(column: _lastPinnedColumn!, row: _lastPinnedRow!),
        offset: Offset.zero,
      );
    }

    if (_lastPinnedRow != null && _firstRegularColumn != null) {
      // Layout cells of pinned rows - those that do not intersect with pinned
      // columns above
      assert(_lastRegularColumn != null);
      assert(offsetIntoColumn != null);
      _layoutCells(
        start: TableVicinity(column: _firstRegularColumn!, row: 0),
        end: TableVicinity(column: _lastRegularColumn!, row: _lastPinnedRow!),
        offset: Offset(offsetIntoColumn!, 0),
      );
    }
    if (_lastPinnedColumn != null && _firstRegularRow != null) {
      // Lay out cells of pinned columns - those that do not intersect with
      // pinned rows above
      assert(_lastRegularRow != null);
      assert(offsetIntoRow != null);
      _layoutCells(
        start: TableVicinity(column: 0, row: _firstRegularRow!),
        end: TableVicinity(column: _lastPinnedColumn!, row: _lastRegularRow!),
        offset: Offset(0, offsetIntoRow!),
      );
    }
    if (_firstRegularCell != null) {
      // Lay out all other cells.
      assert(_lastRegularCell != null);
      assert(offsetIntoColumn != null);
      assert(offsetIntoRow != null);
      _layoutCells(
        start: _firstRegularCell!,
        end: _lastRegularCell!,
        offset: Offset(offsetIntoColumn!, offsetIntoRow!),
      );
    }
  }

  void _layoutCells({
    required TableVicinity start,
    required TableVicinity end,
    required Offset offset,
  }) {
    // TODO(Piinks): Assert here or somewhere else merged cells cannot span
    // pinned and unpinned cells (for merged cell follow-up), <ISSUE>
    double yPaintOffset = -offset.dy;
    for (int row = start.row; row <= end.row; row += 1) {
      double xPaintOffset = -offset.dx;
      final double rowHeight = _rowMetrics[row]!.extent;
      for (int column = start.column; column <= end.column; column += 1) {
        final double columnWidth = _columnMetrics[column]!.extent;

        final TableVicinity vicinity = TableVicinity(column: column, row: row);
        // TODO(Piinks): Add back merged cells, <ISSUE>

        final RenderBox? cell = buildOrObtainChildFor(vicinity);

        if (cell != null) {
          final TableViewParentData cellParentData = parentDataOf(cell);

          final BoxConstraints cellConstraints = BoxConstraints.tightFor(
            width: columnWidth,
            height: rowHeight,
          );
          cell.layout(cellConstraints);
          cellParentData.layoutOffset = Offset(xPaintOffset, yPaintOffset);
        }
        xPaintOffset += columnWidth;
      }
      yPaintOffset += rowHeight;
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
    if (_firstRegularCell == null &&
        _lastPinnedRow == null &&
        _lastPinnedColumn == null) {
      assert(_lastRegularCell == null);
      return;
    }

    // Subclasses of RenderTwoDimensionalViewport will typically use
    // firstChild to traverse children in a standard paint order that
    // follows row or column major ordering. Here is slightly different
    // as we break the cells up into 4 main paint passes to clip for overlap.

    if (_firstRegularCell != null) {
      // Paint all un-pinned cells
      assert(_lastRegularCell != null);
      _clipCellsHandle.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Rect.fromLTWH(
          _pinnedColumnsExtent,
          _pinnedRowsExtent,
          viewportDimension.width - _pinnedColumnsExtent,
          viewportDimension.height - _pinnedRowsExtent,
        ),
        (PaintingContext context, Offset offset) {
          _paintCells(
            context: context,
            offset: offset,
            leading: _firstRegularCell!,
            trailing: _lastRegularCell!,
          );
        },
        clipBehavior: clipBehavior,
        oldLayer: _clipCellsHandle.layer,
      );
    }

    if (_lastPinnedColumn != null && _firstRegularRow != null) {
      // Paint all pinned column cells that do not intersect with pinned row
      // cells.
      _clipPinnedColumnsHandle.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Rect.fromLTWH(
          0.0,
          _pinnedRowsExtent,
          _pinnedColumnsExtent,
          viewportDimension.height - _pinnedRowsExtent,
        ),
        (PaintingContext context, Offset offset) {
          _paintCells(
            context: context,
            offset: offset,
            leading: TableVicinity(column: 0, row: _firstRegularRow!),
            trailing: TableVicinity(
                column: _lastPinnedColumn!, row: _lastRegularRow!),
          );
        },
        clipBehavior: clipBehavior,
        oldLayer: _clipPinnedColumnsHandle.layer,
      );
    } else {
      _clipPinnedColumnsHandle.layer = null;
    }

    if (_lastPinnedRow != null && _firstRegularColumn != null) {
      // Paint all pinned row cells that do not intersect with pinned column
      // cells.
      _clipPinnedRowsHandle.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Rect.fromLTWH(
          _pinnedColumnsExtent,
          0.0,
          viewportDimension.width - _pinnedColumnsExtent,
          _pinnedRowsExtent,
        ),
        (PaintingContext context, Offset offset) {
          _paintCells(
            context: context,
            offset: offset,
            leading: TableVicinity(column: _firstRegularColumn!, row: 0),
            trailing: TableVicinity(
                column: _lastRegularColumn!, row: _lastPinnedRow!),
          );
        },
        clipBehavior: clipBehavior,
        oldLayer: _clipPinnedRowsHandle.layer,
      );
    } else {
      _clipPinnedRowsHandle.layer = null;
    }

    if (_lastPinnedRow != null && _lastPinnedColumn != null) {
      // Paint remaining pinned cells that represent the intersection of both
      // pinned rows and columns.
      _paintCells(
        context: context,
        offset: offset,
        leading: const TableVicinity(column: 0, row: 0),
        trailing:
            TableVicinity(column: _lastPinnedColumn!, row: _lastPinnedRow!),
      );
    }
  }

  void _paintCells({
    required PaintingContext context,
    required TableVicinity leading,
    required TableVicinity trailing,
    required Offset offset,
  }) {
    // Column decorations
    final LinkedHashMap<Rect, TableSpanDecoration> foregroundColumns =
        LinkedHashMap<Rect, TableSpanDecoration>();
    final LinkedHashMap<Rect, TableSpanDecoration> backgroundColumns =
        LinkedHashMap<Rect, TableSpanDecoration>();

    for (int column = leading.column; column <= trailing.column; column++) {
      final _Span span = _columnMetrics[column]!;
      if (span.configuration.backgroundDecoration != null ||
          span.configuration.foregroundDecoration != null) {
        final RenderBox leadingCell =
            getChildFor(TableVicinity(column: column, row: leading.row))!;
        final RenderBox trailingCell =
            getChildFor(TableVicinity(column: column, row: trailing.row))!;

        final Rect rect = Rect.fromPoints(
          parentDataOf(leadingCell).paintOffset! + offset,
          parentDataOf(trailingCell).paintOffset! +
              Offset(trailingCell.size.width, trailingCell.size.height) +
              offset,
        );

        if (span.configuration.backgroundDecoration != null) {
          backgroundColumns[rect] = span.configuration.backgroundDecoration!;
        }
        if (span.configuration.foregroundDecoration != null) {
          foregroundColumns[rect] = span.configuration.foregroundDecoration!;
        }
      }
    }

    // Row decorations
    final LinkedHashMap<Rect, TableSpanDecoration> foregroundRows =
        LinkedHashMap<Rect, TableSpanDecoration>();
    final LinkedHashMap<Rect, TableSpanDecoration> backgroundRows =
        LinkedHashMap<Rect, TableSpanDecoration>();

    for (int row = leading.row; row <= trailing.row; row++) {
      final _Span span = _rowMetrics[row]!;
      if (span.configuration.backgroundDecoration != null ||
          span.configuration.foregroundDecoration != null) {
        final RenderBox leadingCell =
            getChildFor(TableVicinity(column: leading.column, row: row))!;
        final RenderBox trailingCell =
            getChildFor(TableVicinity(column: trailing.column, row: row))!;

        final Rect rect = Rect.fromPoints(
          parentDataOf(leadingCell).paintOffset! + offset,
          parentDataOf(trailingCell).paintOffset! +
              Offset(trailingCell.size.width, trailingCell.size.height) +
              offset,
        );
        if (span.configuration.backgroundDecoration != null) {
          backgroundRows[rect] = span.configuration.backgroundDecoration!;
        }
        if (span.configuration.foregroundDecoration != null) {
          foregroundRows[rect] = span.configuration.foregroundDecoration!;
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
          decoration.paint(context.canvas, rect, Axis.horizontal);
        });
        backgroundColumns.forEach((Rect rect, TableSpanDecoration decoration) {
          decoration.paint(context.canvas, rect, Axis.vertical);
        });
        break;
      // Column major order. Columns go first.
      case Axis.horizontal:
        backgroundColumns.forEach((Rect rect, TableSpanDecoration decoration) {
          decoration.paint(context.canvas, rect, Axis.vertical);
        });
        backgroundRows.forEach((Rect rect, TableSpanDecoration decoration) {
          decoration.paint(context.canvas, rect, Axis.horizontal);
        });
    }

    // Cells
    for (int column = leading.column; column <= trailing.column; column++) {
      for (int row = leading.row; row <= trailing.row; row++) {
        final RenderBox cell =
            getChildFor(TableVicinity(column: column, row: row))!;
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
          decoration.paint(context.canvas, rect, Axis.horizontal);
        });
        foregroundColumns.forEach((Rect rect, TableSpanDecoration decoration) {
          decoration.paint(context.canvas, rect, Axis.vertical);
        });
        break;
      // Column major order. Columns go first.
      case Axis.horizontal:
        foregroundColumns.forEach((Rect rect, TableSpanDecoration decoration) {
          decoration.paint(context.canvas, rect, Axis.vertical);
        });
        foregroundRows.forEach((Rect rect, TableSpanDecoration decoration) {
          decoration.paint(context.canvas, rect, Axis.horizontal);
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

  double get trailingOffset => leadingOffset + extent;

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
