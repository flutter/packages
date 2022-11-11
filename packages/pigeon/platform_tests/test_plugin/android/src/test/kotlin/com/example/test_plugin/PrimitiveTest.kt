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
import java.util.ArrayList

class PrimitiveTest: TestCase() {
    @Test
    fun testIntPrimitiveHost() {
        val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
        val api = mockk<PrimitiveHostApi>(relaxed = true)

        val input = 1

        val channelName = "dev.flutter.pigeon.PrimitiveHostApi.anInt"
        val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

        every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
        every { api.anInt(any()) } returnsArgument 0

        PrimitiveHostApi.setUp(binaryMessenger, api)

        val codec = PrimitiveHostApi.codec
        val message = codec.encodeMessage(listOf(input))
        message?.rewind()
        handlerSlot.captured.onMessage(message) {
            it?.rewind()
            @Suppress("UNCHECKED_CAST")
            val wrapped = codec.decodeMessage(it) as HashMap<String, Any>?
            assertNotNull(wrapped)
            wrapped?.let {
                assertEquals(input.toLong(), wrapped["result"])
            }
        }

        verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
        verify { api.anInt(input.toLong()) }
    }

    @Test
    fun testIntPrimitiveFlutter() {
        val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
        val api = PrimitiveFlutterApi(binaryMessenger)

        val input = 1L

        var didCall = false
        api.anInt(input) {
            didCall = true
            assertEquals(input, it)
        }

        assertTrue(didCall)
    }

    @Test
    fun testBoolPrimitiveHost() {
        val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
        val api = mockk<PrimitiveHostApi>(relaxed = true)

        val input = true

        val channelName = "dev.flutter.pigeon.PrimitiveHostApi.aBool"
        val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

        every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
        every { api.aBool(any()) } returnsArgument 0

        PrimitiveHostApi.setUp(binaryMessenger, api)

        val codec = PrimitiveHostApi.codec
        val message = codec.encodeMessage(listOf(input))
        message?.rewind()
        handlerSlot.captured.onMessage(message) {
            it?.rewind()
            @Suppress("UNCHECKED_CAST")
            val wrapped = codec.decodeMessage(it) as HashMap<String, Any>?
            assertNotNull(wrapped)
            wrapped?.let {
                assertEquals(input, wrapped["result"])
            }
        }

        verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
        verify { api.aBool(input) }
    }

    @Test
    fun testBoolPrimitiveFlutter() {
        val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
        val api = PrimitiveFlutterApi(binaryMessenger)

        val input = true

        var didCall = false
        api.aBool(input) {
            didCall = true
            assertEquals(input, it)
        }

        assertTrue(didCall)
    }

    @Test
    fun testStringPrimitiveHost() {
        val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
        val api = mockk<PrimitiveHostApi>(relaxed = true)

        val input = "Hello"

        val channelName = "dev.flutter.pigeon.PrimitiveHostApi.aString"
        val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

        every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
        every { api.aString(any()) } returnsArgument 0

        PrimitiveHostApi.setUp(binaryMessenger, api)

        val codec = PrimitiveHostApi.codec
        val message = codec.encodeMessage(listOf(input))
        message?.rewind()
        handlerSlot.captured.onMessage(message) {
            it?.rewind()
            @Suppress("UNCHECKED_CAST")
            val wrapped = codec.decodeMessage(it) as HashMap<String, Any>?
            assertNotNull(wrapped)
            wrapped?.let {
                assertEquals(input, wrapped["result"])
            }
        }

        verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
        verify { api.aString(input) }
    }

    @Test
    fun testDoublePrimitiveHost() {
        val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
        val api = mockk<PrimitiveHostApi>(relaxed = true)

        val input = 1.0

        val channelName = "dev.flutter.pigeon.PrimitiveHostApi.aDouble"
        val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

        every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
        every { api.aDouble(any()) } returnsArgument 0

        PrimitiveHostApi.setUp(binaryMessenger, api)

        val codec = PrimitiveHostApi.codec
        val message = codec.encodeMessage(listOf(input))
        message?.rewind()
        handlerSlot.captured.onMessage(message) {
            it?.rewind()
            @Suppress("UNCHECKED_CAST")
            val wrapped = codec.decodeMessage(it) as HashMap<String, Any>?
            assertNotNull(wrapped)
            wrapped?.let {
                assertEquals(input, wrapped["result"])
            }
        }

        verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
        verify { api.aDouble(input) }
    }

    @Test
    fun testDoublePrimitiveFlutter() {
        val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
        val api = PrimitiveFlutterApi(binaryMessenger)

        val input = 1.0

        var didCall = false
        api.aDouble(input) {
            didCall = true
            assertEquals(input, it)
        }

        assertTrue(didCall)
    }

    @Test
    fun testMapPrimitiveHost() {
        val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
        val api = mockk<PrimitiveHostApi>(relaxed = true)

        val input = mapOf<Any, Any?>("a" to 1, "b" to 2)

        val channelName = "dev.flutter.pigeon.PrimitiveHostApi.aMap"
        val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

        every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
        every { api.aMap(any()) } returnsArgument 0

        PrimitiveHostApi.setUp(binaryMessenger, api)

        val codec = PrimitiveHostApi.codec
        val message = codec.encodeMessage(listOf(input))
        message?.rewind()
        handlerSlot.captured.onMessage(message) {
            it?.rewind()
            @Suppress("UNCHECKED_CAST")
            val wrapped = codec.decodeMessage(it) as HashMap<String, Any>?
            assertNotNull(wrapped)
            wrapped?.let {
                assertEquals(input, wrapped["result"])
            }
        }

        verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
        verify { api.aMap(input) }
    }

