// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    copyrightHeader: 'pigeons/copyright.txt',
    dartOut: 'lib/src/android/interactive_media_ads.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dev/flutter/packages/interactive_media_ads/InteractiveMediaAdsLibrary.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.flutter.packages.interactive_media_ads',
    ),
  ),
)

/// The types of error that can be encountered.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdError.AdErrorCode.html.
enum AdErrorCode {
  /// Ads player was not provided.
  adsPlayerWasNotProvided,

  /// There was a problem requesting ads from the server.
  adsRequestNetworkError,

  /// A companion ad failed to load or render.
  companionAdLoadingFailed,

  /// There was a problem requesting ads from the server.
  failedToRequestAds,

  /// An error internal to the SDK occurred.
  internalError,

  /// Invalid arguments were provided to SDK methods.
  invalidArguments,

  /// An overlay ad failed to load.
  overlayAdLoadingFailed,

  /// An overlay ad failed to render.
  overlayAdPlayingFailed,

  /// Ads list was returned but ContentProgressProvider was not configured.
  playlistNoContentTracking,

  /// Ads loader sent ads loaded event when it was not expected.
  unexpectedAdsLoadedEvent,

  /// The ad response was not understood and cannot be parsed.
  unknownAdResponse,

  /// An unexpected error occurred and the cause is not known.
  unknownError,

  /// No assets were found in the VAST ad response.
  vastAssetNotFound,

  /// A VAST response containing a single `<VAST>` tag with no child tags.
  vastEmptyResponse,

  /// Assets were found in the VAST ad response for a linear ad, but none of
  /// them matched the video player's capabilities.
  vastLinearAssetMismatch,

  /// At least one VAST wrapper ad loaded successfully and a subsequent wrapper
  /// or inline ad load has timed out.
  vastLoadTimeout,

  /// The ad response was not recognized as a valid VAST ad.
  vastMalformedResponse,

  /// Failed to load media assets from a VAST response.
  vastMediaLoadTimeout,

  /// Assets were found in the VAST ad response for a nonlinear ad, but none of
  /// them matched the video player's capabilities.
  vastNonlinearAssetMismatch,

  /// No Ads VAST response after one or more wrappers.
  vastNoAdsAfterWrapper,

  /// The maximum number of VAST wrapper redirects has been reached.
  vastTooManyRedirects,

  /// Trafficking error.
  ///
  /// Video player received an ad type that it was not expecting and/or cannot
  /// display.
  vastTraffickingError,

  /// There was an error playing the video ad.
  videoPlayError,

  /// The error code is not recognized by this wrapper.
  unknown,
}

/// Specifies when the error was encountered, during either ad loading or playback.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdError.AdErrorType.html.
enum AdErrorType {
  /// Indicates that the error was encountered when the ad was being loaded.
  load,

  /// Indicates that the error was encountered after the ad loaded, during ad play.
  play,

  /// The error is not recognized by this wrapper.
  unknown,
}

/// Types of events that can occur during ad playback.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdEvent.AdEventType.html.
enum AdEventType {
  /// Fired when an ad break in a stream ends.
  adBreakEnded,

  /// Fired when an ad break will not play back any ads.
  adBreakFetchError,

  /// Fired when an ad break is ready from VMAP or ad rule ads.
  adBreakReady,

  /// Fired when an ad break in a stream starts.
  adBreakStarted,

  /// Fired when playback stalls while the ad buffers.
  adBuffering,

  /// Fired when an ad period in a stream ends.
  adPeriodEnded,

  /// Fired when an ad period in a stream starts.
  adPeriodStarted,

  /// Fired to inform of ad progress and can be used by publisher to display a
  /// countdown timer.
  adProgress,

  /// Fired when the ads manager is done playing all the valid ads in the ads
  /// response, or when the response doesn't return any valid ads.
  allAdsCompleted,

  /// Fired when an ad is clicked.
  clicked,

  /// Fired when an ad completes playing.
  completed,

  /// Fired when content should be paused.
  contentPauseRequested,

