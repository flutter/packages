// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'ad_unit_configuration.dart';
import 'ad_unit_widget.dart';
import 'ad_unit_widget_web.dart';
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
  void initialize(String adClient) {
    if (_isInitialized) {
      web.console.warn('AdSense: sdk was already initialized, skipping'.toJS);
      return;
    }
    _adClient = adClient;
    _addMasterScript(_adClient);
    _isInitialized = true;
  }

  /// Returns a configurable [AdUnitWidget]<br>
  /// `configuration`: see [AdUnitConfiguration]
  AdUnitWidget adUnit(AdUnitConfiguration configuration) {
    return AdUnitWidgetWeb.fromConfig(configuration);
  }

  void _addMasterScript(String adClient) {
    final String finalUrl = _url + adClient;

    web.TrustedScriptURL? trustedUrl;
    if (web.window.nullableTrustedTypes != null) {
      final String finalUrl = _url + adClient;
      const String trustedTypePolicyName = 'adsense-dart';
      web.console.debug(
        'TrustedTypes available. Creating policy: $trustedTypePolicyName'.toJS,
      );
      try {
        final web.TrustedTypePolicy policy =
            web.window.trustedTypes.createPolicy(
                trustedTypePolicyName,
                web.TrustedTypePolicyOptions(
                  createScriptURL: ((JSString url) => finalUrl).toJS,
                ));
        trustedUrl = policy.createScriptURLNoArgs(finalUrl);
      } catch (e) {
        throw TrustedTypesException(e.toString());
      }
    }

    final web.HTMLScriptElement script = web.HTMLScriptElement()
      ..async = true
      ..crossOrigin = 'anonymous';
    if (trustedUrl != null) {
      script.trustedSrc = trustedUrl;
    } else {
      script.src = finalUrl;
    }

    script.src = finalUrl;
    web.document.head!.appendChild(script);
  }
}
