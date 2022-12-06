// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

/**
 * This plugin handles the native side of the integration tests in
 * example/integration_test/.
 */
public class TestPlugin: NSObject, FlutterPlugin, HostIntegrationCoreApi {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = TestPlugin()
    HostIntegrationCoreApiSetup.setUp(binaryMessenger: registrar.messenger(), api: plugin)
  }

  // MARK: HostIntegrationCoreApi implementation

  public func noop() {
  }

  public func echoAllTypes(everything: AllTypes) -> AllTypes {
    return everything
  }

  public func throwError() {
    // TODO(stuartmorgan): Implement this. See
    // https://github.com/flutter/flutter/issues/112483
  }

  public func extractNestedString(wrapper: AllTypesWrapper) -> String? {
    return wrapper.values.aString;
  }

  public func createNestedString(string: String) -> AllTypesWrapper {
    return AllTypesWrapper(values: AllTypes(aString: string))
  }
}
