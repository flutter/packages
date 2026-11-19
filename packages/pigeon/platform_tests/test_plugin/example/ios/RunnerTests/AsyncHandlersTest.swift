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
  func hostStreamFiniteAsyncThrowingStream() async throws {
    let codec = EventChannelTestsPigeonCodec.shared
    let messenger = StreamRecordingBinaryMessenger(codec: codec)
    let api = MockStreamHostTestApi()
    StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: api)
    defer { StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: nil) }

    let finiteReply = try await sendStreamControl(
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
  }

  @Test
  func hostStreamUnknownControlActionReturnsInvalidActionError() async throws {
    let codec = EventChannelTestsPigeonCodec.shared
    let messenger = StreamRecordingBinaryMessenger(codec: codec)
    let api = MockStreamHostTestApi()
    StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: api)
    defer { StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: nil) }

    let unknownReply = try await sendStreamControl(
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

    try await sendStreamControl(
      messengerA,
      codec: codec,
      channel: Self.streamNumbersChannel,
      args: ["listen", Int64(0), Int64(99), Int64(1)])
    try await sendStreamControl(
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
    try await sendStreamControl(
      messengerA,
      codec: codec,
      channel: Self.streamNumbersChannel,
      args: ["listen", Int64(0), Int64(99), Int64(1)])
    await cancelledA.wait()
    #expect(cancelledA.isSignaled)
    #expect(!replacedCancelledA.isSignaled)

    // Explicit "cancel" control message cancels the replacement stream.
    try await sendStreamControl(
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
    try await sendStreamControl(
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
    try await sendStreamControl(
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
  func hostStreamCallbackSinkErrorTerminatesAndIgnoresSubsequentCalls() async throws {
    let codec = EventChannelTestsPigeonCodec.shared
    let messenger = StreamRecordingBinaryMessenger(codec: codec)
    let api = MockStreamHostTestApi()
    StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: api)
    defer { StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: nil) }

    try await sendStreamControl(
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
  }

  @Test
  func hostStreamCallbackSinkEndOfStreamTerminatesAndIgnoresSubsequentCalls() async throws {
    let codec = EventChannelTestsPigeonCodec.shared
    let messenger = StreamRecordingBinaryMessenger(codec: codec)
    let api = MockStreamHostTestApi()
    StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: api)
    defer { StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: nil) }

    try await sendStreamControl(
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
  }

  @Test
  func hostStreamCallbackSyncEndOfStreamDoesNotInvokeCancel() async throws {
    let codec = EventChannelTestsPigeonCodec.shared
    let messenger = StreamRecordingBinaryMessenger(codec: codec)
    let api = MockStreamHostTestApi()
    StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: api)

    let syncDoneCancelled = StreamCancelSignal()
    api.onCallbackCancelled = { syncDoneCancelled.signal() }
    try await sendStreamControl(
      messenger,
      codec: codec,
      channel: Self.streamCallbackChannel,
      args: ["listen", Int64(9), "sync-done", Int64(1)])
    let syncDoneFrames = messenger.sentFrames.map(\.1)
    try #require(syncDoneFrames.count == 1)
    #expect(syncDoneFrames[0][0] as? Int64 == 9)
    #expect(syncDoneFrames[0][1] as? Int64 == 2)
    #expect(!syncDoneCancelled.isSignaled)

    // Teardown must also not fire cancel, verifying synchronous endOfStream() cleared registration.
    StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: nil)
    #expect(!syncDoneCancelled.isSignaled)
  }

  @Test
  func hostStreamCallbackCancelBeforeAttachInvokesCancelImmediately() async throws {
    let codec = EventChannelTestsPigeonCodec.shared
    let messenger = StreamRecordingBinaryMessenger(codec: codec)
    let api = MockStreamHostTestApi()
    StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: api)
    defer { StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: nil) }

    let cancelled = StreamCancelSignal()
    api.onCallbackCancelled = { cancelled.signal() }
    api.onCallbackListen = {
      let cancelEncoded = codec.encode(["cancel", Int64(11)])
      messenger.handlers[Self.streamCallbackChannel]?(cancelEncoded) { _ in }
    }
    try await sendStreamControl(
      messenger,
      codec: codec,
      channel: Self.streamCallbackChannel,
      args: ["listen", Int64(11), "cb", Int64(1)])
    #expect(cancelled.isSignaled)
  }

  @Test
  func hostStreamCallbackExplicitCancelInvokesCancelAndIgnoresSubsequentCalls() async throws {
    let codec = EventChannelTestsPigeonCodec.shared
    let messenger = StreamRecordingBinaryMessenger(codec: codec)
    let api = MockStreamHostTestApi()
    StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: api)
    defer { StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: nil) }

    let explicitCancelled = StreamCancelSignal()
    api.onCallbackCancelled = { explicitCancelled.signal() }
    try await sendStreamControl(
      messenger,
      codec: codec,
      channel: Self.streamCallbackChannel,
      args: ["listen", Int64(10), "cb", Int64(1)])
    let explicitCancelSink = try #require(api.capturedSink)
    try await sendStreamControl(
      messenger,
      codec: codec,
      channel: Self.streamCallbackChannel,
      args: ["cancel", Int64(10)])
    #expect(explicitCancelled.isSignaled)
    explicitCancelSink.success("ignored-after-cancel")
    #expect(messenger.sentFrames.isEmpty)
  }

  @Test
  func hostStreamCallbackTeardownInvokesCancelAndClosesSink() async throws {
    let codec = EventChannelTestsPigeonCodec.shared
    let messenger = StreamRecordingBinaryMessenger(codec: codec)
    let api = MockStreamHostTestApi()
    StreamHostTestApiSetup.setUp(binaryMessenger: messenger, api: api)

    let teardownCancelled = StreamCancelSignal()
    api.onCallbackCancelled = { teardownCancelled.signal() }
    try await sendStreamControl(
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

  @Test
  func ffiHostStreamUnregisterCancelsActiveAsyncAndCallbackStreams() async throws {
    let api = MockNativeInteropStreamHostApi()
    let registrar = MockFfiStreamPluginRegistrar()
    let instanceName = "test-ffi-unregister-cancels"
    NativeInteropStreamHostApiSetup.register(api: api, registrar: registrar, name: instanceName)
    let setup = try #require(
      NativeInteropStreamHostApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min, name: instanceName))

    let asyncCancelled = StreamCancelSignal()
    let callbackCancelled = StreamCancelSignal()
    let firstValueReceived = StreamCancelSignal()
    api.onNumbersCancelled = { asyncCancelled.signal() }
    api.onCallbackCancelled = { callbackCancelled.signal() }

    let asyncError = NativeInteropTestsError(code: "", message: nil, details: nil)
    let asyncHandle = setup.streamNumbers(
      count: 99,
      start: 1,
      pigeonOnData: { _ in firstValueReceived.signal() },
      pigeonOnError: { _, _, _ in },
      pigeonOnDone: {},
      wrappedError: asyncError)
    #expect(asyncHandle != nil)
    await firstValueReceived.wait()

    let cbError = NativeInteropTestsError(code: "", message: nil, details: nil)
    let cbHandle = setup.streamViaCallback(
      prefix: "cb",
      count: 1,
      pigeonOnData: { _ in },
      pigeonOnError: { _, _, _ in },
      pigeonOnDone: {},
      wrappedError: cbError)
    #expect(cbHandle != nil)

    NativeInteropStreamHostApiSetup.unregister(api: api, registrar: registrar, name: instanceName)
    await asyncCancelled.wait()
    await callbackCancelled.wait()
    #expect(asyncCancelled.isSignaled)
    #expect(callbackCancelled.isSignaled)
  }

  @Test
  func ffiHostStreamOnUnregisteredSetupPopulatesUnregisteredInstanceError() async throws {
    let api = MockNativeInteropStreamHostApi()
    let registrar = MockFfiStreamPluginRegistrar()
    let instanceName = "test-ffi-unregistered-error"
    NativeInteropStreamHostApiSetup.register(api: api, registrar: registrar, name: instanceName)
    let setup = try #require(
      NativeInteropStreamHostApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min, name: instanceName))
    NativeInteropStreamHostApiSetup.unregister(api: api, registrar: registrar, name: instanceName)

    let error = NativeInteropTestsError(code: "", message: nil, details: nil)
    let handle = setup.streamNumbers(
      count: 1,
      start: 0,
      pigeonOnData: { _ in },
      pigeonOnError: { _, _, _ in },
      pigeonOnDone: {},
      wrappedError: error)
    #expect(handle == nil)
    #expect(error.code == "unregistered-instance")
  }

  @Test
  func ffiCallbackSinkErrorIsIdempotent() async throws {
    let api = MockNativeInteropStreamHostApi()
    let registrar = MockFfiStreamPluginRegistrar()
    let instanceName = "test-ffi-sink-error-idempotency"
    NativeInteropStreamHostApiSetup.register(api: api, registrar: registrar, name: instanceName)
    defer {
      NativeInteropStreamHostApiSetup.unregister(api: api, registrar: registrar, name: instanceName)
    }
    let setup = try #require(
      NativeInteropStreamHostApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min, name: instanceName))

    var errorCodes: [String] = []
    var dataCount = 0
    var doneCount = 0
    let error = NativeInteropTestsError(code: "", message: nil, details: nil)
    let handle = setup.streamViaCallback(
      prefix: "cb",
      count: 1,
      pigeonOnData: { _ in dataCount += 1 },
      pigeonOnError: { code, _, _ in errorCodes.append(code) },
      pigeonOnDone: { doneCount += 1 },
      wrappedError: error)
    #expect(handle != nil)
    let sink = try #require(api.capturedSink)
    sink.success("first")
    sink.error(code: "err_code", message: "err_msg", details: "err_details")
    sink.success("ignored")
    sink.error(code: "ignored_err", message: nil, details: nil)
    sink.endOfStream()
    #expect(dataCount == 1)
    #expect(errorCodes == ["err_code"])
    #expect(doneCount == 0)
  }

  @Test
  func ffiCallbackSinkEndOfStreamIsIdempotent() async throws {
    let api = MockNativeInteropStreamHostApi()
    let registrar = MockFfiStreamPluginRegistrar()
    let instanceName = "test-ffi-sink-done-idempotency"
    NativeInteropStreamHostApiSetup.register(api: api, registrar: registrar, name: instanceName)
    defer {
      NativeInteropStreamHostApiSetup.unregister(api: api, registrar: registrar, name: instanceName)
    }
    let setup = try #require(
      NativeInteropStreamHostApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min, name: instanceName))

    var dataCount = 0
    var errorCount = 0
    var doneCount = 0
    let error = NativeInteropTestsError(code: "", message: nil, details: nil)
    let handle = setup.streamViaCallback(
      prefix: "cb",
      count: 1,
      pigeonOnData: { _ in dataCount += 1 },
      pigeonOnError: { _, _, _ in errorCount += 1 },
      pigeonOnDone: { doneCount += 1 },
      wrappedError: error)
    #expect(handle != nil)
    let sink = try #require(api.capturedSink)
    sink.endOfStream()
    sink.success("ignored-after-done")
    sink.error(code: "ignored", message: nil, details: nil)
    sink.endOfStream()
    #expect(dataCount == 0)
    #expect(errorCount == 0)
    #expect(doneCount == 1)
  }

  @Test
  func ffiCancelHandleIsIdempotent() async throws {
    let api = MockNativeInteropStreamHostApi()
    let registrar = MockFfiStreamPluginRegistrar()
    let instanceName = "test-ffi-cancel-handle-idempotency"
    NativeInteropStreamHostApiSetup.register(api: api, registrar: registrar, name: instanceName)
    defer {
      NativeInteropStreamHostApiSetup.unregister(api: api, registrar: registrar, name: instanceName)
    }
    let setup = try #require(
      NativeInteropStreamHostApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min, name: instanceName))

    final class CounterBox: @unchecked Sendable {
      var count = 0
    }
    let cancelCounter = CounterBox()
    api.onCallbackCancelled = { cancelCounter.count += 1 }
    let error = NativeInteropTestsError(code: "", message: nil, details: nil)
    let cancelHandle = try #require(
      setup.streamViaCallback(
        prefix: "cb",
        count: 1,
        pigeonOnData: { _ in },
        pigeonOnError: { _, _, _ in },
        pigeonOnDone: {},
        wrappedError: error))
    cancelHandle.cancel()
    cancelHandle.cancel()
    #expect(cancelCounter.count == 1)
  }

  @Test
  func ffiCallbackSinkCancelBeforeAttachInvokesCancelImmediately() async throws {
    let api = MockNativeInteropStreamHostApi()
    let registrar = MockFfiStreamPluginRegistrar()
    let instanceName = "test-ffi-cancel-before-attach"
    NativeInteropStreamHostApiSetup.register(api: api, registrar: registrar, name: instanceName)
    let setup = try #require(
      NativeInteropStreamHostApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min, name: instanceName))

    let cancelled = StreamCancelSignal()
    api.onCallbackCancelled = { cancelled.signal() }
    api.onCallbackListen = {
      NativeInteropStreamHostApiSetup.unregister(
        api: api, registrar: registrar, name: instanceName)
    }
    let error = NativeInteropTestsError(code: "", message: nil, details: nil)
    let handle = setup.streamViaCallback(
      prefix: "cb",
      count: 1,
      pigeonOnData: { _ in },
      pigeonOnError: { _, _, _ in },
      pigeonOnDone: {},
      wrappedError: error)
    #expect(handle != nil)
    #expect(cancelled.isSignaled)
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
  var onCallbackListen: (() -> Void)?

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
    onCallbackListen?()
    if prefix == "sync-done" {
      sink.endOfStream()
    }
    let cancelHook = onCallbackCancelled
    return { cancelHook?() }
  }

  func getCancelledStreamCount() throws -> Int64 { 0 }
  func resetCancelledStreamCount() throws {}
}

