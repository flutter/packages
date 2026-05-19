// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

void main() {
  group('SpanExtent', () {
    test('FixedSpanExtent', () {
      var extent = const FixedSpanExtent(150);
      expect(
        extent.calculateExtent(
          const SpanExtentDelegate(precedingExtent: 0, viewportExtent: 0),
        ),
        150,
      );
      expect(
        extent.calculateExtent(
          const SpanExtentDelegate(precedingExtent: 100, viewportExtent: 1000),
        ),
        150,
      );
      // asserts value is valid
      expect(
        () {
          extent = FixedSpanExtent(-100);
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

    test('FractionalSpanExtent', () {
      var extent = const FractionalSpanExtent(0.5);
      expect(
        extent.calculateExtent(
          const SpanExtentDelegate(precedingExtent: 0, viewportExtent: 0),
        ),
        0.0,
      );
      expect(
        extent.calculateExtent(
          const SpanExtentDelegate(precedingExtent: 100, viewportExtent: 1000),
        ),
        500,
      );
      // asserts value is valid
      expect(
        () {
          extent = FractionalSpanExtent(-20);
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

    test('RemainingSpanExtent', () {
      const extent = RemainingSpanExtent();
      expect(
        extent.calculateExtent(
          const SpanExtentDelegate(precedingExtent: 0, viewportExtent: 0),
        ),
        0.0,
      );
      expect(
        extent.calculateExtent(
          const SpanExtentDelegate(precedingExtent: 100, viewportExtent: 1000),
        ),
        900,
      );
    });

    test('CombiningSpanExtent', () {
      final extent = CombiningSpanExtent(
        const FixedSpanExtent(100),
        const RemainingSpanExtent(),
        (double a, double b) {
          return a + b;
        },
      );
      expect(
        extent.calculateExtent(
          const SpanExtentDelegate(precedingExtent: 0, viewportExtent: 0),
        ),
        100,
      );
      expect(
        extent.calculateExtent(
          const SpanExtentDelegate(precedingExtent: 100, viewportExtent: 1000),
        ),
        1000,
      );
    });

    test('MaxSpanExtent', () {
      const extent = MaxSpanExtent(FixedSpanExtent(100), RemainingSpanExtent());
      expect(
        extent.calculateExtent(
          const SpanExtentDelegate(precedingExtent: 0, viewportExtent: 0),
        ),
        100,
      );
      expect(
        extent.calculateExtent(
          const SpanExtentDelegate(precedingExtent: 100, viewportExtent: 1000),
        ),
        900,
      );
    });

    test('MinSpanExtent', () {
      const extent = MinSpanExtent(FixedSpanExtent(100), RemainingSpanExtent());
      expect(
        extent.calculateExtent(
          const SpanExtentDelegate(precedingExtent: 0, viewportExtent: 0),
        ),
        0,
      );
      expect(
        extent.calculateExtent(
          const SpanExtentDelegate(precedingExtent: 100, viewportExtent: 1000),
        ),
        100,
      );
    });
  });

  test('SpanDecoration', () {
    var decoration = const SpanDecoration(color: Color(0xffff0000));
    final canvas = TestCanvas();
    const rect = Rect.fromLTWH(0, 0, 10, 10);
    final details = SpanDecorationPaintDetails(
      canvas: canvas,
      rect: rect,
      axisDirection: AxisDirection.down,
    );
    final radius = BorderRadius.circular(10.0);
    decoration.paint(details);
    expect(canvas.rect, rect);
    expect(canvas.paint.color, const Color(0xffff0000));
    expect(canvas.paint.isAntiAlias, isFalse);
    final border = TestSpanBorder(leading: const BorderSide());
    decoration = SpanDecoration(border: border, borderRadius: radius);
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

class TestSpanBorder extends SpanBorder {
  TestSpanBorder({super.leading});
  TableSpanDecorationPaintDetails? details;
  BorderRadius? radius;
  @override
  void paint(TableSpanDecorationPaintDetails details, BorderRadius? radius) {
    this.details = details;
    this.radius = radius;
  }
}
