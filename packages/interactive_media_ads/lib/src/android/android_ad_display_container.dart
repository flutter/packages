// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../platform_interface/platform_interface.dart';
import 'android_view_widget.dart';
import 'interactive_media_ads.g.dart' as ima;

/// Android implementation of [PlatformAdDisplayContainer].
final class AndroidAdDisplayContainer extends PlatformAdDisplayContainer {
  /// Constructs an [AndroidAdDisplayContainer].
  AndroidAdDisplayContainer(super.params) : super.implementation() {
    _videoView = _setUpVideoView(
      WeakReference<AndroidAdDisplayContainer>(this),
    );
    _frameLayout.addView(_videoView);
  }

  final ima.FrameLayout _frameLayout = ima.FrameLayout();
  final Set<ima.VideoAdPlayerCallback> _videoAdPlayerCallbacks =
      <ima.VideoAdPlayerCallback>{};
  late final ima.VideoView _videoView;
  ima.AdMediaInfo? _loadedAdMediaInfo;
  // The saved ad position, used to resumed ad playback following an ad click-through.
  int _savedAdPosition = 0;
  ima.MediaPlayer? _mediaPlayer;
  late final ima.AdDisplayContainer _adDisplayContainer;

  @override
  Widget build(BuildContext context) {
    return AndroidViewWidget(
      view: _frameLayout,
      onPlatformViewCreated: () async {
        _adDisplayContainer = await _setUpAdDisplayContainer(
          WeakReference<AndroidAdDisplayContainer>(this),
        );
        params.onContainerAdded(this);
      },
    );
  }

  void _resetPlayer() {
    _mediaPlayer = null;
    _savedAdPosition = 0;
  }

  static ima.VideoView _setUpVideoView(
    WeakReference<AndroidAdDisplayContainer> weakThis,
  ) {
    return ima.VideoView(
      onCompletion: (_, ima.MediaPlayer player) {
        weakThis.target?._resetPlayer();
      },
      onPrepared: (_, ima.MediaPlayer player) {
        final AndroidAdDisplayContainer? container = weakThis.target;
        if (container != null) {
          container._mediaPlayer = player;
          if (container._savedAdPosition > 0) {
            player.seekTo(container._savedAdPosition);
          }
        }

        player.start();
      },
      onError: (_, ima.MediaPlayer player, int what, int extra) {
        final AndroidAdDisplayContainer? container = weakThis.target;
        if (container != null) {
          container._resetPlayer();
          for (final ima.VideoAdPlayerCallback callback
              in container._videoAdPlayerCallbacks) {
            callback.onError(container._loadedAdMediaInfo!);
          }
        }
      },
    );
  }

  static Future<ima.AdDisplayContainer> _setUpAdDisplayContainer(
    WeakReference<AndroidAdDisplayContainer> weakThis,
  ) async {
    return ima.ImaSdkFactory.createAdDisplayContainer(
      weakThis.target!._frameLayout,
      ima.VideoAdPlayer(
        addCallback: (_, ima.VideoAdPlayerCallback callback) {
          weakThis.target?._videoAdPlayerCallbacks.add(callback);
        },
        removeCallback: (_, ima.VideoAdPlayerCallback callback) {
          weakThis.target?._videoAdPlayerCallbacks.remove(callback);
        },
        loadAd: (_, ima.AdMediaInfo adMediaInfo, ima.AdPodInfo adPodInfo) {
          weakThis.target?._loadedAdMediaInfo = adMediaInfo;
        },
        pauseAd: (_, ima.AdMediaInfo adMediaInfo) async {
          final AndroidAdDisplayContainer? container = weakThis.target;
          if (container != null) {
            await container._mediaPlayer!.pause();
            container._savedAdPosition =
                await container._videoView.getCurrentPosition();
          }
        },
        playAd: (_, ima.AdMediaInfo adMediaInfo) {
          weakThis.target?._videoView.setVideoUri(adMediaInfo.url);
        },
        release: (_) {},
        stopAd: (_, ima.AdMediaInfo adMediaInfo) {
          final AndroidAdDisplayContainer? container = weakThis.target;
          if (container != null) {
            container._resetPlayer();
            container._loadedAdMediaInfo = null;
          }
        },
      ),
    );
  }
}

/// Android implementation of [PlatformAdsLoader].
final class AndroidAdsLoader extends PlatformAdsLoader {
  /// Constructs an [AndroidAdsLoader].
  AndroidAdsLoader(super.params)
      : assert(params.container is AndroidAdDisplayContainer),
        super.implementation() {
    _adsLoaderFuture = _createAdsLoader();
  }

  final ima.ImaSdkFactory _sdkFactory = ima.ImaSdkFactory.instance;
  late Future<ima.AdsLoader> _adsLoaderFuture;

  @override
  Future<void> contentComplete() async {
    final Set<ima.VideoAdPlayerCallback> callbacks =
        (params.container as AndroidAdDisplayContainer)._videoAdPlayerCallbacks;
    await Future.wait(
      callbacks.map(
        (ima.VideoAdPlayerCallback callback) => callback.onContentComplete(),
      ),
    );
  }

  @override
  Future<void> requestAds(AdsRequest request) async {
    final ima.AdsLoader adsLoader = await _adsLoaderFuture;

    final ima.AdsRequest androidRequest = await _sdkFactory.createAdsRequest();
    unawaited(androidRequest.setAdTagUrl(request.adTagUrl));

    await adsLoader.requestAds(androidRequest);
  }

