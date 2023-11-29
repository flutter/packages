// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.pigeon_example_app

import ExampleHostApi
import FlutterError
import MessageData
import MessageFlutterApi
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin

// #docregion kotlin-class
private class PigeonApiImplementation : ExampleHostApi {
  override fun getHostLanguage(): String {
    return "Kotlin"
  }

  override fun add(a: Long, b: Long): Long {
    if (a < 0L || b < 0L) {
      throw FlutterError("code", "message", "details")
    }
    return a + b
  }

  override fun sendMessage(message: MessageData, callback: (Result<Boolean>) -> Unit) {
    if (message.code == Code.ONE) {
      callback(Result.failure(FlutterError("code", "message", "details")))
      return
    }
    callback(Result.success(true))
  }
}
// #enddocregion kotlin-class

// #docregion kotlin-class-flutter
private class PigeonFlutterApi {

  var flutterApi: MessageFlutterApi? = null

  constructor(binding: FlutterPlugin.FlutterPluginBinding) {
    flutterApi = MessageFlutterApi(binding.getBinaryMessenger())
  }

  fun callFlutterMethod(aString: String, callback: (Result<String>) -> Unit) {
    flutterApi!!.flutterMethod(aString) { echo -> callback(Result.success(echo)) }
  }
}
// #enddocregion kotlin-class-flutter

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    val api = PigeonApiImplementation()
    ExampleHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, api)
  }
}
