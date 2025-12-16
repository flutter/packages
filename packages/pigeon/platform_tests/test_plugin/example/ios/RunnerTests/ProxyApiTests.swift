// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import test_plugin

class ProxyApiTests: XCTestCase {
  func testCallsToDartFailIfTheInstanceIsNotInTheInstanceManager() {
    let testObject = ProxyApiTestClass()

    let binaryMessenger = MockBinaryMessenger<Any>(
      codec: FlutterStandardMessageCodec.sharedInstance())
    let registrar = ProxyApiTestsPigeonProxyApiRegistrar(
      binaryMessenger: binaryMessenger, apiDelegate: ProxyApiDelegate())

    _ = registrar.instanceManager.addHostCreatedInstance(testObject)
    try? registrar.instanceManager.removeAllObjects()

    let api = PigeonApiProxyApiTestClass(
      pigeonRegistrar: registrar, delegate: ProxyApiTestClassDelegate())

    var error: String? = nil
    api.flutterNoop(pigeonInstance: testObject) { response in
      if case .failure(let response) = response {
        error = response.message
      }
    }

    XCTAssertEqual(
      error,
      "Callback to `ProxyApiTestClass.flutterNoop` failed because native instance was not in the instance manager."
    )
  }
}
