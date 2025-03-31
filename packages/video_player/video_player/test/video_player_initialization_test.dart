// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'video_player_test.dart' show FakeVideoPlayerPlatform;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeVideoPlayerPlatform fakeVideoPlayerPlatform;

  setUp(() {
    VideoPlayerPlatform.instance =
        fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();
  });

  test('plugin initialized', () async {
    final VideoPlayerController controller = VideoPlayerController.networkUrl(
      Uri.parse('https://127.0.0.1'),
    );
    await controller.initialize();
    expect(fakeVideoPlayerPlatform.calls.first, 'init');
  });

  test('web configuration is applied (web only)', () async {
    const VideoPlayerWebOptions expected = VideoPlayerWebOptions(
      allowContextMenu: false,
      allowRemotePlayback: false,
      controls: VideoPlayerWebOptionsControls.enabled(),
    );

    final VideoPlayerController controller = VideoPlayerController.networkUrl(
      Uri.parse('https://127.0.0.1'),
      videoPlayerOptions: VideoPlayerOptions(
        webOptions: expected,
      ),
    );
    await controller.initialize();

    expect(
      () {
        fakeVideoPlayerPlatform.calls.singleWhere(
          (String call) => call == 'setWebOptions',
        );
      },
      returnsNormally,
      reason: 'setWebOptions must be called exactly once.',
    );
    expect(
      fakeVideoPlayerPlatform.webOptions[controller.textureId],
      expected,
      reason: 'web options must be passed to the platform',
    );
  }, skip: !kIsWeb);
}
