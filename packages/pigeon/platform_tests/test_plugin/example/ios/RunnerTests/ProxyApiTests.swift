// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Testing

@testable import test_plugin

@MainActor
struct ProxyApiTests {
  @Test
  func callsToDartFailIfTheInstanceIsNotInTheInstanceManager() async {
    let testObject = ProxyApiTestClass()

    let binaryMessenger = MockBinaryMessenger<Any>(
      codec: FlutterStandardMessageCodec.sharedInstance())
    let registrar = ProxyApiTestsPigeonProxyApiRegistrar(
      binaryMessenger: binaryMessenger, apiDelegate: ProxyApiDelegate())

    _ = registrar.instanceManager.addHostCreatedInstance(testObject)
    try? registrar.instanceManager.removeAllObjects()

    let api = PigeonApiProxyApiTestClass(
      pigeonRegistrar: registrar, delegate: ProxyApiTestClassDelegate())

    await confirmation { confirmed in
      api.flutterNoop(pigeonInstance: testObject) { response in
        if case .failure(let response) = response {
          #expect(
            response.message
              == "Callback to `ProxyApiTestClass.flutterNoop` failed because native instance was not in the instance manager."
          )
          confirmed()
        }
      }
    }
  }
}
