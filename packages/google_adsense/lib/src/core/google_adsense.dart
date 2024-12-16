// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import '../utils/logging.dart';
import 'js_interop/js_loader.dart';

/// The web implementation of the AdSense API.
class AdSense {
  bool _isInitialized = false;

  /// The [Publisher ID](https://support.google.com/adsense/answer/2923881).
  late String adClient;

  /// Initializes the AdSense SDK with your [adClient].
  ///
  /// The [adClient] parameter is your AdSense [Publisher ID](https://support.google.com/adsense/answer/2923881).
  ///
  /// Should be called ASAP, ideally in the `main` method.
  //
  // TODO(dit): Add the "optional AdSense code parameters", and render them
  // in the right location (the script tag for h5 + the ins for display ads).
  // See: https://support.google.com/adsense/answer/9955214?hl=en#adsense_code_parameter_descriptions
  Future<void> initialize(
    String adClient, {
    @visibleForTesting bool skipJsLoader = false,
    @visibleForTesting web.HTMLElement? jsLoaderTarget,
  }) async {
    if (_isInitialized) {
      debugLog('initialize already called. Skipping.');
      return;
    }
    this.adClient = adClient;
    if (!skipJsLoader) {
      await loadJsSdk(adClient, jsLoaderTarget);
    } else {
      debugLog('initialize called with skipJsLoader. Skipping loadJsSdk.');
    }
    _isInitialized = true;
  }
}

/// The singleton instance of the AdSense SDK.
final AdSense adSense = AdSense();
