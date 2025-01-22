// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:web/web.dart' as web;

/// Logs [log] to the JS console with debug level, if [kDebugMode] is `true`.
void debugLog(String log) {
  if (kDebugMode) {
    web.console.debug('[google_adsense] $log'.toJS);
  }
}
