---
name: video-player-avfoundation-setup-and-usage
description: Set up and use video_player_avfoundation, the endorsed iOS and macOS implementation of Flutter's video_player plugin built on Apple's AVPlayer.
---

# Setting Up and Using `video_player_avfoundation`

[`video_player_avfoundation`](https://pub.dev/packages/video_player_avfoundation) is the endorsed iOS and macOS platform implementation of the Flutter [`video_player`](https://pub.dev/packages/video_player) plugin, built using Apple's AVFoundation (`AVPlayer`) framework.

## 1. Installation and `pubspec.yaml` Setup

### Endorsed Usage (Recommended)

Because `video_player_avfoundation` is endorsed by `video_player` for both iOS and macOS, you only need to add `video_player` to your `pubspec.yaml`:

```yaml
dependencies:
  video_player: ^2.14.0
```

### Direct Dependency Usage

If you need to depend on `video_player_avfoundation` directly to pin a version or access platform-specific registration APIs:

```yaml
dependencies:
  video_player: ^2.14.0
  video_player_avfoundation: ^2.12.0
```

## 2. Platform-Specific Configuration

### iOS Configuration (`ios/Runner/Info.plist`)

- **Minimum Deployment Target**: **iOS 13.0+**.
- **HTTP Streaming (`NSAppTransportSecurity`)**: By default, iOS blocks cleartext `http://` URLs. To stream non-HTTPS videos, configure `NSAppTransportSecurity` in `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

### macOS Configuration (`macos/Runner/*.entitlements`)

- **Minimum Deployment Target**: **macOS 10.15+**.
- **Network Client Entitlement**: macOS apps are sandboxed by default. To stream network videos using `VideoPlayerController.networkUrl`, add the `com.apple.security.network.client` entitlement to both `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

## 3. Usage and API Examples

### Standard App Usage with Audio Mixing Options

On iOS and macOS, you can configure `VideoPlayerOptions(mixWithOthers: true)` so that video playback does not interrupt background audio from other apps:

```dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AppleVideoPlayerWidget extends StatefulWidget {
  const AppleVideoPlayerWidget({super.key, required this.videoUrl});

  final Uri videoUrl;

  @override
  State<AppleVideoPlayerWidget> createState() => _AppleVideoPlayerWidgetState();
}

class _AppleVideoPlayerWidgetState extends State<AppleVideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      widget.videoUrl,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
        allowBackgroundPlayback: false,
      ),
    )..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.play();
        }
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
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  }
}
```

### Direct Registration or Testing

To register or test `AVFoundationVideoPlayer` directly with `VideoPlayerPlatform`:

```dart
import 'package:video_player_avfoundation/video_player_avfoundation.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void registerDarwinVideoPlayer() {
  AVFoundationVideoPlayer.registerWith();
  // Or explicitly set:
  VideoPlayerPlatform.instance = AVFoundationVideoPlayer();
}
```
