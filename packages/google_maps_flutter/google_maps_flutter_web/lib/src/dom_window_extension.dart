// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(srujzs): Needed for https://github.com/dart-lang/sdk/issues/54801. Once
// we publish a version with a min SDK constraint that contains this fix,
// remove.
@JS()
library;

import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// This extension gives [web.Window] a nullable getter to the `trustedTypes`
/// property, which is used to check for feature support.
extension NullableTrustedTypesGetter on web.Window {
  /// (Nullable) Bindings to window.trustedTypes.
  ///
  /// This may be null if the browser doesn't support the Trusted Types API.
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/Trusted_Types_API
  @JS('trustedTypes')
  external web.TrustedTypePolicyFactory? get nullableTrustedTypes;
}

/// This extension provides a setter for the [web.HTMLElement] `innerHTML` property,
/// that accepts trusted HTML only.
extension TrustedInnerHTML on web.HTMLElement {
  /// Set the inner HTML of this element to the given [trustedHTML].
  @JS('innerHTML')
  external set trustedInnerHTML(web.TrustedHTML trustedHTML);
}

/// This extension allows supporting both web:0.5.1 and web:1.0.0.
/// To be removed once we stop using web:0.5.1.
extension InnerHTMLString on web.HTMLElement {
  @JS('innerHTML')
  external set innerHTMLString(String value);
}

/// Allows creating a TrustedHTML object from a string, with no arguments.
extension CreateHTMLNoArgs on web.TrustedTypePolicy {
  /// Allows calling `createHTML` with only the `input` argument.
  @JS('createHTML')
  external web.TrustedHTML createHTMLNoArgs(
    String input,
  );
}
