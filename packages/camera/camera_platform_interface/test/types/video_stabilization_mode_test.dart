// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/src/types/video_stabilization_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('VideoStabilizationMode should contain 4 options', () {
    const List<VideoStabilizationMode> values = VideoStabilizationMode.values;

    expect(values.length, 4);
  });

  test('VideoStabilizationMode enum should have items in correct index', () {
    const List<VideoStabilizationMode> values = VideoStabilizationMode.values;

    expect(values[0], VideoStabilizationMode.off);
    expect(values[1], VideoStabilizationMode.level1);
    expect(values[2], VideoStabilizationMode.level2);
    expect(values[3], VideoStabilizationMode.level3);
  });
}
