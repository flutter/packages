// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart' show ViewportOffset;
import 'package:flutter/widgets.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

void testFixes(TwoDimensionalChildManager childManager, double extent) {
  final TableCellBuilderDelegate tableDelegate = TableCellBuilderDelegate(
    columnBuilder: (int index) =>
        const TableSpan(extent: FixedTableSpanExtent(100)),
    rowBuilder: (int index) =>
        const TableSpan(extent: FixedTableSpanExtent(100)),
    cellBuilder: (BuildContext context, TableVicinity vicinity) =>
        const TableViewCell(child: SizedBox()),
  );
  final TreeRowBuilderDelegate treeDelegate = TreeRowBuilderDelegate(
    rowCount: 0,
    nodeBuilder: (BuildContext context, ChildVicinity vicinity) =>
        const SizedBox(),
    rowBuilder: (TreeVicinity vicinity) =>
        const TreeRow(extent: FixedTreeRowExtent(40)),
  );
  final ViewportOffset verticalOffset = ViewportOffset.zero();
  final ViewportOffset horizontalOffset = ViewportOffset.zero();

  TableView(cacheExtent: 100.0, delegate: tableDelegate);
  TableView(cacheExtent: extent, delegate: tableDelegate);
  TableView(cacheExtent: null, delegate: tableDelegate);
  TableView(
    cacheExtent: 100.0,
    scrollCacheExtent: const ScrollCacheExtent.viewport(1.0),
    delegate: tableDelegate,
  );
  TableView.builder(
    cacheExtent: 100.0,
    columnBuilder: (int index) =>
        const TableSpan(extent: FixedTableSpanExtent(100)),
    rowBuilder: (int index) =>
        const TableSpan(extent: FixedTableSpanExtent(100)),
    cellBuilder: (BuildContext context, TableVicinity vicinity) =>
        const TableViewCell(child: SizedBox()),
  );
  TableView.list(
    cacheExtent: 100.0,
    columnBuilder: (int index) =>
        const TableSpan(extent: FixedTableSpanExtent(100)),
    rowBuilder: (int index) =>
        const TableSpan(extent: FixedTableSpanExtent(100)),
  );
  TableViewport(
    verticalOffset: verticalOffset,
    verticalAxisDirection: AxisDirection.down,
    horizontalOffset: horizontalOffset,
    horizontalAxisDirection: AxisDirection.right,
    delegate: tableDelegate,
    mainAxis: Axis.vertical,
    cacheExtent: 100.0,
  );
  RenderTableViewport(
    horizontalOffset: horizontalOffset,
    horizontalAxisDirection: AxisDirection.right,
    verticalOffset: verticalOffset,
    verticalAxisDirection: AxisDirection.down,
    delegate: tableDelegate,
    mainAxis: Axis.vertical,
    childManager: childManager,
    cacheExtent: 100.0,
  );
  TreeView<String>(tree: const <TreeViewNode<String>>[], cacheExtent: 100.0);
  TreeView<String>(tree: const <TreeViewNode<String>>[], cacheExtent: null);
  TreeViewport(
    verticalOffset: verticalOffset,
    verticalAxisDirection: AxisDirection.down,
    horizontalOffset: horizontalOffset,
    horizontalAxisDirection: AxisDirection.right,
    delegate: treeDelegate,
    cacheExtent: 100.0,
    activeAnimations: const <UniqueKey, TreeViewNodesAnimation>{},
    rowDepths: const <int, int>{},
    indentation: 0.0,
  );
  RenderTreeViewport(
    activeAnimations: const <UniqueKey, TreeViewNodesAnimation>{},
    rowDepths: const <int, int>{},
    indentation: 0.0,
    horizontalOffset: horizontalOffset,
    horizontalAxisDirection: AxisDirection.right,
    verticalOffset: verticalOffset,
    verticalAxisDirection: AxisDirection.down,
    delegate: treeDelegate,
    childManager: childManager,
    cacheExtent: 100.0,
  );
}
