// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/widgets.dart' show visibleForTesting;

import '../core/js_interop/adsbygoogle.dart';
import 'enums.dart';

// Used to prefix all the "name"s of the ad placements.
const String _namePrefix = 'APFlutter-';

/// Adds H5's `adBreak` and `adConfig` methods to `adSense` to request H5 ads.
extension H5JsInteropExtension on AdsByGoogle {
  /// Defines an ad placement configured by [params].
  @JS('push')
  external void adBreak(AdBreakPlacement params);

  /// Communicates the app's current [configuration] to the Ad Placement API.
  ///
  /// The Ad Placement API can use this to tune the way it preloads ads and to
  /// filter the kinds of ads it requests so they're suitable (eg. video ads
  /// that require sound).
  @JS('push')
  external void adConfig(AdConfigParameters configuration);
}

/// Placement configuration object.
///
/// Used to configure the ad request through the `h5GamesAds.adBreak` method.
///
/// In addition to a general constructor that takes all possible parameters, this
/// class contains named constructors for the following placement types:
///
/// * Interstitial (see: [AdBreakPlacement.interstitial])
/// * Preroll (see: [AdBreakPlacement.preroll])
/// * Rewarded (see: [AdBreakPlacement.rewarded])
///
/// Each constructor will use one or more of the following arguments:
///
/// {@template pkg_google_adsense_parameter_h5_type}
/// * [type]: The type of the placement. See [BreakType].
/// {@endtemplate}
/// {@template pkg_google_adsense_parameter_h5_name}
/// * [name]: A name for this particular ad placement within your game. It is an
///   internal identifier, and is not shown to the player. Recommended.
/// {@endtemplate}
/// {@template pkg_google_adsense_parameter_h5_beforeAd}
/// * [beforeAd]: Called before the ad is displayed. The game should pause and
///   mute the sound. These actions must be done synchronously. The ad will be
///   displayed immediately after this callback finishes..
/// {@endtemplate}
/// {@template pkg_google_adsense_parameter_h5_afterAd}
/// * [afterAd]: Called after the ad is finished (for any reason). For rewarded
///   ads, it is called after either adDismissed or adViewed, depending on
///   player actions
/// {@endtemplate}
/// {@template pkg_google_adsense_parameter_h5_adBreakDone}
/// * [adBreakDone]: Always called as the last step in an `adBreak`, even if
///   there was no ad shown. Takes as argument a `placementInfo` object.
///   See [AdBreakDonePlacementInfo], and: https://developers.google.com/ad-placement/apis/adbreak#adbreakdone_and_placementinfo
/// {@endtemplate}
///
/// For rewarded placements, the following parameters are also available:
///
/// {@template pkg_google_adsense_parameter_h5_beforeReward}
/// * [beforeReward]: Called if a rewarded ad is available. The function should
///   take a single argument `showAdFn` which **must** be called to display the
///   rewarded ad.
/// {@endtemplate}
/// {@template pkg_google_adsense_parameter_h5_adDismissed}
/// * [adDismissed]: Called if the player dismisses the ad before it completes.
///   In this case the reward should not be granted.
/// {@endtemplate}
/// {@template pkg_google_adsense_parameter_h5_adViewed}
/// * [adViewed]: Called when the player completes the ad and should be granted
///   the reward.
/// {@endtemplate}
///
/// For more information about ad units, check
/// [Placement Types](https://developers.google.com/ad-placement/docs/placement-types)
/// documentation and
/// [adBreak parameters](https://developers.google.com/ad-placement/apis/adbreak#adbreak_parameters)
/// in the Ad Placement API docs.
extension type AdBreakPlacement._(JSObject _) implements JSObject {
  /// Creates an ad placement configuration that can be passed to `adBreak`.
  ///
  /// The following parameters are available:
  ///
  /// {@macro pkg_google_adsense_parameter_h5_type}
  /// {@macro pkg_google_adsense_parameter_h5_name}
  /// {@macro pkg_google_adsense_parameter_h5_beforeAd}
  /// {@macro pkg_google_adsense_parameter_h5_afterAd}
  /// {@macro pkg_google_adsense_parameter_h5_beforeReward}
  /// {@macro pkg_google_adsense_parameter_h5_adDismissed}
  /// {@macro pkg_google_adsense_parameter_h5_adViewed}
  /// {@macro pkg_google_adsense_parameter_h5_adBreakDone}
  ///
  /// This factory can create any type of placement configuration. Read the
  /// [Placement Types](https://developers.google.com/ad-placement/docs/placement-types)
  /// documentation for more information.
  factory AdBreakPlacement({
    required BreakType type,
    String? name,
    H5BeforeAdCallback? beforeAd,
    H5AfterAdCallback? afterAd,
    H5BeforeRewardCallback? beforeReward,
    H5AdDismissedCallback? adDismissed,
    H5AdViewedCallback? adViewed,
    H5AdBreakDoneCallback? adBreakDone,
  }) {
    return AdBreakPlacement._toJS(
      type: type.name.toJS,
      name: '$_namePrefix${name ?? ''}'.toJS,
      beforeAd: beforeAd?.toJS,
      afterAd: afterAd?.toJS,
      beforeReward: beforeReward != null
          ? (JSFunction showAdFn) {
              beforeReward(() {
                // Delay the call to `showAdFn` so tap users don't trigger a click on the
                // ad on pointerup. This should leaves enough time for Flutter to settle
                // its tap events, before triggering the H5 ad.
                Timer(const Duration(milliseconds: 100), () {
                  showAdFn.callAsFunction();
                });
              });
            }.toJS
          : null,
      adDismissed: adDismissed?.toJS,
      adViewed: adViewed?.toJS,
      adBreakDone: adBreakDone?.toJS,
    );
  }

