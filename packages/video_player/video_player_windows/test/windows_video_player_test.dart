// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:video_player_windows/src/messages.g.dart';
import 'package:video_player_windows/video_player_windows.dart';

void main() {
  _NetworkTestBinding();
  final TestDefaultBinaryMessenger messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late WindowsVideoPlayer player;
  late _FakeApi api;

  setUp(() {
    api = _FakeApi();
    player = WindowsVideoPlayer(api: api);
  });

  test('registers the Windows implementation', () {
    final VideoPlayerPlatform original = VideoPlayerPlatform.instance;
    addTearDown(() => VideoPlayerPlatform.instance = original);
    WindowsVideoPlayer.registerWith();
    expect(VideoPlayerPlatform.instance, isA<WindowsVideoPlayer>());
  });

  test('preserves Unicode and percent escaped file paths', () async {
    final uri = Uri.file(r'C:\فیلم ها\100%.mp4', windows: true);
    expect(
      await player.create(DataSource(sourceType: DataSourceType.file, uri: uri.toString())),
      17,
    );
    expect(api.sources, <String>[r'C:\فیلم ها\100%.mp4']);
  });

  test('resolves packaged assets inside the application bundle', () async {
    await player.create(
      DataSource(sourceType: DataSourceType.asset, asset: 'assets/a b.mp4', package: 'clips'),
    );
    expect(api.sources.single, endsWith(r'data\flutter_assets\packages\clips\assets\a b.mp4'));
  });

  test('rejects asset traversal and unsupported sources before native creation', () async {
    await expectLater(
      player.create(DataSource(sourceType: DataSourceType.asset, asset: '../outside.mp4')),
      throwsArgumentError,
    );
    await expectLater(
      player.create(DataSource(sourceType: DataSourceType.contentUri, uri: 'content://video')),
      throwsUnsupportedError,
    );
    await expectLater(
      player.create(DataSource(sourceType: DataSourceType.network, uri: 'ftp://example.com/video')),
      throwsArgumentError,
    );
    expect(api.sources, isEmpty);
  });

  test('custom headers use a private source which closes on disposal and reset', () async {
    final client = HttpClient();
    addTearDown(() => client.close(force: true));
    for (final reset in <bool>[false, true]) {
      await player.create(
        DataSource(
          sourceType: DataSourceType.network,
          uri: 'https://example.com/video',
          httpHeaders: <String, String>{'Authorization': 'test'},
        ),
      );
      final Uri uri = Uri.parse(api.sources.last);
      expect(uri.host, '127.0.0.1');
      expect(uri.toString(), isNot(contains('test')));
      final HttpClientResponse response = await (await client.getUrl(
        uri.replace(path: '/'),
      )).close();
      expect(response.statusCode, HttpStatus.notFound);
      await response.drain<void>();
      if (reset) {
        await player.init();
      } else {
        await player.dispose(17);
      }
      await expectLater(() async {
        final HttpClientRequest request = await client.getUrl(uri);
        await request.close();
      }(), throwsA(isA<IOException>()));
    }
  });

  test('uses the texture fallback for a platform view request', () async {
    await player.createWithOptions(
      VideoCreationOptions(
        dataSource: DataSource(
          sourceType: DataSourceType.network,
          uri: 'https://example.com/video.mp4',
        ),
        viewType: VideoViewType.platformView,
      ),
    );
    expect(api.sources, <String>['https://example.com/video.mp4']);
    expect(
      (player.buildViewWithOptions(const VideoViewOptions(playerId: 17)) as Texture).textureId,
      17,
    );
  });

  test('reset during native creation closes the source and rejects the stale player', () async {
    final started = Completer<Uri>();
    final result = Completer<int>();
    api.onCreate = (String source) {
      started.complete(Uri.parse(source));
      return result.future;
    };
    final Future<int> creating = player.create(
      DataSource(
        sourceType: DataSourceType.network,
        uri: 'https://example.com/media',
        httpHeaders: <String, String>{'Authorization': 'test'},
      ),
    );
    final Future<void> rejected = expectLater(creating, throwsStateError);

    final Uri uri = await started.future;
    final Future<void> reset = player.init();
    result.complete(17);
    await rejected;
    await reset;

    expect(api.disposed, <int>{17});
    expect(api.initializationCount, 1);
    final client = HttpClient();
    addTearDown(() => client.close(force: true));
    await expectLater(client.getUrl(uri), throwsA(isA<IOException>()));
  });

  test('preserves millisecond positions and forwards playback options', () async {
    await player.seekTo(17, const Duration(milliseconds: 1234));
    expect(api.seekPositions[17], 1234);
    expect(await player.getPosition(17), const Duration(milliseconds: 1250));
    await player.setPlaybackSpeed(17, 1.5);
    await player.setLooping(17, true);
    await player.setVolume(17, 0.25);
    await player.setPreventsDisplaySleepDuringVideoPlayback(17, false);
    expect(api.playbackSpeeds[17], 1.5);
    expect(api.looping[17], isTrue);
    expect(api.volumes[17], 0.25);
    expect(api.preventsSleep[17], isFalse);
  });

  test('failed native creation closes its HTTP source', () async {
    late Uri uri;
    api.onCreate = (String source) async {
      uri = Uri.parse(source);
      throw PlatformException(code: 'VideoError', message: 'fixture failure');
    };
    await expectLater(
      player.create(
        DataSource(
          sourceType: DataSourceType.network,
          uri: 'https://example.com/media',
          httpHeaders: <String, String>{'X-Test': 'test'},
        ),
      ),
      throwsA(isA<PlatformException>()),
    );
    final client = HttpClient();
    addTearDown(() => client.close(force: true));
    await expectLater(client.getUrl(uri), throwsA(isA<IOException>()));
  });

  test('decodes metadata and absolute buffered range endpoints', () async {
    const channel = MethodChannel('flutter.dev/video_player_windows/events/17');
    messenger.setMockMethodCallHandler(channel, (MethodCall call) async => null);
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    final events = <VideoEvent>[];
    final StreamSubscription<VideoEvent> subscription = player
        .videoEventsFor(17)
        .listen(events.add);
    await Future<void>.delayed(Duration.zero);
    for (final event in <Map<String, Object>>[
      <String, Object>{'event': 'initialized', 'duration': 5000, 'width': 640, 'height': 360},
      <String, Object>{
        'event': 'bufferingUpdate',
        'values': <List<int>>[
          <int>[1000, 3000],
        ],
      },
      <String, Object>{'event': 'isPlayingStateUpdate', 'isPlaying': true},
    ]) {
      await messenger.handlePlatformMessage(
        channel.name,
        const StandardMethodCodec().encodeSuccessEnvelope(event),
        (_) {},
      );
    }
    await Future<void>.delayed(Duration.zero);
    expect(events[0].size, const Size(640, 360));
    expect(events[0].duration, const Duration(seconds: 5));
    expect(events[1].buffered!.single.end, const Duration(seconds: 3));
    expect(events[2].isPlaying, isTrue);
    await subscription.cancel();
  });
}

