// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.pigeon_example_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

private class PigeonApiImplementation : ExampleHostApi() {
  override fun determineHostLanguage(): String {
    return "Kotlin"
  }

  override fun add(a: Long, b: Long): Long {
    if (a < 0L || b < 0L) {
      throw FlutterError("code", "message", "details")
    }
    return a + b
  }

  override suspend fun sendMessage(message: MessageData): Boolean {
    if (message.code == Code.ONE) {
      throw FlutterError("code", "message", "details")
    }
    return true
  }
}

private class PigeonFlutterApi {
  fun callFlutterMethod(aString: String): String? {
    val flutterApi = MessageFlutterApiRegistrar().getInstance()
    return flutterApi?.flutterMethod(aString)
  }
}

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    val api = PigeonApiImplementation()
    ExampleHostApiRegistrar().register(api)
  }
}
