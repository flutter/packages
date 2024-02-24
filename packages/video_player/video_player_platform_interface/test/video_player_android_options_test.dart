// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  test(
    'VideoPlayerAndroidOptions enableDecoderFallback defaults to false',
    () {
      const VideoPlayerAndroidOptions options = VideoPlayerAndroidOptions();
      expect(options.enableDecoderFallback, false);
    },
  );
  test(
    'VideoPlayerAndroidOptions extensionMode defaults to extensionRendererModeOff',
    () {
      const VideoPlayerAndroidOptions options = VideoPlayerAndroidOptions();
      expect(options.extensionMode,
          AndroidVideoPlayerExtensionMode.extensionRendererModeOff);
    },
  );
}
