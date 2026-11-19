// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import io.flutter.plugin.common.BinaryMessenger
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import io.mockk.verify
import java.nio.ByteBuffer
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.awaitCancellation
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
internal class AsyncHandlersTest {

  @Before
  fun setUp() {
    Dispatchers.setMain(UnconfinedTestDispatcher())
  }

  @After
  fun tearDown() {
    Dispatchers.resetMain()
  }

  @Test
  fun testAsyncHost2Flutter() = runTest {
    val binaryMessenger = mockk<BinaryMessenger>()
    val api = FlutterIntegrationCoreApi(binaryMessenger)

    val value = "Test"

    every { binaryMessenger.send(any(), any(), any()) } answers
        {
          val codec = FlutterIntegrationCoreApi.codec
          val message = arg<ByteBuffer>(1)
          val reply = arg<BinaryMessenger.BinaryReply>(2)
          message.position(0)
          val replyData = codec.encodeMessage(listOf(value))
          replyData?.position(0)
          reply.reply(replyData)
        }

    val res = api.echoAsyncString(value)
    assertEquals(value, res)

    verify {
      binaryMessenger.send(
          "dev.flutter.pigeon.pigeon_integration_tests.FlutterIntegrationCoreApi.echoAsyncString",
          any(),
          any())
    }
  }

  @Test
  fun testAsyncFlutter2HostEcho() {
    val binaryMessenger = mockk<BinaryMessenger>()
    val api = mockk<HostSmallApi>()

    val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

    val input = "Test"
    val channelName = "dev.flutter.pigeon.pigeon_integration_tests.HostSmallApi.echo"

    every {
      binaryMessenger.setMessageHandler(
          "dev.flutter.pigeon.pigeon_integration_tests.HostSmallApi.voidVoid", any())
    } returns Unit
    every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
    coEvery { api.echo(any()) } returns input

    HostSmallApi.setUp(binaryMessenger, api)

    val codec = HostSmallApi.codec
    val message = codec.encodeMessage(listOf(input))
    message?.rewind()
    handlerSlot.captured.onMessage(message) {
      assertNotNull(it)
      it?.rewind()
      @Suppress("UNCHECKED_CAST") val wrapped = codec.decodeMessage(it) as MutableList<Any>?
      assertNotNull(wrapped)
      wrapped?.let { assertEquals(input, wrapped.first()) }
    }

    verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
    coVerify { api.echo(input) }
  }

  @Test
  fun testAsyncFlutter2HostVoidVoid() {
    val binaryMessenger = mockk<BinaryMessenger>()
    val api = mockk<HostSmallApi>()

    val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

    val channelName = "dev.flutter.pigeon.pigeon_integration_tests.HostSmallApi.voidVoid"

    every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
    every {
      binaryMessenger.setMessageHandler(
          "dev.flutter.pigeon.pigeon_integration_tests.HostSmallApi.echo", any())
    } returns Unit
    coEvery { api.voidVoid() } returns Unit

    HostSmallApi.setUp(binaryMessenger, api)

    val codec = HostSmallApi.codec
    val message = codec.encodeMessage(null)
    handlerSlot.captured.onMessage(message) {
      it?.rewind()
      @Suppress("UNCHECKED_CAST") val wrapped = codec.decodeMessage(it) as MutableList<Any>?
      assertNotNull(wrapped)
      assertNull(wrapped?.first())
    }

    verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
    coVerify { api.voidVoid() }
  }

