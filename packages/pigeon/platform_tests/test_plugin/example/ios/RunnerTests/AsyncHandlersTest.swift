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

  @Test
  func hostStreamFiniteAsyncThrowingStreamAndUnknownAction() async throws {
    let codec = EventChannelTestsPigeonCodec.shared
    let messenger = StreamRecordingBinaryMessenger(codec: codec)
    let api = MockStreamHostTestApi()
    StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: api)
    defer { StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: nil) }

    // 1. Finite AsyncThrowingStream emits data + done frames.
    let finiteReply = await sendStreamControl(
      messenger,
      codec: codec,
      channel: Self.streamNumbersChannel,
      args: ["listen", Int64(1), Int64(2), Int64(10)])
    #expect(finiteReply?.count == 1)
    await messenger.waitForFrames(count: 3)
    let finiteFrames = messenger.sentFrames.map(\.1)
    try #require(finiteFrames.count == 3)
    #expect(finiteFrames[0][0] as? Int64 == 1)
    #expect(finiteFrames[0][1] as? Int64 == 0)
    #expect(finiteFrames[0][2] as? Int64 == 10)
    #expect(finiteFrames[1][2] as? Int64 == 11)
    #expect(finiteFrames[2][1] as? Int64 == 2)

    // 2. Unknown control action replies with an invalid-action error instead of spawning a stream.
    let unknownReply = await sendStreamControl(
      messenger,
      codec: codec,
      channel: Self.streamNumbersChannel,
      args: ["bogus", Int64(99)])
    try #require(unknownReply?.count == 3)
    #expect(unknownReply?[0] as? String == "invalid-action")
  }

  @Test
  func hostStreamMultiEngineIsolationSupersedeAndExplicitCancel() async throws {
    let codec = EventChannelTestsPigeonCodec.shared
    let messengerA = StreamRecordingBinaryMessenger(codec: codec)
    let messengerB = StreamRecordingBinaryMessenger(codec: codec)
    let apiA = MockStreamHostTestApi()
    let apiB = MockStreamHostTestApi()

    StreamHostTestApiSetup.setUp(binaryMessenger: messengerA, api: apiA)
    StreamHostTestApiSetup.setUp(binaryMessenger: messengerB, api: apiB)
    defer {
      StreamHostTestApiSetup.setUp(binaryMessenger: messengerA, api: nil)
      StreamHostTestApiSetup.setUp(binaryMessenger: messengerB, api: nil)
    }

    let cancelledA = StreamCancelSignal()
    let cancelledB = StreamCancelSignal()
    apiA.onNumbersCancelled = { cancelledA.signal() }
    apiB.onNumbersCancelled = { cancelledB.signal() }

    await sendStreamControl(
      messengerA,
      codec: codec,
      channel: Self.streamNumbersChannel,
      args: ["listen", Int64(0), Int64(99), Int64(1)])
    await sendStreamControl(
      messengerB,
      codec: codec,
      channel: Self.streamNumbersChannel,
      args: ["listen", Int64(0), Int64(99), Int64(2)])
    await messengerA.waitForFrames(count: 1)
    await messengerB.waitForFrames(count: 1)
    #expect(!cancelledA.isSignaled)
    #expect(!cancelledB.isSignaled)

    // Tearing down messengerB cancels B without affecting messengerA.
    StreamHostTestApiSetup.setUp(binaryMessenger: messengerB, api: nil)
    await cancelledB.wait()
    #expect(cancelledB.isSignaled)
    #expect(!cancelledA.isSignaled)

    // Superseding subscriptionId = 0 cancels old stream without removing replacement registration.
    let replacedCancelledA = StreamCancelSignal()
    apiA.onNumbersCancelled = { replacedCancelledA.signal() }
    await sendStreamControl(
      messengerA,
      codec: codec,
      channel: Self.streamNumbersChannel,
      args: ["listen", Int64(0), Int64(99), Int64(1)])
    await cancelledA.wait()
    #expect(cancelledA.isSignaled)
    #expect(!replacedCancelledA.isSignaled)

    // Explicit "cancel" control message cancels the replacement stream.
    await sendStreamControl(
      messengerA,
      codec: codec,
      channel: Self.streamNumbersChannel,
      args: ["cancel", Int64(0)])
    await replacedCancelledA.wait()
    #expect(replacedCancelledA.isSignaled)
  }

  @Test
  func hostStreamErrorAndHostCancellationError() async throws {
    let codec = EventChannelTestsPigeonCodec.shared
    let messenger = StreamRecordingBinaryMessenger(codec: codec)
    let api = MockStreamHostTestApi()
    StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: api)
    defer { StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: nil) }

    // 1. Custom EventChannelTestsError from AsyncThrowingStream wraps code/message/details.
    await sendStreamControl(
      messenger,
      codec: codec,
      channel: Self.streamErrorChannel,
      args: ["listen", Int64(4), true])
    await messenger.waitForFrames(count: 1)
    let errFrames = messenger.sentFrames.map(\.1)
    try #require(errFrames.count == 1)
    #expect(errFrames[0][0] as? Int64 == 4)
    #expect(errFrames[0][1] as? Int64 == 1)
    #expect(errFrames[0][2] as? String == "e")
    #expect(errFrames[0][3] as? String == "m")
    #expect(errFrames[0][4] as? String == "d")

    // 2. Host-thrown CancellationError propagates an error frame instead of hanging Dart.
    messenger.clearFrames()
    api.throwCancellationError = true
    await sendStreamControl(
      messenger,
      codec: codec,
      channel: Self.streamNumbersChannel,
      args: ["listen", Int64(5), Int64(1), Int64(0)])
    await messenger.waitForFrames(count: 1)
    let cancelErrFrames = messenger.sentFrames.map(\.1)
    try #require(cancelErrFrames.count == 1)
    #expect(cancelErrFrames[0][0] as? Int64 == 5)
    #expect(cancelErrFrames[0][1] as? Int64 == 1)
  }

  @Test
  func hostStreamCallbackSinkTerminalExplicitCancelAndTeardown() async throws {
    let codec = EventChannelTestsPigeonCodec.shared
    let messenger = StreamRecordingBinaryMessenger(codec: codec)
    let api = MockStreamHostTestApi()
    StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: api)
    defer { StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: nil) }

    // 1. success + error terminates sink and ignores subsequent calls.
    await sendStreamControl(
      messenger,
      codec: codec,
      channel: Self.streamCallbackChannel,
      args: ["listen", Int64(6), "cb", Int64(1)])
    let errorSink = try #require(api.capturedSink)
    errorSink.success("first")
    errorSink.error(code: "err_code", message: "err_msg", details: "err_det")
    errorSink.success("ignored")
    errorSink.endOfStream()
    let cbErrFrames = messenger.sentFrames.map(\.1)
    try #require(cbErrFrames.count == 2)
    #expect(cbErrFrames[0][2] as? String == "first")
    #expect(cbErrFrames[1][1] as? Int64 == 1)
    #expect(cbErrFrames[1][2] as? String == "err_code")

    // 2. endOfStream terminates sink and ignores subsequent calls.
    messenger.clearFrames()
    await sendStreamControl(
      messenger,
      codec: codec,
      channel: Self.streamCallbackChannel,
      args: ["listen", Int64(8), "cb", Int64(1)])
    let doneSink = try #require(api.capturedSink)
    doneSink.endOfStream()
    doneSink.success("ignored-after-done")
    let cbDoneFrames = messenger.sentFrames.map(\.1)
    try #require(cbDoneFrames.count == 1)
    #expect(cbDoneFrames[0][0] as? Int64 == 8)
    #expect(cbDoneFrames[0][1] as? Int64 == 2)

    // 3. Synchronous endOfStream() inside streamViaCallback does NOT fire cancel closure.
    messenger.clearFrames()
    let syncDoneCancelled = StreamCancelSignal()
    api.onCallbackCancelled = { syncDoneCancelled.signal() }
    await sendStreamControl(
      messenger,
      codec: codec,
      channel: Self.streamCallbackChannel,
      args: ["listen", Int64(9), "sync-done", Int64(1)])
    let syncDoneFrames = messenger.sentFrames.map(\.1)
    try #require(syncDoneFrames.count == 1)
    #expect(syncDoneFrames[0][0] as? Int64 == 9)
    #expect(syncDoneFrames[0][1] as? Int64 == 2)
    #expect(!syncDoneCancelled.isSignaled)

    // 4. Explicit "cancel" control message on callbackChannel invokes cancel closure.
    messenger.clearFrames()
    let explicitCancelled = StreamCancelSignal()
    api.onCallbackCancelled = { explicitCancelled.signal() }
    await sendStreamControl(
      messenger,
      codec: codec,
      channel: Self.streamCallbackChannel,
      args: ["listen", Int64(10), "cb", Int64(1)])
    let explicitCancelSink = try #require(api.capturedSink)
    await sendStreamControl(
      messenger,
      codec: codec,
      channel: Self.streamCallbackChannel,
      args: ["cancel", Int64(10)])
    #expect(explicitCancelled.isSignaled)
    explicitCancelSink.success("ignored-after-cancel")
    #expect(messenger.sentFrames.isEmpty)

    // 5. Teardown via setUp(..., api: nil) invokes cancel closure and closes sink.
    messenger.clearFrames()
    let teardownCancelled = StreamCancelSignal()
    api.onCallbackCancelled = { teardownCancelled.signal() }
    await sendStreamControl(
      messenger,
      codec: codec,
      channel: Self.streamCallbackChannel,
      args: ["listen", Int64(7), "cb", Int64(1)])
    let teardownSink = try #require(api.capturedSink)
    StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: nil)
    #expect(teardownCancelled.isSignaled)
    teardownSink.success("ignored-after-teardown")
    #expect(messenger.sentFrames.isEmpty)
  }

  private static let streamNumbersChannel =
    "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamNumbers"
  private static let streamErrorChannel =
    "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamError"
  private static let streamCallbackChannel =
    "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamViaCallback"
}

