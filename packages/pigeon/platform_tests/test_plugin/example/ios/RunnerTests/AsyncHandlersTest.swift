// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import Flutter
import Testing

@testable import test_plugin

class MockHostSmallApi: HostSmallApi {
  var output: String?

  func echo(aString: String) async throws -> String {
    return output!
  }

  func voidVoid() async throws {}
}

@MainActor
struct AsyncHandlersTest {

  @Test
  func asyncHost2Flutter() async throws {
    let value = "Test"
    let binaryMessenger = MockBinaryMessenger<String>(codec: CoreTestsPigeonCodec.shared)
    binaryMessenger.result = value
    let flutterApi = FlutterIntegrationCoreApi(binaryMessenger: binaryMessenger)

    let res = try await flutterApi.echo(value)
    #expect(res == value)
  }

  @Test
  func asyncFlutter2HostVoidVoid() async throws {
    let binaryMessenger = MockBinaryMessenger<String>(
      codec: FlutterStandardMessageCodec.sharedInstance())
    let mockHostSmallApi = MockHostSmallApi()
    HostSmallApiSetup.setUp(binaryMessenger: binaryMessenger, api: mockHostSmallApi)
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.HostSmallApi.voidVoid"
    #expect(binaryMessenger.handlers[channelName] != nil)

    let data = await withCheckedContinuation { continuation in
      binaryMessenger.handlers[channelName]?(nil) { replyData in
        continuation.resume(returning: replyData)
      }
    }
    let outputList = binaryMessenger.codec.decode(data) as? [Any]
    #expect(outputList?.first is NSNull)
  }

  @Test
  func asyncFlutter2Host() async throws {
    let binaryMessenger = MockBinaryMessenger<String>(
      codec: FlutterStandardMessageCodec.sharedInstance())
    let mockHostSmallApi = MockHostSmallApi()
    let value = "Test"
    mockHostSmallApi.output = value
    HostSmallApiSetup.setUp(binaryMessenger: binaryMessenger, api: mockHostSmallApi)
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.HostSmallApi.echo"
    #expect(binaryMessenger.handlers[channelName] != nil)

    let inputEncoded = binaryMessenger.codec.encode([value])

    let data = await withCheckedContinuation { continuation in
      binaryMessenger.handlers[channelName]?(inputEncoded) { replyData in
        continuation.resume(returning: replyData)
      }
    }
    let outputList = binaryMessenger.codec.decode(data) as? [Any]
    let output = outputList?.first as? String
    #expect(output == value)
  }
}
