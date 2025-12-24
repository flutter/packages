// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'table.dart';

/// The relative position of a child in a [TableViewport] in relation
/// to other children of the viewport, in terms of rows and columns.
///
/// This subclass translates the abstract [ChildVicinity.xIndex] and
/// [ChildVicinity.yIndex] into terms of rows and columns for ease of use within
/// the context of a [TableView].
@immutable
class TableVicinity extends ChildVicinity {
  /// Creates a reference to a child in a [TableView], with the [xIndex] and
  /// [yIndex] converted to terms of [row] and [column].
  const TableVicinity({required int row, required int column})
    : super(xIndex: column, yIndex: row);

  /// The row index of the child in the [TableView].
  ///
  /// Equivalent to the [yIndex].
  int get row => yIndex;

  /// The column index of the child in the [TableView].
  ///
  /// Equivalent to the [xIndex].
  int get column => xIndex;

  /// The origin vicinity of the [TableView], (0,0).
  static const TableVicinity zero = TableVicinity(row: 0, column: 0);

  /// Returns a new [TableVicinity], copying over the row and column fields with
  /// those provided, or maintaining the original values.
  TableVicinity copyWith({int? row, int? column}) {
    return TableVicinity(row: row ?? this.row, column: column ?? this.column);
  }

  @override
  String toString() => '(row: $row, column: $column)';
}

/// Parent data structure used by [RenderTableViewport].
class TableViewParentData extends TwoDimensionalViewportParentData {
  /// Converts the [ChildVicinity] to a [TableVicinity] for ease of use.
  TableVicinity get tableVicinity => vicinity as TableVicinity;

  /// Represents the row index where a merged cell in the table begins.
  ///
  /// Defaults to null, meaning a non-merged cell. A value must be provided if
  /// a value is provided for [rowMergeSpan].
  int? rowMergeStart;

  /// Represents the number of rows spanned by a merged cell.
  ///
  /// Defaults to null, meaning the cell is not merged. A value must be provided
  /// if a value is provided for [rowMergeStart].
  int? rowMergeSpan;

  /// Represents the column index where a merged cell in the table begins.
  ///
  /// Defaults to null, meaning a non-merged cell. A value must be provided if
  /// a value is provided for [columnMergeSpan].
  int? columnMergeStart;

  /// Represents the number of columns spanned by a merged cell.
  ///
  /// Defaults to null, meaning the cell is not merged. A value must be provided
  /// if a value is provided for [columnMergeStart].
  int? columnMergeSpan;

  @override
  String toString() {
    var mergeDetails = '';
    if (rowMergeStart != null || columnMergeStart != null) {
      mergeDetails += ', merged';
    }
    if (rowMergeStart != null) {
      mergeDetails +=
          ', rowMergeStart=$rowMergeStart, '
          'rowMergeSpan=$rowMergeSpan';
    }
    if (columnMergeStart != null) {
      mergeDetails +=
          ', columnMergeStart=$columnMergeStart, '
          'columnMergeSpan=$columnMergeSpan';
    }
    return super.toString() + mergeDetails;
  }
}

/// Creates a cell of the [TableView], along with information regarding merged
/// cells and [RepaintBoundary]s.
///
/// When merging cells in a [TableView], the same child should be returned from
/// every vicinity the merged cell contains. The `build` method will only be
/// called once for a merged cell, but since the table's children are lazily
/// laid out, returning the same child ensures the merged cell can be built no
/// matter which part of it is visible.
class TableViewCell extends StatelessWidget {
  /// Creates a widget that controls how a child of a [TableView] spans across
  /// multiple rows or columns.
  const TableViewCell({
    super.key,
    this.rowMergeStart,
    this.rowMergeSpan,
    this.columnMergeStart,
    this.columnMergeSpan,
    this.addRepaintBoundaries = true,
    required this.child,
  }) : assert(
         (rowMergeStart == null && rowMergeSpan == null) ||
             (rowMergeStart != null && rowMergeSpan != null),
         'Row merge start and span must both be set, or both unset.',
       ),
       assert(rowMergeStart == null || rowMergeStart >= 0),
       assert(rowMergeSpan == null || rowMergeSpan > 0),
       assert(
         (columnMergeStart == null && columnMergeSpan == null) ||
             (columnMergeStart != null && columnMergeSpan != null),
         'Column merge start and span must both be set, or both unset.',
       ),
       assert(columnMergeStart == null || columnMergeStart >= 0),
       assert(columnMergeSpan == null || columnMergeSpan > 0);

