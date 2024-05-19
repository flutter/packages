// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../platform_interface/platform_interface.dart';
import 'android_view_widget.dart';
import 'interactive_media_ads.g.dart' as ima;
import 'interactive_media_ads_proxy.dart';
import 'platform_views_service_proxy.dart';

/// Android implementation of [PlatformAdDisplayContainerCreationParams].
final class AndroidAdDisplayContainerCreationParams
    extends PlatformAdDisplayContainerCreationParams {
  /// Constructs a [AndroidAdDisplayContainerCreationParams].
  const AndroidAdDisplayContainerCreationParams({
    super.key,
    required super.onContainerAdded,
    @visibleForTesting InteractiveMediaAdsProxy? imaProxy,
    @visibleForTesting PlatformViewsServiceProxy? platformViewsProxy,
  })  : _imaProxy = imaProxy ?? const InteractiveMediaAdsProxy(),
        _platformViewsProxy =
            platformViewsProxy ?? const PlatformViewsServiceProxy(),
        super();

  /// Creates a [AndroidAdDisplayContainerCreationParams] from an instance of
  /// [PlatformAdDisplayContainerCreationParams].
  factory AndroidAdDisplayContainerCreationParams.fromPlatformAdDisplayContainerCreationParams(
    PlatformAdDisplayContainerCreationParams params, {
    @visibleForTesting InteractiveMediaAdsProxy? imaProxy,
    @visibleForTesting PlatformViewsServiceProxy? platformViewsProxy,
  }) {
    return AndroidAdDisplayContainerCreationParams(
      key: params.key,
      onContainerAdded: params.onContainerAdded,
      imaProxy: imaProxy,
      platformViewsProxy: platformViewsProxy,
    );
  }

  final InteractiveMediaAdsProxy _imaProxy;
  final PlatformViewsServiceProxy _platformViewsProxy;
}

/// Android implementation of [PlatformAdDisplayContainer].
final class AndroidAdDisplayContainer extends PlatformAdDisplayContainer {
  /// Constructs an [AndroidAdDisplayContainer].
  AndroidAdDisplayContainer(super.params) : super.implementation() {
    final WeakReference<AndroidAdDisplayContainer> weakThis =
        WeakReference<AndroidAdDisplayContainer>(this);
    _videoView = _setUpVideoView(weakThis);
    _frameLayout.addView(_videoView);
    _videoAdPlayer = _setUpVideoAdPlayer(weakThis);
  }

  // The duration between each update to the IMA SDK of the progress of the
  // currently playing ad.
  static const int _progressPollingMs = 250;

  // ViewGroup used to create the `ima.AdDisplayContainer`.
  late final ima.FrameLayout _frameLayout =
      _androidParams._imaProxy.newFrameLayout();

  // Handles ad playback.
  late final ima.VideoView _videoView;
  ima.MediaPlayer? _mediaPlayer;

  // Callbacks that must be called to update to the state of ad playback.
  final Set<ima.VideoAdPlayerCallback> _videoAdPlayerCallbacks =
      <ima.VideoAdPlayerCallback>{};

  // Handles ad playback callbacks from the IMA SDK.
  late final ima.VideoAdPlayer _videoAdPlayer;

  late final ima.AdDisplayContainer _adDisplayContainer;

  // Currently loaded ad.
  ima.AdMediaInfo? _loadedAdMediaInfo;

  // The saved ad position, used to resumed ad playback following an ad
  // click-through.
  int _savedAdPosition = 0;

  // Timer used to periodically update the IMA SDK the progress of the currently
  // playing ad.
  Timer? _adProgressTimer;
  int? _adDuration;

  late final AndroidAdDisplayContainerCreationParams _androidParams =
      params is AndroidAdDisplayContainerCreationParams
          ? params as AndroidAdDisplayContainerCreationParams
          : AndroidAdDisplayContainerCreationParams
              .fromPlatformAdDisplayContainerCreationParams(params);

  @override
  Widget build(BuildContext context) {
    return AndroidViewWidget(
      key: params.key,
      view: _frameLayout,
      platformViewsServiceProxy: _androidParams._platformViewsProxy,
      onPlatformViewCreated: () async {
        _adDisplayContainer = await _androidParams._imaProxy
            .createAdDisplayContainerImaSdkFactory(
          _frameLayout,
          _videoAdPlayer,
        );
        params.onContainerAdded(this);
      },
    );
  }

  void _resetPlayer() {
    _mediaPlayer = null;
    _savedAdPosition = 0;
    _adDuration = null;
  }

