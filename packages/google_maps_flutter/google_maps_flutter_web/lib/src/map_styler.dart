// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(srujzs): Needed for https://github.com/dart-lang/sdk/issues/54801. Once
// we publish a version with a min SDK constraint that contains this fix,
// remove.
@JS()
library;

import 'dart:js_interop';

/// The interop type for a Google Maps Map Styler.
///
/// See: https://developers.google.com/maps/documentation/javascript/style-reference#stylers
@JS()
extension type MapStyler._(JSObject _) implements JSObject {
  /// Create a new [MapStyler] instance.
  external factory MapStyler({
    String? hue,
    num? lightness,
    num? saturation,
    num? gamma,
    // ignore: non_constant_identifier_names
    bool? invert_lightness,
    String? visibility,
    String? color,
    int? weight,
  });

  /// Create a new [MapStyler] instance from the given [json].
  factory MapStyler.fromJson(Map<String, Object?> json) {
    return MapStyler(
      hue: json['hue'] as String?,
      lightness: json['lightness'] as num?,
      saturation: json['saturation'] as num?,
      gamma: json['gamma'] as num?,
      invert_lightness: json['invert_lightness'] as bool?,
      visibility: json['visibility'] as String?,
      color: json['color'] as String?,
      weight: json['weight'] as int?,
    );
  }
}
