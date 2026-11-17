// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ViewportOffset;
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

// The viewport is 400x400 and every row and column is 100 pixels, so a cache
// extent of 150 pixels lays out rows/columns 0 through 5 (the trailing cache
// edge is at 550), but not 6.
const double _kViewportExtent = 400.0;
const double _kSpanExtent = 100.0;

ScrollCacheExtent _defaultScrollCacheExtent() {
  final delegate = TwoDimensionalChildBuilderDelegate(
    maxXIndex: 0,
    maxYIndex: 0,
    builder: (_, _) => const SizedBox(),
  );
  final verticalOffset = ViewportOffset.zero();
  final horizontalOffset = ViewportOffset.zero();
  final viewport = _DefaultTwoDimensionalViewport(
    horizontalOffset: horizontalOffset,
    horizontalAxisDirection: AxisDirection.right,
    verticalOffset: verticalOffset,
    verticalAxisDirection: AxisDirection.down,
    delegate: delegate,
    mainAxis: Axis.vertical,
    childManager: _NullChildManager(),
  );
  final ScrollCacheExtent result = viewport.scrollCacheExtent;
  viewport.dispose();
  horizontalOffset.dispose();
  verticalOffset.dispose();
  delegate.dispose();
  return result;
}

Widget _wrap(Widget child, {double width = _kViewportExtent, double height = _kViewportExtent}) {
  return MaterialApp(
    home: Center(
      child: SizedBox(width: width, height: height, child: child),
    ),
  );
}

Widget _buildTable({
  Axis mainAxis = Axis.vertical,
  double? cacheExtent,
  ScrollCacheExtent? scrollCacheExtent,
  double width = _kViewportExtent,
  double height = _kViewportExtent,
}) {
  return _wrap(
    width: width,
    height: height,
    TableView.builder(
      mainAxis: mainAxis,
      cacheExtent: cacheExtent,
      scrollCacheExtent: scrollCacheExtent,
      rowCount: 20,
      columnCount: 20,
      rowBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(_kSpanExtent)),
      columnBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(_kSpanExtent)),
      cellBuilder: (_, TableVicinity vicinity) {
        return TableViewCell(child: Text('R${vicinity.row}C${vicinity.column}'));
      },
    ),
  );
}

Widget _buildTree({
  double? cacheExtent,
  ScrollCacheExtent? scrollCacheExtent,
  double width = _kViewportExtent,
  double height = _kViewportExtent,
  int nodeCount = 20,
}) {
  return _wrap(
    width: width,
    height: height,
    TreeView<String>(
      tree: <TreeViewNode<String>>[
        for (int i = 0; i < nodeCount; i++) TreeViewNode<String>('Node $i'),
      ],
      cacheExtent: cacheExtent,
      scrollCacheExtent: scrollCacheExtent,
      treeRowBuilder: (_) => const TreeRow(extent: FixedTreeRowExtent(_kSpanExtent)),
      treeNodeBuilder: (_, TreeViewNode<String> node, _) => Text(node.content),
    ),
  );
}

Finder _text(String text) => find.text(text, skipOffstage: false);

