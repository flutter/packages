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
    val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
    val api = mockk<StreamHostTestApi>()
    val numbersHandler = slot<BinaryMessenger.BinaryMessageHandler>()
    val callbackHandler = slot<BinaryMessenger.BinaryMessageHandler>()
    val sentFrames = mutableListOf<List<Any?>>()
    val codec = StreamHostTestApi.codec

    val numbersChannel =
        "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamNumbers"
    val callbackChannel =
        "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamViaCallback"

    every { binaryMessenger.setMessageHandler(numbersChannel, capture(numbersHandler)) } returns
        Unit
    every { binaryMessenger.setMessageHandler(callbackChannel, capture(callbackHandler)) } returns
        Unit
    every { binaryMessenger.send(any(), any(), any()) } answers
        {
          val buffer = arg<ByteBuffer>(1)
          buffer.rewind()
          @Suppress("UNCHECKED_CAST") val decoded = codec.decodeMessage(buffer) as List<Any?>
          sentFrames.add(decoded)
        }

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

    val listenFinite = codec.encodeMessage(listOf("listen", 1L, 2L, 10L))
    listenFinite?.rewind()
    numbersHandler.captured.onMessage(listenFinite) {}
    assertEquals(
        listOf(listOf(1L, 0L, 10L), listOf(1L, 0L, 11L), listOf(1L, 2L)),
        sentFrames,
    )

    sentFrames.clear()
    val listenInfinite = codec.encodeMessage(listOf("listen", 2L, 99L, 0L))
    listenInfinite?.rewind()
    numbersHandler.captured.onMessage(listenInfinite) {}

    val listenCallback = codec.encodeMessage(listOf("listen", 3L, "p", 1L))
    listenCallback?.rewind()
    callbackHandler.captured.onMessage(listenCallback) {}
    assertEquals(listOf(listOf(2L, 0L, 0L), listOf(3L, 0L, "p:0")), sentFrames)

    // Tearing down via setUp(binaryMessenger, null) cancels both active subscriptions.
    StreamHostTestApi.setUp(binaryMessenger, null)
    assertTrue(flowCancelled)
    assertTrue(callbackClosed)
  }

  @Test
  fun testHostStreamExplicitCancelSinkTerminalAndMultiEngineIsolation() {
    val messengerA = mockk<BinaryMessenger>(relaxed = true)
    val messengerB = mockk<BinaryMessenger>(relaxed = true)
    val apiA = mockk<StreamHostTestApi>()
    val apiB = mockk<StreamHostTestApi>()
    val numbersHandlerA = slot<BinaryMessenger.BinaryMessageHandler>()
    val numbersHandlerB = slot<BinaryMessenger.BinaryMessageHandler>()
    val callbackHandlerA = slot<BinaryMessenger.BinaryMessageHandler>()
    val framesA = mutableListOf<List<Any?>>()
    val framesB = mutableListOf<List<Any?>>()
    val codec = StreamHostTestApi.codec

    val numbersChannel =
        "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamNumbers"
    val callbackChannel =
        "dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamViaCallback"

    every { messengerA.setMessageHandler(numbersChannel, capture(numbersHandlerA)) } returns Unit
    every { messengerB.setMessageHandler(numbersChannel, capture(numbersHandlerB)) } returns Unit
    every { messengerA.setMessageHandler(callbackChannel, capture(callbackHandlerA)) } returns Unit
    every { messengerA.send(any(), any(), any()) } answers
        {
          val buffer = arg<ByteBuffer>(1)
          buffer.rewind()
          @Suppress("UNCHECKED_CAST") framesA.add(codec.decodeMessage(buffer) as List<Any?>)
        }
    every { messengerB.send(any(), any(), any()) } answers
        {
          val buffer = arg<ByteBuffer>(1)
          buffer.rewind()
          @Suppress("UNCHECKED_CAST") framesB.add(codec.decodeMessage(buffer) as List<Any?>)
        }

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
    every { apiA.streamNumbers(1L, -1L) } returns
        flow { throw kotlinx.coroutines.CancellationException("host cancelled") }
    every { apiA.streamNumbers(1L, -2L) } returns flow { throw IllegalStateException("flow boom") }
    every { apiA.streamNumbers(1L, -3L) } throws IllegalStateException("sync boom")

    var capturedSink: EventChannelTestsPigeonEventSink<String>? = null
    var callbackClosed = false
    every { apiA.streamViaCallback("cb", 1L, any()) } answers
        {
          capturedSink = arg(2)
          AutoCloseable { callbackClosed = true }
        }
    var syncClosed = false
    every { apiA.streamViaCallback("sync-done", 1L, any()) } answers
        {
          val sink = arg<EventChannelTestsPigeonEventSink<String>>(2)
          sink.endOfStream()
          AutoCloseable { syncClosed = true }
        }

    StreamHostTestApi.setUp(messengerA, apiA)
    StreamHostTestApi.setUp(messengerB, apiB)

    fun sendControl(
        handler: BinaryMessenger.BinaryMessageHandler,
        args: List<Any?>,
    ): List<Any?> {
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

    // Both engines subscribe with subscriptionId = 0L; neither may clobber the other.
    assertEquals(listOf(null), sendControl(numbersHandlerA.captured, listOf("listen", 0L, 10L, 0L)))
    assertEquals(listOf(null), sendControl(numbersHandlerB.captured, listOf("listen", 0L, 10L, 0L)))

    assertFalse(flowACancelled)
    assertFalse(flowBCancelled)
    assertEquals(listOf(listOf(0L, 0L, 1L)), framesA)
    assertEquals(listOf(listOf(0L, 0L, 2L)), framesB)

    // Unknown control actions must fail loudly with an error reply instead of spawning a stream.
    val unknownReply = sendControl(numbersHandlerA.captured, listOf("bogus", 99L))
    assertEquals(3, unknownReply.size)

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
    assertEquals(
        listOf(null), sendControl(numbersHandlerA.captured, listOf("listen", 0L, 10L, 50L)))
    assertTrue(flowACancelled)
    assertFalse(replacedFlowCancelled)
    // Explicit "cancel" must still cancel the replacement subscription.
    assertEquals(listOf(null), sendControl(numbersHandlerA.captured, listOf("cancel", 0L)))
    assertTrue(replacedFlowCancelled)

    // Host-originated CancellationException forwards an error frame instead of hanging Dart.
    framesA.clear()
    assertEquals(listOf(null), sendControl(numbersHandlerA.captured, listOf("listen", 5L, 1L, -1L)))
    assertEquals(1, framesA.size)
    assertEquals(5L, framesA[0][0])
    assertEquals(1L, framesA[0][1])

    // Regular Flow exception forwards an error frame; synchronous api throw returns an error reply.
    framesA.clear()
    assertEquals(listOf(null), sendControl(numbersHandlerA.captured, listOf("listen", 9L, 1L, -2L)))
    assertEquals(1, framesA.size)
    assertEquals(9L, framesA[0][0])
    assertEquals(1L, framesA[0][1])

    val syncErrReply = sendControl(numbersHandlerA.captured, listOf("listen", 10L, 1L, -3L))
    assertEquals(3, syncErrReply.size)

    // Callback sink: error(), post-termination no-op, synchronous endOfStream, and explicit cancel.
    framesA.clear()
    assertEquals(
        listOf(null),
        sendControl(callbackHandlerA.captured, listOf("listen", 6L, "cb", 1L)),
    )
    val errorSink = capturedSink!!
    errorSink.success("first")
    errorSink.error("err_code", "err_msg", "err_det")
    // Calls after error() must be ignored.
    errorSink.success("ignored")
    errorSink.endOfStream()
    assertEquals(
        listOf(listOf(6L, 0L, "first"), listOf(6L, 1L, "err_code", "err_msg", "err_det")),
        framesA,
    )

    framesA.clear()
    assertEquals(
        listOf(null),
        sendControl(callbackHandlerA.captured, listOf("listen", 7L, "cb", 1L)),
    )
    val doneSink = capturedSink!!
    doneSink.endOfStream()
    doneSink.success("ignored-after-done")
    assertEquals(listOf(listOf(7L, 2L)), framesA)

    framesA.clear()
    assertEquals(
        listOf(null),
        sendControl(callbackHandlerA.captured, listOf("listen", 11L, "sync-done", 1L)),
    )
    assertEquals(listOf(listOf(11L, 2L)), framesA)
    assertTrue(syncClosed)

    framesA.clear()
    callbackClosed = false
    assertEquals(
        listOf(null),
        sendControl(callbackHandlerA.captured, listOf("listen", 8L, "cb", 1L)),
    )
    val cancelSink = capturedSink!!
    assertEquals(listOf(null), sendControl(callbackHandlerA.captured, listOf("cancel", 8L)))
    assertTrue(callbackClosed)
    cancelSink.success("ignored-after-cancel")
    assertTrue(framesA.isEmpty())

    StreamHostTestApi.setUp(messengerA, null)
  }
}