  // Starts periodically updating the IMA SDK the current progress of the
  // currently playing ad.
  void _startAdTracking() {
    _adProgressTimer = Timer.periodic(
      const Duration(milliseconds: _progressPollingMs),
      (Timer timer) async {
        final ima.VideoProgressUpdate currentProgress =
            _androidParams._imaProxy.newVideoProgressUpdate(
          currentTimeMs: await _videoView.getCurrentPosition(),
          durationMs: _adDuration!,
        );
        await Future.wait(
          <Future<void>>[
            _videoAdPlayer.setAdProgress(currentProgress),
            ..._videoAdPlayerCallbacks.map(
              (ima.VideoAdPlayerCallback callback) async {
                await callback.onAdProgress(
                  _loadedAdMediaInfo!,
                  currentProgress,
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Stops periodically updating the IMA SDK the current progress of the
  // currently playing ad.
  void _stopAdTracking() {
    _adProgressTimer?.cancel();
    _adProgressTimer = null;
  }

  static ima.VideoView _setUpVideoView(
    WeakReference<AndroidAdDisplayContainer> weakThis,
  ) {
    return weakThis.target!._androidParams._imaProxy.newVideoView(
      onCompletion: (_, __) {
        final AndroidAdDisplayContainer? container = weakThis.target;
        if (container != null) {
          weakThis.target?._resetPlayer();
          for (final ima.VideoAdPlayerCallback callback
              in container._videoAdPlayerCallbacks) {
            callback.onEnded(container._loadedAdMediaInfo!);
          }
        }
      },
      onPrepared: (_, ima.MediaPlayer player) async {
        final AndroidAdDisplayContainer? container = weakThis.target;
        if (container != null) {
          container._adDuration = await player.getDuration();
          container._mediaPlayer = player;
          if (container._savedAdPosition > 0) {
            await player.seekTo(container._savedAdPosition);
          }
        }

        await player.start();
        container?._startAdTracking();
      },
      onError: (_, __, ___, ____) {
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

  static ima.VideoAdPlayer _setUpVideoAdPlayer(
    WeakReference<AndroidAdDisplayContainer> weakThis,
  ) {
    return weakThis.target!._androidParams._imaProxy.newVideoAdPlayer(
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
          container._stopAdTracking();
        }
      },
      playAd: (_, ima.AdMediaInfo adMediaInfo) {
        weakThis.target?._videoView.setVideoUri(adMediaInfo.url);
      },
      release: (_) {},
      stopAd: (_, ima.AdMediaInfo adMediaInfo) {
        final AndroidAdDisplayContainer? container = weakThis.target;
        if (container != null) {
          container._stopAdTracking();
          container._resetPlayer();
          container._loadedAdMediaInfo = null;
        }
      },
    );
  }
}

/// Android implementation of [PlatformAdsLoaderCreationParams].
final class AndroidAdsLoaderCreationParams
    extends PlatformAdsLoaderCreationParams {
  /// Constructs a [AndroidAdsLoaderCreationParams].
  const AndroidAdsLoaderCreationParams({
    required super.container,
    required super.onAdsLoaded,
    required super.onAdsLoadError,
    InteractiveMediaAdsProxy? proxy,
  })  : _proxy = proxy ?? const InteractiveMediaAdsProxy(),
        super();

  /// Creates a [AndroidAdsLoaderCreationParams] from an instance of
  /// [PlatformAdsLoaderCreationParams].
  factory AndroidAdsLoaderCreationParams.fromPlatformAdsLoaderCreationParams(
    PlatformAdsLoaderCreationParams params, {
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
  }) {
    return AndroidAdsLoaderCreationParams(
      container: params.container,
      onAdsLoaded: params.onAdsLoaded,
      onAdsLoadError: params.onAdsLoadError,
      proxy: proxy,
    );
  }

  final InteractiveMediaAdsProxy _proxy;
}

/// Android implementation of [PlatformAdsLoader].
final class AndroidAdsLoader extends PlatformAdsLoader {
  /// Constructs an [AndroidAdsLoader].
  AndroidAdsLoader(super.params)
      : assert(params.container is AndroidAdDisplayContainer),
        super.implementation() {
    _adsLoaderFuture = _createAdsLoader();
  }

  late final ima.ImaSdkFactory _sdkFactory =
      _androidParams._proxy.instanceImaSdkFactory();
  late Future<ima.AdsLoader> _adsLoaderFuture;

  late final AndroidAdsLoaderCreationParams _androidParams =
      params is AndroidAdsLoaderCreationParams
          ? params as AndroidAdsLoaderCreationParams
          : AndroidAdsLoaderCreationParams.fromPlatformAdsLoaderCreationParams(
              params,
            );

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

    final ima.AdsLoader adsLoader = await _androidParams._proxy
        .instanceImaSdkFactory()
        .createAdsLoader(
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
    final InteractiveMediaAdsProxy proxy =
        weakThis.target!._androidParams._proxy;
    adsLoader.addAdsLoadedListener(proxy.newAdsLoadedListener(
      onAdsManagerLoaded: (_, ima.AdsManagerLoadedEvent event) {
        weakThis.target?.params.onAdsLoaded(
          PlatformOnAdsLoadedData(manager: AndroidAdsManager(event.manager)),
        );
      },
    ));
    adsLoader.addAdErrorListener(proxy.newAdErrorListener(
      onAdError: (_, ima.AdErrorEvent event) {
        weakThis.target?.params.onAdsLoadError(
          AdsLoadErrorData(
            error: AdError(
              type: event.error.errorType.asInterfaceErrorType(),
              code: event.error.errorCode.asInterfaceErrorCode(),
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
  /// Constructs an [AndroidAdsManager].
  AndroidAdsManager(
    ima.AdsManager manager, {
    InteractiveMediaAdsProxy? proxy,
  })  : _manager = manager,
        _proxy = proxy ?? const InteractiveMediaAdsProxy();

  final ima.AdsManager _manager;
  final InteractiveMediaAdsProxy _proxy;

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
    final InteractiveMediaAdsProxy proxy = weakThis.target!._proxy;
    weakThis.target?._manager.addAdEventListener(
      proxy.newAdEventListener(
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
            case ima.AdEventType.clicked:
              eventType = AdEventType.clicked;
            case ima.AdEventType.unknown:
            case ima.AdEventType.adBreakReady:
            case ima.AdEventType.adBreakEnded:
            case ima.AdEventType.adBreakFetchError:
            case ima.AdEventType.adBreakStarted:
            case ima.AdEventType.adBuffering:
            case ima.AdEventType.adPeriodEnded:
            case ima.AdEventType.adPeriodStarted:
            case ima.AdEventType.adProgress:
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
      proxy.newAdErrorListener(
        onAdError: (_, ima.AdErrorEvent event) {
          weakThis.target?._managerDelegate?.params.onAdErrorEvent?.call(
            AdErrorEvent(
              error: AdError(
                type: event.error.errorType.asInterfaceErrorType(),
                code: event.error.errorCode.asInterfaceErrorCode(),
                message: event.error.message,
              ),
            ),
          );
          weakThis.target?._manager.discardAdBreak();
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

extension on ima.AdErrorType {
  AdErrorType asInterfaceErrorType() {
    return switch (this) {
      ima.AdErrorType.load => AdErrorType.loading,
      ima.AdErrorType.play => AdErrorType.playing,
      ima.AdErrorType.unknown => AdErrorType.unknown,
    };
  }
}

extension on ima.AdErrorCode {
  AdErrorCode asInterfaceErrorCode() {
    return switch (this) {
      ima.AdErrorCode.adsPlayerWasNotProvided =>
        AdErrorCode.adsPlayerNotProvided,
      ima.AdErrorCode.adsRequestNetworkError =>
        AdErrorCode.adsRequestNetworkError,
      ima.AdErrorCode.companionAdLoadingFailed =>
        AdErrorCode.companionAdLoadingFailed,
      ima.AdErrorCode.failedToRequestAds => AdErrorCode.failedToRequestAds,
      ima.AdErrorCode.internalError => AdErrorCode.internalError,
      ima.AdErrorCode.invalidArguments => AdErrorCode.invalidArguments,
      ima.AdErrorCode.overlayAdLoadingFailed =>
        AdErrorCode.overlayAdLoadingFailed,
      ima.AdErrorCode.overlayAdPlayingFailed =>
        AdErrorCode.overlayAdPlayingFailed,
      ima.AdErrorCode.playlistNoContentTracking =>
        AdErrorCode.playlistNoContentTracking,
      ima.AdErrorCode.unexpectedAdsLoadedEvent =>
        AdErrorCode.unexpectedAdsLoadedEvent,
      ima.AdErrorCode.unknownAdResponse => AdErrorCode.unknownAdResponse,
      ima.AdErrorCode.unknownError => AdErrorCode.unknownError,
      ima.AdErrorCode.vastAssetNotFound => AdErrorCode.vastAssetNotFound,
      ima.AdErrorCode.vastEmptyResponse => AdErrorCode.vastEmptyResponse,
      ima.AdErrorCode.vastLinearAssetMismatch =>
        AdErrorCode.vastLinearAssetMismatch,
      ima.AdErrorCode.vastLoadTimeout => AdErrorCode.vastLoadTimeout,
      ima.AdErrorCode.vastMalformedResponse =>
        AdErrorCode.vastMalformedResponse,
      ima.AdErrorCode.vastMediaLoadTimeout => AdErrorCode.vastMediaLoadTimeout,
      ima.AdErrorCode.vastNonlinearAssetMismatch =>
        AdErrorCode.vastNonlinearAssetMismatch,
      ima.AdErrorCode.vastNoAdsAfterWrapper =>
        AdErrorCode.vastNoAdsAfterWrapper,
      ima.AdErrorCode.vastTooManyRedirects => AdErrorCode.vastTooManyRedirects,
      ima.AdErrorCode.vastTraffickingError => AdErrorCode.vastTraffickingError,
      ima.AdErrorCode.videoPlayError => AdErrorCode.videoPlayError,
    };
  }
}