  /// Convenience factory to create a rewarded ad placement configuration.
  ///
  /// The following parameters are available:
  ///
  /// {@macro pkg_google_adsense_parameter_h5_name}
  /// {@macro pkg_google_adsense_parameter_h5_beforeAd}
  /// {@macro pkg_google_adsense_parameter_h5_afterAd}
  /// {@macro pkg_google_adsense_parameter_h5_beforeReward}
  /// {@macro pkg_google_adsense_parameter_h5_adDismissed}
  /// {@macro pkg_google_adsense_parameter_h5_adViewed}
  /// {@macro pkg_google_adsense_parameter_h5_adBreakDone}
  ///
  /// See: https://developers.google.com/ad-placement/apis#rewarded_ads
  factory AdBreakPlacement.rewarded({
    String? name,
    H5BeforeAdCallback? beforeAd,
    H5AfterAdCallback? afterAd,
    required H5BeforeRewardCallback? beforeReward,
    required H5AdDismissedCallback? adDismissed,
    required H5AdViewedCallback? adViewed,
    H5AdBreakDoneCallback? adBreakDone,
  }) {
    return AdBreakPlacement(
      type: BreakType.reward,
      name: name,
      beforeAd: beforeAd,
      afterAd: afterAd,
      beforeReward: beforeReward,
      adDismissed: adDismissed,
      adViewed: adViewed,
      adBreakDone: adBreakDone,
    );
  }

  /// Convenience factory to create a preroll ad configuration.
  ///
  /// The following parameters are available:
  ///
  /// {@macro pkg_google_adsense_parameter_h5_adBreakDone}
  ///
  /// See: https://developers.google.com/ad-placement/apis#prerolls
  factory AdBreakPlacement.preroll({
    required H5AdBreakDoneCallback? adBreakDone,
  }) {
    return AdBreakPlacement(
      type: BreakType.preroll,
      adBreakDone: adBreakDone,
    );
  }

  /// Convenience factory to create an interstitial ad configuration.
  ///
  /// The following parameters are available:
  ///
  /// {@macro pkg_google_adsense_parameter_h5_name}
  /// {@macro pkg_google_adsense_parameter_h5_beforeAd}
  /// {@macro pkg_google_adsense_parameter_h5_afterAd}
  /// {@macro pkg_google_adsense_parameter_h5_adBreakDone}
  ///
  /// See: https://developers.google.com/ad-placement/apis#interstitials
  factory AdBreakPlacement.interstitial({
    required BreakType type,
    String? name,
    H5BeforeAdCallback? beforeAd,
    H5AfterAdCallback? afterAd,
    H5AdBreakDoneCallback? adBreakDone,
  }) {
    assert(interstitialBreakType.contains(type),
        '$type is not a valid interstitial placement type.');
    return AdBreakPlacement(
      type: type,
      name: name,
      beforeAd: beforeAd,
      afterAd: afterAd,
      adBreakDone: adBreakDone,
    );
  }

