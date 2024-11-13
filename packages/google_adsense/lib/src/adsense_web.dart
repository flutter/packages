// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'package:web/web.dart' as web;
import 'ad_unit_configuration.dart';
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
    final web.HTMLScriptElement script = web.HTMLScriptElement()
      ..async = true
      ..crossOrigin = 'anonymous';
    script.src = _url + adClient; // This needs TrustedTypes
    web.document.head!.appendChild(script);
  }
}
