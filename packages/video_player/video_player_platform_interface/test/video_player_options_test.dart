// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  test('VideoPlayerOptions allowBackgroundPlayback defaults to false', () {
    final options = VideoPlayerOptions();
    expect(options.allowBackgroundPlayback, false);
  });

  test('VideoPlayerOptions mixWithOthers defaults to false', () {
    final options = VideoPlayerOptions();
    expect(options.mixWithOthers, false);
  });

  test('VideoPlayerOptions notificationMetadata defaults to null', () {
    final options = VideoPlayerOptions();
    expect(options.notificationMetadata, isNull);
  });

  test('VideoPlayerOptions accepts notificationMetadata', () {
    const metadata = NotificationMetadata(
      id: 'test_id',
      title: 'Test Title',
      artist: 'Test Artist',
    );
    final options = VideoPlayerOptions(notificationMetadata: metadata);

    expect(options.notificationMetadata, isNotNull);
    expect(options.notificationMetadata!.id, 'test_id');
    expect(options.notificationMetadata!.title, 'Test Title');
    expect(options.notificationMetadata!.artist, 'Test Artist');
  });

  test('VideoPlayerOptions webOptions defaults to null', () {
    final options = VideoPlayerOptions();
    expect(options.webOptions, isNull);
  });
}
