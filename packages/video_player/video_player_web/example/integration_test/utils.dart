// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS()
library integration_test_utils;

import 'package:js/js.dart';
import 'package:web/web.dart' as web;

// Returns the URL to load an asset from this example app as a network source.
//
// TODO(stuartmorgan): Convert this to a local `HttpServer` that vends the
// assets directly, https://github.com/flutter/flutter/issues/95420
String getUrlForAssetAsNetworkSource(String assetKey) {
  return 'https://github.com/flutter/packages/blob/'
      // This hash can be rolled forward to pick up newly-added assets.
      '2e1673307ff7454aff40b47024eaed49a9e77e81'
      '/packages/video_player/video_player/example/'
      '$assetKey'
      '?raw=true';
}

@JS()
@anonymous
class _Descriptor {
  // May also contain "configurable" and "enumerable" bools.
  // See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty#description
  external factory _Descriptor({
    // bool configurable,
    // bool enumerable,
    bool writable,
    Object value,
  });
}

@JS('Object.defineProperty')
external void _defineProperty(
  Object object,
  String property,
  _Descriptor description,
);

/// Forces a VideoElement to report "Infinity" duration.
///
/// Uses JS Object.defineProperty to set the value of a readonly property.
void setInfinityDuration(web.HTMLVideoElement element) {
  _defineProperty(
      element,
      'duration',
      _Descriptor(
        writable: true,
        value: double.infinity,
      ));
}
