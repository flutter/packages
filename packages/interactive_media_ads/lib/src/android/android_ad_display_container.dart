// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

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
base class AndroidAdDisplayContainer extends PlatformAdDisplayContainer {
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

  /// Callbacks that update the state of ad playback.
  @internal
  final Set<ima.VideoAdPlayerCallback> videoAdPlayerCallbacks =
      <ima.VideoAdPlayerCallback>{};

  // Handles ad playback callbacks from the IMA SDK.
  late final ima.VideoAdPlayer _videoAdPlayer;

  /// The native Android AdDisplayContainer.
  @internal
  ima.AdDisplayContainer? adDisplayContainer;

  // Currently loaded ad.
  ima.AdMediaInfo? _loadedAdMediaInfo;

  // The saved ad position, used to resume ad playback following an ad
  // click-through.
  int _savedAdPosition = 0;

  // Timer used to periodically update the IMA SDK of the progress of the
  // currently playing ad.
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
        adDisplayContainer = await _androidParams._imaProxy
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
  }

  // Starts periodically updating the IMA SDK the progress of the currently
  // playing ad.
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
            ...videoAdPlayerCallbacks.map(
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

  // Stops updating the IMA SDK the progress of the currently playing ad.
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
              in container.videoAdPlayerCallbacks) {
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
              in container.videoAdPlayerCallbacks) {
            callback.onError(container._loadedAdMediaInfo!);
          }
          container._loadedAdMediaInfo = null;
          container._adDuration = null;
        }
      },
    );
  }

  static ima.VideoAdPlayer _setUpVideoAdPlayer(
    WeakReference<AndroidAdDisplayContainer> weakThis,
  ) {
    return weakThis.target!._androidParams._imaProxy.newVideoAdPlayer(
      addCallback: (_, ima.VideoAdPlayerCallback callback) {
        weakThis.target?.videoAdPlayerCallbacks.add(callback);
      },
      removeCallback: (_, ima.VideoAdPlayerCallback callback) {
        weakThis.target?.videoAdPlayerCallbacks.remove(callback);
      },
      loadAd: (_, ima.AdMediaInfo adMediaInfo, __) {
        weakThis.target?._loadedAdMediaInfo = adMediaInfo;
      },
      pauseAd: (_, __) async {
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
      stopAd: (_, __) {
        final AndroidAdDisplayContainer? container = weakThis.target;
        if (container != null) {
          container._stopAdTracking();
          container._resetPlayer();
          container._loadedAdMediaInfo = null;
          container._adDuration = null;
        }
      },
    );
  }
}
