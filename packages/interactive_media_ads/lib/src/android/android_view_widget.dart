// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'interactive_media_ads.g.dart' as ima;
import 'platform_views_service_proxy.dart';

/// Represents a Flutter implementation of the Android [View](https://developer.android.com/reference/android/view/View)
/// that is created by the Android platform.
class AndroidViewWidget extends StatelessWidget {
  /// Creates a [AndroidViewWidget].
  ///
  /// The [AndroidViewWidget] should only be instantiated internally.
  /// This constructor is visible for testing purposes only and should
  /// never be called externally.
  AndroidViewWidget({
    super.key,
    required this.view,
    this.layoutDirection = TextDirection.ltr,
    this.onPlatformViewCreated,
    ima.PigeonInstanceManager? instanceManager,
  }) : instanceManager = instanceManager ?? ima.PigeonInstanceManager.instance;

  /// The unique identifier for the view type to be embedded.
  static const String _viewType =
      'interactive_media_ads.packages.flutter.dev/view';

  /// The reference to the Android native view that should be shown.
  final ima.View view;

  /// Maintains instances used to communicate with the native objects they
  /// represent.
  ///
  /// This field is exposed for testing purposes only and should not be used
  /// outside of tests.
  final ima.PigeonInstanceManager instanceManager;
  
  /// Layout direction used by the Android View.
  final TextDirection layoutDirection;

  /// Callback that will get invoke after the platform view has been created.
  final VoidCallback? onPlatformViewCreated;

  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: _viewType,
      layoutDirection: layoutDirection,
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
      hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      creationParamsCodec: const StandardMessageCodec(),
      creationParams: instanceManager.getIdentifier(view),
      onPlatformViewCreated: (id) {
        onPlatformViewCreated?.call();
      },
    );
  }
}
