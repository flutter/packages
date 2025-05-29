// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../platform_interface/build_widget_creation_params.dart';
import '../platform_interface/platform_companion_ad_slot.dart';
import 'android_view_widget.dart';
import 'interactive_media_ads.g.dart' as ima;
import 'interactive_media_ads_proxy.dart';
import 'platform_views_service_proxy.dart';

/// Android implementation of [PlatformCompanionAdSlotCreationParams].
final class AndroidCompanionAdSlotCreationParams
    extends PlatformCompanionAdSlotCreationParams {
  /// Constructs a [AndroidCompanionAdSlotCreationParams].
  const AndroidCompanionAdSlotCreationParams.size({
    required super.width,
    required super.height,
    super.onClicked,
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
    @visibleForTesting PlatformViewsServiceProxy? platformViewsProxy,
  })  : _proxy = proxy ?? const InteractiveMediaAdsProxy(),
        _platformViewsProxy =
            platformViewsProxy ?? const PlatformViewsServiceProxy(),
        super.size();

  /// Constructs a [AndroidCompanionAdSlotCreationParams].
  const AndroidCompanionAdSlotCreationParams.fluid({
    super.onClicked,
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
    @visibleForTesting PlatformViewsServiceProxy? platformViewsProxy,
  })  : _proxy = proxy ?? const InteractiveMediaAdsProxy(),
        _platformViewsProxy =
            platformViewsProxy ?? const PlatformViewsServiceProxy(),
        super.fluid();

  /// Creates a [AndroidCompanionAdSlotCreationParams] from an instance of
  /// [PlatformCompanionAdSlotCreationParams].
  factory AndroidCompanionAdSlotCreationParams.fromPlatformCompanionAdSlotCreationParamsSize(
    // Placeholder to prevent requiring a breaking change if params are added to
    // PlatformCompanionAdSlotCreationParams.
    // ignore: avoid_unused_constructor_parameters
    PlatformCompanionAdSlotCreationParams params, {
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
    @visibleForTesting PlatformViewsServiceProxy? platformViewsProxy,
  }) {
    return AndroidCompanionAdSlotCreationParams.size(
      width: params.width!,
      height: params.height!,
      onClicked: params.onClicked,
      proxy: proxy,
      platformViewsProxy: platformViewsProxy,
    );
  }

  /// Creates a [AndroidCompanionAdSlotCreationParams] from an instance of
  /// [PlatformCompanionAdSlotCreationParams].
  factory AndroidCompanionAdSlotCreationParams.fromPlatformCompanionAdSlotCreationParamsFluid(
    // Placeholder to prevent requiring a breaking change if params are added to
    // PlatformCompanionAdSlotCreationParams.
    PlatformCompanionAdSlotCreationParams params, {
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
    @visibleForTesting PlatformViewsServiceProxy? platformViewsProxy,
  }) {
    return AndroidCompanionAdSlotCreationParams.fluid(
      onClicked: params.onClicked,
      proxy: proxy,
      platformViewsProxy: platformViewsProxy,
    );
  }

  final InteractiveMediaAdsProxy _proxy;
  final PlatformViewsServiceProxy _platformViewsProxy;
}

/// Android implementation of [PlatformCompanionAdSlot].
base class AndroidCompanionAdSlot extends PlatformCompanionAdSlot {
  /// Constructs an [AndroidCompanionAdSlot].
  AndroidCompanionAdSlot(super.params) : super.implementation();

  late final AndroidCompanionAdSlotCreationParams _androidParams =
      _initAndroidParams(params);

  // ViewGroup used to display the Ad.
  late final ima.ViewGroup _frameLayout =
      _androidParams._proxy.newFrameLayout();

  late final Future<ima.CompanionAdSlot> _adSlotFuture = _initCompanionAdSlot();

  /// The future returning the native CompanionAdSlot.
  @internal
  Future<ima.CompanionAdSlot> getNativeCompanionAdSlot() => _adSlotFuture;

  @override
  Widget buildWidget(BuildWidgetCreationParams params) {
    return AndroidViewWidget(
      key: params.key,
      view: _frameLayout,
      platformViewsServiceProxy: _androidParams._platformViewsProxy,
      layoutDirection: params.layoutDirection,
    );
  }

  AndroidCompanionAdSlotCreationParams _initAndroidParams(
    PlatformCompanionAdSlotCreationParams params,
  ) {
    if (params is AndroidCompanionAdSlotCreationParams) {
      return params;
    }

    if (params.isFluid) {
      return AndroidCompanionAdSlotCreationParams
          .fromPlatformCompanionAdSlotCreationParamsFluid(params);
    } else {
      return AndroidCompanionAdSlotCreationParams
          .fromPlatformCompanionAdSlotCreationParamsSize(params);
    }
  }

  Future<ima.CompanionAdSlot> _initCompanionAdSlot() async {
    final ima.CompanionAdSlot adSlot = await _androidParams._proxy
        .instanceImaSdkFactory()
        .createCompanionAdSlot();

    await Future.wait(<Future<void>>[
      adSlot.setContainer(_frameLayout),
      if (params.isFluid)
        adSlot.setFluidSize()
      else
        adSlot.setSize(params.width!, params.height!),
      if (params.onClicked != null)
        adSlot.addClickListener(
          _createAdSlotClickListener(
            WeakReference<AndroidCompanionAdSlot>(this),
          ),
        ),
    ]);

    return adSlot;
  }

  // This value is created in a static method because the callback methods for
  // any wrapped classes must not reference the encapsulating object. This is to
  // prevent a circular reference that prevents garbage collection.
  static ima.CompanionAdSlotClickListener _createAdSlotClickListener(
    WeakReference<AndroidCompanionAdSlot> weakThis,
  ) {
    return weakThis.target!._androidParams._proxy
        .newCompanionAdSlotClickListener(
      onCompanionAdClick: (_) {
        weakThis.target?.params.onClicked!.call();
      },
    );
  }
}
