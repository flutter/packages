<?code-excerpt path-base="example/lib"?>

# Video Player plugin for Flutter

[![pub package](https://img.shields.io/pub/v/video_player.svg)](https://pub.dev/packages/video_player)

A Flutter plugin for iOS, Android and Web for playing back video on a Widget surface.

|             | Android | iOS   | macOS  | Web   |
|-------------|---------|-------|--------|-------|
| **Support** | SDK 24+ | 13.0+ | 10.15+ | Any\* |

![The example app running in iOS](https://github.com/flutter/packages/blob/main/packages/video_player/video_player/doc/demo_ipod.gif?raw=true)

## Setup

### iOS

If you need to access videos using `http` (rather than `https`) URLs, you will need to add
the appropriate `NSAppTransportSecurity` permissions to your app's _Info.plist_ file, located
in `<project root>/ios/Runner/Info.plist`. See
[Apple's documentation](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity)
to determine the right combination of entries for your use case and supported iOS versions.

### Android

If you are using network-based videos, ensure that the following permission is present in your
Android Manifest file, located in `<project root>/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### macOS

If you are using network-based videos, you will need to [add the
`com.apple.security.network.client`
entitlement](https://flutter.dev/to/macos-entitlements)

### Web

> The Web platform does **not** support `dart:io`, so avoid using the `VideoPlayerController.file` constructor for the plugin. Using the constructor attempts to create a `VideoPlayerController.file` that will throw an `UnimplementedError`.

\* Different web browsers may have different video-playback capabilities (supported formats, autoplay...). Check [package:video_player_web](https://pub.dev/packages/video_player_web) for more web-specific information.

The `VideoPlayerOptions.mixWithOthers` option can't be implemented in web, at least at the moment. If you use this option in web it will be silently ignored.

## Supported Formats

- On iOS and macOS, the backing player is [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer).
  The supported formats vary depending on the version of iOS, [AVURLAsset](https://developer.apple.com/documentation/avfoundation/avurlasset) class
  has [audiovisualTypes](https://developer.apple.com/documentation/avfoundation/avurlasset/1386800-audiovisualtypes?language=objc) that you can query for supported av formats.
- On Android, the backing player is [ExoPlayer](https://google.github.io/ExoPlayer/),
  please refer [here](https://google.github.io/ExoPlayer/supported-formats.html) for list of supported formats.
- On Web, available formats depend on your users' browsers (vendor and version). Check [package:video_player_web](https://pub.dev/packages/video_player_web) for more specific information.

## Example

<?code-excerpt "basic.dart (basic-example)"?>
```dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const VideoApp());

/// Stateful widget to fetch and then display video content.
class VideoApp extends StatefulWidget {
  const VideoApp({super.key});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(
            Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
          )
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying ? _controller.pause() : _controller.play();
            });
          },
          child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

```

## Usage

The following section contains usage information that goes beyond what is included in the
documentation in order to give a more elaborate overview of the API.

This is not complete as of now. You can contribute to this section by [opening a pull request](https://github.com/flutter/packages/pulls).

### Playback speed

You can set the playback speed on your `_controller` (instance of `VideoPlayerController`) by
calling `_controller.setPlaybackSpeed`. `setPlaybackSpeed` takes a `double` speed value indicating
the rate of playback for your video.
For example, when given a value of `2.0`, your video will play at 2x the regular playback speed
and so on.

To learn about playback speed limitations, see the [`setPlaybackSpeed` method documentation](https://pub.dev/documentation/video_player/latest/video_player/VideoPlayerController/setPlaybackSpeed.html).

Furthermore, see the example app for an example playback speed implementation.

### Video view type

You can set the video view type of your controller (instance of `VideoPlayerController`) during its creation by passing the `videoViewType` argument.  
If set to `VideoViewType.platformView`, platform views will be used instead of texture view on supported platforms.

The relative performance of the different view types may vary by platform, and on some platforms the use of platform views may have correctness issues in certain circumstances due to limitations of Flutter's platform view system.

### DRM

Network sources can play DRM-protected content by passing a `drmConfiguration`
to `VideoPlayerController.networkUrl`. DRM systems differ significantly between
platforms, so the configuration types come from the platform implementation
packages rather than from `video_player`:

| Platform | DRM system | Configuration | Package |
| --- | --- | --- | --- |
| Android | Widevine | `WidevineDrmConfiguration` | [`video_player_android`](https://pub.dev/packages/video_player_android) |
| iOS, macOS | FairPlay | `FairPlayDrmConfiguration` | [`video_player_avfoundation`](https://pub.dev/packages/video_player_avfoundation) |

An app that uses DRM therefore depends on those packages directly, and imports
the configuration type it needs:

<?code-excerpt "readme_excerpts.dart (widevine)"?>
```dart
import 'package:video_player_android/video_player_android.dart';
// ···
  final controller = VideoPlayerController.networkUrl(
    Uri.parse('https://example.com/protected.mpd'),
    drmConfiguration: WidevineDrmConfiguration(
      licenseUri: Uri.parse('https://example.com/license'),
      licenseHeaders: const <String, String>{'Authorization': 'Bearer ...'},
    ),
    viewType: VideoViewType.platformView,
  );
  await controller.initialize();
  await controller.play();
```

FairPlay additionally needs the URL of the application certificate, and
optionally a content ID to use when generating the SPC (by default the content
ID is derived from the `skd://` key URL in the HLS manifest):

<?code-excerpt "readme_excerpts.dart (fairplay)"?>
```dart
import 'package:video_player_avfoundation/video_player_avfoundation.dart';
// ···
  final controller = VideoPlayerController.networkUrl(
    Uri.parse('https://example.com/protected.m3u8'),
    drmConfiguration: FairPlayDrmConfiguration(
      certificateUri: Uri.parse('https://example.com/certificate'),
      licenseUri: Uri.parse('https://example.com/license'),
      licenseHeaders: const <String, String>{'Authorization': 'Bearer ...'},
    ),
    viewType: VideoViewType.platformView,
  );
```

Passing a configuration that the current platform doesn't support — Widevine on
iOS, for example — throws an `ArgumentError` from `initialize`, so apps that
support both platforms should pick the configuration based on the platform they
are running on. See the DRM demo in the example app for one way to do that.

#### Limitations

- DRM is only supported for network sources. There is no support for DRM with
  asset, file, or content URI sources, and no support for offline or persistent
  licenses.
- DRM-protected video currently only renders in
  `VideoViewType.platformView`. In texture view mode the audio plays but the
  video frames are not displayed, because protected frames can't be copied into
  the texture used for Flutter rendering.
- On Android, license exchange is performed by Media3 from the license URL and
  headers, so provider setups that need behavior outside Media3's standard DRM
  configuration are not supported.
- On iOS and macOS, only the standard FairPlay exchange is supported: the SPC is
  POSTed as an `application/octet-stream` body, and the response body is used as
  the CKC as-is. Providers that wrap the SPC in JSON, base64-encode the CKC, or
  require request signing performed at request time are not supported.
- Only one DRM system can be configured per source; there is no multi-DRM
  negotiation.
- The Web implementation does not support DRM.
