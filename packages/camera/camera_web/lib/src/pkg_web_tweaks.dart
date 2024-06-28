// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:js_interop';

import 'package:web/web.dart';

// TODO(srujzs): These will be added in `package:web` 0.6.0. Remove all
// helpers unless otherwise marked.

/// Adds missing fields to [HTMLMediaElement]s.
extension NonStandardFieldsOnMediaElement on HTMLMediaElement {
  external MediaStream captureStream();
}

/// Adds missing fields to [HTMLCanvasElement]s.
extension NonStandardFieldsOnCanvasElement on HTMLCanvasElement {
  external MediaStream captureStream();
}

/// Adds missing fields to [MediaTrackSupportedConstraints].
extension NonStandardFieldsOnMediaTrackSupportedConstraints
    on MediaTrackSupportedConstraints {
  static MediaTrackSupportedConstraints construct({
    bool? zoom,
    bool? torch,
  }) {
    final MediaTrackSupportedConstraints constraints =
        MediaTrackSupportedConstraints();

    if (zoom != null) {
      constraints.zoom = zoom;
    }
    if (torch != null) {
      constraints.torch = torch;
    }

    return constraints;
  }

  external set zoom(bool value);
  external set torch(bool value);

  // Do not remove this with web 0.6.0.
  @JS('zoom')
  external bool? get zoomNullable;

  // Do not remove this with web 0.6.0.
  @JS('torch')
  external bool? get torchNullable;
}

/// Adds missing fields to [MediaTrackCapabilities].

extension NonStandardFieldsOnMediaTrackCapabilities on MediaTrackCapabilities {
  static MediaTrackCapabilities construct({
    MediaSettingsRange? zoom,
    JSArray<JSBoolean>? torch,
  }) {
    final MediaTrackCapabilities capabilities = MediaTrackCapabilities();

    if (zoom != null) {
      capabilities.zoom = zoom;
    }
    if (torch != null) {
      capabilities.torch = torch;
    }

    return capabilities;
  }

  external set zoom(MediaSettingsRange value);
  external set torch(JSArray<JSBoolean> value);

  // Do not remove this with web 0.6.0.
  @JS('zoom')
  external MediaSettingsRange? get zoomNullable;

  // Do not remove this with web 0.6.0.
  @JS('torch')
  external JSArray<JSBoolean>? get torchNullable;
}

/// Adds missing fields to [MediaTrackConstraints].
extension NonStandardFieldsOnMediaTrackConstraints on MediaTrackConstraints {
  static MediaTrackConstraints construct({
    JSAny? zoom,
    ConstrainBoolean? torch,
  }) {
    final MediaTrackConstraints constraints = MediaTrackConstraints();

    if (zoom != null) {
      constraints.zoom = zoom;
    }
    if (torch != null) {
      constraints.torch = torch;
    }

    return constraints;
  }
}

/// Adds missing fields to [MediaTrackConstraintSet].
extension NonStandardFieldsOnMediaTrackConstraintSet
    on MediaTrackConstraintSet {
  external JSAny get zoom;
  external set zoom(JSAny value);
  external ConstrainBoolean get torch;
  external set torch(ConstrainBoolean value);
}

extension type MediaSettingsRange._(JSObject _) implements JSObject {
  external factory MediaSettingsRange({
    num max,
    num min,
    num step,
  });

  external num get max;
  external set max(num value);
  external num get min;
  external set min(num value);
  external num get step;
  external set step(num value);
}

typedef FullscreenNavigationUI = String;
extension type FullscreenOptions._(JSObject _) implements JSObject {
  external factory FullscreenOptions({
    FullscreenNavigationUI navigationUI,
    JSObject screen,
  });

  external FullscreenNavigationUI get navigationUI;
  external set navigationUI(FullscreenNavigationUI value);
  external JSObject get screen;
  external set screen(JSObject value);
}

/// Adds missing fields to [Element]
extension NonStandardFieldsOnElement on Element {
  external JSPromise<JSAny?> requestFullscreen([FullscreenOptions options]);
}
