// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import io.flutter.plugin.common.BinaryMessenger
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import io.mockk.verify
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test

class NullableReturnsTest {

  @Test
  fun testNullableParameterHost() {
    val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
    val api = mockk<NullableReturnHostApi>(relaxed = true)

    val output = 1L

    val channelName = "dev.flutter.pigeon.pigeon_integration_tests.NullableReturnHostApi.doit"
    val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

    every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
    every { api.doit() } returns output

    NullableReturnHostApi.setUp(binaryMessenger, api)

    val codec = PrimitiveHostApi.codec
    val message = codec.encodeMessage(null)
    message?.rewind()
    handlerSlot.captured.onMessage(message) {
      it?.rewind()
      @Suppress("UNCHECKED_CAST") val wrapped = codec.decodeMessage(it) as List<Any>?
      assertNotNull(wrapped)
      wrapped?.let { assertEquals(output, wrapped[0]) }
    }

    verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
    verify { api.doit() }
  }

  @Test
  fun testNullableParameterFlutter() {
    val binaryMessenger = mockk<BinaryMessenger>()
    val api = NullableReturnFlutterApi(binaryMessenger)

    val output = 12L

    every { binaryMessenger.send(any(), any(), any()) } answers
        {
          val codec = NullableReturnFlutterApi.codec
          val reply = arg<BinaryMessenger.BinaryReply>(2)
          val replyData = codec.encodeMessage(listOf(output))
          replyData?.position(0)
          reply.reply(replyData)
        }

    var didCall = false
    api.doit {
      didCall = true
      assertEquals(output, it.getOrNull())
    }

    assertTrue(didCall)
  }
}
