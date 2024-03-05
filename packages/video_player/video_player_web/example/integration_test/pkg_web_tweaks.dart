// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS()
library video_player_web_integration_test_pkg_web_tweaks;

import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Adds a `controlsList` getter to `HTMLVideoElement`s.
extension ControlsListInVideoElement on web.HTMLVideoElement {
  external web.DOMTokenList? get controlsList;
}

/// Adds a `disablePictureInPicture` getter to `HTMLVideoElement`s.
extension DisablePictureInPictureInVideoElement on web.HTMLVideoElement {
  external JSBoolean get disablePictureInPicture;
}

/// Adds a `disableRemotePlayback` getter to `HTMLMediaElement`s.
extension DisableRemotePlaybackInMediaElement on web.HTMLMediaElement {
  external JSBoolean get disableRemotePlayback;
}

/// Retrieves the `Object` constructor from the DOM.
@JS('Object')
external DomObjectConstructor get jsObjectConstructor;

/// Defines the JS interop we need from the `Object` constructor.
extension type DomObjectConstructor._(JSAny _) {
  @JS('defineProperty')
  external void _defineProperty(JSAny? object, JSString property, JSAny? value);

  /// `Object.defineProperty`.
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty
  void defineProperty(JSObject object, String property, Object? value) {
    return _defineProperty(object, property.toJS, value.jsify());
  }
}

/// The bag of properties that can be set by `defineProperty`.
extension type Descriptor._(JSObject _) implements JSObject {
  /// Constructs a bag of properties to be defined on a target object with `defineProperty`.
  factory Descriptor({
    bool? writable,
    Object? value,
  }) =>
      Descriptor._js(
        writable: writable!.toJS,
        value: value.jsify()!,
      );
  // May also contain "configurable" and "enumerable" bools.
  // See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty#description
  external factory Descriptor._js({
    // bool configurable,
    // bool enumerable,
    JSBoolean? writable,
    JSAny value,
  });
}
