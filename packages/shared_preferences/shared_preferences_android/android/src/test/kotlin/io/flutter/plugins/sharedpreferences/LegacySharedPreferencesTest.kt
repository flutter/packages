// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.sharedpreferences

import android.content.Context
import android.content.SharedPreferences
import android.content.SharedPreferences.OnSharedPreferenceChangeListener
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import org.mockito.ArgumentMatchers
import org.mockito.Mock
import org.mockito.Mockito

class LegacySharedPreferencesTest {
  lateinit var plugin: LegacySharedPreferencesPlugin

  @Mock lateinit var mockMessenger: BinaryMessenger

  @Mock lateinit var flutterPluginBinding: FlutterPluginBinding

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
    Assert.assertEquals(0, plugin.getAll("", null).size.toLong())

    addData()

    val flutterData: Map<String, Any> = plugin.getAll("flutter.", null)

    Assert.assertEquals(5, flutterData.size.toLong())
    Assert.assertEquals("Java", flutterData["flutter.Language"])
    Assert.assertEquals(0L, flutterData["flutter.Counter"])
    Assert.assertEquals(3.14, flutterData["flutter.Pie"])
    Assert.assertEquals(flutterData["flutter.Names"], listOf<String?>("Flutter", "Dart").toString())
    Assert.assertEquals(false, flutterData["flutter.NewToFlutter"])

    val allData: Map<String, Any> = plugin.getAll("", null)

    Assert.assertEquals(data, allData)
  }

  @Test
  fun allowList() {
    Assert.assertEquals(0, plugin.getAll("", null).size.toLong())

    addData()

    val allowList = listOf("flutter.Language")

    var allData: Map<String, Any> = plugin.getAll("flutter.", allowList)

    Assert.assertEquals(1, allData.size.toLong())
    Assert.assertEquals("Java", allData["flutter.Language"])
    Assert.assertNull(allData["flutter.Counter"])

    allData = plugin.getAll("", allowList)

    Assert.assertEquals(1, allData.size.toLong())
    Assert.assertEquals("Java", allData["flutter.Language"])
    Assert.assertNull(allData["flutter.Counter"])

    allData = plugin.getAll("prefix.", allowList)

    Assert.assertEquals(0, allData.size.toLong())
    Assert.assertNull(allData["flutter.Language"])
  }

  @Test
  fun setString() {
    val key = "language"
    val value = "Java"
    plugin.setString(key, value)
    val flutterData: Map<String, Any> = plugin.getAll("", null)
    Assert.assertEquals(value, flutterData[key])
  }

  @Test
  fun setInt() {
    val key = "Counter"
    val value = 0L
    plugin.setInt(key, value)
    val flutterData: Map<String, Any> = plugin.getAll("", null)
    Assert.assertEquals(value, flutterData[key])
  }

  @Test
  fun setDouble() {
    val key = "Pie"
    val value = 3.14
    plugin.setDouble(key, value)
    val flutterData: Map<String, Any> = plugin.getAll("", null)
    Assert.assertEquals(value, flutterData[key])
  }

  @Test
  fun setEncodedStringListSetsAndGetsString() {
    val key = "Names"
    val value = listOf<String?>("Flutter", "Dart").toString()
    plugin.setEncodedStringList(key, value)
    val flutterData: Map<String, Any> = plugin.getAll("", null)
    Assert.assertEquals(flutterData[key], value)
  }

  @Test
  fun setBool() {
    val key = "NewToFlutter"
    val value = false
    plugin.setBool(key, value)
    val flutterData: Map<String, Any> = plugin.getAll("", null)
    Assert.assertEquals(value, flutterData[key])
  }

  @Test
  fun clearWithNoAllowList() {
    addData()

    Assert.assertEquals(15, plugin.getAll("", null).size.toLong())

    plugin.clear("flutter.", null)

    Assert.assertEquals(10, plugin.getAll("", null).size.toLong())
  }

  @Test
  fun clearWithAllowList() {
    addData()

    Assert.assertEquals(15, plugin.getAll("", null).size.toLong())

    plugin.clear("flutter.", listOf("flutter.Language"))

    Assert.assertEquals(14, plugin.getAll("", null).size.toLong())
  }

  @Test
  fun clearAll() {
    addData()

    Assert.assertEquals(15, plugin.getAll("", null).size.toLong())

    plugin.clear("", null)

    Assert.assertEquals(0, plugin.getAll("", null).size.toLong())
  }

  @Test
  fun testRemove() {
    val key = "NewToFlutter"
    val value = true
    plugin.setBool(key, value)
    assert(plugin.getAll("", null).containsKey(key))
    plugin.remove(key)
    Assert.assertFalse(plugin.getAll("", null).containsKey(key))
  }

  private fun addData() {
    plugin.setString("Language", "Java")
    plugin.setInt("Counter", 0L)
    plugin.setDouble("Pie", 3.14)
    plugin.setEncodedStringList("Names", listOf<String?>("Flutter", "Dart").toString())
    plugin.setBool("NewToFlutter", false)
    plugin.setString("flutter.Language", "Java")
    plugin.setInt("flutter.Counter", 0L)
    plugin.setDouble("flutter.Pie", 3.14)
    plugin.setEncodedStringList("flutter.Names", listOf<String?>("Flutter", "Dart").toString())
    plugin.setBool("flutter.NewToFlutter", false)
    plugin.setString("prefix.Language", "Java")
    plugin.setInt("prefix.Counter", 0L)
    plugin.setDouble("prefix.Pie", 3.14)
    plugin.setEncodedStringList("prefix.Names", listOf<String?>("Flutter", "Dart").toString())
    plugin.setBool("prefix.NewToFlutter", false)
  }

  /** A dummy implementation for tests for use with FakeSharedPreferences */
  class FakeSharedPreferencesEditor
  internal constructor(private val sharedPrefData: MutableMap<String, Any?>) :
      SharedPreferences.Editor {
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
    var sharedPrefData: MutableMap<String, Any?> = HashMap()

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

  /**
   * A dummy implementation of SharedPreferencesListEncoder for tests that store List<String>.
   * </String>
   */
  internal class ListEncoder : SharedPreferencesListEncoder {
    override fun encode(list: List<String>): String {
      return list.joinToString(separator = ";-;")
    }

    override fun decode(listString: String): List<String> {
      return listString.split(";-;")
    }
  }

  companion object {
    private val data: MutableMap<String?, Any?> = HashMap()

    init {
      data["Language"] = "Java"
      data["Counter"] = 0L
      data["Pie"] = 3.14
      data["Names"] = listOf("Flutter", "Dart").toString()
      data["NewToFlutter"] = false
      data["flutter.Language"] = "Java"
      data["flutter.Counter"] = 0L
      data["flutter.Pie"] = 3.14
      data["flutter.Names"] = listOf("Flutter", "Dart").toString()
      data["flutter.NewToFlutter"] = false
      data["prefix.Language"] = "Java"
      data["prefix.Counter"] = 0L
      data["prefix.Pie"] = 3.14
      data["prefix.Names"] = listOf("Flutter", "Dart").toString()
      data["prefix.NewToFlutter"] = false
    }
  }
}
