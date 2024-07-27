import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import 'ad_view_widget.dart';

/// Main class to work with the library
class Adsense {
  /// Returns a singleton instance of Adsense library public interface
  factory Adsense() {
    return _instance;
  }
  Adsense._internal();
  static final Adsense _instance = Adsense._internal();
  static bool _isInitialized = false;
  String _adClient = '';

  /// Initialization API. Should be called ASAP, ideally in the main method of your app.
  void initialize(String adClient) {
    if (_isInitialized) {
      log('Adsense was already initialized, skipping');
      return;
    }
    _isInitialized = true;
    _adClient = adClient;
    _addMasterScript(adClient);
  }

  /// Returns a configurable AdViewWidget
  Widget adView(
      {required String adSlot,
      String adClient = '',
      bool isAdTest = false,
      Map<String, dynamic> adUnitParams = const <String, dynamic>{}}) {
    return AdViewWidget(
      adSlot: adSlot,
      adClient: adClient.isNotEmpty ? adClient : _adClient,
      isAdTest: isAdTest,
      additionalParams: adUnitParams,
    );
  }

  static void _addMasterScript(String adClient) {
    final web.HTMLScriptElement scriptElement = web.HTMLScriptElement();
    scriptElement.async = true;
    scriptElement.src =
        'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-$adClient';
    scriptElement.crossOrigin = 'anonymous';
    final web.HTMLHeadElement? head = web.document.head;
    if (head != null) {
      head.appendChild(scriptElement);
    } else {
      web.document.appendChild(scriptElement);
    }
  }
}
