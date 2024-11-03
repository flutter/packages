// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'ad_unit_widget.dart';
import 'ad_unit_widget_web.dart';

/// Returns a singleton instance of Adsense library public interface
final AdSense adSense = AdSense();

/// Main class to work with the library
class AdSense {
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
    JSObject adsbygoogle;
    if (web.window.getProperty('adsbygoogle'.toJS).isUndefinedOrNull) {
      adsbygoogle = JSArray<JSObject>();
    } else {
      adsbygoogle = web.window.getProperty('adsbygoogle'.toJS);
    }
    globalContext.setProperty('adsbygoogle'.toJS, adsbygoogle);
    final web.HTMLScriptElement script =
        web.document.createElement('script') as web.HTMLScriptElement
          ..async = true
          ..crossOrigin = 'anonymous';
    script.src = _url + adClient;
    web.document.head!.appendChild(script);
  }
}
