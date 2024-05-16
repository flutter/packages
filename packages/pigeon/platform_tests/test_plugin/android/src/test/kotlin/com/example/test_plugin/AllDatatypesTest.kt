// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import io.flutter.plugin.common.BinaryMessenger
import io.mockk.every
import io.mockk.mockk
import java.nio.ByteBuffer
import java.util.ArrayList
import junit.framework.TestCase

internal class AllDatatypesTest : TestCase() {

  private fun compareAllListTypes(firstTypes: AllListTypes?, secondTypes: AllListTypes?) {
    assertEquals(firstTypes == null, secondTypes == null)
    if (firstTypes == null || secondTypes == null) {
      return
    }
    assertEquals(firstTypes.list, secondTypes.list)
    assertEquals(firstTypes.boolList, secondTypes.boolList)
    assertEquals(firstTypes.doubleList, secondTypes.doubleList)
    assertEquals(firstTypes.intList, secondTypes.intList)
    assertEquals(firstTypes.stringList, secondTypes.stringList)
  }

  private fun compareAllMapTypes(firstTypes: AllMapTypes?, secondTypes: AllMapTypes?) {
    assertEquals(firstTypes == null, secondTypes == null)
    if (firstTypes == null || secondTypes == null) {
      return
    }
    assertEquals(firstTypes.map, secondTypes.map)
  }

  private fun compareAllNullableListTypes(
      firstTypes: AllNullableListTypes?,
      secondTypes: AllNullableListTypes?
  ) {
    assertEquals(firstTypes == null, secondTypes == null)
    if (firstTypes == null || secondTypes == null) {
      return
    }
    assertEquals(firstTypes.list, secondTypes.list)
    assertEquals(firstTypes.boolList, secondTypes.boolList)
    assertEquals(firstTypes.doubleList, secondTypes.doubleList)
    assertEquals(firstTypes.intList, secondTypes.intList)
    assertEquals(firstTypes.stringList, secondTypes.stringList)
  }

  private fun compareAllNullableMapTypes(
      firstTypes: AllNullableMapTypes?,
      secondTypes: AllNullableMapTypes?
  ) {
    assertEquals(firstTypes == null, secondTypes == null)
    if (firstTypes == null || secondTypes == null) {
      return
    }
    assertEquals(firstTypes.map, secondTypes.map)
  }

  fun compareAllTypes(firstTypes: AllTypes?, secondTypes: AllTypes?) {
    assertEquals(firstTypes == null, secondTypes == null)
    if (firstTypes == null || secondTypes == null) {
      return
    }
    assertEquals(firstTypes.aBool, secondTypes.aBool)
    assertEquals(firstTypes.anInt, secondTypes.anInt)
    assertEquals(firstTypes.anInt64, secondTypes.anInt64)
    assertEquals(firstTypes.aDouble, secondTypes.aDouble)
    assertEquals(firstTypes.aString, secondTypes.aString)
    assertTrue(firstTypes.aByteArray.contentEquals(secondTypes.aByteArray))
    assertTrue(firstTypes.a4ByteArray.contentEquals(secondTypes.a4ByteArray))
    assertTrue(firstTypes.a8ByteArray.contentEquals(secondTypes.a8ByteArray))
    assertTrue(firstTypes.aFloatArray.contentEquals(secondTypes.aFloatArray))
    assertEquals(firstTypes.anEnum, secondTypes.anEnum)
    assertEquals(firstTypes.anObject, secondTypes.anObject)
    compareAllListTypes(firstTypes.allLists, secondTypes.allLists)
    compareAllMapTypes(firstTypes.allMaps, secondTypes.allMaps)
  }

