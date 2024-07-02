// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import '../platform_interface/platform_interface.dart';
import 'interactive_media_ads.g.dart';
import 'interactive_media_ads_proxy.dart';

/// Implementation of [PlatformAdDisplayContainerCreationParams] for iOS.
final class IOSAdDisplayContainerCreationParams
    extends PlatformAdDisplayContainerCreationParams {
  /// Constructs a [AndroidAdDisplayContainerCreationParams].
  const IOSAdDisplayContainerCreationParams({
    super.key,
    required super.onContainerAdded,
    @visibleForTesting InteractiveMediaAdsProxy? imaProxy,
  })  : _imaProxy = imaProxy ?? const InteractiveMediaAdsProxy(),
        super();

  /// Creates a [AndroidAdDisplayContainerCreationParams] from an instance of
  /// [PlatformAdDisplayContainerCreationParams].
  factory IOSAdDisplayContainerCreationParams.fromPlatformAdDisplayContainerCreationParams(
    PlatformAdDisplayContainerCreationParams params, {
    @visibleForTesting InteractiveMediaAdsProxy? imaProxy,
  }) {
    return IOSAdDisplayContainerCreationParams(
      key: params.key,
      onContainerAdded: params.onContainerAdded,
      imaProxy: imaProxy,
    );
  }

  final InteractiveMediaAdsProxy _imaProxy;
}

/// Implementation of [PlatformAdDisplayContainer] for iOS.
base class IosAdDisplayContainer extends PlatformAdDisplayContainer {
  /// Constructs an [IosAdDisplayContainer].
  IosAdDisplayContainer(super.params) : super.implementation() {
    _controller = _iosParams._imaProxy.newUIViewController();
  }

  // The `UIViewController` used to create the native `IMAAdDisplayContainer`.
  late final UIViewController _controller;

  /// The native iOS AdDisplayContainer.
  ///
  /// This holds the player for video ads.
  ///
  /// Created with the `View` that handles playing an ad.
  @internal
  late final IMAAdDisplayContainer? adDisplayContainer;

  late final IOSAdDisplayContainerCreationParams _iosParams =
      params is IOSAdDisplayContainerCreationParams
          ? params as IOSAdDisplayContainerCreationParams
          : IOSAdDisplayContainerCreationParams
              .fromPlatformAdDisplayContainerCreationParams(params);

  @override
  Widget build(BuildContext context) {
    return UiKitView(
      key: _iosParams.key,
      viewType: 'interactive_media_ads.packages.flutter.dev',
      onPlatformViewCreated: (_) async {
        adDisplayContainer = _iosParams._imaProxy.newIMAAdDisplayContainer(
          adContainer: _controller.view,
          adContainerViewController: _controller,
        );
        // A delay is added since this callback only indicates when the View is
        // created, but not when it has been added to the native View hierarchy.
        // See https://github.com/flutter/flutter/issues/150802
        await Future<void>.delayed(const Duration(seconds: 1));
        params.onContainerAdded(this);
      },
      creationParams:
          // ignore: invalid_use_of_protected_member
          _controller.pigeon_instanceManager.getIdentifier(_controller.view),
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
