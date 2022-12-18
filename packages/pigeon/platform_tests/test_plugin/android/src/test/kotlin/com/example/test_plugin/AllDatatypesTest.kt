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
        val everything = AllNullableTypes()
        val binaryMessenger = mockk<BinaryMessenger>()
        val api = FlutterIntegrationCoreApi(binaryMessenger)

        every { binaryMessenger.send(any(), any(), any()) } answers {
            val codec = FlutterIntegrationCoreApi.codec
            val message = arg<ByteBuffer>(1)
            val reply = arg<BinaryMessenger.BinaryReply>(2)
            message.position(0)
            val args = codec.decodeMessage(message) as ArrayList<*>
            val replyData = codec.encodeMessage(args[0])
            replyData?.position(0)
            reply.reply(replyData)
        }

        var didCall = false
        api.echoAllNullableTypes(everything) {
            didCall = true
            assertNull(it.aNullableBool)
            assertNull(it.aNullableInt)
            assertNull(it.aNullableDouble)
            assertNull(it.aNullableString)
            assertNull(it.aNullableByteArray)
            assertNull(it.aNullable4ByteArray)
            assertNull(it.aNullable8ByteArray)
            assertNull(it.aNullableFloatArray)
            assertNull(it.aNullableList)
            assertNull(it.aNullableMap)
            assertNull(it.nullableMapWithObject)
        }

        assertTrue(didCall)
    }

    @Test
    fun testHasValues() {
        val everything = AllNullableTypes(
            aNullableBool = false,
            aNullableInt = 1234L,
            aNullableDouble = 2.0,
            aNullableString = "hello",
            aNullableByteArray = byteArrayOf(1, 2, 3, 4),
            aNullable4ByteArray = intArrayOf(1, 2, 3, 4),
            aNullable8ByteArray = longArrayOf(1, 2, 3, 4),
            aNullableFloatArray = doubleArrayOf(0.5, 0.25, 1.5, 1.25),
            aNullableList = listOf(1, 2, 3),
            aNullableMap = mapOf("hello" to 1234),
            nullableMapWithObject = mapOf("hello" to 1234)
        )
        val binaryMessenger = mockk<BinaryMessenger>()
        val api = FlutterIntegrationCoreApi(binaryMessenger)

        every { binaryMessenger.send(any(), any(), any()) } answers {
            val codec = FlutterIntegrationCoreApi.codec
            val message = arg<ByteBuffer>(1)
            val reply = arg<BinaryMessenger.BinaryReply>(2)
            message.position(0)
            val args = codec.decodeMessage(message) as ArrayList<*>
            val replyData = codec.encodeMessage(args[0])
            replyData?.position(0)
            reply.reply(replyData)
        }

        var didCall = false
        api.echoAllNullableTypes(everything) {
            didCall = true
            assertEquals(everything.aNullableBool, it.aNullableBool)
            assertEquals(everything.aNullableInt, it.aNullableInt)
            assertEquals(everything.aNullableDouble, it.aNullableDouble)
            assertEquals(everything.aNullableString, it.aNullableString)
            assertTrue(everything.aNullableByteArray.contentEquals(it.aNullableByteArray))
            assertTrue(everything.aNullable4ByteArray.contentEquals(it.aNullable4ByteArray))
            assertTrue(everything.aNullable8ByteArray.contentEquals(it.aNullable8ByteArray))
            assertTrue(everything.aNullableFloatArray.contentEquals(it.aNullableFloatArray))
            assertEquals(everything.aNullableList, it.aNullableList)
            assertEquals(everything.aNullableMap, it.aNullableMap)
            assertEquals(everything.nullableMapWithObject, it.nullableMapWithObject)
        }

        assertTrue(didCall)
    }

    @Test
    fun testIntegerToLong() {
        val everything = AllNullableTypes(aNullableInt = 123L)
        val map = everything.toMap()
        assertTrue(map.containsKey("aNullableInt"))

        val map2 = hashMapOf("aNullableInt" to 123)
        val everything2 = AllNullableTypes.fromMap(map2)

        assertEquals(everything.aNullableInt, everything2.aNullableInt)
    }
}
