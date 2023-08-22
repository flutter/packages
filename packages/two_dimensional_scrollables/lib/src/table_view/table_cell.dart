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
class TableViewParentData extends TwoDimensionalViewportParentData {
  // TODO(Piinks): Add back merged cells here, https://github.com/flutter/flutter/issues/131224
  /// Converts the [ChildVicinity] to a [TableVicinity] for ease of use.
  TableVicinity get tableVicinity => vicinity as TableVicinity;
}
