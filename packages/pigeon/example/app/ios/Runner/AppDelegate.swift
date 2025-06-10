// Copyright 2013 The Flutter Authors. All rights reserved.
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

  func sendMessage(message: MessageData, completion: @escaping (Result<Bool, Error>) -> Void) {
    if message.code == Code.one {
      completion(.failure(PigeonError(code: "code", message: "message", details: "details")))
      return
    }
    completion(.success(true))
  }
}
// #enddocregion swift-class

// #docregion swift-class-flutter
private class PigeonFlutterApi {
  var flutterAPI: MessageFlutterApi

  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterAPI = MessageFlutterApi(binaryMessenger: binaryMessenger)
  }

  func callFlutterMethod(
    aString aStringArg: String?, completion: @escaping (Result<String, PigeonError>) -> Void
  ) {
    flutterAPI.flutterMethod(aString: aStringArg) {
      completion($0)
    }
  }
}
// #enddocregion swift-class-flutter

// #docregion swift-class-event
class EventListener: StreamEventsStreamHandler {
  var eventSink: PigeonEventSink<PlatformEvent>?

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<PlatformEvent>) {
    eventSink = sink
  }

  func onIntEvent(event: Int64) {
    if let eventSink = eventSink {
      eventSink.success(IntEvent(data: event))
    }
  }

  func onStringEvent(event: String) {
    if let eventSink = eventSink {
      eventSink.success(StringEvent(data: event))
    }
  }

  func onEventsDone() {
    eventSink?.endOfStream()
    eventSink = nil
  }
}
// #enddocregion swift-class-event

func sendEvents(_ eventListener: EventListener) {
  var timer: Timer?
  var count: Int64 = 0
  timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
    DispatchQueue.main.async {
      if count >= 100 {
        eventListener.onEventsDone()
        timer?.invalidate()
      } else {
        if (count % 2) == 0 {
          eventListener.onIntEvent(event: Int64(count))
        } else {
          eventListener.onStringEvent(event: String(count))
        }
        count += 1
      }
    }
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// TODO(stuartmorgan): Once 3.33+ reaches stable, remove this subclass and move the setup to
// AppDelegate.register(...). This approach is only used because this example needs to support
// both stable and master, and 3.32 doesn't have FlutterPluginRegistrant, while 3.33+ can't use
// the older application(didFinishLaunchingWithOptions) approach.
@objc class ExampleViewController: FlutterViewController {
  override func awakeFromNib() {
    super.awakeFromNib()

    let api = PigeonApiImplementation()
    ExampleHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: api)
    let controller = self
    // #docregion swift-init-event
    let eventListener = EventListener()
    StreamEventsStreamHandler.register(
      with: controller.binaryMessenger, streamHandler: eventListener)
    // #enddocregion swift-init-event
    sendEvents(eventListener)
  }
}