  @Test
  fun testHostStreamFlowAndTeardownCancellation() {
    val numbersChannel =
        "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamNumbers"
    val callbackChannel =
        "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamViaCallback"
    val sentFrames = mutableListOf<List<Any?>>()
    val (binaryMessenger, slots) =
        mockStreamMessenger(listOf(numbersChannel, callbackChannel), sentFrames)
    val api = mockk<StreamHostTestApi>()

    var flowCancelled = false
    every { api.streamNumbers(2L, 10L) } returns flowOf(10L, 11L)
    every { api.streamNumbers(99L, 0L) } returns
        flow {
          try {
            emit(0L)
            awaitCancellation()
          } finally {
            flowCancelled = true
          }
        }
    var callbackClosed = false
    every { api.streamViaCallback("p", 1L, any()) } answers
        {
          val sink = arg<EventChannelTestsPigeonEventSink<String>>(2)
          sink.success("p:0")
          AutoCloseable { callbackClosed = true }
        }

    StreamHostTestApi.setUp(binaryMessenger, api)
    val numbersHandler = slots[numbersChannel]!!.captured
    val callbackHandler = slots[callbackChannel]!!.captured

    assertEquals(listOf(null), sendStreamControl(numbersHandler, listOf("listen", 1L, 2L, 10L)))
    assertEquals(
        listOf(listOf(1L, 0L, 10L), listOf(1L, 0L, 11L), listOf(1L, 2L)),
        sentFrames,
    )

    sentFrames.clear()
    assertEquals(listOf(null), sendStreamControl(numbersHandler, listOf("listen", 2L, 99L, 0L)))
    assertEquals(listOf(null), sendStreamControl(callbackHandler, listOf("listen", 3L, "p", 1L)))
    assertEquals(listOf(listOf(2L, 0L, 0L), listOf(3L, 0L, "p:0")), sentFrames)

    // Tearing down via setUp(binaryMessenger, null) cancels both active subscriptions.
    StreamHostTestApi.setUp(binaryMessenger, null)
    assertTrue(flowCancelled)
    assertTrue(callbackClosed)
  }

  private fun sendStreamControl(
      handler: BinaryMessenger.BinaryMessageHandler,
      args: List<Any?>,
  ): List<Any?> {
    val codec = StreamHostTestApi.codec
    val encoded = codec.encodeMessage(args)
    encoded?.rewind()
    lateinit var decodedReply: List<Any?>
    handler.onMessage(encoded) { reply ->
      assertNotNull(reply)
      reply!!.rewind()
      @Suppress("UNCHECKED_CAST")
      decodedReply = codec.decodeMessage(reply) as List<Any?>
    }
    return decodedReply
  }

  private fun mockStreamMessenger(
      channels: List<String>,
      frames: MutableList<List<Any?>>,
  ): Pair<
      BinaryMessenger, Map<String, io.mockk.CapturingSlot<BinaryMessenger.BinaryMessageHandler>>> {
    val messenger = mockk<BinaryMessenger>(relaxed = true)
    val codec = StreamHostTestApi.codec
    val slots = channels.associateWith { slot<BinaryMessenger.BinaryMessageHandler>() }
    for ((channel, handlerSlot) in slots) {
      every { messenger.setMessageHandler(channel, capture(handlerSlot)) } returns Unit
    }
    every { messenger.send(any(), any(), any()) } answers
        {
          val buffer = arg<ByteBuffer>(1)
          buffer.rewind()
          @Suppress("UNCHECKED_CAST") frames.add(codec.decodeMessage(buffer) as List<Any?>)
        }
    return messenger to slots
  }

  @Test
  fun testHostStreamUnknownControlActionReturnsInvalidActionError() {
    val numbersChannel =
        "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamNumbers"
    val frames = mutableListOf<List<Any?>>()
    val (messenger, slots) = mockStreamMessenger(listOf(numbersChannel), frames)
    val api = mockk<StreamHostTestApi>()
    StreamHostTestApi.setUp(messenger, api)

    val reply = sendStreamControl(slots[numbersChannel]!!.captured, listOf("bogus", 99L))
    assertEquals(3, reply.size)
    assertEquals("invalid-action", reply[0])
    assertTrue((reply[1] as String).contains("bogus"))
    assertTrue(frames.isEmpty())

    StreamHostTestApi.setUp(messenger, null)
  }

