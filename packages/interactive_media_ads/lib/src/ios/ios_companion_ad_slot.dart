// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import '../platform_interface/build_widget_creation_params.dart';
import '../platform_interface/companion_ad_slot_size.dart';
import '../platform_interface/platform_companion_ad_slot.dart';
import 'interactive_media_ads.g.dart';

/// Implementation of [PlatformCompanionAdSlotCreationParams] for iOS.
final class IOSCompanionAdSlotCreationParams
    extends PlatformCompanionAdSlotCreationParams {
  /// Constructs an [IOSCompanionAdSlotCreationParams].
  const IOSCompanionAdSlotCreationParams({required super.size, super.onClicked})
    : super();

  /// Creates an [IOSCompanionAdSlotCreationParams] from an instance of
  /// [PlatformCompanionAdSlotCreationParams].
  factory IOSCompanionAdSlotCreationParams.fromPlatformCompanionAdSlotCreationParamsSize(
    PlatformCompanionAdSlotCreationParams params,
  ) {
    return IOSCompanionAdSlotCreationParams(
      size: params.size,
      onClicked: params.onClicked,
    );
  }
}

/// Implementation of [PlatformCompanionAdSlot] for iOS.
base class IOSCompanionAdSlot extends PlatformCompanionAdSlot {
  /// Constructs an [IOSCompanionAdSlot].
  IOSCompanionAdSlot(super.params) : super.implementation();

  // View used to display the Ad.
  late final UIView _view = UIView();

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
      creationParams: PigeonInstanceManager.instance.getIdentifier(_view),
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  IMACompanionAdSlot _initCompanionAdSlot() {
    final IMACompanionAdSlot adSlot = switch (params.size) {
      final CompanionAdSlotSizeFixed size => IMACompanionAdSlot.size(
        view: _view,
        width: size.width,
        height: size.height,
      ),
      CompanionAdSlotSizeFluid() => IMACompanionAdSlot(view: _view),
    };

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
    return IMACompanionDelegate(
      companionSlotWasClicked: (_, __) {
        weakThis.target?.params.onClicked!.call();
      },
    );
  }
}