  factory AdBreakPlacement._toJS({
    JSString? type,
    JSString? name,
    JSFunction? beforeAd,
    JSFunction? afterAd,
    JSFunction? beforeReward,
    JSFunction? adDismissed,
    JSFunction? adViewed,
    JSFunction? adBreakDone,
  }) {
    return <String, Object>{
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (beforeAd != null) 'beforeAd': beforeAd,
      if (afterAd != null) 'afterAd': afterAd,
      if (beforeReward != null) 'beforeReward': beforeReward,
      if (adDismissed != null) 'adDismissed': adDismissed,
      if (adViewed != null) 'adViewed': adViewed,
      if (adBreakDone != null) 'adBreakDone': adBreakDone,
    }.jsify()! as AdBreakPlacement;
  }
}

/// Parameters for the `adConfig` method call.
extension type AdConfigParameters._(JSObject _) implements JSObject {
  /// Parameters for the `adConfig` method call.
  ///
  /// The following parameters are available:
  ///
  /// * [sound]: Whether the game is currently playing sound.
  /// * [preloadAdBreaks]: Whether ads should always be preloaded before the
  ///   first call to `adBreak`. See: https://developers.google.com/ad-placement/docs/preload-ads
  /// * [onReady]: Called when the API has initialized and has finished preloading
  ///   ads (if you requested preloading using `preloadAdBreaks`).
  ///
  /// For more information, see: https://developers.google.com/ad-placement/apis/adconfig#adconfig_parameters
  factory AdConfigParameters({
    required SoundEnabled? sound, // required because: cl/704928576
    PreloadAdBreaks? preloadAdBreaks,
    H5OnReadyCallback? onReady,
  }) {
    return AdConfigParameters._toJS(
      sound: sound?.name.toJS,
      preloadAdBreaks: preloadAdBreaks?.name.toJS,
      onReady: onReady?.toJS,
    );
  }

  factory AdConfigParameters._toJS({
    JSString? sound,
    JSString? preloadAdBreaks,
    JSFunction? onReady,
  }) {
    return <String, Object>{
      if (sound != null) 'sound': sound,
      if (preloadAdBreaks != null) 'preloadAdBreaks': preloadAdBreaks,
      if (onReady != null) 'onReady': onReady,
    }.jsify()! as AdConfigParameters;
  }
}

/// The parameter passed from the Ad Placement API to the `adBreakDone` callback.
extension type AdBreakDonePlacementInfo._(JSObject _) implements JSObject {
  /// Builds an AdBreakDonePlacementInfo object (for tests).
  @visibleForTesting
  external factory AdBreakDonePlacementInfo({
    JSString? breakType,
    JSString? breakName,
    JSString? breakFormat,
    JSString? breakStatus,
  });

  /// The `type` argument passed to `adBreak`.
  BreakType? get breakType => BreakType.values.maybe(_breakType?.toDart);
  @JS('breakType')
  external JSString? _breakType;

  /// The `name` argument passed to `adBreak`.
  String? get breakName => _breakName?.toDart;
  @JS('breakName')
  external JSString? _breakName;

  /// The format of the break. See [BreakFormat].
  BreakFormat? get breakFormat =>
      BreakFormat.values.maybe(_breakFormat?.toDart);
  @JS('breakFormat')
  external JSString? _breakFormat;

  /// The status of this placement. See [BreakStatus].
  BreakStatus? get breakStatus =>
      BreakStatus.values.maybe(_breakStatus?.toDart);
  @JS('breakStatus')
  external JSString? _breakStatus;
}

/// The type of the `showAdFn` function passed to the `beforeReward` callback.
///
/// This is actually a JSFunction. Do not call outside of the browser.
typedef H5ShowAdFn = void Function();

/// The type of the `beforeAd` callback.
typedef H5BeforeAdCallback = void Function();

/// The type of the `afterAd` callback.
typedef H5AfterAdCallback = void Function();

/// The type of the `adBreakDone` callback.
typedef H5AdBreakDoneCallback = void Function(
    AdBreakDonePlacementInfo placementInfo);

/// The type of the `beforeReward` callback.
typedef H5BeforeRewardCallback = void Function(H5ShowAdFn showAdFn);

/// The type of the `adDismissed` callback.
typedef H5AdDismissedCallback = void Function();

/// The type of the `adViewed` callback.
typedef H5AdViewedCallback = void Function();

/// The type of the `onReady` callback.
typedef H5OnReadyCallback = void Function();
