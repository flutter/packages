// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'ad_unit_widget.dart';
import 'ad_unit_widget_web.dart';

/// Main class to work with the library
class AdSense {
  // Internal constructor
  AdSense._internal();

  /// Returns a singleton instance of Adsense library public interface
  static AdSense get instance => _instance;

  // Singleton property
  static AdSense _instance = AdSense._internal();
  bool _isInitialized = false;
  String _adClient = '';
  static const String _url =
      'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-';

  /// Initialization API. Should be called ASAP, ideally in the main method of your app.
  /// Throws [StateError] if called more than once
  void initialize(String adClient) {
    if (_isInitialized) {
      throw StateError('AdSense was already initialized, skipping');
    }
    _adClient = adClient;
    _addMasterScript(_adClient);
    _isInitialized = true;
  }

  /// Returns a configurable [AdUnitWidget]
  ///
  /// `adSlot`: see [AdUnitParams.AD_SLOT]
  ///
  /// `adClient`: see [AdUnitParams.AD_CLIENT]
  ///
  /// `isAdTest`: testing environment flag, should be set to `false` in production
  ///
  /// `adUnitParams`: see [AdUnitParams] for the non-extensive list of some possible keys.
  AdUnitWidget adUnit(
      {required String adSlot,
      String adClient = '',
      bool isAdTest = kDebugMode,
      Map<String, String> adUnitParams = const <String, String>{},
      String? cssText}) {
    return AdUnitWidgetWeb(
        adSlot: adSlot,
        adClient: adClient.isNotEmpty ? adClient : _adClient,
        isAdTest: isAdTest,
        additionalParams: adUnitParams,
        cssText: cssText);
  }

  void _addMasterScript(String adClient) {
    final web.HTMLScriptElement adsbygoogle = web.HTMLScriptElement();
    adsbygoogle.innerText = 'adsbygoogle = window.adsbygoogle || [];';
    final web.HTMLScriptElement script =
        web.document.createElement('script') as web.HTMLScriptElement
          ..async = true
          ..crossOrigin = 'anonymous';
    script.src = _url + adClient;
    (web.document.head ?? web.document).appendChild(adsbygoogle);
    (web.document.head ?? web.document).appendChild(script);
  }

  /// Only for use in tests
  static void resetForTesting() {
    _instance = AdSense._internal();
  }
}