  /// Fired when content should be resumed.
  contentResumeRequested,

  /// Fired when VOD stream cuepoints have changed.
  cuepointsChanged,

  /// Fired when the ad playhead crosses first quartile.
  firstQuartile,

  /// The user has closed the icon fallback image dialog.
  iconFallbackImageClosed,

  /// The user has tapped an ad icon.
  iconTapped,

  /// Fired when the VAST response has been received.
  loaded,

  /// Fired to enable the SDK to communicate a message to be logged, which is
  /// stored in adData.
  log,

  /// Fired when the ad playhead crosses midpoint.
  midpoint,

  /// Fired when an ad is paused.
  paused,

  /// Fired when an ad is resumed.
  resumed,

  /// Fired when an ad changes its skippable state.
  skippableStateChanged,

  /// Fired when an ad was skipped.
  skipped,

  /// Fired when an ad starts playing.
  started,

  /// Fired when a non-clickthrough portion of a video ad is clicked.
  tapped,

  /// Fired when the ad playhead crosses third quartile.
  thirdQuartile,

  /// The event type is not recognized by this wrapper.
  unknown,
}

/// Describes an element of the ad UI, to be requested or rendered by the SDK.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/UiElement.html.
enum UiElement {
  /// The ad attribution UI element, for example, "Ad".
  adAttribution,

  /// Ad attribution is required for a countdown timer to be displayed.
  countdown,

  /// The element is not recognized by this wrapper.
  unknown,
}

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
abstract class AdsLoader {
  /// Registers a listener for errors that occur during the ads request.
  void addAdErrorListener(AdErrorListener listener);

  /// Registers a listener for the ads manager loaded event.
  void addAdsLoadedListener(AdsLoadedListener listener);

  /// Requests ads from a server.
  void requestAds(AdsRequest request);
}

/// An event raised when ads are successfully loaded from the ad server through an AdsLoader.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdsManagerLoadedEvent.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.AdsManagerLoadedEvent',
  ),
)
abstract class AdsManagerLoadedEvent {
  /// The ads manager that will control playback of the loaded ads, or null when
  /// using dynamic ad insertion.
  late final AdsManager manager;
}

/// An event raised when there is an error loading or playing ads.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdErrorEvent.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.AdErrorEvent',
  ),
)
abstract class AdErrorEvent {
  /// The AdError that caused this event.
  late final AdError error;
}

/// An error that occurred in the SDK.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdError.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.AdError',
  ),
)
abstract class AdError {
  /// The error's code.
  late final AdErrorCode errorCode;

  /// The error code's number.
  late final int errorCodeNumber;

  /// The error's type.
  late final AdErrorType errorType;

  /// A human-readable summary of the error.
  late final String message;
}

/// An object containing the data used to request ads from the server.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdsRequest.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.AdsRequest',
  ),
)
abstract class AdsRequest {
  /// Sets the URL from which ads will be requested.
  void setAdTagUrl(String adTagUrl);

  /// Attaches a ContentProgressProvider instance to allow scheduling ad breaks
  /// based on content progress (cue points).
  void setContentProgressProvider(ContentProgressProvider provider);
}

/// Defines an interface to allow SDK to track progress of the content video.
///
/// See https://developers.google.com/ad-manager/dynamic-ad-insertion/sdk/android/api/reference/com/google/ads/interactivemedia/v3/api/player/ContentProgressProvider.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.player.ContentProgressProvider',
  ),
)
abstract class ContentProgressProvider {
  ContentProgressProvider();

  /// Sets an update on the progress of the video.
  ///
  /// This is a custom method added to the native class because the native
  /// method `getContentProgress` requires a synchronous return value.
  void setContentProgress(VideoProgressUpdate update);
}

/// An object which handles playing ads after they've been received from the
/// server.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdsManager.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.AdsManager',
  ),
)
abstract class AdsManager extends BaseManager {
  /// Discards current ad break and resumes content.
  void discardAdBreak();

