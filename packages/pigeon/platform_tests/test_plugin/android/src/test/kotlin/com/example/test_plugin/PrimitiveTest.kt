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

class PrimitiveTest : TestCase() {

  fun testIntPrimitiveHost() {
    val binaryMessenger = mockk<BinaryMessenger>(relaxed = true)
    val api = mockk<PrimitiveHostApi>(relaxed = true)

    val input = 1

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
      wrapped?.let { assertEquals(input.toLong(), wrapped[0]) }
    }

    verify { binaryMessenger.setMessageHandler(channelName, handlerSlot.captured) }
    verify { api.anInt(input.toLong()) }
  }

  fun testIntPrimitiveFlutter() {
    val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
    val api = PrimitiveFlutterApi(binaryMessenger)

    val input = 1L

    var didCall = false
    api.anInt(input) {
      didCall = true
      assertEquals(input, it.getOrNull())
    }

    assertTrue(didCall)
  }

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

  fun testBoolPrimitiveFlutter() {
    val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
    val api = PrimitiveFlutterApi(binaryMessenger)

    val input = true

    var didCall = false
    api.aBool(input) {
      didCall = true
      assertEquals(input, it.getOrNull())
    }

    assertTrue(didCall)
  }

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

  fun testDoublePrimitiveFlutter() {
    val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
    val api = PrimitiveFlutterApi(binaryMessenger)

    val input = 1.0

    var didCall = false
    api.aDouble(input) {
      didCall = true
      assertEquals(input, it.getOrNull())
    }

    assertTrue(didCall)
  }

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

  fun testMapPrimitiveFlutter() {
    val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
    val api = PrimitiveFlutterApi(binaryMessenger)

    val input = mapOf<Any, Any?>("a" to 1, "b" to 2)

    var didCall = false
    api.aMap(input) {
      didCall = true
      assertEquals(input, it.getOrNull())
    }

    assertTrue(didCall)
  }

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

  fun testListPrimitiveFlutter() {
    val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
    val api = PrimitiveFlutterApi(binaryMessenger)

    val input = listOf(1, 2, 3)

    var didCall = false
    api.aList(input) {
      didCall = true
      assertEquals(input, it.getOrNull())
    }

    assertTrue(didCall)
  }

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

  fun testInt32ListPrimitiveFlutter() {
    val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
    val api = PrimitiveFlutterApi(binaryMessenger)

    val input = intArrayOf(1, 2, 3)

    var didCall = false
    api.anInt32List(input) {
      didCall = true
      assertTrue(input.contentEquals(it.getOrNull()))
    }

    assertTrue(didCall)
  }

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

  fun testBoolListPrimitiveFlutter() {
    val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
    val api = PrimitiveFlutterApi(binaryMessenger)

    val input = listOf(true, false, true)

    var didCall = false
    api.aBoolList(input) {
      didCall = true
      assertEquals(input, it.getOrNull())
    }

    assertTrue(didCall)
  }

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

  fun testStringIntMapPrimitiveFlutter() {
    val binaryMessenger = EchoBinaryMessenger(MultipleArityFlutterApi.codec)
    val api = PrimitiveFlutterApi(binaryMessenger)

    val input = mapOf<String?, Long?>("a" to 1, "b" to 2)

    var didCall = false
    api.aStringIntMap(input) {
      didCall = true
      assertEquals(input, it.getOrNull())
    }

    assertTrue(didCall)
  }
}
