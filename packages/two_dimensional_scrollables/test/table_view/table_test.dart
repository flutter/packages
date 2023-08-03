// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/table_view.dart';

const TableSpan span = TableSpan(extent: FixedTableSpanExtent(100));
const Widget cell = SizedBox.shrink();

void main() {
  group('TableView.builder', () {
    test('creates correct delegate', () {
      final TableView tableView = TableView.builder(
        columnCount: 3,
        rowCount: 2,
        rowBuilder: (_) => span,
        columnBuilder: (_) => span,
        cellBuilder: (_, __) => cell,
      );
      final TableCellBuilderDelegate delegate =
          tableView.delegate as TableCellBuilderDelegate;
      expect(delegate.pinnedRowCount, 0);
      expect(delegate.pinnedRowCount, 0);
      expect(delegate.rowCount, 2);
      expect(delegate.columnCount, 3);
      expect(delegate.columnBuilder(0), span);
      expect(delegate.rowBuilder(0), span);
      expect(
        delegate.builder(
            _NullBuildContext(), const TableVicinity(row: 0, column: 0)),
        cell,
      );
    });

    test('asserts correct counts', () {
      TableView? tableView;
      expect(
        () {
          tableView = TableView.builder(
            cellBuilder: (_, __) => cell,
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            columnCount: 1,
            rowCount: 1,
            pinnedColumnCount: -1, // asserts
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('pinnedColumnCount >= 0'),
          ),
        ),
      );
      expect(
        () {
          tableView = TableView.builder(
            cellBuilder: (_, __) => cell,
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            columnCount: 1,
            rowCount: 1,
            pinnedRowCount: -1, // asserts
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('pinnedRowCount >= 0'),
          ),
        ),
      );
      expect(
        () {
          tableView = TableView.builder(
            cellBuilder: (_, __) => cell,
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            columnCount: 1,
            rowCount: -1, // asserts
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('rowCount >= 0'),
          ),
        ),
      );
      expect(
        () {
          tableView = TableView.builder(
            cellBuilder: (_, __) => cell,
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            columnCount: -1, // asserts
            rowCount: 1,
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('columnCount >= 0'),
          ),
        ),
      );
      expect(
        () {
          tableView = TableView.builder(
            cellBuilder: (_, __) => cell,
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            columnCount: 1,
            pinnedColumnCount: 2, // asserts
            rowCount: 1,
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('columnCount >= pinnedColumnCount'),
          ),
        ),
      );
      expect(
        () {
          tableView = TableView.builder(
            cellBuilder: (_, __) => cell,
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            columnCount: 1,
            pinnedRowCount: 2, // asserts
            rowCount: 1,
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('rowCount >= pinnedRowCount'),
          ),
        ),
      );
      expect(tableView, isNull);
    });
  });

  group('TableView.list', () {
    test('creates correct delegate', () {
      final TableView tableView = TableView.list(
        rowBuilder: (_) => span,
        columnBuilder: (_) => span,
        cells: const <List<Widget>>[
          <Widget>[cell, cell, cell],
          <Widget>[cell, cell, cell]
        ],
      );
      final TableCellListDelegate delegate =
          tableView.delegate as TableCellListDelegate;
      expect(delegate.pinnedRowCount, 0);
      expect(delegate.pinnedRowCount, 0);
      expect(delegate.rowCount, 2);
      expect(delegate.columnCount, 3);
      expect(delegate.columnBuilder(0), span);
      expect(delegate.rowBuilder(0), span);
      expect(delegate.children[0][0], cell);
    });

    test('asserts correct counts', () {
      TableView? tableView;
      expect(
        () {
          tableView = TableView.list(
            cells: const <List<Widget>>[
              <Widget>[cell]
            ],
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            pinnedColumnCount: -1, // asserts
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('pinnedColumnCount >= 0'),
          ),
        ),
      );
      expect(
        () {
          tableView = TableView.list(
            cells: const <List<Widget>>[
              <Widget>[cell]
            ],
            columnBuilder: (_) => span,
            rowBuilder: (_) => span,
            pinnedRowCount: -1, // asserts
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('pinnedRowCount >= 0'),
          ),
        ),
      );
      expect(tableView, isNull);
    });
  });

  group('RenderTableViewport', () {
    testWidgets('parent data and table vicinities',
        (WidgetTester tester) async {
      final Map<TableVicinity, UniqueKey> childKeys =
          <TableVicinity, UniqueKey>{};
      const TableSpan span = TableSpan(extent: FixedTableSpanExtent(200));
      final TableView tableView = TableView.builder(
        rowCount: 5,
        columnCount: 5,
        columnBuilder: (_) => span,
        rowBuilder: (_) => span,
        cellBuilder: (_, TableVicinity vicinity) {
          childKeys[vicinity] = UniqueKey();
          return SizedBox.square(key: childKeys[vicinity], dimension: 200);
        },
      );
      TableViewParentData parentDataOf(RenderBox child) {
        return child.parentData! as TableViewParentData;
      }

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();
      final RenderTwoDimensionalViewport viewport = getViewport(
        tester,
        childKeys.values.first,
      );
      expect(viewport.mainAxis, Axis.vertical);
      // first child
      TableVicinity vicinity = const TableVicinity(column: 0, row: 0);
      expect(
        parentDataOf(viewport.firstChild!).vicinity,
        vicinity,
      );
      expect(
        parentDataOf(tester
                .renderObject<RenderBox>(find.byKey(childKeys[vicinity]!)))
            .vicinity,
        vicinity,
      );
      // after first child
      vicinity = const TableVicinity(column: 1, row: 0);
      expect(
        parentDataOf(viewport.childAfter(viewport.firstChild!)!).vicinity,
        vicinity,
      );
      expect(
        parentDataOf(tester
                .renderObject<RenderBox>(find.byKey(childKeys[vicinity]!)))
            .vicinity,
        vicinity,
      );
      // before first child (none)
      expect(
        viewport.childBefore(viewport.firstChild!),
        isNull,
      );

      // last child
      vicinity = const TableVicinity(column: 4, row: 4);
      expect(
        parentDataOf(viewport.lastChild!).vicinity,
        vicinity,
      );
      expect(
        parentDataOf(tester
                .renderObject<RenderBox>(find.byKey(childKeys[vicinity]!)))
            .vicinity,
        vicinity,
      );
      // after last child (none)
      expect(
        viewport.childAfter(viewport.lastChild!),
        isNull,
      );
      // before last child
      vicinity = const TableVicinity(column: 3, row: 4);
      expect(
        parentDataOf(viewport.childBefore(viewport.lastChild!)!).vicinity,
        vicinity,
      );
      expect(
        parentDataOf(tester
                .renderObject<RenderBox>(find.byKey(childKeys[vicinity]!)))
            .vicinity,
        vicinity,
      );
    });

    testWidgets('hit testing', (WidgetTester tester) async {
      // cells, rows, columns, mainAxis
      // TODO(Piinks)
    });

    testWidgets('provides correct details in TableSpanExtentDelegate',
        (WidgetTester tester) async {
      final TestTableSpanExtent columnExtent = TestTableSpanExtent();
      final TestTableSpanExtent rowExtent = TestTableSpanExtent();
      final ScrollController verticalController = ScrollController();
      final ScrollController horizontalController = ScrollController();
      final TableView tableView = TableView.builder(
        rowCount: 10,
        columnCount: 10,
        columnBuilder: (_) => TableSpan(extent: columnExtent),
        rowBuilder: (_) => TableSpan(extent: rowExtent),
        cellBuilder: (_, TableVicinity vicinity) {
          return const SizedBox.square(dimension: 100);
        },
        verticalDetails: ScrollableDetails.vertical(
          controller: verticalController,
        ),
        horizontalDetails: ScrollableDetails.horizontal(
          controller: horizontalController,
        ),
      );

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();
      expect(verticalController.position.pixels, 0.0);
      expect(horizontalController.position.pixels, 0.0);
      // Represents the last delegate provided to the last row and column
      expect(columnExtent.delegate.precedingExtent, 900.0);
      expect(columnExtent.delegate.viewportExtent, 800.0);
      expect(rowExtent.delegate.precedingExtent, 900.0);
      expect(rowExtent.delegate.viewportExtent, 600.0);

      verticalController.jumpTo(10.0);
      await tester.pump();
      expect(verticalController.position.pixels, 10.0);
      expect(horizontalController.position.pixels, 0.0);
      // Represents the last delegate provided to the last row and column
      expect(columnExtent.delegate.precedingExtent, 900.0);
      expect(columnExtent.delegate.viewportExtent, 800.0);
      expect(rowExtent.delegate.precedingExtent, 900.0);
      expect(rowExtent.delegate.viewportExtent, 600.0);

      horizontalController.jumpTo(10.0);
      await tester.pump();
      expect(verticalController.position.pixels, 10.0);
      expect(horizontalController.position.pixels, 10.0);
      // Represents the last delegate provided to the last row and column
      expect(columnExtent.delegate.precedingExtent, 900.0);
      expect(columnExtent.delegate.viewportExtent, 800.0);
      expect(rowExtent.delegate.precedingExtent, 900.0);
      expect(rowExtent.delegate.viewportExtent, 600.0);
    });

    testWidgets('regular layout - no pinning', (WidgetTester tester) async {
      final ScrollController verticalController = ScrollController();
      final ScrollController horizontalController = ScrollController();
      final TableView tableView = TableView.builder(
        rowCount: 50,
        columnCount: 50,
        columnBuilder: (_) => span,
        rowBuilder: (_) => span,
        cellBuilder: (_, TableVicinity vicinity) {
          return SizedBox.square(
              dimension: 200,
              child: Text('Row: ${vicinity.row} Column: ${vicinity.column}'),);
        },
        verticalDetails: ScrollableDetails.vertical(
          controller: verticalController,
        ),
        horizontalDetails: ScrollableDetails.horizontal(
          controller: horizontalController,
        ),
      );

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();
      expect(find.text('Row: 0 Column: 0'), findsOneWidget);
      expect(find.text('Row: 1 Column: 0'), findsOneWidget);
      expect(find.text('Row: 0 Column: 1'), findsOneWidget);
      expect(find.text('Row: 1 Column: 1'), findsOneWidget);
      // Within the cacheExtent
      expect(find.text('Row: 3 Column: 0'), findsOneWidget);
      expect(find.text('Row: 4 Column: 0'), findsOneWidget);
      expect(find.text('Row: 0 Column: 4'), findsOneWidget);
      expect(find.text('Row: 1 Column: 5'), findsOneWidget);
      // Outside of the cacheExtent
      expect(find.text('Row: 10 Column: 10'), findsNothing);
      expect(find.text('Row: 11 Column: 10'), findsNothing);
      expect(find.text('Row: 10 Column: 11'), findsNothing);
      expect(find.text('Row: 11 Column: 11'), findsNothing);

      // Let's scroll!
      verticalController.jumpTo(verticalController.position.maxScrollExtent);
      await tester.pump();
      expect(verticalController.position.pixels, 9400.0);
      expect(horizontalController.position.pixels, 0.0);
      expect(find.text('Row: 49 Column: 0'), findsOneWidget);
      expect(find.text('Row: 48 Column: 0'), findsOneWidget);
      expect(find.text('Row: 49 Column: 1'), findsOneWidget);
      expect(find.text('Row: 48 Column: 1'), findsOneWidget);
      // Within the CacheExtent
      expect(find.text('Row: 49 Column: 4'), findsOneWidget);
      expect(find.text('Row: 48 Column: 5'), findsOneWidget);
      // Not around.
      expect(find.text('Row: 0 Column: 0'), findsNothing);
      expect(find.text('Row: 1 Column: 0'), findsNothing);
      expect(find.text('Row: 0 Column: 1'), findsNothing);
      expect(find.text('Row: 1 Column: 1'), findsNothing);

      // Let's scroll some more!
    });

    testWidgets('pinned rows and columns', (WidgetTester tester) async {
      // Just pinned rows
      // Just pinned columns
      // Both
    });

    testWidgets('only paints visible cells', (WidgetTester tester) async {});

    testWidgets('paints decorations in order', (WidgetTester tester) async {});
  });
}

class _NullBuildContext implements BuildContext, TwoDimensionalChildManager {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

RenderTableViewport getViewport(WidgetTester tester, Key childKey) {
  return RenderAbstractViewport.of(tester.renderObject(find.byKey(childKey)))
      as RenderTableViewport;
}

class TestTableSpanExtent extends TableSpanExtent {
  late TableSpanExtentDelegate delegate;

  @override
  double calculateExtent(TableSpanExtentDelegate delegate) {
    this.delegate = delegate;
    return 100;
  }
}
