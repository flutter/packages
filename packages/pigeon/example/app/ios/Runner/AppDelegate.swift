// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

private class PigeonApiImplementation: ExampleHostApi {
  func getHostLanguage() throws -> String {
    return "Swift"
  }
}

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