private final class StreamRecordingBinaryMessenger: NSObject, FlutterBinaryMessenger,
  @unchecked Sendable
{
  let codec: FlutterMessageCodec
  private(set) var handlers: [String: FlutterBinaryMessageHandler] = [:]
  private let lock = NSLock()
  private var _sentFrames: [(String, [Any?])] = []
  private var waiters: [(Int, CheckedContinuation<Void, Never>)] = []

  var sentFrames: [(String, [Any?])] {
    lock.lock()
    defer { lock.unlock() }
    return _sentFrames
  }

  func clearFrames() {
    lock.lock()
    _sentFrames.removeAll()
    lock.unlock()
  }

  func waitForFrames(count: Int) async {
    await withCheckedContinuation { continuation in
      var ready = false
      lock.lock()
      if _sentFrames.count >= count {
        ready = true
      } else {
        waiters.append((count, continuation))
      }
      lock.unlock()
      if ready {
        continuation.resume()
      }
    }
  }

  init(codec: FlutterMessageCodec) {
    self.codec = codec
    super.init()
  }

  func send(onChannel channel: String, message: Data?) {
    let decoded = codec.decode(message) as? [Any?] ?? []
    var toResume: [CheckedContinuation<Void, Never>] = []
    lock.lock()
    _sentFrames.append((channel, decoded))
    let currentCount = _sentFrames.count
    var remaining: [(Int, CheckedContinuation<Void, Never>)] = []
    for waiter in waiters {
      if currentCount >= waiter.0 {
        toResume.append(waiter.1)
      } else {
        remaining.append(waiter)
      }
    }
    waiters = remaining
    lock.unlock()
    for continuation in toResume {
      continuation.resume()
    }
  }

  func send(
    onChannel channel: String,
    message: Data?,
    binaryReply callback: FlutterBinaryReply? = nil
  ) {
    send(onChannel: channel, message: message)
    callback?(nil)
  }

  func setMessageHandlerOnChannel(
    _ channel: String,
    binaryMessageHandler handler: FlutterBinaryMessageHandler? = nil
  ) -> FlutterBinaryMessengerConnection {
    handlers[channel] = handler
    return .init(handlers.count)
  }

  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}
}

