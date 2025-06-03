// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    copyrightHeader: 'pigeons/copyright.txt',
    dartOut: 'lib/src/ios/interactive_media_ads.g.dart',
    swiftOut:
        'ios/interactive_media_ads/Sources/interactive_media_ads/InteractiveMediaAdsLibrary.g.swift',
  ),
)

/// Possible error types while loading or playing ads.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Enums/IMAErrorType.html.
enum AdErrorType {
  /// An error occurred while loading the ads.
  loadingFailed,

  /// An error occurred while playing the ads.
  adPlayingFailed,

  /// An unexpected error occurred while loading or playing the ads.
  ///
  /// This may mean that the SDK wasn’t loaded properly or the wrapper doesn't
  /// recognize this value.
  unknown,
}

/// Possible error codes raised while loading or playing ads.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Enums/IMAErrorCode.html.
enum AdErrorCode {
  /// The ad slot is not visible on the page.
  adslotNotVisible,

  /// Generic invalid usage of the API.
  apiError,

  /// A companion ad failed to load or render.
  companionAdLoadingFailed,

  /// Content playhead was not passed in, but list of ads has been returned from
  /// the server.
  contentPlayheadMissing,

  /// There was an error loading the ad.
  failedLoadingAd,

  /// There was a problem requesting ads from the server.
  failedToRequestAds,

  /// Invalid arguments were provided to SDK methods.
  invalidArguments,

  /// The version of the runtime is too old.
  osRuntimeTooOld,

  /// Ads list response was malformed.
  playlistMalformedResponse,

  /// Listener for at least one of the required vast events was not added.
  requiredListenersNotAdded,

  /// There was an error initializing the stream.
  streamInitializationFailed,

  /// An unexpected error occurred and the cause is not known.
  unknownError,

  /// No assets were found in the VAST ad response.
  vastAssetNotFound,

  /// A VAST response containing a single `<VAST>` tag with no child tags.
  vastEmptyResponse,

  /// At least one VAST wrapper loaded and a subsequent wrapper or inline ad
  /// load has resulted in a 404 response code.
  vastInvalidUrl,

  /// Assets were found in the VAST ad response for a linear ad, but none of
  /// them matched the video player's capabilities.
  vastLinearAssetMismatch,

  /// The VAST URI provided, or a VAST URI provided in a subsequent Wrapper
  /// element, was either unavailable or reached a timeout, as defined by the
  /// video player.
  vastLoadTimeout,

  /// The ad response was not recognized as a valid VAST ad.
  vastMalformedResponse,

  /// Failed to load media assets from a VAST response.
  vastMediaLoadTimeout,

  /// The maximum number of VAST wrapper redirects has been reached.
  vastTooManyRedirects,

  /// Trafficking error.
  ///
  /// Video player received an ad type that it was not expecting and/or cannot
  /// display.
  vastTraffickingError,

  /// Another VideoAdsManager is still using the video.
  videoElementUsed,

  /// A video element was not specified where it was required.
  videoElementRequired,

  /// There was an error playing the video ad.
  videoPlayError,
}

/// Different event types sent by the IMAAdsManager to its delegate.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Enums/IMAAdEventType.html.
enum AdEventType {
  /// Fired the first time each ad break ends.
  adBreakEnded,

  /// Fired when an ad break will not play back any ads.
  adBreakFetchError,

  /// Fired when an ad break is ready.
  adBreakReady,

  /// Fired first time each ad break begins playback.
  adBreakStarted,

  /// Fired every time the stream switches from advertising or slate to content.
  adPeriodEnded,

  /// Fired every time the stream switches from content to advertising or slate.
  adPeriodStarted,

  /// All valid ads managed by the ads manager have completed or the ad response
  /// did not return any valid ads.
  allAdsCompleted,

  /// Fired when an ad is clicked.
  clicked,

  /// Single ad has finished.
  completed,

  /// Cuepoints changed for VOD stream (only used for dynamic ad insertion).
  cuepointsChanged,

  /// First quartile of a linear ad was reached.
  firstQuartile,

  /// The user has closed the icon fallback image dialog.
  iconFallbackImageClosed,

  /// The user has tapped an ad icon.
  iconTapped,

  /// An ad was loaded.
  loaded,

  /// A log event for the ads being played.
  log,

  /// Midpoint of a linear ad was reached.
  midpoint,