  @Test
  fun testHostStreamMultiEngineIsolationAndSupersede() {
    val numbersChannel =
        "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamNumbers"
    val framesA = mutableListOf<List<Any?>>()
    val framesB = mutableListOf<List<Any?>>()
    val (messengerA, slotsA) = mockStreamMessenger(listOf(numbersChannel), framesA)
    val (messengerB, slotsB) = mockStreamMessenger(listOf(numbersChannel), framesB)
    val apiA = mockk<StreamHostTestApi>()
    val apiB = mockk<StreamHostTestApi>()

    var flowACancelled = false
    var flowBCancelled = false
    every { apiA.streamNumbers(10L, 0L) } returns
        flow {
          try {
            emit(1L)
            awaitCancellation()
          } finally {
            flowACancelled = true
          }
        }
    every { apiB.streamNumbers(10L, 0L) } returns
        flow {
          try {
            emit(2L)
            awaitCancellation()
          } finally {
            flowBCancelled = true
          }
        }

    StreamHostTestApi.setUp(messengerA, apiA)
    StreamHostTestApi.setUp(messengerB, apiB)

    val handlerA = slotsA[numbersChannel]!!.captured
    val handlerB = slotsB[numbersChannel]!!.captured

    // Both engines subscribe with subscriptionId = 0L; neither may clobber the other.
    assertEquals(listOf(null), sendStreamControl(handlerA, listOf("listen", 0L, 10L, 0L)))
    assertEquals(listOf(null), sendStreamControl(handlerB, listOf("listen", 0L, 10L, 0L)))
    assertFalse(flowACancelled)
    assertFalse(flowBCancelled)
    assertEquals(listOf(listOf(0L, 0L, 1L)), framesA)
    assertEquals(listOf(listOf(0L, 0L, 2L)), framesB)

    // Tearing down messengerB must NOT cancel messengerA's active stream.
    StreamHostTestApi.setUp(messengerB, null)
    assertTrue(flowBCancelled)
    assertFalse(flowACancelled)

    // Superseding subscriptionId = 0L on messengerA must cancel the old flow without removing the
    // new one.
    var replacedFlowCancelled = false
    every { apiA.streamNumbers(10L, 50L) } returns
        flow {
          try {
            emit(50L)
            awaitCancellation()
          } finally {
            replacedFlowCancelled = true
          }
        }
    assertEquals(listOf(null), sendStreamControl(handlerA, listOf("listen", 0L, 10L, 50L)))
    assertTrue(flowACancelled)
    assertFalse(replacedFlowCancelled)

    // Explicit "cancel" must still cancel the replacement subscription.
    assertEquals(listOf(null), sendStreamControl(handlerA, listOf("cancel", 0L)))
    assertTrue(replacedFlowCancelled)

    StreamHostTestApi.setUp(messengerA, null)
  }

  @Test
  fun testHostStreamErrorAndCancellationPropagation() {
    val numbersChannel =
        "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamNumbers"
    val frames = mutableListOf<List<Any?>>()
    val (messenger, slots) = mockStreamMessenger(listOf(numbersChannel), frames)
    val api = mockk<StreamHostTestApi>()

    every { api.streamNumbers(1L, -1L) } returns
        flow { throw kotlinx.coroutines.CancellationException("host cancelled") }
    every { api.streamNumbers(1L, -2L) } returns flow { throw IllegalStateException("flow boom") }
    every { api.streamNumbers(1L, -3L) } throws IllegalStateException("sync boom")

    StreamHostTestApi.setUp(messenger, api)
    val handler = slots[numbersChannel]!!.captured

    // Host-originated CancellationException forwards an error frame instead of hanging Dart.
    assertEquals(listOf(null), sendStreamControl(handler, listOf("listen", 5L, 1L, -1L)))
    assertEquals(1, frames.size)
    assertEquals(5L, frames[0][0])
    assertEquals(1L, frames[0][1])

    // Regular Flow exception forwards an error frame; synchronous api throw returns an error reply.
    frames.clear()
    assertEquals(listOf(null), sendStreamControl(handler, listOf("listen", 9L, 1L, -2L)))
    assertEquals(1, frames.size)
    assertEquals(9L, frames[0][0])
    assertEquals(1L, frames[0][1])

    val syncErrReply = sendStreamControl(handler, listOf("listen", 10L, 1L, -3L))
    assertEquals(3, syncErrReply.size)

    StreamHostTestApi.setUp(messenger, null)
  }

