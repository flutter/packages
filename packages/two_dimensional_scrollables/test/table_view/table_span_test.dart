// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

void main() {
  group('TableSpanExtent', () {
    test('FixedTableSpanExtent', () {
      FixedTableSpanExtent extent = const FixedTableSpanExtent(150);
      expect(
        extent.calculateExtent(
          const TableSpanExtentDelegate(precedingExtent: 0, viewportExtent: 0),
        ),
        150,
      );
      expect(
        extent.calculateExtent(
          const TableSpanExtentDelegate(
              precedingExtent: 100, viewportExtent: 1000),
        ),
        150,
      );
      // asserts value is valid
      expect(
        () {
          extent = FixedTableSpanExtent(-100);
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('pixels >= 0.0'),
          ),
        ),
      );
    });

    test('FractionalTableSpanExtent', () {
      FractionalTableSpanExtent extent = const FractionalTableSpanExtent(0.5);
      expect(
        extent.calculateExtent(
          const TableSpanExtentDelegate(precedingExtent: 0, viewportExtent: 0),
        ),
        0.0,
      );
      expect(
        extent.calculateExtent(
          const TableSpanExtentDelegate(
              precedingExtent: 100, viewportExtent: 1000),
        ),
        500,
      );
      // asserts value is valid
      expect(
        () {
          extent = FractionalTableSpanExtent(-20);
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('fraction >= 0.0'),
          ),
        ),
      );
    });

    test('RemainingTableSpanExtent', () {
      const RemainingTableSpanExtent extent = RemainingTableSpanExtent();
      expect(
        extent.calculateExtent(
          const TableSpanExtentDelegate(precedingExtent: 0, viewportExtent: 0),
        ),
        0.0,
      );
      expect(
        extent.calculateExtent(
          const TableSpanExtentDelegate(
              precedingExtent: 100, viewportExtent: 1000),
        ),
        900,
      );
    });

    test('CombiningTableSpanExtent', () {
      final CombiningTableSpanExtent extent = CombiningTableSpanExtent(
        const FixedTableSpanExtent(100),
        const RemainingTableSpanExtent(),
        (double a, double b) {
          return a + b;
        },
      );
      expect(
        extent.calculateExtent(
          const TableSpanExtentDelegate(precedingExtent: 0, viewportExtent: 0),
        ),
        100,
      );
      expect(
        extent.calculateExtent(
          const TableSpanExtentDelegate(
              precedingExtent: 100, viewportExtent: 1000),
        ),
        1000,
      );
    });

    test('MaxTableSpanExtent', () {
      const MaxTableSpanExtent extent = MaxTableSpanExtent(
        FixedTableSpanExtent(100),
        RemainingTableSpanExtent(),
      );
      expect(
        extent.calculateExtent(
          const TableSpanExtentDelegate(precedingExtent: 0, viewportExtent: 0),
        ),
        100,
      );
      expect(
        extent.calculateExtent(
          const TableSpanExtentDelegate(
              precedingExtent: 100, viewportExtent: 1000),
        ),
        900,
      );
    });

    test('MinTableSpanExtent', () {
      const MinTableSpanExtent extent = MinTableSpanExtent(
        FixedTableSpanExtent(100),
        RemainingTableSpanExtent(),
      );
      expect(
        extent.calculateExtent(
          const TableSpanExtentDelegate(precedingExtent: 0, viewportExtent: 0),
        ),
        0,
      );
      expect(
        extent.calculateExtent(
          const TableSpanExtentDelegate(
              precedingExtent: 100, viewportExtent: 1000),
        ),
        100,
      );
    });
  });

  test('TableSpanDecoration', () {
    TableSpanDecoration decoration = const TableSpanDecoration(
      color: Color(0xffff0000),
    );
    final TestCanvas canvas = TestCanvas();
    const Rect rect = Rect.fromLTWH(0, 0, 10, 10);
    final TableSpanDecorationPaintDetails details =
        TableSpanDecorationPaintDetails(
      canvas: canvas,
      rect: rect,
      axisDirection: AxisDirection.down,
    );
    final BorderRadius radius = BorderRadius.circular(10.0);
    decoration.paint(details);
    expect(canvas.rect, rect);
    expect(canvas.paint.color, const Color(0xffff0000));
    expect(canvas.paint.isAntiAlias, isFalse);
    final TestTableSpanBorder border = TestTableSpanBorder(
      leading: const BorderSide(),
    );
    decoration = TableSpanDecoration(
      border: border,
      borderRadius: radius,
    );
    decoration.paint(details);
    expect(border.details, details);
    expect(border.radius, radius);
  });

  group('Decoration rects account for reversed axes', () {
    late ScrollController verticalController;
    late ScrollController horizontalController;

    setUp(() {
      verticalController = ScrollController();
      horizontalController = ScrollController();
    });

    tearDown(() {
      verticalController.dispose();
      horizontalController.dispose();
    });

    Widget buildCell(BuildContext context, TableVicinity vicinity) {
      return const SizedBox.shrink();
    }

    TableSpan buildSpan(bool isColumn) {
      return TableSpan(
        extent: const FixedTableSpanExtent(100),
        foregroundDecoration: TableSpanDecoration(
          color: isColumn ? const Color(0xFFE1BEE7) : const Color(0xFFBBDEFB),
        ),
      );
    }

    testWidgets('Vertical main axis, vertical reversed',
        (WidgetTester tester) async {
      final TableView table = TableView.builder(
        verticalDetails: ScrollableDetails.vertical(
          controller: verticalController,
          reverse: true,
        ),
        horizontalDetails: ScrollableDetails.horizontal(
          controller: horizontalController,
        ),
        rowCount: 10,
        columnCount: 10,
        rowBuilder: (_) => buildSpan(false),
        columnBuilder: (_) => buildSpan(true),
        cellBuilder: buildCell,
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: table,
      ));
      await tester.pumpAndSettle();

      expect(
        find.byType(TableViewport),
        paints
          // Rows first, bottom to top for reversed axis
          ..rect(
            rect: const Rect.fromLTRB(0.0, 500.0, 1000.0, 600.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, 400.0, 1000.0, 500.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, 300.0, 1000.0, 400.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, 200.0, 1000.0, 300.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, 100.0, 1000.0, 200.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, 0.0, 1000.0, 100.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, -100.0, 1000.0, 0.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, -200.0, 1000.0, -100.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, -300.0, 1000.0, -200.0),
            color: const Color(0xffbbdefb),
          )
          // Columns next
          ..rect(
            rect: const Rect.fromLTRB(0.0, -300.0, 100.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(100.0, -300.0, 200.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(200.0, -300.0, 300.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(300.0, -300.0, 400.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(400.0, -300.0, 500.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(500.0, -300.0, 600.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(600.0, -300.0, 700.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(700.0, -300.0, 800.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(800.0, -300.0, 900.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(900.0, -300.0, 1000.0, 600.0),
            color: const Color(0xffe1bee7),
          ),
      );
    });

    testWidgets('Vertical main axis, horizontal reversed',
        (WidgetTester tester) async {
      final TableView table = TableView.builder(
        verticalDetails: ScrollableDetails.vertical(
          controller: verticalController,
        ),
        horizontalDetails: ScrollableDetails.horizontal(
          controller: horizontalController,
          reverse: true,
        ),
        rowCount: 10,
        columnCount: 10,
        rowBuilder: (_) => buildSpan(false),
        columnBuilder: (_) => buildSpan(true),
        cellBuilder: buildCell,
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: table,
      ));
      await tester.pumpAndSettle();

      expect(
        find.byType(TableViewport),
        paints
          // Rows first
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 0.0, 800.0, 100.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 100.0, 800.0, 200.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 200.0, 800.0, 300.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 300.0, 800.0, 400.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 400.0, 800.0, 500.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 500.0, 800.0, 600.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 600.0, 800.0, 700.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 700.0, 800.0, 800.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 800.0, 800.0, 900.0),
            color: const Color(0xffbbdefb),
          )
          // Columns next, right to left for reversed axis
          ..rect(
            rect: const Rect.fromLTRB(700.0, 0.0, 800.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(600.0, 0.0, 700.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(500.0, 0.0, 600.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(400.0, 0.0, 500.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(300.0, 0.0, 400.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(200.0, 0.0, 300.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(100.0, 0.0, 200.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, 0.0, 100.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(-100.0, 0.0, 0.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 0.0, -100.0, 900.0),
            color: const Color(0xffe1bee7),
          ),
      );
    });

    testWidgets('Vertical main axis, both reversed',
        (WidgetTester tester) async {
      final TableView table = TableView.builder(
        verticalDetails: ScrollableDetails.vertical(
          controller: verticalController,
          reverse: true,
        ),
        horizontalDetails: ScrollableDetails.horizontal(
          controller: horizontalController,
          reverse: true,
        ),
        rowCount: 10,
        columnCount: 10,
        rowBuilder: (_) => buildSpan(false),
        columnBuilder: (_) => buildSpan(true),
        cellBuilder: buildCell,
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: table,
      ));
      await tester.pumpAndSettle();

      expect(
        find.byType(TableViewport),
        paints
          // Rows first, bottom to top for reversed axis
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 500.0, 800.0, 600.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 400.0, 800.0, 500.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 300.0, 800.0, 400.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 200.0, 800.0, 300.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 100.0, 800.0, 200.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 0.0, 800.0, 100.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, -100.0, 800.0, 0.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, -200.0, 800.0, -100.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, -300.0, 800.0, -200.0),
            color: const Color(0xffbbdefb),
          )
          // Columns next, right to left for reversed axis
          ..rect(
            rect: const Rect.fromLTRB(700.0, -300.0, 800.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(600.0, -300.0, 700.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(500.0, -300.0, 600.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(400.0, -300.0, 500.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(300.0, -300.0, 400.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(200.0, -300.0, 300.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(100.0, -300.0, 200.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, -300.0, 100.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(-100.0, -300.0, 0.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, -300.0, -100.0, 600.0),
            color: const Color(0xffe1bee7),
          ),
      );
    });

    testWidgets('Horizontal main axis, vertical reversed',
        (WidgetTester tester) async {
      final TableView table = TableView.builder(
        mainAxis: Axis.horizontal,
        verticalDetails: ScrollableDetails.vertical(
          controller: verticalController,
          reverse: true,
        ),
        horizontalDetails: ScrollableDetails.horizontal(
          controller: horizontalController,
        ),
        rowCount: 10,
        columnCount: 10,
        rowBuilder: (_) => buildSpan(false),
        columnBuilder: (_) => buildSpan(true),
        cellBuilder: buildCell,
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: table,
      ));
      await tester.pumpAndSettle();

      expect(
        find.byType(TableViewport),
        paints
          // Columns first
          ..rect(
            rect: const Rect.fromLTRB(0.0, -300.0, 100.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(100.0, -300.0, 200.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(200.0, -300.0, 300.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(300.0, -300.0, 400.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(400.0, -300.0, 500.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(500.0, -300.0, 600.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(600.0, -300.0, 700.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(700.0, -300.0, 800.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(800.0, -300.0, 900.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(900.0, -300.0, 1000.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          // Rows next, bottom to top for reversed axis
          ..rect(
            rect: const Rect.fromLTRB(0.0, 500.0, 1000.0, 600.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, 400.0, 1000.0, 500.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, 300.0, 1000.0, 400.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, 200.0, 1000.0, 300.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, 100.0, 1000.0, 200.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, 0.0, 1000.0, 100.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, -100.0, 1000.0, 0.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, -200.0, 1000.0, -100.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, -300.0, 1000.0, -200.0),
            color: const Color(0xffbbdefb),
          ),
      );
    });

    testWidgets('Horizontal main axis, horizontal reversed',
        (WidgetTester tester) async {
      final TableView table = TableView.builder(
        mainAxis: Axis.horizontal,
        verticalDetails: ScrollableDetails.vertical(
          controller: verticalController,
        ),
        horizontalDetails: ScrollableDetails.horizontal(
          controller: horizontalController,
          reverse: true,
        ),
        rowCount: 10,
        columnCount: 10,
        rowBuilder: (_) => buildSpan(false),
        columnBuilder: (_) => buildSpan(true),
        cellBuilder: buildCell,
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: table,
      ));
      await tester.pumpAndSettle();

      expect(
        find.byType(TableViewport),
        paints
          // Columns first, right to left for reversed axis
          ..rect(
            rect: const Rect.fromLTRB(700.0, 0.0, 800.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(600.0, 0.0, 700.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(500.0, 0.0, 600.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(400.0, 0.0, 500.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(300.0, 0.0, 400.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(200.0, 0.0, 300.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(100.0, 0.0, 200.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, 0.0, 100.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(-100.0, 0.0, 0.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 0.0, -100.0, 900.0),
            color: const Color(0xffe1bee7),
          )
          // Rows next
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 0.0, 800.0, 100.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 100.0, 800.0, 200.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 200.0, 800.0, 300.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 300.0, 800.0, 400.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 400.0, 800.0, 500.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 500.0, 800.0, 600.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 600.0, 800.0, 700.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 700.0, 800.0, 800.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 800.0, 800.0, 900.0),
            color: const Color(0xffbbdefb),
          ),
      );
    });

    testWidgets('Horizontal main axis, both reversed',
        (WidgetTester tester) async {
      final TableView table = TableView.builder(
        mainAxis: Axis.horizontal,
        verticalDetails: ScrollableDetails.vertical(
          controller: verticalController,
          reverse: true,
        ),
        horizontalDetails: ScrollableDetails.horizontal(
          controller: horizontalController,
          reverse: true,
        ),
        rowCount: 10,
        columnCount: 10,
        rowBuilder: (_) => buildSpan(false),
        columnBuilder: (_) => buildSpan(true),
        cellBuilder: buildCell,
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: table,
      ));
      await tester.pumpAndSettle();

      expect(
        find.byType(TableViewport),
        paints
          // Columns first, right to left for reversed axis
          ..rect(
            rect: const Rect.fromLTRB(700.0, -300.0, 800.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(600.0, -300.0, 700.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(500.0, -300.0, 600.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(400.0, -300.0, 500.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(300.0, -300.0, 400.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(200.0, -300.0, 300.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(100.0, -300.0, 200.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(0.0, -300.0, 100.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(-100.0, -300.0, 0.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, -300.0, -100.0, 600.0),
            color: const Color(0xffe1bee7),
          )
          // Rows next, bottom to top for reversed axis
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 500.0, 800.0, 600.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 400.0, 800.0, 500.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 300.0, 800.0, 400.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 200.0, 800.0, 300.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 100.0, 800.0, 200.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, 0.0, 800.0, 100.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, -100.0, 800.0, 0.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, -200.0, 800.0, -100.0),
            color: const Color(0xffbbdefb),
          )
          ..rect(
            rect: const Rect.fromLTRB(-200.0, -300.0, 800.0, -200.0),
            color: const Color(0xffbbdefb),
          ),
      );
    });
  });
}

class TestCanvas implements Canvas {
  final List<Invocation> noSuchMethodInvocations = <Invocation>[];
  late Rect rect;
  late Paint paint;

  @override
  void drawRect(Rect rect, Paint paint) {
    this.rect = rect;
    this.paint = paint;
  }

  @override
  void noSuchMethod(Invocation invocation) {
    noSuchMethodInvocations.add(invocation);
  }
}

class TestTableSpanBorder extends TableSpanBorder {
  TestTableSpanBorder({super.leading});
  TableSpanDecorationPaintDetails? details;
  BorderRadius? radius;
  @override
  void paint(TableSpanDecorationPaintDetails details, BorderRadius? radius) {
    this.details = details;
    this.radius = radius;
  }
}
