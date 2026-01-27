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

  test(
    'default implementation setBackgroundPlayback throws unimplemented',
    () async {
      await expectLater(
        () => initialInstance.setBackgroundPlayback(1, enableBackground: true),
        throwsUnimplementedError,
      );
    },
  );

  test(
    'default implementation isBackgroundPlaybackSupportAvailable returns false',
    () {
      expect(initialInstance.isBackgroundPlaybackSupportAvailable(), false);
    },
  );

  group('NotificationMetadata', () {
    test('constructs with required id', () {
      const metadata = NotificationMetadata(id: 'test_id');

      expect(metadata.id, 'test_id');
      expect(metadata.title, isNull);
      expect(metadata.album, isNull);
      expect(metadata.artist, isNull);
      expect(metadata.duration, isNull);
      expect(metadata.artUri, isNull);
    });

    test('constructs with all properties', () {
      final metadata = NotificationMetadata(
        id: 'test_id',
        title: 'Test Title',
        album: 'Test Album',
        artist: 'Test Artist',
        duration: const Duration(minutes: 5),
        artUri: Uri.parse('https://example.com/art.jpg'),
      );

      expect(metadata.id, 'test_id');
      expect(metadata.title, 'Test Title');
      expect(metadata.album, 'Test Album');
      expect(metadata.artist, 'Test Artist');
      expect(metadata.duration, const Duration(minutes: 5));
      expect(metadata.artUri, Uri.parse('https://example.com/art.jpg'));
    });

    test('equality works correctly', () {
      final metadata1 = NotificationMetadata(
        id: 'test_id',
        title: 'Test Title',
        artUri: Uri.parse('https://example.com/art.jpg'),
      );
      final metadata2 = NotificationMetadata(
        id: 'test_id',
        title: 'Test Title',
        artUri: Uri.parse('https://example.com/art.jpg'),
      );
      final metadata3 = NotificationMetadata(
        id: 'different_id',
        title: 'Test Title',
        artUri: Uri.parse('https://example.com/art.jpg'),
      );

      expect(metadata1, equals(metadata2));
      expect(metadata1, isNot(equals(metadata3)));
    });

    test('hashCode is consistent with equality', () {
      final metadata1 = NotificationMetadata(
        id: 'test_id',
        title: 'Test Title',
        artUri: Uri.parse('https://example.com/art.jpg'),
      );
      final metadata2 = NotificationMetadata(
        id: 'test_id',
        title: 'Test Title',
        artUri: Uri.parse('https://example.com/art.jpg'),
      );

      expect(metadata1.hashCode, equals(metadata2.hashCode));
    });

    test('toString returns readable representation', () {
      const metadata = NotificationMetadata(id: 'test_id', title: 'Test Title');

      final string = metadata.toString();
      expect(string, contains('NotificationMetadata'));
      expect(string, contains('test_id'));
      expect(string, contains('Test Title'));
    });
  });
}
