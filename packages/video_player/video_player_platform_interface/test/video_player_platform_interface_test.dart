// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  // Store the initial instance before any tests change it.
  final VideoPlayerPlatform initialInstance = VideoPlayerPlatform.instance;

  test('default implementation init throws unimplemented', () async {
    await expectLater(() => initialInstance.init(), throwsUnimplementedError);
  });

  test('default implementation setWebOptions throws unimplemented', () async {
    await expectLater(
      () => initialInstance.setWebOptions(1, const VideoPlayerWebOptions()),
      throwsUnimplementedError,
    );
  });

  test('default implementation getAudioTracks throws unimplemented', () async {
    await expectLater(
      () => initialInstance.getAudioTracks(1),
      throwsUnimplementedError,
    );
  });

  test(
    'default implementation selectAudioTrack throws unimplemented',
    () async {
      await expectLater(
        () => initialInstance.selectAudioTrack(1, 'trackId'),
        throwsUnimplementedError,
      );
    },
  );

  test('default implementation isAudioTrackSupportAvailable returns false', () {
    expect(initialInstance.isAudioTrackSupportAvailable(), false);
  });

  test('default implementation getVideoTracks throws unimplemented', () async {
    await expectLater(
      () => initialInstance.getVideoTracks(1),
      throwsUnimplementedError,
    );
  });

  test(
    'default implementation selectVideoTrack throws unimplemented',
    () async {
      await expectLater(
        () => initialInstance.selectVideoTrack(
          1,
          const VideoTrack(id: 'test', isSelected: false),
        ),
        throwsUnimplementedError,
      );
    },
  );

  test('default implementation isVideoTrackSupportAvailable returns false', () {
    expect(initialInstance.isVideoTrackSupportAvailable(), false);
  });

  group('VideoTrack', () {
    test('constructor creates instance with required fields', () {
      const track = VideoTrack(id: 'track_1', isSelected: true);
      expect(track.id, 'track_1');
      expect(track.isSelected, true);
      expect(track.label, isNull);
      expect(track.bitrate, isNull);
      expect(track.width, isNull);
      expect(track.height, isNull);
      expect(track.frameRate, isNull);
      expect(track.codec, isNull);
    });

    test('constructor creates instance with all fields', () {
      const track = VideoTrack(
        id: 'track_1',
        isSelected: true,
        label: '1080p',
        bitrate: 5000000,
        width: 1920,
        height: 1080,
        frameRate: 30.0,
        codec: 'avc1',
      );
      expect(track.id, 'track_1');
      expect(track.isSelected, true);
      expect(track.label, '1080p');
      expect(track.bitrate, 5000000);
      expect(track.width, 1920);
      expect(track.height, 1080);
      expect(track.frameRate, 30.0);
      expect(track.codec, 'avc1');
    });

    test('equality works correctly', () {
      const track1 = VideoTrack(
        id: 'track_1',
        isSelected: true,
        label: '1080p',
        bitrate: 5000000,
      );
      const track2 = VideoTrack(
        id: 'track_1',
        isSelected: true,
        label: '1080p',
        bitrate: 5000000,
      );
      const track3 = VideoTrack(id: 'track_2', isSelected: false);

      expect(track1, equals(track2));
      expect(track1, isNot(equals(track3)));
    });

    test('hashCode is consistent with equality', () {
      const track1 = VideoTrack(
        id: 'track_1',
        isSelected: true,
        label: '1080p',
      );
      const track2 = VideoTrack(
        id: 'track_1',
        isSelected: true,
        label: '1080p',
      );

      expect(track1.hashCode, equals(track2.hashCode));
    });

    test('toString returns expected format', () {
      const track = VideoTrack(
        id: 'track_1',
        isSelected: true,
        label: '1080p',
        bitrate: 5000000,
        width: 1920,
        height: 1080,
        frameRate: 30.0,
        codec: 'avc1',
      );

      final str = track.toString();
      expect(str, contains('VideoTrack'));
      expect(str, contains('id: track_1'));
      expect(str, contains('isSelected: true'));
      expect(str, contains('label: 1080p'));
      expect(str, contains('bitrate: 5000000'));
      expect(str, contains('width: 1920'));
      expect(str, contains('height: 1080'));
      // Accept both '30' and '30.0' (web JS omits trailing .0 for whole-number doubles)
      expect(str, contains('frameRate: 30'));
      expect(str, contains('codec: avc1'));
    });
  });
}
