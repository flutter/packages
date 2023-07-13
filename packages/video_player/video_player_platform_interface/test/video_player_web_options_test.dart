// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  test(
    'VideoPlayerOptions controls defaults to VideoPlayerWebOptionsControls.disabled()',
    () {
      const VideoPlayerWebOptions options = VideoPlayerWebOptions();
      expect(options.controls, const VideoPlayerWebOptionsControls.disabled());
    },
  );

  test(
    'VideoPlayerOptions allowContextMenu defaults to true',
    () {
      const VideoPlayerWebOptions options = VideoPlayerWebOptions();
      expect(options.allowContextMenu, isTrue);
    },
  );

  test(
    'VideoPlayerOptions allowRemotePlayback defaults to true',
    () {
      const VideoPlayerWebOptions options = VideoPlayerWebOptions();
      expect(options.allowRemotePlayback, isTrue);
    },
  );
}
