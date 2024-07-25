library adsense_web_standalone;

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import 'ad_view_widget.dart';

class Adsense {
  static final Adsense _instance = Adsense._internal();
  static bool _isInitialized = false;

  Adsense._internal();

  factory Adsense() {
    return _instance;
  }

  void initialize(String adClient) {
    if (_isInitialized) {
      log('Adsense was already initialized, skipping');
      return;
    }
    _isInitialized = true;
    _addMasterScript(adClient);
  }

  Widget adView(
      {required String adClient,
      required String adSlot,
      String adLayoutKey = '',
      String adLayout = '',
      String adFormat = 'auto',
      bool isAdTest = false,
      bool isFullWidthResponsive = true,
      Map<String, String> slotParams = const {}}) {
    return AdViewWidget(
      adSlot: adSlot,
      adClient: adClient,
      adLayoutKey: adLayoutKey,
      adLayout: adLayout,
      adFormat: adFormat,
      isAdTest: isAdTest,
      isFullWidthResponsive: isFullWidthResponsive,
      slotParams: slotParams,
    );
  }

  static void _addMasterScript(String adClient) {
    final web.HTMLScriptElement scriptElement = web.HTMLScriptElement();
    scriptElement.async = true;
    scriptElement.src =
        'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-$adClient';
    scriptElement.crossOrigin = 'anonymous';
    var head = web.document.head;
    if (head != null) {
      head.appendChild(scriptElement);
    } else {
      web.document.appendChild(scriptElement);
    }
  }
}
