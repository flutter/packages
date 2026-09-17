---
name: video-player-setup-and-usage
description: Set up and use the Flutter video_player plugin to play network, asset, and file videos inline on Android, iOS, macOS, and Web.
---

# Setting Up and Using the Flutter Video Player Plugin

The [`video_player`](https://pub.dev/packages/video_player) plugin enables inline video playback in Flutter widgets across Android (`ExoPlayer`), iOS/macOS (`AVPlayer`), and Web (`HTMLVideoElement`).

## 1. Installation and `pubspec.yaml` Setup

Add `video_player` to your project's `pubspec.yaml`:

```yaml
dependencies:
  video_player: ^2.14.0
```

Or run:

```sh
flutter pub add video_player
```

## 2. Platform-Specific Configuration

### Android (`AndroidManifest.xml` & `build.gradle`)

1. **Minimum SDK Version**: Requires `minSdkVersion 24` or higher in `android/app/build.gradle`.
2. **Internet Permission**: For streaming network videos (`VideoPlayerController.networkUrl`), declare the `INTERNET` permission in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### iOS (`Info.plist`)

The minimum supported version is **iOS 13.0+**.
If your application streams videos over insecure `http://` URLs instead of `https://`, configure `NSAppTransportSecurity` in `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

### macOS (`*.entitlements`)

The minimum supported version is **macOS 10.15+**.
To play network-hosted videos on macOS, add the network client entitlement to both `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

### Web Configuration and Limitations

- **No `dart:io` Support**: `VideoPlayerController.file` throws an `UnimplementedError` on Web. Use `VideoPlayerController.networkUrl` (including `blob:` URLs) or `VideoPlayerController.asset`.
- **Audio Mixing**: `VideoPlayerOptions(mixWithOthers: true)` is not supported on Web and is silently ignored.
- **Autoplay Policies**: Web browsers block autoplay with audio unless initiated by user interaction or muted (`_controller.setVolume(0.0)`).

## 3. Usage and API Examples

### Playing a Network Video with Controls and Aspect Ratio

Always initialize `VideoPlayerController` in `initState()`, wrap the `VideoPlayer` widget in an `AspectRatio` using `_controller.value.aspectRatio`, and call `_controller.dispose()` in `dispose()`.

```dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const VideoPlayerDemoApp());

class VideoPlayerDemoApp extends StatelessWidget {
  const VideoPlayerDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      ),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // Ensure the first frame is shown once initialized.
      if (mounted) {
        setState(() {});
      }
    });

    _controller.setLooping(true);
  }

  Future<void> _setSpeed(double speed) async {
    await _controller.setPlaybackSpeed(speed);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player Example'),
        actions: <Widget>[
          PopupMenuButton<double>(
            initialValue: _controller.value.playbackSpeed,
            onSelected: _setSpeed,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<double>>[
              const PopupMenuItem<double>(value: 0.5, child: Text('0.5x')),
              const PopupMenuItem<double>(value: 1.0, child: Text('1.0x')),
              const PopupMenuItem<double>(value: 1.5, child: Text('1.5x')),
              const PopupMenuItem<double>(value: 2.0, child: Text('2.0x')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeVideoPlayerFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    VideoPlayer(_controller),
                    VideoProgressIndicator(_controller, allowScrubbing: true),
                  ],
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
```
