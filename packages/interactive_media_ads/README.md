# interactive\_media\_ads

Flutter plugin for the [Interactive Media Ads SDKs][1].

[![pub package](https://img.shields.io/pub/v/interactive_media_ads.svg)](https://pub.dev/packages/interactive_media_ads)

IMA SDKs make it easy to integrate multimedia ads into your websites and apps. IMA SDKs can request
ads from any [VAST-compliant][2] ad server and manage ad playback in your apps. With IMA client-side
SDKs, you maintain control of content video playback, while the SDK handles ad playback. Ads play in
a separate video player positioned on top of the app's content video player.

|             | Android | iOS   |
|-------------|---------|-------|
| **Support** | SDK 21+ | 12.0+ |

**NOTE:**
* Companion ads, Background Audio ads and Google Dynamic Ad Insertion methods are currently not
  supported.

## IMA client-side overview

Implementing IMA client-side involves five main SDK components, which are demonstrated in this
guide:

* [AdDisplayContainer][3]: A container object where ads are rendered.
* [AdsLoader][4]: Requests ads and handles events from ads request responses. You should only
instantiate one ads loader, which can be reused throughout the life of the application.
* [AdsRequest][5]: An object that defines an ads request. Ads requests specify the URL for the VAST
ad tag, as well as additional parameters, such as ad dimensions.
* [AdsManager][6]: Contains the response to the ads request, controls ad playback,
and listens for ad events fired by the SDK.
* [AdsManagerDelegate][8]: Handles ad events and errors that occur during ad or stream
initialization and playback.

## Usage

This guide demonstrates how to integrate the IMA SDK into a new `Widget` using the [video_player][7]
plugin to display content.

### 1. Add Android Required Permissions

If building on Android, add the user permissions required by the IMA SDK for requesting ads in
`android/app/src/main/AndroidManifest.xml`.

<?code-excerpt "example/android/app/src/main/AndroidManifest.xml (android_manifest)"?>
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Required permissions for the IMA SDK -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

### 2. Add Imports

Add the import statements for the `interactive_media_ads` and [video_player][7]. Both plugins should
already be added to your `pubspec.yaml`.

<?code-excerpt "example/lib/readme_example.dart (imports)"?>
```dart
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:video_player/video_player.dart';
```

### 3. Create a New Widget

Create a new [StatefulWidget](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html)
that handles displaying Ads and playing content.

<?code-excerpt "example/lib/readme_example.dart (example_widget)"?>
```dart
/// Example widget displaying an Ad before a video.
class AdExampleWidget extends StatefulWidget {
  /// Constructs an [AdExampleWidget].
  const AdExampleWidget({super.key});

  @override
  State<AdExampleWidget> createState() => _AdExampleWidgetState();
}

class _AdExampleWidgetState extends State<AdExampleWidget>
    with WidgetsBindingObserver {
  // IMA sample tag for a pre-, mid-, and post-roll, single inline video ad. See more IMA sample
  // tags at https://developers.google.com/interactive-media-ads/docs/sdks/html5/client-side/tags
  static const String _adTagUrl =
      'https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/vmap_ad_samples&sz=640x480&cust_params=sample_ar%3Dpremidpost&ciu_szs=300x250&gdfp_req=1&ad_rule=1&output=vmap&unviewed_position_start=1&env=vp&impl=s&cmsid=496&vid=short_onecue&correlator=';

  // The AdsLoader instance exposes the request ads method.
  late final AdsLoader _adsLoader;

  // AdsManager exposes methods to control ad playback and listen to ad events.
  AdsManager? _adsManager;

  // ···
  // Whether the widget should be displaying the content video. The content
  // player is hidden while Ads are playing.
  bool _shouldShowContentVideo = false;

  // Controls the content video player.
  late final VideoPlayerController _contentVideoController;

  // Periodically updates the SDK of the current playback progress of the
  // content video.
  Timer? _contentProgressTimer;

  // Provides the SDK with the current playback progress of the content video.
  // This is required to support mid-roll ads.
  final ContentProgressProvider _contentProgressProvider =
      ContentProgressProvider();
  // ···
  @override
  Widget build(BuildContext context) {
    // ···
  }
}
```

### 4. Add the Video Players

Instantiate the [AdDisplayContainer][3] for playing Ads and the
[VideoPlayerController](https://pub.dev/documentation/video_player/latest/video_player/VideoPlayerController-class.html)
for playing content.

<?code-excerpt "example/lib/readme_example.dart (ad_and_content_players)"?>
```dart
late final AdDisplayContainer _adDisplayContainer = AdDisplayContainer(
  onContainerAdded: (AdDisplayContainer container) {
    _adsLoader = AdsLoader(
      container: container,
      onAdsLoaded: (OnAdsLoadedData data) {
        final AdsManager manager = data.manager;
        _adsManager = data.manager;

        manager.setAdsManagerDelegate(AdsManagerDelegate(
          onAdEvent: (AdEvent event) {
            debugPrint('OnAdEvent: ${event.type} => ${event.adData}');
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
              case AdEventType.clicked:
              case AdEventType.complete:
              case _:
            }
          },
          onAdErrorEvent: (AdErrorEvent event) {
            debugPrint('AdErrorEvent: ${event.error.message}');
            _resumeContent();
          },
        ));

        manager.init(settings: AdsRenderingSettings(enablePreloading: true));
      },
      onAdsLoadError: (AdsLoadErrorData data) {
        debugPrint('OnAdsLoadError: ${data.error.message}');
        _resumeContent();
      },
    );

    // Ads can't be requested until the `AdDisplayContainer` has been added to
    // the native View hierarchy.
    _requestAds(container);
  },
);

@override
void initState() {
  super.initState();
  // ···
  _contentVideoController = VideoPlayerController.networkUrl(
    Uri.parse(
      'https://storage.googleapis.com/gvabox/media/samples/stock.mp4',
    ),
  )
    ..addListener(() {
      if (_contentVideoController.value.isCompleted) {
        _adsLoader.contentComplete();
      }
      setState(() {});
    })
    ..initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });
}
```

### 5. Implement the `build` Method

Return a `Widget` that contains the ad player and the content player.

<?code-excerpt "example/lib/readme_example.dart (widget_build)"?>
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: SizedBox(
        width: 300,
        child: !_contentVideoController.value.isInitialized
            ? Container()
            : AspectRatio(
                aspectRatio: _contentVideoController.value.aspectRatio,
                child: Stack(
                  children: <Widget>[
                    // The display container must be on screen before any Ads can be
                    // loaded and can't be removed between ads. This handles clicks for
                    // ads.
                    _adDisplayContainer,
                    if (_shouldShowContentVideo)
                      VideoPlayer(_contentVideoController)
                  ],
                ),
              ),
      ),
    ),
    floatingActionButton:
        _contentVideoController.value.isInitialized && _shouldShowContentVideo
            ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _contentVideoController.value.isPlaying
                        ? _contentVideoController.pause()
                        : _contentVideoController.play();
                  });
                },
                child: Icon(
                  _contentVideoController.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              )
            : null,
  );
}
```

### 6. Request Ads

Handle requesting ads and add event listeners to handle when content should be displayed or hidden.

<?code-excerpt "example/lib/readme_example.dart (request_ads)"?>
```dart
Future<void> _requestAds(AdDisplayContainer container) {
  return _adsLoader.requestAds(AdsRequest(
    adTagUrl: _adTagUrl,
    contentProgressProvider: _contentProgressProvider,
  ));
}