  private fun compareAllNullableTypes(
      firstTypes: AllNullableTypes?,
      secondTypes: AllNullableTypes?
  ) {
    assertEquals(firstTypes == null, secondTypes == null)
    if (firstTypes == null || secondTypes == null) {
      return
    }
    assertEquals(firstTypes.aNullableBool, secondTypes.aNullableBool)
    assertEquals(firstTypes.aNullableInt, secondTypes.aNullableInt)
    assertEquals(firstTypes.aNullableDouble, secondTypes.aNullableDouble)
    assertEquals(firstTypes.aNullableString, secondTypes.aNullableString)
    assertTrue(firstTypes.aNullableByteArray.contentEquals(secondTypes.aNullableByteArray))
    assertTrue(firstTypes.aNullable4ByteArray.contentEquals(secondTypes.aNullable4ByteArray))
    assertTrue(firstTypes.aNullable8ByteArray.contentEquals(secondTypes.aNullable8ByteArray))
    assertTrue(firstTypes.aNullableFloatArray.contentEquals(secondTypes.aNullableFloatArray))
    assertEquals(firstTypes.nullableMapWithObject, secondTypes.nullableMapWithObject)
    assertEquals(firstTypes.aNullableObject, secondTypes.aNullableObject)
    compareAllNullableListTypes(firstTypes.allNullableLists, secondTypes.allNullableLists)
    compareAllNullableMapTypes(firstTypes.allNullableMaps, secondTypes.allNullableMaps)
  }

  fun testNullValues() {
    val everything =
        AllNullableTypes(
            allNullableLists = AllNullableListTypes(), allNullableMaps = AllNullableMapTypes())
    val binaryMessenger = mockk<BinaryMessenger>()
    val api = FlutterIntegrationCoreApi(binaryMessenger)

    every { binaryMessenger.send(any(), any(), any()) } answers
        {
          val codec = FlutterIntegrationCoreApi.codec
          val message = arg<ByteBuffer>(1)
          val reply = arg<BinaryMessenger.BinaryReply>(2)
          message.position(0)
          val args = codec.decodeMessage(message) as ArrayList<*>
          val replyData = codec.encodeMessage(args)
          replyData?.position(0)
          reply.reply(replyData)
        }

    var didCall = false
    api.echoAllNullableTypes(everything) { result ->
      didCall = true
      val output = (result.getOrNull())?.let { compareAllNullableTypes(it, everything) }
      assertNotNull(output)
    }

    assertTrue(didCall)
  }

  fun testHasValues() {
    val allNullableLists =
        AllNullableListTypes(
            list = listOf(1, 2, 3),
            stringList = listOf("string", "another one"),
            boolList = listOf(true, false),
            intList = listOf(1, 2),
            doubleList = listOf(1.1, 2.2))
    val allNullableMaps = AllNullableMapTypes(map = mapOf("hello" to 1234))

    val everything =
        AllNullableTypes(
            aNullableBool = false,
            aNullableInt = 1234L,
            aNullableDouble = 2.0,
            aNullableString = "hello",
            aNullableByteArray = byteArrayOf(1, 2, 3, 4),
            aNullable4ByteArray = intArrayOf(1, 2, 3, 4),
            aNullable8ByteArray = longArrayOf(1, 2, 3, 4),
            aNullableFloatArray = doubleArrayOf(0.5, 0.25, 1.5, 1.25),
            nullableMapWithObject = mapOf("hello" to 1234),
            aNullableObject = 0,
            allNullableLists = allNullableLists,
            allNullableMaps = allNullableMaps,
        )
    val binaryMessenger = mockk<BinaryMessenger>()
    val api = FlutterIntegrationCoreApi(binaryMessenger)

    every { binaryMessenger.send(any(), any(), any()) } answers
        {
          val codec = FlutterIntegrationCoreApi.codec
          val message = arg<ByteBuffer>(1)
          val reply = arg<BinaryMessenger.BinaryReply>(2)
          message.position(0)
          val args = codec.decodeMessage(message) as ArrayList<*>
          val replyData = codec.encodeMessage(args)
          replyData?.position(0)
          reply.reply(replyData)
        }

    var didCall = false
    api.echoAllNullableTypes(everything) {
      didCall = true
      compareAllNullableTypes(everything, it.getOrNull())
    }

    assertTrue(didCall)
  }

  fun testIntegerToLong() {
    val everything = AllNullableTypes(aNullableInt = 123L)
    val list = everything.toList()
    assertNotNull(list)
    assertNull(list.first())
    assertNotNull(list[1])
    assertTrue(list[1] == 123L)

    val list2 =
        listOf(
            null,
            123,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null)
    val everything2 = AllNullableTypes.fromList(list2)

    assertEquals(everything.aNullableInt, everything2.aNullableInt)
  }
}
