// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player_android/video_player_android.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

const Duration _playDuration = Duration(seconds: 1);
const String _videoAssetKey = 'assets/Butterfly-209.mp4';

// Returns the URL to load an asset from this example app as a network source.
//
// TODO(stuartmorgan): Convert this to a local `HttpServer` that vends the
// assets directly, https://github.com/flutter/flutter/issues/95420
String getUrlForAssetAsNetworkSource(String assetKey) {
  return 'https://github.com/flutter/packages/blob/'
      // This hash can be rolled forward to pick up newly-added assets.
      '2e1673307ff7454aff40b47024eaed49a9e77e81'
      '/packages/video_player/video_player/example/'
      '$assetKey'
      '?raw=true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late AndroidVideoPlayer player;

  setUp(() async {
    player = AndroidVideoPlayer();
    await player.init();
  });

  testWidgets('registers expected implementation', (_) async {
    AndroidVideoPlayer.registerWith();
    expect(VideoPlayerPlatform.instance, isA<AndroidVideoPlayer>());
  });

  testWidgets('initializes at the start', (_) async {
    final int textureId = (await player.create(DataSource(
      sourceType: DataSourceType.asset,
      asset: _videoAssetKey,
    )))!;

    expect(
      await _getDuration(player, textureId),
      const Duration(seconds: 7, milliseconds: 540),
    );

    await player.dispose(textureId);
  });

  testWidgets('can be played', (WidgetTester tester) async {
    final int textureId = (await player.create(DataSource(
      sourceType: DataSourceType.asset,
      asset: _videoAssetKey,
    )))!;

    await player.play(textureId);
    await tester.pumpAndSettle(_playDuration);

    expect(await player.getPosition(textureId), greaterThan(Duration.zero));
    await player.dispose(textureId);
  });

  testWidgets('can seek', (WidgetTester tester) async {
    final int textureId = (await player.create(DataSource(
      sourceType: DataSourceType.asset,
      asset: _videoAssetKey,
    )))!;

    await player.seekTo(textureId, const Duration(seconds: 3));
    await tester.pumpAndSettle(_playDuration);

    expect(
      await player.getPosition(textureId),
      greaterThanOrEqualTo(const Duration(seconds: 3)),
    );
    await player.dispose(textureId);
  });

  testWidgets('can pause', (WidgetTester tester) async {
    final int textureId = (await player.create(DataSource(
      sourceType: DataSourceType.asset,
      asset: _videoAssetKey,
    )))!;

    await player.play(textureId);
    await tester.pumpAndSettle(_playDuration);

    await player.pause(textureId);
    await tester.pumpAndSettle(_playDuration);
    final Duration pausedDuration = await player.getPosition(textureId);
    await tester.pumpAndSettle(_playDuration);

    expect(await player.getPosition(textureId), pausedDuration);
    await player.dispose(textureId);
  });

  testWidgets('can play a video from a file', (WidgetTester tester) async {
    final Directory directory = await getTemporaryDirectory();
    final File file = File('${directory.path}/video.mp4');
    await file.writeAsBytes(
      Uint8List.fromList(
        (await rootBundle.load(_videoAssetKey)).buffer.asUint8List(),
      ),
    );

    final int textureId = (await player.create(DataSource(
      sourceType: DataSourceType.file,
      uri: file.path,
    )))!;

    await player.play(textureId);
    await tester.pumpAndSettle(_playDuration);

    expect(await player.getPosition(textureId), greaterThan(Duration.zero));
    await directory.delete(recursive: true);
    await player.dispose(textureId);
  });

  testWidgets('can play a video from network', (WidgetTester tester) async {
    final int textureId = (await player.create(DataSource(
      sourceType: DataSourceType.network,
      uri: getUrlForAssetAsNetworkSource(_videoAssetKey),
    )))!;

    await player.play(textureId);
    await player.seekTo(textureId, const Duration(seconds: 5));
    await tester.pumpAndSettle(_playDuration);
    await player.pause(textureId);

    expect(await player.getPosition(textureId), greaterThan(Duration.zero));

    final DurationRange range = await _getBufferingRange(player, textureId);
    expect(range.start, Duration.zero);
    expect(range.end, greaterThan(Duration.zero));

    await player.dispose(textureId);
  });
}

Future<Duration> _getDuration(
  AndroidVideoPlayer player,
  int textureId,
) {
  return player.videoEventsFor(textureId).firstWhere((VideoEvent event) {
    return event.eventType == VideoEventType.initialized;
  }).then((VideoEvent event) {
    return event.duration!;
  });
}

Future<DurationRange> _getBufferingRange(
  AndroidVideoPlayer player,
  int textureId,
) {
  return player.videoEventsFor(textureId).firstWhere((VideoEvent event) {
    return event.eventType == VideoEventType.bufferingUpdate;
  }).then((VideoEvent event) {
    return event.buffered!.first;
  });
}
