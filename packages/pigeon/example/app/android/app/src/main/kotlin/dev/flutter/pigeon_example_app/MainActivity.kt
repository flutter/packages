// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.pigeon_example_app

import EventStreamHostApi
import ExampleHostApi
import FlutterError
import IntEvent
import MessageData
import MessageFlutterApi
import PlatformEvent
import StringEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

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

  override suspend fun sendMessage(message: MessageData): Boolean {
    if (message.code == Code.ONE) {
      throw FlutterError("code", "message", "details")
    }
    return true
  }
}
// #enddocregion kotlin-class

// #docregion kotlin-class-flutter
private class PigeonFlutterApi(binding: FlutterPlugin.FlutterPluginBinding) {
  var flutterApi: MessageFlutterApi? = null

  init {
    flutterApi = MessageFlutterApi(binding.binaryMessenger)
  }

  suspend fun callFlutterMethod(aString: String): String {
    return flutterApi!!.flutterMethod(aString)
  }
}
// #enddocregion kotlin-class-flutter

// #docregion kotlin-class-event
private class EventStreamImplementation : EventStreamHostApi {
  override fun streamEvents(): Flow<PlatformEvent> = flow {
    for (count in 0L until 100L) {
      if (count % 2L == 0L) {
        emit(IntEvent(data = count))
      } else {
        emit(StringEvent(data = count.toString()))
      }
      delay(1000)
    }
  }
}
// #enddocregion kotlin-class-event

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    val api = PigeonApiImplementation()
    ExampleHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, api)
    // #docregion kotlin-init-event
    EventStreamHostApi.setUp(
        flutterEngine.dartExecutor.binaryMessenger, EventStreamImplementation())
    // #enddocregion kotlin-init-event
  }
}
