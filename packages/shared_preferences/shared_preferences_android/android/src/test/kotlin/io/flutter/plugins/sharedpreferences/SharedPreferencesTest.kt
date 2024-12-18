// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferences

import android.content.Context
import android.content.SharedPreferences
import android.util.Base64
import androidx.preference.PreferenceManager
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.mockk.every
import io.mockk.mockk
import java.io.ByteArrayOutputStream
import java.io.ObjectOutputStream
import org.junit.Assert
import org.junit.Assert.assertThrows
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

  private val dataStoreOptions = SharedPreferencesPigeonOptions(useDataStore = true)
  private val sharedPreferencesOptions = SharedPreferencesPigeonOptions(useDataStore = false)
  private val testContext: Context = ApplicationProvider.getApplicationContext()

  private fun pluginSetup(options: SharedPreferencesPigeonOptions): SharedPreferencesAsyncApi {
    val plugin = SharedPreferencesPlugin()
    val binaryMessenger = mockk<BinaryMessenger>()
    val flutterPluginBinding = mockk<FlutterPlugin.FlutterPluginBinding>()
    every { flutterPluginBinding.binaryMessenger } returns binaryMessenger
    every { flutterPluginBinding.applicationContext } returns testContext
    plugin.onAttachedToEngine(flutterPluginBinding)
    val backend =
        SharedPreferencesBackend(
            flutterPluginBinding.binaryMessenger, flutterPluginBinding.applicationContext)
    return if (options.useDataStore) {
      plugin
    } else {
      backend
    }
  }

  @Test
  fun testSetAndGetBoolWithDataStore() {
    val plugin = pluginSetup(dataStoreOptions)
    plugin.setBool(boolKey, testBool, dataStoreOptions)
    Assert.assertEquals(plugin.getBool(boolKey, dataStoreOptions), testBool)
  }

  @Test
  fun testSetAndGetStringWithDataStore() {
    val plugin = pluginSetup(dataStoreOptions)
    plugin.setString(stringKey, testString, dataStoreOptions)
    Assert.assertEquals(plugin.getString(stringKey, dataStoreOptions), testString)
  }

  @Test
  fun testSetAndGetIntWithDataStore() {
    val plugin = pluginSetup(dataStoreOptions)
    plugin.setInt(intKey, testInt, dataStoreOptions)
    Assert.assertEquals(plugin.getInt(intKey, dataStoreOptions), testInt)
  }

  @Test
  fun testSetAndGetDoubleWithDataStore() {
    val plugin = pluginSetup(dataStoreOptions)
    plugin.setDouble(doubleKey, testDouble, dataStoreOptions)
    Assert.assertEquals(plugin.getDouble(doubleKey, dataStoreOptions), testDouble)
  }

  @Test
  fun testSetAndGetStringListWithDataStore() {
    val plugin = pluginSetup(dataStoreOptions)
    plugin.setStringList(listKey, testList, dataStoreOptions)
    Assert.assertEquals(plugin.getStringList(listKey, dataStoreOptions), testList)
  }

  @Test
  fun testGetKeysWithDataStore() {
    val plugin = pluginSetup(dataStoreOptions)
    plugin.setBool(boolKey, testBool, dataStoreOptions)
    plugin.setString(stringKey, testString, dataStoreOptions)
    plugin.setInt(intKey, testInt, dataStoreOptions)
    plugin.setDouble(doubleKey, testDouble, dataStoreOptions)
    plugin.setStringList(listKey, testList, dataStoreOptions)
    val keyList = plugin.getKeys(listOf(boolKey, stringKey), dataStoreOptions)
    Assert.assertEquals(keyList.size, 2)
    Assert.assertTrue(keyList.contains(stringKey))
    Assert.assertTrue(keyList.contains(boolKey))
  }

  @Test
  fun testClearWithDataStore() {
    val plugin = pluginSetup(dataStoreOptions)
    plugin.setBool(boolKey, testBool, dataStoreOptions)
    plugin.setString(stringKey, testString, dataStoreOptions)
    plugin.setInt(intKey, testInt, dataStoreOptions)
    plugin.setDouble(doubleKey, testDouble, dataStoreOptions)
    plugin.setStringList(listKey, testList, dataStoreOptions)

    plugin.clear(null, dataStoreOptions)

    Assert.assertNull(plugin.getBool(boolKey, dataStoreOptions))
    Assert.assertNull(plugin.getBool(stringKey, dataStoreOptions))
    Assert.assertNull(plugin.getBool(intKey, dataStoreOptions))
    Assert.assertNull(plugin.getBool(doubleKey, dataStoreOptions))
    Assert.assertNull(plugin.getBool(listKey, dataStoreOptions))
  }

  @Test
  fun testGetAllWithDataStore() {
    val plugin = pluginSetup(dataStoreOptions)
    plugin.setBool(boolKey, testBool, dataStoreOptions)
    plugin.setString(stringKey, testString, dataStoreOptions)
    plugin.setInt(intKey, testInt, dataStoreOptions)
    plugin.setDouble(doubleKey, testDouble, dataStoreOptions)
    plugin.setStringList(listKey, testList, dataStoreOptions)

    val all = plugin.getAll(null, dataStoreOptions)

    Assert.assertEquals(all[boolKey], testBool)
    Assert.assertEquals(all[stringKey], testString)
    Assert.assertEquals(all[intKey], testInt)
    Assert.assertEquals(all[doubleKey], testDouble)
    Assert.assertEquals(all[listKey], testList)
  }

  @Test
  fun testClearWithAllowListWithDataStore() {
    val plugin = pluginSetup(dataStoreOptions)
    plugin.setBool(boolKey, testBool, dataStoreOptions)
    plugin.setString(stringKey, testString, dataStoreOptions)
    plugin.setInt(intKey, testInt, dataStoreOptions)
    plugin.setDouble(doubleKey, testDouble, dataStoreOptions)
    plugin.setStringList(listKey, testList, dataStoreOptions)

    plugin.clear(listOf(boolKey, stringKey), dataStoreOptions)

    Assert.assertNull(plugin.getBool(boolKey, dataStoreOptions))
    Assert.assertNull(plugin.getString(stringKey, dataStoreOptions))
    Assert.assertNotNull(plugin.getInt(intKey, dataStoreOptions))
    Assert.assertNotNull(plugin.getDouble(doubleKey, dataStoreOptions))
    Assert.assertNotNull(plugin.getStringList(listKey, dataStoreOptions))
  }

  @Test
  fun testGetAllWithAllowListWithDataStore() {
    val plugin = pluginSetup(dataStoreOptions)
    plugin.setBool(boolKey, testBool, dataStoreOptions)
    plugin.setString(stringKey, testString, dataStoreOptions)
    plugin.setInt(intKey, testInt, dataStoreOptions)
    plugin.setDouble(doubleKey, testDouble, dataStoreOptions)
    plugin.setStringList(listKey, testList, dataStoreOptions)

    val all = plugin.getAll(listOf(boolKey, stringKey), dataStoreOptions)

    Assert.assertEquals(all[boolKey], testBool)
    Assert.assertEquals(all[stringKey], testString)
    Assert.assertNull(all[intKey])
    Assert.assertNull(all[doubleKey])
    Assert.assertNull(all[listKey])
  }

  @Test
  fun testSetAndGetBoolWithSharedPreferences() {
    val plugin = pluginSetup(sharedPreferencesOptions)
    plugin.setBool(boolKey, testBool, sharedPreferencesOptions)
    Assert.assertEquals(plugin.getBool(boolKey, sharedPreferencesOptions), testBool)
  }

  @Test
  fun testSetAndGetStringWithSharedPreferences() {
    val plugin = pluginSetup(sharedPreferencesOptions)
    plugin.setString(stringKey, testString, sharedPreferencesOptions)
    Assert.assertEquals(plugin.getString(stringKey, sharedPreferencesOptions), testString)
  }

  @Test
  fun testSetAndGetIntWithSharedPreferences() {
    val plugin = pluginSetup(sharedPreferencesOptions)
    plugin.setInt(intKey, testInt, sharedPreferencesOptions)
    Assert.assertEquals(plugin.getInt(intKey, sharedPreferencesOptions), testInt)
  }

  @Test
  fun testSetAndGetDoubleWithSharedPreferences() {
    val plugin = pluginSetup(sharedPreferencesOptions)
    plugin.setDouble(doubleKey, testDouble, sharedPreferencesOptions)
    Assert.assertEquals(plugin.getDouble(doubleKey, sharedPreferencesOptions), testDouble)
  }

  @Test
  fun testSetAndGetStringListWithSharedPreferences() {
    val plugin = pluginSetup(sharedPreferencesOptions)
    plugin.setStringList(listKey, testList, sharedPreferencesOptions)
    Assert.assertEquals(plugin.getStringList(listKey, sharedPreferencesOptions), testList)
  }

  @Test
  fun testGetKeysWithSharedPreferences() {
    val plugin = pluginSetup(sharedPreferencesOptions)
    plugin.setBool(boolKey, testBool, sharedPreferencesOptions)
    plugin.setString(stringKey, testString, sharedPreferencesOptions)
    plugin.setInt(intKey, testInt, sharedPreferencesOptions)
    plugin.setDouble(doubleKey, testDouble, sharedPreferencesOptions)
    plugin.setStringList(listKey, testList, sharedPreferencesOptions)
    val keyList = plugin.getKeys(listOf(boolKey, stringKey), sharedPreferencesOptions)
    Assert.assertEquals(keyList.size, 2)
    Assert.assertTrue(keyList.contains(stringKey))
    Assert.assertTrue(keyList.contains(boolKey))
  }

  @Test
  fun testClearWithSharedPreferences() {
    val plugin = pluginSetup(sharedPreferencesOptions)
    plugin.setBool(boolKey, testBool, sharedPreferencesOptions)
    plugin.setString(stringKey, testString, sharedPreferencesOptions)
    plugin.setInt(intKey, testInt, sharedPreferencesOptions)
    plugin.setDouble(doubleKey, testDouble, sharedPreferencesOptions)
    plugin.setStringList(listKey, testList, sharedPreferencesOptions)

    plugin.clear(null, sharedPreferencesOptions)

    Assert.assertNull(plugin.getBool(boolKey, sharedPreferencesOptions))
    Assert.assertNull(plugin.getBool(stringKey, sharedPreferencesOptions))
    Assert.assertNull(plugin.getBool(intKey, sharedPreferencesOptions))
    Assert.assertNull(plugin.getBool(doubleKey, sharedPreferencesOptions))
    Assert.assertNull(plugin.getBool(listKey, sharedPreferencesOptions))
  }

  @Test
  fun testGetAllWithSharedPreferences() {
    val plugin = pluginSetup(sharedPreferencesOptions)
    plugin.setBool(boolKey, testBool, sharedPreferencesOptions)
    plugin.setString(stringKey, testString, sharedPreferencesOptions)
    plugin.setInt(intKey, testInt, sharedPreferencesOptions)
    plugin.setDouble(doubleKey, testDouble, sharedPreferencesOptions)
    plugin.setStringList(listKey, testList, sharedPreferencesOptions)

    val all = plugin.getAll(null, sharedPreferencesOptions)

    Assert.assertEquals(all[boolKey], testBool)
    Assert.assertEquals(all[stringKey], testString)
    Assert.assertEquals(all[intKey], testInt)
    Assert.assertEquals(all[doubleKey], testDouble)
    Assert.assertEquals(all[listKey], testList)
  }

  @Test
  fun testClearWithAllowListWithSharedPreferences() {
    val plugin = pluginSetup(sharedPreferencesOptions)
    plugin.setBool(boolKey, testBool, sharedPreferencesOptions)
    plugin.setString(stringKey, testString, sharedPreferencesOptions)
    plugin.setInt(intKey, testInt, sharedPreferencesOptions)
    plugin.setDouble(doubleKey, testDouble, sharedPreferencesOptions)
    plugin.setStringList(listKey, testList, sharedPreferencesOptions)

    plugin.clear(listOf(boolKey, stringKey), sharedPreferencesOptions)

    Assert.assertNull(plugin.getBool(boolKey, sharedPreferencesOptions))
    Assert.assertNull(plugin.getString(stringKey, sharedPreferencesOptions))
    Assert.assertNotNull(plugin.getInt(intKey, sharedPreferencesOptions))
    Assert.assertNotNull(plugin.getDouble(doubleKey, sharedPreferencesOptions))
    Assert.assertNotNull(plugin.getStringList(listKey, sharedPreferencesOptions))
  }

  @Test
  fun testGetAllWithAllowListWithSharedPreferences() {
    val plugin = pluginSetup(sharedPreferencesOptions)
    plugin.setBool(boolKey, testBool, sharedPreferencesOptions)
    plugin.setString(stringKey, testString, sharedPreferencesOptions)
    plugin.setInt(intKey, testInt, sharedPreferencesOptions)
    plugin.setDouble(doubleKey, testDouble, sharedPreferencesOptions)
    plugin.setStringList(listKey, testList, sharedPreferencesOptions)

    val all = plugin.getAll(listOf(boolKey, stringKey), sharedPreferencesOptions)

    Assert.assertEquals(all[boolKey], testBool)
    Assert.assertEquals(all[stringKey], testString)
    Assert.assertNull(all[intKey])
    Assert.assertNull(all[doubleKey])
    Assert.assertNull(all[listKey])
  }

  @Test
  fun testSharedPreferencesWithMultipleFiles() {
    val plugin = pluginSetup(sharedPreferencesOptions)
    val optionsWithNewFile =
        SharedPreferencesPigeonOptions(useDataStore = false, fileName = "test_file")
    plugin.setInt(intKey, 1, sharedPreferencesOptions)
    plugin.setInt(intKey, 2, optionsWithNewFile)
    Assert.assertEquals(plugin.getInt(intKey, sharedPreferencesOptions), 1L)
    Assert.assertEquals(plugin.getInt(intKey, optionsWithNewFile), 2L)
  }

  @Test
  fun testSharedPreferencesDefaultFile() {
    val defaultPreferences: SharedPreferences =
        PreferenceManager.getDefaultSharedPreferences(testContext)
    defaultPreferences.edit().putString(stringKey, testString).commit()
    val plugin = pluginSetup(sharedPreferencesOptions)
    Assert.assertEquals(plugin.getString(stringKey, sharedPreferencesOptions), testString)
  }

  @Test
  fun testUnexpectedClassDecodeThrows() {
    // Only String should be allowed in an encoded list.
    val badList = listOf(1, 2, 3)
    // Replicate the behavior of ListEncoder.encode, but with a non-List<String> list.
    val byteStream = ByteArrayOutputStream()
    val stream = ObjectOutputStream(byteStream)
    stream.writeObject(badList)
    stream.flush()
    val badPref = LIST_PREFIX + Base64.encodeToString(byteStream.toByteArray(), 0)

    val plugin = pluginSetup(dataStoreOptions)
    val badListKey = "badList"
    // Inject the bad pref as a string, as that is how string lists are stored internally.
    plugin.setString(badListKey, badPref, dataStoreOptions)
    assertThrows(ClassNotFoundException::class.java) {
      plugin.getStringList(badListKey, dataStoreOptions)
    }
  }
}
