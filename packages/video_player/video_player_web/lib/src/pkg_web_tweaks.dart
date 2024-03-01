// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Adds a "disablePictureInPicture" setter to [web.HTMLVideoElement]s.
extension DisablePictureSetterInPictureInVideoElement on web.HTMLVideoElement {
  external set disablePictureInPicture(JSBoolean disabled);
}

/// Adds a "disableRemotePlayback" setter to [web.HTMLMediaElement]s.
extension DisableRemotePlaybackSetterInMediaElement on web.HTMLMediaElement {
  external set disableRemotePlayback(JSBoolean disabled);
}

/// Adds a "controlsList" setter to [web.HTMLMediaElement]s.
extension ControlsListSetterInMediaElement on web.HTMLMediaElement {
  external set controlsList(JSString? controlsList);
}
