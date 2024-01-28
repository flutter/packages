// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferences

import io.flutter.embedding.engine.plugins.FlutterPlugin
import android.content.Context
import android.util.Base64
import android.util.Log
import androidx.datastore.core.DataStore
import androidx.annotation.VisibleForTesting
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.doublePreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.longPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import io.flutter.plugins.sharedpreferences.SharedPreferencesAsyncApi
import io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.sharedpreferences.SharedPreferencesListEncoder
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.runBlocking
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.ObjectInputStream
import java.io.ObjectOutputStream
import java.lang.Exception

const val TAG = "SharedPreferencesPlugin"
const val SHARED_PREFERENCES_NAME = "FlutterSharedPreferences"
const val LIST_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu"
const val DOUBLE_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu"

private val Context.sharedPreferencesDataStore: DataStore<Preferences> by preferencesDataStore(SHARED_PREFERENCES_NAME)

/// SharedPreferencesPlugin
class SharedPreferencesPlugin() : FlutterPlugin, SharedPreferencesAsyncApi {
  private lateinit var context: Context

  private var listEncoder = ListEncoder() as SharedPreferencesListEncoder

  @VisibleForTesting
  constructor (listEncoder: SharedPreferencesListEncoder) : this() {
    this.listEncoder = listEncoder
  }

