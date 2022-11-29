// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

/**
 * This plugin is currently a no-op since only unit tests have been set up.
 * In the future, this will register Pigeon APIs used in integration tests.
 */
public class TestPlugin: NSObject, FlutterPlugin, HostIntegrationCoreApi {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = TestPlugin()
    HostIntegrationCoreApiSetup.setUp(binaryMessenger: registrar.messenger(), api: plugin)
  }

  // MARK: HostIntegrationCoreApi implementation

  func noop() {
  }

  func echoAllTypes(everything: AllTypes) -> AllTypes {
    return everything
  }
}
