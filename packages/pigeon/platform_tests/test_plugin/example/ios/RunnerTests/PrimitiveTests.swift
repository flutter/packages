// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Testing

@testable import test_plugin

class MockPrimitiveHostApi: PrimitiveHostApi {
  func anInt(value: Int64) -> Int64 { value }
  func aBool(value: Bool) -> Bool { value }
  func aString(value: String) -> String { value }
  func aDouble(value: Double) -> Double { value }
  func aMap(value: [AnyHashable?: Any?]) -> [AnyHashable?: Any?] { value }
  func aList(value: [Any?]) -> [Any?] { value }
  func anInt32List(value: FlutterStandardTypedData) -> FlutterStandardTypedData { value }
  func aBoolList(value: [Bool?]) -> [Bool?] { value }
  func aStringIntMap(value: [String?: Int64?]) -> [String?: Int64?] { value }
}

@MainActor
struct PrimitiveTests {
  var codec = FlutterStandardMessageCodec.sharedInstance()

  @Test
  func intPrimitiveHost() async throws {
    let binaryMessenger = MockBinaryMessenger<Int32>(codec: codec)
    PrimitiveHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: MockPrimitiveHostApi())
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.anInt"
    #expect(binaryMessenger.handlers[channelName] != nil)

    let input = 1
    let inputEncoded = binaryMessenger.codec.encode([input])

