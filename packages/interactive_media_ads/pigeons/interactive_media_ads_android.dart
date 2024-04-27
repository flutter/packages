// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/android/interactive_media_ads.g.dart',
    dartOptions: DartOptions(copyrightHeader: <String>[
      'Copyright 2013 The Flutter Authors. All rights reserved.',
      'Use of this source code is governed by a BSD-style license that can be',
      'found in the LICENSE file.',
    ]),
    kotlinOut:
        'android/src/main/kotlin/dev/flutter/packages/interactive_media_ads/GeneratedInteractiveMediaAdsLibrary.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.flutter.packages.interactive_media_ads',
    ),
  ),
)

/// A base class for more specialized container interfaces.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/BaseDisplayContainer.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.BaseDisplayContainer',
  ),
)
abstract class BaseDisplayContainer {}

/// A container in which to display the ads.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdDisplayContainer.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.AdDisplayContainer',
  ),
)
abstract class AdDisplayContainer implements BaseDisplayContainer {}

/// An object which allows publishers to request ads from ad servers or a
/// dynamic ad insertion stream.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdsLoader.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.AdsLoader',
  ),
)
abstract class AdsLoader {}

/// An object containing the data used to request ads from the server.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdsRequest.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.AdsRequest',
  ),
)
abstract class AdsRequest {}

/// An object which handles playing ads after they've been received from the
/// server.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdsManager.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.AdsManager',
  ),
)
abstract class AdsManager {}

/// Factory class for creating SDK objects.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/ImaSdkFactory.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.ImaSdkFactory',
  ),
)
abstract class ImaSdkFactory {
  @static
  AdDisplayContainer createAdDisplayContainer(
    ViewGroup container,
    VideoAdPlayer player,
  );
}

/// Defines the set of methods that a video player must implement to be used by
/// the IMA SDK, as well as a set of callbacks that it must fire.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/player/VideoAdPlayer.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.player.VideoAdPlayer',
  ),
)
abstract class VideoAdPlayer {
  VideoAdPlayer();

  /// Adds a callback.
  late final void Function(VideoAdPlayerCallback callback) addCallback;

  /// Loads a video ad hosted at AdMediaInfo.
  late final void Function(AdMediaInfo adMediaInfo, AdPodInfo adPodInfo) loadAd;

  /// Pauses playing the current ad.
  late final void Function(AdMediaInfo adMediaInfo) pauseAd;

  /// Starts or resumes playing the video ad referenced by the AdMediaInfo,
  /// provided loadAd has already been called for it.
  late final void Function(AdMediaInfo adMediaInfo) playAd;

  /// Cleans up and releases all resources used by the `VideoAdPlayer`.
  late final void Function() release;

  /// Removes a callback.
  late final void Function(VideoAdPlayerCallback callback) removeCallback;

  /// Stops playing the current ad.
  late final void Function(AdMediaInfo adMediaInfo) stopAd;

  /// The volume of the player as a percentage from 0 to 100.
  void setVolume(int value);

  /// The `VideoProgressUpdate` describing playback progress of the current
  /// video.
  void setAdProgress(VideoProgressUpdate progress);
}

/// Defines an update to the video's progress.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/player/VideoProgressUpdate.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.player.VideoProgressUpdate',
  ),
)
abstract class VideoProgressUpdate {
  VideoProgressUpdate(int currentTimeMs, int durationMs);

  /// Value to use for cases when progress is not yet defined, such as video
  /// initialization.
  @static
  @attached
  late final VideoProgressUpdate videoTimeNotReady;
}

/// Callbacks that the player must fire.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/player/VideoAdPlayer.VideoAdPlayerCallback.html
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.player.VideoAdPlayer.VideoAdPlayerCallback',
  ),
)
abstract class VideoAdPlayerCallback {
  /// Fire this callback periodically as ad playback occurs.
  void onAdProgress(
    AdMediaInfo adMediaInfo,
    VideoProgressUpdate videoProgressUpdate,
  );

  /// Fire this callback when video playback stalls waiting for data.
  void onBuffering(AdMediaInfo adMediaInfo);

