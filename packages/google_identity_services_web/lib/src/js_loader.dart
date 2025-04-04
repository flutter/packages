// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'js_interop/load_callback.dart';
import 'js_interop/package_web_tweaks.dart';

// The URL from which the script should be downloaded.
const String _url = 'https://accounts.google.com/gsi/client';

// The default TrustedPolicy name that will be used to inject the script.
const String _defaultTrustedPolicyName = 'gis-dart';

// Sentinel value to tell apart when users explicitly set the nonce value to `null`.
const String _undefined = '___undefined___';

/// Loads the GIS SDK for web, using Trusted Types API when available.
///
/// This attempts to use Trusted Types when available, and creates a new policy
/// with the given [trustedTypePolicyName].
///
/// By default, the script will attempt to copy the `nonce` attribute from other
/// scripts in the page. The [nonce] parameter will be used when passed, and
/// not-null. When [nonce] parameter is explicitly `null`, no `nonce`
/// attribute is applied to the script.
Future<void> loadWebSdk({
  web.HTMLElement? target,
  String trustedTypePolicyName = _defaultTrustedPolicyName,
  String? nonce = _undefined,
}) {
  final Completer<void> completer = Completer<void>();
  onGoogleLibraryLoad = () => completer.complete();

  // If TrustedTypes are available, prepare a trusted URL.
  web.TrustedScriptURL? trustedUrl;
  if (web.window.nullableTrustedTypes != null) {
    web.console.debug(
      'TrustedTypes available. Creating policy: $trustedTypePolicyName'.toJS,
    );
    try {
      final web.TrustedTypePolicy policy = web.window.trustedTypes.createPolicy(
          trustedTypePolicyName,
          web.TrustedTypePolicyOptions(
            createScriptURL: ((JSString url) => _url).toJS,
          ));
      trustedUrl = policy.createScriptURLNoArgs(_url);
    } catch (e) {
      throw TrustedTypesException(e.toString());
    }
  }

  final web.HTMLScriptElement script = web.HTMLScriptElement()
    ..async = true
    ..defer = true;
  if (trustedUrl != null) {
    script.trustedSrc = trustedUrl;
  } else {
    script.src = _url;
  }

  if (_getNonce(suppliedNonce: nonce) case final String nonce?) {
    script.nonce = nonce;
  }

  (target ?? web.document.head!).appendChild(script);

  return completer.future;
}

/// Computes the actual nonce value to use.
///
/// If [suppliedNonce] has been explicitly passed, returns that.
/// If `suppliedNonce` is null, it attempts to locate the `nonce`
/// attribute from other script in the page.
String? _getNonce({String? suppliedNonce, web.Window? window}) {
  if (suppliedNonce != _undefined) {
    return suppliedNonce;
  }

  final web.Window currentWindow = window ?? web.window;
  final web.NodeList elements =
      currentWindow.document.querySelectorAll('script');

  for (int i = 0; i < elements.length; i++) {
    if (elements.item(i) case final web.HTMLScriptElement element) {
      // Chrome may return an empty string instead of null.
      final String nonce =
          element.nullableNonce ?? element.getAttribute('nonce') ?? '';
      if (nonce.isNotEmpty) {
        return nonce;
      }
    }
  }
  return null;
}

/// Exception thrown if the Trusted Types feature is supported, enabled, and it
/// has prevented this loader from injecting the JS SDK.
class TrustedTypesException implements Exception {
  ///
  TrustedTypesException(this.message);

  /// The message of the exception
  final String message;
  @override
  String toString() => 'TrustedTypesException: $message';
}
