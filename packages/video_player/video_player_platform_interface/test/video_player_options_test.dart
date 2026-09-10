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

  test('VideoPlayerAndroidOptions equality and toString include both fields', () {
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
    expect(options, isNot(const VideoPlayerAndroidOptions(enableDecoderFallback: true)));
    expect(
      options.toString(),
      'VideoPlayerAndroidOptions(enableDecoderFallback: true, '
      'disableMediaCodecAsyncQueueing: true)',
    );
  });

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

  test('VideoCreationOptions carries videoPlayerOptions', () {
    const androidOptions = VideoPlayerAndroidOptions(
      enableDecoderFallback: true,
      disableMediaCodecAsyncQueueing: true,
    );
    final videoPlayerOptions = VideoPlayerOptions(androidOptions: androidOptions);
    final creationOptions = VideoCreationOptions(
      dataSource: DataSource(
        sourceType: DataSourceType.network,
        uri: 'https://example.com/video.mp4',
      ),
      viewType: VideoViewType.textureView,
      videoPlayerOptions: videoPlayerOptions,
    );

    expect(creationOptions.videoPlayerOptions, videoPlayerOptions);
    expect(creationOptions.videoPlayerOptions?.androidOptions, androidOptions);
  });

  test('VideoPlayerOptions preventsDisplaySleepDuringVideoPlayback defaults to true', () {
    final options = VideoPlayerOptions();
    expect(options.preventsDisplaySleepDuringVideoPlayback, true);
  });

  test('VideoPlayerOptions backBufferDurationMs defaults to null', () {
    final options = VideoPlayerOptions();
    expect(options.backBufferDurationMs, null);
  });

  test('VideoPlayerOptions backBufferDurationMs stores configured value', () {
    final options = VideoPlayerOptions(backBufferDurationMs: 20000);
    expect(options.backBufferDurationMs, 20000);
  });
}
