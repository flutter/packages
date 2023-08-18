// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

  @override
  String toString() => '(row: $row, column: $column)';
}

/// Parent data structure used by [RenderTableViewport].
///
/// The parent data primarily describes merged cell behavior for a child of the
/// viewport. This is controlled by the [ParentDataWidget], [TableViewCell].
class TableViewParentData extends TwoDimensionalViewportParentData {
  /// The index of the first column the [TableViewCell] is merged with.
  ///
  /// Pinned cells cannot be merged with cells that are not pinned.
  ///
  /// Must be greater than or equal to zero. If [columnMergeEnd] is set, this
  /// must not be null.
  int? columnMergeStart;

  /// The index of the last column the [TableViewCell] is merged with.
  ///
  /// Pinned cells cannot be merged with cells that are not pinned.
  ///
  /// If [columnMergeStart] is set, this must not be null.
  int? columnMergeEnd;

  /// The index of the first row the [TableViewCell] is merged with.
  ///
  /// Pinned cells cannot be merged with cells that are not pinned.
  ///
  /// Must be greater than or equal to zero. If [rowMergeEnd] is set, this
  /// must not be null.
  int? rowMergeStart;

  /// The index of the last row the [TableViewCell] is merged with.
  ///
  /// Pinned cells cannot be merged with cells that are not pinned.
  ///
  /// If [rowMergeStart] is set, this must not be null.
  int? rowMergeEnd;

  // TODO(Piinks): Add back merged cells here, https://github.com/flutter/flutter/issues/131224
  /// Converts the [ChildVicinity] to a [TableVicinity] for ease of use.
  TableVicinity get tableVicinity => vicinity as TableVicinity;

  @override
  String toString() {
    String appendedString = '';
    if (columnMergeEnd != null) {
      appendedString =
          '$appendedString merged columns $columnMergeStart-$columnMergeEnd;';
    }
    if (rowMergeEnd != null) {
      appendedString =
          '$appendedString merged rows $rowMergeStart-$rowMergeEnd;';
    }
    return '${super.toString()}; $appendedString';
  }
}

/// A widget that can wrap a child of a [TableView], relaying information
/// about merged cells.
class TableViewCell extends ParentDataWidget<TableViewParentData> {
  /// Creates a widget that managed how many cells a child of the [TableView]
  /// can span.
  const TableViewCell({
    super.key,
    required super.child,
    this.columnMergeStart,
    this.columnMergeEnd,
    this.rowMergeStart,
    this.rowMergeEnd,
  })  : assert(columnMergeStart == null || columnMergeStart >= 0),
        assert((columnMergeStart == null && columnMergeEnd == null) ||
            (columnMergeStart != null && columnMergeEnd != null)),
        assert(rowMergeStart == null || rowMergeStart >= 0),
        assert((rowMergeStart == null && rowMergeEnd == null) ||
            (rowMergeStart != null && rowMergeEnd != null));

  /// The index of the first column the [TableViewCell] is merged with.
  ///
  /// Must be greater than or equal to zero. If [columnMergeEnd] is set, this
  /// must not be null.
  final int? columnMergeStart;

  /// The inclusive index of the last column the [TableViewCell] is merged with.
  ///
  /// Must be greater than [columnMergeStart]. If [columnMergeStart] is set,
  /// this must not be null.
  final int? columnMergeEnd;

  /// The index of the first row the [TableViewCell] is merged with.
  ///
  /// Must be greater than or equal to zero. If [rowMergeEnd] is set, this
  /// must not be null.
  final int? rowMergeStart;

  /// The inclusive index of the last row the [TableViewCell] is merged with.
  ///
  /// Must be greater than [rowMergeStart]. If [rowMergeStart] is set,
  /// this must not be null.
  final int? rowMergeEnd;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is TableViewParentData);
    final TableViewParentData parentData =
        renderObject.parentData! as TableViewParentData;
    bool needsLayout = false;
    if (columnMergeStart != parentData.columnMergeStart ||
        columnMergeEnd != parentData.columnMergeEnd) {
      assert(_debugCheckValidMergeSequence(
          columnMergeStart, columnMergeEnd, 'column'));
      parentData.columnMergeStart = columnMergeStart;
      parentData.columnMergeEnd = columnMergeEnd;
      needsLayout = true;
    }
    if (rowMergeStart != parentData.rowMergeStart ||
        rowMergeEnd != parentData.rowMergeEnd) {
      assert(_debugCheckValidMergeSequence(
          columnMergeStart, columnMergeEnd, 'row'));
      parentData.rowMergeStart = rowMergeStart;
      parentData.rowMergeEnd = rowMergeEnd;
      needsLayout = true;
    }

    final RenderObject? targetParent = renderObject.parent;
    if (needsLayout && targetParent is RenderObject) {
      targetParent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => TableViewport;
}

bool _debugCheckValidMergeSequence(int? start, int? end, String span) {
  assert(
    start == null || start >= 0,
    'The starting $span merge index is an invalid value. The value given was '
    '$start. This valid must be greater than or equal to 0 if not null '
    '(meaning the TableViewCell is not merged with another).',
  );
  assert(
      (start == null && end == null) ||
          (start != null && end != null && start < end),
      'An invalid range for merging the $span axis of a TableViewCell was provided. '
      'The provided start and and were ($start - $end). If not null, these valus '
      'must both be set and the start index must be greater than the ending index.');
  return true;
}