private final class StreamCancelSignal: @unchecked Sendable {
  private let lock = NSLock()
  private var _signaled = false
  private var waiters: [CheckedContinuation<Void, Never>] = []

  var isSignaled: Bool {
    lock.lock()
    defer { lock.unlock() }
    return _signaled
  }

  func signal() {
    var toResume: [CheckedContinuation<Void, Never>] = []
    lock.lock()
    _signaled = true
    toResume = waiters
    waiters.removeAll()
    lock.unlock()
    for continuation in toResume {
      continuation.resume()
    }
  }

  func wait() async {
    await withCheckedContinuation { continuation in
      var alreadySignaled = false
      lock.lock()
      if _signaled {
        alreadySignaled = true
      } else {
        waiters.append(continuation)
      }
      lock.unlock()
      if alreadySignaled {
        continuation.resume()
      }
    }
  }
}

private final class MockStreamHostTestApi: StreamHostTestApi, @unchecked Sendable {
  var onNumbersCancelled: (@Sendable () -> Void)?
  var throwCancellationError = false
  var capturedSink: EventChannelTestsPigeonEventSink<String>?
  var onCallbackCancelled: (@Sendable () -> Void)?

  func streamNumbers(count: Int64, start: Int64) -> AsyncThrowingStream<Int64, Error> {
    if throwCancellationError {
      return AsyncThrowingStream { continuation in
        continuation.finish(throwing: CancellationError())
      }
    }
    if count == 2 {
      return AsyncThrowingStream { continuation in
        continuation.yield(start)
        continuation.yield(start + 1)
        continuation.finish()
      }
    }
    let cancelHook = onNumbersCancelled
    return AsyncThrowingStream { continuation in
      continuation.yield(start)
      continuation.onTermination = { termination in
        if case .cancelled = termination {
          cancelHook?()
        }
      }
    }
  }