  @Test
  fun testHostStreamCallbackSinkErrorTerminatesAndIgnoresSubsequentCalls() {
    val callbackChannel =
        "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamViaCallback"
    val frames = mutableListOf<List<Any?>>()
    val (messenger, slots) = mockStreamMessenger(listOf(callbackChannel), frames)
    val api = mockk<StreamHostTestApi>()

    var capturedSink: EventChannelTestsPigeonEventSink<String>? = null
    every { api.streamViaCallback("cb", 1L, any()) } answers
        {
          capturedSink = arg(2)
          AutoCloseable {}
        }

    StreamHostTestApi.setUp(messenger, api)
    val handler = slots[callbackChannel]!!.captured

    assertEquals(listOf(null), sendStreamControl(handler, listOf("listen", 6L, "cb", 1L)))
    val errorSink = capturedSink!!
    errorSink.success("first")
    errorSink.error("err_code", "err_msg", "err_det")
    errorSink.success("ignored")
    errorSink.endOfStream()
    assertEquals(
        listOf(listOf(6L, 0L, "first"), listOf(6L, 1L, "err_code", "err_msg", "err_det")),
        frames,
    )

    StreamHostTestApi.setUp(messenger, null)
  }

  @Test
  fun testHostStreamCallbackSinkEndOfStreamTerminatesAndIgnoresSubsequentCalls() {
    val callbackChannel =
        "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamViaCallback"
    val frames = mutableListOf<List<Any?>>()
    val (messenger, slots) = mockStreamMessenger(listOf(callbackChannel), frames)
    val api = mockk<StreamHostTestApi>()

    var capturedSink: EventChannelTestsPigeonEventSink<String>? = null
    every { api.streamViaCallback("cb", 1L, any()) } answers
        {
          capturedSink = arg(2)
          AutoCloseable {}
        }

    StreamHostTestApi.setUp(messenger, api)
    val handler = slots[callbackChannel]!!.captured

    assertEquals(listOf(null), sendStreamControl(handler, listOf("listen", 7L, "cb", 1L)))
    val doneSink = capturedSink!!
    doneSink.endOfStream()
    doneSink.success("ignored-after-done")
    assertEquals(listOf(listOf(7L, 2L)), frames)

    StreamHostTestApi.setUp(messenger, null)
  }

  @Test
  fun testHostStreamCallbackSyncEndOfStreamDoesNotInvokeCloseable() {
    val callbackChannel =
        "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamViaCallback"
    val frames = mutableListOf<List<Any?>>()
    val (messenger, slots) = mockStreamMessenger(listOf(callbackChannel), frames)
    val api = mockk<StreamHostTestApi>()

    var syncClosed = false
    every { api.streamViaCallback("sync-done", 1L, any()) } answers
        {
          val sink = arg<EventChannelTestsPigeonEventSink<String>>(2)
          sink.endOfStream()
          AutoCloseable { syncClosed = true }
        }

    StreamHostTestApi.setUp(messenger, api)
    val handler = slots[callbackChannel]!!.captured

    assertEquals(listOf(null), sendStreamControl(handler, listOf("listen", 11L, "sync-done", 1L)))
    assertEquals(listOf(listOf(11L, 2L)), frames)
    assertFalse(syncClosed)

    // Teardown must also not invoke the closeable, verifying synchronous endOfStream() cleared the
    // registration.
    StreamHostTestApi.setUp(messenger, null)
    assertFalse(syncClosed)
  }

  @Test
  fun testHostStreamCallbackCancelBeforeAttachClosesHandleImmediately() {
    val callbackChannel =
        "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamViaCallback"
    val frames = mutableListOf<List<Any?>>()
    val (messenger, slots) = mockStreamMessenger(listOf(callbackChannel), frames)
    val api = mockk<StreamHostTestApi>()

    lateinit var handler: BinaryMessenger.BinaryMessageHandler
    var closed = false
    every { api.streamViaCallback("cancel-before-return", 1L, any()) } answers
        {
          assertEquals(listOf(null), sendStreamControl(handler, listOf("cancel", 16L)))
          AutoCloseable { closed = true }
        }

    StreamHostTestApi.setUp(messenger, api)
    handler = slots[callbackChannel]!!.captured

    assertEquals(
        listOf(null),
        sendStreamControl(handler, listOf("listen", 16L, "cancel-before-return", 1L)),
    )
    assertTrue(closed)

    StreamHostTestApi.setUp(messenger, null)
  }

