// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.pigeon_example_app

import EmptyEvent
import ExampleHostApi
import FlutterError
import IntEvent
import MessageData
import MessageFlutterApi
import PigeonEventSink
import PlatformEvent
import StreamEventsStreamHandler
import StringEvent
import android.os.Handler
import android.os.Looper
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
private class PigeonFlutterApi(binding: FlutterPlugin.FlutterPluginBinding) {
  var flutterApi: MessageFlutterApi? = null

  init {
    flutterApi = MessageFlutterApi(binding.binaryMessenger)
  }

  fun callFlutterMethod(aString: String, callback: (Result<String>) -> Unit) {
    flutterApi!!.flutterMethod(aString) { echo -> callback(echo) }
  }
}
// #enddocregion kotlin-class-flutter

// #docregion kotlin-class-event
class EventListener : StreamEventsStreamHandler() {
  private var eventSink: PigeonEventSink<PlatformEvent>? = null

  override fun onListen(p0: Any?, sink: PigeonEventSink<PlatformEvent>) {
    eventSink = sink
  }

  fun onIntEvent(event: Long) {
    eventSink?.success(IntEvent(data = event))
  }

  fun onStringEvent(event: String) {
    eventSink?.success(StringEvent(data = event))
  }

  fun onEmptyEvent() {
    eventSink?.success(EmptyEvent())
  }

  fun onEventsDone() {
    eventSink?.endOfStream()
    eventSink = null
  }
}
// #enddocregion kotlin-class-event

fun sendEvents(eventListener: EventListener) {
  val handler = Handler(Looper.getMainLooper())
  var count: Int = 0
  val r: Runnable =
      object : Runnable {
        override fun run() {
          if (count >= 100) {
            handler.post { eventListener.onEventsDone() }
          } else {
            if (count % 2 == 0) {
              handler.post {
                eventListener.onIntEvent(count.toLong())
                count++
              }
            } else if (count % 5 == 0) {
              handler.post {
                eventListener.onEmptyEvent()
                count++
              }
            } else {
              handler.post {
                eventListener.onStringEvent(count.toString())
                count++
              }
            }
            handler.postDelayed(this, 1000)
          }
        }
      }
  handler.post(r)
}

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    val api = PigeonApiImplementation()
    ExampleHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, api)
    // #docregion kotlin-init-event
    val eventListener = EventListener()
    StreamEventsStreamHandler.register(flutterEngine.dartExecutor.binaryMessenger, eventListener)
    // #enddocregion kotlin-init-event
    sendEvents(eventListener)
  }
}
