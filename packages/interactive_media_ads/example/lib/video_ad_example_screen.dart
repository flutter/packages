// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:video_player/video_player.dart';

/// Example widget displaying an Ad before a video.
class VideoAdExampleScreen extends StatefulWidget {
  /// Constructs an [VideoAdExampleScreen].
  const VideoAdExampleScreen({
    super.key,
    required this.adType,
    required this.adTagUrl,
    this.enablePreloading = true,
  });

  /// The URL from which ads will be requested.
  final String adTagUrl;

  /// Allows the player to preload the ad at any point before
  /// [AdsManager.start].
  final bool enablePreloading;

  /// The type of ads that will be requested.
  final String adType;

  @override
  State<VideoAdExampleScreen> createState() => _VideoAdExampleScreenState();
}

class _VideoAdExampleScreenState extends State<VideoAdExampleScreen>
    with WidgetsBindingObserver {
  // The AdsLoader instance exposes the request ads method.
  late final AdsLoader _adsLoader;

  // AdsManager exposes methods to control ad playback and listen to ad events.
  AdsManager? _adsManager;

  // Last state received in `didChangeAppLifecycleState`.
  AppLifecycleState _lastLifecycleState = AppLifecycleState.resumed;

  // Whether the widget should be displaying the content video. The content
  // player is hidden while Ads are playing.
  bool _shouldShowContentVideo = false;

  // Controls the content video player.
  late final VideoPlayerController _contentVideoController;

  // Periodically updates the SDK of the current playback progress of the
  // content video.
  Timer? _contentProgressTimer;

  // Provides the SDK with the current playback progress of the content video.
  // This is required to support mid-roll ads.
  final ContentProgressProvider _contentProgressProvider =
      ContentProgressProvider();

  late final CompanionAdSlot companionAd = CompanionAdSlot(
    size: CompanionAdSlotSize.fixed(width: 300, height: 250),
    onClicked: () => debugPrint('Companion Ad Clicked'),
  );

  late final AdDisplayContainer _adDisplayContainer = AdDisplayContainer(
    companionSlots: <CompanionAdSlot>[companionAd],
    onContainerAdded: (AdDisplayContainer container) {
      _adsLoader = AdsLoader(
        container: container,
        onAdsLoaded: (OnAdsLoadedData data) {
          debugPrint('OnAdsLoaded: (cuePoints: ${data.manager.adCuePoints})');
          final AdsManager manager = data.manager;
          _adsManager = data.manager;

          manager.setAdsManagerDelegate(
            AdsManagerDelegate(
              onAdEvent: (AdEvent event) {
                debugPrint('OnAdEvent: ${event.type} => ${event.adData}');
                switch (event.type) {
                  case AdEventType.loaded:
                    manager.start();
                  case AdEventType.contentPauseRequested:
                    _pauseContent();
                  case AdEventType.contentResumeRequested:
                    _resumeContent();
                  case AdEventType.allAdsCompleted:
                    manager.destroy();
                    _adsManager = null;
                  case AdEventType.clicked:
                  case AdEventType.complete:
                  case _:
                }
              },
              onAdErrorEvent: (AdErrorEvent event) {
                debugPrint('AdErrorEvent: ${event.error.message}');
                _resumeContent();
              },
            ),
          );

          manager.init(
            settings: AdsRenderingSettings(
              enablePreloading: widget.enablePreloading,
            ),
          );
        },
        onAdsLoadError: (AdsLoadErrorData data) {
          debugPrint('OnAdsLoadError: ${data.error.message}');
          _resumeContent();
        },
      );

      // Ads can't be requested until the `AdDisplayContainer` has been added to
      // the native View hierarchy.
      _requestAds(container);
    },
  );

  @override
  void initState() {
    super.initState();
    // Adds this instance as an observer for `AppLifecycleState` changes.
    WidgetsBinding.instance.addObserver(this);

    _contentVideoController =
        VideoPlayerController.networkUrl(
            Uri.parse(
              'https://storage.googleapis.com/gvabox/media/samples/stock.mp4',
            ),
          )
          ..addListener(() {
            if (_contentVideoController.value.isCompleted) {
              _adsLoader.contentComplete();
              setState(() {});
            }
          })
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_shouldShowContentVideo) {
          _adsManager?.resume();
        }
      case AppLifecycleState.inactive:
        // Pausing the Ad video player on Android can only be done in this state
        // because it corresponds to `Activity.onPause`. This state is also
        // triggered before resume, so this will only pause the Ad if the app is
        // in the process of being sent to the background.
        if (!_shouldShowContentVideo &&
            _lastLifecycleState == AppLifecycleState.resumed) {
          _adsManager?.pause();
        }
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
    }
    _lastLifecycleState = state;
  }

  Future<void> _requestAds(AdDisplayContainer container) {
    return _adsLoader.requestAds(
      AdsRequest(
        adTagUrl: widget.adTagUrl,
        contentProgressProvider: _contentProgressProvider,
      ),
    );
  }

  Future<void> _resumeContent() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _shouldShowContentVideo = true;
    });

    if (_adsManager != null) {
      _contentProgressTimer = Timer.periodic(
        const Duration(milliseconds: 200),
        (Timer timer) async {
          if (_contentVideoController.value.isInitialized) {
            final Duration? progress = await _contentVideoController.position;
            if (progress != null) {
              await _contentProgressProvider.setProgress(
                progress: progress,
                duration: _contentVideoController.value.duration,
              );
            }
          }
        },
      );
    }

    await _contentVideoController.play();
  }

  Future<void> _pauseContent() {
    setState(() {
      _shouldShowContentVideo = false;
    });
    _contentProgressTimer?.cancel();
    _contentProgressTimer = null;
    return _contentVideoController.pause();
  }

  @override
  void dispose() {
    super.dispose();
    _contentProgressTimer?.cancel();
    _contentVideoController.dispose();
    _adsManager?.destroy();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IMA Test App'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          spacing: 80,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.adType,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(
              width: 300,
              child:
                  !_contentVideoController.value.isInitialized
                      ? Container()
                      : AspectRatio(
                        aspectRatio: _contentVideoController.value.aspectRatio,
                        child: Stack(
                          children: <Widget>[
                            // The display container must be on screen before any Ads can be
                            // loaded and can't be removed between ads. This handles clicks for
                            // ads.
                            _adDisplayContainer,
                            if (_shouldShowContentVideo)
                              VideoPlayer(_contentVideoController),
                          ],
                        ),
                      ),
            ),
            ColoredBox(
              color: Colors.green,
              child: SizedBox(
                width: 300,
                height: 250,
                child: companionAd.buildWidget(context),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          _contentVideoController.value.isInitialized && _shouldShowContentVideo
              ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _contentVideoController.value.isPlaying
                        ? _contentVideoController.pause()
                        : _contentVideoController.play();
                  });
                },
                child: Icon(
                  _contentVideoController.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              )
              : null,
    );
  }
}