  /// Pauses the current ad.
  void pause();

  /// Starts playing the ads.
  void start();

  /// List of content time offsets in seconds at which ad breaks are scheduled.
  ///
  /// The list will be empty if no ad breaks are scheduled.
  List<double> getAdCuePoints();

  /// Resumes the current ad.
  void resume();

  /// Skips the current ad.
  ///
  /// `AdsManager.skip()` only skips ads if IMA does not render the 'Skip ad'
  /// button.
  void skip();
}

/// Base interface for managing ads..
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/BaseManager.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.BaseManager',
  ),
)
abstract class BaseManager {
  /// Registers a listener for errors that occur during the ad or stream
  /// initialization and playback.
  void addAdErrorListener(AdErrorListener errorListener);

  /// Registers a listener for ad events that occur during ad or stream
  /// initialization and playback.
  void addAdEventListener(AdEventListener adEventListener);

  /// Stops the ad and all tracking, then releases all assets that were loaded
  /// to play the ad.
  void destroy();

  /// Initializes the ad experience on the manager.
  void init(AdsRenderingSettings? settings);

  /// Generic focus endpoint that puts focus on the skip button if present.
  void focus();

  /// Returns the latest AdProgressInfo for the current playing ad.
  AdProgressInfo? getAdProgressInfo();

  /// Get currently playing ad.
  Ad? getCurrentAd();

  /// Removes a listener for error events.
  void removeAdErrorListener(AdErrorListener errorListener);

  /// Removes a listener for ad events.
  void removeAdEventListener(AdEventListener adEventListener);
}

/// Event to notify publisher that an event occurred with an Ad.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdEvent.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.AdEvent',
  ),
)
abstract class AdEvent {
  /// The type of event that occurred.
  late final AdEventType type;

  /// A map containing any extra ad data for the event, if needed.
  late final Map<String, String>? adData;
}

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
  @attached
  late final ImaSdkFactory instance;

  @static
  AdDisplayContainer createAdDisplayContainer(
    ViewGroup container,
    VideoAdPlayer player,
  );

  /// Creates an `ImaSdkSettings` object for configuring the IMA SDK.
  ImaSdkSettings createImaSdkSettings();

  /// Creates an `AdsLoader` for requesting ads using the specified settings
  /// object.
  AdsLoader createAdsLoader(
    ImaSdkSettings settings,
    AdDisplayContainer container,
  );

  /// Creates an AdsRequest object to contain the data used to request ads.
  AdsRequest createAdsRequest();

  /// Creates an `AdsRenderingSettings` object to give the AdsManager parameters
  /// that control the rendering of ads.
  AdsRenderingSettings createAdsRenderingSettings();
}

/// Defines general SDK settings that are used when creating an `AdsLoader`.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/ImaSdkSettings.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.ImaSdkSettings',
  ),
)
abstract class ImaSdkSettings {}

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
  /// Adds a child view.
  void addView(View view);

  /// Called by a ViewGroup subclass to remove child views from itself, when it
  /// must first know its size on screen before it can calculate how many child
  /// views it will render.
  void removeView(View view);
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
  void setVideoUri(String? uri);

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

/// Listener interface for notification of ad load or stream load completion.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdsLoader.AdsLoadedListener.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.AdsLoader.AdsLoadedListener',
  ),
)
abstract class AdsLoadedListener {
  AdsLoadedListener();

  /// Called once the AdsManager or StreamManager has been loaded.
  late final void Function(AdsManagerLoadedEvent event) onAdsManagerLoaded;
}

/// Interface for classes that will listen to AdErrorEvents.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdErrorEvent.AdErrorListener.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.AdErrorEvent.AdErrorListener',
  ),
)
abstract class AdErrorListener {
  AdErrorListener();

  /// Called when an error occurs.
  late final void Function(AdErrorEvent event) onAdError;
}

/// Listener interface for ad events.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdEvent.AdEventListener.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.AdEvent.AdEventListener',
  ),
)
abstract class AdEventListener {
  AdEventListener();

