// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

void main() {
  group('TableView alignment', () {
    testWidgets('Default alignment - topLeft', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          debugShowCheckedModeBanner: false,
          builder: (context, child) => Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 600,
                height: 600,
                child: TableView.builder(
                  columnCount: 1,
                  rowCount: 1,
                  columnBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  rowBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  cellBuilder: (context, vicinity) {
                    return TableViewCell(
                      child: SizedBox(
                        key: ValueKey<String>(
                          'cell ${vicinity.column}:${vicinity.row}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final Offset tableTopLeft = tester.getTopLeft(find.byType(TableView));
      // Default is Alignment.topLeft (0, 0)
      final Finder cell00 = find.byKey(const ValueKey<String>('cell 0:0'));
      expect(tester.getTopLeft(cell00) - tableTopLeft, Offset.zero);
    });

    testWidgets('Horizontal alignment - center', (WidgetTester tester) async {
      const viewportWidth = 600.0;

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          debugShowCheckedModeBanner: false,
          builder: (context, child) => Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: viewportWidth,
                height: 400,
                child: TableView.builder(
                  columnCount: 3,
                  rowCount: 1,
                  alignment: Alignment.topCenter,
                  columnBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  rowBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  cellBuilder: (context, vicinity) {
                    return TableViewCell(
                      child: SizedBox(
                        key: ValueKey<String>(
                          'cell ${vicinity.column}:${vicinity.row}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final Offset tableTopLeft = tester.getTopLeft(find.byType(TableView));
      // Table is 300 wide, viewport is 600 wide. Centered means 150 offset.
      final Finder cell00 = find.byKey(const ValueKey<String>('cell 0:0'));
      expect(
        tester.getTopLeft(cell00) - tableTopLeft,
        const Offset(150.0, 0.0),
      );

      final Finder cell20 = find.byKey(const ValueKey<String>('cell 2:0'));
      expect(
        tester.getTopLeft(cell20) - tableTopLeft,
        const Offset(350.0, 0.0),
      );
    });

    testWidgets('Horizontal alignment - end', (WidgetTester tester) async {
      const viewportWidth = 600.0;

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          debugShowCheckedModeBanner: false,
          builder: (context, child) => Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: viewportWidth,
                height: 400,
                child: TableView.builder(
                  columnCount: 3,
                  rowCount: 1,
                  alignment: Alignment.topRight,
                  columnBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  rowBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  cellBuilder: (context, vicinity) {
                    return TableViewCell(
                      child: SizedBox(
                        key: ValueKey<String>(
                          'cell ${vicinity.column}:${vicinity.row}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final Offset tableTopLeft = tester.getTopLeft(find.byType(TableView));
      // Table is 300 wide, viewport is 600 wide. End means 300 offset.
      final Finder cell00 = find.byKey(const ValueKey<String>('cell 0:0'));
      expect(
        tester.getTopLeft(cell00) - tableTopLeft,
        const Offset(300.0, 0.0),
      );
    });

    testWidgets('Vertical alignment - center', (WidgetTester tester) async {
      const viewportHeight = 600.0;

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          debugShowCheckedModeBanner: false,
          builder: (context, child) => Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 400,
                height: viewportHeight,
                child: TableView.builder(
                  columnCount: 1,
                  rowCount: 2,
                  alignment: Alignment.centerLeft,
                  columnBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  rowBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  cellBuilder: (context, vicinity) {
                    return TableViewCell(
                      child: SizedBox(
                        key: ValueKey<String>(
                          'cell ${vicinity.column}:${vicinity.row}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final Offset tableTopLeft = tester.getTopLeft(find.byType(TableView));
      // Table is 200 high, viewport is 600 high. Centered means 200 offset.
      final Finder cell00 = find.byKey(const ValueKey<String>('cell 0:0'));
      expect(
        tester.getTopLeft(cell00) - tableTopLeft,
        const Offset(0.0, 200.0),
      );

      final Finder cell01 = find.byKey(const ValueKey<String>('cell 0:1'));
      expect(
        tester.getTopLeft(cell01) - tableTopLeft,
        const Offset(0.0, 300.0),
      );
    });

    testWidgets('Combined alignment', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          debugShowCheckedModeBanner: false,
          builder: (context, child) => Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 600,
                height: 600,
                child: TableView.builder(
                  columnCount: 1,
                  rowCount: 1,
                  alignment: Alignment.center,
                  columnBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  rowBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  cellBuilder: (context, vicinity) {
                    return TableViewCell(
                      child: SizedBox(
                        key: ValueKey<String>(
                          'cell ${vicinity.column}:${vicinity.row}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final Offset tableTopLeft = tester.getTopLeft(find.byType(TableView));
      // Table is 100x100, viewport is 600x600. Centered means 250, 250 offset.
      final Finder cell00 = find.byKey(const ValueKey<String>('cell 0:0'));
      expect(
        tester.getTopLeft(cell00) - tableTopLeft,
        const Offset(250.0, 250.0),
      );
    });

    testWidgets('Alignment with pinned columns', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          debugShowCheckedModeBanner: false,
          builder: (context, child) => Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 600,
                height: 400,
                child: TableView.builder(
                  columnCount: 3,
                  rowCount: 1,
                  pinnedColumnCount: 1,
                  alignment: Alignment.topCenter,
                  columnBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  rowBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  cellBuilder: (context, vicinity) {
                    return TableViewCell(
                      child: SizedBox(
                        key: ValueKey<String>(
                          'cell ${vicinity.column}:${vicinity.row}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final Offset tableTopLeft = tester.getTopLeft(find.byType(TableView));
      // Total width 300 (1 pinned, 2 unpinned). Viewport 600. Offset 150.
      // Pinned column 0 should be at 150.
      final Finder cell00 = find.byKey(const ValueKey<String>('cell 0:0'));
      expect(
        tester.getTopLeft(cell00) - tableTopLeft,
        const Offset(150.0, 0.0),
      );

      // Unpinned column 1 should be at 250.
      final Finder cell10 = find.byKey(const ValueKey<String>('cell 1:0'));
      expect(
        tester.getTopLeft(cell10) - tableTopLeft,
        const Offset(250.0, 0.0),
      );
    });

    testWidgets('Alignment with pinned rows', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          debugShowCheckedModeBanner: false,
          builder: (context, child) => Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 400,
                height: 600,
                child: TableView.builder(
                  columnCount: 1,
                  rowCount: 3,
                  pinnedRowCount: 1,
                  alignment: Alignment.centerLeft,
                  columnBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  rowBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  cellBuilder: (context, vicinity) {
                    return TableViewCell(
                      child: SizedBox(
                        key: ValueKey<String>(
                          'cell ${vicinity.column}:${vicinity.row}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final Offset tableTopLeft = tester.getTopLeft(find.byType(TableView));
      // Total height 300 (1 pinned, 2 unpinned). Viewport 600. Offset 150.
      // Pinned row 0 should be at 150.
      final Finder cell00 = find.byKey(const ValueKey<String>('cell 0:0'));
      expect(
        tester.getTopLeft(cell00) - tableTopLeft,
        const Offset(0.0, 150.0),
      );

      // Unpinned row 1 should be at 250.
      final Finder cell01 = find.byKey(const ValueKey<String>('cell 0:1'));
      expect(
        tester.getTopLeft(cell01) - tableTopLeft,
        const Offset(0.0, 250.0),
      );
    });

    testWidgets('Alignment with reversed horizontal axis', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          debugShowCheckedModeBanner: false,
          builder: (context, child) => Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 600,
                height: 400,
                child: TableView.builder(
                  columnCount: 1,
                  rowCount: 1,
                  alignment: Alignment.topCenter,
                  horizontalDetails: const ScrollableDetails.horizontal(
                    reverse: true,
                  ),
                  columnBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  rowBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  cellBuilder: (context, vicinity) {
                    return TableViewCell(
                      child: SizedBox(
                        key: ValueKey<String>(
                          'cell ${vicinity.column}:${vicinity.row}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final Offset tableTopLeft = tester.getTopLeft(find.byType(TableView));
      // Reversed horizontal. Start is on the right (600).
      // Center should still be at 250.
      final Finder cell00 = find.byKey(const ValueKey<String>('cell 0:0'));
      expect(
        tester.getTopLeft(cell00) - tableTopLeft,
        const Offset(250.0, 0.0),
      );
    });

    testWidgets('Alignment with reversed vertical axis', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          debugShowCheckedModeBanner: false,
          builder: (context, child) => Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 400,
                height: 600,
                child: TableView.builder(
                  columnCount: 1,
                  rowCount: 1,
                  alignment: Alignment.centerLeft,
                  verticalDetails: const ScrollableDetails.vertical(
                    reverse: true,
                  ),
                  columnBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  rowBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  cellBuilder: (context, vicinity) {
                    return TableViewCell(
                      child: SizedBox(
                        key: ValueKey<String>(
                          'cell ${vicinity.column}:${vicinity.row}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final Offset tableTopLeft = tester.getTopLeft(find.byType(TableView));
      // Reversed vertical. Center should still be at 250.
      final Finder cell00 = find.byKey(const ValueKey<String>('cell 0:0'));
      expect(
        tester.getTopLeft(cell00) - tableTopLeft,
        const Offset(0.0, 250.0),
      );
    });

    testWidgets('Alignment with both axes reversed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          debugShowCheckedModeBanner: false,
          builder: (context, child) => Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 600,
                height: 600,
                child: TableView.builder(
                  columnCount: 1,
                  rowCount: 1,
                  alignment: Alignment.center,
                  horizontalDetails: const ScrollableDetails.horizontal(
                    reverse: true,
                  ),
                  verticalDetails: const ScrollableDetails.vertical(
                    reverse: true,
                  ),
                  columnBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  rowBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  cellBuilder: (context, vicinity) {
                    return TableViewCell(
                      child: SizedBox(
                        key: ValueKey<String>(
                          'cell ${vicinity.column}:${vicinity.row}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final Offset tableTopLeft = tester.getTopLeft(find.byType(TableView));
      // Both reversed. Center should still be at (250, 250).
      final Finder cell00 = find.byKey(const ValueKey<String>('cell 0:0'));
      expect(
        tester.getTopLeft(cell00) - tableTopLeft,
        const Offset(250.0, 250.0),
      );
    });

    testWidgets('AlignmentDirectional with RTL', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          debugShowCheckedModeBanner: false,
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 600,
                height: 400,
                child: TableView.builder(
                  columnCount: 1,
                  rowCount: 1,
                  alignment: AlignmentDirectional.centerEnd,
                  columnBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  rowBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  cellBuilder: (context, vicinity) {
                    return TableViewCell(
                      child: SizedBox(
                        key: ValueKey<String>(
                          'cell ${vicinity.column}:${vicinity.row}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final Offset tableTopLeft = tester.getTopLeft(find.byType(TableView));
      // RTL + centerEnd means alignment to the left.
      // Table is 100 wide, viewport 600. centerEnd in RTL resolved to left (x = -1).
      // Wait, centerEnd in RTL is actually Alignment(-1.0, 0.0) which is left.
      // centerEnd in LTR is Alignment(1.0, 0.0) which is right.
      final Finder cell00 = find.byKey(const ValueKey<String>('cell 0:0'));
      expect(
        tester.getTopLeft(cell00) - tableTopLeft,
        const Offset(0.0, 150.0), // Center Y is 150 (400-100)/2
      );
    });

    testWidgets('Overflow alignment behaves like start in overflow axis', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          debugShowCheckedModeBanner: false,
          builder: (context, child) => Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 200,
                height: 400,
                child: TableView.builder(
                  columnCount: 3, // 300 wide
                  rowCount: 1,
                  alignment: Alignment.center,
                  columnBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  rowBuilder: (index) =>
                      const TableSpan(extent: FixedTableSpanExtent(100)),
                  cellBuilder: (context, vicinity) {
                    return TableViewCell(
                      child: SizedBox(
                        key: ValueKey<String>(
                          'cell ${vicinity.column}:${vicinity.row}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final Offset tableTopLeft = tester.getTopLeft(find.byType(TableView));
      // Table (300) > Viewport (200). Horizontal alignment should be ignored (start).
      // Viewport (400) > Table (100) Row. Vertical alignment should be center (150).
      final Finder cell00 = find.byKey(const ValueKey<String>('cell 0:0'));
      expect(
        tester.getTopLeft(cell00) - tableTopLeft,
        const Offset(0.0, 150.0),
      );
    });
  });
}
