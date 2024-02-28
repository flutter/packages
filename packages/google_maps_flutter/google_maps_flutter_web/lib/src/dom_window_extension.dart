// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
  external GoogleMapsTrustedTypePolicyFactory? get nullableTrustedTypes;
}

// TODO(ditman): remove this extension type when we depend on package:web 0.5.1
/// This extension exists as a stop gap until `package:web 0.5.1` is released.
/// That version provides the `TrustedTypes` API.
@JS('TrustedTypePolicyFactory')
extension type GoogleMapsTrustedTypePolicyFactory._(JSObject _)
    implements JSObject {
  /// The `TrustedTypePolicy` for Google Maps Flutter.
  static GoogleMapsTrustedTypePolicy? _policy;

  @JS('createPolicy')
  external GoogleMapsTrustedTypePolicy _createPolicy(
    String policyName, [
    GoogleMapsTrustedTypePolicyOptions policyOptions,
  ]);

  /// Get a new [GoogleMapsTrustedTypePolicy].
  ///
  /// If a policy already exists, it will be returned.
  /// Otherwise, a new policy is created.
  ///
  /// Because of we only cache one _policy, this method
  /// specifically hardcoded to the GoogleMaps use case.
  GoogleMapsTrustedTypePolicy getGoogleMapsTrustedTypesPolicy(
    GoogleMapsTrustedTypePolicyOptions policyOptions,
  ) {
    const String policyName = 'google_maps_flutter_sanitize';
    _policy ??= _createPolicy(policyName, policyOptions);

    return _policy!;
  }
}

// TODO(ditman): remove this extension type when we depend on package:web 0.5.1
/// This extension exists as a stop gap until `package:web 0.5.1` is released.
/// That version provides the `TrustedTypes` API.
@JS('TrustedTypePolicy')
extension type GoogleMapsTrustedTypePolicy._(JSObject _) implements JSObject {
  /// Create a new `TrustedHTML` instance with the given [input] and [arguments].
  external GoogleMapsTrustedHTML createHTML(
    String input,
    JSAny? arguments,
  );
}

// TODO(ditman): remove this extension type when we depend on package:web 0.5.1
/// This extension exists as a stop gap until `package:web 0.5.1` is released.
/// That version provides the `TrustedTypes` API.
@JS('TrustedTypePolicyOptions')
extension type GoogleMapsTrustedTypePolicyOptions._(JSObject _)
    implements JSObject {
  /// Create a new `TrustedTypePolicyOptions` instance.
  external factory GoogleMapsTrustedTypePolicyOptions({
    JSFunction createHTML,
  });
}

// TODO(ditman): remove this extension type when we depend on package:web 0.5.1
/// This extension exists as a stop gap until `package:web 0.5.1` is released.
/// That version provides the `TrustedTypes` API.
@JS('TrustedHTML')
extension type GoogleMapsTrustedHTML._(JSObject _) implements JSObject {}

/// This extension provides a setter for the [web.HTMLElement] `innerHTML` property,
/// that accepts trusted HTML only.
extension TrustedInnerHTML on web.HTMLElement {
  /// Set the inner HTML of this element to the given [trustedHTML].
  @JS('innerHTML')
  external set trustedInnerHTML(GoogleMapsTrustedHTML trustedHTML);
}