  /// Ad paused.
  pause,

  /// Ad resumed.
  resume,

  /// Fired when an ad was skipped.
  skipped,

  /// Fired when an ad starts playing.
  started,

  /// Stream request has loaded (only used for dynamic ad insertion).
  streamLoaded,

  /// Stream has started playing (only used for dynamic ad insertion).
  streamStarted,

  /// Ad tapped.
  tapped,

  /// Third quartile of a linear ad was reached..
  thirdQuartile,

  /// The event type is not recognized by this wrapper.
  unknown,
}

/// The values that can be returned in a change dictionary.
///
/// See https://developer.apple.com/documentation/foundation/nskeyvalueobservingoptions?language=objc.
enum KeyValueObservingOptions {
  /// Indicates that the change dictionary should provide the new attribute
  /// value, if applicable.
  newValue,

  /// Indicates that the change dictionary should contain the old attribute
  /// value, if applicable.
  oldValue,

  /// If specified, a notification should be sent to the observer immediately,
  /// before the observer registration method even returns.
  initialValue,

  /// Whether separate notifications should be sent to the observer before and
  /// after each change, instead of a single notification after the change.
  priorNotification,
}

/// The kinds of changes that can be observed..
///
/// See https://developer.apple.com/documentation/foundation/nskeyvaluechange?language=objc.
enum KeyValueChange {
  /// Indicates that the value of the observed key path was set to a new value.
  setting,

  /// Indicates that an object has been inserted into the to-many relationship
  /// that is being observed.
  insertion,

  /// Indicates that an object has been removed from the to-many relationship
  /// that is being observed.
  removal,

  /// Indicates that an object has been replaced in the to-many relationship
  /// that is being observed.
  replacement,
}

/// The keys that can appear in the change dictionary..
///
/// See https://developer.apple.com/documentation/foundation/nskeyvaluechangekey?language=objc.
enum KeyValueChangeKey {
  /// If the value of the kindKey entry is NSKeyValueChange.insertion,
  /// NSKeyValueChange.removal, or NSKeyValueChange.replacement, the value of
  /// this key is an NSIndexSet object that contains the indexes of the
  /// inserted, removed, or replaced objects.
  indexes,

  /// An NSNumber object that contains a value corresponding to one of the
  /// NSKeyValueChange enums, indicating what sort of change has occurred.
  kind,

  /// If the value of the kindKey entry is NSKeyValueChange.setting, and new was
  /// specified when the observer was registered, the value of this key is the
  /// new value for the attribute.
  newValue,

  /// If the prior option was specified when the observer was registered this
  /// notification is sent prior to a change.
  notificationIsPrior,

  /// If the value of the kindKey entry is NSKeyValueChange.setting, and old was
  /// specified when the observer was registered, the value of this key is the
  /// value before the attribute was changed.
  oldValue,

  /// The key is not recognized by this wrapper.
  unknown,
}

/// A list of purposes for which an obstruction would be registered as friendly.
///
/// See https://developers.google.com/ad-manager/dynamic-ad-insertion/sdk/ios/reference/Enums/IMAFriendlyObstructionPurpose.html.
enum FriendlyObstructionPurpose {
  mediaControls,

  closeAd,

  notVisible,

  other,

  /// The purpose type is not recognized by this wrapper.
  unknown,
}

/// Different UI elements that can be customized.
///
/// See https://developers.google.com/ad-manager/dynamic-ad-insertion/sdk/ios/reference/Enums/IMAUiElementType.html.
enum UIElementType {
  /// Ad attribution UI element.
  adAttribution,

  /// Ad countdown element.
  countdown,

  /// The element is not recognized by this wrapper.
  unknown,
}

/// The `IMAAdDisplayContainer` is responsible for managing the ad container
/// view and companion ad slots used for ad playback.
///
/// See https://developers.google.com/ad-manager/dynamic-ad-insertion/sdk/ios/reference/Classes/IMAAdDisplayContainer.
@ProxyApi(
  swiftOptions: SwiftProxyApiOptions(import: 'GoogleInteractiveMediaAds'),
)
abstract class IMAAdDisplayContainer extends NSObject {
  /// Initializes IMAAdDisplayContainer for rendering the ad and displaying the
  /// sad UI.
  IMAAdDisplayContainer(UIViewController? adContainerViewController);

