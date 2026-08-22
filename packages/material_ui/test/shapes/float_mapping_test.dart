// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/src/shapes/float_mapping.dart';

import 'test_utils.dart';

void main() {
  group('FloatMapping', () {
    void validateMapping(DoubleMapper mapper, double Function(double) expectedFunction) {
      for (var i = 0; i < 10000; i++) {
        final double source = i / 10000;
        final double target = expectedFunction(source);

        expectEqualish(target, mapper.map(source));
        expectEqualish(source, mapper.mapBack(target));
      }
    }

    test('identity mapping', () {
      validateMapping(DoubleMapper.identity, (x) => x);
    });

    test('simple mapping', () {
      validateMapping(
        // Map the first half of the start source to the first quarter of the
        // target.
        DoubleMapper([(0, 0), (0.5, 0.25)]),
        (x) => (x < 0.5) ? x / 2 : (3 * x - 1) / 2,
      );
    });

    test('target wraps', () {
      validateMapping(
        // mapping applies a "+ 0.5".
        DoubleMapper([(0, 0.5), (0.1, 0.6)]),
        (x) => (x + 0.5) % 1,
      );
    });

    test('source wraps', () {
      validateMapping(
        // Values on the source wrap (this is still the "+ 0.5" function).
        DoubleMapper([(0.5, 0), (0.1, 0.6)]),
        (x) => (x + 0.5) % 1,
      );
    });

    test('both wrap', () {
      validateMapping(
        // Just the identity function.
        DoubleMapper([(0.5, 0.5), (0.75, 0.75), (0.1, 0.1), (0.49, 0.49)]),
        (x) => x,
      );
    });

    test('multiple point', () {
      validateMapping(DoubleMapper([(0.4, 0.2), (0.5, 0.22), (0, 0.8)]), (x) {
        if (x < 0.4) {
          return (0.8 + x) % 1;
        } else if (x < 0.5) {
          return 0.2 + (x - 0.4) / 5;
        } else {
          // maps a change of 0.5 in the source to a change 0.58 in the
          // target, hence the 1.16.
          return 0.22 + (x - 0.5) * 1.16;
        }
      });
    });

    test('target double wrap throws', () {
      expect(
        () => DoubleMapper([(0.0, 0.0), (0.3, 0.6), (0.6, 0.3), (0.9, 0.9)]),
        throwsArgumentError,
      );
    });

    test('source double wrap throws', () {
      expect(
        () => DoubleMapper([(0.0, 0.0), (0.6, 0.3), (0.3, 0.6), (0.9, 0.9)]),
        throwsArgumentError,
      );
    });
  });
}
