// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import io.flutter.plugin.common.BinaryMessenger
import io.mockk.every
import io.mockk.mockk
import junit.framework.TestCase
import org.junit.Test
import java.nio.ByteBuffer
import java.util.ArrayList


internal class AllDatatypesTest: TestCase() {
    @Test
    fun testNullValues() {
        val everything = Everything()
        val binaryMessenger = mockk<BinaryMessenger>()
        val api = FlutterEverything(binaryMessenger)

        every { binaryMessenger.send(any(), any(), any()) } answers {
            val codec = FlutterEverything.codec
            val message = arg<ByteBuffer>(1)
            val reply = arg<BinaryMessenger.BinaryReply>(2)
            message.position(0)
            val args = codec.decodeMessage(message) as ArrayList<*>
            val replyData = codec.encodeMessage(args[0])
            replyData?.position(0)
            reply.reply(replyData)
        }

        var didCall = false
        api.echo(everything) {
            didCall = true
            assertNull(it.aBool)
            assertNull(it.anInt)
            assertNull(it.aDouble)
            assertNull(it.aString)
            assertNull(it.aByteArray)
            assertNull(it.a4ByteArray)
            assertNull(it.a8ByteArray)
            assertNull(it.aFloatArray)
            assertNull(it.aList)
            assertNull(it.aMap)
            assertNull(it.mapWithObject)
        }

        assertTrue(didCall)
    }

    @Test
    fun testHasValues() {
        val everything = Everything(
            aBool = false,
            anInt = 1234L,
            aDouble = 2.0,
            aString = "hello",
            aByteArray = byteArrayOf(1, 2, 3, 4),
            a4ByteArray = intArrayOf(1, 2, 3, 4),
            a8ByteArray = longArrayOf(1, 2, 3, 4),
            aFloatArray = doubleArrayOf(0.5, 0.25, 1.5, 1.25),
            aList = listOf(1, 2, 3),
            aMap = mapOf("hello" to 1234),
            mapWithObject = mapOf("hello" to 1234)
        )
        val binaryMessenger = mockk<BinaryMessenger>()
        val api = FlutterEverything(binaryMessenger)

        every { binaryMessenger.send(any(), any(), any()) } answers {
            val codec = FlutterEverything.codec
            val message = arg<ByteBuffer>(1)
            val reply = arg<BinaryMessenger.BinaryReply>(2)
            message.position(0)
            val args = codec.decodeMessage(message) as ArrayList<*>
            val replyData = codec.encodeMessage(args[0])
            replyData?.position(0)
            reply.reply(replyData)
        }

        var didCall = false
        api.echo(everything) {
            didCall = true
            assertEquals(everything.aBool, it.aBool)
            assertEquals(everything.anInt, it.anInt)
            assertEquals(everything.aDouble, it.aDouble)
            assertEquals(everything.aString, it.aString)
            assertTrue(everything.aByteArray.contentEquals(it.aByteArray))
            assertTrue(everything.a4ByteArray.contentEquals(it.a4ByteArray))
            assertTrue(everything.a8ByteArray.contentEquals(it.a8ByteArray))
            assertTrue(everything.aFloatArray.contentEquals(it.aFloatArray))
            assertEquals(everything.aList, it.aList)
            assertEquals(everything.aMap, it.aMap)
            assertEquals(everything.mapWithObject, it.mapWithObject)
        }

        assertTrue(didCall)
    }

    @Test
    fun testIntegerToLong() {
        val everything = Everything(anInt = 123L)
        val map = everything.toMap()
        assertTrue(map.containsKey("anInt"))

        val map2 = hashMapOf("anInt" to 123)
        val everything2 = Everything.fromMap(map2)

        assertEquals(everything.anInt, everything2.anInt)
    }
}