// The default widget-test HTTP client rejects requests; these tests need
// real loopback sockets.
class _NetworkTestBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

class _FakeApi extends WindowsVideoPlayerApi {
  final List<String> sources = <String>[];
  final Set<int> disposed = <int>{};
  final Map<int, int> seekPositions = <int, int>{};
  final Map<int, double> playbackSpeeds = <int, double>{};
  final Map<int, double> volumes = <int, double>{};
  final Map<int, bool> looping = <int, bool>{};
  final Map<int, bool> preventsSleep = <int, bool>{};
  int initializationCount = 0;
  Future<int> Function(String source)? onCreate;

  @override
  Future<void> initialize() async {
    initializationCount++;
  }

  @override
  Future<int> create(String source, String? networkSource, String? networkRelay) async {
    sources.add(source);
    return onCreate == null ? 17 : onCreate!(source);
  }

  @override
  Future<void> dispose(int playerId) async {
    disposed.add(playerId);
  }

  @override
  Future<void> seekTo(int playerId, int milliseconds) async {
    seekPositions[playerId] = milliseconds;
  }

  @override
  Future<int> getPosition(int playerId) async => 1250;
  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {
    playbackSpeeds[playerId] = speed;
  }

  @override
  Future<void> setVolume(int playerId, double volume) async {
    volumes[playerId] = volume;
  }

  @override
  Future<void> setLooping(int playerId, bool value) async {
    looping[playerId] = value;
  }

  @override
  Future<void> setPreventsDisplaySleep(int playerId, bool value) async {
    preventsSleep[playerId] = value;
  }
}
