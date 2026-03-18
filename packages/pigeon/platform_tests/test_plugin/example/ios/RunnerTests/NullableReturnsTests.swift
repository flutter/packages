// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Testing

@testable import test_plugin

class MockNullableArgHostApi: NullableArgHostApi {
  var didCall: Bool = false
  var x: Int64?

  func doit(x: Int64?) -> Int64 {
    didCall = true
    self.x = x
    return x ?? 0
  }
}

@MainActor
struct NullableReturnsTests {
  var codec = FlutterStandardMessageCodec.sharedInstance()

  @Test
  func nullableParameterWithFlutterApi() async throws {
    let binaryMessenger = EchoBinaryMessenger(codec: codec)
    binaryMessenger.defaultReturn = 99
    let api = NullableArgFlutterApi(binaryMessenger: binaryMessenger)

    await confirmation { confirmed in
      api.doit(x: nil) { result in
        switch result {
        case .success(let res):
          #expect(res == 99)
          confirmed()
        case .failure(let error):
          Issue.record("Failed with error: \(error)")
        }
      }
    }
  }

  @Test
  func nullableParameterWithHostApi() async throws {
    let api = MockNullableArgHostApi()
    let binaryMessenger = MockBinaryMessenger<Int64?>(codec: codec)
    let channel = "dev.flutter.pigeon.pigeon_integration_tests.NullableArgHostApi.doit"

    NullableArgHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: api)
    #expect(binaryMessenger.handlers[channel] != nil)

    let inputEncoded = binaryMessenger.codec.encode([nil] as [Any?])

    await confirmation { confirmed in
      binaryMessenger.handlers[channel]?(inputEncoded) { _ in
        confirmed()
      }
    }

    #expect(api.didCall)
    #expect(api.x == nil)
  }
}
