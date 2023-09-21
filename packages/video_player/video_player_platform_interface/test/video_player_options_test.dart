// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  test(
    'VideoPlayerOptions allowBackgroundPlayback defaults to false',
    () {
      final VideoPlayerOptions options = VideoPlayerOptions();
      expect(options.allowBackgroundPlayback, false);
    },
  );
  test(
    'VideoPlayerOptions mixWithOthers defaults to false',
    () {
      final VideoPlayerOptions options = VideoPlayerOptions();
      expect(options.mixWithOthers, false);
    },
  );
  test(
    'VideoPlayerOptions enableCache defaults to false',
    () {
      final VideoPlayerOptions options = VideoPlayerOptions();
      expect(options.enableCache, false);
    },
  );
  test(
    'VideoPlayerOptions maxCacheSize defaults to null',
    () {
      final VideoPlayerOptions options = VideoPlayerOptions();
      expect(options.maxCacheSize, null);
    },
  );
  test(
    'VideoPlayerOptions mixWithOthers defaults to null',
    () {
      final VideoPlayerOptions options = VideoPlayerOptions();
      expect(options.maxFileSize, null);
    },
  );

  test(
    'VideoPlayerOptions enableCache to true',
    () {
      final VideoPlayerOptions options = VideoPlayerOptions(enableCache: true);
      expect(options.enableCache, true);
    },
  );
  test(
    'VideoPlayerOptions maxCacheSize to 10',
    () {
      final VideoPlayerOptions options = VideoPlayerOptions(maxCacheSize: 10);
      expect(options.maxCacheSize, 10);
    },
  );
  test(
    'VideoPlayerOptions mixWithOthers defaults to 15',
    () {
      final VideoPlayerOptions options = VideoPlayerOptions(maxFileSize: 15);
      expect(options.maxFileSize, 15);
    },
  );
}
