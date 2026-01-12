// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import io.flutter.plugin.common.BinaryMessenger
import io.mockk.every
import io.mockk.mockk
import java.nio.ByteBuffer
import java.util.ArrayList
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class ListTest {

  @Test
  fun testListInList() {
    val binaryMessenger = mockk<BinaryMessenger>()
    val api = FlutterSmallApi(binaryMessenger)

    val inside = TestMessage(listOf(1, 2, 3))
    val input = TestMessage(listOf(inside))

    every { binaryMessenger.send(any(), any(), any()) } answers
        {
          val codec = FlutterSmallApi.codec
          val message = arg<ByteBuffer>(1)
          val reply = arg<BinaryMessenger.BinaryReply>(2)
          message.position(0)
          val args = codec.decodeMessage(message) as ArrayList<*>
          val replyData = codec.encodeMessage(args)
          replyData?.position(0)
          reply.reply(replyData)
        }

    var didCall = false
    api.echoWrappedList(input) {
      didCall = true
      assertEquals(input, it.getOrNull())
    }

    assertTrue(didCall)
  }
}