    @Test
    fun testMapPrimitiveFlutter() {
        val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
        val api = PrimitiveFlutterApi(binaryMessenger)

        val input = mapOf<Any, Any?>("a" to 1, "b" to 2)

        var didCall = false
        api.aMap(input) {
            didCall = true
            assertEquals(input, it)
        }

        assertTrue(didCall)
    }

    @Test
    fun testListPrimitiveHost() {
        val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
        val api = mockk<PrimitiveHostApi>(relaxed = true)

        val input = listOf(1, 2, 3)

        val channelName = "dev.flutter.pigeon.PrimitiveHostApi.aList"
        val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

        every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
        every { api.aList(any()) } returnsArgument 0

        PrimitiveHostApi.setUp(binaryMessenger, api)

        val codec = PrimitiveHostApi.codec
        val message = codec.encodeMessage(listOf(input))
        message?.rewind()
        handlerSlot.captured.onMessage(message) {
            it?.rewind()
            @Suppress("UNCHECKED_CAST")
            val wrapped = codec.decodeMessage(it) as HashMap<String, Any>?
            assertNotNull(wrapped)
            wrapped?.let {
                assertEquals(input, wrapped["result"])
            }
        }

        verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
        verify { api.aList(input) }
    }

    @Test
    fun testListPrimitiveFlutter() {
        val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
        val api = PrimitiveFlutterApi(binaryMessenger)

        val input = listOf(1, 2, 3)

        var didCall = false
        api.aList(input) {
            didCall = true
            assertEquals(input, it)
        }

        assertTrue(didCall)
    }

    @Test
    fun testInt32ListPrimitiveHost() {
        val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
        val api = mockk<PrimitiveHostApi>(relaxed = true)

        val input = intArrayOf(1, 2, 3)

        val channelName = "dev.flutter.pigeon.PrimitiveHostApi.anInt32List"
        val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

        every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
        every { api.anInt32List(any()) } returnsArgument 0

        PrimitiveHostApi.setUp(binaryMessenger, api)

        val codec = PrimitiveHostApi.codec
        val message = codec.encodeMessage(listOf(input))
        message?.rewind()
        handlerSlot.captured.onMessage(message) {
            it?.rewind()
            @Suppress("UNCHECKED_CAST")
            val wrapped = codec.decodeMessage(it) as HashMap<String, Any>?
            assertNotNull(wrapped)
            wrapped?.let {
                assertTrue(input.contentEquals(wrapped["result"] as IntArray))
            }
        }

        verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
        verify { api.anInt32List(input) }
    }

    @Test
    fun testInt32ListPrimitiveFlutter() {
        val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
        val api = PrimitiveFlutterApi(binaryMessenger)

        val input = intArrayOf(1, 2, 3)

        var didCall = false
        api.anInt32List(input) {
            didCall = true
            assertTrue(input.contentEquals(it))
        }

        assertTrue(didCall)
    }

    @Test
    fun testBoolListPrimitiveHost() {
        val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
        val api = mockk<PrimitiveHostApi>(relaxed = true)

        val input = listOf(true, false, true)

        val channelName = "dev.flutter.pigeon.PrimitiveHostApi.aBoolList"
        val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

        every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
        every { api.aBoolList(any()) } returnsArgument 0

        PrimitiveHostApi.setUp(binaryMessenger, api)

        val codec = PrimitiveHostApi.codec
        val message = codec.encodeMessage(listOf(input))
        message?.rewind()
        handlerSlot.captured.onMessage(message) {
            it?.rewind()
            @Suppress("UNCHECKED_CAST")
            val wrapped = codec.decodeMessage(it) as HashMap<String, Any>?
            assertNotNull(wrapped)
            wrapped?.let {
                assertEquals(input, wrapped["result"])
            }
        }

        verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
        verify { api.aBoolList(input) }
    }

    @Test
    fun testBoolListPrimitiveFlutter() {
        val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
        val api = PrimitiveFlutterApi(binaryMessenger)

        val input = listOf(true, false, true)

        var didCall = false
        api.aBoolList(input) {
            didCall = true
            assertEquals(input, it)
        }

        assertTrue(didCall)
    }

    @Test
    fun testStringIntMapPrimitiveHost() {
        val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
        val api = mockk<PrimitiveHostApi>(relaxed = true)

        val input = mapOf<String?, Long?>("a" to 1, "b" to 2)

        val channelName = "dev.flutter.pigeon.PrimitiveHostApi.aStringIntMap"
        val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

        every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
        every { api.aStringIntMap(any()) } returnsArgument 0

        PrimitiveHostApi.setUp(binaryMessenger, api)

        val codec = PrimitiveHostApi.codec
        val message = codec.encodeMessage(listOf(input))
        message?.rewind()
        handlerSlot.captured.onMessage(message) {
            it?.rewind()
            @Suppress("UNCHECKED_CAST")
            val wrapped = codec.decodeMessage(it) as HashMap<String, Any>?
            assertNotNull(wrapped)
            wrapped?.let {
                assertEquals(input, wrapped["result"])
            }
        }

        verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
        verify { api.aStringIntMap(input) }
    }

    @Test
    fun testStringIntMapPrimitiveFlutter() {
        val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
        val api = PrimitiveFlutterApi(binaryMessenger)

        val input = mapOf<String?, Long?>("a" to 1, "b" to 2)

        var didCall = false
        api.aStringIntMap(input) {
            didCall = true
            assertEquals(input, it)
        }

        assertTrue(didCall)
    }

}
