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
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "dev.flutter.plugins.shared_preferences_example/multi_engine",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      if call.method == "attachAndDetachSecondaryEngine" {
        autoreleasepool {
          let secondaryEngine = FlutterEngine(
            name: "secondary_engine",
            project: nil,
            allowHeadlessExecution: true
          )
          guard secondaryEngine.run() else {
            secondaryEngine.destroyContext()
            result(
              FlutterError(
                code: "secondary-engine-error",
                message: "Failed to run secondary FlutterEngine.",
                details: nil
              )
            )
            return
          }
          GeneratedPluginRegistrant.register(with: secondaryEngine)
          secondaryEngine.destroyContext()
        }
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