  /// Respond to an occurrence of an AdEvent.
  late final void Function(AdEvent event) onAdEvent;
}

/// Defines parameters that control the rendering of ads.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdsRenderingSettings.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.AdsRenderingSettings',
  ),
)
abstract class AdsRenderingSettings {
  /// Maximum recommended bitrate.
  int getBitrateKbps();

  /// Returns whether the click-through URL will be opened using Custom Tabs
  /// feature.
  bool getEnableCustomTabs();

  /// Whether the SDK will instruct the player to load the creative in response
  /// to `BaseManager.init()`.
  bool getEnablePreloading();

  /// Whether to focus on the skip button when the skippable ad can be skipped
  /// on Android TV.
  ///
  /// This is a no-op on non-Android TV devices.
  bool getFocusSkipButtonWhenAvailable();

  /// The SDK will prioritize the media with MIME type on the list.
  List<String> getMimeTypes();

  /// Maximum recommended bitrate.
  ///
  /// The value is in kbit/s. Default value, -1, means the bitrate will be
  /// selected by the SDK.
  void setBitrateKbps(int bitrate);

  /// Notifies the SDK whether to launch the click-through URL using Custom Tabs
  /// feature.
  ///
  /// Default is false.
  void setEnableCustomTabs(bool enableCustomTabs);

  /// If set, the SDK will instruct the player to load the creative in response
  /// to `BaseManager.init()`.
  ///
  /// This allows the player to preload the ad at any point before calling
  /// `AdsManager.start()`.
  void setEnablePreloading(bool enablePreloading);

  /// Set whether to focus on the skip button when the skippable ad can be
  /// skipped on Android TV.
  ///
  /// This is a no-op on non-Android TV devices.
  ///
  /// Default is true.
  void setFocusSkipButtonWhenAvailable(bool enableFocusSkipButton);

  /// Specifies a non-default amount of time to wait for media to load before
  /// timing out, in milliseconds.
  ///
  /// This only applies to the IMA client-side SDK.
  ///
  /// Default time is 8000 ms.
  void setLoadVideoTimeout(int loadVideoTimeout);

  /// If specified, the SDK will prioritize the media with MIME type on the
  /// list.
  void setMimeTypes(List<String> mimeTypes);

  /// For VMAP and ad rules playlists, only play ad breaks scheduled after this
  /// time (in seconds).
  void setPlayAdsAfterTime(double time);

  /// Sets the ad UI elements to be rendered by the IMA SDK.
  void setUiElements(List<UiElement> uiElements);
}

/// Represents the progress within this ad break.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdProgressInfo.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.AdProgressInfo',
  ),
)
abstract class AdProgressInfo {
  /// Total ad break duration (in seconds).
  late final double adBreakDuration;

  /// Total ad period duration (in seconds).
  late final double adPeriodDuration;

  /// The position of current ad within the ad break, starting with 1.
  late final int adPosition;

  /// Current time within the ad (in seconds).
  late final double currentTime;

  /// Duration of current ad (in seconds).
  late final double duration;

  /// The total number of ads in this ad break.
  late final int totalAds;
}

/// An object that holds data corresponding to the companion Ad.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/CompanionAd.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.CompanionAd',
  ),
)
abstract class CompanionAd {
  /// The API needed to execute this ad, or null if unavailable.
  late final String? apiFramework;

  /// The height of the companion in pixels.
  ///
  /// 0 if unavailable.
  late final int height;

  /// The URL for the static resource of this companion.
  late final String resourceValue;

  /// The width of the companion in pixels.
  ///
  /// 0 if unavailable.
  late final int width;
}

/// This object exposes information about the universal ad ID.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/UniversalAdId.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.UniversalAdId',
  ),
)
abstract class UniversalAdId {
  /// Returns the ad ID registry associated with the ad ID value.
  ///
  /// Returns "unknown" if the registry is not known.
  late final String adIdRegistry;

  /// Returns the universal ad ID value.
  ///
  /// Returns "unknown" if the value is not known.
  late final String adIdValue;
}

