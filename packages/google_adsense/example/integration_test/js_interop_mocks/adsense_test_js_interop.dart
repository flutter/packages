// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS()
library;

import 'dart:js_interop';
import 'dart:ui';

import 'package:google_adsense/src/adsense/ad_unit_params.dart';
import 'package:web/web.dart' as web;
import 'adsbygoogle_js_interop.dart';

export 'adsbygoogle_js_interop.dart';

typedef MockAdConfig = ({Size size, String adStatus});

/// Returns a function that generates a "push" function for [mockAdsByGoogle].
PushFn mockAd({
  Size size = Size.zero,
  String adStatus = AdStatus.FILLED,
}) {
  return mockAds(
    <MockAdConfig>[(size: size, adStatus: adStatus)],
  );
}

/// Returns a function that handles a bunch of ad units at once. Can be used with [mockAdsByGoogle].
PushFn mockAds(List<MockAdConfig> adConfigs) {
  return (JSAny? _) {
    final List<web.HTMLElement> foundTargets =
        web.document.querySelectorAll('div[id^=adUnit] ins').toList;

    for (int i = 0; i < foundTargets.length; i++) {
      final web.HTMLElement adTarget = foundTargets[i];
      if (adTarget.children.length > 0) {
        continue;
      }

      final (:Size size, :String adStatus) = adConfigs[i];

      final web.HTMLElement fakeAd = web.HTMLDivElement()
        ..style.width = '${size.width}px'
        ..style.height = '${size.height}px'
        ..style.background = '#fabada';

      // AdSense seems to be setting the width/height on the `ins` of the injected ad too.
      adTarget
        ..style.width = '${size.width}px'
        ..style.height = '${size.height}px'
        ..style.display = 'block'
        ..appendChild(fakeAd)
        ..setAttribute('data-ad-status', adStatus);
    }
  };
}

extension on web.NodeList {
  List<web.HTMLElement> get toList {
    final List<web.HTMLElement> result = <web.HTMLElement>[];
    for (int i = 0; i < length; i++) {
      final web.Node? node = item(i);
      if (node != null && node.isA<web.HTMLElement>()) {
        result.add(node as web.HTMLElement);
      }
    }
    return result;
  }
}
