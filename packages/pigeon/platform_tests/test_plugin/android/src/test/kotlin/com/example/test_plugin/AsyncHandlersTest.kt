// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import io.flutter.plugin.common.BinaryMessenger
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import io.mockk.verify
import java.nio.ByteBuffer
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

internal class AsyncHandlersTest {

  @Test
  fun testAsyncHost2Flutter() {
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

    var didCall = false
    api.echoAsyncString(value) {
      didCall = true
      assertEquals(it.getOrNull(), value)
    }

    assertTrue(didCall)

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
    every { api.echo(any(), any()) } answers
        {
          val callback = arg<(Result<String>) -> Unit>(1)
          callback(Result.success(input))
        }

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
    verify { api.echo(input, any()) }
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
    every { api.voidVoid(any()) } answers
        {
          val callback = arg<() -> Unit>(0)
          callback()
        }

    HostSmallApi.setUp(binaryMessenger, api)

    val codec = HostSmallApi.codec
    val message = codec.encodeMessage(null)
    handlerSlot.captured.onMessage(message) {
      it?.rewind()
      @Suppress("UNCHECKED_CAST") val wrapped = codec.decodeMessage(it) as MutableList<Any>?
      assertNull(wrapped)
    }

    verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
    verify { api.voidVoid(any()) }
  }
}
