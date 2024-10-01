// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'ad_placement_api_js_interop.dart';
import 'enums.dart';

/// Main class to interact with the Ad Placement API from Flutter Web/Dart code.
class AdPlacementApi {
  /// Wraps JS Ad Placement API in a dart object.
  AdPlacementApi(this._adPlacementApiJsObject);

  final String _namePrefix = 'APFlutter-';

  final AdPlacementApiJSObject? _adPlacementApiJsObject;

  /// Key function for placing ads within your app. It defines an ad placement and takes an object called a placement config that specifies everything required to show an ad.
  void adBreak({
    /// The type of this placement
    required BreakType type,

    /// A descriptive name for this placement
    String? name,

    /// Prepare for the ad. Mute sounds and pause flow.
    void Function()? beforeAd,

    /// Resume the app flow and re-enable sound
    void Function()? afterAd,

    /// Show reward prompt (call showAdFn() if clicked)
    void Function(JSFunction showAdFn)? beforeReward,

    /// User dismissed the ad before completion
    void Function()? adDismissed,

    /// Ad was viewed and closed
    void Function()? adViewed,

    /// Always called (if provided) even if an ad didn't show
    void Function(
      BreakType? breakType,
      String? breakName,
      BreakFormat? breakFormat,
      BreakStatus? breakStatus,
    )? adBreakDone,
  }) {
    final AdBreakParamJSObject param = AdBreakParamJSObject(JSObject());
    void empty() {}
    void showAdDefault(JSFunction? showAd) {
      if (showAd != null) {
        showAd.callAsFunction();
      }
    }

    void wrappedAdBreakDoneCallback(AdBreakDoneCallbackParamJSObject param) {
      final BreakType type = BreakType.values.byName(param.breakType.toDart);
      final BreakFormat format =
          BreakFormat.values.byName(param.breakFormat.toDart);
      final BreakStatus status =
          BreakStatus.values.byName(param.breakStatus.toDart);
      final String name = param.breakName.toDart;
      if (adBreakDone != null) {
        adBreakDone(type, name, format, status);
      }
    }

    String breakName = _namePrefix;
    if (name != null) {
      breakName = breakName + name;
    }

    param.type = type.name.toJS;
    param.name = breakName.toJS;
    param.beforeAd = beforeAd != null ? beforeAd.toJS : empty.toJS;
    param.afterAd = afterAd != null ? afterAd.toJS : empty.toJS;
    if (type == BreakType.reward) {
      param.beforeReward =
          beforeReward != null ? beforeReward.toJS : showAdDefault.toJS;
      param.adDismissed = adDismissed != null ? adDismissed.toJS : empty.toJS;
      param.adViewed = adViewed != null ? adViewed.toJS : empty.toJS;
    }
    param.adBreakDone = wrappedAdBreakDoneCallback.toJS;

    _adPlacementApiJsObject?.adBreak(param);
  }

  /// The adConfig() call communicates the app's current configuration to the Ad Placement API.
  /// The Ad Placement API can use this to tune the way it preloads ads and to filter the kinds of ads it requests so they're suitable (eg. video ads that require sound).
  void adConfig(
    PreloadAdBreaks preloadAdBreaks,
    SoundEnabled sound,
    void Function()? onReady,
  ) {
    final AdConfigParamJSObject param = AdConfigParamJSObject(JSObject());

    param.preloadAdBreaks = preloadAdBreaks.name.toJS;
    param.sound = sound.name.toJS;
    param.onReady = onReady?.toJS;

    _adPlacementApiJsObject?.adConfig(param);
  }
}
