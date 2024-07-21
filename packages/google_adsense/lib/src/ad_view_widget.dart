import 'dart:developer';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

class AdViewWidget extends StatefulWidget {
  final String _adClient;
  final String _adSlot;
  final String _adFormat;
  final String _adLayoutKey;
  final String _adLayout;
  final bool _isAdTest;
  final bool _isFullWidthResponsive;
  final Map<String, String> _slotParams;
  final web.HTMLElement _insElement =
      web.document.createElement('ins') as web.HTMLElement;

  AdViewWidget(
      {required String adClient,
      required String adSlot,
      required String adLayoutKey,
      required String adLayout,
      required String adFormat,
      required bool isAdTest,
      required bool isFullWidthResponsive,
      required Map<String, String> slotParams,
      super.key})
      : _slotParams = slotParams,
        _isFullWidthResponsive = isFullWidthResponsive,
        _isAdTest = isAdTest,
        _adLayout = adLayout,
        _adLayoutKey = adLayoutKey,
        _adFormat = adFormat,
        _adSlot = adSlot,
        _adClient = adClient {
    _insElement
      ..className = 'adsbygoogle'
      ..style.display = 'block';
    final Map<String, String> dataattrs = Map.of(<String, String>{
      'adClient': 'ca-pub-$_adClient',
      'adSlot': _adSlot,
      'adFormat': _adFormat,
      'adtest': _isAdTest.toString(),
      'fullWidthResponsive': _isFullWidthResponsive.toString()
    });
    for (final String key in dataattrs.keys) {
      _insElement.dataset
          .setProperty(key as JSString, dataattrs[key] as JSString);
    }
    if (_adLayoutKey != '') {
      _insElement.dataset
          .setProperty('adLayoutKey' as JSString, _adLayoutKey as JSString);
    }
    if (_adLayout != '') {
      _insElement.dataset
          .setProperty('adLayout' as JSString, _adLayout as JSString);
    }
    if (_slotParams.isNotEmpty) {
      for (final String key in _slotParams.keys) {
        _insElement.dataset
            .setProperty(key as JSString, _slotParams[key] as JSString);
      }
    }
  }

  @override
  State<AdViewWidget> createState() => _AdViewWidgetState();
}

class _AdViewWidgetState extends State<AdViewWidget>
    with AutomaticKeepAliveClientMixin {
  static int adViewCounter = 0;
  double adHeight = 1.0;
  late web.HTMLElement adViewDiv;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      height: adHeight,
      child: HtmlElementView.fromTagName(
          tagName: 'div', onElementCreated: onElementCreated, isVisible: true),
    );
  }

  static void onElementAttached(web.HTMLElement element) {
    log('Element ${element.id} attached with style: height=${element.offsetHeight} and width=${element.offsetWidth}');
    // TODO: replace with proper js_interop
    final web.HTMLScriptElement pushAdsScript = web.HTMLScriptElement();
    pushAdsScript.innerText =
        '(adsbygoogle = window.adsbygoogle || []).push({});';
    log('Adding push ads script');
    element.append(pushAdsScript);
  }

  void onElementCreated(Object element) {
    adViewDiv = element as web.HTMLElement;
    log('onElementCreated: ${adViewDiv.toString()} with style height=${element.offsetHeight} and width=${element.offsetWidth}');
    adViewDiv
      ..id = 'adView${(adViewCounter++).toString()}'
      ..style.height = 'min-content'
      ..style.textAlign = 'center';
    // Adding ins inside of the adView
    adViewDiv.append(widget._insElement);

    // TODO: Make shared
    // Using Resize observer to detect element attached to DOM
    web.ResizeObserver((JSArray<web.ResizeObserverEntry> entries,
            web.ResizeObserver observer) {
      for (final web.ResizeObserverEntry entry in entries.toDart) {
        final web.Element target = entry.target;
        if (target.isConnected) {
          // First time resized since attached to DOM -> attachment callback from Flutter docs by David
          if (!(target as web.HTMLElement)
              .dataset
              .getProperty('attached' as JSString)
              .isDefinedAndNotNull) {
            onElementAttached(target);
            target.dataset
                .setProperty('attached' as JSString, true as JSBoolean);
            observer.disconnect();
          }
        }
      }
    }.toJS)
        .observe(adViewDiv);

    // Using Mutation Observer to detect when adslot is being loaded
    web.MutationObserver(
            (JSArray<JSObject> entries, web.MutationObserver observer) {
      for (final JSObject entry in entries.toDart) {
        final web.HTMLElement target =
            (entry as web.MutationRecord).target as web.HTMLElement;
        log('MO current entry: ${target.toString()}');
        if (isLoaded(target)) {
          observer.disconnect();
          if (isFilled(target)) {
            updateHeight(target.offsetHeight);
          } else {
            target.style.pointerEvents = 'none';
          }
        }
      }
    }.toJS)
        .observe(
            widget._insElement,
            web.MutationObserverInit(
                attributes: true,
                attributeFilter:
                    <String>['data-ad-status'].jsify() as JSArray<JSString>));
  }

  bool isLoaded(web.HTMLElement target) {
    final bool isLoaded =
        target.dataset.getProperty('adStatus' as JSString).isDefinedAndNotNull;
    if (isLoaded) {
      log('Ad is loaded');
    } else {
      log('Ad is loading');
    }
    return isLoaded;
  }

  bool isFilled(web.HTMLElement target) {
    final JSAny? adStatus = target.dataset.getProperty('adStatus' as JSString);
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

  void updateHeight(int newHeight) {
    debugPrint('listener invoked with height $newHeight');
    setState(() {
      adHeight = newHeight.toDouble();
    });
  }
}
