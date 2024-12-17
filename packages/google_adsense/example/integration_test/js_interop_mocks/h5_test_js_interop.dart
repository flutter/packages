// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS()
library;

import 'dart:js_interop';

import 'package:google_adsense/src/h5/h5.dart';
import 'adsbygoogle_js_interop.dart';

export 'adsbygoogle_js_interop.dart';

/// Returns a push implementation that handles calls to `adBreak`.
AdBreakPlacement? lastAdBreakPlacement;
PushFn mockAdBreak({
  AdBreakDonePlacementInfo? adBreakDonePlacementInfo,
}) {
  lastAdBreakPlacement = null;
  return (JSAny? adBreakPlacement) {
    adBreakPlacement as AdBreakPlacement?;
    // Leak the adBreakPlacement.
    lastAdBreakPlacement = adBreakPlacement;
    // Call `adBreakDone` if set, with `adBreakDonePlacementInfo`.
    if (adBreakPlacement?.adBreakDone != null) {
      assert(adBreakDonePlacementInfo != null);
      adBreakPlacement!.adBreakDone!
          .callAsFunction(null, adBreakDonePlacementInfo);
    }
  };
}

AdConfigParameters? lastAdConfigParameters;
PushFn mockAdConfig() {
  lastAdConfigParameters = null;
  return (JSAny? adConfigParameters) {
    adConfigParameters as AdConfigParameters?;
    // Leak the adConfigParameters.
    lastAdConfigParameters = adConfigParameters;
    // Call `onReady` if set.
    if (adConfigParameters?.onReady != null) {
      adConfigParameters!.onReady!.callAsFunction();
    }
  };
}

extension AdBreakPlacementGettersExtension on AdBreakPlacement {
  external JSString? type;
  external JSString? name;
  external JSFunction? adBreakDone;
}

extension AdConfigParametersGettersExtension on AdConfigParameters {
  external JSString? preloadAdBreaks;
  external JSString? sound;
  external JSFunction? onReady;
}
