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

/// Loads the GIS SDK for web, using Trusted Types API when available.
Future<void> loadWebSdk({
  web.HTMLElement? target,
  String trustedTypePolicyName = _defaultTrustedPolicyName,
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

  final web.HTMLScriptElement script =
      web.document.createElement('script') as web.HTMLScriptElement
        ..async = true
        ..defer = true;
  if (trustedUrl != null) {
    script.trustedSrc = trustedUrl;
  } else {
    script.src = _url;
  }

  (target ?? web.document.head!).appendChild(script);

  return completer.future;
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
