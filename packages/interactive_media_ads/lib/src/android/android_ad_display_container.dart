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
    videoView = VideoView(
      onError: (
        VideoView pigeonInstance,
        MediaPlayer player,
        int what,
        int extra,
      ) {
        // report ad load error
      },
    );

    frameLayout.addView(videoView);
  }

  final FrameLayout frameLayout = FrameLayout();

  late final VideoView videoView;

  @override
  Widget build(BuildContext context) {
    return AndroidViewWidget(
      view: frameLayout,
      onPlatformViewCreated: () => params.onContainerAdded(this),
    );
  }
}
