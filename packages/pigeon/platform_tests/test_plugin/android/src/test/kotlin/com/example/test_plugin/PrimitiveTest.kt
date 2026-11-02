// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import io.flutter.plugin.common.BinaryMessenger
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import io.mockk.verify
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test

class PrimitiveTest {

  @Test
  fun testIntPrimitiveHost() {
    val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
    val api = mockk<PrimitiveHostApi>(relaxed = true)

    val input = 1L

    val channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.anInt"
    val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

    every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
    every { api.anInt(any()) } returnsArgument 0

    PrimitiveHostApi.setUp(binaryMessenger, api)

    val codec = PrimitiveHostApi.codec
    val message = codec.encodeMessage(listOf(input))
    message?.rewind()
    handlerSlot.captured.onMessage(message) {
      it?.rewind()
      @Suppress("UNCHECKED_CAST") val wrapped = codec.decodeMessage(it) as List<Any>?
      assertNotNull(wrapped)
      wrapped?.let { assertEquals(input, wrapped[0]) }
    }

    verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
    verify { api.anInt(input) }
  }

  @Test
  fun testIntPrimitiveFlutter() = runTest {
    val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
    val api = PrimitiveFlutterApi(binaryMessenger)

    val input = 1L
    val res = api.anInt(input)
    assertEquals(input, res)
  }

  @Test
  fun testBoolPrimitiveHost() {
    val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
    val api = mockk<PrimitiveHostApi>(relaxed = true)

    val input = true

    val channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aBool"
    val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

    every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
    every { api.aBool(any()) } returnsArgument 0

    PrimitiveHostApi.setUp(binaryMessenger, api)

    val codec = PrimitiveHostApi.codec
    val message = codec.encodeMessage(listOf(input))
    message?.rewind()
    handlerSlot.captured.onMessage(message) {
      it?.rewind()
      @Suppress("UNCHECKED_CAST") val wrapped = codec.decodeMessage(it) as List<Any>?
      assertNotNull(wrapped)
      wrapped?.let { assertEquals(input, wrapped[0]) }
    }

    verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
    verify { api.aBool(input) }
  }

  @Test
  fun testBoolPrimitiveFlutter() = runTest {
    val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
    val api = PrimitiveFlutterApi(binaryMessenger)

    val input = true
    val res = api.aBool(input)
    assertEquals(input, res)
  }

  @Test
  fun testStringPrimitiveHost() {
    val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
    val api = mockk<PrimitiveHostApi>(relaxed = true)

    val input = "Hello"

    val channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aString"
    val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

    every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
    every { api.aString(any()) } returnsArgument 0

    PrimitiveHostApi.setUp(binaryMessenger, api)

    val codec = PrimitiveHostApi.codec
    val message = codec.encodeMessage(listOf(input))
    message?.rewind()
    handlerSlot.captured.onMessage(message) {
      it?.rewind()
      @Suppress("UNCHECKED_CAST") val wrapped = codec.decodeMessage(it) as List<Any>?
      assertNotNull(wrapped)
      wrapped?.let { assertEquals(input, wrapped[0]) }
    }

    verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
    verify { api.aString(input) }
  }

  @Test
  fun testDoublePrimitiveHost() {
    val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
    val api = mockk<PrimitiveHostApi>(relaxed = true)

    val input = 1.0

    val channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aDouble"
    val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

    every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
    every { api.aDouble(any()) } returnsArgument 0

    PrimitiveHostApi.setUp(binaryMessenger, api)

    val codec = PrimitiveHostApi.codec
    val message = codec.encodeMessage(listOf(input))
    message?.rewind()
    handlerSlot.captured.onMessage(message) {
      it?.rewind()
      @Suppress("UNCHECKED_CAST") val wrapped = codec.decodeMessage(it) as List<Any>?
      assertNotNull(wrapped)
      wrapped?.let { assertEquals(input, wrapped[0]) }
    }

    verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
    verify { api.aDouble(input) }
  }

  @Test
  fun testDoublePrimitiveFlutter() = runTest {
    val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
    val api = PrimitiveFlutterApi(binaryMessenger)

    val input = 1.0
    val res = api.aDouble(input)
    assertEquals(input, res, 0.0)
  }

  @Test
  fun testMapPrimitiveHost() {
    val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
    val api = mockk<PrimitiveHostApi>(relaxed = true)

    val input = mapOf<Any, Any?>("a" to 1, "b" to 2)

    val channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aMap"
    val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

    every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
    every { api.aMap(any()) } returnsArgument 0

    PrimitiveHostApi.setUp(binaryMessenger, api)

    val codec = PrimitiveHostApi.codec
    val message = codec.encodeMessage(listOf(input))
    message?.rewind()
    handlerSlot.captured.onMessage(message) {
      it?.rewind()
      @Suppress("UNCHECKED_CAST") val wrapped = codec.decodeMessage(it) as List<Any>?
      assertNotNull(wrapped)
      wrapped?.let { assertEquals(input, wrapped[0]) }
    }

    verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
    verify { api.aMap(input) }
  }

