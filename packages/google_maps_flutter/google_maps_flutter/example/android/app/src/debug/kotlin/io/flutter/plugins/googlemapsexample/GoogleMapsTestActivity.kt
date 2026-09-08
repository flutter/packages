// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemapsexample

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

// Makes the FlutterEngine accessible for testing.
class GoogleMapsTestActivity : FlutterActivity() {
  @JvmField var engine: FlutterEngine? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    engine = flutterEngine
  }
}