  @Test
  fun testHostStreamCallbackExplicitCancelInvokesCloseable() {
    val callbackChannel =
        "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamViaCallback"
    val frames = mutableListOf<List<Any?>>()
    val (messenger, slots) = mockStreamMessenger(listOf(callbackChannel), frames)
    val api = mockk<StreamHostTestApi>()

    var capturedSink: EventChannelTestsPigeonEventSink<String>? = null
    var callbackClosed = false
    every { api.streamViaCallback("cb", 1L, any()) } answers
        {
          capturedSink = arg(2)
          AutoCloseable { callbackClosed = true }
        }

    StreamHostTestApi.setUp(messenger, api)
    val handler = slots[callbackChannel]!!.captured

    assertEquals(listOf(null), sendStreamControl(handler, listOf("listen", 8L, "cb", 1L)))
    val cancelSink = capturedSink!!
    assertEquals(listOf(null), sendStreamControl(handler, listOf("cancel", 8L)))
    assertTrue(callbackClosed)
    cancelSink.success("ignored-after-cancel")
    assertTrue(frames.isEmpty())

    StreamHostTestApi.setUp(messenger, null)
  }

  @Test
  fun testHostStreamCallbackExplicitCancelPropagatesThrowingCloseable() {
    val callbackChannel =
        "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamViaCallback"
    val frames = mutableListOf<List<Any?>>()
    val (messenger, slots) = mockStreamMessenger(listOf(callbackChannel), frames)
    val api = mockk<StreamHostTestApi>()

    every { api.streamViaCallback("throw-close", 1L, any()) } answers
        {
          AutoCloseable { throw EventChannelTestsError("close_err", "close failed", null) }
        }

    StreamHostTestApi.setUp(messenger, api)
    val handler = slots[callbackChannel]!!.captured

    assertEquals(listOf(null), sendStreamControl(handler, listOf("listen", 12L, "throw-close", 1L)))
    val cancelErrReply = sendStreamControl(handler, listOf("cancel", 12L))
    assertEquals(listOf("close_err", "close failed", null), cancelErrReply)

    StreamHostTestApi.setUp(messenger, null)
  }

  @Test
  fun testHostStreamCallbackSyncThrowReturnsWrappedErrorReply() {
    val callbackChannel =
        "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamViaCallback"
    val frames = mutableListOf<List<Any?>>()
    val (messenger, slots) = mockStreamMessenger(listOf(callbackChannel), frames)
    val api = mockk<StreamHostTestApi>()

    every { api.streamViaCallback("throw-listen", 1L, any()) } throws
        EventChannelTestsError("cb_sync_err", "listen failed", null)

    StreamHostTestApi.setUp(messenger, api)
    val handler = slots[callbackChannel]!!.captured

    val syncThrowReply = sendStreamControl(handler, listOf("listen", 13L, "throw-listen", 1L))
    assertEquals(listOf("cb_sync_err", "listen failed", null), syncThrowReply)

    StreamHostTestApi.setUp(messenger, null)
  }

  @Test
  fun testHostStreamCallbackTeardownIsolatesThrowingCloseable() {
    val callbackChannel =
        "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamViaCallback"
    val frames = mutableListOf<List<Any?>>()
    val (messenger, slots) = mockStreamMessenger(listOf(callbackChannel), frames)
    val api = mockk<StreamHostTestApi>()

    var callbackClosed = false
    every { api.streamViaCallback("cb", 1L, any()) } answers
        {
          AutoCloseable { callbackClosed = true }
        }
    every { api.streamViaCallback("throw-close", 1L, any()) } answers
        {
          AutoCloseable { throw EventChannelTestsError("close_err", "close failed", null) }
        }

    StreamHostTestApi.setUp(messenger, api)
    val handler = slots[callbackChannel]!!.captured

    assertEquals(listOf(null), sendStreamControl(handler, listOf("listen", 14L, "throw-close", 1L)))
    assertEquals(listOf(null), sendStreamControl(handler, listOf("listen", 15L, "cb", 1L)))
    StreamHostTestApi.setUp(messenger, null)
    assertTrue(callbackClosed)
  }

