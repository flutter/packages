// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import Flutter
import Testing

@testable import test_plugin

/// Proves `SwiftHostApiOptions(isMainActor: true)` lets a `@MainActor` class
/// implement `HostMainActorApi` directly, with no manual main-thread dispatch.
@MainActor
final class MockHostMainActorApi: HostMainActorApi {
  func isMainThread() async throws -> Bool {
    return Self.isCurrentlyOnMainThread()
  }

  // `Thread.isMainThread` is `noasync`; read it via a sync helper.
  private static func isCurrentlyOnMainThread() -> Bool {
    Thread.isMainThread
  }
}

@MainActor
struct MainActorApiTest {

  @Test
  func mainActorHandlerRunsOnMainThread() async throws {
    let binaryMessenger = MockBinaryMessenger<Bool>(
      codec: FlutterStandardMessageCodec.sharedInstance())
    let mockHostMainActorApi = MockHostMainActorApi()
    HostMainActorApiSetup.setUp(binaryMessenger: binaryMessenger, api: mockHostMainActorApi)
    let channelName = "dev.flutter.pigeon.pigeon_integration_tests.HostMainActorApi.isMainThread"
    #expect(binaryMessenger.handlers[channelName] != nil)

    let data = await withCheckedContinuation { continuation in
      binaryMessenger.handlers[channelName]?(nil) { replyData in
        continuation.resume(returning: replyData)
      }
    }
    let outputList = binaryMessenger.codec.decode(data) as? [Any]
    let output = outputList?.first as? Bool
    #expect(output == true)
  }
}
