import 'dart:developer';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

class AdViewWidget extends StatefulWidget {
  final String adClient;
  final String adSlot;
  final String adFormat;
  final String adLayoutKey;
  final String adLayout;
  final bool isAdTest;
  final bool isFullWidthResponsive;
  final Map<String, String> slotParams;
  final web.HTMLElement insElement =
      web.document.createElement("ins") as web.HTMLElement;

  AdViewWidget(
      {required this.adClient,
      required this.adSlot,
      required this.adLayoutKey,
      required this.adLayout,
      required this.adFormat,
      required this.isAdTest,
      required this.isFullWidthResponsive,
      required this.slotParams,
      super.key}) {
    insElement
      ..className = 'adsbygoogle'
      ..style.display = 'block';
    var dataattrs = Map.of({
      "adClient": "ca-pub-$adClient",
      "adSlot": adSlot,
      "adFormat": adFormat,
      "adtest": isAdTest.toString(),
      "fullWidthResponsive": isFullWidthResponsive.toString()
    });
    for (var key in dataattrs.keys) {
      insElement.dataset
          .setProperty(key as JSString, dataattrs[key] as JSString);
    }
    if (adLayoutKey != "") {
      insElement.dataset
          .setProperty("adLayoutKey" as JSString, adLayoutKey as JSString);
    }
    if (adLayout != "") {
      insElement.dataset
          .setProperty("adLayout" as JSString, adLayout as JSString);
    }
    if (slotParams.isNotEmpty) {
      for (var key in slotParams.keys) {
        insElement.dataset
            .setProperty(key as JSString, slotParams[key] as JSString);
      }
    }
  }

  @override
  State<AdViewWidget> createState() => _AdViewWidgetState();
}

class _AdViewWidgetState extends State<AdViewWidget>
    with AutomaticKeepAliveClientMixin {
  static int adViewCounter = 0;
  double adHeight = 1;
  late web.HTMLElement adViewDiv;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      height: adHeight,
      child: HtmlElementView.fromTagName(
          tagName: "div", onElementCreated: onElementCreated, isVisible: true),
    );
  }

  static void onElementAttached(web.HTMLElement element) {
    log("Element ${element.id} attached with style: height=${element.offsetHeight} and width=${element.offsetWidth}");
    // TODO: replace with proper js_interop
    var pushAdsScript = web.HTMLScriptElement();
    pushAdsScript.innerText =
        "(adsbygoogle = window.adsbygoogle || []).push({});";
    log("Adding push ads script");
    element.append(pushAdsScript);
  }

  void onElementCreated(Object element) {
    adViewDiv = element as web.HTMLElement;
    log("onElementCreated: ${adViewDiv.toString()} with style height=${element.offsetHeight} and width=${element.offsetWidth}");
    adViewDiv
      ..id = 'adView${(adViewCounter++).toString()}'
      ..style.height = "min-content"
      ..style.textAlign = "center";
    // Adding ins inside of the adView
    adViewDiv.append(widget.insElement);

    // TODO: Make shared
    // Using Resize observer to detect element attached to DOM
    web.ResizeObserver((JSArray<web.ResizeObserverEntry> entries,
            web.ResizeObserver observer) {
      for (web.ResizeObserverEntry entry in entries.toDart) {
        var target = entry.target;
        if (target.isConnected) {
          // First time resized since attached to DOM -> attachment callback from Flutter docs by David
          if (!(target as web.HTMLElement)
              .dataset
              .getProperty("attached" as JSString)
              .isDefinedAndNotNull) {
            onElementAttached(target);
            target.dataset
                .setProperty("attached" as JSString, true as JSBoolean);
            observer.disconnect();
          }
        }
      }
    }.toJS)
        .observe(adViewDiv);

    // Using Mutation Observer to detect when adslot is being loaded
    web.MutationObserver(
            ((JSArray<JSObject> entries, web.MutationObserver observer) {
      for (JSObject entry in entries.toDart) {
        var target = (entry as web.MutationRecord).target as web.HTMLElement;
        log("MO current entry: ${target.toString()}");
        if (isLoaded(target)) {
          observer.disconnect();
          if (isFilled(target)) {
            updateHeight(target.offsetHeight);
          } else {
            target.style.pointerEvents = "none";
          }
        }
      }
    }.toJS))
        .observe(
            widget.insElement,
            web.MutationObserverInit(
                attributes: true,
                attributeFilter:
                    ["data-ad-status"].jsify() as JSArray<JSString>));
  }

  bool isLoaded(web.HTMLElement target) {
    var isLoaded =
        target.dataset.getProperty("adStatus" as JSString).isDefinedAndNotNull;
    if (isLoaded) {
      log("Ad is loaded");
    } else {
      log("Ad is loading");
    }
    return isLoaded;
  }

  bool isFilled(web.HTMLElement target) {
    var adStatus = target.dataset.getProperty("adStatus" as JSString);
    switch (adStatus) {
      case "filled":
        {
          log("Ad filled");
          return true;
        }
      case "unfilled":
        {
          log("Ad unfilled!");
          return false;
        }
      default:
        log("No data-ad-status attribute found");
        return false;
    }
  }

  void updateHeight(newHeight) {
    debugPrint("listener invoked with height $newHeight");
    setState(() {
      adHeight = newHeight.toDouble();
    });
  }
}
