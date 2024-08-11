// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:web/web.dart' as web;
import 'ad_unit_widget_interface.dart';
import 'ad_unit_widget_web.dart';

/// Main class to work with the library
class Adsense {
  /// Returns a singleton instance of Adsense library public interface
  factory Adsense() => _instance ?? Adsense._internal();

  Adsense._internal() {
    _instance = this;
  }

  static Adsense? _instance = Adsense._internal();
  bool _isInitialized = false;
  String _adClient = '';
  static const String _url =
      'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-';

  /// Initialization API. Should be called ASAP, ideally in the main method of your app.
  void initialize(String adClient) {
    if (_isInitialized) {
      throw StateError('Adsense was already initialized, skipping');
    }
    _adClient = adClient;
    _addMasterScript(_adClient);
    _isInitialized = true;
  }

  /// Returns a configurable [AdUnitWidget]
  AdUnitWidget adUnit(
      {required String adSlot,
      String adClient = '',
      bool isAdTest = false,
      Map<String, dynamic> adUnitParams = const <String, dynamic>{}}) {
    return AdUnitWidgetWeb(
      adSlot: adSlot,
      adClient: adClient.isNotEmpty ? adClient : _adClient,
      isAdTest: isAdTest,
      additionalParams: adUnitParams,
    );
  }

  void _addMasterScript(String adClient) {
    final web.HTMLScriptElement script =
        web.document.createElement('script') as web.HTMLScriptElement
          ..async = true
          ..crossOrigin = 'anonymous';
    script.src = _url + adClient;
    (web.document.head ?? web.document).appendChild(script);
  }

  /// Only for use in tests
  static void resetForTesting() {
    _instance = null;
  }
}