  private fun mockInteropStreamEngine(id: Long): io.flutter.embedding.engine.FlutterEngine {
    val executor = mockk<io.flutter.embedding.engine.dart.DartExecutor>()
    val engine = mockk<io.flutter.embedding.engine.FlutterEngine>()
    every { engine.engineId } returns id
    every { engine.dartExecutor } returns executor
    return engine
  }

  @Test
  fun testJniHostStreamUnregisterCancelsActiveFlowAndCallbackStreams() {
    val api = mockk<NativeInteropStreamHostApi>()
    val flowDataLatch = java.util.concurrent.CountDownLatch(1)
    val flowCancelledLatch = java.util.concurrent.CountDownLatch(1)
    var callbackClosed = false
    every { api.streamNumbers(99L, 0L) } returns
        flow {
          try {
            emit(1L)
            awaitCancellation()
          } finally {
            flowCancelledLatch.countDown()
          }
        }
    every { api.streamViaCallback("cb", 1L, any()) } answers
        {
          val sink = arg<NativeInteropTestsPigeonEventSink<String>>(2)
          sink.success("cb:0")
          AutoCloseable { callbackClosed = true }
        }

    val engine = mockInteropStreamEngine(9001L)
    val name = "test-jni-unregister-cancels"
    val registrar = NativeInteropStreamHostApiRegistrar()
    registrar.register(api, engine, name)
    val resolved =
        NativeInteropStreamHostApiRegistrar.pigeonResolveInstance(9001L, Long.MIN_VALUE, name)
    assertNotNull(resolved)

    val dataCount = java.util.concurrent.atomic.AtomicInteger(0)
    val flowCallback =
        object : NativeInteropTestsPigeonStreamCallback {
          override fun onData(encodedValue: ByteArray) {
            dataCount.incrementAndGet()
            flowDataLatch.countDown()
          }

          override fun onError(code: String, message: String?, encodedDetails: ByteArray?) {}

          override fun onDone() {}
        }
    val cbCallback =
        object : NativeInteropTestsPigeonStreamCallback {
          override fun onData(encodedValue: ByteArray) {
            dataCount.incrementAndGet()
          }

          override fun onError(code: String, message: String?, encodedDetails: ByteArray?) {}

          override fun onDone() {}
        }

    resolved!!.streamNumbers(99L, 0L, flowCallback)
    resolved.streamViaCallback("cb", 1L, cbCallback)
    assertTrue(flowDataLatch.await(5, java.util.concurrent.TimeUnit.SECONDS))
    assertEquals(2, dataCount.get())
    assertEquals(1L, flowCancelledLatch.count)
    assertFalse(callbackClosed)

    registrar.unregister(api, engine, name)
    assertTrue(flowCancelledLatch.await(5, java.util.concurrent.TimeUnit.SECONDS))
    assertTrue(callbackClosed)
  }

  @Test
  fun testJniHostStreamOnUnregisteredRegistrarThrowsUnregisteredInstance() {
    val api = mockk<NativeInteropStreamHostApi>()
    val engine = mockInteropStreamEngine(9002L)
    val name = "test-jni-unregistered-throws"
    val registrar = NativeInteropStreamHostApiRegistrar()
    registrar.register(api, engine, name)
    val resolved =
        NativeInteropStreamHostApiRegistrar.pigeonResolveInstance(9002L, Long.MIN_VALUE, name)
    assertNotNull(resolved)
    registrar.unregister(api, engine, name)

    val callback =
        object : NativeInteropTestsPigeonStreamCallback {
          override fun onData(encodedValue: ByteArray) {}

          override fun onError(code: String, message: String?, encodedDetails: ByteArray?) {}

          override fun onDone() {}
        }

    var thrown: NativeInteropTestsError? = null
    try {
      resolved!!.streamNumbers(1L, 0L, callback)
    } catch (e: NativeInteropTestsError) {
      thrown = e
    }
    assertNotNull(thrown)
    assertEquals("unregistered-instance", thrown!!.code)
  }

