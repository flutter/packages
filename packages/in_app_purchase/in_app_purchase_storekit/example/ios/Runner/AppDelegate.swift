// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // Plugin registration eventually starts listening to StoreKit transactions in the background,
    // which would run concurrently with the test cases during unit tests and auto-finish
    // transactions under test. Skip it when running unit tests.
    if NSClassFromString("XCTestCase") != nil {
      return
    }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
