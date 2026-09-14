// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  @preconcurrency import Flutter
#elseif os(macOS)
  @preconcurrency import FlutterMacOS
#endif

/// Plugin class for swift_concurrency_test_plugin.
public class SwiftConcurrencyTestPlugin: NSObject, @preconcurrency FlutterPlugin {
  @MainActor
  public static func register(with registrar: FlutterPluginRegistrar) {
    #if os(iOS)
      let messenger = registrar.messenger()
    #else
      let messenger = registrar.messenger
    #endif

    let hostApi = SmokeTestHostApi()
    HostTrivialApiSetup.setUp(binaryMessenger: messenger, api: hostApi)
    HostSmallApiSetup.setUp(binaryMessenger: messenger, api: hostApi)
    StreamIntsStreamHandler.register(with: messenger, streamHandler: SmokeStreamHandler())
  }
}

/// Smoke test host API implementation verifying @MainActor isolation and async methods.
@MainActor
final class SmokeTestHostApi: HostTrivialApi, HostSmallApi {
  func noop() throws {}

  func echo(aString: String) async throws -> String {
    return aString
  }

  func voidVoid() async throws {}
}

/// Smoke test event channel stream handler verifying @MainActor isolation.
@MainActor
final class SmokeStreamHandler: StreamIntsStreamHandler {
  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<Int64>) {
    sink.success(42)
  }

  override func onCancel(withArguments arguments: Any?) {}
}

/// Smoke test calling Flutter API methods.
@MainActor
func testFlutterApiCall(binaryMessenger: FlutterBinaryMessenger) async throws -> String {
  let api = FlutterSmallApi(binaryMessenger: binaryMessenger)
  return try await api.echo(string: "test")
}