  /// View containing the video display and ad related UI.
  ///
  /// This view must be present in the view hierarchy in order to make ad or
  /// stream requests.
  late UIView adContainer;

  /// List of companion ad slots.
  late List<IMACompanionAdSlot>? companionSlots;

  /// View controller containing the ad container.
  void setAdContainerViewController(UIViewController? controller);

  /// View controller containing the ad container.
  UIViewController? getAdContainerViewController();

  /// Registers a view that overlays or obstructs this container as “friendly”
  /// for viewability measurement purposes.
  void registerFriendlyObstruction(IMAFriendlyObstruction friendlyObstruction);

  /// Unregisters all previously registered friendly obstructions.
  void unregisterAllFriendlyObstructions();
}

/// An object that manages the content for a rectangular area on the screen.
///
/// See https://developer.apple.com/documentation/uikit/uiview.
@ProxyApi(swiftOptions: SwiftProxyApiOptions(import: 'UIKit'))
abstract class UIView extends NSObject {}

/// An object that manages a view hierarchy for your UIKit app.
///
/// See https://developer.apple.com/documentation/uikit/uiviewcontroller.
@ProxyApi()
abstract class UIViewController extends NSObject {
  UIViewController();

  /// Notifies the view controller that its view was added to a view hierarchy.
  late void Function(bool animated)? viewDidAppear;

  /// Retrieves the view that the controller manages.
  ///
  /// For convenience this is a `final` attached field despite this being
  /// settable. Since this is not a part of the IMA SDK this is slightly changed
  /// for convenience. Note that this wrapper should not add the ability to set
  /// this property as it should not be needed anyways.
  @attached
  late final UIView view;
}

/// Defines an interface for a class that tracks video content progress and
/// exposes a key value observable property |currentTime|.
///
/// See https://developers.google.com/ad-manager/dynamic-ad-insertion/sdk/ios/reference/Protocols/IMAContentPlayhead.
@ProxyApi()
abstract class IMAContentPlayhead extends NSObject {
  IMAContentPlayhead();

  /// Reflects the current playback time in seconds for the content.
  void setCurrentTime(double timeInterval);
}

/// Allows the requesting of ads from the ad server.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Classes/IMAAdsLoader.
@ProxyApi()
abstract class IMAAdsLoader extends NSObject {
  IMAAdsLoader(IMASettings? settings);

  /// Signal to the SDK that the content has completed.
  void contentComplete();

  /// Request ads from the ad server.
  void requestAds(IMAAdsRequest request);

  /// Delegate that receives `IMAAdsLoaderDelegate` callbacks.
  ///
  /// Note that this sets to a `weak` property in Swift.
  void setDelegate(IMAAdsLoaderDelegate? delegate);
}

/// The IMASettings class stores SDK wide settings.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Classes/IMASettings.html.
@ProxyApi()
abstract class IMASettings extends NSObject {}

/// Data class describing the ad request.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Classes/IMAAdsRequest.
@ProxyApi()
abstract class IMAAdsRequest extends NSObject {
  /// Initializes an ads request instance with the given ad tag URL and ad
  /// display container.
  IMAAdsRequest(
    String adTagUrl,
    IMAAdDisplayContainer adDisplayContainer,
    IMAContentPlayhead? contentPlayhead,
  );
}

/// Delegate object that receives state change callbacks from `IMAAdsLoader`.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Protocols/IMAAdsLoaderDelegate.html.
@ProxyApi()
abstract class IMAAdsLoaderDelegate extends NSObject {
  IMAAdsLoaderDelegate();

  /// Called when ads are successfully loaded from the ad servers by the loader.
  late final void Function(
    IMAAdsLoader loader,
    IMAAdsLoadedData adsLoadedData,
  ) adLoaderLoadedWith;

  /// Error reported by the ads loader when loading or requesting an ad fails.
  late final void Function(
    IMAAdsLoader loader,
    IMAAdLoadingErrorData adErrorData,
  ) adsLoaderFailedWithErrorData;
}

/// Ad data that is returned when the ads loader loads the ad.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Classes/IMAAdsLoadedData.html.
@ProxyApi()
abstract class IMAAdsLoadedData extends NSObject {
  /// The ads manager instance created by the ads loader.
  ///
  /// Will be null when using dynamic ad insertion.
  IMAAdsManager? adsManager;
}