  /// The child contained in this cell of the [TableView].
  final Widget child;

  /// Represents the row index where a merged cell in the table begins.
  ///
  /// Defaults to null, meaning a non-merged cell. A value must be provided if
  /// a value is provided for [rowMergeSpan].
  final int? rowMergeStart;

  /// Represents the number of rows spanned by a merged cell.
  ///
  /// Defaults to null, meaning the cell is not merged. A value must be provided
  /// if a value is provided for [rowMergeStart].
  final int? rowMergeSpan;

  /// Represents the column index where a merged cell in the table begins.
  ///
  /// Defaults to null, meaning a non-merged cell. A value must be provided if
  /// a value is provided for [columnMergeSpan].
  final int? columnMergeStart;

  /// Represents the number of columns spanned by a merged cell.
  ///
  /// Defaults to null, meaning the cell is not merged. A value must be provided
  /// if a value is provided for [columnMergeStart].
  final int? columnMergeSpan;

  /// Whether to wrap each child in a [RepaintBoundary].
  ///
  /// Typically, children in a scrolling container are wrapped in repaint
  /// boundaries so that they do not need to be repainted as the list scrolls.
  /// If the children are easy to repaint (e.g., solid color blocks or a short
  /// snippet of text), it might be more efficient to not add a repaint boundary
  /// and instead always repaint the children during scrolling.
  ///
  /// Defaults to true.
  final bool addRepaintBoundaries;

  @override
  Widget build(BuildContext context) {
    Widget child = this.child;

    if (addRepaintBoundaries) {
      child = RepaintBoundary(child: child);
    }

    return _TableViewCell(
      rowMergeStart: rowMergeStart,
      rowMergeSpan: rowMergeSpan,
      columnMergeStart: columnMergeStart,
      columnMergeSpan: columnMergeSpan,
      child: child,
    );
  }
}

class _TableViewCell extends ParentDataWidget<TableViewParentData> {
  const _TableViewCell({
    this.rowMergeStart,
    this.rowMergeSpan,
    this.columnMergeStart,
    this.columnMergeSpan,
    required super.child,
  });

  final int? rowMergeStart;
  final int? rowMergeSpan;
  final int? columnMergeStart;
  final int? columnMergeSpan;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData! as TableViewParentData;
    var needsLayout = false;
    if (parentData.rowMergeStart != rowMergeStart) {
      assert(rowMergeStart == null || rowMergeStart! >= 0);
      parentData.rowMergeStart = rowMergeStart;
      needsLayout = true;
    }
    if (parentData.rowMergeSpan != rowMergeSpan) {
      assert(rowMergeSpan == null || rowMergeSpan! > 0);
      parentData.rowMergeSpan = rowMergeSpan;
      needsLayout = true;
    }
    if (parentData.columnMergeStart != columnMergeStart) {
      assert(columnMergeStart == null || columnMergeStart! >= 0);
      parentData.columnMergeStart = columnMergeStart;
      needsLayout = true;
    }
    if (parentData.columnMergeSpan != columnMergeSpan) {
      assert(columnMergeSpan == null || columnMergeSpan! > 0);
      parentData.columnMergeSpan = columnMergeSpan;
      needsLayout = true;
    }

    if (needsLayout) {
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => TableViewport;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    if (rowMergeStart != null) {
      properties.add(IntProperty('rowMergeStart', rowMergeStart));
      properties.add(IntProperty('rowMergeSpan', rowMergeSpan));
    }
    if (columnMergeStart != null) {
      properties.add(IntProperty('columnMergeStart', columnMergeStart));
      properties.add(IntProperty('columnMergeSpan', columnMergeSpan));
    }
  }
}
