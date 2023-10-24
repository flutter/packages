// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest
@testable import test_plugin

class MockPrimitiveHostApi: PrimitiveHostApi {
  func anInt(value: Int64) -> Int64 { value }
  func aBool(value: Bool) -> Bool { value }
  func aString(value: String) -> String { value  }
  func aDouble(value: Double) -> Double { value }
  func aMap(value: [AnyHashable: Any?]) -> [AnyHashable: Any?] { value }
  func aList(value: [Any?]) -> [Any?] { value }
  func anInt32List(value: FlutterStandardTypedData) -> FlutterStandardTypedData { value }
  func aBoolList(value: [Bool?]) -> [Bool?] { value }
  func aStringIntMap(value: [String?: Int64?]) -> [String?: Int64?] { value }
}

class PrimitiveTests: XCTestCase {
  var codec = FlutterStandardMessageCodec.sharedInstance()

  func testIntPrimitiveHost() throws {
    let binaryMessenger = MockBinaryMessenger<Int32>(codec: codec)
    PrimitiveHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: MockPrimitiveHostApi())
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.anInt"
    XCTAssertNotNil(binaryMessenger.handlers[channelName])

    let input = 1
    let inputEncoded = binaryMessenger.codec.encode([input])

    let expectation = XCTestExpectation(description: "anInt")
    binaryMessenger.handlers[channelName]?(inputEncoded) { data in
      let outputList = binaryMessenger.codec.decode(data) as? [Any]
      XCTAssertNotNil(outputList)
      
      let output = outputList!.first as? Int64
      XCTAssertEqual(1, output)
      XCTAssertTrue(outputList!.count == 1)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }

  func testIntPrimitiveFlutter() throws {
    let binaryMessenger = EchoBinaryMessenger(codec: codec)
    let api = PrimitiveFlutterApi(binaryMessenger: binaryMessenger)

    let expectation = XCTestExpectation(description: "callback")
    api.anInt(value: 1) { result in
      switch result {
        case .success(let res) :
          XCTAssertEqual(1, res)
          expectation.fulfill()
        case .failure(_) :
          return
        
      }
    }
    wait(for: [expectation], timeout: 1.0)
  }

  func testBoolPrimitiveHost() throws {
    let binaryMessenger = MockBinaryMessenger<Bool>(codec: codec)
    PrimitiveHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: MockPrimitiveHostApi())
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aBool"
    XCTAssertNotNil(binaryMessenger.handlers[channelName])

    let input = true
    let inputEncoded = binaryMessenger.codec.encode([input])

    let expectation = XCTestExpectation(description: "aBool")
    binaryMessenger.handlers[channelName]?(inputEncoded) { data in
      let outputList = binaryMessenger.codec.decode(data) as? [Any]
      XCTAssertNotNil(outputList)
      
      let output = outputList!.first as? Bool
      XCTAssertEqual(true, output)
      XCTAssertTrue(outputList!.count == 1)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }

  func testBoolPrimitiveFlutter() throws {
    let binaryMessenger = EchoBinaryMessenger(codec: codec)
    let api = PrimitiveFlutterApi(binaryMessenger: binaryMessenger)

    let expectation = XCTestExpectation(description: "callback")
    api.aBool(value: true) { result in
      switch result {
        case .success(let res) :
          XCTAssertEqual(true, res)
          expectation.fulfill()
        case .failure(_) :
          return
      }
    }
    wait(for: [expectation], timeout: 1.0)
  }

  func testDoublePrimitiveHost() throws {
    let binaryMessenger = MockBinaryMessenger<Double>(codec: codec)
    PrimitiveHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: MockPrimitiveHostApi())
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aDouble"
    XCTAssertNotNil(binaryMessenger.handlers[channelName])

    let input: Double = 1.0
    let inputEncoded = binaryMessenger.codec.encode([input])

    let expectation = XCTestExpectation(description: "aDouble")
    binaryMessenger.handlers[channelName]?(inputEncoded) { data in
      let outputList = binaryMessenger.codec.decode(data) as? [Any]
      XCTAssertNotNil(outputList)
      
      let output = outputList!.first as? Double
      XCTAssertEqual(1.0, output)
      XCTAssertTrue(outputList!.count == 1)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }

