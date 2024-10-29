// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import '../google_adsense.dart';
import 'js_interop/adsbygoogle.dart';

/// Widget displaying an ad unit
class AdUnitWidgetWeb extends AdUnitWidget {
  // TODO(sokoloff06): consider builder?
  /// Constructs [AdUnitWidgetWeb]
  AdUnitWidgetWeb({
    required String adClient,
    required String adSlot,
    required bool isAdTest,
    required Map<String, String> additionalParams,
    String? cssText,
    super.key,
  })  : _adClient = adClient,
        _adSlot = adSlot,
        _isAdTest = isAdTest,
        _additionalParams = additionalParams {
    _insElement
      ..className = 'adsbygoogle'
      ..style.display = 'block';
    if (cssText != null && cssText.isNotEmpty) {
      _insElement.style.cssText = cssText;
    }
    final Map<String, String> dataAttrs = <String, String>{
      AdUnitParams.AD_CLIENT: 'ca-pub-$_adClient',
      AdUnitParams.AD_SLOT: _adSlot,
    };
    if (_isAdTest) {
      dataAttrs.addAll(<String, String>{_AD_TEST_KEY: 'on'});
    }
    for (final String key in dataAttrs.keys) {
      _insElement.dataset.setProperty(key.toJS, dataAttrs[key]!.toJS);
    }
    if (_additionalParams.isNotEmpty) {
      for (final String key in _additionalParams.keys) {
        _insElement.dataset.setProperty(key.toJS, _additionalParams[key]!.toJS);
      }
    }
  }

  static const String _AD_TEST_KEY = 'adtest';

  @override
  String get adClient => _adClient;
  final String _adClient;

  @override
  String get adSlot => _adSlot;
  final String _adSlot;

  @override
  bool get isAdTest => _isAdTest;
  final bool _isAdTest;

  @override
  Map<String, String> get additionalParams => _additionalParams;
  final Map<String, String> _additionalParams;

  final web.HTMLElement _insElement =
      web.document.createElement('ins') as web.HTMLElement;

  @override
  State<AdUnitWidgetWeb> createState() => _AdUnitWidgetWebState();
}

class _AdUnitWidgetWebState extends State<AdUnitWidgetWeb>
    with AutomaticKeepAliveClientMixin {
  static int adUnitCounter = 0;
  double adHeight = 1.0;
  late web.HTMLElement adUnitDiv;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      height: adHeight,
      child: HtmlElementView.fromTagName(
          tagName: 'div', onElementCreated: onElementCreated),
    );
  }

  void onElementCreated(Object element) {
    adUnitDiv = element as web.HTMLElement;
    log('onElementCreated: $adUnitDiv with style height=${element.offsetHeight} and width=${element.offsetWidth}');
    adUnitDiv
      ..id = 'adUnit${adUnitCounter++}'
      ..style.height = 'min-content'
      ..style.textAlign = 'center';
    // Adding ins inside of the adUnit
    adUnitDiv.append(widget._insElement);

    // TODO(sokoloff06): Make shared
    // Using Resize observer to detect element attached to DOM
    web.ResizeObserver((JSArray<web.ResizeObserverEntry> entries,
            web.ResizeObserver observer) {
      for (final web.ResizeObserverEntry entry in entries.toDart) {
        final web.Element target = entry.target;
        if (target.isConnected) {
          // First time resized since attached to DOM -> attachment callback from Flutter docs by David
          if (!(target as web.HTMLElement)
              .dataset
              .getProperty('attached'.toJS)
              .isDefinedAndNotNull) {
            onElementAttached(target);
            target.dataset.setProperty('attached'.toJS, true.toJS);
            observer.disconnect();
          }
        }
      }
    }.toJS)
        .observe(adUnitDiv);

    // Using Mutation Observer to detect when adslot is being loaded based on https://support.google.com/adsense/answer/10762946?hl=en
    web.MutationObserver(
            (JSArray<JSObject> entries, web.MutationObserver observer) {
      for (final JSObject entry in entries.toDart) {
        final web.HTMLElement target =
            (entry as web.MutationRecord).target as web.HTMLElement;
        log('MO current entry: $target');
        if (isLoaded(target)) {
          observer.disconnect();
          if (isFilled(target)) {
            updateWidgetHeight(target.offsetHeight);
          } else {
            // Prevent scrolling issues over empty ad slot
            target.style.pointerEvents = 'none';
            target.style.height = '0px';
            updateWidgetHeight(0);
          }
        }
      }
    }.toJS)
        .observe(
            widget._insElement,
            web.MutationObserverInit(
                attributes: true,
                attributeFilter: <JSString>['data-ad-status'.toJS].toJS));
  }

  void onElementAttached(web.HTMLElement element) {
    log('Element ${element.id} attached with style: height=${element.offsetHeight} and width=${element.offsetWidth}');
    adsbygoogle.loadAds();
  }

  bool isLoaded(web.HTMLElement target) {
    final bool isLoaded =
        target.dataset.getProperty('adStatus'.toJS).isDefinedAndNotNull;
    if (isLoaded) {
      log('Ad is loaded');
    } else {
      log('Ad is loading');
    }
    return isLoaded;
  }

  bool isFilled(web.HTMLElement target) {
    final JSAny? adStatus = target.dataset.getProperty('adStatus'.toJS);
    switch (adStatus) {
      case 'filled':
        {
          log('Ad filled');
          return true;
        }
      case 'unfilled':
        {
          log('Ad unfilled!');
          return false;
        }
      default:
        log('No data-ad-status attribute found');
        return false;
    }
  }

  void updateWidgetHeight(int newHeight) {
    debugPrint('listener invoked with height $newHeight');
    setState(() {
      adHeight = newHeight.toDouble();
    });
  }
}
