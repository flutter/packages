// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// The AdSense SDK.
class AdSense {
  /// Initializes the AdSense SDK with your [adClient].
  ///
  /// The [adClient] parameter is your AdSense [Publisher ID](https://support.google.com/adsense/answer/2923881).
  ///
  /// Should be called ASAP, ideally in the `main` method.
  void initialize(
    String adClient, {
    @visibleForTesting bool skipJsLoader = false,
    @visibleForTesting Object? jsLoaderTarget,
  }) {
    throw UnsupportedError('Only supported on web');
  }

  /// The [Publisher ID](https://support.google.com/adsense/answer/2923881).
  String get adClient {
    throw UnsupportedError('Only supported on web');
  }
}
