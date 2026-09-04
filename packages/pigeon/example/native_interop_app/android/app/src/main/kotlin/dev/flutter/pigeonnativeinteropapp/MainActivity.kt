// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.pigeonnativeinteropapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

private class PigeonApiImplementation : NativeInteropExampleApi {
  override fun doSomething() {
    // In a real application, native platform logic (e.g., accessing Android system APIs,
    // hardware features, or third-party native SDKs) would be implemented here.
    println("NativeInteropExampleApi.doSomething called from Dart")
  }
}

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    val api = PigeonApiImplementation()
    NativeInteropExampleApiRegistrar().register(api)
  }
}
