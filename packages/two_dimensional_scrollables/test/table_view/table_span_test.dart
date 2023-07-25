// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/table_view.dart';

void main() {
  group('TableSpanExtent', () {
    test('FixedTableSpanExtent', () {
      FixedTableSpanExtent extent = FixedTableSpanExtent(150);
      expect(
        extent.calculateExtent(const TableSpanExtentDelegate(
            precedingExtent: 0, viewportExtent: 0)),
        150,
      );
      expect(
        extent.calculateExtent(const TableSpanExtentDelegate(
            precedingExtent: 100, viewportExtent: 1000)),
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
        extent.calculateExtent(const TableSpanExtentDelegate(
            precedingExtent: 0, viewportExtent: 0)),
        0.0,
      );
      expect(
        extent.calculateExtent(const TableSpanExtentDelegate(
            precedingExtent: 100, viewportExtent: 1000)),
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
            contains('fraction >= 0.0 && fraction <= 1.0'),
          ),
        ),
      );
    });

    test('RemainingTableSpanExtent', () {
      const RemainingTableSpanExtent extent = RemainingTableSpanExtent();
      expect(
        extent.calculateExtent(const TableSpanExtentDelegate(
            precedingExtent: 0, viewportExtent: 0)),
        0.0,
      );
      expect(
        extent.calculateExtent(const TableSpanExtentDelegate(
            precedingExtent: 100, viewportExtent: 1000)),
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
        extent.calculateExtent(const TableSpanExtentDelegate(
            precedingExtent: 0, viewportExtent: 0)),
        100,
      );
      expect(
        extent.calculateExtent(const TableSpanExtentDelegate(
            precedingExtent: 100, viewportExtent: 1000)),
        1000,
      );
    });

    test('MaxTableSpanExtent', () {
      const MaxTableSpanExtent extent = MaxTableSpanExtent(
        FixedTableSpanExtent(100),
        RemainingTableSpanExtent(),
      );
      expect(
        extent.calculateExtent(const TableSpanExtentDelegate(
            precedingExtent: 0, viewportExtent: 0)),
        100,
      );
      expect(
        extent.calculateExtent(const TableSpanExtentDelegate(
            precedingExtent: 100, viewportExtent: 1000)),
        900,
      );
    });

    test('MinTableSpanExtent', () {
      const MinTableSpanExtent extent = MinTableSpanExtent(
        FixedTableSpanExtent(100),
        RemainingTableSpanExtent(),
      );
      expect(
        extent.calculateExtent(const TableSpanExtentDelegate(
            precedingExtent: 0, viewportExtent: 0)),
        0,
      );
      expect(
        extent.calculateExtent(const TableSpanExtentDelegate(
            precedingExtent: 100, viewportExtent: 1000)),
        100,
      );
    });
  });

  test('TableSpanDecoration', () {});

  test('TableSpanBorder', () {});
}
