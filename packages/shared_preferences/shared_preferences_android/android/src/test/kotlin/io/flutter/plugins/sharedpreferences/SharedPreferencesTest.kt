// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferences

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.mockk.every
import io.mockk.mockk
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
internal class SharedPreferencesTest {
  private val stringKey = "testString"

  private val boolKey = "testBool"

  private val intKey = "testInt"

  private val doubleKey = "testDouble"

  private val listKey = "testList"

  private val testString = "hello world"

  private val testBool = true

  private val testInt = 42L

  private val testDouble = 3.14159

  private val testList = listOf("foo", "bar")

  private val emptyOptions = SharedPreferencesPigeonOptions()

  private val plugin = SharedPreferencesPlugin()
  private val binaryMessenger = mockk<BinaryMessenger>()
  private val flutterPluginBinding = mockk<FlutterPlugin.FlutterPluginBinding>()
  private val testContext: Context = ApplicationProvider.getApplicationContext()

  @Before
  fun before() {
    every { flutterPluginBinding.binaryMessenger } returns binaryMessenger
    every { flutterPluginBinding.applicationContext } returns testContext

    plugin.onAttachedToEngine(flutterPluginBinding)
  }

  @Test
  fun testSetAndGet() {
    plugin.setBool(boolKey, testBool, emptyOptions)
    plugin.setString(stringKey, testString, emptyOptions)
    plugin.setInt(intKey, testInt, emptyOptions)
    plugin.setDouble(doubleKey, testDouble, emptyOptions)
    plugin.setStringList(listKey, testList, emptyOptions)
    Assert.assertEquals(plugin.getBool(boolKey, emptyOptions), testBool)
    Assert.assertEquals(plugin.getString(stringKey, emptyOptions), testString)
    Assert.assertEquals(plugin.getInt(intKey, emptyOptions), testInt)
    Assert.assertEquals(plugin.getDouble(doubleKey, emptyOptions), testDouble)
    Assert.assertEquals(plugin.getStringList(listKey, emptyOptions), testList)
  }

  // getKeys
  // clear
  // getAll

  // @Test
  // fun testNullValues() {
  //   val everything = AllNullableTypes()
  //   val binaryMessenger = mockk<BinaryMessenger>()
  //   val api = FlutterIntegrationCoreApi(binaryMessenger)

  //   every { binaryMessenger.send(any(), any(), any()) } answers
  //       {
  //         val codec = FlutterIntegrationCoreApi.codec
  //         val message = arg<ByteBuffer>(1)
  //         val reply = arg<BinaryMessenger.BinaryReply>(2)
  //         message.position(0)
  //         val args = codec.decodeMessage(message) as ArrayList<*>
  //         val replyData = codec.encodeMessage(args)
  //         replyData?.position(0)
  //         reply.reply(replyData)
  //       }

  //   var didCall = false
  //   api.echoAllNullableTypes(everything) {
  //     didCall = true
  //     val output =
  //         (it.getOrNull())?.let {
  //           assertNull(it.aNullableBool)
  //           assertNull(it.aNullableInt)
  //           assertNull(it.aNullableDouble)
  //           assertNull(it.aNullableString)
  //           assertNull(it.aNullableByteArray)
  //           assertNull(it.aNullable4ByteArray)
  //           assertNull(it.aNullable8ByteArray)
  //           assertNull(it.aNullableFloatArray)
  //           assertNull(it.aNullableList)
  //           assertNull(it.aNullableMap)
  //           assertNull(it.nullableMapWithObject)
  //         }
  //     assertNotNull(output)
  //   }

  //   assertTrue(didCall)
  // }

  // @Test
  // fun testHasValues() {
  //   val everything =
  //       AllNullableTypes(
  //           aNullableBool = false,
  //           aNullableInt = 1234L,
  //           aNullableDouble = 2.0,
  //           aNullableString = "hello",
  //           aNullableByteArray = byteArrayOf(1, 2, 3, 4),
  //           aNullable4ByteArray = intArrayOf(1, 2, 3, 4),
  //           aNullable8ByteArray = longArrayOf(1, 2, 3, 4),
  //           aNullableFloatArray = doubleArrayOf(0.5, 0.25, 1.5, 1.25),
  //           aNullableList = listOf(1, 2, 3),
  //           aNullableMap = mapOf("hello" to 1234),
  //           nullableMapWithObject = mapOf("hello" to 1234),
  //           aNullableObject = 0,
  //       )
  //   val binaryMessenger = mockk<BinaryMessenger>()
  //   val api = FlutterIntegrationCoreApi(binaryMessenger)

  //   every { binaryMessenger.send(any(), any(), any()) } answers
  //       {
  //         val codec = FlutterIntegrationCoreApi.codec
  //         val message = arg<ByteBuffer>(1)
  //         val reply = arg<BinaryMessenger.BinaryReply>(2)
  //         message.position(0)
  //         val args = codec.decodeMessage(message) as ArrayList<*>
  //         val replyData = codec.encodeMessage(args)
  //         replyData?.position(0)
  //         reply.reply(replyData)
  //       }

  //   var didCall = false
  //   api.echoAllNullableTypes(everything) {
  //     didCall = true
  //     compareAllNullableTypes(everything, it.getOrNull())
  //   }

  //   assertTrue(didCall)
  // }

  // @Test
  // fun testIntegerToLong() {
  //   val everything = AllNullableTypes(aNullableInt = 123L)
  //   val list = everything.toList()
  //   assertNotNull(list)
  //   assertNull(list.first())
  //   assertNotNull(list[1])
  //   assertTrue(list[1] == 123L)

  //   val list2 =
  //       listOf(
  //           null,
  //           123,
  //           null,
  //           null,
  //           null,
  //           null,
  //           null,
  //           null,
  //           null,
  //           null,
  //           null,
  //           null,
  //           null,
  //           null,
  //           null,
  //           null)
  //   val everything2 = AllNullableTypes.fromList(list2)

  //   assertEquals(everything.aNullableInt, everything2.aNullableInt)
  // }
}
