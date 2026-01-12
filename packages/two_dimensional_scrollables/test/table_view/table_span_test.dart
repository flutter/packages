// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
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
            precedingExtent: 100,
            viewportExtent: 1000,
          ),
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
            precedingExtent: 100,
            viewportExtent: 1000,
          ),
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
            precedingExtent: 100,
            viewportExtent: 1000,
          ),
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
            precedingExtent: 100,
            viewportExtent: 1000,
          ),
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
            precedingExtent: 100,
            viewportExtent: 1000,
          ),
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
            precedingExtent: 100,
            viewportExtent: 1000,
          ),
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
    decoration = TableSpanDecoration(border: border, borderRadius: radius);
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

    TableViewCell buildCell(BuildContext context, TableVicinity vicinity) {
      return const TableViewCell(child: SizedBox.shrink());
    }

    TableSpan buildSpan(bool isColumn) {
      return TableSpan(
        extent: const FixedTableSpanExtent(100),
        foregroundDecoration: TableSpanDecoration(
          color: isColumn ? const Color(0xFFE1BEE7) : const Color(0xFFBBDEFB),
        ),
      );
    }

    testWidgets('Vertical main axis, vertical reversed', (
      WidgetTester tester,
    ) async {
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
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: table),
      );
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

    testWidgets('Vertical main axis, horizontal reversed', (
      WidgetTester tester,
    ) async {
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
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: table),
      );
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

    testWidgets('Vertical main axis, both reversed', (
      WidgetTester tester,
    ) async {
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
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: table),
      );
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

    testWidgets('Horizontal main axis, vertical reversed', (
      WidgetTester tester,
    ) async {
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
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: table),
      );
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

    testWidgets('Horizontal main axis, horizontal reversed', (
      WidgetTester tester,
    ) async {
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
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: table),
      );
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

    testWidgets('Horizontal main axis, both reversed', (
      WidgetTester tester,
    ) async {
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
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: table),
      );
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

  group('merged cell decorations', () {
    // Visualizing test cases in this group of tests ----------
    // For each test configuration, these 3 scenarios are validated.
    // Each test represents a permutation of
    // TableView.mainAxis vertical (default) and horizontal, with
    //  - natural scroll directions
    //  - vertical reversed
    //  - horizontal reversed
    //  - both reversed

    // Scenario 1
    // Cluster of merged rows (M) surrounded by regular cells (...).
    // This tiered scenario verifies that the correct decoration is applied
    // for merged rows.
    // +---------+--------+--------+
    // | M(0,0)//|////////|////////|
    // |/////////|////////|////////|
    // +/////////+--------+--------+
    // |/////////| M(1,1) |        |
    // |/////////|        |        |
    // +---------+        +--------+
    // |         |        | M(2,2) |
    // |         |        |        |
    // +---------+--------+        +
    // |*********|********|        |
    // |*********|********|        |
    // +---------+--------+--------+
    final Map<TableVicinity, (int, int)> scenario1MergedRows =
        <TableVicinity, (int, int)>{
          TableVicinity.zero: (0, 2),
          TableVicinity.zero.copyWith(row: 1): (0, 2),
          const TableVicinity(row: 1, column: 1): (1, 2),
          const TableVicinity(row: 2, column: 1): (1, 2),
          const TableVicinity(row: 2, column: 2): (2, 2),
          const TableVicinity(row: 3, column: 2): (2, 2),
        };

    TableView buildScenario1({
      bool reverseVertical = false,
      bool reverseHorizontal = false,
    }) {
      return TableView.builder(
        verticalDetails: ScrollableDetails.vertical(reverse: reverseVertical),
        horizontalDetails: ScrollableDetails.horizontal(
          reverse: reverseHorizontal,
        ),
        columnCount: 3,
        rowCount: 4,
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            rowMergeStart: scenario1MergedRows[vicinity]?.$1,
            rowMergeSpan: scenario1MergedRows[vicinity]?.$2,
            child: const SizedBox.expand(),
          );
        },
        columnBuilder: (_) {
          return const TableSpan(extent: FixedTableSpanExtent(100.0));
        },
        rowBuilder: (int index) {
          Color? color;
          switch (index) {
            case 0:
              color = const Color(0xFF2196F3);
            case 3:
              color = const Color(0xFF4CAF50);
          }
          return TableSpan(
            extent: const FixedTableSpanExtent(100.0),
            backgroundDecoration:
                color == null ? null : TableSpanDecoration(color: color),
          );
        },
      );
    }

    // Scenario 2
    // Cluster of merged cells (M) surrounded by regular cells (...).
    // This tiered scenario verifies that the correct decoration is applied
    // to merged columns.
    // +--------+--------+--------+--------+
    // | M(0,0)//////////|********|        |
    // |/////////////////|********|        |
    // +--------+--------+--------+--------+
    // |////////| M(1,1)          |        |
    // |////////|                 |        |
    // +--------+--------+--------+--------+
    // |////////|        |M(2,2)***********|
    // |////////|        |*****************|
    // +--------+--------+--------+--------+
    final Map<TableVicinity, (int, int)> scenario2MergedColumns =
        <TableVicinity, (int, int)>{
          TableVicinity.zero: (0, 2),
          TableVicinity.zero.copyWith(column: 1): (0, 2),
          const TableVicinity(row: 1, column: 1): (1, 2),
          const TableVicinity(row: 1, column: 2): (1, 2),
          const TableVicinity(row: 2, column: 2): (2, 2),
          const TableVicinity(row: 2, column: 3): (2, 2),
        };

    TableView buildScenario2({
      bool reverseVertical = false,
      bool reverseHorizontal = false,
    }) {
      return TableView.builder(
        verticalDetails: ScrollableDetails.vertical(reverse: reverseVertical),
        horizontalDetails: ScrollableDetails.horizontal(
          reverse: reverseHorizontal,
        ),
        columnCount: 4,
        rowCount: 3,
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            columnMergeStart: scenario2MergedColumns[vicinity]?.$1,
            columnMergeSpan: scenario2MergedColumns[vicinity]?.$2,
            child: const SizedBox.expand(),
          );
        },
        rowBuilder: (_) {
          return const TableSpan(extent: FixedTableSpanExtent(100.0));
        },
        columnBuilder: (int index) {
          Color? color;
          switch (index) {
            case 0:
              color = const Color(0xFF2196F3);
            case 2:
              color = const Color(0xFF4CAF50);
          }
          return TableSpan(
            extent: const FixedTableSpanExtent(100.0),
            backgroundDecoration:
                color == null ? null : TableSpanDecoration(color: color),
          );
        },
      );
    }

    // Scenario 3
    // Cluster of merged cells (M) surrounded by regular cells (...).
    // This tiered scenario verifies that the correct decoration is applied
    // for merged cells over both rows and columns.
    // \\ = blue
    // // = green
    // XX = intersection
    // +--------+--------+--------+--------+
    // | M(0,0)XXXXXXXXXX|\\\\\\\\|XXXXXXXX|
    // |XXXXXXXXXXXXXXXXX|\\\\\\\\|XXXXXXXX|
    // +XXXXXXXXXXXXXXXXX+--------+--------+
    // |XXXXXXXXXXXXXXXXX| M(1,2)          |
    // |XXXXXXXXXXXXXXXXX|                 |
    // +--------+--------+                 |
    // |////////|        |                 |
    // |////////|        |                 |
    // +--------+--------+--------+--------+
    final Map<TableVicinity, (int, int)> scenario3MergedRows =
        <TableVicinity, (int, int)>{
          TableVicinity.zero: (0, 2),
          const TableVicinity(row: 1, column: 0): (0, 2),
          const TableVicinity(row: 0, column: 1): (0, 2),
          const TableVicinity(row: 1, column: 1): (0, 2),
          const TableVicinity(row: 1, column: 2): (1, 2),
          const TableVicinity(row: 2, column: 2): (1, 2),
          const TableVicinity(row: 1, column: 3): (1, 2),
          const TableVicinity(row: 2, column: 3): (1, 2),
        };
    final Map<TableVicinity, (int, int)> scenario3MergedColumns =
        <TableVicinity, (int, int)>{
          TableVicinity.zero: (0, 2),
          const TableVicinity(row: 1, column: 0): (0, 2),
          const TableVicinity(row: 0, column: 1): (0, 2),
          const TableVicinity(row: 1, column: 1): (0, 2),
          const TableVicinity(row: 1, column: 2): (2, 2),
          const TableVicinity(row: 2, column: 2): (2, 2),
          const TableVicinity(row: 1, column: 3): (2, 2),
          const TableVicinity(row: 2, column: 3): (2, 2),
        };

    TableView buildScenario3({
      Axis mainAxis = Axis.vertical,
      bool reverseVertical = false,
      bool reverseHorizontal = false,
    }) {
      return TableView.builder(
        mainAxis: mainAxis,
        verticalDetails: ScrollableDetails.vertical(reverse: reverseVertical),
        horizontalDetails: ScrollableDetails.horizontal(
          reverse: reverseHorizontal,
        ),
        columnCount: 4,
        rowCount: 3,
        cellBuilder: (_, TableVicinity vicinity) {
          return TableViewCell(
            columnMergeStart: scenario3MergedColumns[vicinity]?.$1,
            columnMergeSpan: scenario3MergedColumns[vicinity]?.$2,
            rowMergeStart: scenario3MergedRows[vicinity]?.$1,
            rowMergeSpan: scenario3MergedRows[vicinity]?.$2,
            child: const SizedBox.expand(),
          );
        },
        rowBuilder: (int index) {
          Color? color;
          switch (index) {
            case 0:
              color = const Color(0xFF2196F3);
          }
          return TableSpan(
            extent: const FixedTableSpanExtent(100.0),
            backgroundDecoration:
                color == null ? null : TableSpanDecoration(color: color),
          );
        },
        columnBuilder: (int index) {
          Color? color;
          switch (index) {
            case 0:
            case 3:
              color = const Color(0xFF4CAF50);
          }
          return TableSpan(
            extent: const FixedTableSpanExtent(100.0),
            backgroundDecoration:
                color == null ? null : TableSpanDecoration(color: color),
          );
        },
      );
    }

    testWidgets('Vertical main axis, natural scroll directions', (
      WidgetTester tester,
    ) async {
      // Scenario 1
      await tester.pumpWidget(buildScenario1());
      expect(
        find.byType(TableViewport),
        paints
          // Top row decorations
          ..rect(
            rect: const Rect.fromLTRB(0.0, 0.0, 100.0, 200.0), // M(0,0)
            color: const Color(0xFF2196F3),
          )
          ..rect(
            // Rest of the unmerged first row
            rect: const Rect.fromLTRB(100.0, 0.0, 300.0, 100.0),
            color: const Color(0xFF2196F3),
          )
          // Bottom row decoration, does not extend into last column
          ..rect(
            rect: const Rect.fromLTRB(0.0, 300.0, 200.0, 400.0),
            color: const Color(0xff4caf50),
          ),
      );

      // Scenario 2
      await tester.pumpWidget(buildScenario2());
      expect(
        find.byType(TableViewport),
        paints
          // First column decorations
          ..rect(
            rect: const Rect.fromLTRB(0.0, 0.0, 200.0, 100.0), // M(0,0)
            color: const Color(0xFF2196F3),
          )
          ..rect(
            // Rest of the unmerged first column
            rect: const Rect.fromLTRB(0.0, 100.0, 100.0, 300.0),
            color: const Color(0xFF2196F3),
          )
          // Third column decorations, does not extend into last column
          ..rect(
            // Unmerged section
            rect: const Rect.fromLTRB(200.0, 0.0, 300.0, 100.0),
            color: const Color(0xff4caf50),
          )
          ..rect(
            rect: const Rect.fromLTRB(200.0, 200.0, 400.0, 300.0), // M(2,2)
            color: const Color(0xff4caf50),
          ),
      );

      // Scenario 3
      await tester.pumpWidget(buildScenario3());
      expect(
        find.byType(TableViewport),
        paints
          // Row decorations
          ..rect(
            rect: const Rect.fromLTRB(0.0, 0.0, 200.0, 200.0), // M(0,0)
            color: const Color(0xFF2196F3),
          )
          ..rect(
            // Rest of the unmerged first row
            rect: const Rect.fromLTRB(200.0, 0.0, 400.0, 100.0),
            color: const Color(0xFF2196F3),
          )
          // Column decorations
          ..rect(
            rect: const Rect.fromLTRB(0.0, 0.0, 200.0, 200.0), // M(0,0)
            color: const Color(0xff4caf50),
          )
          ..rect(
            // Rest of the first column
            rect: const Rect.fromLTRB(0.0, 200.0, 100.0, 300.0),
            color: const Color(0xff4caf50),
          )
          ..rect(
            rect: const Rect.fromLTRB(300.0, 0.0, 400.0, 100.0), // Last column
            color: const Color(0xff4caf50),
          ),
      );
    });

    testWidgets('Vertical main axis, vertical reversed', (
      WidgetTester tester,
    ) async {
      // Scenario 1
      await tester.pumpWidget(buildScenario1(reverseVertical: true));
      expect(
        find.byType(TableViewport),
        paints
          // Bottom row decorations
          ..rect(
            rect: const Rect.fromLTRB(0.0, 400.0, 100.0, 600.0), // M(0,0)
            color: const Color(0xFF2196F3),
          )
          ..rect(
            // Rest of the unmerged first row
            rect: const Rect.fromLTRB(100.0, 500.0, 300.0, 600.0),
            color: const Color(0xFF2196F3),
          )
          // Top row decoration, does not extend into last column
          ..rect(
            rect: const Rect.fromLTRB(0.0, 200.0, 200.0, 300.0),
            color: const Color(0xff4caf50),
          ),
      );

      // Scenario 2
      await tester.pumpWidget(buildScenario2(reverseVertical: true));
      expect(
        find.byType(TableViewport),
        paints
          // First column decorations
          ..rect(
            rect: const Rect.fromLTRB(0.0, 500.0, 200.0, 600.0), // M(0,0)
            color: const Color(0xFF2196F3),
          )
          ..rect(
            // Rest of the unmerged first column
            rect: const Rect.fromLTRB(0.0, 300.0, 100.0, 500.0),
            color: const Color(0xFF2196F3),
          )
          // Third column decorations, does not extend into last column
          ..rect(
            // Unmerged section
            rect: const Rect.fromLTRB(200.0, 500.0, 300.0, 600.0),
            color: const Color(0xff4caf50),
          )
          ..rect(
            rect: const Rect.fromLTRB(200.0, 300.0, 400.0, 400.0), // M(2,2)
            color: const Color(0xff4caf50),
          ),
      );

      // Scenario 3
      await tester.pumpWidget(buildScenario3(reverseVertical: true));
      expect(
        find.byType(TableViewport),
        paints
          // Row decorations
          ..rect(
            rect: const Rect.fromLTRB(0.0, 400.0, 200.0, 600.0), // M(0,0)
            color: const Color(0xFF2196F3),
          )
          ..rect(
            // Rest of the unmerged first row
            rect: const Rect.fromLTRB(200.0, 500.0, 400.0, 600.0),
            color: const Color(0xFF2196F3),
          )
          // Column decorations
          ..rect(
            rect: const Rect.fromLTRB(0.0, 400.0, 200.0, 600.0), // M(0,0)
            color: const Color(0xff4caf50),
          )
          ..rect(
            // Rest of the first column
            rect: const Rect.fromLTRB(0.0, 300.0, 100.0, 400.0),
            color: const Color(0xff4caf50),
          )
          ..rect(
            rect: const Rect.fromLTRB(
              300.0,
              500.0,
              400.0,
              600.0,
            ), // Last column
            color: const Color(0xff4caf50),
          ),
      );
    });

    testWidgets('Vertical main axis, horizontal reversed', (
      WidgetTester tester,
    ) async {
      // Scenario 1
      await tester.pumpWidget(buildScenario1(reverseHorizontal: true));
      expect(
        find.byType(TableViewport),
        paints
          // Top row decorations
          ..rect(
            rect: const Rect.fromLTRB(700.0, 0.0, 800.0, 200.0), // M(0,0)
            color: const Color(0xFF2196F3),
          )
          ..rect(
            // Rest of the unmerged first row
            rect: const Rect.fromLTRB(500.0, 0.0, 700.0, 100.0),
            color: const Color(0xFF2196F3),
          )
          // Bottom row decoration, does not extend into last column
          ..rect(
            rect: const Rect.fromLTRB(600.0, 300.0, 800.0, 400.0),
            color: const Color(0xff4caf50),
          ),
      );

      // Scenario 2
      await tester.pumpWidget(buildScenario2(reverseHorizontal: true));
      expect(
        find.byType(TableViewport),
        paints
          // First column decorations
          ..rect(
            rect: const Rect.fromLTRB(600.0, 0.0, 800.0, 100.0), // M(0,0)
            color: const Color(0xFF2196F3),
          )
          ..rect(
            // Rest of the unmerged first column
            rect: const Rect.fromLTRB(700.0, 100.0, 800.0, 300.0),
            color: const Color(0xFF2196F3),
          )
          // Third column decorations, does not extend into last column
          ..rect(
            // Unmerged section
            rect: const Rect.fromLTRB(500.0, 0.0, 600.0, 100.0),
            color: const Color(0xff4caf50),
          )
          ..rect(
            rect: const Rect.fromLTRB(400.0, 200.0, 600.0, 300.0), // M(2,2)
            color: const Color(0xff4caf50),
          ),
      );

      // Scenario 3
      await tester.pumpWidget(buildScenario3(reverseHorizontal: true));
      expect(
        find.byType(TableViewport),
        paints
          // Row decorations
          ..rect(
            rect: const Rect.fromLTRB(600.0, 0.0, 800.0, 200.0), // M(0,0)
            color: const Color(0xFF2196F3),
          )
          ..rect(
            // Rest of the unmerged first row
            rect: const Rect.fromLTRB(400.0, 0.0, 600.0, 100.0),
            color: const Color(0xFF2196F3),
          )
          // Column decorations
          ..rect(
            rect: const Rect.fromLTRB(600.0, 0.0, 800.0, 200.0), // M(0,0)
            color: const Color(0xff4caf50),
          )
          ..rect(
            // Rest of the first column
            rect: const Rect.fromLTRB(700.0, 200.0, 800.0, 300.0),
            color: const Color(0xff4caf50),
          )
          ..rect(
            rect: const Rect.fromLTRB(400.0, 0.0, 500.0, 100.0), // Last column
            color: const Color(0xff4caf50),
          ),
      );
    });

    testWidgets('Vertical main axis, both reversed', (
      WidgetTester tester,
    ) async {
      // Scenario 1
      await tester.pumpWidget(
        buildScenario1(reverseHorizontal: true, reverseVertical: true),
      );
      expect(
        find.byType(TableViewport),
        paints
          // Top row decorations
          ..rect(
            rect: const Rect.fromLTRB(700.0, 400.0, 800.0, 600.0), // M(0,0)
            color: const Color(0xFF2196F3),
          )
          ..rect(
            // Rest of the unmerged first row
            rect: const Rect.fromLTRB(500.0, 500.0, 700.0, 600.0),
            color: const Color(0xFF2196F3),
          )
          // Bottom row decoration, does not extend into last column
          ..rect(
            rect: const Rect.fromLTRB(600.0, 200.0, 800.0, 300.0),
            color: const Color(0xff4caf50),
          ),
      );

      // Scenario 2
      await tester.pumpWidget(
        buildScenario2(reverseHorizontal: true, reverseVertical: true),
      );
      expect(
        find.byType(TableViewport),
        paints
          // First column decorations
          ..rect(
            rect: const Rect.fromLTRB(600.0, 500.0, 800.0, 600.0), // M(0,0)
            color: const Color(0xFF2196F3),
          )
          ..rect(
            // Rest of the unmerged first column
            rect: const Rect.fromLTRB(700.0, 300.0, 800.0, 500.0),
            color: const Color(0xFF2196F3),
          )
          // Third column decorations, does not extend into last column
          ..rect(
            // Unmerged section
            rect: const Rect.fromLTRB(500.0, 500.0, 600.0, 600.0),
            color: const Color(0xff4caf50),
          )
          ..rect(
            rect: const Rect.fromLTRB(400.0, 300.0, 600.0, 400.0), // M(2,2)
            color: const Color(0xff4caf50),
          ),
      );

      // Scenario 3
      await tester.pumpWidget(
        buildScenario3(reverseHorizontal: true, reverseVertical: true),
      );
      expect(
        find.byType(TableViewport),
        paints
          // Row decorations
          ..rect(
            rect: const Rect.fromLTRB(600.0, 400.0, 800.0, 600.0), // M(0,0)
            color: const Color(0xFF2196F3),
          )
          ..rect(
            // Rest of the unmerged first row
            rect: const Rect.fromLTRB(400.0, 500.0, 600.0, 600.0),
            color: const Color(0xFF2196F3),
          )
          // Column decorations
          ..rect(
            rect: const Rect.fromLTRB(600.0, 400.0, 800.0, 600.0), // M(0,0)
            color: const Color(0xff4caf50),
          )
          ..rect(
            // Rest of the first column
            rect: const Rect.fromLTRB(700.0, 300.0, 800.0, 400.0),
            color: const Color(0xff4caf50),
          )
          ..rect(
            // Last column
            rect: const Rect.fromLTRB(400.0, 500.0, 500.0, 600.0),
            color: const Color(0xff4caf50),
          ),
      );
    });

    testWidgets('Horizontal main axis, natural scroll directions', (
      WidgetTester tester,
    ) async {
      // Scenarios 1 & 2 do not mix column and row decorations, so main axis
      // does not affect them.

      // Scenario 3
      await tester.pumpWidget(buildScenario3(mainAxis: Axis.horizontal));
      expect(
        find.byType(TableViewport),
        paints
          // Column decorations
          ..rect(
            rect: const Rect.fromLTRB(0.0, 0.0, 200.0, 200.0), // M(0,0)
            color: const Color(0xff4caf50),
          )
          ..rect(
            // Rest of the first column
            rect: const Rect.fromLTRB(0.0, 200.0, 100.0, 300.0),
            color: const Color(0xff4caf50),
          )
          ..rect(
            rect: const Rect.fromLTRB(300.0, 0.0, 400.0, 100.0), // Last column
            color: const Color(0xff4caf50),
          )
          // Row decorations
          ..rect(
            rect: const Rect.fromLTRB(0.0, 0.0, 200.0, 200.0), // M(0,0)
            color: const Color(0xFF2196F3),
          )
          ..rect(
            // Rest of the unmerged first row
            rect: const Rect.fromLTRB(200.0, 0.0, 400.0, 100.0),
            color: const Color(0xFF2196F3),
          ),
      );
    });

    testWidgets('Horizontal main axis, vertical reversed', (
      WidgetTester tester,
    ) async {
      // Scenarios 1 & 2 do not mix column and row decorations, so main axis
      // does not affect them.

      // Scenario 3
      await tester.pumpWidget(
        buildScenario3(reverseVertical: true, mainAxis: Axis.horizontal),
      );
      expect(
        find.byType(TableViewport),
        paints
          // Column decorations
          ..rect(
            rect: const Rect.fromLTRB(0.0, 400.0, 200.0, 600.0), // M(0,0)
            color: const Color(0xff4caf50),
          )
          ..rect(
            // Rest of the first column
            rect: const Rect.fromLTRB(0.0, 300.0, 100.0, 400.0),
            color: const Color(0xff4caf50),
          )
          ..rect(
            // Last column
            rect: const Rect.fromLTRB(300.0, 500.0, 400.0, 600.0),
            color: const Color(0xff4caf50),
          )
          // Row decorations
          ..rect(
            rect: const Rect.fromLTRB(0.0, 400.0, 200.0, 600.0), // M(0,0)
            color: const Color(0xFF2196F3),
          )
          ..rect(
            // Rest of the unmerged first row
            rect: const Rect.fromLTRB(200.0, 500.0, 400.0, 600.0),
            color: const Color(0xFF2196F3),
          ),
      );
    });

    testWidgets('Horizontal main axis, horizontal reversed', (
      WidgetTester tester,
    ) async {
      // Scenarios 1 & 2 do not mix column and row decorations, so main axis
      // does not affect them.

      // Scenario 3
      await tester.pumpWidget(
        buildScenario3(reverseHorizontal: true, mainAxis: Axis.horizontal),
      );
      expect(
        find.byType(TableViewport),
        paints
          // Column decorations
          ..rect(
            rect: const Rect.fromLTRB(600.0, 0.0, 800.0, 200.0), // M(0,0)
            color: const Color(0xff4caf50),
          )
          ..rect(
            // Rest of the first column
            rect: const Rect.fromLTRB(700.0, 200.0, 800.0, 300.0),
            color: const Color(0xff4caf50),
          )
          ..rect(
            rect: const Rect.fromLTRB(400.0, 0.0, 500.0, 100.0), // Last column
            color: const Color(0xff4caf50),
          )
          // Row decorations
          ..rect(
            rect: const Rect.fromLTRB(600.0, 0.0, 800.0, 200.0), // M(0,0)
            color: const Color(0xFF2196F3),
          )
          ..rect(
            // Rest of the unmerged first row
            rect: const Rect.fromLTRB(400.0, 0.0, 600.0, 100.0),
            color: const Color(0xFF2196F3),
          ),
      );
    });

    testWidgets('Horizontal main axis, both reversed', (
      WidgetTester tester,
    ) async {
      // Scenarios 1 & 2 do not mix column and row decorations, so main axis
      // does not affect them.

      // Scenario 3
      await tester.pumpWidget(
        buildScenario3(
          reverseHorizontal: true,
          reverseVertical: true,
          mainAxis: Axis.horizontal,
        ),
      );
      expect(
        find.byType(TableViewport),
        paints
          // Column decorations
          ..rect(
            rect: const Rect.fromLTRB(600.0, 400.0, 800.0, 600.0), // M(0,0)
            color: const Color(0xff4caf50),
          )
          ..rect(
            // Rest of the first column
            rect: const Rect.fromLTRB(700.0, 300.0, 800.0, 400.0),
            color: const Color(0xff4caf50),
          )
          ..rect(
            rect: const Rect.fromLTRB(
              400.0,
              500.0,
              500.0,
              600.0,
            ), // Last column
            color: const Color(0xff4caf50),
          )
          // Row decorations
          ..rect(
            rect: const Rect.fromLTRB(600.0, 400.0, 800.0, 600.0), // M(0,0)
            color: const Color(0xFF2196F3),
          )
          ..rect(
            // Rest of the unmerged first row
            rect: const Rect.fromLTRB(400.0, 500.0, 600.0, 600.0),
            color: const Color(0xFF2196F3),
          ),
      );
    });
  });

  testWidgets('merged cells account for row/column padding', (
    WidgetTester tester,
  ) async {
    // Leading padding on the leading cell, and trailing padding on the
    // trailing cell should be excluded. Interim leading/trailing
    // paddings are consumed by the merged cell.
    // Example: This is one whole cell spanning 2 merged columns.
    // l indicates leading padding, t trailing padding
    // +---------------------------------------------------------+
    // |  l  |  column extent  |  t  |  l  | column extent |  t  |
    // +---------------------------------------------------------+
    //       | <--------- extent of merged cell ---------> |

    // Merged Row
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: TableView.builder(
          rowCount: 2,
          columnCount: 1,
          cellBuilder: (_, __) {
            return const TableViewCell(
              rowMergeStart: 0,
              rowMergeSpan: 2,
              child: Text('M(0,0)'),
            );
          },
          columnBuilder:
              (_) => const TableSpan(extent: FixedTableSpanExtent(100.0)),
          rowBuilder: (_) {
            return const TableSpan(
              extent: FixedTableSpanExtent(100.0),
              padding: TableSpanPadding(leading: 10.0, trailing: 15.0),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('M(0,0)')), const Offset(0.0, 10.0));
    expect(tester.getSize(find.text('M(0,0)')), const Size(100.0, 225.0));

    // Merged Column
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: TableView.builder(
          rowCount: 1,
          columnCount: 2,
          cellBuilder: (_, __) {
            return const TableViewCell(
              columnMergeStart: 0,
              columnMergeSpan: 2,
              child: Text('M(0,0)'),
            );
          },
          rowBuilder:
              (_) => const TableSpan(extent: FixedTableSpanExtent(100.0)),
          columnBuilder: (_) {
            return const TableSpan(
              extent: FixedTableSpanExtent(100.0),
              padding: TableSpanPadding(leading: 10.0, trailing: 15.0),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('M(0,0)')), const Offset(10.0, 0));
    expect(tester.getSize(find.text('M(0,0)')), const Size(225.0, 100.0));

    // Merged Square
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: TableView.builder(
          rowCount: 2,
          columnCount: 2,
          cellBuilder: (_, __) {
            return const TableViewCell(
              rowMergeStart: 0,
              rowMergeSpan: 2,
              columnMergeStart: 0,
              columnMergeSpan: 2,
              child: Text('M(0,0)'),
            );
          },
          columnBuilder: (_) {
            return const TableSpan(
              extent: FixedTableSpanExtent(100.0),
              padding: TableSpanPadding(leading: 10.0, trailing: 15.0),
            );
          },
          rowBuilder: (_) {
            return const TableSpan(
              extent: FixedTableSpanExtent(100.0),
              padding: TableSpanPadding(leading: 10.0, trailing: 15.0),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('M(0,0)')), const Offset(10.0, 10.0));
    expect(tester.getSize(find.text('M(0,0)')), const Size(225.0, 225.0));
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
