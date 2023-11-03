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
