// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

// #docregion swift-class
// This extension of Error is required to do use FlutterError in any swift code.
extension FlutterError: Error {}

private class PigeonApiImplementation: ExampleHostApi {
  func getHostLanguage() throws -> String {
    return "Swift"
  }

  func add(a: Int64, b: Int64) throws -> Int64 {
    if (a < 0 || b < 0) {
      throw FlutterError("code", "message", "details");
    }
    return a + b
  }

  func sendMessage(message: CreateMessage, completion: @escaping (Result<Bool, Error>) -> Void) {
    if (message.code == Code.one) {
      completion(Result(false, FlutterError("code", "message", "details")))
      return
    }
    completion(Result(true, nil))
  }
}
// #enddocregion swift-class

// #docregion swift-class-flutter
private class PigeonFlutterApi {
  var flutterAPI: MessageFlutterApi

  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterAPI = MessageFlutterApi(binaryMessenger: binaryMessenger)
  }

  func callFlutterMethod(String: aString) {
    flutterAPI.flutterMethod(aString) {
      completion(.success($0))
    }
  }
}
// #enddocregion swift-class-flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController
    let api = PigeonApiImplementation()
    ExampleHostApiSetup.setUp(binaryMessenger: controller.binaryMessenger, api: api)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)

  }
}
