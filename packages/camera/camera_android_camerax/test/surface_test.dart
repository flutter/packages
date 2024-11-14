// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/surface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'getCounterClockwiseRotationDegrees returns expected rotation degrees for each Surface constant',
      () async {
    final List<int> surfaceConstants = <int>[
      Surface.rotation0,
      Surface.rotation90,
      Surface.rotation180,
      Surface.rotation270
    ];
    for (final int rotationConstant in surfaceConstants) {
      int? expectedRotation;

      switch (rotationConstant) {
        case Surface.rotation0:
          expectedRotation = 0;
        case Surface.rotation90:
          expectedRotation = 270;
        case Surface.rotation180:
          expectedRotation = 180;
        case Surface.rotation270:
          expectedRotation = 90;
        default:
          fail('$rotationConstant is an invalid Surface rotation constant.');
      }
      expect(Surface.getCounterClockwiseRotationDegrees(rotationConstant),
          equals(expectedRotation));
    }
  });
}