private final class MockFfiStreamPluginRegistrar: NSObject, FlutterPluginRegistrar {
  private let dummyMessenger = EchoBinaryMessenger(
    codec: FlutterStandardMessageCodec.sharedInstance())
  func messenger() -> FlutterBinaryMessenger { dummyMessenger }
  func textures() -> FlutterTextureRegistry { fatalError("unused") }
  func register(_ factory: FlutterPlatformViewFactory, withId factoryId: String) {}
  func register(
    _ factory: FlutterPlatformViewFactory, withId factoryId: String,
    gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicy
  ) {}
  func publish(_ value: NSObject) {}
  func addMethodCallDelegate(_ delegate: FlutterPlugin, channel: FlutterMethodChannel) {}
  func addApplicationDelegate(_ delegate: FlutterPlugin) {}
  func addSceneDelegate(_ delegate: FlutterSceneLifeCycleDelegate) {}
  func lookupKey(forAsset asset: String) -> String { "" }
  func lookupKey(forAsset asset: String, fromPackage package: String) -> String { "" }
  var viewController: UIViewController? { nil }
  func valuePublished(byPlugin pluginKey: String) -> NSObject? { nil }
}

private final class MockNativeInteropStreamHostApi: NativeInteropStreamHostApi, @unchecked Sendable
{
  var onNumbersCancelled: (@Sendable () -> Void)?
  var capturedSink: NativeInteropTestsPigeonEventSink<String>?
  var onCallbackCancelled: (@Sendable () -> Void)?
  var onCallbackListen: (() -> Void)?

