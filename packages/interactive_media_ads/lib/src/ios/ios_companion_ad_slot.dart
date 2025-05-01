import 'dart:async';

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
  IOSCompanionAdSlot(super.params) : super.implementation();

  late final IOSCompanionAdSlotCreationParams _iosParams =
      _initIOSParams(params);

  final Completer<IMACompanionAdSlot> viewDidAppearCompleter = Completer<IMACompanionAdSlot>();

  late final UIViewController viewController = _createViewController(WeakReference(this));

  @internal
  Future<IMACompanionAdSlot> getNativeCompanionAdSlot() {
    return viewDidAppearCompleter.future;
  }

  @override
  Widget buildWidget(BuildWidgetCreationParams params) {
    return SizedBox(
      width: 300,
      height: 250,
      child: UiKitView(
        key: params.key,
        viewType: 'interactive_media_ads.packages.flutter.dev/view',
        layoutDirection: params.layoutDirection,
        creationParams: viewController.view.pigeon_instanceManager
            .getIdentifier(viewController.view),
        creationParamsCodec: const StandardMessageCodec(),
      ),
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

  IMACompanionAdSlot? s;

  IMACompanionAdSlot _initCompanionAdSlot() {
    if (_iosParams.isFluid) {
      return s = IMACompanionAdSlot(view: _iosParams._proxy.newUIView());
    } else {
      s = IMACompanionAdSlot.size(
        view: _iosParams._proxy.newUIView(),
        width: _iosParams.width!,
        height: _iosParams.height!,
      );
      print('SIZE');
      s!.width().then((int value) => print(value));
      s!.height().then((int value) => print(value));
      return s!;
    }
  }

  // This value is created in a static method because the callback methods for
  // any wrapped classes must not reference the encapsulating object. This is to
  // prevent a circular reference that prevents garbage collection.
  static UIViewController _createViewController(
    WeakReference<IOSCompanionAdSlot> interfaceContainer,
  ) {
    return interfaceContainer.target!._iosParams._proxy.newUIViewController(
      viewDidAppear: (_, bool animated) {
        print('VIEW appeared');
        final IOSCompanionAdSlot? container = interfaceContainer.target;
        if (container != null &&
            !container.viewDidAppearCompleter.isCompleted) {
          print('complete');
          container.viewDidAppearCompleter.complete(container._initCompanionAdSlot());
        }
      },
    );
  }
}