/// An object that holds data corresponding to the main Ad.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/Ad.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.Ad',
  ),
)
abstract class Ad {
  /// The ad ID as specified in the VAST response.
  late final String adId;

  /// The pod metadata object.
  late final AdPodInfo adPodInfo;

  /// The ad system as specified in the VAST response.
  late final String adSystem;

  /// The IDs of the ads' creatives, starting with the first wrapper ad.
  late final List<String> adWrapperCreativeIds;

  /// The wrapper ad IDs as specified in the VAST response.
  late final List<String> adWrapperIds;

  /// The wrapper ad systems as specified in the VAST response.
  late final List<String> adWrapperSystems;

  /// The advertiser name as defined by the serving party.
  late final String advertiserName;

  /// The companions for the current ad while using DAI.
  ///
  /// Returns an empty list in any other scenario.
  late final List<CompanionAd> companionAds;

  /// The content type of the currently selected creative, or null if no
  /// creative is selected or the content type is unavailable.
  late final String? contentType;

  /// The ISCI (Industry Standard Commercial Identifier) code for an ad.
  late final String creativeAdId;

  /// The ID of the selected creative for the ad,
  late final String creativeId;

  /// The first deal ID present in the wrapper chain for the current ad,
  /// starting from the top.
  late final String dealId;

  /// The description of this ad from the VAST response.
  late final String? description;

  /// The duration of the ad in seconds, -1 if not available.
  late final double duration;

  /// The height of the selected creative if non-linear, else returns 0.
  late final int height;

  /// The number of seconds of playback before the ad becomes skippable.
  late final double skipTimeOffset;

  /// The URL associated with the survey for the given ad.
  late final String? surveyUrl;

  /// The title of this ad from the VAST response.
  late final String? title;

  /// The custom parameters associated with the ad at the time of ad
  /// trafficking.
  late final String traffickingParameters;

  /// Te set of ad UI elements rendered by the IMA SDK for this ad.
  late final List<UiElement> uiElements;

  /// The list of all universal ad IDs for this ad.
  late final List<UniversalAdId> universalAdIds;

  /// The VAST bitrate in Kbps of the selected creative.
  late final int vastMediaBitrate;

  /// The VAST media height in pixels of the selected creative.
  late final int vastMediaHeight;

  /// The VAST media width in pixels of the selected creative.
  late final int vastMediaWidth;

  /// The width of the selected creative if non-linear, else returns 0.
  late final int width;

  /// Indicates whether the ad’s current mode of operation is linear or
  /// non-linear.
  late final bool isLinear;

  /// Indicates whether the ad can be skipped by the user.
  late final bool isSkippable;
}

/// Listener interface for click events.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/CompanionAdSlot.ClickListener.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.CompanionAdSlot.ClickListener',
  ),
)
abstract class CompanionAdSlotClickListener {
  CompanionAdSlotClickListener();

  /// Respond to a click on this companion ad slot.
  late final void Function() onCompanionAdClick;
}

/// A companion ad slot for which the SDK should retrieve ads.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/CompanionAdSlot.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.CompanionAdSlot',
  ),
)
abstract class CompanionAdSlot {
  /// Registers a listener for companion clicks.
  void addClickListener(CompanionAdSlotClickListener clickListener);

  /// Returns the ViewGroup into which the companion will be rendered.
  ViewGroup getContainer();

  /// Returns the height of the companion slot.
  int getHeight();

  /// Returns the width of the companion slot.
  int getWidth();

  /// Returns true if the companion slot is filled, false otherwise.
  bool isFilled();

  /// Removes a listener for companion clicks.
  void removeClickListener(CompanionAdSlotClickListener clickListener);

  /// Sets the ViewGroup into which the companion will be rendered.
  ///
  /// Required.
  void setContainer(ViewGroup container);

  /// Sets the size of the slot.
  ///
  /// Only companions matching the slot size will be displayed in the slot.
  void setSize(int width, int height);
}
