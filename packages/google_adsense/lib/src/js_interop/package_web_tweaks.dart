// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'package:web/web.dart' as web;

// Re-use of https://github.com/flutter/packages/blob/main/packages/google_identity_services_web/lib/src/js_interop/package_web_tweaks.dart

/// This extension gives web.window a nullable getter to the `trustedTypes`
/// property, which needs to be used to check for feature support.
extension NullableTrustedTypesGetter on web.Window {
  /// (Nullable) Bindings to window.trustedTypes.
  ///
  /// This may be null if the browser doesn't support the Trusted Types API.
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/Trusted_Types_API
  @JS('trustedTypes')
  external web.TrustedTypePolicyFactory? get nullableTrustedTypes;
}

/// Allows setting a TrustedScriptURL as the src of a script element.
extension TrustedTypeSrcAttribute on web.HTMLScriptElement {
  @JS('src')
  external set trustedSrc(web.TrustedScriptURL value);
}

/// Allows creating a script URL only from a string, with no arguments.
extension CreateScriptUrlNoArgs on web.TrustedTypePolicy {
  /// Allows calling `createScriptURL` with only the `input` argument.
  @JS('createScriptURL')
  external web.TrustedScriptURL createScriptURLNoArgs(String input);
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
