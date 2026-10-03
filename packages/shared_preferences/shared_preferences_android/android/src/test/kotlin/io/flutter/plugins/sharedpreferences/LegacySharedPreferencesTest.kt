// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.sharedpreferences

import android.content.Context
import android.content.SharedPreferences
import android.content.SharedPreferences.OnSharedPreferenceChangeListener
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.mockito.ArgumentMatchers
import org.mockito.Mockito

class LegacySharedPreferencesTest {
  private lateinit var plugin: LegacySharedPreferencesPlugin

  private lateinit var mockMessenger: BinaryMessenger

  private lateinit var flutterPluginBinding: FlutterPluginBinding

  @Before
  fun before() {
    val context = Mockito.mock(Context::class.java)
    val sharedPrefs: SharedPreferences = FakeSharedPreferences()

    mockMessenger = Mockito.mock(BinaryMessenger::class.java)
    flutterPluginBinding = Mockito.mock(FlutterPluginBinding::class.java)

    Mockito.`when`(flutterPluginBinding.binaryMessenger).thenReturn(mockMessenger)
    Mockito.`when`(flutterPluginBinding.applicationContext).thenReturn(context)
    Mockito.`when`(
            context.getSharedPreferences(ArgumentMatchers.anyString(), ArgumentMatchers.anyInt()))
        .thenReturn(sharedPrefs)

    plugin = LegacySharedPreferencesPlugin(ListEncoder())
    plugin.onAttachedToEngine(flutterPluginBinding)
  }

  @Test
  fun getAll() {
    assertEquals(0, plugin.getAll("", null).size)

    addData()

    val flutterData: Map<String, Any> = plugin.getAll("flutter.", null)

    assertEquals(5, flutterData.size)
    assertEquals("Kotlin", flutterData["flutter.Language"])
    assertEquals(0L, flutterData["flutter.Counter"])
    assertEquals(3.14, flutterData["flutter.Pie"])
    assertEquals(listOf("Flutter", "Dart").toString(), flutterData["flutter.Names"])
    assertEquals(false, flutterData["flutter.NewToFlutter"])

    val allData: Map<String, Any> = plugin.getAll("", null)

    assertEquals(data, allData)
  }

  @Test
  fun allowList() {
    assertEquals(0, plugin.getAll("", null).size)

    addData()

    val allowList = listOf("flutter.Language")

    var allData: Map<String, Any> = plugin.getAll("flutter.", allowList)

    assertEquals(1, allData.size)
    assertEquals("Kotlin", allData["flutter.Language"])
    assertNull(allData["flutter.Counter"])

    allData = plugin.getAll("", allowList)

    assertEquals(1, allData.size)
    assertEquals("Kotlin", allData["flutter.Language"])
    assertNull(allData["flutter.Counter"])

    allData = plugin.getAll("prefix.", allowList)

    assertEquals(0, allData.size)
    assertNull(allData["flutter.Language"])
  }

  @Test
  fun setString() {
    val key = "language"
    val value = "Kotlin"
    plugin.setString(key, value)
    val flutterData: Map<String, Any> = plugin.getAll("", null)
    assertEquals(value, flutterData[key])
  }

  @Test
  fun setInt() {
    val key = "Counter"
    val value = 0L
    plugin.setInt(key, value)
    val flutterData: Map<String, Any> = plugin.getAll("", null)
    assertEquals(value, flutterData[key])
  }

  @Test
  fun setDouble() {
    val key = "Pie"
    val value = 3.14
    plugin.setDouble(key, value)
    val flutterData: Map<String, Any> = plugin.getAll("", null)
    assertEquals(value, flutterData[key])
  }

  @Test
  fun setEncodedStringListSetsAndGetsString() {
    val key = "Names"
    val value = listOf("Flutter", "Dart").toString()
    plugin.setEncodedStringList(key, value)
    val flutterData: Map<String, Any> = plugin.getAll("", null)
    assertEquals(value, flutterData[key])
  }

  @Test
  fun setBool() {
    val key = "NewToFlutter"
    val value = false
    plugin.setBool(key, value)
    val flutterData: Map<String, Any> = plugin.getAll("", null)
    assertEquals(value, flutterData[key])
  }

  @Test
  fun clearWithNoAllowList() {
    addData()

    assertEquals(15, plugin.getAll("", null).size)

    plugin.clear("flutter.", null)

    assertEquals(10, plugin.getAll("", null).size)
  }

  @Test
  fun clearWithAllowList() {
    addData()

    assertEquals(15, plugin.getAll("", null).size)

    plugin.clear("flutter.", listOf("flutter.Language"))

    assertEquals(14, plugin.getAll("", null).size)
  }

  @Test
  fun clearAll() {
    addData()

    assertEquals(15, plugin.getAll("", null).size)

    plugin.clear("", null)

    assertEquals(0, plugin.getAll("", null).size)
  }

  @Test
  fun testRemove() {
    val key = "NewToFlutter"
    val value = true
    plugin.setBool(key, value)
    assertTrue(plugin.getAll("", null).containsKey(key))
    plugin.remove(key)
    assertFalse(plugin.getAll("", null).containsKey(key))
  }

