// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

void main() {
  group('TreeRowExtent', () {
    test('FixedTreeRowExtent', () {
      FixedTreeRowExtent extent = const FixedTreeRowExtent(150);
      expect(
        extent.calculateExtent(
          const TreeRowExtentDelegate(precedingExtent: 0, viewportExtent: 0),
        ),
        150,
      );
      expect(
        extent.calculateExtent(
          const TreeRowExtentDelegate(
              precedingExtent: 100, viewportExtent: 1000),
        ),
        150,
      );
      // asserts value is valid
      expect(
        () {
          extent = FixedTreeRowExtent(-100);
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

    test('FractionalTreeRowExtent', () {
      FractionalTreeRowExtent extent = const FractionalTreeRowExtent(0.5);
      expect(
        extent.calculateExtent(
          const TreeRowExtentDelegate(precedingExtent: 0, viewportExtent: 0),
        ),
        0.0,
      );
      expect(
        extent.calculateExtent(
          const TreeRowExtentDelegate(
              precedingExtent: 100, viewportExtent: 1000),
        ),
        500,
      );
      // asserts value is valid
      expect(
        () {
          extent = FractionalTreeRowExtent(-20);
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

    test('RemainingTreeRowExtent', () {
      const RemainingTreeRowExtent extent = RemainingTreeRowExtent();
      expect(
        extent.calculateExtent(
          const TreeRowExtentDelegate(precedingExtent: 0, viewportExtent: 0),
        ),
        0.0,
      );
      expect(
        extent.calculateExtent(
          const TreeRowExtentDelegate(
              precedingExtent: 100, viewportExtent: 1000),
        ),
        900,
      );
    });

    test('CombiningTreeRowExtent', () {
      final CombiningTreeRowExtent extent = CombiningTreeRowExtent(
        const FixedTreeRowExtent(100),
        const RemainingTreeRowExtent(),
        (double a, double b) {
          return a + b;
        },
      );
      expect(
        extent.calculateExtent(
          const TreeRowExtentDelegate(precedingExtent: 0, viewportExtent: 0),
        ),
        100,
      );
      expect(
        extent.calculateExtent(
          const TreeRowExtentDelegate(
              precedingExtent: 100, viewportExtent: 1000),
        ),
        1000,
      );
    });

    test('MaxTreeRowExtent', () {
      const MaxTreeRowExtent extent = MaxTreeRowExtent(
        FixedTreeRowExtent(100),
        RemainingTreeRowExtent(),
      );
      expect(
        extent.calculateExtent(
          const TreeRowExtentDelegate(precedingExtent: 0, viewportExtent: 0),
        ),
        100,
      );
      expect(
        extent.calculateExtent(
          const TreeRowExtentDelegate(
              precedingExtent: 100, viewportExtent: 1000),
        ),
        900,
      );
    });

    test('MinTreeRowExtent', () {
      const MinTreeRowExtent extent = MinTreeRowExtent(
        FixedTreeRowExtent(100),
        RemainingTreeRowExtent(),
      );
      expect(
        extent.calculateExtent(
          const TreeRowExtentDelegate(precedingExtent: 0, viewportExtent: 0),
        ),
        0,
      );
      expect(
        extent.calculateExtent(
          const TreeRowExtentDelegate(
              precedingExtent: 100, viewportExtent: 1000),
        ),
        100,
      );
    });
  });

  test('TreeRowDecoration', () {
    TreeRowDecoration decoration = const TreeRowDecoration(
      color: Color(0xffff0000),
    );
    final TestCanvas canvas = TestCanvas();
    const Rect rect = Rect.fromLTWH(0, 0, 10, 10);
    final TreeRowDecorationPaintDetails details = TreeRowDecorationPaintDetails(
      canvas: canvas,
      rect: rect,
      axisDirection: AxisDirection.down,
    );
    final BorderRadius radius = BorderRadius.circular(10.0);
    decoration.paint(details);
    expect(canvas.rect, rect);
    expect(canvas.paint.color, const Color(0xffff0000));
    expect(canvas.paint.isAntiAlias, isFalse);
    final TestTreeRowBorder border = TestTreeRowBorder(
      top: const BorderSide(),
    );
    decoration = TreeRowDecoration(
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

class TestTreeRowBorder extends TreeRowBorder {
  TestTreeRowBorder({super.top});
  TreeRowDecorationPaintDetails? details;
  BorderRadius? radius;
  @override
  void paint(TreeRowDecorationPaintDetails details, BorderRadius? radius) {
    this.details = details;
    this.radius = radius;
  }
}