Future<void> _resumeContent() async {
  setState(() {
    _shouldShowContentVideo = true;
  });

  if (_adsManager != null) {
    _contentProgressTimer = Timer.periodic(
      const Duration(milliseconds: 200),
      (Timer timer) async {
        if (_contentVideoController.value.isInitialized) {
          final Duration? progress = await _contentVideoController.position;
          if (progress != null) {
            await _contentProgressProvider.setProgress(
              progress: progress,
              duration: _contentVideoController.value.duration,
            );
          }
        }
      },
    );
  }

  await _contentVideoController.play();
}

Future<void> _pauseContent() {
  setState(() {
    _shouldShowContentVideo = false;
  });
  _contentProgressTimer?.cancel();
  _contentProgressTimer = null;
  return _contentVideoController.pause();
}
```

### 7. Dispose Resources

Dispose the content player and destroy the [AdsManager][6].

<?code-excerpt "example/lib/readme_example.dart (dispose)"?>
```dart
@override
void dispose() {
  super.dispose();
  _contentProgressTimer?.cancel();
  _contentVideoController.dispose();
  _adsManager?.destroy();
  // ···
}
```

That's it! You're now requesting and displaying ads with the IMA SDK. To learn about additional SDK
features, see the [API reference](https://pub.dev/documentation/interactive_media_ads/latest/).

## Contributing

For information on contributing to this plugin, see [`CONTRIBUTING.md`](CONTRIBUTING.md).

[1]: https://developers.google.com/interactive-media-ads
[2]: https://www.iab.com/guidelines/vast/
[3]: https://pub.dev/documentation/interactive_media_ads/latest/interactive_media_ads/AdDisplayContainer-class.html
[4]: https://pub.dev/documentation/interactive_media_ads/latest/interactive_media_ads/AdsLoader-class.html
[5]: https://pub.dev/documentation/interactive_media_ads/latest/interactive_media_ads/AdsRequest-class.html
[6]: https://pub.dev/documentation/interactive_media_ads/latest/interactive_media_ads/AdsManager-class.html
[7]: https://pub.dev/packages/video_player
[8]: https://pub.dev/documentation/interactive_media_ads/latest/interactive_media_ads/AdsManagerDelegate-class.html
