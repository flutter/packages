---
name: interactive-media-ads
description: Set up and use the interactive_media_ads plugin to integrate Google IMA SDK video ads (VAST/VMAP pre-, mid-, and post-rolls) on Android and iOS.
---

# Setting Up and Using interactive_media_ads

The `interactive_media_ads` plugin integrates the Google Interactive Media Ads (IMA) client-side SDKs on Android (SDK 24+) and iOS (13.0+). It enables requesting ads from VAST-compliant ad servers, rendering video ads over your content player, and handling playback events.

## 1. Installation

Add `interactive_media_ads` and a content video player (such as `video_player`) to your `pubspec.yaml`:

```bash
flutter pub add interactive_media_ads video_player
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  interactive_media_ads: ^0.3.0+17
  video_player: ^2.9.0
```

## 2. Android and iOS Platform Configuration

### Android Manifest Permissions
Add `INTERNET` and `ACCESS_NETWORK_STATE` permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    ...
</manifest>
```

### Android Core Library Desugaring
Enable core library desugaring in `android/app/build.gradle.kts`:

```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
```

## 3. Usage and API Examples

### Integrating `AdDisplayContainer` and `AdsLoader` with a Content Video Player

The IMA SDK uses five primary classes:
- `AdDisplayContainer`: Widget where video ads are rendered. Must remain in the widget tree.
- `AdsLoader`: Requests ads using an `AdsRequest`.
- `AdsManager`: Controls ad playback (`init`, `start`, `pause`, `resume`, `destroy`).
- `AdsManagerDelegate`: Handles `AdEvent`s (`loaded`, `contentPauseRequested`, `contentResumeRequested`, `allAdsCompleted`) and `AdErrorEvent`s.
- `ContentProgressProvider`: Reports content playback progress to trigger mid-roll ads.

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:video_player/video_player.dart';

class VideoAdPlayerWidget extends StatefulWidget {
  const VideoAdPlayerWidget({super.key});

  @override
  State<VideoAdPlayerWidget> createState() => _VideoAdPlayerWidgetState();
}

class _VideoAdPlayerWidgetState extends State<VideoAdPlayerWidget> {
  static const String _sampleAdTagUrl =
      'https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_ad_samples&sz=640x480&cust_params=sample_ct%3Dlinear&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator=';

  late final AdsLoader _adsLoader;
  AdsManager? _adsManager;
  bool _showContentVideo = false;
  late final VideoPlayerController _contentController;
  final ContentProgressProvider _progressProvider = ContentProgressProvider();
  Timer? _progressTimer;

  late final AdDisplayContainer _adDisplayContainer = AdDisplayContainer(
    onContainerAdded: (AdDisplayContainer container) {
      _adsLoader = AdsLoader(
        container: container,
        onAdsLoaded: (OnAdsLoadedData data) {
          final AdsManager manager = data.manager;
          _adsManager = manager;
          manager.setAdsManagerDelegate(
            AdsManagerDelegate(
              onAdEvent: (AdEvent event) {
                switch (event.type) {
                  case AdEventType.loaded:
                    manager.start();
                  case AdEventType.contentPauseRequested:
                    _pauseContent();
                  case AdEventType.contentResumeRequested:
                    _resumeContent();
                  case AdEventType.allAdsCompleted:
                    manager.destroy();
                    _adsManager = null;
                  case _:
                    break;
                }
              },
              onAdErrorEvent: (AdErrorEvent event) {
                debugPrint('AdError: ${event.error.message}');
                _resumeContent();
              },
            ),
          );
          manager.init(settings: AdsRenderingSettings(enablePreloading: true));
        },
        onAdsLoadError: (AdsLoadErrorData data) {
          debugPrint('AdsLoadError: ${data.error.message}');
          _resumeContent();
        },
      );

      _adsLoader.requestAds(
        AdsRequest(
          adTagUrl: _sampleAdTagUrl,
          contentProgressProvider: _progressProvider,
        ),
      );
    },
  );

  @override
  void initState() {
    super.initState();
    _contentController = VideoPlayerController.networkUrl(
      Uri.parse('https://storage.googleapis.com/gvabox/media/samples/stock.mp4'),
    )
      ..addListener(() {
        if (_contentController.value.isCompleted) {
          _adsLoader.contentComplete();
        }
        if (mounted) {
          setState(() {});
        }
      })
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
  }

  Future<void> _resumeContent() async {
    setState(() => _showContentVideo = true);
    _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (_) async {
      if (_contentController.value.isInitialized) {
        final Duration? position = await _contentController.position;
        if (position != null) {
          await _progressProvider.setProgress(
            progress: position,
            duration: _contentController.value.duration,
          );
        }
      }
    });
    await _contentController.play();
  }

  Future<void> _pauseContent() {
    setState(() => _showContentVideo = false);
    _progressTimer?.cancel();
    _progressTimer = null;
    return _contentController.pause();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _contentController.dispose();
    _adsManager?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: <Widget>[
          _adDisplayContainer,
          if (_showContentVideo && _contentController.value.isInitialized)
            VideoPlayer(_contentController),
        ],
      ),
    );
  }
}
```
