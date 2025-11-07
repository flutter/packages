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
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test

internal class AllDatatypesTest {

  @Test
  fun testNullValues() {
    val everything = AllNullableTypes()
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
      val output = (result.getOrNull())?.let { it == everything }
      assertNotNull(output)
    }

    assertTrue(didCall)
  }

  @Test
  fun testRoundtripNullValues() {
    val everything = AllNullableTypes()
    val codec = FlutterIntegrationCoreApi.codec
    val encoded = codec.encodeMessage(everything)
    encoded?.rewind()
    val decoded = codec.decodeMessage(encoded)
    assertEquals(everything, decoded)
  }

  fun getFullyPopulatedAllNullableTypes(): AllNullableTypes {
    val stringList = listOf("string", "another one")

    return AllNullableTypes(
        aNullableBool = false,
        aNullableInt = 1234L,
        aNullableDouble = 2.0,
        aNullableString = "hello",
        aNullableByteArray = byteArrayOf(1, 2, 3, 4),
        aNullable4ByteArray = intArrayOf(1, 2, 3, 4),
        aNullable8ByteArray = longArrayOf(1, 2, 3, 4),
        aNullableFloatArray = doubleArrayOf(0.5, 0.25, 1.5, 1.25),
        aNullableEnum = AnEnum.TWO,
        anotherNullableEnum = AnotherEnum.JUST_IN_CASE,
        aNullableObject = 0,
        list = listOf(1, 2, 3),
        stringList = stringList,
        boolList = listOf(true, false),
        enumList = listOf(AnEnum.ONE, AnEnum.TWO),
        intList = listOf(1, 2),
        doubleList = listOf(1.1, 2.2),
        objectList = listOf(1, 2, 3),
        listList = listOf(stringList, stringList.toList()),
        mapList = listOf(mapOf("hello" to 1234), mapOf("hello" to 1234)),
        map = mapOf("hello" to 1234),
        stringMap = mapOf("hello" to "you"),
        intMap = mapOf(1L to 0L),
        objectMap = mapOf("hello" to 1234),
        enumMap =
            mapOf(AnEnum.ONE to AnEnum.FORTY_TWO, AnEnum.TWO to AnEnum.FOUR_HUNDRED_TWENTY_TWO),
        listMap = mapOf(1L to stringList),
        mapMap = mapOf(1L to mapOf()))
  }

  @Test
  fun testHasValues() {
    val everything = getFullyPopulatedAllNullableTypes()
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
      assertTrue(everything == it.getOrNull())
    }

    assertTrue(didCall)
  }

  @Test
  fun testRoundtripHasValues() {
    val everything = getFullyPopulatedAllNullableTypes()
    val codec = FlutterIntegrationCoreApi.codec
    val encoded = codec.encodeMessage(everything)
    encoded?.rewind()
    val decoded = codec.decodeMessage(encoded)
    assertEquals(everything, decoded)
  }

  private val correctList = listOf<Any?>("a", 2, "three")
  private val matchingList = correctList.toMutableList()
  private val differentList = listOf<Any?>("a", 2, "three", 4.0)

  private val correctMap = mapOf<Any, Any?>("a" to 1, "b" to 2, "c" to "three")
  private val matchingMap = correctMap.toMap()
  private val differentKeyMap = mapOf<Any, Any?>("a" to 1, "b" to 2, "d" to "three")
  private val differentValueMap = mapOf<Any, Any?>("a" to 1, "b" to 2, "c" to "five")

  private val correctListInMap = mapOf<Any, Any?>("a" to 1, "b" to 2, "c" to correctList)
  private val matchingListInMap = mapOf<Any, Any?>("a" to 1, "b" to 2, "c" to matchingList)
  private val differentListInMap = mapOf<Any, Any?>("a" to 1, "b" to 2, "c" to differentList)

  private val correctMapInList = listOf<Any?>("a", 2, correctMap)
  private val matchingMapInList = listOf<Any?>("a", 2, matchingMap)
  private val differentKeyMapInList = listOf<Any?>("a", 2, differentKeyMap)
  private val differentValueMapInList = listOf<Any?>("a", 2, differentValueMap)

  @Test
  fun `equality method correctly checks deep equality`() {
    val generic = AllNullableTypes(list = correctList, map = correctMap)
    val identical = generic.copy()
    assertEquals(generic, identical)
  }

  @Test
  fun `equality method correctly identifies non-matching classes`() {
    val generic = AllNullableTypes(list = correctList, map = correctMap)
    val allNull = AllNullableTypes()
    assertNotEquals(allNull, generic)
  }

  @Test
  fun `equality method correctly identifies non-matching lists in classes`() {
    val withList = AllNullableTypes(list = correctList)
    val withDifferentList = AllNullableTypes(list = differentList)
    assertNotEquals(withList, withDifferentList)
  }

  @Test
  fun `equality method correctly identifies matching -but unique- lists in classes`() {
    val withList = AllNullableTypes(list = correctList)
    val withDifferentList = AllNullableTypes(list = matchingList)
    assertEquals(withList, withDifferentList)
  }

  @Test
  fun `equality method correctly identifies non-matching keys in maps in classes`() {
    val withMap = AllNullableTypes(map = correctMap)
    val withDifferentMap = AllNullableTypes(map = differentKeyMap)
    assertNotEquals(withMap, withDifferentMap)
  }

  @Test
  fun `equality method correctly identifies non-matching values in maps in classes`() {
    val withMap = AllNullableTypes(map = correctMap)
    val withDifferentMap = AllNullableTypes(map = differentValueMap)
    assertNotEquals(withMap, withDifferentMap)
  }

  @Test
  fun `equality method correctly identifies matching -but unique- maps in classes`() {
    val withMap = AllNullableTypes(map = correctMap)
    val withDifferentMap = AllNullableTypes(map = matchingMap)
    assertEquals(withMap, withDifferentMap)
  }

  @Test
  fun `equality method correctly identifies non-matching lists nested in maps in classes`() {
    val withListInMap = AllNullableTypes(map = correctListInMap)
    val withDifferentListInMap = AllNullableTypes(map = differentListInMap)
    assertNotEquals(withListInMap, withDifferentListInMap)
  }

  @Test
  fun `equality method correctly identifies matching -but unique- lists nested in maps in classes`() {
    val withListInMap = AllNullableTypes(map = correctListInMap)
    val withDifferentListInMap = AllNullableTypes(map = matchingListInMap)
    assertEquals(withListInMap, withDifferentListInMap)
  }

  @Test
  fun `equality method correctly identifies non-matching keys in maps nested in lists in classes`() {
    val withMapInList = AllNullableTypes(list = correctMapInList)
    val withDifferentMapInList = AllNullableTypes(list = differentKeyMapInList)
    assertNotEquals(withMapInList, withDifferentMapInList)
  }

  @Test
  fun `equality method correctly identifies non-matching values in maps nested in lists in classes`() {
    val withMapInList = AllNullableTypes(list = correctMapInList)
    val withDifferentMapInList = AllNullableTypes(list = differentValueMapInList)
    assertNotEquals(withMapInList, withDifferentMapInList)
  }

  @Test
  fun `equality method correctly identifies matching -but unique- maps nested in lists in classes`() {
    val withMapInList = AllNullableTypes(list = correctMapInList)
    val withDifferentMapInList = AllNullableTypes(list = matchingMapInList)
    assertEquals(withMapInList, withDifferentMapInList)
  }
}
