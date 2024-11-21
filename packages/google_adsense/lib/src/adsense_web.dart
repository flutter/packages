// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import 'ad_unit_configuration.dart';
import 'ad_unit_widget.dart';
import 'js_interop/adsbygoogle.dart' show adsbygooglePresent;
import 'js_interop/package_web_tweaks.dart';

import 'logging.dart';

/// Returns a singleton instance of Adsense library public interface
final AdSense adSense = AdSense();

/// Main class to work with the library
class AdSense {
  bool _isInitialized = false;

  /// The ad client ID used by this client.
  late String _adClient;
  static const String _url =
      'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-';

  /// Initializes the AdSense SDK with your [adClient].
  ///
  /// Should be called ASAP, ideally in the main method of your app.
  ///
  /// Noops after the first call.
  void initialize(
    String adClient, {
    @visibleForTesting bool skipJsLoader = false,
    @visibleForTesting web.HTMLElement? jsLoaderTarget,
  }) {
    if (_isInitialized) {
      debugLog('adSense.initialize called multiple times. Skipping init.');
      return;
    }
    _adClient = adClient;
    if (!(skipJsLoader || _sdkAlreadyLoaded(testingTarget: jsLoaderTarget))) {
      _loadJsSdk(_adClient, jsLoaderTarget);
    } else {
      debugLog('SDK already on page. Skipping init.');
    }
    _isInitialized = true;
  }

  /// Returns an [AdUnitWidget] with the specified [configuration].
  Widget adUnit(AdUnitConfiguration configuration) {
    return AdUnitWidget(adClient: _adClient, configuration: configuration);
  }

  bool _sdkAlreadyLoaded({
    web.HTMLElement? testingTarget,
  }) {
    final String selector = 'script[src*=ca-pub-$_adClient]';
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
