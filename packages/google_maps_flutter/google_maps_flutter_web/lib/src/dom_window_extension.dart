// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'package:web/web.dart';

/// This extension type exists to handle unsupported features by certain browsers.
@JS()
extension type WindowWithTrustedTypes(Window _) implements JSObject {
  /// Get the `trustedTypes` object from the window, if it is supported.
  @JS('trustedTypes')
  external TrustedTypePolicyFactory? get trustedTypesNullable;
}

// TODO(ditman): remove this extension type when we depend on package:web 0.5.1
/// This extension exists as a stop gap until `package:web 0.5.1` is released.
/// That version provides the `TrustedTypes` API.
@JS()
extension type TrustedTypePolicyFactory._(JSObject _) implements JSObject {
  /// Create a new `TrustedTypePolicy` instance
  /// with the given [policyName] and [policyOptions].
  external TrustedTypePolicy createPolicy(
    String policyName, [
    TrustedTypePolicyOptions policyOptions,
  ]);
}

// TODO(ditman): remove this extension type when we depend on package:web 0.5.1
/// This extension exists as a stop gap until `package:web 0.5.1` is released.
/// That version provides the `TrustedTypes` API.
extension type TrustedTypePolicy._(JSObject _) implements JSObject {
  /// Create a new `TrustedHTML` instance with the given [input] and [arguments].
  external TrustedHTML createHTML(
    String input,
    JSAny? arguments,
  );
}

// TODO(ditman): remove this extension type when we depend on package:web 0.5.1
/// This extension exists as a stop gap until `package:web 0.5.1` is released.
/// That version provides the `TrustedTypes` API.
@JS()
extension type TrustedTypePolicyOptions._(JSObject _) implements JSObject {
  /// Create a new `TrustedTypePolicyOptions` instance.
  external factory TrustedTypePolicyOptions({
    JSFunction createHTML,
  });
}

// TODO(ditman): remove this extension type when we depend on package:web 0.5.1
/// This extension exists as a stop gap until `package:web 0.5.1` is released.
/// That version provides the `TrustedTypes` API.
@JS()
extension type TrustedHTML._(JSObject _) implements JSObject {
  // This type inherits `toString()` from `Object`.
  // See also: https://developer.mozilla.org/en-US/docs/Web/API/TrustedHTML/toString
}
