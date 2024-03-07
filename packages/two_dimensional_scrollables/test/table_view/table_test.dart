// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

const TableSpan span = TableSpan(extent: FixedTableSpanExtent(100));
const TableViewCell cell = TableViewCell(child: SizedBox.shrink());

TableSpan getTappableSpan(int index, VoidCallback callback) {
  return TableSpan(
    extent: const FixedTableSpanExtent(100),
    recognizerFactories: <Type, GestureRecognizerFactory>{
      TapGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
        () => TapGestureRecognizer(),
        (TapGestureRecognizer t) => t.onTap = () => callback(),
      ),
    },
  );
}

TableSpan getMouseTrackingSpan(
  int index, {
  PointerEnterEventListener? onEnter,
  PointerExitEventListener? onExit,
}) {
  return TableSpan(
    extent: const FixedTableSpanExtent(100),
    onEnter: onEnter,
    onExit: onExit,
    cursor: SystemMouseCursors.cell,
  );
}

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
      expect(delegate.buildColumn(0), span);
      expect(delegate.buildRow(0), span);
      expect(
        delegate.builder(
          _NullBuildContext(),
          TableVicinity.zero,
        ),
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
        cells: const <List<TableViewCell>>[
          <TableViewCell>[cell, cell, cell],
          <TableViewCell>[cell, cell, cell]
        ],
      );
      final TableCellListDelegate delegate =
          tableView.delegate as TableCellListDelegate;
      expect(delegate.pinnedRowCount, 0);
      expect(delegate.pinnedRowCount, 0);
      expect(delegate.rowCount, 2);
      expect(delegate.columnCount, 3);
      expect(delegate.buildColumn(0), span);
      expect(delegate.buildRow(0), span);
      expect(delegate.children[0][0], cell);
    });

    test('asserts correct counts', () {
      TableView? tableView;
      expect(
        () {
          tableView = TableView.list(
            cells: const <List<TableViewCell>>[
              <TableViewCell>[cell]
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
            cells: const <List<TableViewCell>>[
              <TableViewCell>[cell]
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
          childKeys[vicinity] = childKeys[vicinity] ?? UniqueKey();
          return TableViewCell(
            child: SizedBox.square(
              key: childKeys[vicinity],
              dimension: 200,
            ),
          );
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
      TableVicinity vicinity = TableVicinity.zero;
      TableViewParentData parentData = parentDataOf(
        viewport.firstChild!,
      );
      expect(parentData.vicinity, vicinity);
      expect(parentData.layoutOffset, Offset.zero);
      expect(parentData.isVisible, isTrue);
      // after first child
      vicinity = const TableVicinity(column: 1, row: 0);

      parentData = parentDataOf(
        viewport.childAfter(viewport.firstChild!)!,
      );
      expect(parentData.vicinity, vicinity);
      expect(parentData.layoutOffset, const Offset(200, 0.0));
      expect(parentData.isVisible, isTrue);
      // before first child (none)
      expect(
        viewport.childBefore(viewport.firstChild!),
        isNull,
      );

      // last child
      vicinity = const TableVicinity(column: 4, row: 4);
      parentData = parentDataOf(viewport.lastChild!);
      expect(parentData.vicinity, vicinity);
      expect(parentData.layoutOffset, const Offset(800.0, 800.0));
      expect(parentData.isVisible, isFalse);
      // after last child (none)
      expect(
        viewport.childAfter(viewport.lastChild!),
        isNull,
      );
      // before last child
      vicinity = const TableVicinity(column: 3, row: 4);
      parentData = parentDataOf(
        viewport.childBefore(viewport.lastChild!)!,
      );
      expect(parentData.vicinity, vicinity);
      expect(parentData.layoutOffset, const Offset(600.0, 800.0));
      expect(parentData.isVisible, isFalse);
    });

    testWidgets('TableSpanPadding', (WidgetTester tester) async {
      final Map<TableVicinity, UniqueKey> childKeys =
          <TableVicinity, UniqueKey>{};
      const TableSpan columnSpan = TableSpan(
        extent: FixedTableSpanExtent(200),
        padding: TableSpanPadding(
          leading: 10.0,
          trailing: 20.0,
        ),
      );
      const TableSpan rowSpan = TableSpan(
        extent: FixedTableSpanExtent(200),
        padding: TableSpanPadding(
          leading: 30.0,
          trailing: 40.0,
        ),
      );
      TableView tableView = TableView.builder(
        rowCount: 2,
        columnCount: 2,
        columnBuilder: (_) => columnSpan,
        rowBuilder: (_) => rowSpan,
        cellBuilder: (_, TableVicinity vicinity) {
          childKeys[vicinity] = childKeys[vicinity] ?? UniqueKey();
          return TableViewCell(
            child: SizedBox.square(
              key: childKeys[vicinity],
              dimension: 200,
            ),
          );
        },
      );
      TableViewParentData parentDataOf(RenderBox child) {
        return child.parentData! as TableViewParentData;
      }

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();
      RenderTwoDimensionalViewport viewport = getViewport(
        tester,
        childKeys.values.first,
      );
      // first child
      TableVicinity vicinity = TableVicinity.zero;
      TableViewParentData parentData = parentDataOf(
        viewport.firstChild!,
      );
      expect(parentData.vicinity, vicinity);
      expect(
        parentData.layoutOffset,
        const Offset(
          10.0, // Leading 10 pixels before first column
          30.0, // leading 30 pixels before first row
        ),
      );
      // after first child
      vicinity = const TableVicinity(column: 1, row: 0);

      parentData = parentDataOf(
        viewport.childAfter(viewport.firstChild!)!,
      );
      expect(parentData.vicinity, vicinity);
      expect(
        parentData.layoutOffset,
        const Offset(
          240, // 10 leading + 200 first column + 20 trailing + 10 leading
          30.0, // leading 30 pixels before first row
        ),
      );

      // last child
      vicinity = const TableVicinity(column: 1, row: 1);
      parentData = parentDataOf(viewport.lastChild!);
      expect(parentData.vicinity, vicinity);
      expect(
        parentData.layoutOffset,
        const Offset(
          240.0, // 10 leading + 200 first column + 20 trailing + 10 leading
          300.0, // 30 leading + 200 first row + 40 trailing + 30 leading
        ),
      );

      // reverse
      tableView = TableView.builder(
        rowCount: 2,
        columnCount: 2,
        verticalDetails: const ScrollableDetails.vertical(reverse: true),
        horizontalDetails: const ScrollableDetails.horizontal(reverse: true),
        columnBuilder: (_) => columnSpan,
        rowBuilder: (_) => rowSpan,
        cellBuilder: (_, TableVicinity vicinity) {
          childKeys[vicinity] = childKeys[vicinity] ?? UniqueKey();
          return TableViewCell(
            child: SizedBox.square(
              key: childKeys[vicinity],
              dimension: 200,
            ),
          );
        },
      );

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();
      viewport = getViewport(
        tester,
        childKeys.values.first,
      );
      // first child
      vicinity = TableVicinity.zero;
      parentData = parentDataOf(
        viewport.firstChild!,
      );
      expect(parentData.vicinity, vicinity);
      // layoutOffset is later corrected for reverse in the paintOffset
      expect(parentData.paintOffset, const Offset(590.0, 370.0));
      // after first child
      vicinity = const TableVicinity(column: 1, row: 0);

      parentData = parentDataOf(
        viewport.childAfter(viewport.firstChild!)!,
      );
      expect(parentData.vicinity, vicinity);
      expect(parentData.paintOffset, const Offset(360.0, 370.0));

      // last child
      vicinity = const TableVicinity(column: 1, row: 1);
      parentData = parentDataOf(viewport.lastChild!);
      expect(parentData.vicinity, vicinity);
      expect(parentData.paintOffset, const Offset(360.0, 100.0));
    });

    testWidgets('TableSpan gesture hit testing', (WidgetTester tester) async {
      int tapCounter = 0;
      // Rows
      TableView tableView = TableView.builder(
        rowCount: 50,
        columnCount: 50,
        columnBuilder: (_) => span,
        rowBuilder: (int index) => index.isEven
            ? getTappableSpan(
                index,
                () => tapCounter++,
              )
            : span,
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: SizedBox.square(
              dimension: 100,
              child: Text('Row: ${vicinity.row} Column: ${vicinity.column}'),
            ),
          );
        },
      );

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();

      // Even rows are set up for taps.
      expect(tapCounter, 0);
      // Tap along along a row
      await tester.tap(find.text('Row: 0 Column: 0'));
      await tester.tap(find.text('Row: 0 Column: 1'));
      await tester.tap(find.text('Row: 0 Column: 2'));
      await tester.tap(find.text('Row: 0 Column: 3'));
      expect(tapCounter, 4);
      // Tap along some odd rows
      await tester.tap(find.text('Row: 1 Column: 0'));
      await tester.tap(find.text('Row: 1 Column: 1'));
      await tester.tap(find.text('Row: 3 Column: 2'));
      await tester.tap(find.text('Row: 5 Column: 3'));
      expect(tapCounter, 4);
      // Check other even rows
      await tester.tap(find.text('Row: 2 Column: 1'));
      await tester.tap(find.text('Row: 2 Column: 2'));
      await tester.tap(find.text('Row: 4 Column: 4'));
      await tester.tap(find.text('Row: 4 Column: 5'));
      expect(tapCounter, 8);

      // Columns
      tapCounter = 0;
      tableView = TableView.builder(
        rowCount: 50,
        columnCount: 50,
        rowBuilder: (_) => span,
        columnBuilder: (int index) => index.isEven
            ? getTappableSpan(
                index,
                () => tapCounter++,
              )
            : span,
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: SizedBox.square(
              dimension: 100,
              child: Text('Row: ${vicinity.row} Column: ${vicinity.column}'),
            ),
          );
        },
      );

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();

      // Even columns are set up for taps.
      expect(tapCounter, 0);
      // Tap along along a column
      await tester.tap(find.text('Row: 1 Column: 0'));
      await tester.tap(find.text('Row: 2 Column: 0'));
      await tester.tap(find.text('Row: 3 Column: 0'));
      await tester.tap(find.text('Row: 4 Column: 0'));
      expect(tapCounter, 4);
      // Tap along some odd columns
      await tester.tap(find.text('Row: 1 Column: 1'));
      await tester.tap(find.text('Row: 2 Column: 1'));
      await tester.tap(find.text('Row: 3 Column: 3'));
      await tester.tap(find.text('Row: 4 Column: 3'));
      expect(tapCounter, 4);
      // Check other even columns
      await tester.tap(find.text('Row: 2 Column: 2'));
      await tester.tap(find.text('Row: 3 Column: 2'));
      await tester.tap(find.text('Row: 4 Column: 4'));
      await tester.tap(find.text('Row: 5 Column: 4'));
      expect(tapCounter, 8);

      // Intersecting - main axis sets precedence
      int rowTapCounter = 0;
      int columnTapCounter = 0;
      tableView = TableView.builder(
        rowCount: 50,
        columnCount: 50,
        rowBuilder: (int index) => index.isEven
            ? getTappableSpan(
                index,
                () => rowTapCounter++,
              )
            : span,
        columnBuilder: (int index) => index.isEven
            ? getTappableSpan(
                index,
                () => columnTapCounter++,
              )
            : span,
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: SizedBox.square(
              dimension: 100,
              child: Text('Row: ${vicinity.row} Column: ${vicinity.column}'),
            ),
          );
        },
      );

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();

      // Even columns and rows are set up for taps, mainAxis is vertical by
      // default, mening row major order. Rows should take precedence where they
      // intersect at even indices.
      expect(columnTapCounter, 0);
      expect(rowTapCounter, 0);
      // Tap where non intersecting, but even.
      await tester.tap(find.text('Row: 2 Column: 3')); // Row
      await tester.tap(find.text('Row: 4 Column: 5')); // Row
      await tester.tap(find.text('Row: 3 Column: 2')); // Column
      await tester.tap(find.text('Row: 1 Column: 6')); // Column
      expect(columnTapCounter, 2);
      expect(rowTapCounter, 2);
      // Tap where both are odd and nothing should receive a tap.
      await tester.tap(find.text('Row: 1 Column: 1'));
      await tester.tap(find.text('Row: 3 Column: 1'));
      await tester.tap(find.text('Row: 3 Column: 3'));
      await tester.tap(find.text('Row: 5 Column: 3'));
      expect(columnTapCounter, 2);
      expect(rowTapCounter, 2);
      // Check intersections.
      await tester.tap(find.text('Row: 2 Column: 2'));
      await tester.tap(find.text('Row: 4 Column: 2'));
      await tester.tap(find.text('Row: 2 Column: 4'));
      await tester.tap(find.text('Row: 4 Column: 4'));
      expect(columnTapCounter, 2);
      expect(rowTapCounter, 6); // Rows took precedence

      // Change mainAxis
      rowTapCounter = 0;
      columnTapCounter = 0;
      tableView = TableView.builder(
        mainAxis: Axis.horizontal,
        rowCount: 50,
        columnCount: 50,
        rowBuilder: (int index) => index.isEven
            ? getTappableSpan(
                index,
                () => rowTapCounter++,
              )
            : span,
        columnBuilder: (int index) => index.isEven
            ? getTappableSpan(
                index,
                () => columnTapCounter++,
              )
            : span,
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: SizedBox.square(
              dimension: 100,
              child: Text('Row: ${vicinity.row} Column: ${vicinity.column}'),
            ),
          );
        },
      );

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();
      expect(rowTapCounter, 0);
      expect(columnTapCounter, 0);

      // Check intersections.
      await tester.tap(find.text('Row: 2 Column: 2'));
      await tester.tap(find.text('Row: 4 Column: 2'));
      await tester.tap(find.text('Row: 2 Column: 4'));
      await tester.tap(find.text('Row: 4 Column: 4'));
      expect(columnTapCounter, 4); // Columns took precedence
      expect(rowTapCounter, 0);
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
          return const TableViewCell(
            child: SizedBox.square(dimension: 100),
          );
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

    testWidgets('First row/column layout based on padding',
        (WidgetTester tester) async {
      // Huge padding, first span layout
      // Column-wise
      TableView tableView = TableView.builder(
        rowCount: 50,
        columnCount: 50,
        columnBuilder: (_) => const TableSpan(
          extent: FixedTableSpanExtent(100),
          // This padding is so high, only the first column should be laid out.
          padding: TableSpanPadding(leading: 2000),
        ),
        rowBuilder: (_) => span,
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: SizedBox.square(
              dimension: 100,
              child: Text('Row: ${vicinity.row} Column: ${vicinity.column}'),
            ),
          );
        },
      );

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();
      // All of these children are so offset by the column padding that they are
      // outside of the viewport and cache extent, so all but the very
      // first column is laid out. This is so that the ability to scroll the
      // table through means such as focus traversal are still accessible.
      expect(find.text('Row: 0 Column: 0'), findsOneWidget);
      expect(find.text('Row: 1 Column: 0'), findsOneWidget);
      expect(find.text('Row: 0 Column: 1'), findsNothing);
      expect(find.text('Row: 1 Column: 1'), findsNothing);
      expect(find.text('Row: 0 Column: 2'), findsNothing);
      expect(find.text('Row: 1 Column: 2'), findsNothing);

      // Row-wise
      tableView = TableView.builder(
        rowCount: 50,
        columnCount: 50,
        // This padding is so high, no children should be laid out.
        rowBuilder: (_) => const TableSpan(
          extent: FixedTableSpanExtent(100),
          padding: TableSpanPadding(leading: 2000),
        ),
        columnBuilder: (_) => span,
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: SizedBox.square(
              dimension: 100,
              child: Text('Row: ${vicinity.row} Column: ${vicinity.column}'),
            ),
          );
        },
      );

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();
      // All of these children are so offset by the row padding that they are
      // outside of the viewport and cache extent, so all but the very
      // first row is laid out. This is so that the ability to scroll the
      // table through means such as focus traversal are still accessible.
      expect(find.text('Row: 0 Column: 0'), findsOneWidget);
      expect(find.text('Row: 0 Column: 1'), findsOneWidget);
      expect(find.text('Row: 1 Column: 0'), findsNothing);
      expect(find.text('Row: 1 Column: 1'), findsNothing);
      expect(find.text('Row: 2 Column: 0'), findsNothing);
      expect(find.text('Row: 2 Column: 1'), findsNothing);
    });

    testWidgets('lazy layout accounts for gradually accrued padding',
        (WidgetTester tester) async {
      // Check with gradually accrued paddings
      // Column-wise
      TableView tableView = TableView.builder(
        rowCount: 50,
        columnCount: 50,
        columnBuilder: (_) => const TableSpan(
          extent: FixedTableSpanExtent(200),
        ),
        rowBuilder: (_) => span,
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: SizedBox.square(
              dimension: 200,
              child: Text('Row: ${vicinity.row} Column: ${vicinity.column}'),
            ),
          );
        },
      );

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();

      // No padding here, check all lazily laid out columns in one row.
      expect(find.text('Row: 0 Column: 0'), findsOneWidget);
      expect(find.text('Row: 0 Column: 1'), findsOneWidget);
      expect(find.text('Row: 0 Column: 2'), findsOneWidget);
      expect(find.text('Row: 0 Column: 3'), findsOneWidget);
      expect(find.text('Row: 0 Column: 4'), findsOneWidget);
      expect(find.text('Row: 0 Column: 5'), findsOneWidget);
      expect(find.text('Row: 0 Column: 6'), findsNothing);

      tableView = TableView.builder(
        rowCount: 50,
        columnCount: 50,
        columnBuilder: (_) => const TableSpan(
          extent: FixedTableSpanExtent(200),
          padding: TableSpanPadding(trailing: 200),
        ),
        rowBuilder: (_) => span,
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: SizedBox.square(
              dimension: 200,
              child: Text('Row: ${vicinity.row} Column: ${vicinity.column}'),
            ),
          );
        },
      );

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();

      // Fewer children laid out.
      expect(find.text('Row: 0 Column: 0'), findsOneWidget);
      expect(find.text('Row: 0 Column: 1'), findsOneWidget);
      expect(find.text('Row: 0 Column: 2'), findsOneWidget);
      expect(find.text('Row: 0 Column: 3'), findsNothing);
      expect(find.text('Row: 0 Column: 4'), findsNothing);
      expect(find.text('Row: 0 Column: 5'), findsNothing);
      expect(find.text('Row: 0 Column: 6'), findsNothing);

      // Row-wise
      tableView = TableView.builder(
        rowCount: 50,
        columnCount: 50,
        rowBuilder: (_) => const TableSpan(
          extent: FixedTableSpanExtent(200),
        ),
        columnBuilder: (_) => span,
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: SizedBox.square(
              dimension: 200,
              child: Text('Row: ${vicinity.row} Column: ${vicinity.column}'),
            ),
          );
        },
      );

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();

      // No padding here, check all lazily laid out rows in one column.
      expect(find.text('Row: 0 Column: 0'), findsOneWidget);
      expect(find.text('Row: 1 Column: 0'), findsOneWidget);
      expect(find.text('Row: 2 Column: 0'), findsOneWidget);
      expect(find.text('Row: 3 Column: 0'), findsOneWidget);
      expect(find.text('Row: 4 Column: 0'), findsOneWidget);
      expect(find.text('Row: 5 Column: 0'), findsNothing);

      tableView = TableView.builder(
        rowCount: 50,
        columnCount: 50,
        rowBuilder: (_) => const TableSpan(
          extent: FixedTableSpanExtent(200),
          padding: TableSpanPadding(trailing: 200),
        ),
        columnBuilder: (_) => span,
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: SizedBox.square(
              dimension: 200,
              child: Text('Row: ${vicinity.row} Column: ${vicinity.column}'),
            ),
          );
        },
      );

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();

      // Fewer children laid out.
      expect(find.text('Row: 0 Column: 0'), findsOneWidget);
      expect(find.text('Row: 1 Column: 0'), findsOneWidget);
      expect(find.text('Row: 2 Column: 0'), findsOneWidget);
      expect(find.text('Row: 3 Column: 0'), findsNothing);
      expect(find.text('Row: 4 Column: 0'), findsNothing);
      expect(find.text('Row: 5 Column: 0'), findsNothing);

      // Check padding with pinned rows and columns
      // TODO(Piinks): Pinned rows/columns are not lazily laid out, should check
      //  for assertions in this case. Will add in https://github.com/flutter/flutter/issues/136833
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
          return TableViewCell(
            child: SizedBox.square(
              dimension: 100,
              child: Text('Row: ${vicinity.row} Column: ${vicinity.column}'),
            ),
          );
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
      expect(verticalController.position.pixels, 4400.0);
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
      horizontalController.jumpTo(verticalController.position.maxScrollExtent);
      await tester.pump();
      expect(verticalController.position.pixels, 4400.0);
      expect(horizontalController.position.pixels, 4400.0);
      expect(find.text('Row: 49 Column: 49'), findsOneWidget);
      expect(find.text('Row: 48 Column: 49'), findsOneWidget);
      expect(find.text('Row: 49 Column: 48'), findsOneWidget);
      expect(find.text('Row: 48 Column: 48'), findsOneWidget);
      // Nothing within the CacheExtent
      expect(find.text('Row: 50 Column: 50'), findsNothing);
      expect(find.text('Row: 51 Column: 51'), findsNothing);
      // Not around.
      expect(find.text('Row: 0 Column: 0'), findsNothing);
      expect(find.text('Row: 1 Column: 0'), findsNothing);
      expect(find.text('Row: 0 Column: 1'), findsNothing);
      expect(find.text('Row: 1 Column: 1'), findsNothing);
    });

    testWidgets('pinned rows and columns', (WidgetTester tester) async {
      // Just pinned rows
      final ScrollController verticalController = ScrollController();
      final ScrollController horizontalController = ScrollController();
      TableView tableView = TableView.builder(
        rowCount: 50,
        pinnedRowCount: 1,
        columnCount: 50,
        columnBuilder: (_) => span,
        rowBuilder: (_) => span,
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: SizedBox.square(
              dimension: 100,
              child: Text('Row: ${vicinity.row} Column: ${vicinity.column}'),
            ),
          );
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
      expect(find.text('Row: 0 Column: 0'), findsOneWidget);
      expect(find.text('Row: 1 Column: 0'), findsOneWidget);
      expect(find.text('Row: 0 Column: 1'), findsOneWidget);
      expect(find.text('Row: 1 Column: 1'), findsOneWidget);
      // Within the cacheExtent
      expect(find.text('Row: 6 Column: 0'), findsOneWidget);
      expect(find.text('Row: 7 Column: 0'), findsOneWidget);
      expect(find.text('Row: 0 Column: 8'), findsOneWidget);
      expect(find.text('Row: 1 Column: 8'), findsOneWidget);
      // Outside of the cacheExtent
      expect(find.text('Row: 10 Column: 10'), findsNothing);
      expect(find.text('Row: 11 Column: 10'), findsNothing);
      expect(find.text('Row: 10 Column: 11'), findsNothing);
      expect(find.text('Row: 11 Column: 11'), findsNothing);

      // Let's scroll!
      verticalController.jumpTo(verticalController.position.maxScrollExtent);
      await tester.pump();
      expect(verticalController.position.pixels, 4400.0);
      expect(horizontalController.position.pixels, 0.0);
      expect(find.text('Row: 49 Column: 0'), findsOneWidget);
      expect(find.text('Row: 48 Column: 0'), findsOneWidget);
      expect(find.text('Row: 49 Column: 1'), findsOneWidget);
      expect(find.text('Row: 48 Column: 1'), findsOneWidget);
      // Within the CacheExtent
      expect(find.text('Row: 49 Column: 8'), findsOneWidget);
      expect(find.text('Row: 48 Column: 9'), findsOneWidget);
      // Not around unless pinned.
      expect(find.text('Row: 0 Column: 0'), findsOneWidget); // Pinned row
      expect(find.text('Row: 1 Column: 0'), findsNothing);
      expect(find.text('Row: 0 Column: 1'), findsOneWidget); // Pinned row
      expect(find.text('Row: 1 Column: 1'), findsNothing);

      // Let's scroll some more!
      horizontalController.jumpTo(verticalController.position.maxScrollExtent);
      await tester.pump();
      expect(verticalController.position.pixels, 4400.0);
      expect(horizontalController.position.pixels, 4400.0);
      expect(find.text('Row: 49 Column: 49'), findsOneWidget);
      expect(find.text('Row: 48 Column: 49'), findsOneWidget);
      expect(find.text('Row: 49 Column: 48'), findsOneWidget);
      expect(find.text('Row: 48 Column: 48'), findsOneWidget);
      // Nothing within the CacheExtent
      expect(find.text('Row: 50 Column: 50'), findsNothing);
      expect(find.text('Row: 51 Column: 51'), findsNothing);
      // Not around unless pinned.
      expect(find.text('Row: 0 Column: 49'), findsOneWidget); // Pinned row
      expect(find.text('Row: 1 Column: 49'), findsNothing);
      expect(find.text('Row: 0 Column: 48'), findsOneWidget); // Pinned row
      expect(find.text('Row: 1 Column: 48'), findsNothing);

      // Just pinned columns
      verticalController.jumpTo(0.0);
      horizontalController.jumpTo(0.0);
      tableView = TableView.builder(
        rowCount: 50,
        pinnedColumnCount: 1,
        columnCount: 50,
        columnBuilder: (_) => span,
        rowBuilder: (_) => span,
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: SizedBox.square(
              dimension: 100,
              child: Text('Row: ${vicinity.row} Column: ${vicinity.column}'),
            ),
          );
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
      expect(find.text('Row: 0 Column: 0'), findsOneWidget);
      expect(find.text('Row: 1 Column: 0'), findsOneWidget);
      expect(find.text('Row: 0 Column: 1'), findsOneWidget);
      expect(find.text('Row: 1 Column: 1'), findsOneWidget);
      // Within the cacheExtent
      expect(find.text('Row: 6 Column: 0'), findsOneWidget);
      expect(find.text('Row: 7 Column: 0'), findsOneWidget);
      expect(find.text('Row: 0 Column: 8'), findsOneWidget);
      expect(find.text('Row: 1 Column: 9'), findsOneWidget);
      // Outside of the cacheExtent
      expect(find.text('Row: 10 Column: 10'), findsNothing);
      expect(find.text('Row: 11 Column: 10'), findsNothing);
      expect(find.text('Row: 10 Column: 11'), findsNothing);
      expect(find.text('Row: 11 Column: 11'), findsNothing);

      // Let's scroll!
      verticalController.jumpTo(verticalController.position.maxScrollExtent);
      await tester.pump();
      expect(verticalController.position.pixels, 4400.0);
      expect(horizontalController.position.pixels, 0.0);
      expect(find.text('Row: 49 Column: 0'), findsOneWidget);
      expect(find.text('Row: 48 Column: 0'), findsOneWidget);
      expect(find.text('Row: 49 Column: 1'), findsOneWidget);
      expect(find.text('Row: 48 Column: 1'), findsOneWidget);
      // Within the CacheExtent
      expect(find.text('Row: 49 Column: 8'), findsOneWidget);
      expect(find.text('Row: 48 Column: 9'), findsOneWidget);
      // Not around unless pinned.
      expect(find.text('Row: 49 Column: 0'), findsOneWidget); // Pinned column
      expect(find.text('Row: 48 Column: 0'), findsOneWidget); // Pinned column
      expect(find.text('Row: 0 Column: 1'), findsNothing);
      expect(find.text('Row: 1 Column: 1'), findsNothing);

      // Let's scroll some more!
      horizontalController.jumpTo(verticalController.position.maxScrollExtent);
      await tester.pump();
      expect(verticalController.position.pixels, 4400.0);
      expect(horizontalController.position.pixels, 4400.0);
      expect(find.text('Row: 49 Column: 49'), findsOneWidget);
      expect(find.text('Row: 48 Column: 49'), findsOneWidget);
      expect(find.text('Row: 49 Column: 48'), findsOneWidget);
      expect(find.text('Row: 48 Column: 48'), findsOneWidget);
      // Nothing within the CacheExtent
      expect(find.text('Row: 50 Column: 50'), findsNothing);
      expect(find.text('Row: 51 Column: 51'), findsNothing);
      // Not around.
      expect(find.text('Row: 49 Column: 0'), findsOneWidget); // Pinned column
      expect(find.text('Row: 48 Column: 0'), findsOneWidget); // Pinned column
      expect(find.text('Row: 0 Column: 1'), findsNothing);
      expect(find.text('Row: 1 Column: 1'), findsNothing);

      // Both
      verticalController.jumpTo(0.0);
      horizontalController.jumpTo(0.0);
      tableView = TableView.builder(
        rowCount: 50,
        pinnedColumnCount: 1,
        pinnedRowCount: 1,
        columnCount: 50,
        columnBuilder: (_) => span,
        rowBuilder: (_) => span,
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: SizedBox.square(
              dimension: 100,
              child: Text('Row: ${vicinity.row} Column: ${vicinity.column}'),
            ),
          );
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
      expect(find.text('Row: 0 Column: 0'), findsOneWidget);
      expect(find.text('Row: 1 Column: 0'), findsOneWidget);
      expect(find.text('Row: 0 Column: 1'), findsOneWidget);
      expect(find.text('Row: 1 Column: 1'), findsOneWidget);
      // Within the cacheExtent
      expect(find.text('Row: 7 Column: 0'), findsOneWidget);
      expect(find.text('Row: 6 Column: 0'), findsOneWidget);
      expect(find.text('Row: 0 Column: 8'), findsOneWidget);
      expect(find.text('Row: 1 Column: 9'), findsOneWidget);
      // Outside of the cacheExtent
      expect(find.text('Row: 10 Column: 10'), findsNothing);
      expect(find.text('Row: 11 Column: 10'), findsNothing);
      expect(find.text('Row: 10 Column: 11'), findsNothing);
      expect(find.text('Row: 11 Column: 11'), findsNothing);

      // Let's scroll!
      verticalController.jumpTo(verticalController.position.maxScrollExtent);
      await tester.pump();
      expect(verticalController.position.pixels, 4400.0);
      expect(horizontalController.position.pixels, 0.0);
      expect(find.text('Row: 49 Column: 0'), findsOneWidget);
      expect(find.text('Row: 48 Column: 0'), findsOneWidget);
      expect(find.text('Row: 49 Column: 1'), findsOneWidget);
      expect(find.text('Row: 48 Column: 1'), findsOneWidget);
      // Within the CacheExtent
      expect(find.text('Row: 49 Column: 8'), findsOneWidget);
      expect(find.text('Row: 48 Column: 9'), findsOneWidget);
      // Not around unless pinned.
      expect(find.text('Row: 0 Column: 0'), findsOneWidget); // Pinned
      expect(find.text('Row: 48 Column: 0'), findsOneWidget); // Pinned
      expect(find.text('Row: 0 Column: 1'), findsOneWidget); // Pinned
      expect(find.text('Row: 1 Column: 1'), findsNothing);

      // Let's scroll some more!
      horizontalController.jumpTo(verticalController.position.maxScrollExtent);
      await tester.pump();
      expect(verticalController.position.pixels, 4400.0);
      expect(horizontalController.position.pixels, 4400.0);
      expect(find.text('Row: 49 Column: 49'), findsOneWidget);
      expect(find.text('Row: 48 Column: 49'), findsOneWidget);
      expect(find.text('Row: 49 Column: 48'), findsOneWidget);
      expect(find.text('Row: 48 Column: 48'), findsOneWidget);
      // Nothing within the CacheExtent
      expect(find.text('Row: 50 Column: 50'), findsNothing);
      expect(find.text('Row: 51 Column: 51'), findsNothing);
      // Not around unless pinned.
      expect(find.text('Row: 0 Column: 0'), findsOneWidget); // Pinned
      expect(find.text('Row: 49 Column: 0'), findsOneWidget); // Pinned
      expect(find.text('Row: 0 Column: 49'), findsOneWidget); // Pinned
      expect(find.text('Row: 1 Column: 1'), findsNothing);
    });

    testWidgets('only paints visible cells', (WidgetTester tester) async {
      final ScrollController verticalController = ScrollController();
      final ScrollController horizontalController = ScrollController();
      final TableView tableView = TableView.builder(
        rowCount: 50,
        columnCount: 50,
        columnBuilder: (_) => span,
        rowBuilder: (_) => span,
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: SizedBox.square(
              dimension: 100,
              child: Text('Row: ${vicinity.row} Column: ${vicinity.column}'),
            ),
          );
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

      bool cellNeedsPaint(String cell) {
        return find.text(cell).evaluate().first.renderObject!.debugNeedsPaint;
      }

      expect(cellNeedsPaint('Row: 0 Column: 0'), isFalse);
      expect(cellNeedsPaint('Row: 0 Column: 1'), isFalse);
      expect(cellNeedsPaint('Row: 0 Column: 2'), isFalse);
      expect(cellNeedsPaint('Row: 0 Column: 3'), isFalse);
      expect(cellNeedsPaint('Row: 0 Column: 4'), isFalse);
      expect(cellNeedsPaint('Row: 0 Column: 5'), isFalse);
      expect(cellNeedsPaint('Row: 0 Column: 6'), isFalse);
      expect(cellNeedsPaint('Row: 0 Column: 7'), isFalse);
      expect(cellNeedsPaint('Row: 0 Column: 8'), isTrue); // cacheExtent
      expect(cellNeedsPaint('Row: 0 Column: 9'), isTrue); // cacheExtent
      expect(cellNeedsPaint('Row: 0 Column: 10'), isTrue); // cacheExtent
      expect(
        find.text('Row: 0 Column: 11'),
        findsNothing,
      ); // outside of cacheExtent

      expect(cellNeedsPaint('Row: 1 Column: 0'), isFalse);
      expect(cellNeedsPaint('Row: 2 Column: 0'), isFalse);
      expect(cellNeedsPaint('Row: 3 Column: 0'), isFalse);
      expect(cellNeedsPaint('Row: 4 Column: 0'), isFalse);
      expect(cellNeedsPaint('Row: 5 Column: 0'), isFalse);
      expect(cellNeedsPaint('Row: 6 Column: 0'), isTrue); // cacheExtent
      expect(cellNeedsPaint('Row: 7 Column: 0'), isTrue); // cacheExtent
      expect(cellNeedsPaint('Row: 8 Column: 0'), isTrue); // cacheExtent
      expect(
        find.text('Row: 9 Column: 0'),
        findsNothing,
      ); // outside of cacheExtent

      // Check a couple other cells
      expect(cellNeedsPaint('Row: 5 Column: 7'), isFalse); // last visible cell
      expect(cellNeedsPaint('Row: 6 Column: 7'), isTrue); // also in cacheExtent
      expect(cellNeedsPaint('Row: 5 Column: 8'), isTrue); // also in cacheExtent
      expect(cellNeedsPaint('Row: 6 Column: 8'), isTrue); // also in cacheExtent
    });

    testWidgets('paints decorations in correct order',
        (WidgetTester tester) async {
      TableView tableView = TableView.builder(
        rowCount: 2,
        columnCount: 2,
        columnBuilder: (int index) => TableSpan(
          extent: const FixedTableSpanExtent(200.0),
          padding: index == 0 ? const TableSpanPadding(trailing: 10) : null,
          foregroundDecoration: TableSpanDecoration(
            consumeSpanPadding: false,
            borderRadius: BorderRadius.circular(10.0),
            border: const TableSpanBorder(
              trailing: BorderSide(
                color: Colors.orange,
                width: 3,
              ),
            ),
          ),
          backgroundDecoration: TableSpanDecoration(
            // consumePadding true by default
            color: index.isEven ? Colors.red : null,
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        rowBuilder: (int index) => TableSpan(
          extent: const FixedTableSpanExtent(200.0),
          padding: index == 1 ? const TableSpanPadding(leading: 10) : null,
          foregroundDecoration: TableSpanDecoration(
            // consumePadding true by default
            borderRadius: BorderRadius.circular(30.0),
            border: const TableSpanBorder(
              leading: BorderSide(
                color: Colors.green,
                width: 3,
              ),
            ),
          ),
          backgroundDecoration: TableSpanDecoration(
            color: index.isOdd ? Colors.blue : null,
            borderRadius: BorderRadius.circular(30.0),
            consumeSpanPadding: false,
          ),
        ),
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: Container(
              height: 200,
              width: 200,
              color: Colors.grey.withOpacity(0.5),
            ),
          );
        },
      );

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();
      expect(
        find.byType(TableViewport),
        paints
          // background row
          ..rrect(
            rrect: RRect.fromRectAndRadius(
              const Rect.fromLTRB(0.0, 210.0, 410.0, 410.0),
              const Radius.circular(30.0),
            ),
            color: const Color(0xff2196f3),
          )
          // background column
          ..rrect(
            rrect: RRect.fromRectAndRadius(
              const Rect.fromLTRB(0.0, 0.0, 210.0, 410.0),
              const Radius.circular(30.0),
            ),
            color: const Color(0xfff44336),
          )
          // child at 0,0
          ..rect(
            rect: const Rect.fromLTRB(0.0, 0.0, 200.0, 200.0),
            color: const Color(0x809e9e9e),
          )
          // child at 0,1
          ..rect(
            rect: const Rect.fromLTRB(0.0, 210.0, 200.0, 410.0),
            color: const Color(0x809e9e9e),
          )
          // child at 1,0
          ..rect(
            rect: const Rect.fromLTRB(210.0, 0.0, 410.0, 200.0),
            color: const Color(0x809e9e9e),
          )
          // child at 1,1
          ..rect(
            rect: const Rect.fromLTRB(210.0, 210.0, 410.0, 410.0),
            color: const Color(0x809e9e9e),
          )
          // foreground row border (1)
          ..drrect(
            outer: RRect.fromRectAndRadius(
              const Rect.fromLTRB(0.0, 0.0, 410.0, 200.0),
              const Radius.circular(30.0),
            ),
            inner: RRect.fromLTRBAndCorners(
              0.0,
              3.0,
              410.0,
              200.0,
              topLeft: const Radius.elliptical(30.0, 27.0),
              topRight: const Radius.elliptical(30.0, 27.0),
              bottomRight: const Radius.circular(30.0),
              bottomLeft: const Radius.circular(30.0),
            ),
            color: const Color(0xff4caf50),
          )
          // foreground row border (2)
          ..drrect(
            outer: RRect.fromRectAndRadius(
              const Rect.fromLTRB(0.0, 200.0, 410.0, 410.0),
              const Radius.circular(30.0),
            ),
            inner: RRect.fromLTRBAndCorners(
              0.0,
              203.0,
              410.0,
              410.0,
              topLeft: const Radius.elliptical(30.0, 27.0),
              topRight: const Radius.elliptical(30.0, 27.0),
              bottomRight: const Radius.circular(30.0),
              bottomLeft: const Radius.circular(30.0),
            ),
            color: const Color(0xff4caf50),
          )
          // foreground column border (1)
          ..drrect(
            outer: RRect.fromRectAndRadius(
              const Rect.fromLTRB(0.0, 0.0, 200.0, 410.0),
              const Radius.circular(10.0),
            ),
            inner: RRect.fromLTRBAndCorners(
              0.0,
              0.0,
              197.0,
              410.0,
              topLeft: const Radius.circular(10.0),
              topRight: const Radius.elliptical(7.0, 10.0),
              bottomRight: const Radius.elliptical(7.0, 10.0),
              bottomLeft: const Radius.circular(10.0),
            ),
            color: const Color(0xffff9800),
          )
          // foreground column border (2)
          ..drrect(
            outer: RRect.fromRectAndRadius(
              const Rect.fromLTRB(210.0, 0.0, 410.0, 410.0),
              const Radius.circular(10.0),
            ),
            inner: RRect.fromLTRBAndCorners(
              210.0,
              0.0,
              407.0,
              410.0,
              topLeft: const Radius.circular(10.0),
              topRight: const Radius.elliptical(7.0, 10.0),
              bottomRight: const Radius.elliptical(7.0, 10.0),
              bottomLeft: const Radius.circular(10.0),
            ),
            color: const Color(0xffff9800),
          ),
      );

      // Switch main axis
      tableView = TableView.builder(
        mainAxis: Axis.horizontal,
        rowCount: 2,
        columnCount: 2,
        columnBuilder: (int index) => TableSpan(
          extent: const FixedTableSpanExtent(200.0),
          foregroundDecoration: const TableSpanDecoration(
            border: TableSpanBorder(
              trailing: BorderSide(
                color: Colors.orange,
                width: 3,
              ),
            ),
          ),
          backgroundDecoration: TableSpanDecoration(
            color: index.isEven ? Colors.red : null,
          ),
        ),
        rowBuilder: (int index) => TableSpan(
          extent: const FixedTableSpanExtent(200.0),
          foregroundDecoration: const TableSpanDecoration(
            border: TableSpanBorder(
              leading: BorderSide(
                color: Colors.green,
                width: 3,
              ),
            ),
          ),
          backgroundDecoration: TableSpanDecoration(
            color: index.isOdd ? Colors.blue : null,
          ),
        ),
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: Container(
              height: 200,
              width: 200,
              color: Colors.grey.withOpacity(0.5),
            ),
          );
        },
      );

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();
      expect(
        find.byType(TableViewport),
        paints
          // background column goes first this time
          ..rect(
            rect: const Rect.fromLTRB(0.0, 0.0, 200.0, 400.0),
            color: const Color(0xfff44336),
          )
          // background row
          ..rect(
            rect: const Rect.fromLTRB(0.0, 200.0, 400.0, 400.0),
            color: const Color(0xff2196f3),
          )
          // child at 0,0
          ..rect(
            rect: const Rect.fromLTRB(0.0, 0.0, 200.0, 200.0),
            color: const Color(0x809e9e9e),
          )
          // child at 1,0
          ..rect(
            rect: const Rect.fromLTRB(0.0, 200.0, 200.0, 400.0),
            color: const Color(0x809e9e9e),
          )
          // child at 0,1
          ..rect(
            rect: const Rect.fromLTRB(200.0, 0.0, 400.0, 200.0),
            color: const Color(0x809e9e9e),
          )
          // child at 1,1
          ..rect(
            rect: const Rect.fromLTRB(200.0, 200.0, 400.0, 400.0),
            color: const Color(0x809e9e9e),
          )
          // foreground column border (1)
          ..path(
            includes: <Offset>[
              const Offset(200.0, 0.0),
              const Offset(200.0, 200.0),
              const Offset(200.0, 400.0),
            ],
            color: const Color(0xffff9800),
          )
          // foreground column border (2)
          ..path(
            includes: <Offset>[
              const Offset(400.0, 0.0),
              const Offset(400.0, 200.0),
              const Offset(400.0, 400.0),
            ],
            color: const Color(0xffff9800),
          )
          // foreground row border
          ..path(
            includes: <Offset>[
              Offset.zero,
              const Offset(200.0, 0.0),
              const Offset(400.0, 0.0),
            ],
            color: const Color(0xff4caf50),
          )
          // foreground row border(2)
          ..path(
            includes: <Offset>[
              const Offset(0.0, 200.0),
              const Offset(200.0, 200.0),
              const Offset(400.0, 200.0),
            ],
            color: const Color(0xff4caf50),
          ),
      );
    });

    testWidgets('child paint rects are correct when reversed and pinned',
        (WidgetTester tester) async {
      // Both reversed - Regression test for https://github.com/flutter/flutter/issues/135386
      TableView tableView = TableView.builder(
        verticalDetails: const ScrollableDetails.vertical(reverse: true),
        horizontalDetails: const ScrollableDetails.horizontal(reverse: true),
        rowCount: 2,
        pinnedRowCount: 1,
        columnCount: 2,
        pinnedColumnCount: 1,
        columnBuilder: (int index) => const TableSpan(
          extent: FixedTableSpanExtent(200.0),
        ),
        rowBuilder: (int index) => const TableSpan(
          extent: FixedTableSpanExtent(200.0),
        ),
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: Container(
              height: 200,
              width: 200,
              color: Colors.grey.withOpacity(0.5),
            ),
          );
        },
      );

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();
      // All children are painted in the right place
      expect(
        find.byType(TableViewport),
        paints
          ..rect(
            rect: const Rect.fromLTRB(400.0, 200.0, 600.0, 400.0),
            color: const Color(0x809e9e9e),
          )
          ..rect(
            rect: const Rect.fromLTRB(600.0, 200.0, 800.0, 400.0),
            color: const Color(0x809e9e9e),
          )
          ..rect(
            rect: const Rect.fromLTRB(400.0, 400.0, 600.0, 600.0),
            color: const Color(0x809e9e9e),
          )
          ..rect(
            rect: const Rect.fromLTRB(600.0, 400.0, 800.0, 600.0),
            color: const Color(0x809e9e9e),
          ),
      );

      // Only one axis reversed - Regression test for https://github.com/flutter/flutter/issues/136897
      tableView = TableView.builder(
        horizontalDetails: const ScrollableDetails.horizontal(reverse: true),
        rowCount: 2,
        pinnedRowCount: 1,
        columnCount: 2,
        pinnedColumnCount: 1,
        columnBuilder: (int index) => const TableSpan(
          extent: FixedTableSpanExtent(200.0),
        ),
        rowBuilder: (int index) => const TableSpan(
          extent: FixedTableSpanExtent(200.0),
        ),
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: Container(
              height: 200,
              width: 200,
              color: Colors.grey.withOpacity(0.5),
            ),
          );
        },
      );

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();
      expect(
        find.byType(TableViewport),
        paints
          ..rect(
            rect: const Rect.fromLTRB(400.0, 200.0, 600.0, 400.0),
            color: const Color(0x809e9e9e),
          )
          ..rect(
            rect: const Rect.fromLTRB(600.0, 200.0, 800.0, 400.0),
            color: const Color(0x809e9e9e),
          )
          ..rect(
            rect: const Rect.fromLTRB(400.0, 0.0, 600.0, 200.0),
            color: const Color(0x809e9e9e),
          )
          ..rect(
            rect: const Rect.fromLTRB(600.0, 0.0, 800.0, 200.0),
            color: const Color(0x809e9e9e),
          ),
      );
    });

    testWidgets('mouse handling', (WidgetTester tester) async {
      int enterCounter = 0;
      int exitCounter = 0;
      final TableView tableView = TableView.builder(
        rowCount: 50,
        columnCount: 50,
        columnBuilder: (_) => span,
        rowBuilder: (int index) => index.isEven
            ? getMouseTrackingSpan(
                index,
                onEnter: (_) => enterCounter++,
                onExit: (_) => exitCounter++,
              )
            : span,
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            child: SizedBox.square(
              dimension: 100,
              child: Text('Row: ${vicinity.row} Column: ${vicinity.column}'),
            ),
          );
        },
      );

      await tester.pumpWidget(MaterialApp(home: tableView));
      await tester.pumpAndSettle();
      // Even rows will respond to mouse, odd will not
      final Offset evenRow = tester.getCenter(find.text('Row: 2 Column: 2'));
      final Offset oddRow = tester.getCenter(find.text('Row: 3 Column: 2'));
      final TestGesture gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: oddRow);
      expect(enterCounter, 0);
      expect(exitCounter, 0);
      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.basic,
      );
      await gesture.moveTo(evenRow);
      await tester.pumpAndSettle();
      expect(enterCounter, 1);
      expect(exitCounter, 0);
      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.cell,
      );
      await gesture.moveTo(oddRow);
      await tester.pumpAndSettle();
      expect(enterCounter, 1);
      expect(exitCounter, 1);
      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.basic,
      );
    });

    group('Merged pinned cells layout', () {
      // Regression tests for https://github.com/flutter/flutter/issues/143526
      // These tests all use the same collection of merged pinned cells in a
      // variety of combinations.
      final Map<TableVicinity, ({int start, int span})> bothMerged =
          <TableVicinity, ({int start, int span})>{
        TableVicinity.zero: (start: 0, span: 2),
        const TableVicinity(row: 1, column: 0): (start: 0, span: 2),
        const TableVicinity(row: 0, column: 1): (start: 0, span: 2),
        const TableVicinity(row: 1, column: 1): (start: 0, span: 2),
      };

      final Map<TableVicinity, ({int start, int span})> rowMerged =
          <TableVicinity, ({int start, int span})>{
        const TableVicinity(row: 2, column: 0): (start: 2, span: 2),
        const TableVicinity(row: 3, column: 0): (start: 2, span: 2),
        const TableVicinity(row: 4, column: 1): (start: 4, span: 3),
        const TableVicinity(row: 5, column: 1): (start: 4, span: 3),
        const TableVicinity(row: 6, column: 1): (start: 4, span: 3),
      };

      final Map<TableVicinity, ({int start, int span})> columnMerged =
          <TableVicinity, ({int start, int span})>{
        const TableVicinity(row: 0, column: 2): (start: 2, span: 2),
        const TableVicinity(row: 0, column: 3): (start: 2, span: 2),
        const TableVicinity(row: 1, column: 4): (start: 4, span: 3),
        const TableVicinity(row: 1, column: 5): (start: 4, span: 3),
        const TableVicinity(row: 1, column: 6): (start: 4, span: 3),
      };
      const TableSpan span = TableSpan(extent: FixedTableSpanExtent(75));

      testWidgets('Normal axes', (WidgetTester tester) async {
        final ScrollController verticalController = ScrollController();
        final ScrollController horizontalController = ScrollController();
        final TableView tableView = TableView.builder(
          verticalDetails: ScrollableDetails.vertical(
            controller: verticalController,
          ),
          horizontalDetails: ScrollableDetails.horizontal(
            controller: horizontalController,
          ),
          columnCount: 20,
          rowCount: 20,
          pinnedRowCount: 2,
          pinnedColumnCount: 2,
          columnBuilder: (_) => span,
          rowBuilder: (_) => span,
          cellBuilder: (_, TableVicinity vicinity) {
            return TableViewCell(
              columnMergeStart:
                  bothMerged[vicinity]?.start ?? columnMerged[vicinity]?.start,
              columnMergeSpan:
                  bothMerged[vicinity]?.span ?? columnMerged[vicinity]?.span,
              rowMergeStart:
                  bothMerged[vicinity]?.start ?? rowMerged[vicinity]?.start,
              rowMergeSpan:
                  bothMerged[vicinity]?.span ?? rowMerged[vicinity]?.span,
              child: Text(
                'R${bothMerged[vicinity]?.start ?? rowMerged[vicinity]?.start ?? vicinity.row}:'
                'C${bothMerged[vicinity]?.start ?? columnMerged[vicinity]?.start ?? vicinity.column}',
              ),
            );
          },
        );
        await tester.pumpWidget(MaterialApp(home: tableView));
        await tester.pumpAndSettle();

        expect(verticalController.position.pixels, 0.0);
        expect(horizontalController.position.pixels, 0.0);
        expect(
          tester.getRect(find.text('R0:C0')),
          const Rect.fromLTWH(0.0, 0.0, 150.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R0:C2')),
          const Rect.fromLTWH(150.0, 0.0, 150.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R1:C4')),
          const Rect.fromLTWH(300.0, 75.0, 225.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R2:C0')),
          const Rect.fromLTWH(0.0, 150.0, 75.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R4:C1')),
          const Rect.fromLTWH(75.0, 300.0, 75.0, 225.0),
        );

        verticalController.jumpTo(10.0);
        await tester.pumpAndSettle();
        expect(verticalController.position.pixels, 10.0);
        expect(horizontalController.position.pixels, 0.0);
        expect(
          tester.getRect(find.text('R0:C0')),
          const Rect.fromLTWH(0.0, 0.0, 150.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R0:C2')),
          const Rect.fromLTWH(150.0, 0.0, 150.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R1:C4')),
          const Rect.fromLTWH(300.0, 75.0, 225.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R2:C0')),
          const Rect.fromLTWH(0.0, 140.0, 75.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R4:C1')),
          const Rect.fromLTWH(75.0, 290.0, 75.0, 225.0),
        );

        horizontalController.jumpTo(10.0);
        await tester.pumpAndSettle();
        expect(verticalController.position.pixels, 10.0);
        expect(horizontalController.position.pixels, 10.0);
        expect(
          tester.getRect(find.text('R0:C0')),
          const Rect.fromLTWH(0.0, 0.0, 150.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R0:C2')),
          const Rect.fromLTWH(140.0, 0.0, 150.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R1:C4')),
          const Rect.fromLTWH(290.0, 75.0, 225.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R2:C0')),
          const Rect.fromLTWH(0.0, 140.0, 75.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R4:C1')),
          const Rect.fromLTWH(75.0, 290.0, 75.0, 225.0),
        );
      });

      testWidgets('Vertical reversed', (WidgetTester tester) async {
        final ScrollController verticalController = ScrollController();
        final ScrollController horizontalController = ScrollController();
        final TableView tableView = TableView.builder(
          verticalDetails: ScrollableDetails.vertical(
            reverse: true,
            controller: verticalController,
          ),
          horizontalDetails: ScrollableDetails.horizontal(
            controller: horizontalController,
          ),
          columnCount: 20,
          rowCount: 20,
          pinnedRowCount: 2,
          pinnedColumnCount: 2,
          columnBuilder: (_) => span,
          rowBuilder: (_) => span,
          cellBuilder: (_, TableVicinity vicinity) {
            return TableViewCell(
              columnMergeStart:
                  bothMerged[vicinity]?.start ?? columnMerged[vicinity]?.start,
              columnMergeSpan:
                  bothMerged[vicinity]?.span ?? columnMerged[vicinity]?.span,
              rowMergeStart:
                  bothMerged[vicinity]?.start ?? rowMerged[vicinity]?.start,
              rowMergeSpan:
                  bothMerged[vicinity]?.span ?? rowMerged[vicinity]?.span,
              child: Text(
                'R${bothMerged[vicinity]?.start ?? rowMerged[vicinity]?.start ?? vicinity.row}:'
                'C${bothMerged[vicinity]?.start ?? columnMerged[vicinity]?.start ?? vicinity.column}',
              ),
            );
          },
        );
        await tester.pumpWidget(MaterialApp(home: tableView));
        await tester.pumpAndSettle();

        expect(verticalController.position.pixels, 0.0);
        expect(horizontalController.position.pixels, 0.0);
        expect(
          tester.getRect(find.text('R0:C0')),
          const Rect.fromLTWH(0.0, 450.0, 150.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R0:C2')),
          const Rect.fromLTWH(150.0, 525.0, 150.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R1:C4')),
          const Rect.fromLTWH(300.0, 450.0, 225.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R2:C0')),
          const Rect.fromLTWH(0.0, 300.0, 75.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R4:C1')),
          const Rect.fromLTWH(75.0, 75.0, 75.0, 225.0),
        );

        verticalController.jumpTo(10.0);
        await tester.pumpAndSettle();
        expect(verticalController.position.pixels, 10.0);
        expect(horizontalController.position.pixels, 0.0);
        expect(
          tester.getRect(find.text('R0:C0')),
          const Rect.fromLTWH(0.0, 450.0, 150.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R0:C2')),
          const Rect.fromLTWH(150.0, 525.0, 150.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R1:C4')),
          const Rect.fromLTWH(300.0, 450.0, 225.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R2:C0')),
          const Rect.fromLTWH(0.0, 310.0, 75.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R4:C1')),
          const Rect.fromLTWH(75.0, 85.0, 75.0, 225.0),
        );

        horizontalController.jumpTo(10.0);
        await tester.pumpAndSettle();
        expect(verticalController.position.pixels, 10.0);
        expect(horizontalController.position.pixels, 10.0);
        expect(
          tester.getRect(find.text('R0:C0')),
          const Rect.fromLTWH(0.0, 450.0, 150.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R0:C2')),
          const Rect.fromLTWH(140.0, 525.0, 150.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R1:C4')),
          const Rect.fromLTWH(290.0, 450.0, 225.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R2:C0')),
          const Rect.fromLTWH(0.0, 310.0, 75.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R4:C1')),
          const Rect.fromLTWH(75.0, 85.0, 75.0, 225.0),
        );
      });

      testWidgets('Horizontal reversed', (WidgetTester tester) async {
        final ScrollController verticalController = ScrollController();
        final ScrollController horizontalController = ScrollController();
        final TableView tableView = TableView.builder(
          verticalDetails: ScrollableDetails.vertical(
            controller: verticalController,
          ),
          horizontalDetails: ScrollableDetails.horizontal(
            reverse: true,
            controller: horizontalController,
          ),
          columnCount: 20,
          rowCount: 20,
          pinnedRowCount: 2,
          pinnedColumnCount: 2,
          columnBuilder: (_) => span,
          rowBuilder: (_) => span,
          cellBuilder: (_, TableVicinity vicinity) {
            return TableViewCell(
              columnMergeStart:
                  bothMerged[vicinity]?.start ?? columnMerged[vicinity]?.start,
              columnMergeSpan:
                  bothMerged[vicinity]?.span ?? columnMerged[vicinity]?.span,
              rowMergeStart:
                  bothMerged[vicinity]?.start ?? rowMerged[vicinity]?.start,
              rowMergeSpan:
                  bothMerged[vicinity]?.span ?? rowMerged[vicinity]?.span,
              child: Text(
                'R${bothMerged[vicinity]?.start ?? rowMerged[vicinity]?.start ?? vicinity.row}:'
                'C${bothMerged[vicinity]?.start ?? columnMerged[vicinity]?.start ?? vicinity.column}',
              ),
            );
          },
        );
        await tester.pumpWidget(MaterialApp(home: tableView));
        await tester.pumpAndSettle();

        expect(verticalController.position.pixels, 0.0);
        expect(horizontalController.position.pixels, 0.0);
        expect(
          tester.getRect(find.text('R0:C0')),
          const Rect.fromLTWH(650.0, 0.0, 150.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R0:C2')),
          const Rect.fromLTWH(500.0, 0.0, 150.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R1:C4')),
          const Rect.fromLTWH(275.0, 75.0, 225.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R2:C0')),
          const Rect.fromLTWH(725.0, 150.0, 75.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R4:C1')),
          const Rect.fromLTWH(650.0, 300.0, 75.0, 225.0),
        );

        verticalController.jumpTo(10.0);
        await tester.pumpAndSettle();
        expect(verticalController.position.pixels, 10.0);
        expect(horizontalController.position.pixels, 0.0);
        expect(
          tester.getRect(find.text('R0:C0')),
          const Rect.fromLTWH(650.0, 0.0, 150.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R0:C2')),
          const Rect.fromLTWH(500.0, 0.0, 150.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R1:C4')),
          const Rect.fromLTWH(275.0, 75.0, 225.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R2:C0')),
          const Rect.fromLTWH(725.0, 140.0, 75.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R4:C1')),
          const Rect.fromLTWH(650.0, 290.0, 75.0, 225.0),
        );

        horizontalController.jumpTo(10.0);
        await tester.pumpAndSettle();
        expect(verticalController.position.pixels, 10.0);
        expect(horizontalController.position.pixels, 10.0);
        expect(
          tester.getRect(find.text('R0:C0')),
          const Rect.fromLTWH(650.0, 0.0, 150.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R0:C2')),
          const Rect.fromLTWH(510.0, 0.0, 150.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R1:C4')),
          const Rect.fromLTWH(285.0, 75.0, 225.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R2:C0')),
          const Rect.fromLTWH(725.0, 140.0, 75.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R4:C1')),
          const Rect.fromLTWH(650.0, 290.0, 75.0, 225.0),
        );
      });

      testWidgets('Both reversed', (WidgetTester tester) async {
        final ScrollController verticalController = ScrollController();
        final ScrollController horizontalController = ScrollController();
        final TableView tableView = TableView.builder(
          verticalDetails: ScrollableDetails.vertical(
            reverse: true,
            controller: verticalController,
          ),
          horizontalDetails: ScrollableDetails.horizontal(
            reverse: true,
            controller: horizontalController,
          ),
          columnCount: 20,
          rowCount: 20,
          pinnedRowCount: 2,
          pinnedColumnCount: 2,
          columnBuilder: (_) => span,
          rowBuilder: (_) => span,
          cellBuilder: (_, TableVicinity vicinity) {
            return TableViewCell(
              columnMergeStart:
                  bothMerged[vicinity]?.start ?? columnMerged[vicinity]?.start,
              columnMergeSpan:
                  bothMerged[vicinity]?.span ?? columnMerged[vicinity]?.span,
              rowMergeStart:
                  bothMerged[vicinity]?.start ?? rowMerged[vicinity]?.start,
              rowMergeSpan:
                  bothMerged[vicinity]?.span ?? rowMerged[vicinity]?.span,
              child: Text(
                'R${bothMerged[vicinity]?.start ?? rowMerged[vicinity]?.start ?? vicinity.row}:'
                'C${bothMerged[vicinity]?.start ?? columnMerged[vicinity]?.start ?? vicinity.column}',
              ),
            );
          },
        );
        await tester.pumpWidget(MaterialApp(home: tableView));
        await tester.pumpAndSettle();

        expect(verticalController.position.pixels, 0.0);
        expect(horizontalController.position.pixels, 0.0);
        expect(
          tester.getRect(find.text('R0:C0')),
          const Rect.fromLTWH(650.0, 450.0, 150.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R0:C2')),
          const Rect.fromLTWH(500.0, 525.0, 150.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R1:C4')),
          const Rect.fromLTWH(275.0, 450.0, 225.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R2:C0')),
          const Rect.fromLTWH(725.0, 300.0, 75.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R4:C1')),
          const Rect.fromLTWH(650.0, 75.0, 75.0, 225.0),
        );

        verticalController.jumpTo(10.0);
        await tester.pumpAndSettle();
        expect(verticalController.position.pixels, 10.0);
        expect(horizontalController.position.pixels, 0.0);
        expect(
          tester.getRect(find.text('R0:C0')),
          const Rect.fromLTWH(650.0, 450.0, 150.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R0:C2')),
          const Rect.fromLTWH(500.0, 525.0, 150.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R1:C4')),
          const Rect.fromLTWH(275.0, 450.0, 225.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R2:C0')),
          const Rect.fromLTWH(725.0, 310.0, 75.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R4:C1')),
          const Rect.fromLTWH(650.0, 85.0, 75.0, 225.0),
        );

        horizontalController.jumpTo(10.0);
        await tester.pumpAndSettle();
        expect(verticalController.position.pixels, 10.0);
        expect(horizontalController.position.pixels, 10.0);
        expect(
          tester.getRect(find.text('R0:C0')),
          const Rect.fromLTWH(650.0, 450.0, 150.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R0:C2')),
          const Rect.fromLTWH(510.0, 525.0, 150.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R1:C4')),
          const Rect.fromLTWH(285.0, 450.0, 225.0, 75.0),
        );
        expect(
          tester.getRect(find.text('R2:C0')),
          const Rect.fromLTWH(725.0, 310.0, 75.0, 150.0),
        );
        expect(
          tester.getRect(find.text('R4:C1')),
          const Rect.fromLTWH(650.0, 85.0, 75.0, 225.0),
        );
      });
    });
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