/// Ad error data that is returned when the ads loader fails to load the ad.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Classes/IMAAdLoadingErrorData.html.
@ProxyApi()
abstract class IMAAdLoadingErrorData extends NSObject {
  /// The ad error that occurred while loading the ad.
  late final IMAAdError adError;
}

/// Surfaces an error that occurred during ad loading or playing.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Classes/IMAAdError.html.
@ProxyApi()
abstract class IMAAdError extends NSObject {
  /// The type of error that occurred during ad loading or ad playing.
  late final AdErrorType type;

  /// The error code for obtaining more specific information about the error.
  late final AdErrorCode code;

  /// A brief description about the error.
  late final String? message;
}

/// Responsible for playing ads.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Classes/IMAAdsManager.html.
@ProxyApi()
abstract class IMAAdsManager extends NSObject {
  /// The `IMAAdsManagerDelegate` to notify with events during ad playback.
  void setDelegate(IMAAdsManagerDelegate? delegate);

  /// Initializes and loads the ad.
  void initialize(IMAAdsRenderingSettings? adsRenderingSettings);

  /// Starts advertisement playback.
  void start();

  /// Pauses advertisement.
  void pause();

  /// Resumes the current ad.
  void resume();

  /// Skips the advertisement if the ad is skippable and the skip offset has
  /// been reached.
  void skip();

  /// If an ad break is currently playing, discard it and resume content.
  void discardAdBreak();

  /// Causes the ads manager to stop the ad and clean its internal state.
  void destroy();
}

/// A callback protocol for IMAAdsManager.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Protocols/IMAAdsManagerDelegate.html.
@ProxyApi()
abstract class IMAAdsManagerDelegate extends NSObject {
  IMAAdsManagerDelegate();

  /// Called when there is an IMAAdEvent.
  late final void Function(
    IMAAdsManager adsManager,
    IMAAdEvent event,
  ) didReceiveAdEvent;

  /// Called when there was an error playing the ad.
  late final void Function(
    IMAAdsManager adsManager,
    IMAAdError error,
  ) didReceiveAdError;

  /// Called when an ad is ready to play.
  late final void Function(IMAAdsManager adsManager) didRequestContentPause;

  /// Called when an ad has finished or an error occurred during the playback.
  late final void Function(IMAAdsManager adsManager) didRequestContentResume;
}

/// Simple data class used to transport ad playback information.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Classes/IMAAdEvent.html.
@ProxyApi()
abstract class IMAAdEvent extends NSObject {
  /// Type of the event.
  late final AdEventType type;

  /// Stringified type of the event.
  late final String typeString;

  /// Extra data about the ad.
  late final Map<String, Object>? adData;
}

/// Set of properties that influence how ads are rendered.
///
/// See https://developers.google.com/ad-manager/dynamic-ad-insertion/sdk/ios/reference/Classes/IMAAdsRenderingSettings.
@ProxyApi()
abstract class IMAAdsRenderingSettings extends NSObject {
  IMAAdsRenderingSettings();

  /// If specified, the SDK will play the media with MIME type on the list.
  void setMimeTypes(List<String>? types);

  /// Maximum recommended bitrate.
  ///
  /// The value is in kbit/s.
  void setBitrate(int bitrate);

  /// Timeout (in seconds) when loading a video ad media file.
  ///
  /// Use -1 for the default of 8 seconds.
  void setLoadVideoTimeout(double seconds);

  /// For VMAP and ad rules playlists, only play ad breaks scheduled after this
  /// time (in seconds).
  void setPlayAdsAfterTime(double seconds);

  /// Specifies the list of UI elements that should be visible.
  void setUIElements(List<UIElementType>? types);

  /// Whether or not the SDK will preload ad media.
  ///
  /// Default is YES.
  void setEnablePreloading(bool enable);

  /// Specifies the optional UIViewController that will be used to open links
  /// in-app.
  void setLinkOpenerPresentingController(UIViewController controller);
}

/// The root class of most Objective-C class hierarchies, from which subclasses
/// inherit a basic interface to the runtime system and the ability to behave as
/// Objective-C objects.
///
/// See https://developer.apple.com/documentation/objectivec/nsobject.
@ProxyApi()
abstract class NSObject {}

