---
name: video-player-web-setup-and-usage
description: Set up and use video_player_web, the endorsed Web implementation of Flutter's video_player plugin, including browser autoplay rules, HTTP range requests for seeking, and supported video codecs.
---

# Setting Up and Using `video_player_web`

[`video_player_web`](https://pub.dev/packages/video_player_web) is the endorsed Web platform implementation of the Flutter [`video_player`](https://pub.dev/packages/video_player) plugin, rendering HTML5 `<video>` elements in Flutter Web apps.

## 1. Installation and `pubspec.yaml` Setup

### Endorsed Usage (Recommended)

Because `video_player_web` is endorsed by `video_player`, adding `video_player` to your `pubspec.yaml` automatically includes Web support:

```yaml
dependencies:
  video_player: ^2.14.0
```

### Direct Dependency Usage

If you need to depend on `video_player_web` directly to constrain its version or register `VideoPlayerPlugin` explicitly:

```yaml
dependencies:
  video_player: ^2.14.0
  video_player_web: ^2.4.0
```

## 2. Platform-Specific Configuration and Web Limitations

### Browser Autoplay Policy

Modern browsers block unmuted video autoplay without prior user interaction ("user activation") on the webpage. Calling `_controller.play()` automatically on page load with audio enabled will throw a JavaScript runtime error.
- **Workaround for Autoplay**: Mute the video before playing (`await _controller.setVolume(0.0); await _controller.play();`), or trigger `_controller.play()` inside a button press (`onPressed`) callback.

### Seeking and HTTP Range Requests

If calling `_controller.seekTo(...)` causes the video to restart from `0:00`, the server hosting the video does not support **HTTP Range Requests** (`Accept-Ranges: bytes`).
- **Note on `flutter run` Debug Server**: Flutter Web's local development server does **not** support HTTP range requests. Seeking in local video assets during `flutter run -d chrome` will restart the video until the entire asset is cached by the browser. Production servers (CDNs, S3, Nginx, etc.) should have HTTP range requests enabled.

### Unsupported Features on Web

1. **`dart:io` File Constructor**: `VideoPlayerController.file(...)` throws an `UnimplementedError` on Web. Use `VideoPlayerController.networkUrl(...)` (supports `https://` and browser `blob:` URLs) or `VideoPlayerController.asset(...)`.
2. **Audio Mixing**: `VideoPlayerOptions(mixWithOthers: true)` cannot be implemented in web browsers and is silently ignored.
3. **Browser Codec Support**: Video format compatibility depends on the user's browser (e.g., H.264/MP4 and WebM are broadly supported across Chrome, Firefox, Edge, and Safari).

## 3. Usage and API Examples

### Muted Autoplay and User-Triggered Unmute on Web

To safely autoplay a video on Web without violating browser autoplay policies, set the volume to `0.0` before calling `play()`, and provide a button for the user to unmute:

```dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class WebAutoplayVideo extends StatefulWidget {
  const WebAutoplayVideo({super.key, required this.videoUrl});

  final Uri videoUrl;

  @override
  State<WebAutoplayVideo> createState() => _WebAutoplayVideoState();
}

class _WebAutoplayVideoState extends State<WebAutoplayVideo> {
  late VideoPlayerController _controller;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(widget.videoUrl);
    _initializeAndAutoplay();
  }

  Future<void> _initializeAndAutoplay() async {
    await _controller.initialize();
    await _controller.setLooping(true);
    // Mute before playing to satisfy browser autoplay restrictions.
    await _controller.setVolume(0.0);
    await _controller.play();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleMute() async {
    final bool nextMuted = !_isMuted;
    await _controller.setVolume(nextMuted ? 0.0 : 1.0);
    setState(() {
      _isMuted = nextMuted;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: IconButton(
            onPressed: _toggleMute,
            icon: Icon(
              _isMuted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
```
