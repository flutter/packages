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
  external web.TrustedScriptURL createScriptURLNoArgs(
    String input,
  );
}
