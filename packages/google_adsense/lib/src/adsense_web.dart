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

/// Returns a singleton instance of Adsense library public interface
final AdSense adSense = AdSense();

/// Main class to work with the library
class AdSense {
  bool _isInitialized = false;
  String _adClient = '';
  static const String _url =
      'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-';

  /// Getter for adClient passed on initialization
  String get adClient => _adClient;

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
      web.console.warn(
          'AdSense: adSense.initialize called multiple times! Skipping.'.toJS);
      return;
    }
    _adClient = adClient;
    if (!(skipJsLoader || _sdkAlreadyLoaded())) {
      _loadJsSdk(_adClient, jsLoaderTarget);
    } else {
      web.console.debug('AdSense: SDK already on page, skipping'.toJS);
    }
    _isInitialized = true;
  }

  /// Returns an [AdUnitWidget] with the specified [configuration].
  Widget adUnit(AdUnitConfiguration configuration) {
    return AdUnitWidget.fromConfig(configuration);
  }

  bool _sdkAlreadyLoaded() {
    return adsbygooglePresent ||
        web.document.querySelector('script[src*=ca-pub-$adClient]') != null;
  }

  void _loadJsSdk(String adClient, web.HTMLElement? target) {
    final String finalUrl = _url + adClient;

    final web.HTMLScriptElement script = web.HTMLScriptElement()
      ..async = true
      ..crossOrigin = 'anonymous';

    if (web.window.nullableTrustedTypes != null) {
      final String trustedTypePolicyName = 'adsense-dart-$adClient';
      web.console.debug(
        'TrustedTypes available. Creating policy: $trustedTypePolicyName'.toJS,
      );
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
      script.src = finalUrl;
    }

    (target ?? web.document.head)!.appendChild(script);
  }
}
