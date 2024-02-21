// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'package:web/web.dart' as web;

// TODO(kevmoo): Make this file unnecessary, https://github.com/dart-lang/web/issues/175

/// This extension gives web.window a nullable getter to the `trustedTypes`
/// property, which needs to be used to check for feature support.
extension NullableTrustedTypesGetter on web.Window {
  /// (Nullable) Bindings to window.trustedTypes.
  ///
  /// This may be null if the browser doesn't support the Trusted Types API.
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/Trusted_Types_API
  @JS('trustedTypes')
  external TrustedTypePolicyFactory? get nullableTrustedTypes;

  /// Bindings to window.trustedTypes.
  ///
  /// This will crash if accessed in a browser that doesn't support the
  /// Trusted Types API.
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/Trusted_Types_API
  @JS('trustedTypes')
  external TrustedTypePolicyFactory get trustedTypes;
}

/// This extension allows setting a TrustedScriptURL as the src of a script element,
/// which currently only accepts a string.
extension TrustedTypeSrcAttribute on web.HTMLScriptElement {
  @JS('src')
  external set trustedSrc(TrustedScriptURL value);
}

// TODO(kevmoo): drop all of this once `pkg:web` publishes `0.5.1`.

/// Bindings to a JS TrustedScriptURL.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/TrustedScriptURL
extension type TrustedScriptURL._(JSObject _) implements JSObject {}

/// Bindings to a JS TrustedTypePolicyFactory.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/TrustedTypePolicyFactory
extension type TrustedTypePolicyFactory._(JSObject _) implements JSObject {
  ///
  external TrustedTypePolicy createPolicy(
    String policyName, [
    TrustedTypePolicyOptions policyOptions,
  ]);
}

/// Bindings to a JS TrustedTypePolicy.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/TrustedTypePolicy
extension type TrustedTypePolicy._(JSObject _) implements JSObject {
  ///
  @JS('createScriptURL')
  external TrustedScriptURL createScriptURLNoArgs(
    String input,
  );
}

/// Bindings to a JS TrustedTypePolicyOptions (anonymous).
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/TrustedTypePolicyFactory/createPolicy#policyoptions
extension type TrustedTypePolicyOptions._(JSObject _) implements JSObject {
  ///
  external factory TrustedTypePolicyOptions({
    JSFunction createScriptURL,
  });
}
