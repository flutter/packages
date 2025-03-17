// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_builder_example/all_types.dart';

void main() {
  test('IterableRouteWithDefaultValues', () {
    expect(
      const IterableRouteWithDefaultValues().location,
      '/iterable-route-with-default-values',
    );

    // Needs to not be a const to test
    // https://github.com/flutter/flutter/issues/127825.
    final Set<double> doubleSetField = <double>{};
    expect(
      IterableRouteWithDefaultValues(
        doubleSetField: doubleSetField,
      ).location,
      '/iterable-route-with-default-values',
    );

    expect(
      IterableRouteWithDefaultValues(
        doubleSetField: <double>{0.0, 1.0},
      ).location,
      '/iterable-route-with-default-values?double-set-field=0.0&double-set-field=1.0',
    );

    // Needs to not be a const to test
    // https://github.com/flutter/flutter/issues/127825.
    final Set<int> intSetField = <int>{0, 1};
    expect(
      IterableRouteWithDefaultValues(
        intSetField: intSetField,
      ).location,
      '/iterable-route-with-default-values',
    );

    expect(
      const IterableRouteWithDefaultValues(
        intSetField: <int>{0, 1, 2},
      ).location,
      '/iterable-route-with-default-values?int-set-field=0&int-set-field=1&int-set-field=2',
    );
  });
}
