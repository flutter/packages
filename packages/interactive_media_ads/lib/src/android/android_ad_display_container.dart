// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../platform_interface/platform_interface.dart';
import 'android_companion_ad_slot.dart';
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
    super.companionSlots,
    @visibleForTesting InteractiveMediaAdsProxy? imaProxy,
    @visibleForTesting PlatformViewsServiceProxy? platformViewsProxy,
  }) : _imaProxy = imaProxy ?? const InteractiveMediaAdsProxy(),
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
      companionSlots: params.companionSlots,
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

  // Queue of ads to be played.
  final Queue<ima.AdMediaInfo> _loadedAdMediaInfoQueue =
      Queue<ima.AdMediaInfo>();

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
          : AndroidAdDisplayContainerCreationParams.fromPlatformAdDisplayContainerCreationParams(
            params,
          );

  @override
  Widget build(BuildContext context) {
    return _AdPlayer(this);
  }

  // Clears the current `MediaPlayer` and resets any saved position of an ad.
  // This should be used when current ad that is loaded in the `VideoView` is
  // complete, failed to load/play, or has been stopped.
  void _clearMediaPlayer() {
    _mediaPlayer = null;
    _savedAdPosition = 0;
  }

  // Resets the state to before an ad is loaded and releases references to all
  // ads and callbacks.
  void _release() {
    _resetStateForNextAd();
    _loadedAdMediaInfoQueue.clear();
    videoAdPlayerCallbacks.clear();
  }

  // Clears the state to before ad is loaded and replace current VideoView with
  // a new one.
  void _resetStateForNextAd() {
    _stopAdProgressTracking();

    // The `VideoView` is replaced to clear the last frame of the last loaded
    // ad. See https://stackoverflow.com/questions/25660994/clear-video-frame-from-surfaceview-on-video-complete.
    _frameLayout.removeView(_videoView);
    _videoView = _setUpVideoView(
      WeakReference<AndroidAdDisplayContainer>(this),
    );
    _frameLayout.addView(_videoView);

    _clearMediaPlayer();
    if (_loadedAdMediaInfoQueue.isNotEmpty) {
      _loadedAdMediaInfoQueue.removeFirst();
    }
    _adDuration = null;
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
        final int videoCurrentPosition = await _videoView.getCurrentPosition();
        if (_adDuration case final int adDuration) {
          final ima.VideoProgressUpdate currentProgress = _androidParams
              ._imaProxy
              .newVideoProgressUpdate(
                currentTimeMs: videoCurrentPosition,
                durationMs: adDuration,
              );

          await Future.wait(<Future<void>>[
            _videoAdPlayer.setAdProgress(currentProgress),

            if (_loadedAdMediaInfoQueue.firstOrNull
                case final ima.AdMediaInfo loadedAdMediaInfo)
              ...videoAdPlayerCallbacks.map(
                (ima.VideoAdPlayerCallback callback) =>
                    callback.onAdProgress(loadedAdMediaInfo, currentProgress),
              ),
          ]);
        }
      },
    );
  }

  // Stops updating the IMA SDK the progress of the currently playing ad.
  void _stopAdProgressTracking() {
    _adProgressTimer?.cancel();
    _adProgressTimer = null;
  }

  /// Load the first ad in the queue.
  Future<void> _loadCurrentAd() {
    _startPlayerWhenVideoIsPrepared = false;
    return Future.wait(<Future<void>>[
      // Audio focus is set to none to prevent the `VideoView` from requesting
      // focus while loading the app in the background.
      _videoView.setAudioFocusRequest(ima.AudioManagerAudioFocus.none),
      _videoView.setVideoUri(_loadedAdMediaInfoQueue.first.url),
    ]);
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
            callback.onEnded(container._loadedAdMediaInfoQueue.first);
          }
        }
      },
      onPrepared: (_, ima.MediaPlayer player) async {
        final AndroidAdDisplayContainer? container = weakThis.target;
        if (container != null) {
          container._mediaPlayer = player;
          container._adDuration = await player.getDuration();
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
            callback.onError(container._loadedAdMediaInfoQueue.first);
          }
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
        final AndroidAdDisplayContainer? container = weakThis.target;
        if (container != null) {
          container._loadedAdMediaInfoQueue.add(adMediaInfo);
          if (container._loadedAdMediaInfoQueue.length == 1) {
            container._loadCurrentAd();
          }
        }
      },
      pauseAd: (_, __) async {
        final AndroidAdDisplayContainer? container = weakThis.target;
        final ima.MediaPlayer? player = container?._mediaPlayer;
        if (container != null && player != null) {
          // Setting this to false ensures the ad doesn't start playing if an
          // app is returned to the foreground.
          container._startPlayerWhenVideoIsPrepared = false;
          await player.pause();
          container._savedAdPosition =
              await container._videoView.getCurrentPosition();
          container._stopAdProgressTracking();
          await Future.wait(<Future<void>>[
            for (final ima.VideoAdPlayerCallback callback
                in container.videoAdPlayerCallbacks)
              callback.onPause(container._loadedAdMediaInfoQueue.first),
          ]);
        }
      },
      playAd: (_, ima.AdMediaInfo adMediaInfo) {
        final AndroidAdDisplayContainer? container = weakThis.target;
        if (container != null) {
          assert(container._loadedAdMediaInfoQueue.first == adMediaInfo);

          container._videoView.setAudioFocusRequest(
            ima.AudioManagerAudioFocus.gain,
          );

          if (container._mediaPlayer != null) {
            container._mediaPlayer!.start().then(
              (_) => container._startAdProgressTracking(),
            );
          }
          container._startPlayerWhenVideoIsPrepared = true;

          for (final ima.VideoAdPlayerCallback callback
              in container.videoAdPlayerCallbacks) {
            if (container._savedAdPosition == 0) {
              callback.onPlay(adMediaInfo);
            } else {
              callback.onResume(adMediaInfo);
            }
          }
        }
      },
      release: (_) => weakThis.target?._release(),
      stopAd: (_, __) {
        final AndroidAdDisplayContainer? container = weakThis.target;
        if (container != null) {
          container._resetStateForNextAd();
          if (container._loadedAdMediaInfoQueue.isNotEmpty) {
            container._loadCurrentAd();
          }
        }
      },
    );
  }
}

