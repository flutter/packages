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
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
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
}