/// An obstruction that is marked as “friendly” for viewability measurement
/// purposes.
///
/// See https://developers.google.com/ad-manager/dynamic-ad-insertion/sdk/ios/reference/Classes/IMAFriendlyObstruction.html.
@ProxyApi()
abstract class IMAFriendlyObstruction extends NSObject {
  /// Initializes a friendly obstruction.
  IMAFriendlyObstruction();

  /// The view causing the obstruction.
  late final UIView view;

  /// The purpose for registering the obstruction as friendly.
  late final FriendlyObstructionPurpose purpose;

  /// Optional, detailed reasoning for registering this obstruction as friendly.
  ///
  /// If the detailedReason is not null, it must follow the IAB standard by
  /// being 50 characters or less and only containing characters A-z, 0-9, or
  /// spaces.
  late final String? detailedReason;
}

/// An object that holds data corresponding to the companion ad.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Classes/IMACompanionAd.
@ProxyApi()
abstract class IMACompanionAd extends NSObject {
  /// The value for the resource of this companion.
  late final String? resourceValue;

  /// The API needed to execute this ad, or nil if unavailable.
  late final String? apiFramework;

  /// The width of the companion in pixels.
  ///
  /// 0 if unavailable.
  late final int width;

  /// The height of the companion in pixels.
  ///
  /// 0 if unavailable.
  late final int height;
}

/// Ad slot for companion ads.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Classes/IMACompanionAdSlot.
@ProxyApi()
abstract class IMACompanionAdSlot {
  /// Initializes an instance of a IMACompanionAdSlot with fluid size.
  IMACompanionAdSlot();

  /// Initializes an instance of a IMACompanionAdSlot with design ad width and
  /// height.
  ///
  /// `width` and `height` are in pixels.
  IMACompanionAdSlot.size(int width, int height);

  /// The view the companion will be rendered in.
  ///
  /// Display this view in your application before video ad starts.
  late final UIView view;

  /// The IMACompanionDelegate for receiving events from the companion ad slot.
  ///
  /// This instance only creates a weak reference to the delegate, so the Dart
  /// instance should create an explicit reference to receive callbacks.
  void setDelegate(IMACompanionDelegate? delegate);
}

/// Delegate to receive events from the companion ad slot.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Protocols/IMACompanionDelegate.html.
@ProxyApi()
abstract class IMACompanionDelegate extends NSObject {
  IMACompanionDelegate();

  /// Called when the slot is either filled or not filled.
  late void Function(
    IMACompanionAdSlot slot,
    bool filled,
  )? companionAdSlotFilled;

  /// Called when the slot is clicked on by the user and will successfully
  /// navigate away.
  late void Function(IMACompanionAdSlot slot)? companionSlotWasClicked;
}

/// Simple data object containing podding metadata.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Classes/IMAAdPodInfo.html.
@ProxyApi(
  swiftOptions: SwiftProxyApiOptions(import: 'GoogleInteractiveMediaAds'),
)
abstract class IMAAdPodInfo {
  /// The position of this ad within an ad pod.
  ///
  /// Will be 1 for standalone ads.
  late final int adPosition;

  /// The maximum duration of the pod in seconds.
  ///
  /// For unknown duration, -1 is returned.
  late final double maxDuration;

  /// Returns the index of the ad pod.
  ///
  /// Client side: For a preroll pod, returns 0. For midrolls, returns 1, 2,…,
  /// N. For a postroll pod, returns -1. Defaults to 0 if this ad is not part of
  /// a pod, or this pod is not part of a playlist.
  ///
  /// DAI VOD: Returns the index of the ad pod. For a preroll pod, returns 0.
  /// For midrolls, returns 1, 2,…,N. For a postroll pod, returns N+1…N+X.
  /// Defaults to 0 if this ad is not part of a pod, or this pod is not part of
  /// a playlist.
  ///
  /// DAI live stream: For a preroll pod, returns 0. For midrolls, returns the
  /// break ID. Returns -2 if pod index cannot be determined (internal error).
  late final int podIndex;

  /// The position of the pod in the content in seconds.
  ///
  /// Pre-roll returns 0, post-roll returns -1 and mid-rolls return the
  /// scheduled time of the pod.
  late final double timeOffset;

  /// Total number of ads in the pod this ad belongs to.
  ///
  /// Will be 1 for standalone ads.
  late final int totalAds;

  /// Specifies whether the ad is a bumper.
  ///
  /// Bumpers are short videos used to open and close ad breaks.
  late final bool isBumper;
}
