// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import io.flutter.plugin.common.BinaryMessenger
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import io.mockk.verify
import junit.framework.TestCase
import org.junit.Test
import java.nio.ByteBuffer


internal class AsyncHandlersTest: TestCase() {
    @Test
    fun testAsyncHost2Flutter() {
        val binaryMessenger = mockk<BinaryMessenger>()
        val api = Api2Flutter(binaryMessenger)

        val input = Value(1)
        val output = Value(2)

        every { binaryMessenger.send(any(), any(), any()) } answers {
            val codec = Api2Flutter.codec
            val message = arg<ByteBuffer>(1)
            val reply = arg<BinaryMessenger.BinaryReply>(2)
            message.position(0)
            val replyData = codec.encodeMessage(output)
            replyData?.position(0)
            reply.reply(replyData)
        }

        var didCall = false
        api.calculate(input) {
            didCall = true
            assertEquals(it, output)
        }

        assertTrue(didCall)

        verify { binaryMessenger.send("dev.flutter.pigeon.Api2Flutter.calculate", any(), any()) }
    }

    @Test
    fun testAsyncFlutter2HostCalculate() {
        val binaryMessenger = mockk<BinaryMessenger>()
        val api = mockk<Api2Host>()

        val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

        val input = Value(1)
        val output = Value(2)
        val channelName = "dev.flutter.pigeon.Api2Host.calculate"

        every { binaryMessenger.setMessageHandler("dev.flutter.pigeon.Api2Host.voidVoid", any()) } returns Unit
        every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
        every { api.calculate(any(), any()) } answers {
            val callback = arg<(Result<Value>) -> Unit>(1)
            callback(Result.success(output))
        }

        Api2Host.setUp(binaryMessenger, api)

        val codec = Api2Host.codec
        val message = codec.encodeMessage(listOf(input))
        message?.rewind()
        handlerSlot.captured.onMessage(message) {
            assertNotNull(it)
            it?.rewind()
            @Suppress("UNCHECKED_CAST")
            val wrapped = codec.decodeMessage(it) as MutableList<Any>?
            assertNotNull(wrapped)
            wrapped?.let {
                assertEquals(output, wrapped.first())
            }
        }

        verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
        verify { api.calculate(input, any()) }
    }

    @Test
    fun asyncFlutter2HostVoidVoid() {
        val binaryMessenger = mockk<BinaryMessenger>()
        val api = mockk<Api2Host>()

        val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

        val channelName = "dev.flutter.pigeon.Api2Host.voidVoid"

        every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
        every { binaryMessenger.setMessageHandler("dev.flutter.pigeon.Api2Host.calculate", any()) } returns Unit
        every { api.voidVoid(any()) } answers {
            val callback = arg<() -> Unit>(0)
            callback()
        }

        Api2Host.setUp(binaryMessenger, api)

        val codec = Api2Host.codec
        val message = codec.encodeMessage(null)
        handlerSlot.captured.onMessage(message) {
            it?.rewind()
            @Suppress("UNCHECKED_CAST")
            val wrapped = codec.decodeMessage(it) as MutableList<Any>?
            assertNull(wrapped)
        }

        verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
        verify { api.voidVoid(any()) }
    }
}
