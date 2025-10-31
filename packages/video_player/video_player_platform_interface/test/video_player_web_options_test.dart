// Copyright 2013 The Flutter Authors
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

  test('VideoPlayerOptions allowContextMenu defaults to true', () {
    const VideoPlayerWebOptions options = VideoPlayerWebOptions();
    expect(options.allowContextMenu, isTrue);
  });

  test('VideoPlayerOptions allowRemotePlayback defaults to true', () {
    const VideoPlayerWebOptions options = VideoPlayerWebOptions();
    expect(options.allowRemotePlayback, isTrue);
  });

  group('VideoPlayerOptions poster', () {
    test('defaults to null', () {
      const VideoPlayerWebOptions options = VideoPlayerWebOptions();
      expect(options.poster, null);
    });

    test('with a value', () {
      final VideoPlayerWebOptions options = VideoPlayerWebOptions(
        poster: Uri.parse('https://example.com/poster.jpg'),
      );
      expect(options.poster, Uri.parse('https://example.com/poster.jpg'));
    });
  });
}
