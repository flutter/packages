// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import '../core/js_interop/adsbygoogle.dart';

/// Adds a `requestAd` method to request an AdSense ad.
extension AdsByGoogleExtension on AdsByGoogle {
  /// Convenience method for invoking push() with an empty object
  void requestAd() {
    // This can't be defined as a named external, because we *must* call push
    // with an empty JSObject
    push(JSObject());
  }
}
