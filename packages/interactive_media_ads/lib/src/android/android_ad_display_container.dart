// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import '../platform_interface/platform_interface.dart';
import 'android_view_widget.dart';
import 'interactive_media_ads.g.dart';

final class AndroidAdDisplayContainer extends PlatformAdDisplayContainer {
  AndroidAdDisplayContainer(super.params) : super.implementation() {
    final WeakReference<AndroidAdDisplayContainer> weakThis =
        WeakReference<AndroidAdDisplayContainer>(this);
    videoView = _setUpVideoView(weakThis);
    frameLayout.addView(videoView);
    _setUpAdDisplayContainer(weakThis).then((_) {
      params.onContainerAdded(this);
    });
  }

  final Set<VideoAdPlayerCallback> videoAdPlayerCallbacks =
      <VideoAdPlayerCallback>{};g

  AdMediaInfo? loadedAdMediaInfo;
  int savedAdPosition = 0;
  MediaPlayer? mediaPlayer;

  late final AdDisplayContainer adDisplayContainer;

  final FrameLayout frameLayout = FrameLayout();

  late final VideoView videoView;

  static VideoView _setUpVideoView(
    WeakReference<AndroidAdDisplayContainer> weakThis,
  ) {
    return VideoView(
      onCompletion: (
        VideoView pigeonInstance,
        MediaPlayer player,
      ) {
        weakThis.target?.mediaPlayer = null;
      },
      onPrepared: (
        VideoView pigeonInstance,
        MediaPlayer player,
      ) {
        final AndroidAdDisplayContainer? container = weakThis.target;
        if (container != null) {
          container.mediaPlayer = player;
          if (container.savedAdPosition > 0) {
            player.seekTo(container.savedAdPosition);
          }
        }

        player.start();
      },
      onError: (
        VideoView pigeonInstance,
        MediaPlayer player,
        int what,
        int extra,
      ) {
        final AndroidAdDisplayContainer? container = weakThis.target;
        if (container != null) {
          container.mediaPlayer = null;
          container.savedAdPosition = 0;
          for (final VideoAdPlayerCallback callback
              in container.videoAdPlayerCallbacks) {
            callback.onError(container.loadedAdMediaInfo!);
          }
        }
      },
    );
  }

  static Future<AdDisplayContainer> _setUpAdDisplayContainer(
    WeakReference<AndroidAdDisplayContainer> weakThis,
  ) async {
    return ImaSdkFactory.createAdDisplayContainer(
      weakThis.target!.frameLayout,
      VideoAdPlayer(
        addCallback: (
          VideoAdPlayer pigeonInstance,
          VideoAdPlayerCallback callback,
        ) {
          weakThis.target?.videoAdPlayerCallbacks.add(callback);
        },
        removeCallback: (
          VideoAdPlayer pigeonInstance,
          VideoAdPlayerCallback callback,
        ) {
          weakThis.target?.videoAdPlayerCallbacks.remove(callback);
        },
        loadAd: (
          VideoAdPlayer pigeonInstance,
          AdMediaInfo adMediaInfo,
          AdPodInfo adPodInfo,
        ) {
          weakThis.target?.loadedAdMediaInfo = adMediaInfo;
        },
        pauseAd: (
          VideoAdPlayer pigeonInstance,
          AdMediaInfo adMediaInfo,
        ) async {
          final AndroidAdDisplayContainer? container = weakThis.target;
          if (container != null) {
            await container.mediaPlayer!.pause();
            container.savedAdPosition =
                await container.videoView.getCurrentPosition();
          }
        },
        playAd: (
          VideoAdPlayer pigeonInstance,
          AdMediaInfo adMediaInfo,
        ) {
          weakThis.target?.videoView.setVideoUri(adMediaInfo.url);
        },
        release: (VideoAdPlayer pigeonInstance) {},
        stopAd: (
          VideoAdPlayer pigeonInstance,
          AdMediaInfo adMediaInfo,
        ) {
          final AndroidAdDisplayContainer? container = weakThis.target;
          if (container != null) {
            container.savedAdPosition = 0;
            container.mediaPlayer = null;
            container.loadedAdMediaInfo = null;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AndroidViewWidget(view: frameLayout);
  }
}
