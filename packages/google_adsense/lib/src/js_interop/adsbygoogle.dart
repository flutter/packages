// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS()
library;

import 'dart:js_interop';

/// Binding to the `adsbygoogle` JS global.
///
/// See: https://support.google.com/adsense/answer/9274516?hl=en&ref_topic=28893&sjid=11495822575537499409-EU
@JS('adsbygoogle')
external AdsByGoogle get adsbygoogle;

/// The Dart definition of the `adsbygoogle` global.
@JS()
@staticInterop
abstract class AdsByGoogle {}

/// The `adsbygoogle` methods mappings
extension AdsByGoogleExtension on AdsByGoogle {
  /// Replacement of part of the adUnit code:
  /// <script>
  /// (adsbygoogle = window.adsbygoogle || []).push({});
  /// </script>
  external void push(JSObject params);

  /// Convenience method for invoking push() with an empty object
  void requestAd() {
    push(JSObject());
  }
}
