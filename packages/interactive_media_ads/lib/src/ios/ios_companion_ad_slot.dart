// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.g

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import '../platform_interface/build_widget_creation_params.dart';
import '../platform_interface/platform_companion_ad_slot.dart';
import 'interactive_media_ads.g.dart';
import 'interactive_media_ads_proxy.dart';

/// Implementation of [PlatformCompanionAdSlotCreationParams] for iOS.
final class IOSCompanionAdSlotCreationParams
    extends PlatformCompanionAdSlotCreationParams {
  /// Constructs a [IOSCompanionAdSlotCreationParams].
  const IOSCompanionAdSlotCreationParams.size({
    required super.width,
    required super.height,
    super.onClicked,
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
  })  : _proxy = proxy ?? const InteractiveMediaAdsProxy(),
        super.size();

  /// Constructs a [IOSCompanionAdSlotCreationParams].
  const IOSCompanionAdSlotCreationParams.fluid({
    super.onClicked,
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
  })  : _proxy = proxy ?? const InteractiveMediaAdsProxy(),
        super.fluid();

  /// Creates a [IOSCompanionAdSlotCreationParams] from an instance of
  /// [PlatformCompanionAdSlotCreationParams].
  factory IOSCompanionAdSlotCreationParams.fromPlatformCompanionAdSlotCreationParamsSize(
    // Placeholder to prevent requiring a breaking change if params are added to
    // PlatformCompanionAdSlotCreationParams.
    // ignore: avoid_unused_constructor_parameters
    PlatformCompanionAdSlotCreationParams params, {
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
  }) {
    return IOSCompanionAdSlotCreationParams.size(
      width: params.width!,
      height: params.height!,
      onClicked: params.onClicked,
      proxy: proxy,
    );
  }

  /// Creates a [IOSCompanionAdSlotCreationParams] from an instance of
  /// [PlatformCompanionAdSlotCreationParams].
  factory IOSCompanionAdSlotCreationParams.fromPlatformCompanionAdSlotCreationParamsFluid(
    // Placeholder to prevent requiring a breaking change if params are added to
    // PlatformCompanionAdSlotCreationParams.
    // ignore: avoid_unused_constructor_parameters
    PlatformCompanionAdSlotCreationParams params, {
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
  }) {
    return IOSCompanionAdSlotCreationParams.fluid(
      onClicked: params.onClicked,
      proxy: proxy,
    );
  }

  final InteractiveMediaAdsProxy _proxy;
}

/// Implementation of [PlatformCompanionAdSlot] for iOS.
base class IOSCompanionAdSlot extends PlatformCompanionAdSlot {
  /// Constructs an [IOSCompanionAdSlot].
  IOSCompanionAdSlot(super.params) : super.implementation();

  late final IOSCompanionAdSlotCreationParams _iosParams =
      _initIOSParams(params);

  // View used to display the Ad.
  late final UIView _view = _iosParams._proxy.newUIView();

  late final IMACompanionDelegate _delegate = _createCompanionDelegate(
    WeakReference<IOSCompanionAdSlot>(this),
  );

  /// The native iOS IMACompanionAdSlot.
  @internal
  late final IMACompanionAdSlot nativeCompanionAdSlot = _initCompanionAdSlot();

  @override
  Widget buildWidget(BuildWidgetCreationParams params) {
    return UiKitView(
      key: params.key,
      viewType: 'interactive_media_ads.packages.flutter.dev/view',
      layoutDirection: params.layoutDirection,
      creationParams: _view.pigeon_instanceManager.getIdentifier(_view),
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  IOSCompanionAdSlotCreationParams _initIOSParams(
    PlatformCompanionAdSlotCreationParams params,
  ) {
    if (params is IOSCompanionAdSlotCreationParams) {
      return params;
    }

    if (params.isFluid) {
      return IOSCompanionAdSlotCreationParams
          .fromPlatformCompanionAdSlotCreationParamsFluid(params);
    } else {
      return IOSCompanionAdSlotCreationParams
          .fromPlatformCompanionAdSlotCreationParamsSize(params);
    }
  }

  IMACompanionAdSlot _initCompanionAdSlot() {
    final IMACompanionAdSlot adSlot = params.isFluid
        ? _iosParams._proxy.newIMACompanionAdSlot(view: _view)
        : _iosParams._proxy.sizeIMACompanionAdSlot(
            view: _view,
            width: _iosParams.width!,
            height: _iosParams.height!,
          );

    if (params.onClicked != null) {
      adSlot.setDelegate(_delegate);
    }

    return adSlot;
  }

  // This value is created in a static method because the callback methods for
  // any wrapped classes must not reference the encapsulating object. This is to
  // prevent a circular reference that prevents garbage collection.
  static IMACompanionDelegate _createCompanionDelegate(
    WeakReference<IOSCompanionAdSlot> weakThis,
  ) {
    return weakThis.target!._iosParams._proxy.newIMACompanionDelegate(
      companionSlotWasClicked: (_, __) {
        weakThis.target?.params.onClicked!.call();
      },
    );
  }
}
