// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  test('VideoPlayerAndroidOptions defaults to false', () {
    const options = VideoPlayerAndroidOptions();
    expect(options.enableDecoderFallback, false);
    expect(options.disableMediaCodecAsyncQueueing, false);
  });

  test(
    'VideoPlayerAndroidOptions equality and toString include both fields',
    () {
      const options = VideoPlayerAndroidOptions(
        enableDecoderFallback: true,
        disableMediaCodecAsyncQueueing: true,
      );

      expect(
        options,
        const VideoPlayerAndroidOptions(
          enableDecoderFallback: true,
          disableMediaCodecAsyncQueueing: true,
        ),
      );
      expect(
        options,
        isNot(
          const VideoPlayerAndroidOptions(
            enableDecoderFallback: true,
            disableMediaCodecAsyncQueueing: false,
          ),
        ),
      );
      expect(
        options.toString(),
        'VideoPlayerAndroidOptions(enableDecoderFallback: true, '
        'disableMediaCodecAsyncQueueing: true)',
      );
    },
  );

  test('VideoPlayerOptions allowBackgroundPlayback defaults to false', () {
    final options = VideoPlayerOptions();
    expect(options.allowBackgroundPlayback, false);
  });

  test('VideoPlayerOptions mixWithOthers defaults to false', () {
    final options = VideoPlayerOptions();
    expect(options.mixWithOthers, false);
  });

  test('VideoPlayerOptions androidOptions defaults to null', () {
    final options = VideoPlayerOptions();
    expect(options.androidOptions, isNull);
  });

  test('VideoCreationOptions carries androidOptions', () {
    const androidOptions = VideoPlayerAndroidOptions(
      enableDecoderFallback: true,
      disableMediaCodecAsyncQueueing: true,
    );
    final options = VideoCreationOptions(
      dataSource: DataSource(
        sourceType: DataSourceType.network,
        uri: 'https://example.com/video.mp4',
      ),
      viewType: VideoViewType.textureView,
      androidOptions: androidOptions,
    );

    expect(options.androidOptions, androidOptions);
  });
}
