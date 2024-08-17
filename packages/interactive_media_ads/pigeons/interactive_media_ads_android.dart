// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Uncomment this file once
// https://github.com/flutter/packages/pull/6371 lands. This file uses the
// Kotlin ProxyApi feature from pigeon.
// ignore_for_file: avoid_unused_constructor_parameters
/*
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

/// A list of purposes for which an obstruction would be registered as friendly.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/FriendlyObstructionPurpose.html.
enum FriendlyObstructionPurpose {
  closeAd,
  notVisible,
  other,
  videoControls,
  unknown,
}

/// Enum of possible stream formats.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/StreamRequest.StreamFormat.html.
enum StreamFormat {
  dash,
  hls,
  unknown,
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

/// Represents a cuepoint within a VOD stream.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/CuePoint.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.CuePoint',
  ),
)
abstract class CuePoint {
  /// The end time of the cuepoint in milliseconds.
  late final int endTimeMs;

  /// The start time of the cuepoint in milliseconds.
  late final int startTimeMs;

  /// Whether the corresponding ad break was played.
  late final bool isPlayed;
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

/// A base class for more specialized container interfaces.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/BaseDisplayContainer.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.BaseDisplayContainer',
  ),
)
abstract class BaseDisplayContainer {
  /// Returns the previously set container, or null if none has been set.
  ViewGroup? getAdContainer();

  /// Gets the companion slots that have been set.
  ///
  /// Returns an empty list if none have been set.
  List<CompanionAdSlot> getCompanionSlots();

  /// Registers a view that overlays or obstructs this container as "friendly"
  /// for viewability measurement purposes.
  void registerFriendlyObstruction(FriendlyObstruction friendlyObstruction);

  /// Sets slots for displaying companions.
  ///
  /// Passing null will reset the container to having no companion slots.
  void setCompanionSlots(List<CompanionAdSlot>? companionSlots);

  /// Unregisters all previously registered friendly obstructions.
  void unregisterAllFriendlyObstructions();
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

/// An obstruction that is marked as "friendly" for viewability measurement
/// purposes.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/FriendlyObstruction.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.FriendlyObstruction',
  ),
)
abstract class FriendlyObstruction {
  ///  The optional, detailed reasoning for registering this obstruction as friendly.
  late final String? detailedReason;

  /// The purpose for registering the obstruction as friendly.
  late final FriendlyObstructionPurpose purpose;

  /// The view causing the obstruction.
  late final View view;
}

/// A container in which to display the ads.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdDisplayContainer.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.AdDisplayContainer',
  ),
)
abstract class AdDisplayContainer extends BaseDisplayContainer {
  /// The previously set player, or null if none has been set.
  VideoAdPlayer getPlayer();
}

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

  /// Returns the IMA SDK settings instance.
  ///
  /// To change the settings, just call the methods on the instance. The changes
  /// will apply for all ad requests made with this ads loader.
  ImaSdkSettings getSettings();

  /// Frees resources from the BaseDisplayContainer as well as the underlying
  /// WebView.
  ///
  /// This should occur after disposing of the `BaseManager` using
  /// `BaseManager.destroy()` and after the manager has finished its own
  /// cleanup, as indicated by `AdEventType.ALL_ADS_COMPLETED`
  void release();

  /// Removes a listener for error events.
  void removeAdErrorListener(AdErrorListener errorListener);

  /// Removes a listener for the ads manager loaded event.
  void removeAdsLoadedListener(AdsLoadedListener loadedListener);

  /// Initiates a stream session with server-side ad insertion.
  String requestStream(StreamRequest streamRequest);
}

/// Base interface for requesting ads.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/BaseRequest.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.BaseRequest',
  ),
)
abstract class BaseRequest {
  /// Returns the deep link to the content's screen provided in
  /// `setContentUrl()`.
  String getContentUrl();

  /// Returns the Secure Signals with custom data.
  SecureSignals? getSecureSignals();

  /// Returns the user-provided object that is associated with the request.
  Object? getUserRequestContext();

  /// Specifies the deep link to the content's screen.
  void setContentUrl(String url);

  /// Specifies the Secure Signals with custom data for this request.
  void setSecureSignals(SecureSignals? signal);

  /// Sets the user-provided object that is associated with the request.
  void setUserRequestContext(Object userRequestContext);
}

/// Base interface for requesting ads.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/BaseRequest.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.signals.SecureSignals',
  ),
)
abstract class SecureSignals {
  /// Creates a new SecureSignals object that will contain all the necessary
  /// information for a secure signal.
  @static
  SecureSignals create(String customData);

  /// Secure Signal.
  late final String secureSignal;
}

/// An event raised when ads are successfully loaded from the ad server through
/// an AdsLoader.
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
  late final AdsManager? adsManager;

  /// the stream manager for the current dynamic ad insertion stream, or null
  /// when requesting ads directly.
  late final StreamManager? streamManager;

  /// The user-provided object that is associated with the ads request.
  late final Object? userRequestContext;
}

/// An object which manages dynamic ad insertion streams.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/StreamManager.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.StreamManager',
  ),
)
abstract class StreamManager extends BaseManager {
  /// Converts time offset within the stream to time offset of the underlying
  /// content, excluding ads.
  int getContentTimeMsForStreamTimeMs(int streamTimeMs);

  /// Returns the CuePoints for the current VOD stream, which are available
  /// after cuepointsChanged is broadcast
  List<CuePoint> getCuePoints();

  /// Returns the previous cuepoint for the given VOD stream time.
  ///
  /// Returns null if there is no previous cue point, or if called for a live
  /// stream.
  CuePoint? getPreviousCuePointForStreamTimeMs(int streamTimeMs);

  /// Get the identifier used during server side ad insertion to uniquely
  /// identify a stream.
  ///
  /// Returns null if server side ad insertion was not used.
  String getStreamId();

  /// Converts time offset within the content to time offset of the underlying
  /// stream, including ads.
  int getStreamTimeMsForContentTimeMs(int contentTimeMs);

  /// Requests SDK to retrieve the ad metadata and then load the provided
  /// streamManifestUrl and streamSubtitles into player.
  void loadThirdPartyStream(
    String streamUrl,
    List<Map<String, String>> streamSubtitles,
  );

  /// Replaces all the ad tag parameters used for the upcoming ad requests for a
  /// live stream.
  void replaceAdTagParameters(Map<String, String> adTagParameters);
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

  /// The user-provided object that is associated with the ads request.
  late final Object? userRequestContext;
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
abstract class AdsRequest extends BaseRequest {
  /// Sets the URL from which ads will be requested.
  void setAdTagUrl(String adTagUrl);

  /// Attaches a ContentProgressProvider instance to allow scheduling ad breaks
  /// based on content progress (cue points).
  void setContentProgressProvider(ContentProgressProvider provider);

  /// Returns the URL from which ads will be requested.
  String getAdTagUrl();

  /// Returns the progress provider that will be used to schedule ad breaks.
  ContentProgressProvider getContentProgressProvider();

  /// Notifies the SDK whether the player intends to start the content and ad in
  /// response to a user action or whether it will be automatically played.
  ///
  /// Not calling this function leaves the setting as unknown.
  void setAdWillAutoPlay(bool willAutoPlay);

  /// Notifies the SDK whether the player intends to start the content and ad
  /// while muted.
  void setAdWillPlayMuted(bool willPlayMuted);

  /// Specifies a VAST, VMAP, or ad rules response to be used instead of making
  /// a request through an ad tag URL.
  void setAdsResponse(String cannedAdResponse);

  /// Specifies the duration of the content in seconds to be shown
  void setContentDuration(double duration);

  /// Specifies the keywords used to describe the content to be shown.
  void setContentKeywords(List<String> keywords);

  /// Specifies the title of the content to be shown.
  void setContentTitle(String title);

  /// Notifies the SDK whether the player intends to continuously play the
  /// content videos one after another similar to TV broadcast.
  ///
  /// Not calling this function leaves the setting as unknown.
  void setContinuousPlayback(bool continuousPlayback);

  /// Specifies the maximum amount of time to wait in seconds, after calling
  /// requestAds, before requesting the ad tag URL.
  void setLiveStreamPrefetchSeconds(double prefetchTime);

  /// Specifies the VAST load timeout in milliseconds for a single wrapper.
  ///
  /// This parameter is optional and will override the default timeout,
  /// currently set to 5000ms.
  void setVastLoadTimeout(double timeout);
}

/// An object containing the data used to request a stream with server-side ad
/// insertion.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/StreamRequest.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.StreamRequest',
  ),
)
abstract class StreamRequest extends BaseRequest {
  /// Returns any parameters that the SDK will attempt to add to ad tags based
  /// on a call to setAdTagParameters().
  Map<String, String>? getAdTagParameters();

  /// Returns the ad tag associated with this stream request.
  ///
  /// Returns null for all stream requests other than cloud based video on
  /// demand request.
  String? getAdTagUrl();

  /// Returns the API key for the ad server.
  String getApiKey();

  /// Returns the asset key for server-side ad insertion streams.
  ///
  /// Returns null for video on demand streams and pod streams.
  String? getAssetKey();

  /// Returns the stream request authorization token.
  String getAuthToken();

  /// Returns the content source ID for video on demand server-side ad insertion
  /// streams.
  ///
  /// Returns null for live streams and pod streams.
  String? getContentSourceId();

  /// Returns the source of the content for this stream request.
  ///
  /// Returns null for all stream requests other than cloud based video on
  /// demand request
  String? getContentSourceUrl();

  /// Returns the custom asset key for a pod serving request.
  ///
  /// Returns null for live and video on demand streams.
  String? getCustomAssetKey();

  /// Returns the format of the stream request.
  StreamFormat getFormat();

  /// Returns the suffix that the SDK will append to the query of the stream
  /// manifest URL.
  String getManifestSuffix();

  /// Returns the network code for a pod serving request.
  ///
  /// Returns null for live and video on demand streams.
  String? getNetworkCode();

  /// Returns the video ID for video on demand server-side ad insertion streams.
  ///
  /// Returns null for live and pod streams.
  String? getVideoId();

  /// Returns the associated Video Stitcher-specific session options for a Video
  /// Stitcher stream request.
  ///
  /// This method will return null unless `setVideoStitcherSessionOptions` was
  /// called with some value(s).
  Map<String, Object>? getVideoStitcherSessionOptions();

  /// The vodConfig ID for the VOD stream, as set up on the Video Stitcher.
  String? getVodConfigId();

  /// Sets the overridable ad tag parameters on the stream request.
  ///
  /// See https://support.google.com/admanager/answer/7320899.
  void setAdTagParameters(Map<String, String> adTagParameters);

  /// Sets the stream request authorization token.
  void setAuthToken(String authToken);

  /// Sets the format of the stream request.
  void setFormat(StreamFormat format);

  /// Sets the stream manifest's suffix, which will be appended to the stream
  /// manifest's URL.
  ///
  /// This setting is optional.
  void setManifestSuffix(String manifestSuffix);

  /// Sets the ID to be used to debug the stream with the stream activity
  /// monitor.
  void setStreamActivityMonitorId(String streamActivityMonitorId);

  /// Sets Video Stitcher-specific session options for a Video Stitcher stream
  /// request.
  void setVideoStitcherSessionOptions(
    Map<String, Object> videoStitcherSessionOptions,
  );
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

/// Base interface for managing ads.
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
  ///  Default is false.
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

  /// The ad with which this event is associated.
  late final Ad? ad;
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
  /// The global ImaSdkFactory object.
  @static
  @attached
  late final ImaSdkFactory instance;

  /// Creates an `AdDisplayContainer` to hold the player for video ads, a
  /// container for non-linear ads, and slots for companion ads.
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

  /// Creates an AdsLoader for requesting server-side ad insertion ads using the
  /// specified settings object.
  AdsLoader createStreamAdsLoader(
    ImaSdkSettings settings,
    StreamDisplayContainer container,
  );

  /// Creates an `AdsRenderingSettings` object to give the `AdsManager`
  /// parameters that control the rendering of ads.
  AdsRenderingSettings createAdsRenderingSettings();

  /// Creates an `AdDisplayContainer` for audio ads.
  @static
  AdDisplayContainer createAudioAdDisplayContainer(VideoAdPlayer player);

  /// Creates a `CompanionAdSlot` for the SDK to fill with companion ads.
  CompanionAdSlot createCompanionAdSlot();

  /// Creates a `FriendlyObstruction` object to describe an obstruction
  /// considered "friendly" for viewability measurement purposes.
  ///
  /// If the detailedReason is not null, it must follow the IAB standard by
  /// being 50 characters or less and only containing characters A-z , 0-9, or
  /// spaces.
  FriendlyObstruction createFriendlyObstruction(
    View view,
    FriendlyObstructionPurpose purpose,
    String? detailedReason,
  );

  /// Creates a `StreamRequest` object to contain the data used to request a
  /// server-side ad insertion live stream.
  StreamRequest createLiveStreamRequest(String assetKey, String apiKey);

  /// Creates a StreamRequest object to contain the data used to request a
  /// server-side ad insertion pod serving live stream.
  StreamRequest createPodStreamRequest(
    String networkCode,
    String customAssetKey,
    String apiKey,
  );

  /// Creates a StreamRequest object to contain the data used to request a 3rd
  /// party stitched server-side ad insertion pod serving vod stream.
  StreamRequest createPodVodStreamRequest(String networkCode);

  /// Creates a `StreamDisplayContainer` to hold the player for server-side ad
  /// insertion streams and slots for companion ads.
  @static
  StreamDisplayContainer createStreamDisplayContainer(
    ViewGroup container,
    VideoStreamPlayer player,
  );

  /// Creates a `StreamRequest` object to contain the data used to request a
  /// cloud video stitcher server-side ad insertion pod live serving stream.
  StreamRequest createVideoStitcherLiveStreamRequest(
    String networkCode,
    String customAssetKey,
    String liveStreamEventId,
    String region,
    String projectNumber,
    String oAuthToken,
  );

  /// Creates a `StreamRequest` object to contain the data used to request a
  /// cloud video stitcher server-side ad insertion pod serving vod stream.
  StreamRequest createContentSourceVideoStitcherVodStreamRequest(
    String contentSourceUrl,
    String networkCode,
    String region,
    String projectNumber,
    String oAuthToken,
    String adTagUrl,
  );

  /// Creates a `StreamRequest` object to contain the data used to request a
  /// cloud video stitcher server-side ad insertion pod serving vod stream, with
  /// a vod config flow.
  StreamRequest createVideoStitcherVodStreamRequest(
    String networkCode,
    String region,
    String projectNumber,
    String oAuthToken,
    String vodConfigId,
  );

  /// Creates a StreamRequest object to contain the data used to request a
  /// server-side ad insertion video on demand stream.
  StreamRequest createVodStreamRequest(
    String contentSourceId,
    String videoId,
    String apiKey,
  );
}

/// A display container specific to server-side ad insertion.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/StreamDisplayContainer.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.StreamDisplayContainer',
  ),
)
abstract class StreamDisplayContainer extends BaseDisplayContainer {
  /// Returns the previously set player used for server-side ad insertion, or
  /// null if none has been set.
  VideoStreamPlayer? getVideoStreamPlayer();
}

/// Defines a set of methods that a video player must implement to be used by
/// the IMA SDK for dynamic ad insertion.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/player/VideoStreamPlayer.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.player.VideoStreamPlayer',
  ),
)
abstract class VideoStreamPlayer {
  VideoStreamPlayer();

  /// Adds a callback so that listeners can react to events from the
  /// `VideoStreamPlayer`.
  late final void Function(VideoStreamPlayerCallback callback) addCallback;

  /// Loads a stream with dynamic ad insertion given the stream url and
  /// subtitles array.
  late final void Function(String url, List<Map<String, String>> subtitles)
      loadUrl;

  /// The SDK will call this method the first time each ad break ends.
  late final void Function() onAdBreakEnded;

  /// The SDK will call this method the first time each ad break begins playback.
  late final void Function() onAdBreakStarted;

  /// The SDK will call this method every time the stream switches from
  /// advertising or slate to content.
  late final void Function() onAdPeriodEnded;

  /// The SDK will call this method every time the stream switches from content
  /// to advertising or slate.
  late final void Function() onAdPeriodStarted;

  /// Pauses the current stream.
  late final void Function() pause;

  /// Removes a callback.
  late final void Function(VideoStreamPlayerCallback callback) removeCallback;

  /// Resumes playing the stream.
  late final void Function() resume;

  /// Seeks the stream to the given time in milliseconds.
  late final void Function(int time) seek;

  /// The volume of the player as a percentage from 0 to 100.
  void setVolume(int value);

  /// The `VideoProgressUpdate` describing playback progress of the current
  /// video.
  void setContentProgress(VideoProgressUpdate progress);
}

/// Defines a set of methods that a video player must implement to be used by
/// the IMA SDK for dynamic ad insertion.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/player/VideoStreamPlayer.VideoStreamPlayerCallback.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.player.VideoStreamPlayer.VideoStreamPlayerCallback',
  ),
)
abstract class VideoStreamPlayerCallback {
  /// Fire this callback when all content has finished playing.
  void onContentComplete();

  /// Fire this callback when the video is paused.
  void onPause();

  /// Fire this callback when the video is resumed.
  void onResume();

  /// Fire this callback when a timed metadata ID3 event corresponding to
  /// user-defined text is received.
  ///
  /// For more information about user text events, see
  /// http://id3.org/id3v2.4.0-frames.
  void onUserTextReceived(String userText);

  /// Fire this callback when the video player volume changes.
  void onVolumeChanged(int percentage);
}

/// Defines general SDK settings that are used when creating an `AdsLoader`.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/ImaSdkSettings.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.ImaSdkSettings',
  ),
)
abstract class ImaSdkSettings {
  /// Specifies whether VMAP and ad rules ad breaks are automatically played.
  ///
  /// Default is true.
  bool getAutoPlayAdBreaks();

  /// Returns the feature flags and their states as set by the
  /// `setFeatureFlags(Map)` function.
  Map<String, String> getFeatureFlags();

  /// Gets the current ISO 639-1 language code.
  ///
  /// Defaults to "en" for English.
  String getLanguage();

  /// Returns the maximum number of VAST redirects.
  int getMaxRedirects();

  /// Returns the partner provided player type.
  String getPlayerType();

  /// Returns the partner provided player version.
  String getPlayerVersion();

  /// Returns the PPID.
  String getPpid();

  /// Returns the session ID if set.
  String? getSessionId();

  /// Gets the debug mode.
  ///
  /// Default is false.
  bool isDebugMode();

  /// Sets whether to automatically play VMAP and ad rules ad breaks.
  void setAutoPlayAdBreaks(bool autoPlayAdBreaks);

  /// Enables and disables the debug mode, which is disabled by default.
  void setDebugMode(bool debugMode);

  /// Sets the feature flags and their states to control experimental features.
  void setFeatureFlags(Map<String, String> featureFlags);

  /// Sets the preferred language for the ad UI.
  ///
  /// The supported codes  are closely related to the two-letter ISO 639-1
  /// language codes. See
  /// https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/localization.
  ///
  /// Once the AdsLoader object has been created, using this setter will have no
  /// effect.
  void setLanguage(String language);

  /// Specifies the maximum number of redirects before the subsequent redirects
  /// will be denied and the ad load aborted. In this case, the ad will raise an
  /// error with error code 302.
  void setMaxRedirects(int maxRedirects);

  /// Sets the partner provided player type.
  void setPlayerType(String playerType);

  /// Sets the partner provided player version.
  void setPlayerVersion(String playerVersion);

  /// Sets the publisher provided ID used for tracking.
  void setPpid(String ppid);

  /// Session ID is a temporary random ID. It is used exclusively for frequency
  /// capping.
  void setSessionId(String sessionId);
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

/// Version info for SecureSignals adapters and for third party SDKs that
/// collect SecureSignals.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/VersionInfo.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.VersionInfo',
  ),
)
abstract class VersionInfo {
  /// Creates a new VersionInfo object that will contain the version of an rtb
  /// adapter or third party SDK.
  VersionInfo();

  late final int majorVersion;
  late final int minorVersion;
  late final int microVersion;
}

/// Provides an API for interactive advertisements to resize the `VideoAdPlayer`
/// or `VideoStreamPlayer` within its container.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/player/ResizablePlayer.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.player.ResizablePlayer',
  ),
)
abstract class ResizablePlayer {
  /// Resize the VideoPlayer within its bounds by adding margins to each side,
  /// in pixels.
  late final void Function(
    int leftMargin,
    int topMargin,
    int rightMargin,
    int bottomMargin,
  ) resize;
}

/// Implementation of a `VideoAdPlayer` that also implements `ResizablePlayer`.
///
/// This class is not a part of the IMA SDK and is provided as a work around to
/// create a class that implements both `VideoAdPlayer` and `ResizablePlayer`.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'dev.flutter.packages.interactive_media_ads.ResizableVideoAdPlayerProxyApi.ResizableVideoAdPlayer',
  ),
)
abstract class ResizableVideoAdPlayer extends VideoAdPlayer
    implements ResizablePlayer {
  ResizableVideoAdPlayer();
}

/// Implementation of a `VideoStreamPlayer` that also implements
/// `ResizablePlayer`.
///
/// This class is not a part of the IMA SDK and is provided as a work around to
/// create a class that implements both `VideoStreamPlayer` and
/// `ResizablePlayer`.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'dev.flutter.packages.interactive_media_ads.ResizableVideoStreamPlayerProxyApi.ResizableVideoStreamPlayer',
  ),
)
abstract class ResizableVideoStreamPlayer extends VideoStreamPlayer
    implements ResizablePlayer {
  ResizableVideoStreamPlayer();
}

/// Mediation adapter for gathering Secure Signals generated by a 3P entity that
/// is not the publisher.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/signals/SecureSignalsAdapter.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.signals.SecureSignalsAdapter',
  ),
)
abstract class SecureSignalsAdapter {
  void collectSignals(
    SecureSignalsCollectSignalsCallback callback,
  );

  /// Returns the version of the third party SDK built into the app.
  VersionInfo getSDKVersion();

  /// Returns the version of the SecureSignals Adapter.
  VersionInfo getVersion();

  /// Called by Interactive Media Ads SDK to initialize a third party adapter
  /// and SDK.
  void initialize(SecureSignalsInitializeCallback callback);
}

/// Defines callback methods for an implementation of `SecureSignalsAdapter` to
/// communicate success or failure of a call to
/// `SecureSignalsAdapter.collectSignals(SecureSignalsCollectSignalsCallback)`.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/signals/SecureSignalsCollectSignalsCallback.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.signals.SecureSignalsCollectSignalsCallback',
  ),
)
abstract class SecureSignalsCollectSignalsCallback {
  SecureSignalsCollectSignalsCallback();

  /// To be invoked when signal collection fails.
  late final void Function(String type, String? message) onFailure;

  /// To be invoked when the signals have been successfully collected.
  late final void Function(String signals) onSuccess;
}

/// Defines callback methods for an implementation of `SecureSignalsAdapter` to
/// communicate success or failure of a call to
/// `SecureSignalsAdapter.initialize(SecureSignalsInitializeCallback)`.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/signals/SecureSignalsInitializeCallback.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.signals.SecureSignalsInitializeCallback',
  ),
)
abstract class SecureSignalsInitializeCallback {
  SecureSignalsInitializeCallback();

  /// To be invoked when initialization fails.
  late final void Function(String type, String? message) onFailure;

  /// Indicates to the SDK that the adapter has been initialized and can be used
  /// for future signal collection.
  late final void Function() onSuccess;
}
*/