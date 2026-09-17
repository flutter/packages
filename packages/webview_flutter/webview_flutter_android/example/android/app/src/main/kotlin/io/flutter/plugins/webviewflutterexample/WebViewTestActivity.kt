// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutterexample

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

// Extends FlutterActivity to make the FlutterEngine accessible for testing.
class WebViewTestActivity : FlutterActivity() {
  @JvmField var engine: FlutterEngine? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    engine = flutterEngine
  }
}