  func streamPlatformEvents() -> AsyncThrowingStream<PlatformEvent, Error> {
    AsyncThrowingStream { $0.finish() }
  }

  func streamNullableInts() -> AsyncThrowingStream<Int64?, Error> {
    AsyncThrowingStream { $0.finish() }
  }

  func streamError(customError: Bool) -> AsyncThrowingStream<Int64, Error> {
    AsyncThrowingStream { continuation in
      continuation.finish(
        throwing: EventChannelTestsError(code: "e", message: "m", details: "d"))
    }
  }

  func streamViaCallback(
    prefix: String,
    count: Int64,
    sink: EventChannelTestsPigeonEventSink<String>
  ) -> (() -> Void)? {
    capturedSink = sink
    if prefix == "sync-done" {
      sink.endOfStream()
    }
    let cancelHook = onCallbackCancelled
    return { cancelHook?() }
  }

  func getCancelledStreamCount() throws -> Int64 { 0 }
  func resetCancelledStreamCount() throws {}
}

@MainActor
@discardableResult
private func sendStreamControl(
  _ messenger: StreamRecordingBinaryMessenger,
  codec: FlutterMessageCodec,
  channel: String,
  args: [Any?]
) async -> [Any?]? {
  let encoded = codec.encode(args)
  let replyData: Data? = await withCheckedContinuation {
    (continuation: CheckedContinuation<Data?, Never>) in
    messenger.handlers[channel]?(encoded) { data in
      continuation.resume(returning: data)
    }
  }
  return replyData.flatMap { codec.decode($0) as? [Any?] }
}
