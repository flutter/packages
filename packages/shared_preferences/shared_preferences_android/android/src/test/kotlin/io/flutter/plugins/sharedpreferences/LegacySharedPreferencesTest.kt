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
import java.lang.String
import java.util.Arrays
import kotlin.Any
import kotlin.Boolean
import kotlin.Float
import kotlin.Int
import kotlin.Long
import kotlin.UnsupportedOperationException
import kotlin.assert
import kotlin.collections.HashMap
import kotlin.collections.MutableList
import kotlin.collections.MutableMap
import kotlin.collections.MutableSet
import kotlin.collections.dropLastWhile
import kotlin.collections.get
import kotlin.collections.mutableListOf
import kotlin.collections.toTypedArray

class LegacySharedPreferencesTest {
    lateinit var plugin: LegacySharedPreferencesPlugin

    @Mock
    lateinit var mockMessenger: BinaryMessenger

    @Mock
    lateinit var flutterPluginBinding: FlutterPluginBinding

    @Before
    fun before() {
        val context = Mockito.mock<Context>(Context::class.java)
        val sharedPrefs: SharedPreferences = FakeSharedPreferences()

        mockMessenger = Mockito.mock<BinaryMessenger?>(BinaryMessenger::class.java)
        flutterPluginBinding = Mockito.mock<FlutterPluginBinding>(FlutterPluginBinding::class.java)

        Mockito.`when`<BinaryMessenger?>(flutterPluginBinding.getBinaryMessenger())
            .thenReturn(mockMessenger)
        Mockito.`when`<Context?>(flutterPluginBinding.getApplicationContext()).thenReturn(context)
        Mockito.`when`<SharedPreferences?>(
            context.getSharedPreferences(
                ArgumentMatchers.anyString(),
                ArgumentMatchers.anyInt()
            )
        ).thenReturn(sharedPrefs)

        plugin = LegacySharedPreferencesPlugin(ListEncoder())
        plugin.onAttachedToEngine(flutterPluginBinding)
    }

    @Test
    fun getAll() {
        Assert.assertEquals(0, plugin.getAll("", null).size.toLong())

        addData()

        val flutterData: MutableMap<String?, Any?> = plugin.getAll("flutter.", null)

        Assert.assertEquals(5, flutterData.size.toLong())
        Assert.assertEquals("Java", flutterData.get("flutter.Language"))
        Assert.assertEquals(0L, flutterData.get("flutter.Counter"))
        Assert.assertEquals(3.14, flutterData.get("flutter.Pie"))
        Assert.assertEquals(
            flutterData.get("flutter.Names"),
            mutableListOf<String?>("Flutter", "Dart").toString()
        )
        Assert.assertEquals(false, flutterData.get("flutter.NewToFlutter"))

        val allData: MutableMap<String?, Any?> = plugin.getAll("", null)

        Assert.assertEquals(data, allData)
    }

    @Test
    fun allowList() {
        Assert.assertEquals(0, plugin.getAll("", null).size.toLong())

        addData()

        val allowList = mutableListOf<String?>("flutter.Language")

        var allData: MutableMap<String?, Any?> = plugin.getAll("flutter.", allowList)

        Assert.assertEquals(1, allData.size.toLong())
        Assert.assertEquals("Java", allData.get("flutter.Language"))
        Assert.assertNull(allData.get("flutter.Counter"))

        allData = plugin.getAll("", allowList)

        Assert.assertEquals(1, allData.size.toLong())
        Assert.assertEquals("Java", allData.get("flutter.Language"))
        Assert.assertNull(allData.get("flutter.Counter"))

        allData = plugin.getAll("prefix.", allowList)

        Assert.assertEquals(0, allData.size.toLong())
        Assert.assertNull(allData.get("flutter.Language"))
    }

    @Test
    fun setString() {
        val key = "language"
        val value = "Java"
        plugin.setString(key, value)
        val flutterData: MutableMap<String?, Any?> = plugin.getAll("", null)
        Assert.assertEquals(value, flutterData.get(key))
    }

    @Test
    fun setInt() {
        val key = "Counter"
        val value = 0L
        plugin.setInt(key, value)
        val flutterData: MutableMap<String?, Any?> = plugin.getAll("", null)
        Assert.assertEquals(value, flutterData.get(key))
    }

    @Test
    fun setDouble() {
        val key = "Pie"
        val value = 3.14
        plugin.setDouble(key, value)
        val flutterData: MutableMap<String?, Any?> = plugin.getAll("", null)
        Assert.assertEquals(value, flutterData.get(key))
    }

