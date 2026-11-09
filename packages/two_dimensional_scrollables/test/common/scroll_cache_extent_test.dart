// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

// The viewport is 400x400 and every row and column is 100 pixels, so a cache
// extent of 150 pixels lays out rows/columns 0 through 5 (the trailing cache
// edge is at 550), but not 6.
const double _kViewportExtent = 400.0;
const double _kSpanExtent = 100.0;

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Center(
      child: SizedBox(width: _kViewportExtent, height: _kViewportExtent, child: child),
    ),
  );
}

Widget _buildTable({ScrollCacheExtent? scrollCacheExtent}) {
  return _wrap(
    TableView.builder(
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

Widget _buildTree({ScrollCacheExtent? scrollCacheExtent}) {
  return _wrap(
    TreeView<String>(
      tree: <TreeViewNode<String>>[for (int i = 0; i < 20; i++) TreeViewNode<String>('Node $i')],
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
      expect(
        viewport.scrollCacheExtent,
        const ScrollCacheExtent.pixels(RenderAbstractViewport.defaultCacheExtent),
      );
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
      expect(
        viewport.scrollCacheExtent,
        const ScrollCacheExtent.pixels(RenderAbstractViewport.defaultCacheExtent),
      );
    });

    testWidgets('TableViewport forwards scrollCacheExtent', (WidgetTester tester) async {
      final delegate = TableCellBuilderDelegate(
        columnCount: 0,
        rowCount: 0,
        columnBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(_kSpanExtent)),
        rowBuilder: (_) => const TableSpan(extent: FixedTableSpanExtent(_kSpanExtent)),
        cellBuilder: (_, _) => const TableViewCell(child: SizedBox()),
      );
      addTearDown(delegate.dispose);

      Widget buildViewport({ScrollCacheExtent? scrollCacheExtent}) {
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
                scrollCacheExtent: scrollCacheExtent,
              );
            },
          ),
        );
      }

      await tester.pumpWidget(buildViewport(scrollCacheExtent: const ScrollCacheExtent.pixels(25)));
      final RenderTableViewport viewport = tester.renderObject(find.byType(TableViewport));
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.pixels(25));

      await tester.pumpWidget(
        buildViewport(scrollCacheExtent: const ScrollCacheExtent.viewport(1)),
      );
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.viewport(1));

      await tester.pumpWidget(buildViewport());
      expect(
        viewport.scrollCacheExtent,
        const ScrollCacheExtent.pixels(RenderAbstractViewport.defaultCacheExtent),
      );
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

    testWidgets('updates the render object', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTree(scrollCacheExtent: const ScrollCacheExtent.pixels(0)));
      expect(_text('Node 5'), findsNothing);

      await tester.pumpWidget(_buildTree(scrollCacheExtent: const ScrollCacheExtent.pixels(150)));
      final RenderTreeViewport viewport = tester.renderObject(find.byType(TreeViewport));
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.pixels(150));
      expect(_text('Node 5'), findsOneWidget);

      await tester.pumpWidget(_buildTree());
      expect(
        viewport.scrollCacheExtent,
        const ScrollCacheExtent.pixels(RenderAbstractViewport.defaultCacheExtent),
      );
    });

    testWidgets('TreeViewport forwards scrollCacheExtent', (WidgetTester tester) async {
      final delegate = TreeRowBuilderDelegate(
        rowCount: 0,
        nodeBuilder: (_, _) => const SizedBox(),
        rowBuilder: (_) => const TreeRow(extent: FixedTreeRowExtent(_kSpanExtent)),
      );
      addTearDown(delegate.dispose);

      Widget buildViewport({ScrollCacheExtent? scrollCacheExtent}) {
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
                scrollCacheExtent: scrollCacheExtent,
              );
            },
          ),
        );
      }

      await tester.pumpWidget(buildViewport(scrollCacheExtent: const ScrollCacheExtent.pixels(25)));
      final RenderTreeViewport viewport = tester.renderObject(find.byType(TreeViewport));
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.pixels(25));

      await tester.pumpWidget(
        buildViewport(scrollCacheExtent: const ScrollCacheExtent.viewport(1)),
      );
      expect(viewport.scrollCacheExtent, const ScrollCacheExtent.viewport(1));

      await tester.pumpWidget(buildViewport());
      expect(
        viewport.scrollCacheExtent,
        const ScrollCacheExtent.pixels(RenderAbstractViewport.defaultCacheExtent),
      );
    });
  });
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