  Future<ima.AdsLoader> _createAdsLoader() async {
    final ima.ImaSdkSettings settings =
        await _sdkFactory.createImaSdkSettings();

    final ima.AdsLoader adsLoader =
        await ima.ImaSdkFactory.instance.createAdsLoader(
      settings,
      (params.container as AndroidAdDisplayContainer)._adDisplayContainer,
    );

    _addListeners(WeakReference<AndroidAdsLoader>(this), adsLoader);

    return adsLoader;
  }

  static void _addListeners(
    WeakReference<AndroidAdsLoader> weakThis,
    ima.AdsLoader adsLoader,
  ) {
    adsLoader.addAdsLoadedListener(ima.AdsLoadedListener(
      onAdsManagerLoaded: (_, ima.AdsManagerLoadedEvent event) {
        weakThis.target?.params.onAdsLoaded(
          PlatformOnAdsLoadedData(manager: AndroidAdsManager._(event.manager)),
        );
      },
    ));
    adsLoader.addAdErrorListener(ima.AdErrorListener(
      onAdError: (_, ima.AdErrorEvent event) {
        final AdErrorType errorType = switch (event.error.errorType) {
          ima.AdErrorType.load => AdErrorType.loading,
          ima.AdErrorType.play => AdErrorType.playing,
          ima.AdErrorType.unknown => AdErrorType.unknown,
        };

        final AdErrorCode errorCode = switch (event.error.errorCode) {
          ima.AdErrorCode.adsPlayerWasNotProvided =>
            AdErrorCode.adsPlayerNotProvided,
          ima.AdErrorCode.unknownError => AdErrorCode.unknownError,
        };

        weakThis.target?.params.onAdsLoadError(
          AdsLoadErrorData(
            error: AdError(
              type: errorType,
              code: errorCode,
              message: event.error.message,
            ),
          ),
        );
      },
    ));
  }
}

/// Android implementation of [PlatformAdsManager].
class AndroidAdsManager extends PlatformAdsManager {
  AndroidAdsManager._(ima.AdsManager manager) : _manager = manager;

  final ima.AdsManager _manager;

  PlatformAdsManagerDelegate? _managerDelegate;

  @override
  Future<void> destroy() {
    return _manager.destroy();
  }

  @override
  Future<void> init(AdsManagerInitParams params) {
    return _manager.init();
  }

  @override
  Future<void> setAdsManagerDelegate(
    PlatformAdsManagerDelegate delegate,
  ) async {
    _managerDelegate = delegate;
    _addListeners(WeakReference<AndroidAdsManager>(this));
  }

  @override
  Future<void> start(AdsManagerStartParams params) {
    return _manager.start();
  }

  static void _addListeners(WeakReference<AndroidAdsManager> weakThis) {
    weakThis.target?._manager.addAdEventListener(
      ima.AdEventListener(
        onAdEvent: (_, ima.AdEvent event) {
          late final AdEventType eventType;

          switch (event.type) {
            case ima.AdEventType.allAdsCompleted:
              eventType = AdEventType.allAdsCompleted;
            case ima.AdEventType.completed:
              eventType = AdEventType.complete;
            case ima.AdEventType.contentPauseRequested:
              eventType = AdEventType.contentPauseRequested;
            case ima.AdEventType.contentResumeRequested:
              eventType = AdEventType.contentResumeRequested;
            case ima.AdEventType.loaded:
              eventType = AdEventType.loaded;
            case ima.AdEventType.unknown:
            case ima.AdEventType.adBreakReady:
            case ima.AdEventType.adBreakEnded:
            case ima.AdEventType.adBreakFetchError:
            case ima.AdEventType.adBreakStarted:
            case ima.AdEventType.adBuffering:
            case ima.AdEventType.adPeriodEnded:
            case ima.AdEventType.adPeriodStarted:
            case ima.AdEventType.adProgress:
            case ima.AdEventType.clicked:
            case ima.AdEventType.cuepointsChanged:
            case ima.AdEventType.firstQuartile:
            case ima.AdEventType.iconFallbackImageClosed:
            case ima.AdEventType.iconTapped:
            case ima.AdEventType.log:
            case ima.AdEventType.midpoint:
            case ima.AdEventType.paused:
            case ima.AdEventType.resumed:
            case ima.AdEventType.skippableStateChanged:
            case ima.AdEventType.skipped:
            case ima.AdEventType.started:
            case ima.AdEventType.tapped:
            case ima.AdEventType.thirdQuartile:
              return;
          }
          weakThis.target?._managerDelegate?.params.onAdEvent
              ?.call(AdEvent(type: eventType));
        },
      ),
    );
    weakThis.target?._manager.addAdErrorListener(
      ima.AdErrorListener(
        onAdError: (_, ima.AdErrorEvent event) {
          final AdErrorType errorType = switch (event.error.errorType) {
            ima.AdErrorType.load => AdErrorType.loading,
            ima.AdErrorType.play => AdErrorType.playing,
            ima.AdErrorType.unknown => AdErrorType.unknown,
          };

          final AdErrorCode errorCode = switch (event.error.errorCode) {
            ima.AdErrorCode.adsPlayerWasNotProvided =>
              AdErrorCode.adsPlayerNotProvided,
            ima.AdErrorCode.unknownError => AdErrorCode.unknownError,
          };

          weakThis.target?._managerDelegate?.params.onAdErrorEvent?.call(
            AdErrorEvent(
              error: AdError(
                type: errorType,
                code: errorCode,
                message: event.error.message,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Android implementation of [PlatformAdsManagerDelegate].
final class AndroidAdsManagerDelegate extends PlatformAdsManagerDelegate {
  /// Constructs an [AndroidAdsManagerDelegate].
  AndroidAdsManagerDelegate(super.params) : super.implementation();
}
