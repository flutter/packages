// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:web/web.dart' as web;

/// Adds a "captureStream" getter to [web.HTMLMediaElement]s.
extension NonStandardSettersOnMediaElement on web.HTMLMediaElement {
  // TODO(srujzs): This will be added in `package:web` 0.6.0. Remove this helper
  // once it's available.
  external web.MediaStream captureStream();
}

/// Adds a "captureStream" getter to [web.HTMLCanvasElement]s.
extension NonStandardSettersOnCanvasElement on web.HTMLCanvasElement {
  // TODO(srujzs): This will be added in `package:web` 0.6.0. Remove this helper
  // once it's available.
  external web.MediaStream captureStream();
}
