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
///
/// This acts as the video player for an ad. To be a player for an ad from the
/// IMA SDK:
/// 1. The [ima.VideoView] must be in the View hierarchy until all ads have
/// finished.
/// 2. Must respond to callbacks from the [ima.VideoAdPlayer].
/// 3. Must trigger methods for [ima.VideoAdPlayerCallback]s that provide ad
/// playback information to the IMA SDK. [ima.VideoAdPlayerCallback]s are
/// provided by [ima.VideoAdPlayer.addCallback].
/// 4. Must create an [ima.AdDisplayContainer] with the `ViewGroup` that
/// contains the `VideoView`.
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
  // currently playing ad. This value matches the one used in the Android
  // example.
  // See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side#6.-create-the-videoadplayeradapter-class
  static const int _progressPollingMs = 250;

  // The `ViewGroup` used to create the native `ima.AdDisplayContainer`. The
  // `View` that handles playing an ad is added as a child to this `ViewGroup`.
  late final ima.FrameLayout _frameLayout =
      _androidParams._imaProxy.newFrameLayout();

  // Handles loading and displaying an ad.
  late ima.VideoView _videoView;

  // After an ad is loaded in the `VideoView`, this is used to control
  // playback.
  ima.MediaPlayer? _mediaPlayer;

  /// Methods that must be triggered to update the IMA SDK of the state of
  /// playback of an ad.
  @internal
  final Set<ima.VideoAdPlayerCallback> videoAdPlayerCallbacks =
      <ima.VideoAdPlayerCallback>{};

  // Handles ad playback callbacks from the IMA SDK. For a player to be used for
  // ad playback, the callbacks in this class must be implemented. This also
  // provides `VideoAdPlayerCallback`s that contain methods that must be
  // triggered by the player.
  late final ima.VideoAdPlayer _videoAdPlayer;

  /// The native Android AdDisplayContainer.
  ///
  /// This holds the player for video ads.
  ///
  /// Created with the `ViewGroup` that contains the `View` that handles playing
  /// an ad.
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

  // Whether MediaPlayer.start() should be called whenever the VideoView
  // `onPrepared` callback is triggered. `onPrepared` is triggered whenever the
  // app is resumed after being inactive.
  bool _startPlayerWhenVideoIsPrepared = true;

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
      layoutDirection: params.layoutDirection,
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

  // Clears the current `MediaPlayer` and resets any saved position of an ad.
  // This should be used when current ad that is loaded in the `VideoView` is
  // complete, failed to load/play, or has been stopped.
  void _clearMediaPlayer() {
    _mediaPlayer = null;
    _savedAdPosition = 0;
  }

  // Starts periodically updating the IMA SDK the progress of the currently
  // playing ad.
  //
  // Setting a timer to periodically update the IMA SDK is also done in the
  // official Android example: https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side#8.-set-up-ad-tracking.
  void _startAdProgressTracking() {
    // Stop any previous ad tracking.
    _stopAdProgressTracking();
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
  void _stopAdProgressTracking() {
    _adProgressTimer?.cancel();
    _adProgressTimer = null;
  }

  // This value is created in a static method because the callback methods for
  // any wrapped classes must not reference the encapsulating object. This is to
  // prevent a circular reference that prevents garbage collection.
  static ima.VideoView _setUpVideoView(
    WeakReference<AndroidAdDisplayContainer> weakThis,
  ) {
    return weakThis.target!._androidParams._imaProxy.newVideoView(
      onCompletion: (_, __) {
        final AndroidAdDisplayContainer? container = weakThis.target;
        if (container != null) {
          container._clearMediaPlayer();
          container._stopAdProgressTracking();
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

          if (container._startPlayerWhenVideoIsPrepared) {
            await player.start();
            container._startAdProgressTracking();
          }
        }
      },
      onError: (_, __, ___, ____) {
        final AndroidAdDisplayContainer? container = weakThis.target;
        if (container != null) {
          container._clearMediaPlayer();
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

  // This value is created in a static method because the callback methods for
  // any wrapped classes must not reference the encapsulating object. This is to
  // prevent a circular reference that prevents garbage collection.
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
          // Setting this to false ensures the ad doesn't start playing if an
          // app is returned to the foreground.
          container._startPlayerWhenVideoIsPrepared = false;
          await container._mediaPlayer!.pause();
          container._savedAdPosition =
              await container._videoView.getCurrentPosition();
          container._stopAdProgressTracking();
        }
      },
      playAd: (_, ima.AdMediaInfo adMediaInfo) {
        final AndroidAdDisplayContainer? container = weakThis.target;
        if (container != null) {
          container._startPlayerWhenVideoIsPrepared = true;
          container._videoView.setVideoUri(adMediaInfo.url);
        }
      },
      release: (_) {},
      stopAd: (_, __) {
        final AndroidAdDisplayContainer? container = weakThis.target;
        if (container != null) {
          // Clear and reset all state.
          container._stopAdProgressTracking();

          container._frameLayout.removeView(container._videoView);
          container._videoView = _setUpVideoView(
            WeakReference<AndroidAdDisplayContainer>(container),
          );
          container._frameLayout.addView(container._videoView);

          container._clearMediaPlayer();
          container._loadedAdMediaInfo = null;
          container._adDuration = null;
          container._startPlayerWhenVideoIsPrepared = true;
        }
      },
    );
  }
}
