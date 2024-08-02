// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:js_interop';

import 'package:web/web.dart';

/// Adds missing fields to [Element].
extension FullScreenSupportMethods on Element {
  @JS('requestFullscreen')
  external JSPromise<JSAny?> requestFullScreenTweak([JSAny options]);
}

/// Adds missing fields to [MediaTrackSupportedConstraints].
extension NonStandardFieldsOnMediaTrackSupportedConstraints
    on MediaTrackSupportedConstraints {
  @JS('zoom')
  external bool? get zoomNullable;

  @JS('torch')
  external bool? get torchNullable;
}

/// Adds missing fields to [MediaTrackCapabilities].
extension NonStandardFieldsOnMediaTrackCapabilities on MediaTrackCapabilities {
  @JS('zoom')
  external WebTweakMediaSettingsRange? get zoomNullable;

  @JS('torch')
  external JSArray<JSBoolean>? get torchNullable;
}

/// Adds missing fields to [MediaTrackSettings]
extension NonStandardFieldsOnMediaTrackSettings on MediaTrackSettings {
  @JS('facingMode')
  external String? get facingModeNullable;
}

/// Brought over from package:web 1.0.0
extension type WebTweakMediaSettingsRange._(JSObject _) implements JSObject {
  @JS('MediaSettingsRange')
  external factory WebTweakMediaSettingsRange({
    num max,
    num min,
    num step,
  });

  external double get max;
  external set max(num value);
  external double get min;
  external set min(num value);
  external double get step;
  external set step(num value);
}

/// Adds an applyConstraints method that accepts the WebTweakMediaTrackConstraints.
extension WebTweakMethodVersions on MediaStreamTrack {
  @JS('applyConstraints')
  external JSPromise<JSAny?> applyWebTweakConstraints(
      [WebTweakMediaTrackConstraints constraints]);
}

/// Allows creating the MediaTrackConstraints that are needed.
/// Brought over from package:web 1.0.0
extension type WebTweakMediaTrackConstraints._(JSObject _) implements JSObject {
  @JS('MediaTrackConstraints')
  external factory WebTweakMediaTrackConstraints({
    JSAny zoom,
    ConstrainBoolean torch,
  });
}