  @Test
  fun testMapPrimitiveFlutter() = runTest {
    val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
    val api = PrimitiveFlutterApi(binaryMessenger)

    val input = mapOf<Any, Any?>("a" to 1, "b" to 2)
    val res = api.aMap(input)
    assertEquals(input, res)
  }

  @Test
  fun testListPrimitiveHost() {
    val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
    val api = mockk<PrimitiveHostApi>(relaxed = true)

    val input = listOf(1, 2, 3)

    val channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aList"
    val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

    every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
    every { api.aList(any()) } returnsArgument 0

    PrimitiveHostApi.setUp(binaryMessenger, api)

    val codec = PrimitiveHostApi.codec
    val message = codec.encodeMessage(listOf(input))
    message?.rewind()
    handlerSlot.captured.onMessage(message) {
      it?.rewind()
      @Suppress("UNCHECKED_CAST") val wrapped = codec.decodeMessage(it) as List<Any>?
      assertNotNull(wrapped)
      wrapped?.let { assertEquals(input, wrapped[0]) }
    }

    verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
    verify { api.aList(input) }
  }

  @Test
  fun testListPrimitiveFlutter() = runTest {
    val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
    val api = PrimitiveFlutterApi(binaryMessenger)

    val input = listOf(1, 2, 3)
    val res = api.aList(input)
    assertEquals(input, res)
  }

  @Test
  fun testInt32ListPrimitiveHost() {
    val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
    val api = mockk<PrimitiveHostApi>(relaxed = true)

    val input = intArrayOf(1, 2, 3)

    val channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.anInt32List"
    val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

    every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
    every { api.anInt32List(any()) } returnsArgument 0

    PrimitiveHostApi.setUp(binaryMessenger, api)

    val codec = PrimitiveHostApi.codec
    val message = codec.encodeMessage(listOf(input))
    message?.rewind()
    handlerSlot.captured.onMessage(message) {
      it?.rewind()
      @Suppress("UNCHECKED_CAST") val wrapped = codec.decodeMessage(it) as List<Any>?
      assertNotNull(wrapped)
      wrapped?.let { assertTrue(input.contentEquals(wrapped[0] as IntArray)) }
    }

    verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
    verify { api.anInt32List(input) }
  }

  @Test
  fun testInt32ListPrimitiveFlutter() = runTest {
    val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
    val api = PrimitiveFlutterApi(binaryMessenger)

    val input = intArrayOf(1, 2, 3)
    val res = api.anInt32List(input)
    assertTrue(input.contentEquals(res))
  }

  @Test
  fun testBoolListPrimitiveHost() {
    val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
    val api = mockk<PrimitiveHostApi>(relaxed = true)

    val input = listOf(true, false, true)

    val channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aBoolList"
    val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

    every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
    every { api.aBoolList(any()) } returnsArgument 0

    PrimitiveHostApi.setUp(binaryMessenger, api)

    val codec = PrimitiveHostApi.codec
    val message = codec.encodeMessage(listOf(input))
    message?.rewind()
    handlerSlot.captured.onMessage(message) {
      it?.rewind()
      @Suppress("UNCHECKED_CAST") val wrapped = codec.decodeMessage(it) as List<Any>?
      assertNotNull(wrapped)
      wrapped?.let { assertEquals(input, wrapped[0]) }
    }

    verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
    verify { api.aBoolList(input) }
  }

  @Test
  fun testBoolListPrimitiveFlutter() = runTest {
    val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
    val api = PrimitiveFlutterApi(binaryMessenger)

    val input = listOf(true, false, true)
    val res = api.aBoolList(input)
    assertEquals(input, res)
  }

  @Test
  fun testStringIntMapPrimitiveHost() {
    val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
    val api = mockk<PrimitiveHostApi>(relaxed = true)

    val input = mapOf<String?, Long?>("a" to 1, "b" to 2)

    val channelName = "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aStringIntMap"
    val handlerSlot = slot<BinaryMessenger.BinaryMessageHandler>()

    every { binaryMessenger.setMessageHandler(channelName, capture(handlerSlot)) } returns Unit
    every { api.aStringIntMap(any()) } returnsArgument 0

    PrimitiveHostApi.setUp(binaryMessenger, api)

    val codec = PrimitiveHostApi.codec
    val message = codec.encodeMessage(listOf(input))
    message?.rewind()
    handlerSlot.captured.onMessage(message) {
      it?.rewind()
      @Suppress("UNCHECKED_CAST") val wrapped = codec.decodeMessage(it) as List<Any>?
      assertNotNull(wrapped)
      wrapped?.let { assertEquals(input, wrapped[0]) }
    }

    verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
    verify { api.aStringIntMap(input) }
  }

  @Test
  fun testStringIntMapPrimitiveFlutter() = runTest {
    val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
    val api = PrimitiveFlutterApi(binaryMessenger)

    val input = mapOf<String?, Long?>("a" to 1, "b" to 2)
    val res = api.aStringIntMap(input)
    assertEquals(input, res)
  }
}
