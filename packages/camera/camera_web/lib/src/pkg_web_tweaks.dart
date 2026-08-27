// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart';

/// Adds missing fields to [Element].
extension FullScreenSupportMethods on Element {
  @JS('requestFullscreen')
  external JSPromise<JSAny?> requestFullScreenTweak([JSAny options]);
}

/// Adds missing fields to [MediaTrackSupportedConstraints].
extension NonStandardFieldsOnMediaTrackSupportedConstraints on MediaTrackSupportedConstraints {
  @JS('zoom')
  external bool? get zoomNullable;

  @JS('torch')
  external bool? get torchNullable;
}

/// Adds missing fields to [MediaTrackCapabilities].
extension NonStandardFieldsOnMediaTrackCapabilities on MediaTrackCapabilities {
  @JS('zoom')
  external WebTweakMediaSettingsRange? get zoomNullable;

  /// The raw `torch` capability, as reported by the browser.
  ///
  /// Chromium and WebKit report a `boolean`, while the Image Capture
  /// specification changed this to `sequence<boolean>` in
  /// https://github.com/w3c/mediacapture-image/pull/305. Typed as [JSAny] so
  /// that either shape can be read; see [canEnableTorch].
  @JS('torch')
  external JSAny? get torchNullable;

  /// Whether the camera is able to turn its torch on.
  bool get canEnableTorch {
    final JSAny? torch = torchNullable;
    if (torch == null) {
      return false;
    }
    if (torch.isA<JSBoolean>()) {
      return (torch as JSBoolean).toDart;
    }
    if (torch.isA<JSArray<JSAny?>>()) {
      final List<JSAny?> values = (torch as JSArray<JSAny?>).toDart;
      if (values.every((JSAny? value) => value.isA<JSBoolean>())) {
        return values.any((JSAny? value) => (value! as JSBoolean).toDart);
      }
    }
    assert(() {
      debugPrint(
        'camera_web: ignoring the `torch` capability of this camera because '
        'the browser reported it as neither a boolean nor a sequence of '
        'booleans. Please report the browser and its version at '
        'https://github.com/flutter/flutter/issues.',
      );
      return true;
    }());
    return false;
  }

  @JS('facingMode')
  external JSArray<JSString>? get facingModeNullable;
}

/// Adds missing fields to [MediaTrackSettings]
extension NonStandardFieldsOnMediaTrackSettings on MediaTrackSettings {
  @JS('facingMode')
  external String? get facingModeNullable;
}

/// Brought over from package:web 1.0.0
extension type WebTweakMediaSettingsRange._(JSObject _) implements JSObject {
  external factory WebTweakMediaSettingsRange({num max, num min, num step});

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
  external JSPromise<JSAny?> applyWebTweakConstraints([WebTweakMediaTrackConstraints constraints]);
}

/// Allows creating the MediaTrackConstraints that are needed.
/// Brought over from package:web 1.0.0
extension type WebTweakMediaTrackConstraints._(JSObject _) implements JSObject {
  external factory WebTweakMediaTrackConstraints({JSAny zoom, ConstrainBoolean torch});
}
