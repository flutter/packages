// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

private class PigeonApiImplementation: NativeInteropExampleApi {
  func doSomething() throws {
    // In a real application, native platform logic (e.g., accessing iOS system APIs,
    // hardware features, or third-party native frameworks) would be implemented here.
    print("NativeInteropExampleApi.doSomething called from Dart")
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let api = PigeonApiImplementation()
    NativeInteropExampleApiSetup.register(api: api)
  }
}
