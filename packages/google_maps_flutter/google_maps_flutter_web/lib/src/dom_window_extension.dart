// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(srujzs): Needed for https://github.com/dart-lang/sdk/issues/54801. Once
// we publish a version with a min SDK constraint that contains this fix,
// remove.
@JS()
library;

import 'dart:js_interop';
import 'package:flutter/foundation.dart';
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
  external web.TrustedHTML createHTMLNoArgs(String input);
}

/// This extension gives [web.Window] a nullable getter to the `google`
/// property, which is used to check if the Google Maps SDK is loaded.
@visibleForTesting
extension NullableGoogleGetter on web.Window {
  /// (Nullable) Bindings to window.google.
  @JS('google')
  external JSObject? get nullableGoogle;
}

/// Nullable bindings to get `maps` from a JSObject.
@visibleForTesting
extension NullableMapsGetter on JSObject {
  /// (Nullable) Bindings to google.maps.
  @JS('maps')
  external JSObject? get nullableMaps;
}

/// Nullable bindings to get `visualization` from a JSObject.
@visibleForTesting
extension NullableVisualizationGetter on JSObject {
  /// (Nullable) Bindings to google.maps.visualization.
  @JS('visualization')
  external JSObject? get nullableVisualization;

  /// Bindings to set google.maps.visualization (for testing).
  @JS('visualization')
  external set nullableVisualization(JSObject? value);
}

/// Nullable bindings to get `HeatmapLayer` from a JSObject.
@visibleForTesting
extension NullableHeatmapLayerGetter on JSObject {
  /// (Nullable) Bindings to google.maps.visualization.HeatmapLayer.
  @JS('HeatmapLayer')
  external JSObject? get nullableHeatmapLayer;

  /// Bindings to set HeatmapLayer (for testing).
  @JS('HeatmapLayer')
  external set nullableHeatmapLayer(JSObject? value);
}

/// Returns whether the Heatmap Layer is supported by the loaded Google Maps JS SDK.
bool isHeatmapSupported() {
  final JSObject? google = web.window.nullableGoogle;
  if (google == null) {
    return false;
  }
  final JSObject? maps = google.nullableMaps;
  if (maps == null) {
    return false;
  }
  final JSObject? visualization = maps.nullableVisualization;
  if (visualization == null) {
    return false;
  }
  return visualization.nullableHeatmapLayer != null;
}
