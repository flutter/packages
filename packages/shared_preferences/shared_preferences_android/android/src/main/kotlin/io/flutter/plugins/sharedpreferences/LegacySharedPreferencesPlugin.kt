// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.sharedpreferences

import android.annotation.SuppressLint
import android.content.Context
import android.content.SharedPreferences
import android.util.Base64
import android.util.Log
import androidx.annotation.VisibleForTesting
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.io.ObjectInputStream
import java.io.ObjectOutputStream
import java.math.BigInteger

/** LegacySharedPreferencesPlugin */
@SuppressLint("UseKtx")
class LegacySharedPreferencesPlugin
@VisibleForTesting
internal constructor(private val listEncoder: SharedPreferencesListEncoder) :
    FlutterPlugin, SharedPreferencesApi {
  private lateinit var preferences: SharedPreferences

  constructor() : this(ListEncoder())

  private fun setUp(messenger: BinaryMessenger, context: Context) {
    preferences = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
    try {
      SharedPreferencesApi.setUp(messenger, this)
    } catch (ex: Exception) {
      Log.e(TAG, "Received exception while setting up SharedPreferencesPlugin", ex)
    }
  }

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    setUp(binding.binaryMessenger, binding.applicationContext)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    SharedPreferencesApi.setUp(binding.binaryMessenger, null)
  }

  override fun setBool(key: String, value: Boolean): Boolean {
    return preferences.edit().putBoolean(key, value).commit()
  }

  override fun setString(key: String, value: String): Boolean {
    // TODO (tarrinneal): Move this string prefix checking logic to Dart code and make it an
    // Argument Error.
    if (value.startsWith(LIST_PREFIX) ||
        value.startsWith(BIG_INTEGER_PREFIX) ||
        value.startsWith(DOUBLE_PREFIX)) {
      throw RuntimeException(
          "StorageError: This string cannot be stored as it clashes with special identifier" +
              " prefixes")
    }
    return preferences.edit().putString(key, value).commit()
  }

  override fun setInt(key: String, value: Long): Boolean {
    return preferences.edit().putLong(key, value).commit()
  }

  override fun setDouble(key: String, value: Double): Boolean {
    val doubleValueStr = value.toString()
    return preferences.edit().putString(key, DOUBLE_PREFIX + doubleValueStr).commit()
  }

  override fun remove(key: String): Boolean {
    return preferences.edit().remove(key).commit()
  }

  override fun setEncodedStringList(key: String, value: String): Boolean {
    return preferences.edit().putString(key, value).commit()
  }

  // Deprecated, for testing purposes only.
  @Deprecated("")
  override fun setDeprecatedStringList(key: String, value: List<String>): Boolean {
    return preferences.edit().putString(key, LIST_PREFIX + listEncoder.encode(value)).commit()
  }

  override fun getAll(prefix: String, allowList: List<String>?): Map<String, Any> {
    return getAllPrefs(prefix, allowList?.toSet())
  }

  override fun clear(prefix: String, allowList: List<String>?): Boolean {
    val clearEditor = preferences.edit()
    val allowSet = allowList?.toSet()
    preferences.all.keys
        .filter { key -> key.startsWith(prefix) && (allowSet == null || allowSet.contains(key)) }
        .forEach { key -> clearEditor.remove(key) }
    return clearEditor.commit()
  }

  // Gets all shared preferences, filtered to only those set with the given prefix.
  // Optionally filtered also to only those items in
  private fun getAllPrefs(prefix: String, allowList: Set<String>?): Map<String, Any> {
    return buildMap {
      preferences.all.forEach { (key, value) ->
        if (key.startsWith(prefix) &&
            value != null &&
            (allowList == null || allowList.contains(key))) {
          put(key, transformPref(key, value))
        }
      }
    }
  }

  private fun transformPref(key: String, value: Any): Any {
    if (value is String) {
      if (value.startsWith(LIST_PREFIX)) {
        // The JSON-encoded lists use an extended prefix to distinguish them from
        // lists that are encoded on the platform.
        return if (value.startsWith(JSON_LIST_PREFIX)) {
          value
        } else {
          listEncoder.decode(value.substring(LIST_PREFIX.length))
        }
      } else if (value.startsWith(BIG_INTEGER_PREFIX)) {
        // TODO (tarrinneal): Remove all BigInt code.
        // https://github.com/flutter/flutter/issues/124420
        val encoded: String = value.substring(BIG_INTEGER_PREFIX.length)
        return BigInteger(encoded, Character.MAX_RADIX)
      } else if (value.startsWith(DOUBLE_PREFIX)) {
        val doubleStr: String = value.substring(DOUBLE_PREFIX.length)
        return doubleStr.toDouble()
      }
    } else if (value is Set<*>) {
      // TODO (tarrinneal): Remove Set code.
      // https://github.com/flutter/flutter/issues/124420

      // This only happens for previous usage of setStringSet. The app expects a list.
      @Suppress("UNCHECKED_CAST") val listValue = (value as Set<String>).toList()
      // Let's migrate the value too while we are at it.
      preferences
          .edit()
          .remove(key)
          .putString(key, LIST_PREFIX + listEncoder.encode(listValue))
          .apply()

      return listValue
    }
    return value
  }

  internal class ListEncoder : SharedPreferencesListEncoder {
    override fun encode(list: List<String>): String {
      try {
        val byteStream = ByteArrayOutputStream()
        val stream = ObjectOutputStream(byteStream)
        stream.writeObject(list)
        stream.flush()
        return Base64.encodeToString(byteStream.toByteArray(), 0)
      } catch (e: IOException) {
        throw RuntimeException(e)
      }
    }

    override fun decode(listString: String): List<String> {
      try {
        val stream: ObjectInputStream =
            StringListObjectInputStream(ByteArrayInputStream(Base64.decode(listString, 0)))
        @Suppress("UNCHECKED_CAST") return stream.readObject() as List<String>
      } catch (e: IOException) {
        throw RuntimeException(e)
      } catch (e: ClassNotFoundException) {
        throw RuntimeException(e)
      }
    }
  }

  companion object {
    private const val BIG_INTEGER_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy"
  }
}
