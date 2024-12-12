// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import '../js_interop/adsbygoogle.dart' show adsbygooglePresent;
import '../js_interop/package_web_tweaks.dart';

import '../utils/logging.dart';

/// The web implementation of the AdSense API.
class AdSense {
  bool _isInitialized = false;

  /// The [Publisher ID](https://support.google.com/adsense/answer/2923881).
  late String adClient;
  static const String _url =
      'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-';

  /// Initializes the AdSense SDK with your [adClient].
  ///
  /// The [adClient] parameter is your AdSense [Publisher ID](https://support.google.com/adsense/answer/2923881).
  ///
  /// Should be called ASAP, ideally in the `main` method.
  Future<void> initialize(
    String adClient, {
    @visibleForTesting bool skipJsLoader = false,
    @visibleForTesting web.HTMLElement? jsLoaderTarget,
  }) async {
    if (_isInitialized) {
      debugLog('adSense.initialize called multiple times. Skipping init.');
      return;
    }
    this.adClient = adClient;
    if (!(skipJsLoader || _sdkAlreadyLoaded(testingTarget: jsLoaderTarget))) {
      _loadJsSdk(adClient, jsLoaderTarget);
    } else {
      debugLog('SDK already on page. Skipping init.');
    }
    _isInitialized = true;
  }

  bool _sdkAlreadyLoaded({
    web.HTMLElement? testingTarget,
  }) {
    final String selector = 'script[src*=ca-pub-$adClient]';
    return adsbygooglePresent ||
        web.document.querySelector(selector) != null ||
        testingTarget?.querySelector(selector) != null;
  }

  void _loadJsSdk(String adClient, web.HTMLElement? testingTarget) {
    final String finalUrl = _url + adClient;

    final web.HTMLScriptElement script = web.HTMLScriptElement()
      ..async = true
      ..crossOrigin = 'anonymous';

    if (web.window.nullableTrustedTypes != null) {
      final String trustedTypePolicyName = 'adsense-dart-$adClient';
      try {
        final web.TrustedTypePolicy policy =
            web.window.trustedTypes.createPolicy(
                trustedTypePolicyName,
                web.TrustedTypePolicyOptions(
                  createScriptURL: ((JSString url) => url).toJS,
                ));
        script.trustedSrc = policy.createScriptURLNoArgs(finalUrl);
      } catch (e) {
        throw TrustedTypesException(e.toString());
      }
    } else {
      debugLog('TrustedTypes not available.');
      script.src = finalUrl;
    }

    (testingTarget ?? web.document.head)!.appendChild(script);
  }
}

/// The singleton instance of the AdSense SDK.
final AdSense adSense = AdSense();
