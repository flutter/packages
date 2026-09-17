---
name: video-player-android-setup-and-usage
description: Set up and use video_player_android, the endorsed Android implementation of Flutter's video_player plugin powered by Jetpack Media3 ExoPlayer.
---

# Setting Up and Using `video_player_android`

[`video_player_android`](https://pub.dev/packages/video_player_android) is the endorsed Android platform implementation of the Flutter [`video_player`](https://pub.dev/packages/video_player) plugin, powered by Android's Media3 / ExoPlayer library.

## 1. Installation and `pubspec.yaml` Setup

### Endorsed Usage (Recommended)

Because `video_player_android` is endorsed by `video_player`, adding `video_player` to your `pubspec.yaml` automatically includes Android support:

```yaml
dependencies:
  video_player: ^2.14.0
```

### Direct Dependency Usage

If you need to depend on `video_player_android` directly (for example, to pin a specific version or register `AndroidVideoPlayer` manually):

```yaml
dependencies:
  video_player: ^2.14.0
  video_player_android: ^2.12.2
```

## 2. Platform-Specific Configuration

### Android Minimum SDK (`android/app/build.gradle`)

Ensure your Android app targets `minSdkVersion 24` or higher:

```groovy
android {
    defaultConfig {
        minSdkVersion 24
        compileSdkVersion 35
    }
}
```

### Network Permissions (`AndroidManifest.xml`)

When playing videos from network URLs (`VideoPlayerController.networkUrl`), ensure your `android/app/src/main/AndroidManifest.xml` includes the `INTERNET` permission:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <application ...>
    </application>
</manifest>
```

### Known Issue: `VideoViewType.platformView` on Android

Avoid passing `viewType: VideoViewType.platformView` to `VideoPlayerController` on Android unless strictly necessary. Using `VideoViewType.platformView` on Android is currently not recommended due to known rendering and synchronization issues with Android platform views (see [Flutter issue #164899](https://github.com/flutter/flutter/issues/164899)). Use the default texture-based rendering (`VideoViewType.textureView`) instead.

## 3. Usage and API Examples

### Standard App Usage via `package:video_player`

In application code, interact with the ExoPlayer-backed implementation through `VideoPlayerController`:

```dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AndroidVideoDemo extends StatefulWidget {
  const AndroidVideoDemo({super.key});

  @override
  State<AndroidVideoDemo> createState() => _AndroidVideoDemoState();
}

class _AndroidVideoDemoState extends State<AndroidVideoDemo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Uses VideoViewType.textureView by default (recommended on Android).
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
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

If you are registering or testing the Android implementation directly against `VideoPlayerPlatform`:

```dart
import 'package:video_player_android/video_player_android.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void registerAndroidVideoPlayer() {
  AndroidVideoPlayer.registerWith();
  // Or explicitly set:
  VideoPlayerPlatform.instance = AndroidVideoPlayer();
}
```
