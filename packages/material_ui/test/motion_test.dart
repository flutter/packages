// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('Springs exposes standard spring tokens', () {
    expect(Springs.standardDefaultSpatial, _springDescription(stiffness: 700.0, dampingRatio: 0.9));
    expect(Springs.standardFastSpatial, _springDescription(stiffness: 1400.0, dampingRatio: 0.9));
    expect(Springs.standardSlowSpatial, _springDescription(stiffness: 300.0, dampingRatio: 0.9));
    expect(
      Springs.standardDefaultEffects,
      _springDescription(stiffness: 1600.0, dampingRatio: 1.0),
    );
    expect(Springs.standardFastEffects, _springDescription(stiffness: 3800.0, dampingRatio: 1.0));
    expect(Springs.standardSlowEffects, _springDescription(stiffness: 800.0, dampingRatio: 1.0));
  });

  test('Springs exposes expressive spring tokens', () {
    expect(
      Springs.expressiveDefaultSpatial,
      _springDescription(stiffness: 380.0, dampingRatio: 0.8),
    );
    expect(Springs.expressiveFastSpatial, _springDescription(stiffness: 800.0, dampingRatio: 0.6));
    expect(Springs.expressiveSlowSpatial, _springDescription(stiffness: 200.0, dampingRatio: 0.8));
    expect(
      Springs.expressiveDefaultEffects,
      _springDescription(stiffness: 1600.0, dampingRatio: 1.0),
    );
    expect(Springs.expressiveFastEffects, _springDescription(stiffness: 3800.0, dampingRatio: 1.0));
    expect(Springs.expressiveSlowEffects, _springDescription(stiffness: 800.0, dampingRatio: 1.0));
  });
}

Matcher _springDescription({required double stiffness, required double dampingRatio}) {
  return isA<SpringDescription>()
      .having((SpringDescription spring) => spring.mass, 'mass', 1.0)
      .having((SpringDescription spring) => spring.stiffness, 'stiffness', stiffness)
      .having(
        (SpringDescription spring) => spring.damping,
        'damping',
        moreOrLessEquals(2 * dampingRatio * math.sqrt(stiffness)),
      );
}