  @Test
  fun testJniEventSinkErrorAndEndOfStreamAreIdempotentWithoutAttachOnClosed() {
    val dataCount = java.util.concurrent.atomic.AtomicInteger(0)
    val errorCodes = mutableListOf<String>()
    val doneCount = java.util.concurrent.atomic.AtomicInteger(0)
    val callback =
        object : NativeInteropTestsPigeonStreamCallback {
          override fun onData(encodedValue: ByteArray) {
            dataCount.incrementAndGet()
          }

          override fun onError(code: String, message: String?, encodedDetails: ByteArray?) {
            errorCodes.add(code)
            assertNotNull(encodedDetails)
          }

          override fun onDone() {
            doneCount.incrementAndGet()
          }
        }

    // Direct sink without attachOnClosed() must still deliver onError and ignore subsequent calls.
    val errorSink = NativeInteropTestsPigeonEventSink<String>(callback)
    errorSink.success("first")
    errorSink.error("err_code", "err_msg", "err_details")
    errorSink.success("ignored")
    errorSink.error("ignored_err", null, null)
    errorSink.endOfStream()
    assertEquals(1, dataCount.get())
    assertEquals(listOf("err_code"), errorCodes)
    assertEquals(0, doneCount.get())

    // Direct sink without attachOnClosed() must still deliver onDone and ignore subsequent calls.
    val doneSink = NativeInteropTestsPigeonEventSink<String>(callback)
    doneSink.endOfStream()
    doneSink.success("ignored")
    doneSink.endOfStream()
    assertEquals(1, dataCount.get())
    assertEquals(1, doneCount.get())
  }

  @Test
  fun testJniEventSinkCancelBeforeAttachClosesImmediately() {
    val callback =
        object : NativeInteropTestsPigeonStreamCallback {
          override fun onData(encodedValue: ByteArray) {}

          override fun onError(code: String, message: String?, encodedDetails: ByteArray?) {}

          override fun onDone() {}
        }
    val sink = NativeInteropTestsPigeonEventSink<String>(callback)
    sink.close()
    var closed = false
    sink.attachCloseable(AutoCloseable { closed = true })
    assertTrue(closed)
  }

  @Test
  fun testJniCancelHandleIsIdempotentAndReencodesFlutterErrorDetails() {
    var cancelCalls = 0
    val handle = NativeInteropTestsPigeonStreamCancelHandle { cancelCalls++ }
    handle.cancel()
    handle.cancel()
    assertEquals(1, cancelCalls)

    val throwingHandle = NativeInteropTestsPigeonStreamCancelHandle {
      throw NativeInteropTestsError("close_err", "close msg", "raw_details")
    }
    var thrown: NativeInteropTestsError? = null
    try {
      throwingHandle.cancel()
    } catch (e: NativeInteropTestsError) {
      thrown = e
    }
    assertNotNull(thrown)
    assertEquals("close_err", thrown!!.code)
    assertEquals("close msg", thrown.message)
    assertTrue(thrown.details is ByteArray)
    // Subsequent cancel() is a no-op even after a throw.
    throwingHandle.cancel()
  }

  @Test
  fun testJniCallbackSyncThrowCleansUpAndReencodesDetails() {
    val api = mockk<NativeInteropStreamHostApi>()
    every { api.streamViaCallback("throw", 1L, any()) } throws
        NativeInteropTestsError("sync_cb_err", "sync msg", "sync_details")

    val engine = mockInteropStreamEngine(9003L)
    val name = "test-jni-sync-throw"
    val registrar = NativeInteropStreamHostApiRegistrar()
    registrar.register(api, engine, name)
    val resolved =
        NativeInteropStreamHostApiRegistrar.pigeonResolveInstance(9003L, Long.MIN_VALUE, name)
    assertNotNull(resolved)

    val callback =
        object : NativeInteropTestsPigeonStreamCallback {
          override fun onData(encodedValue: ByteArray) {}

          override fun onError(code: String, message: String?, encodedDetails: ByteArray?) {}

          override fun onDone() {}
        }

    var thrown: NativeInteropTestsError? = null
    try {
      resolved!!.streamViaCallback("throw", 1L, callback)
    } catch (e: NativeInteropTestsError) {
      thrown = e
    }
    assertNotNull(thrown)
    assertEquals("sync_cb_err", thrown!!.code)
    assertTrue(thrown.details is ByteArray)
    registrar.unregister(api, engine, name)
  }
}
