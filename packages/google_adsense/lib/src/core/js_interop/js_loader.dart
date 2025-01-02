// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'dart:js_interop_unsafe' show JSObjectUnsafeUtilExtension;
import 'package:web/web.dart' as web;

import '../../utils/logging.dart';
import 'adsbygoogle.dart' show adsbygooglePresent;
import 'package_web_tweaks.dart';

// The URL of the ads by google client.
const String _URL =
    'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js';

/// Loads the JS SDK for [adClient].
///
/// [target] can be used to specify a different injection target than
/// `window.document.head`, and is normally used for tests.
///
/// [dataAttributes] are used to configure the dataset `data-` attributes of the
/// created script element.
Future<void> loadJsSdk(
  String adClient, {
  web.HTMLElement? target,
  Map<String, String>? dataAttributes,
}) async {
  if (_sdkAlreadyLoaded(adClient, target)) {
    debugLog('adsbygoogle.js already injected. Skipping call to loadJsSdk.');
    return;
  }

  final String scriptUrl = '$_URL?client=ca-pub-$adClient';

  final web.HTMLScriptElement script = web.HTMLScriptElement()
    ..async = true
    ..crossOrigin = 'anonymous';

  if (web.window.nullableTrustedTypes != null) {
    final String trustedTypePolicyName = 'adsense-dart-$adClient';
    try {
      final web.TrustedTypePolicy policy = web.window.trustedTypes.createPolicy(
          trustedTypePolicyName,
          web.TrustedTypePolicyOptions(
            createScriptURL: ((JSString url) => url).toJS,
          ));
      script.trustedSrc = policy.createScriptURLNoArgs(scriptUrl);
    } catch (e) {
      throw TrustedTypesException(e.toString());
    }
  } else {
    debugLog('TrustedTypes not available.');
    script.src = scriptUrl;
  }

  _applyDataAttributes(script, dataAttributes);

  (target ?? web.document.head)!.appendChild(script);
}

// Applies a map of [attributes] to the `dataset` of [element].
void _applyDataAttributes(
  web.HTMLElement element,
  Map<String, String>? attributes,
) {
  attributes?.forEach((String key, String value) {
    element.dataset.setProperty(key.toJS, value.toJS);
  });
}

// Whether the script for [adClient] is already injected.
//
// [target] can be used to specify a different injection target than
// `window.document.head`, and is normally used for tests.
bool _sdkAlreadyLoaded(
  String adClient,
  web.HTMLElement? target,
) {
  final String selector = 'script[src*=ca-pub-$adClient]';
  return adsbygooglePresent ||
      web.document.querySelector(selector) != null ||
      target?.querySelector(selector) != null;
}
