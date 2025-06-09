// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import test_plugin

class MockEnumApi2Host: EnumApi2Host {
  func echo(data: DataWithEnum) -> DataWithEnum {
    return data
  }
}

class EnumTests: XCTestCase {

  func testEchoHost() throws {
    let binaryMessenger = MockBinaryMessenger<DataWithEnum>(codec: EnumPigeonCodec.shared)
    EnumApi2HostSetup.setUp(binaryMessenger: binaryMessenger, api: MockEnumApi2Host())
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.EnumApi2Host.echo"
    XCTAssertNotNil(binaryMessenger.handlers[channelName])

    let input = DataWithEnum(state: .success)
    let inputEncoded = binaryMessenger.codec.encode([input])

    let expectation = XCTestExpectation(description: "echo")
    binaryMessenger.handlers[channelName]?(inputEncoded) { data in
      let outputMap = binaryMessenger.codec.decode(data) as? [Any]
      XCTAssertNotNil(outputMap)

      let output = outputMap?.first as? DataWithEnum
      XCTAssertEqual(output, input)
      XCTAssertTrue(outputMap?.count == 1)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }

  func testEchoFlutter() throws {
    let data = DataWithEnum(state: .error)
    let binaryMessenger = EchoBinaryMessenger(codec: EnumPigeonCodec.shared)
    let api = EnumApi2Flutter(binaryMessenger: binaryMessenger)

    let expectation = XCTestExpectation(description: "callback")
    api.echo(data: data) { result in
      switch result {
      case .success(let res):
        XCTAssertEqual(res.state, res.state)
        expectation.fulfill()
      case .failure(_):
        return
      }
    }
    wait(for: [expectation], timeout: 1.0)
  }

}