  func testDoublePrimitiveFlutter() throws {
    let binaryMessenger = EchoBinaryMessenger(codec: codec)
    let api = PrimitiveFlutterApi(binaryMessenger: binaryMessenger)

    let expectation = XCTestExpectation(description: "callback")
    let arg: Double = 1.5
    api.aDouble(value: arg) { result in
      switch result {
        case .success(let res) :
          XCTAssertEqual(arg, res)
          expectation.fulfill()
        case .failure(_) :
          return
      }
    }
    wait(for: [expectation], timeout: 1.0)
  }

  func testStringPrimitiveHost() throws {
    let binaryMessenger = MockBinaryMessenger<String>(codec: codec)
    PrimitiveHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: MockPrimitiveHostApi())
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aString"
    XCTAssertNotNil(binaryMessenger.handlers[channelName])

    let input: String = "hello"
    let inputEncoded = binaryMessenger.codec.encode([input])

    let expectation = XCTestExpectation(description: "aString")
    binaryMessenger.handlers[channelName]?(inputEncoded) { data in
      let outputList = binaryMessenger.codec.decode(data) as? [Any]
      XCTAssertNotNil(outputList)
      
      let output = outputList!.first as? String
      XCTAssertEqual("hello", output)
      XCTAssertTrue(outputList!.count == 1)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }

  func testStringPrimitiveFlutter() throws {
    let binaryMessenger = EchoBinaryMessenger(codec: codec)
    let api = PrimitiveFlutterApi(binaryMessenger: binaryMessenger)

    let expectation = XCTestExpectation(description: "callback")
    let arg: String = "hello"
    api.aString(value: arg) { result in
      switch result {
        case .success(let res) :
          XCTAssertEqual(arg, res)
          expectation.fulfill()
        case .failure(_) :
          return
      }
    }
    wait(for: [expectation], timeout: 1.0)
  }

  func testListPrimitiveHost() throws {
    let binaryMessenger = MockBinaryMessenger<[Int]>(codec: codec)
    PrimitiveHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: MockPrimitiveHostApi())
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aList"
    XCTAssertNotNil(binaryMessenger.handlers[channelName])

    let input: [Int] = [1, 2, 3]
    let inputEncoded = binaryMessenger.codec.encode([input])

    let expectation = XCTestExpectation(description: "aList")
    binaryMessenger.handlers[channelName]?(inputEncoded) { data in
      let outputList = binaryMessenger.codec.decode(data) as? [Any]
      XCTAssertNotNil(outputList)
      
      let output = outputList!.first as? [Int]
      XCTAssertEqual([1, 2, 3], output)
      XCTAssertTrue(outputList!.count == 1)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }

  func testListPrimitiveFlutter() throws {
    let binaryMessenger = EchoBinaryMessenger(codec: codec)
    let api = PrimitiveFlutterApi(binaryMessenger: binaryMessenger)

    let expectation = XCTestExpectation(description: "callback")
    let arg = ["hello"]
    api.aList(value: arg) { result in
      switch result {
        case .success(let res) :
          XCTAssert(equalsList(arg, res))
          expectation.fulfill()
        case .failure(_) :
          return
      }
    }
    wait(for: [expectation], timeout: 1.0)
  }

  func testMapPrimitiveHost() throws {
    let binaryMessenger = MockBinaryMessenger<[String: Int]>(codec: codec)
    PrimitiveHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: MockPrimitiveHostApi())
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aMap"
    XCTAssertNotNil(binaryMessenger.handlers[channelName])

    let input: [String: Int] = ["hello": 1, "world": 2]
    let inputEncoded = binaryMessenger.codec.encode([input])

    let expectation = XCTestExpectation(description: "aMap")
    binaryMessenger.handlers[channelName]?(inputEncoded) { data in
      let output = binaryMessenger.codec.decode(data) as? [Any]
      XCTAssertTrue(output?.count == 1)

      let outputMap = output?.first as? [String: Int]
      XCTAssertNotNil(outputMap)
      XCTAssertEqual(["hello": 1, "world": 2], outputMap)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }

  func testMapPrimitiveFlutter() throws {
    let binaryMessenger = EchoBinaryMessenger(codec: codec)
    let api = PrimitiveFlutterApi(binaryMessenger: binaryMessenger)

    let expectation = XCTestExpectation(description: "callback")
    let arg = ["hello": 1]
    api.aMap(value: arg) { result in
      switch result {
        case .success(let res) :
          XCTAssert(equalsDictionary(arg, res))
          expectation.fulfill()
        case .failure(_) :
          return
      }

    }
    wait(for: [expectation], timeout: 1.0)
  }

}
