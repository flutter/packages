// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Testing

@testable import test_plugin

class MockMultipleArityHostApi: MultipleArityHostApi {
  func subtract(x: Int64, y: Int64) -> Int64 {
    return x - y
  }
}

@MainActor
struct MultipleArityTests {
  var codec = FlutterStandardMessageCodec.sharedInstance()

  @Test
  func simpleHost() async throws {
    let binaryMessenger = MockBinaryMessenger<Int64>(codec: EnumPigeonCodec.shared)
    MultipleArityHostApiSetup.setUp(
      binaryMessenger: binaryMessenger, api: MockMultipleArityHostApi())
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.MultipleArityHostApi.subtract"
    #expect(binaryMessenger.handlers[channelName] != nil)

    let inputX = 10
    let inputY = 7
    let inputEncoded = binaryMessenger.codec.encode([inputX, inputY])

    await confirmation { confirmed in
      binaryMessenger.handlers[channelName]?(inputEncoded) { data in
        let outputList = binaryMessenger.codec.decode(data) as? [Any]
        #expect(outputList != nil)

        let output = outputList![0] as? Int64
        #expect(output == 3)
        #expect(outputList?.count == 1)
        confirmed()
      }
    }
  }

  @Test
  func simpleFlutter() async throws {
    let binaryMessenger = HandlerBinaryMessenger(codec: codec) { args in
      return (args[0] as! Int) - (args[1] as! Int)
    }
    let api = MultipleArityFlutterApi(binaryMessenger: binaryMessenger)

    await confirmation { confirmed in
      api.subtract(x: 30, y: 10) { result in
        switch result {
        case .success(let res):
          #expect(res == 20)
          confirmed()
        case .failure(_):
          Issue.record("Failed")
          return
        }
      }
    }
  }
}