// Widget for displaying the native ViewGroup of the AdDisplayContainer.
//
// When the app is sent to the background, the state of the underlying native
// `VideoView` is not maintained. So this widget uses `WidgetsBindingObserver`
// to listen and react to lifecycle events.
class _AdPlayer extends StatefulWidget {
  _AdPlayer(this.container) : super(key: container._androidParams.key);

  final AndroidAdDisplayContainer container;

  @override
  State<StatefulWidget> createState() => _AdPlayerState();
}

class _AdPlayerState extends State<_AdPlayer> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final AndroidAdDisplayContainer container = widget.container;
    switch (state) {
      case AppLifecycleState.resumed:
        if (container._loadedAdMediaInfoQueue.isNotEmpty) {
          container._loadCurrentAd();
        }
      case AppLifecycleState.paused:
        container._mediaPlayer = null;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
    }
  }

  @override
  Widget build(BuildContext context) {
    return AndroidViewWidget(
      view: widget.container._frameLayout,
      platformViewsServiceProxy:
          widget.container._androidParams._platformViewsProxy,
      layoutDirection: widget.container._androidParams.layoutDirection,
      onPlatformViewCreated: () async {
        final ima.AdDisplayContainer nativeContainer = await widget
            .container
            ._androidParams
            ._imaProxy
            .createAdDisplayContainerImaSdkFactory(
              widget.container._frameLayout,
              widget.container._videoAdPlayer,
            );
        final Iterable<ima.CompanionAdSlot> nativeCompanionSlots =
            await Future.wait(
              widget.container._androidParams.companionSlots.map((
                PlatformCompanionAdSlot slot,
              ) {
                return (slot as AndroidCompanionAdSlot)
                    .getNativeCompanionAdSlot();
              }),
            );
        await nativeContainer.setCompanionSlots(nativeCompanionSlots.toList());

        widget.container.adDisplayContainer = nativeContainer;
        widget.container.params.onContainerAdded(widget.container);
      },
    );
  }
}
