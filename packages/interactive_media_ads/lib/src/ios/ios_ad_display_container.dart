// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import '../platform_interface/platform_interface.dart';
import 'interactive_media_ads.g.dart';
import 'interactive_media_ads_proxy.dart';

/// Implementation of [PlatformAdDisplayContainerCreationParams] for iOS.
final class IOSAdDisplayContainerCreationParams
    extends PlatformAdDisplayContainerCreationParams {
  /// Constructs a [IOSAdDisplayContainerCreationParams].
  const IOSAdDisplayContainerCreationParams({
    super.key,
    required super.onContainerAdded,
    @visibleForTesting InteractiveMediaAdsProxy? imaProxy,
  })  : _imaProxy = imaProxy ?? const InteractiveMediaAdsProxy(),
        super();

  /// Creates a [IOSAdDisplayContainerCreationParams] from an instance of
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
base class IOSAdDisplayContainer extends PlatformAdDisplayContainer {
  /// Constructs an [IOSAdDisplayContainer].
  IOSAdDisplayContainer(super.params) : super.implementation() {
    _controller = _iosParams._imaProxy.newUIViewController();

    final BaseObject windowListener =
        _createWindowListener(WeakReference<IOSAdDisplayContainer>(this));
    _controller.view.addObserver(
      windowListener,
      'window',
      KeyValueObservingOptions.newValue,
    );
  }

  // This value is created in a static method because the callback methods for
  // any wrapped classes must not reference the encapsulating object. This is to
  // prevent a circular reference that prevents garbage collection.
  static BaseObject _createWindowListener(
    WeakReference<IOSAdDisplayContainer> interfaceContainer,
  ) {
    return interfaceContainer.target!._iosParams._imaProxy.newNSObject(
      observeValue: (
        BaseObject instance,
        String? keyPath,
        BaseObject? object,
        Map<KeyValueChangeKey?, Object?>? changeKeys,
      ) {
        if (changeKeys == null) {
          return;
        }

        final IOSAdDisplayContainer? container = interfaceContainer.target;
        if (container != null &&
            changeKeys[KeyValueChangeKey.newValue] != null &&
            !container._viewAddedToWindowCompleter.isCompleted) {
          container._viewAddedToWindowCompleter.complete();
          container._controller.view.removeObserver(instance, 'window');
        }
      },
    );
  }

  // The `UIViewController` used to create the native `IMAAdDisplayContainer`.
  late final UIViewController _controller;

  final Completer<void> _viewAddedToWindowCompleter = Completer<void>();

  /// The native iOS IMAAdDisplayContainer.
  ///
  /// Created with the `UIView` that handles playing an ad.
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
      viewType: 'interactive_media_ads.packages.flutter.dev/view',
      onPlatformViewCreated: (_) async {
        adDisplayContainer = _iosParams._imaProxy.newIMAAdDisplayContainer(
          adContainer: _controller.view,
          adContainerViewController: _controller,
        );
        await _viewAddedToWindowCompleter.future;
        params.onContainerAdded(this);
      },
      layoutDirection: params.layoutDirection,
      creationParams:
          // ignore: invalid_use_of_protected_member
          _controller.view.pigeon_instanceManager
              .getIdentifier(_controller.view),
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
