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

  private fun pluginSetup(): SharedPreferencesPlugin {
    val testContext: Context = ApplicationProvider.getApplicationContext()

    val plugin = SharedPreferencesPlugin()
    val binaryMessenger = mockk<BinaryMessenger>()
    val flutterPluginBinding = mockk<FlutterPlugin.FlutterPluginBinding>()
    every { flutterPluginBinding.binaryMessenger } returns binaryMessenger
    every { flutterPluginBinding.applicationContext } returns testContext
    plugin.onAttachedToEngine(flutterPluginBinding)
    return plugin
  }

  @Test
  fun testSetAndGetBool() {
    val plugin = pluginSetup()
    plugin.setBool(boolKey, testBool, emptyOptions)
    Assert.assertEquals(plugin.getBool(boolKey, emptyOptions), testBool)
  }

  @Test
  fun testSetAndGetString() {
    val plugin = pluginSetup()
    plugin.setString(stringKey, testString, emptyOptions)
    Assert.assertEquals(plugin.getString(stringKey, emptyOptions), testString)
  }

  @Test
  fun testSetAndGetInt() {
    val plugin = pluginSetup()
    plugin.setInt(intKey, testInt, emptyOptions)
    Assert.assertEquals(plugin.getInt(intKey, emptyOptions), testInt)
  }

  @Test
  fun testSetAndGetDouble() {
    val plugin = pluginSetup()
    plugin.setDouble(doubleKey, testDouble, emptyOptions)
    Assert.assertEquals(plugin.getDouble(doubleKey, emptyOptions), testDouble)
  }

  @Test
  fun testSetAndGetStringList() {
    val plugin = pluginSetup()
    plugin.setStringList(listKey, testList, emptyOptions)
    Assert.assertEquals(plugin.getStringList(listKey, emptyOptions), testList)
  }

  @Test
  fun testGetKeys() {
    val plugin = pluginSetup()
    plugin.setBool(boolKey, testBool, emptyOptions)
    plugin.setString(stringKey, testString, emptyOptions)
    plugin.setInt(intKey, testInt, emptyOptions)
    plugin.setDouble(doubleKey, testDouble, emptyOptions)
    plugin.setStringList(listKey, testList, emptyOptions)
    val keyList = plugin.getKeys(listOf(boolKey, stringKey), emptyOptions)
    Assert.assertEquals(keyList.size, 2)
    Assert.assertTrue(keyList.contains(stringKey))
    Assert.assertTrue(keyList.contains(boolKey))
  }

  @Test
  fun testClear() {
    val plugin = pluginSetup()
    plugin.setBool(boolKey, testBool, emptyOptions)
    plugin.setString(stringKey, testString, emptyOptions)
    plugin.setInt(intKey, testInt, emptyOptions)
    plugin.setDouble(doubleKey, testDouble, emptyOptions)
    plugin.setStringList(listKey, testList, emptyOptions)

    plugin.clear(null, emptyOptions)

    Assert.assertNull(plugin.getBool(boolKey, emptyOptions))
    Assert.assertNull(plugin.getBool(stringKey, emptyOptions))
    Assert.assertNull(plugin.getBool(intKey, emptyOptions))
    Assert.assertNull(plugin.getBool(doubleKey, emptyOptions))
    Assert.assertNull(plugin.getBool(listKey, emptyOptions))
  }

  @Test
  fun testGetAll() {
    val plugin = pluginSetup()
    plugin.setBool(boolKey, testBool, emptyOptions)
    plugin.setString(stringKey, testString, emptyOptions)
    plugin.setInt(intKey, testInt, emptyOptions)
    plugin.setDouble(doubleKey, testDouble, emptyOptions)
    plugin.setStringList(listKey, testList, emptyOptions)

    val all = plugin.getAll(null, emptyOptions)

    Assert.assertEquals(all[boolKey], testBool)
    Assert.assertEquals(all[stringKey], testString)
    Assert.assertEquals(all[intKey], testInt)
    Assert.assertEquals(all[doubleKey], testDouble)
    Assert.assertEquals(all[listKey], testList)
  }

  @Test
  fun testClearWithAllowList() {
    val plugin = pluginSetup()
    plugin.setBool(boolKey, testBool, emptyOptions)
    plugin.setString(stringKey, testString, emptyOptions)
    plugin.setInt(intKey, testInt, emptyOptions)
    plugin.setDouble(doubleKey, testDouble, emptyOptions)
    plugin.setStringList(listKey, testList, emptyOptions)

    plugin.clear(listOf(boolKey, stringKey), emptyOptions)

    Assert.assertNull(plugin.getBool(boolKey, emptyOptions))
    Assert.assertNull(plugin.getString(stringKey, emptyOptions))
    Assert.assertNotNull(plugin.getInt(intKey, emptyOptions))
    Assert.assertNotNull(plugin.getDouble(doubleKey, emptyOptions))
    Assert.assertNotNull(plugin.getStringList(listKey, emptyOptions))
  }

  @Test
  fun testGetAllWithAllowList() {
    val plugin = pluginSetup()
    plugin.setBool(boolKey, testBool, emptyOptions)
    plugin.setString(stringKey, testString, emptyOptions)
    plugin.setInt(intKey, testInt, emptyOptions)
    plugin.setDouble(doubleKey, testDouble, emptyOptions)
    plugin.setStringList(listKey, testList, emptyOptions)

    val all = plugin.getAll(listOf(boolKey, stringKey), emptyOptions)

    Assert.assertEquals(all[boolKey], testBool)
    Assert.assertEquals(all[stringKey], testString)
    Assert.assertNull(all[intKey])
    Assert.assertNull(all[doubleKey])
    Assert.assertNull(all[listKey])
  }
}
