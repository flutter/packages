// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'messages.g.dart';

/// A widget that displays a video player using a platform view.
class PlatformViewPlayer extends StatelessWidget {
  /// Creates a new instance of [PlatformViewPlayer].
  const PlatformViewPlayer({
    super.key,
    required this.playerId,
  });

  /// The ID of the player.
  final int playerId;

  @override
  Widget build(BuildContext context) {
    const String viewType = 'plugins.flutter.dev/video_player_android';
    final PlatformVideoViewCreationParams creationParams =
        PlatformVideoViewCreationParams(playerId: playerId);

    // IgnorePointer so that GestureDetector can be used above the platform view.
    return IgnorePointer(
      child: PlatformViewLink(
        viewType: viewType,
        surfaceFactory: (
          BuildContext context,
          PlatformViewController controller,
        ) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection:
                Directionality.maybeOf(context) ?? TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: AndroidVideoPlayerApi.pigeonChannelCodec,
            onFocus: () => params.onFocusChanged(true),
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..create();
        },
      ),
    );
  }
}
