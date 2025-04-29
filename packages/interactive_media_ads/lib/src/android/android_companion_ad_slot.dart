import 'package:flutter/cupertino.dart';

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
    super.key,
    required super.width,
    required super.height,
    super.layoutDirection,
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
    @visibleForTesting PlatformViewsServiceProxy? platformViewsProxy,
  })  : _proxy = proxy ?? const InteractiveMediaAdsProxy(),
        _platformViewsProxy =
            platformViewsProxy ?? const PlatformViewsServiceProxy(),
        super.size();

  /// Constructs a [AndroidCompanionAdSlotCreationParams].
  const AndroidCompanionAdSlotCreationParams.fluid({
    super.key,
    super.layoutDirection,
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
      proxy: proxy,
      platformViewsProxy: platformViewsProxy,
    );
  }

  /// Creates a [AndroidCompanionAdSlotCreationParams] from an instance of
  /// [PlatformCompanionAdSlotCreationParams].
  factory AndroidCompanionAdSlotCreationParams.fromPlatformCompanionAdSlotCreationParamsFluid(
    // Placeholder to prevent requiring a breaking change if params are added to
    // PlatformCompanionAdSlotCreationParams.
    // ignore: avoid_unused_constructor_parameters
    PlatformCompanionAdSlotCreationParams params, {
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
    @visibleForTesting PlatformViewsServiceProxy? platformViewsProxy,
  }) {
    return AndroidCompanionAdSlotCreationParams.fluid(
      proxy: proxy,
      platformViewsProxy: platformViewsProxy,
    );
  }

  final InteractiveMediaAdsProxy _proxy;
  final PlatformViewsServiceProxy _platformViewsProxy;
}

base class AndroidCompanionAdSlot extends PlatformCompanionAdSlot {
  /// Constructs an [AndroidCompanionAdSlot].
  AndroidCompanionAdSlot(super.params) : super.implementation() {
    _initCompanionAdSlot();
  }

  late final AndroidCompanionAdSlotCreationParams _androidParams =
      _initAndroidParams(params);

  late final ima.ViewGroup _frameLayout =
      _androidParams._proxy.newFrameLayout();

  late final Future<ima.CompanionAdSlot> _adSlotFuture;

  Future<ima.CompanionAdSlot> getNativeCompanionAdSlot() => _adSlotFuture;

  Future<void> _initCompanionAdSlot() async {
    _adSlotFuture =
        _androidParams._proxy.instanceImaSdkFactory().createCompanionAdSlot();
    final ima.CompanionAdSlot adSlot = await _adSlotFuture;

    await adSlot.setContainer(_frameLayout);
    if (_androidParams.isFluid) {
      await adSlot.setFluidSize();
    } else {
      await adSlot.setSize(params.width!, params.height!);
    }
  }

  @override
  Widget build(BuildContext context) {
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
}