    @Test
    fun setEncodedStringListSetsAndGetsString() {
        val key = "Names"
        val value = mutableListOf<String?>("Flutter", "Dart").toString()
        plugin.setEncodedStringList(key, value)
        val flutterData: MutableMap<String?, Any?> = plugin.getAll("", null)
        Assert.assertEquals(flutterData.get(key), value)
    }

    @Test
    fun setBool() {
        val key = "NewToFlutter"
        val value = false
        plugin.setBool(key, value)
        val flutterData: MutableMap<String?, Any?> = plugin.getAll("", null)
        Assert.assertEquals(value, flutterData.get(key))
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

        plugin.clear("flutter.", mutableListOf<String>("flutter.Language"))

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
        plugin.setEncodedStringList("Names", mutableListOf<String?>("Flutter", "Dart").toString())
        plugin.setBool("NewToFlutter", false)
        plugin.setString("flutter.Language", "Java")
        plugin.setInt("flutter.Counter", 0L)
        plugin.setDouble("flutter.Pie", 3.14)
        plugin.setEncodedStringList(
            "flutter.Names",
            mutableListOf<String?>("Flutter", "Dart").toString()
        )
        plugin.setBool("flutter.NewToFlutter", false)
        plugin.setString("prefix.Language", "Java")
        plugin.setInt("prefix.Counter", 0L)
        plugin.setDouble("prefix.Pie", 3.14)
        plugin.setEncodedStringList(
            "prefix.Names",
            mutableListOf<String?>("Flutter", "Dart").toString()
        )
        plugin.setBool("prefix.NewToFlutter", false)
    }

    /** A dummy implementation for tests for use with FakeSharedPreferences  */
    class FakeSharedPreferencesEditor internal constructor(private val sharedPrefData: MutableMap<String?, Any?>) :
        SharedPreferences.Editor {
        override fun putString(
            key: String, value: String?
        ): SharedPreferences.Editor {
            sharedPrefData.put(key, value)
            return this
        }

        override fun putStringSet(
            key: String, values: MutableSet<String?>?
        ): SharedPreferences.Editor {
            sharedPrefData.put(key, values)
            return this
        }

        override fun putBoolean(key: String, value: Boolean): SharedPreferences.Editor {
            sharedPrefData.put(key, value)
            return this
        }

        override fun putInt(key: String, value: Int): SharedPreferences.Editor {
            sharedPrefData.put(key, value)
            return this
        }

        override fun putLong(key: String, value: Long): SharedPreferences.Editor {
            sharedPrefData.put(key, value)
            return this
        }

        override fun putFloat(key: String, value: Float): SharedPreferences.Editor {
            sharedPrefData.put(key, value)
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

    /** A dummy implementation of SharedPreferences for tests that store values in memory.  */
    private class FakeSharedPreferences : SharedPreferences {
        var sharedPrefData: MutableMap<String?, Any?> = HashMap<String?, Any?>()

        override fun getAll(): MutableMap<String?, *> {
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

        override fun getStringSet(
            key: String,
            defValues: MutableSet<String?>?
        ): MutableSet<String?> {
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

    /** A dummy implementation of SharedPreferencesListEncoder for tests that store List<String>. </String> */
    internal class ListEncoder : SharedPreferencesListEncoder {
        override fun encode(list: MutableList<String?>): String {
            return String.join(";-;", list)
        }

        override fun decode(listString: kotlin.String): MutableList<kotlin.String?> {
            return Arrays.asList<kotlin.String?>(
                *listString.split(";-;".toRegex()).dropLastWhile { it.isEmpty() }.toTypedArray()
            )
        }
    }

    companion object {
        private val data: MutableMap<kotlin.String?, Any?> = HashMap<kotlin.String?, Any?>()

        init {
            data.put("Language", "Java")
            data.put("Counter", 0L)
            data.put("Pie", 3.14)
            data.put("Names", mutableListOf<kotlin.String?>("Flutter", "Dart").toString())
            data.put("NewToFlutter", false)
            data.put("flutter.Language", "Java")
            data.put("flutter.Counter", 0L)
            data.put("flutter.Pie", 3.14)
            data.put("flutter.Names", mutableListOf<kotlin.String?>("Flutter", "Dart").toString())
            data.put("flutter.NewToFlutter", false)
            data.put("prefix.Language", "Java")
            data.put("prefix.Counter", 0L)
            data.put("prefix.Pie", 3.14)
            data.put("prefix.Names", mutableListOf<kotlin.String?>("Flutter", "Dart").toString())
            data.put("prefix.NewToFlutter", false)
        }
    }
}
