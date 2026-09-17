---
name: video-player-platform-interface
description: Implement a custom video_player platform plugin or mock VideoPlayerPlatform in unit tests using video_player_platform_interface.
---

# Using and Implementing `video_player_platform_interface`

[`video_player_platform_interface`](https://pub.dev/packages/video_player_platform_interface) defines the common platform interface (`VideoPlayerPlatform`) for the [`video_player`](https://pub.dev/packages/video_player) plugin and all platform-specific implementations (`video_player_android`, `video_player_avfoundation`, `video_player_web`).

## 1. Installation and `pubspec.yaml` Setup

To create a new platform implementation of `video_player` or mock `VideoPlayerPlatform` in tests, add `video_player_platform_interface` to your `pubspec.yaml`:

```yaml
dependencies:
  video_player_platform_interface: ^6.9.0
```

For unit testing an app that uses `video_player`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  plugin_platform_interface: ^2.1.7
  video_player_platform_interface: ^6.9.0
```

## 2. Platform-Specific Configuration

`video_player_platform_interface` is a pure Dart/Flutter package containing the `VideoPlayerPlatform` base class, `DataSource`, `VideoEvent`, `VideoPlayerOptions`, and `DurationRange` types. It requires no native platform configuration (`Info.plist`, `AndroidManifest.xml`, etc.).

**Design Note on Breaking Changes**: Platform implementations must **extend** (`extends VideoPlayerPlatform`) rather than **implement** (`implements VideoPlayerPlatform`). Extending `VideoPlayerPlatform` ensures subclasses inherit default `UnimplementedError` fallbacks for newly added methods without breaking existing implementations.

## 3. Usage and API Examples

### Implementing a Custom Platform Plugin

To implement a new platform plugin for `video_player`, extend `VideoPlayerPlatform` and register your class via `VideoPlayerPlatform.instance`:

```dart
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class MyCustomVideoPlayerPlatform extends VideoPlayerPlatform {
  /// Registers this class as the default instance of [VideoPlayerPlatform].
  static void registerWith() {
    VideoPlayerPlatform.instance = MyCustomVideoPlayerPlatform();
  }

  @override
  Future<void> init() async {
    // Initialize global native video player resources.
  }

  @override
  Future<int?> create(DataSource dataSource) async {
    const int textureId = 1;
    // Create native player for dataSource (asset, network, file, or contentUri).
    return textureId;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    // Emit VideoEvent(eventType: VideoEventType.initialized, duration: ..., size: ...)
    return const Stream<VideoEvent>.empty();
  }

  @override
  Future<void> play(int textureId) async {}

  @override
  Future<void> pause(int textureId) async {}

  @override
  Future<void> seekTo(int textureId, Duration position) async {}

  @override
  Future<void> setVolume(int textureId, double volume) async {}

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {}

  @override
  Future<void> setLooping(int textureId, bool looping) async {}

  @override
  Future<Duration> getPosition(int textureId) async => Duration.zero;

  @override
  Widget buildView(int textureId) {
    return Texture(textureId: textureId);
  }

  @override
  Future<void> dispose(int textureId) async {
    // Dispose native player for textureId.
  }
}
```

### Mocking `VideoPlayerPlatform` in Widget and Unit Tests

To test widgets that use `VideoPlayerController` without running native platform channels, create a fake implementation that extends `VideoPlayerPlatform` (or mixes in `MockPlatformInterfaceMixin`):

```dart
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class FakeVideoPlayerPlatform extends VideoPlayerPlatform
    with MockPlatformInterfaceMixin {
  final Map<int, StreamController<VideoEvent>> _streams =
      <int, StreamController<VideoEvent>>{};

  @override
  Future<void> init() async {}

  @override
  Future<int?> create(DataSource dataSource) async {
    const int playerId = 1;
    final StreamController<VideoEvent> controller =
        StreamController<VideoEvent>();
    _streams[playerId] = controller;

    controller.add(
      VideoEvent(
        eventType: VideoEventType.initialized,
        duration: const Duration(seconds: 30),
        size: const Size(1920, 1080),
      ),
    );
    return playerId;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) {
    return _streams[playerId]!.stream;
  }

  @override
  Future<void> play(int playerId) async {}

  @override
  Future<void> pause(int playerId) async {}

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<void> seekTo(int playerId, Duration position) async {}

  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;

  @override
  Widget buildView(int playerId) => const SizedBox();

  @override
  Future<void> dispose(int playerId) async {
    await _streams[playerId]?.close();
  }
}

void main() {
  test('FakeVideoPlayerPlatform initializes player', () async {
    VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();
    final int? id = await VideoPlayerPlatform.instance.create(
      DataSource(
        sourceType: DataSourceType.network,
        uri: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      ),
    );
    expect(id, 1);
  });
}
```