  /// Fire this callback when all content has finished playing.
  void onContentComplete();

  /// Fire this callback when the video finishes playing.
  void onEnded(AdMediaInfo adMediaInfo);

  /// Fire this callback when the video has encountered an error.
  void onError(AdMediaInfo adMediaInfo);

  /// Fire this callback when the video is ready to begin playback.
  void onLoaded(AdMediaInfo adMediaInfo);

  /// Fire this callback when the video is paused.
  void onPause(AdMediaInfo adMediaInfo);

  /// Fire this callback when the player begins playing a video.
  void onPlay(AdMediaInfo adMediaInfo);

  /// Fire this callback when the video is unpaused.
  void onResume(AdMediaInfo adMediaInfo);

  /// Fire this callback when the playback volume changes.
  void onVolumeChanged(AdMediaInfo adMediaInfo, int percentage);
}

/// The minimal information required to play an ad.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/player/AdMediaInfo.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.player.AdMediaInfo',
  ),
)
abstract class AdMediaInfo {
  late final String url;
}

/// An ad may be part of a pod of ads.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdPodInfo.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.AdPodInfo',
  ),
)
abstract class AdPodInfo {
  /// The position of the ad within the pod.
  ///
  /// The value returned is one-based, for example, 1 of 2, 2 of 2, etc. If the
  /// ad is not part of a pod, this will return 1.
  late final int adPosition;

  /// The maximum duration of the pod in seconds.
  ///
  /// For unknown duration, -1 is returned.
  late final double maxDuration;

  /// Client side and DAI VOD: Returns the index of the ad pod.
  late final int podIndex;

  /// The content time offset at which the current ad pod was scheduled.
  ///
  /// For preroll pod, 0 is returned. For midrolls, the scheduled time is
  /// returned in seconds. For postroll, -1 is returned. Defaults to 0 if this
  /// ad is not part of a pod, or the pod is not part of an ad playlist.
  late final double timeOffset;

  /// The total number of ads contained within this pod, including bumpers.
  late final int totalAds;

  /// Returns true if the ad is a bumper ad.
  late final bool isBumper;
}

/// FrameLayout is designed to block out an area on the screen to display a
/// single item.
///
/// See https://developer.android.com/reference/android/widget/FrameLayout.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.widget.FrameLayout',
  ),
)
abstract class FrameLayout extends ViewGroup {
  FrameLayout();
}

/// A special view that can contain other views (called children.)
///
/// See https://developer.android.com/reference/android/view/ViewGroup.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.view.ViewGroup',
  ),
)
abstract class ViewGroup extends View {
  void addView(View view);
}

/// Displays a video file.
///
/// See https://developer.android.com/reference/android/widget/VideoView.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.widget.VideoView',
  ),
)
abstract class VideoView extends View {
  VideoView();

  /// Callback to be invoked when the media source is ready for playback.
  late final void Function(MediaPlayer player)? onPrepared;

  /// Callback to be invoked when playback of a media source has completed.
  late final void Function(MediaPlayer player)? onCompletion;

  /// Callback to be invoked when there has been an error during an asynchronous
  /// operation.
  late final void Function(MediaPlayer player, int what, int extra) onError;

  /// Sets the URI of the video.
  void setVideoUri(String uri);

  /// The current position of the playing video.
  ///
  /// In milliseconds.
  int getCurrentPosition();
}

/// This class represents the basic building block for user interface components.
///
/// See https://developer.android.com/reference/android/view/View.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(fullClassName: 'android.view.View'),
)
abstract class View {}

/// MediaPlayer class can be used to control playback of audio/video files and
/// streams.
///
/// See https://developer.android.com/reference/android/media/MediaPlayer.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.media.MediaPlayer',
  ),
)
abstract class MediaPlayer {
  /// Gets the duration of the file.
  int getDuration();

  /// Seeks to specified time position.
  void seekTo(int mSec);

  /// Starts or resumes playback.
  void start();

  /// Pauses playback.
  void pause();

  /// Stops playback after playback has been started or paused.
  void stop();
}
