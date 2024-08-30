// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/src/types/video_stabilization_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('VideoStabilizationMode should contain 3 options', () {
    const List<VideoStabilizationMode> values = VideoStabilizationMode.values;

    expect(values.length, 5);
  });

  test('VideoStabilizationMode enum should have items in correct index', () {
    const List<VideoStabilizationMode> values = VideoStabilizationMode.values;

    expect(values[0], VideoStabilizationMode.off);
    expect(values[1], VideoStabilizationMode.on);
    expect(values[2], VideoStabilizationMode.standard);
    expect(values[3], VideoStabilizationMode.cinematic);
    expect(values[4], VideoStabilizationMode.cinematicExtended);
  });

  test('deserializeVideoStabilizationMode() should deserialize correctly', () {
    expect(
        VideoStabilizationMode.fromString('off'), VideoStabilizationMode.off);
    expect(VideoStabilizationMode.fromString('on'), VideoStabilizationMode.on);
    expect(VideoStabilizationMode.fromString('standard'),
        VideoStabilizationMode.standard);
    expect(VideoStabilizationMode.fromString('cinematic'),
        VideoStabilizationMode.cinematic);
    expect(VideoStabilizationMode.fromString('cinematicExtended'),
        VideoStabilizationMode.cinematicExtended);
  });
}
