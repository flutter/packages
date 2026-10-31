// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class _LoadingPlatform extends VideoPlayerPlatform {
  final setting = Completer<void>();
  bool failCreation = false;
  bool subscribed = false;
  final disposed = <int>[];

  @override
  Future<void> init() async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    if (failCreation) {
      throw PlatformException(code: 'VideoError', message: 'Creation failed');
    }
    return 7;
  }

  @override
  Future<void> setPreventsDisplaySleepDuringVideoPlayback(
    int playerId,
    bool preventsDisplaySleepDuringVideoPlayback,
  ) => setting.future;

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) {
    subscribed = true;
    return const Stream<VideoEvent>.empty();
  }

  @override
  Future<void> dispose(int playerId) async => disposed.add(playerId);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('disposing during platform setup prevents a late event subscription', () async {
    final platform = _LoadingPlatform();
    final VideoPlayerPlatform original = VideoPlayerPlatform.instance;
    VideoPlayerPlatform.instance = platform;
    addTearDown(() => VideoPlayerPlatform.instance = original);

    final controller = VideoPlayerController.asset('video.mp4');
    final Future<void> initialization = controller.initialize();
    await controller.dispose();
    platform.setting.complete();
    await initialization;

    expect(platform.subscribed, isFalse);
    expect(platform.disposed, <int>[7]);
  });

  test('a failed creation does not leave disposal waiting for an absent player', () async {
    final platform = _LoadingPlatform()..failCreation = true;
    final VideoPlayerPlatform original = VideoPlayerPlatform.instance;
    VideoPlayerPlatform.instance = platform;
    addTearDown(() => VideoPlayerPlatform.instance = original);
    final controller = VideoPlayerController.asset('video.mp4');
    await expectLater(controller.initialize(), throwsA(isA<PlatformException>()));
    await controller.dispose().timeout(const Duration(seconds: 2));

    expect(platform.disposed, isEmpty);
  });

  test('caption loading can finish after disposal without updating the controller', () async {
    final platform = _LoadingPlatform()..setting.complete();
    final VideoPlayerPlatform original = VideoPlayerPlatform.instance;
    VideoPlayerPlatform.instance = platform;
    addTearDown(() => VideoPlayerPlatform.instance = original);
    final captions = Completer<ClosedCaptionFile>();
    final controller = VideoPlayerController.asset('video.mp4', closedCaptionFile: captions.future);
    final Future<void> initialization = controller.initialize();

    // Let platform creation finish so disposal races with caption loading.
    await Future<void>.delayed(Duration.zero);
    await controller.dispose();
    captions.complete(SubRipCaptionFile(''));
    await initialization;

    expect(platform.subscribed, isFalse);
    expect(platform.disposed, <int>[7]);
  });
}
