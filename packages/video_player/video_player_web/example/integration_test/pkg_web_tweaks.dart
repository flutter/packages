// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS()
library video_player_web_integration_test_pkg_web_tweaks;

import 'dart:js_interop';
import 'package:web/web.dart' as web;

extension ControlsListInVideoElement on web.HTMLVideoElement {
  external web.DOMTokenList? get controlsList;
}

extension DisablePictureInPictureInVideoElement on web.HTMLVideoElement {
  external JSBoolean get disablePictureInPicture;
}

extension DisableRemotePlaybackInMediaElement on web.HTMLMediaElement {
  external JSBoolean get disableRemotePlayback;
}

@JS('Object')
external DomObjectConstructor get jsObjectConstructor;

extension type DomObjectConstructor._(JSAny _) {
  @JS('defineProperty')
  external void _defineProperty(JSAny? object, JSString property, JSAny? value);
  void defineProperty(JSObject object, String property, Object? value) {
    return _defineProperty(object, property.toJS, value.jsify());
  }
}

extension type Descriptor._(JSObject _) implements JSObject {
  // May also contain "configurable" and "enumerable" bools.
  // See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty#description
  factory Descriptor({
    bool? writable,
    Object? value,
  }) =>
      Descriptor._js(
        writable: writable!.toJS,
        value: value.jsify()!,
      );
  external factory Descriptor._js({
    // bool configurable,
    // bool enumerable,
    JSBoolean? writable,
    JSAny value,
  });
}
