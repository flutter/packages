// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

// #docregion swift-class
private class PigeonApiImplementation: ExampleHostApi {
  func getHostLanguage() throws -> String {
    return "Swift"
  }

  func add(_ a: Int64, to b: Int64) throws -> Int64 {
    if a < 0 || b < 0 {
      throw PigeonError(code: "code", message: "message", details: "details")
    }
    return a + b
  }

  func sendMessage(message: MessageData) async throws -> Bool {
    if message.code == Code.one {
      throw PigeonError(code: "code", message: "message", details: "details")
    }
    return true
  }
}
// #enddocregion swift-class

// #docregion swift-class-flutter
private class PigeonFlutterApi {
  var flutterAPI: MessageFlutterApi

  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterAPI = MessageFlutterApi(binaryMessenger: binaryMessenger)
  }

  func callFlutterMethod(aString aStringArg: String?) async throws -> String {
    return try await flutterAPI.flutterMethod(aString: aStringArg)
  }
}
// #enddocregion swift-class-flutter

// #docregion swift-class-event
private class EventStreamImplementation: EventStreamHostApi {
  func streamEvents() -> AsyncThrowingStream<PlatformEvent, Error> {
    AsyncThrowingStream { continuation in
      let task = Task {
        for count: Int64 in 0..<100 {
          if Task.isCancelled { break }
          if (count % 2) == 0 {
            continuation.yield(IntEvent(data: count))
          } else {
            continuation.yield(StringEvent(data: String(count)))
          }
          try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
        continuation.finish()
      }
      continuation.onTermination = { _ in task.cancel() }
    }
  }
}
// #enddocregion swift-class-event

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let api = PigeonApiImplementation()
    let binaryMessenger = engineBridge.applicationRegistrar.messenger()
    ExampleHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: api)
    // #docregion swift-init-event
    EventStreamHostApiSetup.setUp(
      binaryMessenger: binaryMessenger, api: EventStreamImplementation())
    // #enddocregion swift-init-event
  }
}
