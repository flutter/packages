// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:web/web.dart' as web;

/// Adds a "disablePictureInPicture" setter to [web.HTMLVideoElement]s.
extension NonStandardSettersOnVideoElement on web.HTMLVideoElement {
  // TODO(srujzs): This will be added in `package:web` 0.6.0. Remove this helper
  // once it's available.
  external set disablePictureInPicture(bool disabled);
}

/// Adds a "disableRemotePlayback" and "controlsList" setters to [web.HTMLMediaElement]s.
extension NonStandardSettersOnMediaElement on web.HTMLMediaElement {
  // TODO(srujzs): This will be added in `package:web` 0.6.0. Remove this helper
  // once it's available.
  external set disableRemotePlayback(bool disabled);
  external set controlsList(String? controlsList);
}
