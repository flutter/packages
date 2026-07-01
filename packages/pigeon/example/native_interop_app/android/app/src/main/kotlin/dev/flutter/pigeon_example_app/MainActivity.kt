// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.pigeon_example_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

private class PigeonApiImplementation : NativeInteropExampleApi() {
  override fun doSomething() {
    // Do nothing or print
  }
}

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    val api = PigeonApiImplementation()
    NativeInteropExampleApiRegistrar().register(api)
  }
}
