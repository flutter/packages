// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Testing

@testable import test_plugin

class MockEnumApi2Host: EnumApi2Host {
  func echo(data: DataWithEnum) -> DataWithEnum {
    return data
  }
}

@MainActor
struct EnumTests {

  @Test
  func echoHost() async throws {
    let binaryMessenger = MockBinaryMessenger<DataWithEnum>(codec: EnumPigeonCodec.shared)
    EnumApi2HostSetup.setUp(binaryMessenger: binaryMessenger, api: MockEnumApi2Host())
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.EnumApi2Host.echo"
    #expect(binaryMessenger.handlers[channelName] != nil)

    let input = DataWithEnum(state: .success)
    let inputEncoded = binaryMessenger.codec.encode([input])

    await confirmation { confirmed in
      binaryMessenger.handlers[channelName]?(inputEncoded) { data in
        let outputMap = binaryMessenger.codec.decode(data) as? [Any]
        #expect(outputMap != nil)

        let output = outputMap?.first as? DataWithEnum
        #expect(output == input)
        #expect(outputMap?.count == 1)
        confirmed()
      }
    }
  }

  @Test
  func echoFlutter() async throws {
    let data = DataWithEnum(state: .error)
    let binaryMessenger = EchoBinaryMessenger(codec: EnumPigeonCodec.shared)
    let api = EnumApi2Flutter(binaryMessenger: binaryMessenger)

    await confirmation { confirmed in
      api.echo(data: data) { result in
        switch result {
        case .success(let res):
          #expect(res.state == data.state)
          confirmed()
        case .failure(let error):
          Issue.record("Error: \(error) from data \(data)")
        }
      }
    }
  }

  // Verifies that generated enums conform to `CaseIterable` and that
  // `allCases` returns every member in declaration order with the
  // expected raw values.
  @Test
  func enumIsCaseIterable() {
    let allCases = AnEnum.allCases
    #expect(allCases == [.one, .two, .three, .fortyTwo, .fourHundredTwentyTwo])
    #expect(allCases.count == 5)
    #expect(allCases.map { $0.rawValue } == [0, 1, 2, 3, 4])

    // Single-member enums should also conform and report a single case.
    #expect(AnotherEnum.allCases == [.justInCase])
  }

}
