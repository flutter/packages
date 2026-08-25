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
  let codec = FlutterStandardMessageCodec.sharedInstance()

  @Test
  func nullableParameterWithFlutterApi() async throws {
    let binaryMessenger = EchoBinaryMessenger(codec: codec)
    binaryMessenger.defaultReturn = 99
    let api = NullableArgFlutterApi(binaryMessenger: binaryMessenger)

    let res = try await api.doit(x: nil)
    #expect(res == 99)
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

/// Regression test for https://github.com/flutter/flutter/issues/191254.
///
/// `FlutterStandardReader` substitutes `NSNull` for a `nil` element of a list,
/// so a null reply for a non-null return value arrives as `NSNull` rather than
/// as `nil`. Before the fix that value was force-cast to the return type, which
/// aborted the process instead of reporting an error.
@MainActor
struct NullReplyForNonNullReturnTests {
  let codec = FlutterStandardMessageCodec.sharedInstance()

  @Test
  func nullReplyForNonNullReturnFailsWithoutCrashing() async throws {
    let binaryMessenger = MockBinaryMessenger<NSNull>(codec: codec)
    binaryMessenger.result = NSNull()
    let api = FlutterIntegrationCoreApi(binaryMessenger: binaryMessenger)

    do {
      // `sendMultipleNullableTypes` has a non-null return value.
      _ = try await api.sendMultipleNullableTypes(aBool: nil, anInt: nil, aString: nil)
      Issue.record("Expected a null-error but the call succeeded.")
    } catch let error as PigeonError {
      #expect(error.code == "null-error")
    }
  }
}
