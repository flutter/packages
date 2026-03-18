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
    // Plugin registration eventually sends camera operations on the background queue, which
    // would run concurrently with the test cases during unit tests, making the debugging
    // process confusing. This setup is actually not necessary for the unit tests, so
    // skip it when running unit tests.
    if NSClassFromString("XCTestCase") != nil {
      return
    }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
