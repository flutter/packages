import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import '../platform_interface/build_widget_creation_params.dart';
import '../platform_interface/platform_companion_ad_slot.dart';
import 'interactive_media_ads.g.dart';
import 'interactive_media_ads_proxy.dart';

/// iOS implementation of [PlatformCompanionAdSlotCreationParams].
final class IOSCompanionAdSlotCreationParams
    extends PlatformCompanionAdSlotCreationParams {
  /// Constructs a [IOSCompanionAdSlotCreationParams].
  const IOSCompanionAdSlotCreationParams.size({
    required super.width,
    required super.height,
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
  })  : _proxy = proxy ?? const InteractiveMediaAdsProxy(),
        super.size();

  /// Constructs a [IOSCompanionAdSlotCreationParams].
  const IOSCompanionAdSlotCreationParams.fluid({
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
      proxy: proxy,
    );
  }

  final InteractiveMediaAdsProxy _proxy;
}

base class IOSCompanionAdSlot extends PlatformCompanionAdSlot {
  /// Constructs an [IOSCompanionAdSlot].
  IOSCompanionAdSlot(super.params) : super.implementation() {
    _initCompanionAdSlot();
  }

  late final IOSCompanionAdSlotCreationParams _iosParams =
      _initIOSParams(params);

  @internal
  late final IMACompanionAdSlot nativeCompanionAdSlot = _initCompanionAdSlot();

  @override
  Widget buildWidget(BuildWidgetCreationParams params) {
    print('BUILDING');
    return UiKitView(
      key: params.key,
      viewType: 'interactive_media_ads.packages.flutter.dev/view',
      layoutDirection: params.layoutDirection,
      creationParams: nativeCompanionAdSlot.view.pigeon_instanceManager
          .getIdentifier(nativeCompanionAdSlot.view),
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
    if (_iosParams.isFluid) {
      return IMACompanionAdSlot(view: _iosParams._proxy.newUIView());
    } else {
      return IMACompanionAdSlot.size(
        view: _iosParams._proxy.newUIView(),
        width: _iosParams.width!,
        height: _iosParams.height!,
      );
    }
  }
}
