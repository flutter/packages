// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

/// JSInterop object that wraps the Javascript object for the Ad Placement API.
extension type AdPlacementApiJSObject(JSObject _) implements JSObject {
  /// Key function for placing ads within your app. It defines an ad placement and takes an object called a placement config that specifies everything required to show an ad.
  @JS()
  external void adBreak(AdBreakParamJSObject o);

  /// The adConfig() call communicates the app's current configuration to the Ad Placement API.
  /// The Ad Placement API can use this to tune the way it preloads ads and to filter the kinds of ads it requests so they're suitable (eg. video ads that require sound).
  @JS()
  external void adConfig(AdConfigParamJSObject o);
}

/// JSInterop object that wraps the parameters for the adBreak call in the Ad Placement API.
extension type AdBreakParamJSObject(JSObject _) implements JSObject {
  /// The type of this placement
  external JSString type;

  /// A descriptive name for this placement
  external JSString? name;

  /// Prepare for the ad. Mute sounds and pause flow.
  external JSFunction? beforeAd;

  /// Resume the app flow and re-enable sound
  external JSFunction? afterAd;

  /// Show reward prompt (call showAdFn() if clicked)
  external JSFunction? beforeReward;

  /// User dismissed the ad before completion
  external JSFunction? adDismissed;

  /// Ad was viewed and closed
  external JSFunction? adViewed;

  /// Always called (if provided) even if an ad didn't show
  external JSFunction? adBreakDone;
}

/// JSInterop object representing the return object of the AdBreakDone callback
extension type AdBreakDoneCallbackParamJSObject(JSObject _)
    implements JSObject {
  /// See [BreakType] enum
  external JSString breakType;

  /// Name of the ad break
  external JSString breakName;

  /// See [BreakFormat] enum
  external JSString breakFormat;

  /// See [BreakStatus] enum
  external JSString breakStatus;
}

/// JSInterop object that wraps the parameters for the adConfig call in the Ad Placement API.
extension type AdConfigParamJSObject(JSObject _) implements JSObject {
  /// Ad preloading strategy
  external JSString preloadAdBreaks;

  /// This app has sound
  external JSString? sound;

  /// Called when API has initialised and adBreak() is ready
  external JSExportedDartFunction? onReady;
}