    await confirmation { confirmed in
      binaryMessenger.handlers[channelName]?(inputEncoded) { data in
        let outputList = binaryMessenger.codec.decode(data) as? [Any]
        #expect(outputList != nil)

        let output = outputList!.first as? Int64
        #expect(output == 1)
        #expect(outputList!.count == 1)
        confirmed()
      }
    }
  }

  @Test
  func intPrimitiveFlutter() async throws {
    let binaryMessenger = EchoBinaryMessenger(codec: codec)
    let api = PrimitiveFlutterApi(binaryMessenger: binaryMessenger)

    await confirmation { confirmed in
      api.anInt(value: 1) { result in
        switch result {
        case .success(let res):
          #expect(res == 1)
          confirmed()
        case .failure(let error):
          Issue.record("Failed with error: \(error)")
        }
      }
    }
  }

  @Test
  func boolPrimitiveHost() async throws {
    let binaryMessenger = MockBinaryMessenger<Bool>(codec: codec)
    PrimitiveHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: MockPrimitiveHostApi())
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aBool"
    #expect(binaryMessenger.handlers[channelName] != nil)

    let input = true
    let inputEncoded = binaryMessenger.codec.encode([input])

    await confirmation { confirmed in
      binaryMessenger.handlers[channelName]?(inputEncoded) { data in
        let outputList = binaryMessenger.codec.decode(data) as? [Any]
        #expect(outputList != nil)

        let output = outputList!.first as? Bool
        #expect(output == true)
        #expect(outputList!.count == 1)
        confirmed()
      }
    }
  }

  @Test
  func boolPrimitiveFlutter() async throws {
    let binaryMessenger = EchoBinaryMessenger(codec: codec)
    let api = PrimitiveFlutterApi(binaryMessenger: binaryMessenger)

    await confirmation { confirmed in
      api.aBool(value: true) { result in
        switch result {
        case .success(let res):
          #expect(res == true)
          confirmed()
        case .failure(let error):
          Issue.record("Failed with error: \(error)")
        }
      }
    }
  }

  @Test
  func doublePrimitiveHost() async throws {
    let binaryMessenger = MockBinaryMessenger<Double>(codec: codec)
    PrimitiveHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: MockPrimitiveHostApi())
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aDouble"
    #expect(binaryMessenger.handlers[channelName] != nil)

    let input: Double = 1.0
    let inputEncoded = binaryMessenger.codec.encode([input])

    await confirmation { confirmed in
      binaryMessenger.handlers[channelName]?(inputEncoded) { data in
        let outputList = binaryMessenger.codec.decode(data) as? [Any]
        #expect(outputList != nil)

        let output = outputList!.first as? Double
        #expect(output == 1.0)
        #expect(outputList!.count == 1)
        confirmed()
      }
    }
  }

  @Test
  func doublePrimitiveFlutter() async throws {
    let binaryMessenger = EchoBinaryMessenger(codec: codec)
    let api = PrimitiveFlutterApi(binaryMessenger: binaryMessenger)

    await confirmation { confirmed in
      let arg: Double = 1.5
      api.aDouble(value: arg) { result in
        switch result {
        case .success(let res):
          #expect(res == arg)
          confirmed()
        case .failure(let error):
          Issue.record("Failed with error: \(error)")
        }
      }
    }
  }

  @Test
  func stringPrimitiveHost() async throws {
    let binaryMessenger = MockBinaryMessenger<String>(codec: codec)
    PrimitiveHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: MockPrimitiveHostApi())
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aString"
    #expect(binaryMessenger.handlers[channelName] != nil)

    let input: String = "hello"
    let inputEncoded = binaryMessenger.codec.encode([input])

    await confirmation { confirmed in
      binaryMessenger.handlers[channelName]?(inputEncoded) { data in
        let outputList = binaryMessenger.codec.decode(data) as? [Any]
        #expect(outputList != nil)

        let output = outputList!.first as? String
        #expect(output == "hello")
        #expect(outputList!.count == 1)
        confirmed()
      }
    }
  }

  @Test
  func stringPrimitiveFlutter() async throws {
    let binaryMessenger = EchoBinaryMessenger(codec: codec)
    let api = PrimitiveFlutterApi(binaryMessenger: binaryMessenger)

    await confirmation { confirmed in
      let arg: String = "hello"
      api.aString(value: arg) { result in
        switch result {
        case .success(let res):
          #expect(res == arg)
          confirmed()
        case .failure(let error):
          Issue.record("Failed with error: \(error)")
        }
      }
    }
  }

  @Test
  func listPrimitiveHost() async throws {
    let binaryMessenger = MockBinaryMessenger<[Int]>(codec: codec)
    PrimitiveHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: MockPrimitiveHostApi())
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aList"
    #expect(binaryMessenger.handlers[channelName] != nil)

    let input: [Int] = [1, 2, 3]
    let inputEncoded = binaryMessenger.codec.encode([input])

    await confirmation { confirmed in
      binaryMessenger.handlers[channelName]?(inputEncoded) { data in
        let outputList = binaryMessenger.codec.decode(data) as? [Any]
        #expect(outputList != nil)

        let output = outputList!.first as? [Int]
        #expect(output == [1, 2, 3])
        #expect(outputList!.count == 1)
        confirmed()
      }
    }
  }

  @Test
  func listPrimitiveFlutter() async throws {
    let binaryMessenger = EchoBinaryMessenger(codec: codec)
    let api = PrimitiveFlutterApi(binaryMessenger: binaryMessenger)

    await confirmation { confirmed in
      let arg = ["hello"]
      api.aList(value: arg) { result in
        switch result {
        case .success(let res):
          #expect(equalsList(arg, res))
          confirmed()
        case .failure(let error):
          Issue.record("Failed with error: \(error)")
        }
      }
    }
  }

  @Test
  func mapPrimitiveHost() async throws {
    let binaryMessenger = MockBinaryMessenger<[String: Int]>(codec: codec)
    PrimitiveHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: MockPrimitiveHostApi())
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aMap"
    #expect(binaryMessenger.handlers[channelName] != nil)

    let input: [String: Int] = ["hello": 1, "world": 2]
    let inputEncoded = binaryMessenger.codec.encode([input])

    await confirmation { confirmed in
      binaryMessenger.handlers[channelName]?(inputEncoded) { data in
        let output = binaryMessenger.codec.decode(data) as? [Any]
        #expect(output?.count == 1)

        let outputMap = output?.first as? [String: Int]
        #expect(outputMap != nil)
        #expect(outputMap == ["hello": 1, "world": 2])
        confirmed()
      }
    }
  }

  @Test
  func mapPrimitiveFlutter() async throws {
    let binaryMessenger = EchoBinaryMessenger(codec: codec)
    let api = PrimitiveFlutterApi(binaryMessenger: binaryMessenger)

    await confirmation { confirmed in
      let arg = ["hello": 1]
      api.aMap(value: arg) { result in
        switch result {
        case .success(let res):
          #expect(equalsDictionary(arg, res))
          confirmed()
        case .failure(let error):
          Issue.record("Failed with error: \(error)")
        }
      }
    }
  }
}