  func streamNumbers(count: Int64, start: Int64) -> AsyncThrowingStream<Int64, Error> {
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

  func streamNullableInts() -> AsyncThrowingStream<Int64?, Error> {
    AsyncThrowingStream { $0.finish() }
  }

  func streamShapes() -> AsyncThrowingStream<NativeInteropShape, Error> {
    AsyncThrowingStream { $0.finish() }
  }

  func streamShapesWithFilter(filter: NativeInteropShape) -> AsyncThrowingStream<
    NativeInteropShape, Error
  > {
    AsyncThrowingStream { $0.finish() }
  }

  func streamError(customError: Bool) -> AsyncThrowingStream<Int64, Error> {
    AsyncThrowingStream { $0.finish() }
  }

  func streamViaCallback(
    prefix: String, count: Int64, sink: NativeInteropTestsPigeonEventSink<String>
  ) -> (() -> Void)? {
    capturedSink = sink
    onCallbackListen?()
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
) async throws -> [Any?]? {
  let handler = try #require(messenger.handlers[channel])
  let encoded = codec.encode(args)
  let replyData: Data? = await withCheckedContinuation {
    (continuation: CheckedContinuation<Data?, Never>) in
    handler(encoded) { data in
      continuation.resume(returning: data)
    }
  }
  return replyData.flatMap { codec.decode($0) as? [Any?] }
}
