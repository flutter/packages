// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/src/types/video_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('VideoCodec should contain 2 options', () {
    const List<VideoCodec> values = VideoCodec.values;

    expect(values.length, 2);
  });

  test('VideoCodec enum should have items in correct index', () {
    const List<VideoCodec> values = VideoCodec.values;

    expect(values[0], VideoCodec.h264);
    expect(values[1], VideoCodec.hevc);
  });
}
