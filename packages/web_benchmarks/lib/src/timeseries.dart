// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';

// TODO(kenz): move the time series logic from recorder.dart into this file for
// better code separation.

/// Computes the percentile threshold in [values] for the given [percentiles].
///
/// Each value in [percentiles] should be between 0.0 and 1.0.
///
/// Returns a [Map] of percentile values to the computed value from [values].
Map<double, double> computePercentiles(
  String label,
  List<double> percentiles,
  Iterable<double> values,
) {
  if (values.isEmpty) {
    throw StateError(
      '$label: attempted to compute a percentile of an empty value list.',
    );
  }
  for (final double percentile in percentiles) {
    if (percentile < 0.0 || percentile > 1.0) {
      throw StateError(
        '$label: attempted to compute a percentile for an invalid '
        'value: $percentile',
      );
    }
  }

  final List<double> sorted =
      values.sorted((double a, double b) => a.compareTo(b));
  final Map<double, double> computed = <double, double>{};
  for (final double percentile in percentiles) {
    final int percentileIndex =
        (sorted.length * percentile).round().clamp(0, sorted.length - 1);
    computed[percentile] = sorted[percentileIndex];
  }

  return computed;
}
