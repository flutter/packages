// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import '../utils/logging.dart';
import 'adsense_code_parameters.dart';
import 'js_interop/js_loader.dart';

export 'adsense_code_parameters.dart' show AdSenseCodeParameters;

/// The web implementation of the AdSense API.
class AdSense {
  bool _isInitialized = false;

  /// The [Publisher ID](https://support.google.com/adsense/answer/2923881).
  late String adClient;

  /// The (optional)
  /// [AdSense Code Parameters](https://support.google.com/adsense/answer/9955214#adsense_code_parameter_descriptions).
  AdSenseCodeParameters? adSenseCodeParameters;

  /// Initializes the AdSense SDK with your [adClient].
  ///
  /// The [adClient] parameter is your AdSense [Publisher ID](https://support.google.com/adsense/answer/2923881).
  ///
  /// The [adSenseCodeParameters] let you configure various settings for your
  /// ads. All parameters are optional. See
  /// [AdSense code parameter descriptions](https://support.google.com/adsense/answer/9955214#adsense_code_parameter_descriptions).
  ///
  /// Should be called ASAP, ideally in the `main` method.
  Future<void> initialize(
    String adClient, {
    AdSenseCodeParameters? adSenseCodeParameters,
    @visibleForTesting bool skipJsLoader = false,
    @visibleForTesting web.HTMLElement? jsLoaderTarget,
  }) async {
    if (_isInitialized) {
      debugLog('initialize already called. Skipping.');
      return;
    }
    this.adClient = adClient;
    this.adSenseCodeParameters = adSenseCodeParameters;
    if (!skipJsLoader) {
      await loadJsSdk(
        adClient,
        target: jsLoaderTarget,
        dataAttributes: adSenseCodeParameters?.toMap,
      );
    } else {
      debugLog('initialize called with skipJsLoader. Skipping loadJsSdk.');
    }
    _isInitialized = true;
  }
}

/// The singleton instance of the AdSense SDK.
final AdSense adSense = AdSense();
