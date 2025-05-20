// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'interactive_media_ads.g.dart';

/// Handles constructing objects and calling static methods for the Android
/// Interactive Media Ads native library.
///
/// This class provides dependency injection for the implementations of the
/// platform interface classes. Improving the ease of unit testing and/or
/// overriding the underlying Android classes.
///
/// By default each function calls the default constructor of the class it
/// intends to return.
class InteractiveMediaAdsProxy {
  /// Constructs an [InteractiveMediaAdsProxy].
  const InteractiveMediaAdsProxy({
    this.newContentProgressProvider = ContentProgressProvider.new,
    this.newVideoProgressUpdate = VideoProgressUpdate.new,
    this.newFrameLayout = FrameLayout.new,
    this.newVideoView = VideoView.new,
    this.newVideoAdPlayer = VideoAdPlayer.new,
    this.newAdsLoadedListener = AdsLoadedListener.new,
    this.newAdErrorListener = AdErrorListener.new,
    this.newAdEventListener = AdEventListener.new,
    this.newCompanionAdSlotClickListener = CompanionAdSlotClickListener.new,
    this.createAdDisplayContainerImaSdkFactory =
        ImaSdkFactory.createAdDisplayContainer,
    this.instanceImaSdkFactory = _instanceImaSdkFactory,
    this.videoTimeNotReadyVideoProgressUpdate =
        _videoTimeNotReadyVideoProgressUpdate,
  });

  /// Constructs [ContentProgressProvider].
  final ContentProgressProvider Function() newContentProgressProvider;

  /// Constructs [VideoProgressUpdate].
  final VideoProgressUpdate Function({
    required int currentTimeMs,
    required int durationMs,
  }) newVideoProgressUpdate;

  /// Constructs [FrameLayout].
  final FrameLayout Function() newFrameLayout;

  /// Constructs [VideoView].
  final VideoView Function({
    required void Function(VideoView, MediaPlayer, int, int) onError,
    void Function(VideoView, MediaPlayer)? onPrepared,
    void Function(VideoView, MediaPlayer)? onCompletion,
  }) newVideoView;

  /// Constructs [VideoAdPlayer].
  final VideoAdPlayer Function({
    required void Function(VideoAdPlayer, VideoAdPlayerCallback) addCallback,
    required void Function(VideoAdPlayer, AdMediaInfo, AdPodInfo) loadAd,
    required void Function(VideoAdPlayer, AdMediaInfo) pauseAd,
    required void Function(VideoAdPlayer, AdMediaInfo) playAd,
    required void Function(VideoAdPlayer) release,
    required void Function(VideoAdPlayer, VideoAdPlayerCallback) removeCallback,
    required void Function(VideoAdPlayer, AdMediaInfo) stopAd,
  }) newVideoAdPlayer;

  /// Constructs [AdsLoadedListener].
  final AdsLoadedListener Function({
    required void Function(AdsLoadedListener, AdsManagerLoadedEvent)
        onAdsManagerLoaded,
  }) newAdsLoadedListener;

  /// Constructs [AdErrorListener].
  final AdErrorListener Function({
    required void Function(AdErrorListener, AdErrorEvent) onAdError,
  }) newAdErrorListener;

  /// Constructs [AdEventListener].
  final AdEventListener Function({
    required void Function(AdEventListener, AdEvent) onAdEvent,
  }) newAdEventListener;

  /// Constructs [CompanionAdSlotClickListener].
  final CompanionAdSlotClickListener Function({
    required void Function(CompanionAdSlotClickListener) onCompanionAdClick,
  }) newCompanionAdSlotClickListener;

  /// Calls to [ImaSdkFactory.createAdDisplayContainer].
  final Future<AdDisplayContainer> Function(ViewGroup, VideoAdPlayer)
      createAdDisplayContainerImaSdkFactory;

  /// Calls to [ImaSdkFactory.instance].
  final ImaSdkFactory Function() instanceImaSdkFactory;

  /// Calls to [VideoProgressUpdate.videoTimeNotReady].
  final VideoProgressUpdate Function() videoTimeNotReadyVideoProgressUpdate;

  static ImaSdkFactory _instanceImaSdkFactory() => ImaSdkFactory.instance;

  static VideoProgressUpdate _videoTimeNotReadyVideoProgressUpdate() =>
      VideoProgressUpdate.videoTimeNotReady;
}