void main() {
  group('TableView', () {
    testWidgets('scrollCacheExtent in pixels', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTable(scrollCacheExtent: const ScrollCacheExtent.pixels(150)));

      final RenderTableViewport viewport = tester.renderObject(find.byType(TableViewport));
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.pixels(150));
      expect(_text('R5C0'), findsOneWidget);
      expect(_text('R6C0'), findsNothing);
      expect(_text('R0C5'), findsOneWidget);
      expect(_text('R0C6'), findsNothing);
    });

    testWidgets('scrollCacheExtent as a multiple of the viewport', (WidgetTester tester) async {
      // 0.375 * 400 = 150 pixels in each axis.
      await tester.pumpWidget(
        _buildTable(scrollCacheExtent: const ScrollCacheExtent.viewport(0.375)),
      );

      final RenderTableViewport viewport = tester.renderObject(find.byType(TableViewport));
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.viewport(0.375));
      expect(_text('R5C0'), findsOneWidget);
      expect(_text('R6C0'), findsNothing);
      expect(_text('R0C5'), findsOneWidget);
      expect(_text('R0C6'), findsNothing);
    });

    testWidgets('viewport cache extent is applied to the leading edge', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _buildTable(scrollCacheExtent: const ScrollCacheExtent.viewport(0.375)),
      );
      final RenderTableViewport viewport = tester.renderObject(find.byType(TableViewport));
      viewport.verticalOffset.jumpTo(1000);
      viewport.horizontalOffset.jumpTo(1000);
      await tester.pump();

      // The leading cache edge is at 1000 - 150 = 850, so span 8 (800-900) is
      // laid out but span 7 (700-800) is not.
      expect(_text('R8C10'), findsOneWidget);
      expect(_text('R7C10'), findsNothing);
      expect(_text('R10C8'), findsOneWidget);
      expect(_text('R10C7'), findsNothing);
    });

    testWidgets('defaults when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTable());

      final RenderTableViewport viewport = tester.renderObject(find.byType(TableViewport));
      expect(viewport.scrollCacheExtent, _defaultScrollCacheExtent());
    });

    testWidgets('updates the render object', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTable(scrollCacheExtent: const ScrollCacheExtent.pixels(0)));
      expect(_text('R5C0'), findsNothing);

      await tester.pumpWidget(_buildTable(scrollCacheExtent: const ScrollCacheExtent.pixels(150)));
      final RenderTableViewport viewport = tester.renderObject(find.byType(TableViewport));
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.pixels(150));
      expect(_text('R5C0'), findsOneWidget);

      // Removing it falls back to the default.
      await tester.pumpWidget(_buildTable());
      expect(viewport.scrollCacheExtent, _defaultScrollCacheExtent());
    });

    testWidgets('default TableView constructor forwards scrollCacheExtent and cacheExtent', (
      WidgetTester tester,
    ) async {
      final delegate = TableCellBuilderDelegate(
        rowCount: 20,
        columnCount: 20,
        rowBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(_kSpanExtent)),
        columnBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(_kSpanExtent)),
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(child: Text('R${vicinity.row}C${vicinity.column}'));
        },
      );
      addTearDown(delegate.dispose);

      await tester.pumpWidget(
        _wrap(
          TableView(delegate: delegate, scrollCacheExtent: const ScrollCacheExtent.pixels(150)),
        ),
      );
      final RenderTableViewport viewport = tester.renderObject(find.byType(TableViewport));
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.pixels(150));
      expect(_text('R5C0'), findsOneWidget);
      expect(_text('R6C0'), findsNothing);

      // Deprecated cacheExtent is converted to pixels.
      await tester.pumpWidget(_wrap(TableView(delegate: delegate, cacheExtent: 50)));
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.pixels(50));
      expect(_text('R4C0'), findsOneWidget);
      expect(_text('R5C0'), findsNothing);

      // scrollCacheExtent takes precedence over deprecated cacheExtent.
      await tester.pumpWidget(
        _wrap(
          TableView(
            delegate: delegate,
            cacheExtent: 50,
            scrollCacheExtent: const ScrollCacheExtent.viewport(0.375),
          ),
        ),
      );
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.viewport(0.375));
      expect(_text('R5C0'), findsOneWidget);
      expect(_text('R6C0'), findsNothing);
    });

    testWidgets('TableView.list forwards scrollCacheExtent and cacheExtent', (
      WidgetTester tester,
    ) async {
      final cells = List<List<TableViewCell>>.generate(
        10,
        (int row) => List<TableViewCell>.generate(
          10,
          (int col) => TableViewCell(child: Text('R${row}C$col')),
        ),
      );

      await tester.pumpWidget(
        _wrap(
          TableView.list(
            scrollCacheExtent: const ScrollCacheExtent.pixels(150),
            rowBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(_kSpanExtent)),
            columnBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(_kSpanExtent)),
            cells: cells,
          ),
        ),
      );
      final RenderTableViewport viewport = tester.renderObject(find.byType(TableViewport));
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.pixels(150));
      expect(_text('R5C0'), findsOneWidget);
      expect(_text('R6C0'), findsNothing);

      // Deprecated cacheExtent is converted to pixels.
      await tester.pumpWidget(
        _wrap(
          TableView.list(
            cacheExtent: 50,
            rowBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(_kSpanExtent)),
            columnBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(_kSpanExtent)),
            cells: cells,
          ),
        ),
      );
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.pixels(50));
      expect(_text('R4C0'), findsOneWidget);
      expect(_text('R5C0'), findsNothing);

      // scrollCacheExtent takes precedence over deprecated cacheExtent.
      await tester.pumpWidget(
        _wrap(
          TableView.list(
            cacheExtent: 50,
            scrollCacheExtent: const ScrollCacheExtent.viewport(0.375),
            rowBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(_kSpanExtent)),
            columnBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(_kSpanExtent)),
            cells: cells,
          ),
        ),
      );
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.viewport(0.375));
      expect(_text('R5C0'), findsOneWidget);
      expect(_text('R6C0'), findsNothing);
    });

    testWidgets('TableView.builder deprecated cacheExtent fallback and precedence', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildTable(cacheExtent: 150));
      final RenderTableViewport viewport = tester.renderObject(find.byType(TableViewport));
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.pixels(150));
      expect(_text('R5C0'), findsOneWidget);
      expect(_text('R6C0'), findsNothing);

      await tester.pumpWidget(
        _buildTable(cacheExtent: 50, scrollCacheExtent: const ScrollCacheExtent.pixels(150)),
      );
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.pixels(150));
    });

    testWidgets('TableViewport forwards scrollCacheExtent and deprecated cacheExtent', (
      WidgetTester tester,
    ) async {
      final delegate = TableCellBuilderDelegate(
        columnCount: 0,
        rowCount: 0,
        columnBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(_kSpanExtent)),
        rowBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(_kSpanExtent)),
        cellBuilder: (_, _) => const TableViewCell(child: SizedBox()),
      );
      addTearDown(delegate.dispose);

      Widget buildViewport({double? cacheExtent, ScrollCacheExtent? scrollCacheExtent}) {
        return _wrap(
          _TestScrollView(
            delegate: delegate,
            viewportBuilder: (ViewportOffset verticalOffset, ViewportOffset horizontalOffset) {
              return TableViewport(
                verticalOffset: verticalOffset,
                verticalAxisDirection: AxisDirection.down,
                horizontalOffset: horizontalOffset,
                horizontalAxisDirection: AxisDirection.right,
                delegate: delegate,
                mainAxis: Axis.vertical,
                cacheExtent: cacheExtent,
                scrollCacheExtent: scrollCacheExtent,
              );
            },
          ),
        );
      }

      await tester.pumpWidget(buildViewport(scrollCacheExtent: const ScrollCacheExtent.pixels(25)));
      final RenderTableViewport viewport = tester.renderObject(find.byType(TableViewport));
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.pixels(25));
      expect(tester.widget<TableViewport>(find.byType(TableViewport)).cacheExtent, isNull);

      await tester.pumpWidget(
        buildViewport(scrollCacheExtent: const ScrollCacheExtent.viewport(1)),
      );
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.viewport(1));

      await tester.pumpWidget(buildViewport(cacheExtent: 75));
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.pixels(75));
      expect(tester.widget<TableViewport>(find.byType(TableViewport)).cacheExtent, 75);

      await tester.pumpWidget(
        buildViewport(cacheExtent: 75, scrollCacheExtent: const ScrollCacheExtent.viewport(0.5)),
      );
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.viewport(0.5));

      await tester.pumpWidget(buildViewport());
      expect(viewport.scrollCacheExtent, _defaultScrollCacheExtent());
    });

    testWidgets('viewport cache extent uses width horizontally and height vertically', (
      WidgetTester tester,
    ) async {
      // Width defaults to 400 -> horizontal cache is 0.5 * 400 = 200 (trailing edge at 600, spans 0..5).
      // Height is 200 -> vertical cache is 0.5 * 200 = 100 (trailing edge at 300, spans 0..2).
      for (final Axis mainAxis in Axis.values) {
        await tester.pumpWidget(
          _buildTable(
            mainAxis: mainAxis,
            height: 200,
            scrollCacheExtent: const ScrollCacheExtent.viewport(0.5),
          ),
        );

        expect(_text('R0C5'), findsOneWidget);
        expect(_text('R0C6'), findsNothing);
        expect(_text('R2C0'), findsOneWidget);
        expect(_text('R3C0'), findsNothing);
      }
    });

    test('RenderTableViewport constructor initializes defaults and explicit values', () {
      final delegate = TableCellBuilderDelegate(
        columnCount: 0,
        rowCount: 0,
        columnBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(_kSpanExtent)),
        rowBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(_kSpanExtent)),
        cellBuilder: (_, _) => const TableViewCell(child: SizedBox()),
      );
      addTearDown(delegate.dispose);
      final verticalOffset = ViewportOffset.zero();
      addTearDown(verticalOffset.dispose);
      final horizontalOffset = ViewportOffset.zero();
      addTearDown(horizontalOffset.dispose);

      final defaultViewport = RenderTableViewport(
        horizontalOffset: horizontalOffset,
        horizontalAxisDirection: AxisDirection.right,
        verticalOffset: verticalOffset,
        verticalAxisDirection: AxisDirection.down,
        delegate: delegate,
        mainAxis: Axis.vertical,
        childManager: _NullChildManager(),
      );
      addTearDown(defaultViewport.dispose);

      expect(defaultViewport.alignment, Alignment.topLeft);
      expect(defaultViewport.textDirection, isNull);
      expect(defaultViewport.scrollCacheExtent, _defaultScrollCacheExtent());

      final customViewport = RenderTableViewport(
        horizontalOffset: horizontalOffset,
        horizontalAxisDirection: AxisDirection.right,
        verticalOffset: verticalOffset,
        verticalAxisDirection: AxisDirection.down,
        delegate: delegate,
        mainAxis: Axis.vertical,
        childManager: _NullChildManager(),
        scrollCacheExtent: const ScrollCacheExtent.viewport(0.5),
        alignment: AlignmentDirectional.bottomEnd,
        textDirection: TextDirection.rtl,
      );
      addTearDown(customViewport.dispose);

      expect(customViewport.alignment, AlignmentDirectional.bottomEnd);
      expect(customViewport.textDirection, TextDirection.rtl);
      expect(customViewport.scrollCacheExtent, const ScrollCacheExtent.viewport(0.5));

      final deprecatedViewport = RenderTableViewport(
        horizontalOffset: horizontalOffset,
        horizontalAxisDirection: AxisDirection.right,
        verticalOffset: verticalOffset,
        verticalAxisDirection: AxisDirection.down,
        delegate: delegate,
        mainAxis: Axis.vertical,
        childManager: _NullChildManager(),
        cacheExtent: 120,
      );
      addTearDown(deprecatedViewport.dispose);
      expect(deprecatedViewport.scrollCacheExtent, const ScrollCacheExtent.pixels(120));

      final precedenceViewport = RenderTableViewport(
        horizontalOffset: horizontalOffset,
        horizontalAxisDirection: AxisDirection.right,
        verticalOffset: verticalOffset,
        verticalAxisDirection: AxisDirection.down,
        delegate: delegate,
        mainAxis: Axis.vertical,
        childManager: _NullChildManager(),
        cacheExtent: 120,
        scrollCacheExtent: const ScrollCacheExtent.viewport(0.25),
      );
      addTearDown(precedenceViewport.dispose);
      expect(precedenceViewport.scrollCacheExtent, const ScrollCacheExtent.viewport(0.25));
    });
  });

  group('TreeView', () {
    testWidgets('scrollCacheExtent in pixels', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTree(scrollCacheExtent: const ScrollCacheExtent.pixels(150)));

      final RenderTreeViewport viewport = tester.renderObject(find.byType(TreeViewport));
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.pixels(150));
      expect(_text('Node 5'), findsOneWidget);
      expect(_text('Node 6'), findsNothing);
    });

    testWidgets('scrollCacheExtent as a multiple of the viewport', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTree(scrollCacheExtent: const ScrollCacheExtent.viewport(0.375)),
      );

      final RenderTreeViewport viewport = tester.renderObject(find.byType(TreeViewport));
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.viewport(0.375));
      expect(_text('Node 5'), findsOneWidget);
      expect(_text('Node 6'), findsNothing);
    });

    testWidgets('cache extent is applied to the leading edge', (WidgetTester tester) async {
      // 0.375 * 400 = 150 pixels.
      await tester.pumpWidget(
        _buildTree(scrollCacheExtent: const ScrollCacheExtent.viewport(0.375)),
      );
      final RenderTreeViewport viewport = tester.renderObject(find.byType(TreeViewport));
      viewport.verticalOffset.jumpTo(1000);
      await tester.pump();

      // The leading cache edge is at 1000 - 150 = 850, so Node 8 (800-900) is
      // laid out but Node 7 (700-800) is not. The trailing cache edge is at
      // 1000 + 400 + 150 = 1550, so Node 15 (1500-1600) is laid out but
      // Node 16 (1600-1700) is not.
      expect(_text('Node 8'), findsOneWidget);
      expect(_text('Node 7'), findsNothing);
      expect(_text('Node 15'), findsOneWidget);
      expect(_text('Node 16'), findsNothing);

      // Rebuilding the delegate (triggering _updateRowMetrics instead of
      // _updateFirstAndLastVisibleRow) preserves leading-edge caching.
      await tester.pumpWidget(
        _buildTree(scrollCacheExtent: const ScrollCacheExtent.pixels(150), nodeCount: 21),
      );
      expect(_text('Node 8'), findsOneWidget);
      expect(_text('Node 7'), findsNothing);
      expect(_text('Node 15'), findsOneWidget);
      expect(_text('Node 16'), findsNothing);

      // Scrolling near the start clamps the leading edge at 0 without error.
      viewport.verticalOffset.jumpTo(50);
      await tester.pump();
      expect(_text('Node 0'), findsOneWidget);
    });

    testWidgets('updates the render object', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTree(scrollCacheExtent: const ScrollCacheExtent.pixels(0)));
      expect(_text('Node 5'), findsNothing);

      await tester.pumpWidget(_buildTree(scrollCacheExtent: const ScrollCacheExtent.pixels(150)));
      final RenderTreeViewport viewport = tester.renderObject(find.byType(TreeViewport));
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.pixels(150));
      expect(_text('Node 5'), findsOneWidget);

      await tester.pumpWidget(_buildTree());
      expect(viewport.scrollCacheExtent, _defaultScrollCacheExtent());
    });

    testWidgets('deprecated cacheExtent fallback and precedence', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTree(cacheExtent: 150));
      final RenderTreeViewport viewport = tester.renderObject(find.byType(TreeViewport));
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.pixels(150));
      expect(_text('Node 5'), findsOneWidget);
      expect(_text('Node 6'), findsNothing);

      await tester.pumpWidget(
        _buildTree(cacheExtent: 50, scrollCacheExtent: const ScrollCacheExtent.viewport(0.375)),
      );
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.viewport(0.375));
      expect(_text('Node 5'), findsOneWidget);
      expect(_text('Node 6'), findsNothing);
    });

    testWidgets('TreeViewport forwards scrollCacheExtent and deprecated cacheExtent', (
      WidgetTester tester,
    ) async {
      final delegate = TreeRowBuilderDelegate(
        rowCount: 0,
        nodeBuilder: (_, _) => const SizedBox(),
        rowBuilder: (_) => const TreeRow(extent: FixedTreeRowExtent(_kSpanExtent)),
      );
      addTearDown(delegate.dispose);

      Widget buildViewport({double? cacheExtent, ScrollCacheExtent? scrollCacheExtent}) {
        return _wrap(
          _TestScrollView(
            delegate: delegate,
            viewportBuilder: (ViewportOffset verticalOffset, ViewportOffset horizontalOffset) {
              return TreeViewport(
                verticalOffset: verticalOffset,
                verticalAxisDirection: AxisDirection.down,
                horizontalOffset: horizontalOffset,
                horizontalAxisDirection: AxisDirection.right,
                delegate: delegate,
                activeAnimations: const <UniqueKey, TreeViewNodesAnimation>{},
                rowDepths: const <int, int>{},
                indentation: 0.0,
                cacheExtent: cacheExtent,
                scrollCacheExtent: scrollCacheExtent,
              );
            },
          ),
        );
      }

      await tester.pumpWidget(buildViewport(scrollCacheExtent: const ScrollCacheExtent.pixels(25)));
      final RenderTreeViewport viewport = tester.renderObject(find.byType(TreeViewport));
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.pixels(25));
      expect(tester.widget<TreeViewport>(find.byType(TreeViewport)).cacheExtent, isNull);

      await tester.pumpWidget(
        buildViewport(scrollCacheExtent: const ScrollCacheExtent.viewport(1)),
      );
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.viewport(1));

      await tester.pumpWidget(buildViewport(cacheExtent: 75));
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.pixels(75));
      expect(tester.widget<TreeViewport>(find.byType(TreeViewport)).cacheExtent, 75);

      await tester.pumpWidget(
        buildViewport(cacheExtent: 75, scrollCacheExtent: const ScrollCacheExtent.viewport(0.5)),
      );
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.viewport(0.5));

      await tester.pumpWidget(buildViewport());
      expect(viewport.scrollCacheExtent, _defaultScrollCacheExtent());
    });

    testWidgets('viewport cache extent uses viewport height', (WidgetTester tester) async {
      // Height is 200 -> vertical cache is 0.5 * 200 = 100 (trailing edge at 300, nodes 0..2).
      await tester.pumpWidget(
        _buildTree(height: 200, scrollCacheExtent: const ScrollCacheExtent.viewport(0.5)),
      );

      expect(_text('Node 2'), findsOneWidget);
      expect(_text('Node 3'), findsNothing);
    });

    test('RenderTreeViewport constructor initializes defaults and explicit values', () {
      final delegate = TreeRowBuilderDelegate(
        rowCount: 0,
        nodeBuilder: (_, _) => const SizedBox(),
        rowBuilder: (_) => const TreeRow(extent: FixedTreeRowExtent(_kSpanExtent)),
      );
      addTearDown(delegate.dispose);
      final verticalOffset = ViewportOffset.zero();
      addTearDown(verticalOffset.dispose);
      final horizontalOffset = ViewportOffset.zero();
      addTearDown(horizontalOffset.dispose);

      final defaultViewport = RenderTreeViewport(
        horizontalOffset: horizontalOffset,
        horizontalAxisDirection: AxisDirection.right,
        verticalOffset: verticalOffset,
        verticalAxisDirection: AxisDirection.down,
        delegate: delegate,
        activeAnimations: const <UniqueKey, TreeViewNodesAnimation>{},
        rowDepths: const <int, int>{},
        indentation: 0.0,
        childManager: _NullChildManager(),
      );
      addTearDown(defaultViewport.dispose);

      expect(defaultViewport.alignment, Alignment.topLeft);
      expect(defaultViewport.textDirection, isNull);
      expect(defaultViewport.scrollCacheExtent, _defaultScrollCacheExtent());

      final customViewport = RenderTreeViewport(
        horizontalOffset: horizontalOffset,
        horizontalAxisDirection: AxisDirection.right,
        verticalOffset: verticalOffset,
        verticalAxisDirection: AxisDirection.down,
        delegate: delegate,
        activeAnimations: const <UniqueKey, TreeViewNodesAnimation>{},
        rowDepths: const <int, int>{},
        indentation: 8.0,
        childManager: _NullChildManager(),
        scrollCacheExtent: const ScrollCacheExtent.viewport(0.5),
        alignment: AlignmentDirectional.bottomEnd,
        textDirection: TextDirection.rtl,
      );
      addTearDown(customViewport.dispose);

      expect(customViewport.alignment, AlignmentDirectional.bottomEnd);
      expect(customViewport.textDirection, TextDirection.rtl);
      expect(customViewport.scrollCacheExtent, const ScrollCacheExtent.viewport(0.5));

      final deprecatedViewport = RenderTreeViewport(
        horizontalOffset: horizontalOffset,
        horizontalAxisDirection: AxisDirection.right,
        verticalOffset: verticalOffset,
        verticalAxisDirection: AxisDirection.down,
        delegate: delegate,
        activeAnimations: const <UniqueKey, TreeViewNodesAnimation>{},
        rowDepths: const <int, int>{},
        indentation: 0.0,
        childManager: _NullChildManager(),
        cacheExtent: 120,
      );
      addTearDown(deprecatedViewport.dispose);
      expect(deprecatedViewport.scrollCacheExtent, const ScrollCacheExtent.pixels(120));

      final precedenceViewport = RenderTreeViewport(
        horizontalOffset: horizontalOffset,
        horizontalAxisDirection: AxisDirection.right,
        verticalOffset: verticalOffset,
        verticalAxisDirection: AxisDirection.down,
        delegate: delegate,
        activeAnimations: const <UniqueKey, TreeViewNodesAnimation>{},
        rowDepths: const <int, int>{},
        indentation: 0.0,
        childManager: _NullChildManager(),
        cacheExtent: 120,
        scrollCacheExtent: const ScrollCacheExtent.viewport(0.25),
      );
      addTearDown(precedenceViewport.dispose);
      expect(precedenceViewport.scrollCacheExtent, const ScrollCacheExtent.viewport(0.25));
    });
  });
}

class _NullChildManager implements TwoDimensionalChildManager {
  @override
  Object? noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _DefaultTwoDimensionalViewport extends RenderTwoDimensionalViewport {
  _DefaultTwoDimensionalViewport({
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.delegate,
    required super.mainAxis,
    required super.childManager,
  });

  @override
  void layoutChildSequence() {}
}

// Hosts a viewport built by [viewportBuilder] in a two dimensional scrollable,
// which provides the scroll positions the viewport needs.
class _TestScrollView extends TwoDimensionalScrollView {
  const _TestScrollView({required super.delegate, required this.viewportBuilder});

  final TwoDimensionalViewport Function(
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  )
  viewportBuilder;

  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  ) {
    return viewportBuilder(verticalOffset, horizontalOffset);
  }
}