  private fun addData() {
    plugin.setString("Language", "Kotlin")
    plugin.setInt("Counter", 0L)
    plugin.setDouble("Pie", 3.14)
    plugin.setEncodedStringList("Names", listOf("Flutter", "Dart").toString())
    plugin.setBool("NewToFlutter", false)
    plugin.setString("flutter.Language", "Kotlin")
    plugin.setInt("flutter.Counter", 0L)
    plugin.setDouble("flutter.Pie", 3.14)
    plugin.setEncodedStringList("flutter.Names", listOf("Flutter", "Dart").toString())
    plugin.setBool("flutter.NewToFlutter", false)
    plugin.setString("prefix.Language", "Kotlin")
    plugin.setInt("prefix.Counter", 0L)
    plugin.setDouble("prefix.Pie", 3.14)
    plugin.setEncodedStringList("prefix.Names", listOf("Flutter", "Dart").toString())
    plugin.setBool("prefix.NewToFlutter", false)
  }

  /** A dummy implementation for tests for use with FakeSharedPreferences */
  private class FakeSharedPreferencesEditor
  constructor(private val sharedPrefData: MutableMap<String, Any?>) : SharedPreferences.Editor {
    override fun putString(key: String, value: String?): SharedPreferences.Editor {
      sharedPrefData[key] = value
      return this
    }

    override fun putStringSet(key: String, values: Set<String?>?): SharedPreferences.Editor {
      sharedPrefData[key] = values
      return this
    }

    override fun putBoolean(key: String, value: Boolean): SharedPreferences.Editor {
      sharedPrefData[key] = value
      return this
    }

    override fun putInt(key: String, value: Int): SharedPreferences.Editor {
      sharedPrefData[key] = value
      return this
    }

    override fun putLong(key: String, value: Long): SharedPreferences.Editor {
      sharedPrefData[key] = value
      return this
    }

    override fun putFloat(key: String, value: Float): SharedPreferences.Editor {
      sharedPrefData[key] = value
      return this
    }

    override fun remove(key: String): SharedPreferences.Editor {
      sharedPrefData.remove(key)
      return this
    }

    override fun commit(): Boolean {
      return true
    }

    override fun apply() {
      throw UnsupportedOperationException("This method is not implemented for testing")
    }

    override fun clear(): SharedPreferences.Editor {
      throw UnsupportedOperationException("This method is not implemented for testing")
    }
  }

  /** A dummy implementation of SharedPreferences for tests that store values in memory. */
  private class FakeSharedPreferences : SharedPreferences {
    val sharedPrefData = mutableMapOf<String, Any?>()

    override fun getAll(): Map<String, Any?> {
      return sharedPrefData
    }

    override fun edit(): SharedPreferences.Editor {
      return FakeSharedPreferencesEditor(sharedPrefData)
    }

    // All methods below are not implemented.
    override fun contains(key: String): Boolean {
      throw UnsupportedOperationException("This method is not implemented for testing")
    }

    override fun getBoolean(key: String, defValue: Boolean): Boolean {
      throw UnsupportedOperationException("This method is not implemented for testing")
    }

    override fun getFloat(key: String, defValue: Float): Float {
      throw UnsupportedOperationException("This method is not implemented for testing")
    }

    override fun getInt(key: String, defValue: Int): Int {
      throw UnsupportedOperationException("This method is not implemented for testing")
    }

    override fun getLong(key: String, defValue: Long): Long {
      throw UnsupportedOperationException("This method is not implemented for testing")
    }

    override fun getString(key: String, defValue: String?): String {
      throw UnsupportedOperationException("This method is not implemented for testing")
    }

    override fun getStringSet(key: String, defValues: Set<String?>?): Set<String?> {
      throw UnsupportedOperationException("This method is not implemented for testing")
    }

    override fun registerOnSharedPreferenceChangeListener(
        listener: OnSharedPreferenceChangeListener
    ) {
      throw UnsupportedOperationException("This method is not implemented for testing")
    }

    override fun unregisterOnSharedPreferenceChangeListener(
        listener: OnSharedPreferenceChangeListener
    ) {
      throw UnsupportedOperationException("This method is not implemented for testing")
    }
  }

  /** A dummy implementation of SharedPreferencesListEncoder for tests that store List<String>. */
  internal class ListEncoder : SharedPreferencesListEncoder {
    override fun encode(list: List<String>): String {
      return list.joinToString(separator = ";-;")
    }

    override fun decode(listString: String): List<String> {
      return listString.split(";-;")
    }
  }

  companion object {
    private val data =
        mapOf<String, Any>(
            "Language" to "Kotlin",
            "Counter" to 0L,
            "Pie" to 3.14,
            "Names" to listOf("Flutter", "Dart").toString(),
            "NewToFlutter" to false,
            "flutter.Language" to "Kotlin",
            "flutter.Counter" to 0L,
            "flutter.Pie" to 3.14,
            "flutter.Names" to listOf("Flutter", "Dart").toString(),
            "flutter.NewToFlutter" to false,
            "prefix.Language" to "Kotlin",
            "prefix.Counter" to 0L,
            "prefix.Pie" to 3.14,
            "prefix.Names" to listOf("Flutter", "Dart").toString(),
            "prefix.NewToFlutter" to false)
  }
}