  private fun setUp(messenger: BinaryMessenger, context: Context) {
    this.context = context
    try {
      SharedPreferencesAsyncApi.setUp(messenger, this)
    } catch (ex: Exception) {
      Log.e(TAG, "Received exception while setting up SharedPreferencesPlugin", ex)
    }
  }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    setUp(binding.binaryMessenger, binding.applicationContext)
    DeprecatedSharedPreferencesPlugin().onAttachedToEngine(binding);
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    SharedPreferencesAsyncApi.setUp(binding.binaryMessenger, null)
  }

  /** Adds property to data store of type bool. */
  override fun setBool(key: String, value: Boolean, options: SharedPreferencesPigeonOptions): Boolean {
    return runBlocking {dataStoreSetBool(key, value)}
  }

  private suspend fun dataStoreSetBool(key: String, value: Boolean): Boolean {
    val boolKey = booleanPreferencesKey(key)
    context.sharedPreferencesDataStore.edit { preferences ->
      preferences[boolKey] = value
    }
    return true
  }

  /** Adds property to data store of type String. */
  override fun setString(key: String, value: String, options: SharedPreferencesPigeonOptions): Boolean {
    return runBlocking {dataStoreSetString(key, value)}
  }

  private suspend fun dataStoreSetString(key: String, value: String): Boolean {
    val stringKey = stringPreferencesKey(key)
    context.sharedPreferencesDataStore.edit { preferences ->
      preferences[stringKey] = value
    }
    return true
  }

  /**
   * Adds property to data store of type int.
   * Converted to Long by pigeon, and saved as such.
   **/
  override fun setInt(key: String, value: Long, options: SharedPreferencesPigeonOptions): Boolean {
    return runBlocking {dataStoreSetInt(key, value)}
  }

  private suspend fun dataStoreSetInt(key: String, value: Long): Boolean {
    val intKey = longPreferencesKey(key)
    context.sharedPreferencesDataStore.edit { preferences ->
      preferences[intKey] = value
    }
    return true
  }

  /** Adds property to data store of type double. */
  override fun setDouble(key: String, value: Double, options: SharedPreferencesPigeonOptions): Boolean {
    return runBlocking {dataStoreSetDouble(key, value)}
  }

  private suspend fun dataStoreSetDouble(key: String, value: Double): Boolean {
    val doubleKey = doublePreferencesKey(key)
    context.sharedPreferencesDataStore.edit { preferences ->
      preferences[doubleKey] = value
    }
    return true
  }

  /** Adds property to data store of type List<String>. */
  override fun setStringList(key: String, value: List<String>, options: SharedPreferencesPigeonOptions): Boolean {
    val valueString = LIST_PREFIX + listEncoder.encode(value)
    return runBlocking {dataStoreSetString(key, valueString)}
  }

  /** Removes all properties from data store. */
  override fun clear(allowList: List<String>?, options: SharedPreferencesPigeonOptions): Boolean {
    runBlocking {clearFromDataStore(allowList)}
    return true
  }

  private suspend fun clearFromDataStore(allowList: List<String>?) {
     context.sharedPreferencesDataStore.edit { preferences ->
      allowList?.let { list ->
        list.forEach { key ->
          val preferencesKey = booleanPreferencesKey(key)
          preferences.remove(preferencesKey)
        }
      } ?: preferences.clear()


    }
  }

  /** Gets all properties from data store. */
  override fun getAll(allowList: List<String>?, options: SharedPreferencesPigeonOptions): Map<String, Any> {
    return getPrefs(allowList)
  }

  /** Gets int (as long) at [key] from data store. */
  override fun getInt(key: String, options: SharedPreferencesPigeonOptions): Long? {
    return runBlocking { getIntFromPreferences(key)}
  }

  private suspend fun getIntFromPreferences(key: String): Long? {
    val preferencesKey = longPreferencesKey(key)
    val preferenceFlow: Flow<Long?> = context.sharedPreferencesDataStore.data
      .map { preferences ->
        preferences[preferencesKey]
      }

    return preferenceFlow.first()
  }

  /** Gets bool at [key] from data store. */
  override fun getBool(key: String, options: SharedPreferencesPigeonOptions): Boolean? {
    return runBlocking { getBoolFromPreferences(key)}
  }

  private suspend fun getBoolFromPreferences(key: String): Boolean? {
    val preferencesKey = booleanPreferencesKey(key)
    val preferenceFlow: Flow<Boolean?> = context.sharedPreferencesDataStore.data
      .map { preferences ->
        preferences[preferencesKey]
      }

    return preferenceFlow.first()
  }

  /** Gets double at [key] from data store. */
  override fun getDouble(key: String, options: SharedPreferencesPigeonOptions): Double? {
    return runBlocking { getDoubleFromPreferences(key)}
  }

  private suspend fun getDoubleFromPreferences(key: String): Double? {
    val preferencesKey = doublePreferencesKey(key)
    val preferenceFlow: Flow<Double?> = context.sharedPreferencesDataStore.data
      .map { preferences ->
        transformPref(preferences[preferencesKey] as Any) as Double?
      }

    return preferenceFlow.first()
  }

  /** Gets String at [key] from data store. */
  override fun getString(key: String, options: SharedPreferencesPigeonOptions): String? {
    return runBlocking { getStringFromPreferences(key)}
  }

  private suspend fun getStringFromPreferences(key: String): String? {
    val preferencesKey = stringPreferencesKey(key)
    val preferenceFlow: Flow<String?> = context.sharedPreferencesDataStore.data
      .map { preferences ->
        preferences[preferencesKey]
      }

    return preferenceFlow.first()
  }

  /** Gets StringList at [key] from data store. */
  override fun getStringList(key: String, options: SharedPreferencesPigeonOptions): List<String> {
    return (transformPref(getString(key, options) as Any) as List<*>).filterIsInstance<String>()
  }

  /** Gets all properties from data store. */
  override fun getKeys(allowList: List<String>?, options: SharedPreferencesPigeonOptions): List<String> {
    val prefs = getPrefs(allowList)
    return prefs.keys.toList()
  }

  private fun getPrefs(allowList: List<String>?): Map<String, Any> {
    val allPrefs = context.sharedPreferencesDataStore.data
    val allowSet = allowList?.toSet()
    val filteredMap = mutableMapOf<String, Any>()
    allPrefs.map{
      it.asMap().map { entry ->
        if (preferencesFilter(entry, allowSet)) {
          filteredMap[entry.key.toString()] = transformPref(entry.value)
        }
      }
    }
    return filteredMap
  }

  /** 
   * Returns false for any preferences that are not included in [allowList].
   *
   * If no [allowList] is provided, instead returns false for any preferences
   * that are not supported by shared_preferences.
   */
  private fun preferencesFilter(
     entry: Map.Entry<Preferences.Key<*>, Any>, allowList: Set<String>?): Boolean {
    val key = entry.key.toString()
    val value = entry.value
    if (allowList == null) {
      return value is Boolean
          || value is Long
          || value is String
          || value is Double
    }

    return allowList.contains(key)
  }
  
  /** Transforms preferences that are stored as Strings back to original type. */
  private fun transformPref(value: Any): Any {
    if (value is String) {
      if (value.startsWith(LIST_PREFIX)) {
        return listEncoder.decode(value.substring(LIST_PREFIX.length))
      } else if (value.startsWith(DOUBLE_PREFIX)) {
        val doubleStr = value.substring(DOUBLE_PREFIX.length)
        return doubleStr.toDouble()
      }
    }
    return value
  }

  /** Class that provides tools for encoding and decoding List<String> to String and back. */
  class ListEncoder : SharedPreferencesListEncoder {
    override fun encode(list: List<String>): String {
      try {
        val byteStream = ByteArrayOutputStream()
        val stream = ObjectOutputStream(byteStream)
        stream.writeObject(list)
        stream.flush()
        return Base64.encodeToString(byteStream.toByteArray(), 0)
      } catch (e: RuntimeException) {
        throw RuntimeException(e)
      }
    }

    override fun decode(listString: String): List<String> {
      try {
        val byteArray = Base64.decode(listString, 0)
        val stream = ObjectInputStream(ByteArrayInputStream(byteArray))
        return (stream.readObject() as List<*>).filterIsInstance<String>()
      } catch (e: RuntimeException) {
        throw RuntimeException(e)
      }
    }
  }

}
