// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS()
library;

import 'dart:js_interop';

/// JS-interop mappings to the window.adsbygoogle object.
extension type AdsByGoogle._(JSObject _) implements JSObject {
  @JS('push')
  external void _push(JSObject params);
}

/// Convenience methods for Dart users.
extension AdsByGoogleExtension on AdsByGoogle {
  /// Convenience method for invoking push() with an empty object
  void requestAd() {
    _push(JSObject());
  }
}

// window.adsbygoogle may be null if this package runs before the JS SDK loads.
@JS('adsbygoogle')
external AdsByGoogle? get _adsbygoogle;

// window.adsbygoogle uses "duck typing", so let us set anything to it.
@JS('adsbygoogle')
external set _adsbygoogle(JSAny? value);

/// Whether or not the `window.adsbygoogle` object is defined and not null.
bool get adsbygooglePresent => _adsbygoogle.isDefinedAndNotNull;

/// Binding to the `adsbygoogle` JS global.
///
/// See: https://support.google.com/adsense/answer/9274516?hl=en&ref_topic=28893&sjid=11495822575537499409-EU
AdsByGoogle get adsbygoogle {
  if (!adsbygooglePresent) {
    // Initialize _adsbygoole to "something that has a push method".
    _adsbygoogle = JSArray<JSObject>();
  }
  return _adsbygoogle!;
}
