// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:web_benchmarks/src/timeseries.dart';

void main() {
  group('Timeseries', () {
    test('computePercentiles', () {
      final Map<double, double> computed = computePercentiles(
        'test',
        <double>[0.0, 0.5, 0.9, 0.95, 1.0],
        List<double>.generate(100, (int i) => i.toDouble()),
      );
      expect(computed.length, 5);
      expect(computed[0.0], 0.0);
      expect(computed[0.5], 50.0);
      expect(computed[0.9], 90.0);
      expect(computed[0.95], 95.0);
      expect(computed[1.0], 99.0);
    });

    test('generatePercentileTargets', () {
      // This should match the expected percentile values in the
      // [BenchmarkMetricComputation] enum.
      expect(generatePercentileTargets(), <double>[0.50, 0.90, 0.95]);
    });
  });
}
