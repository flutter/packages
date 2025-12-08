// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import Flutter
import XCTest

@testable import test_plugin

class MockHostSmallApi: HostSmallApi {
  var output: String?

  func echo(aString: String, completion: @escaping (Result<String, Error>) -> Void) {
    completion(.success(output!))
  }

  func voidVoid(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.success(()))
  }
}

class AsyncHandlersTest: XCTestCase {

  func testAsyncHost2Flutter() throws {
    let value = "Test"
    let binaryMessenger = MockBinaryMessenger<String>(codec: CoreTestsPigeonCodec.shared)
    binaryMessenger.result = value
    let flutterApi = FlutterIntegrationCoreApi(binaryMessenger: binaryMessenger)

    let expectation = XCTestExpectation(description: "callback")
    flutterApi.echo(value) { result in
      switch result {
      case .success(let res):
        XCTAssertEqual(res, value)
        expectation.fulfill()
      case .failure(_):
        return
      }

    }
    wait(for: [expectation], timeout: 1.0)
  }

  func testAsyncFlutter2HostVoidVoid() throws {
    let binaryMessenger = MockBinaryMessenger<String>(
      codec: FlutterStandardMessageCodec.sharedInstance())
    let mockHostSmallApi = MockHostSmallApi()
    HostSmallApiSetup.setUp(binaryMessenger: binaryMessenger, api: mockHostSmallApi)
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.HostSmallApi.voidVoid"
    XCTAssertNotNil(binaryMessenger.handlers[channelName])

    let expectation = XCTestExpectation(description: "voidvoid callback")
    binaryMessenger.handlers[channelName]?(nil) { data in
      let outputList = binaryMessenger.codec.decode(data) as? [Any]
      XCTAssertEqual(outputList?.first as! NSNull, NSNull())
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }

  func testAsyncFlutter2Host() throws {
    let binaryMessenger = MockBinaryMessenger<String>(
      codec: FlutterStandardMessageCodec.sharedInstance())
    let mockHostSmallApi = MockHostSmallApi()
    let value = "Test"
    mockHostSmallApi.output = value
    HostSmallApiSetup.setUp(binaryMessenger: binaryMessenger, api: mockHostSmallApi)
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.HostSmallApi.echo"
    XCTAssertNotNil(binaryMessenger.handlers[channelName])

    let inputEncoded = binaryMessenger.codec.encode([value])

    let expectation = XCTestExpectation(description: "echo callback")
    binaryMessenger.handlers[channelName]?(inputEncoded) { data in
      let outputList = binaryMessenger.codec.decode(data) as? [Any]
      let output = outputList?.first as? String
      XCTAssertEqual(output, value)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }
}
