// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS()
library video_player_web_integration_test_pkg_web_tweaks;

import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Adds a `controlsList` and `disablePictureInPicture` getters.
extension NonStandardGettersOnVideoElement on web.HTMLVideoElement {
  external web.DOMTokenList? get controlsList;
  // TODO(srujzs): This will be added in `package:web` 0.6.0. Remove this helper
  // once it's available.
  external bool get disablePictureInPicture;
}

/// Adds a `disableRemotePlayback` getter.
extension NonStandardGettersOnMediaElement on web.HTMLMediaElement {
  // TODO(srujzs): This will be added in `package:web` 0.6.0. Remove this helper
  // once it's available.
  external bool get disableRemotePlayback;
}

/// Defines JS interop to access static methods from `Object`.
@JS('Object')
extension type DomObject._(JSAny _) {
  @JS('defineProperty')
  external static void _defineProperty(
      JSAny? object, JSString property, Descriptor value);

  /// `Object.defineProperty`.
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty
  static void defineProperty(
      JSObject object, String property, Descriptor descriptor) {
    return _defineProperty(object, property.toJS, descriptor);
  }
}

/// The descriptor for the property being defined or modified with `defineProperty`.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty#description
extension type Descriptor._(JSObject _) implements JSObject {
  /// Builds a "data descriptor".
  factory Descriptor.data({
    bool? writable,
    JSAny? value,
  }) =>
      Descriptor._data(
        writable: writable?.toJS,
        value: value.jsify(),
      );

  /// Builds an "accessor descriptor".
  factory Descriptor.accessor({
    void Function(JSAny? value)? set,
    JSAny? Function()? get,
  }) =>
      Descriptor._accessor(
        set: set?.toJS,
        get: get?.toJS,
      );

  external factory Descriptor._accessor({
    // JSBoolean configurable,
    // JSBoolean enumerable,
    JSFunction? set,
    JSFunction? get,
  });

  external factory Descriptor._data({
    // JSBoolean configurable,
    // JSBoolean enumerable,
    JSBoolean? writable,
    JSAny? value,
  });
}
