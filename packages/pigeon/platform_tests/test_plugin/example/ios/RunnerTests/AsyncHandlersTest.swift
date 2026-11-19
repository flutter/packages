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
  func hostStreamAsyncThrowingStreamCallbackCancelAndMultiEngine() async throws {
    final class RecordingBinaryMessenger: NSObject, FlutterBinaryMessenger, @unchecked Sendable {
      let codec: FlutterMessageCodec
      private(set) var handlers: [String: FlutterBinaryMessageHandler] = [:]
      private let lock = NSLock()
      private var _sentFrames: [(String, [Any?])] = []

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

      init(codec: FlutterMessageCodec) {
        self.codec = codec
        super.init()
      }

      func send(onChannel channel: String, message: Data?) {
        let decoded = codec.decode(message) as? [Any?] ?? []
        lock.lock()
        _sentFrames.append((channel, decoded))
        lock.unlock()
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

    final class AtomicFlag: @unchecked Sendable {
      private let lock = NSLock()
      private var _value = false
      var value: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _value
      }
      func set() {
        lock.lock()
        _value = true
        lock.unlock()
      }
    }

    final class MockStreamHostTestApi: StreamHostTestApi, @unchecked Sendable {
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
        let cancelHook = onCallbackCancelled
        return { cancelHook?() }
      }

      func getCancelledStreamCount() throws -> Int64 { 0 }
      func resetCancelledStreamCount() throws {}
    }

    let codec = EventChannelTestsPigeonCodec.shared
    let messengerA = RecordingBinaryMessenger(codec: codec)
    let messengerB = RecordingBinaryMessenger(codec: codec)
    let apiA = MockStreamHostTestApi()
    let apiB = MockStreamHostTestApi()

    let numbersChannel =
      "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamNumbers"
    let callbackChannel =
      "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamViaCallback"

    @discardableResult
    func sendControl(_ messenger: RecordingBinaryMessenger, channel: String, args: [Any?]) async
      -> [Any?]?
    {
      let encoded = codec.encode(args)
      let replyData: Data? = await withCheckedContinuation {
        (continuation: CheckedContinuation<Data?, Never>) in
        messenger.handlers[channel]?(encoded) { data in
          continuation.resume(returning: data)
        }
      }
      return replyData.flatMap { codec.decode($0) as? [Any?] }
    }

    StreamHostTestApiSetup.setUp(binaryMessenger: messengerA, api: apiA)
    StreamHostTestApiSetup.setUp(binaryMessenger: messengerB, api: apiB)

    // 1. Finite AsyncThrowingStream emits data + done frames.
    let finiteReply = await sendControl(
      messengerA, channel: numbersChannel, args: ["listen", Int64(1), Int64(2), Int64(10)])
    #expect(finiteReply?.count == 1)
    try await Task.sleep(nanoseconds: 50_000_000)
    let finiteFrames = messengerA.sentFrames.map(\.1)
    #expect(finiteFrames.count == 3)
    #expect(finiteFrames[0][0] as? Int64 == 1)
    #expect(finiteFrames[0][1] as? Int64 == 0)
    #expect(finiteFrames[0][2] as? Int64 == 10)
    #expect(finiteFrames[1][2] as? Int64 == 11)
    #expect(finiteFrames[2][1] as? Int64 == 2)

    // Unknown control action replies with an error instead of spawning a stream.
    let unknownReply = await sendControl(
      messengerA, channel: numbersChannel, args: ["bogus", Int64(99)])
    #expect(unknownReply?.count == 3)

    // 2. Multi-engine isolation: both subscribe with subscriptionId = 0; tearing down B does not cancel A.
    messengerA.clearFrames()
    messengerB.clearFrames()
    let cancelledA = AtomicFlag()
    let cancelledB = AtomicFlag()
    apiA.onNumbersCancelled = { cancelledA.set() }
    apiB.onNumbersCancelled = { cancelledB.set() }

    await sendControl(
      messengerA, channel: numbersChannel, args: ["listen", Int64(0), Int64(99), Int64(1)])
    await sendControl(
      messengerB, channel: numbersChannel, args: ["listen", Int64(0), Int64(99), Int64(2)])
    try await Task.sleep(nanoseconds: 50_000_000)
    #expect(!cancelledA.value)
    #expect(!cancelledB.value)

    StreamHostTestApiSetup.setUp(binaryMessenger: messengerB, api: nil)
    try await Task.sleep(nanoseconds: 50_000_000)
    #expect(cancelledB.value)
    #expect(!cancelledA.value)

    // 3. Superseding subscriptionId = 0 cancels old stream without removing replacement registration.
    let replacedCancelledA = AtomicFlag()
    apiA.onNumbersCancelled = { replacedCancelledA.set() }
    await sendControl(
      messengerA, channel: numbersChannel, args: ["listen", Int64(0), Int64(99), Int64(1)])
    try await Task.sleep(nanoseconds: 50_000_000)
    #expect(cancelledA.value)
    #expect(!replacedCancelledA.value)

    // Explicit "cancel" control message cancels the replacement stream.
    await sendControl(messengerA, channel: numbersChannel, args: ["cancel", Int64(0)])
    try await Task.sleep(nanoseconds: 50_000_000)
    #expect(replacedCancelledA.value)

    // 4. Host-thrown CancellationError propagates an error frame instead of hanging Dart.
    messengerA.clearFrames()
    apiA.throwCancellationError = true
    await sendControl(
      messengerA, channel: numbersChannel, args: ["listen", Int64(5), Int64(1), Int64(0)])
    try await Task.sleep(nanoseconds: 50_000_000)
    let cancelErrFrames = messengerA.sentFrames.map(\.1)
    #expect(cancelErrFrames.count == 1)
    #expect(cancelErrFrames[0][0] as? Int64 == 5)
    #expect(cancelErrFrames[0][1] as? Int64 == 1)
    apiA.throwCancellationError = false

    // 5. @asyncCallback PigeonEventSink: success, error, endOfStream, post-termination no-op, and teardown cancel.
    messengerA.clearFrames()
    await sendControl(
      messengerA, channel: callbackChannel, args: ["listen", Int64(6), "cb", Int64(1)])
    let errorSink = try #require(apiA.capturedSink)
    errorSink.success("first")
    errorSink.error(code: "err_code", message: "err_msg", details: "err_det")
    errorSink.success("ignored")
    errorSink.endOfStream()
    let cbErrFrames = messengerA.sentFrames.map(\.1)
    #expect(cbErrFrames.count == 2)
    #expect(cbErrFrames[0][2] as? String == "first")
    #expect(cbErrFrames[1][1] as? Int64 == 1)
    #expect(cbErrFrames[1][2] as? String == "err_code")

    messengerA.clearFrames()
    await sendControl(
      messengerA, channel: callbackChannel, args: ["listen", Int64(8), "cb", Int64(1)])
    let doneSink = try #require(apiA.capturedSink)
    doneSink.endOfStream()
    doneSink.success("ignored-after-done")
    let cbDoneFrames = messengerA.sentFrames.map(\.1)
    #expect(cbDoneFrames.count == 1)
    #expect(cbDoneFrames[0][0] as? Int64 == 8)
    #expect(cbDoneFrames[0][1] as? Int64 == 2)

    messengerA.clearFrames()
    let callbackCancelled = AtomicFlag()
    apiA.onCallbackCancelled = { callbackCancelled.set() }
    await sendControl(
      messengerA, channel: callbackChannel, args: ["listen", Int64(7), "cb", Int64(1)])
    let teardownSink = try #require(apiA.capturedSink)
    StreamHostTestApiSetup.setUp(binaryMessenger: messengerA, api: nil)
    #expect(callbackCancelled.value)
    teardownSink.success("ignored-after-teardown")
    #expect(messengerA.sentFrames.isEmpty)
  }
}
