// Copyright 2013 The Flutter Authors. All rights reserved.
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
  const TableVicinity({
    required int row,
    required int column,
  }) : super(xIndex: column, yIndex: row);

  /// The row index of the child in the [TableView].
  ///
  /// Equivalent to the [yIndex].
  int get row => yIndex;

  /// The column index of the child in the [TableView].
  ///
  /// Equivalent to the [xIndex].
  int get column => xIndex;

  ///
  static const TableVicinity zero = TableVicinity(row: 0, column: 0);

  /// Returns a new TableVicinity, copying over the row and column fields with
  /// those provided, or maintaining the original values.
  TableVicinity copyWith({
    int? row,
    int? column,
  }) {
    return TableVicinity(
      row: row ?? this.row,
      column: column ?? this.column,
    );
  }

  @override
  String toString() => '(row: $row, column: $column)';
}

/// Parent data structure used by [RenderTableViewport].
class TableViewParentData extends TwoDimensionalViewportParentData {
  /// Converts the [ChildVicinity] to a [TableVicinity] for ease of use.
  TableVicinity get tableVicinity => vicinity as TableVicinity;

  ///
  int? rowMergeStart;

  ///
  int? rowMergeSpan;

  ///
  int? columnMergeStart;

  ///
  int? columnMergeSpan;

  @override
  String toString() {
    String mergeDetails = '';
    if (rowMergeStart != null || columnMergeStart != null) {
      mergeDetails += ', merged';
    }
    if (rowMergeStart != null) {
      mergeDetails +=
          ', rowMergeStart=$rowMergeStart, rowMergeSpan=$rowMergeSpan';
    }
    if (columnMergeStart != null) {
      mergeDetails +=
          ', columnMergeStart=$columnMergeStart, columnMergeSpan=$columnMergeSpan';
    }
    return super.toString() + mergeDetails;
  }
}

///
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
  })  : assert(
          (rowMergeStart == null && rowMergeSpan == null) ||
              (rowMergeStart != null && rowMergeSpan != null),
          'Row merge start and span must both be set, or both unset.',
        ),
        assert(
          (columnMergeStart == null && columnMergeSpan == null) ||
              (columnMergeStart != null && columnMergeSpan != null),
          'Column merge start and span must both be set, or both unset.',
        );

  ///
  final Widget child;

  ///
  final int? rowMergeStart;

  ///
  final int? rowMergeSpan;

  ///
  final int? columnMergeStart;

  ///
  final int? columnMergeSpan;

  ///
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
  })  : assert(
          (rowMergeStart == null && rowMergeSpan == null) ||
              (rowMergeStart != null && rowMergeSpan != null),
          'Row merge start and span must both be set, or both unset.',
        ),
        assert(
          (columnMergeStart == null && columnMergeSpan == null) ||
              (columnMergeStart != null && columnMergeSpan != null),
          'Column merge start and span must both be set, or both unset.',
        );

  final int? rowMergeStart;
  final int? rowMergeSpan;
  final int? columnMergeStart;
  final int? columnMergeSpan;

  @override
  void applyParentData(RenderObject renderObject) {
    final TableViewParentData parentData =
        renderObject.parentData! as TableViewParentData;
    bool needsLayout = false;
    if (parentData.rowMergeStart != rowMergeStart) {
      parentData.rowMergeStart = rowMergeStart;
      needsLayout = true;
    }
    if (parentData.rowMergeSpan != rowMergeSpan) {
      parentData.rowMergeSpan = rowMergeSpan;
      needsLayout = true;
    }
    if (parentData.columnMergeStart != columnMergeStart) {
      parentData.columnMergeStart = columnMergeStart;
      needsLayout = true;
    }
    if (parentData.columnMergeSpan != columnMergeSpan) {
      parentData.columnMergeSpan = columnMergeSpan;
      needsLayout = true;
    }

    final RenderObject? targetParent = renderObject.parent;
    if (targetParent is RenderObject && needsLayout) {
      targetParent.markNeedsLayout();
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
