// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

/**
 * This plugin handles the native side of the integration tests in
 * example/integration_test/.
 */
public class TestPlugin: NSObject, FlutterPlugin, AllVoidHostApi, HostEverything {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = TestPlugin()
    AllVoidHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: plugin)
    HostEverythingSetup.setUp(binaryMessenger: registrar.messenger(), api: plugin)
  }

  // MARK: AllVoidHostApi implementation

  func doit() {
    // No-op
  }

  // MARK: HostEverything implementation

  func giveMeEverything() -> Everything {
    // Currently unused in integration tests, so just return an empty object.
    return Everything()
  }

  func echo(everything: Everything) -> Everything {
    return everything
  }
}
