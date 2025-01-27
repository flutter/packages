// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import io.flutter.plugin.common.BinaryMessenger
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import java.nio.ByteBuffer
import java.util.ArrayList
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test

class MultipleArityTests {

  @Test
  fun testSimpleHost() {
    val binaryMessenger = mockk<BinaryMessenger>()
    val api = mockk<MultipleArityHostApi>()

    val inputX = 10L
    val inputY = 5L

    val channelName = "dev.flutter.pigeon.pigeon_integration_tests.MultipleArityHostApi.subtract"
    val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

    every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
    every { api.subtract(any(), any()) } answers { firstArg<Long>() - secondArg<Long>() }

    MultipleArityHostApi.setUp(binaryMessenger, api)

    val codec = MultipleArityHostApi.codec
    val message = codec.encodeMessage(listOf(inputX, inputY))
    message?.rewind()
    handlerSlot.captured.onMessage(message) {
      it?.rewind()
      @Suppress("UNCHECKED_CAST") val wrapped = codec.decodeMessage(it) as List<Any>?
      assertNotNull(wrapped)
      wrapped?.let { assertEquals(inputX - inputY, wrapped[0]) }
    }
  }

  @Test
  fun testSimpleFlutter() {
    val binaryMessenger = mockk<BinaryMessenger>()
    val api = MultipleArityFlutterApi(binaryMessenger)

    val inputX = 10L
    val inputY = 5L

    every { binaryMessenger.send(any(), any(), any()) } answers
        {
          val codec = MultipleArityFlutterApi.codec
          val message = arg<ByteBuffer>(1)
          val reply = arg<BinaryMessenger.BinaryReply>(2)
          message.position(0)
          val args = codec.decodeMessage(message) as ArrayList<*>
          val argX = args[0] as Long
          val argY = args[1] as Long
          val replyData = codec.encodeMessage(listOf(argX - argY))
          replyData?.position(0)
          reply.reply(replyData)
        }

    var didCall = false
    api.subtract(inputX, inputY) {
      didCall = true
      assertEquals(inputX - inputY, it.getOrNull())
    }

    assertTrue(didCall)
  }
}
