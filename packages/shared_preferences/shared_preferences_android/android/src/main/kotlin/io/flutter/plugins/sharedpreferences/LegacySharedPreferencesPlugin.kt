// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.sharedpreferences

import android.content.Context
import android.content.SharedPreferences
import android.util.Base64
import android.util.Log
import androidx.annotation.VisibleForTesting
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.sharedpreferences.SharedPreferencesApi.Companion.setUp
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.io.ObjectInputStream
import java.io.ObjectOutputStream
import java.math.BigInteger
import java.util.Objects

/** LegacySharedPreferencesPlugin  */
class LegacySharedPreferencesPlugin @VisibleForTesting internal constructor(
    private val listEncoder: SharedPreferencesListEncoder
) : FlutterPlugin, SharedPreferencesApi {
    private var preferences: SharedPreferences? = null

    constructor() : this(ListEncoder())

    private fun setUp(messenger: BinaryMessenger, context: Context) {
        preferences = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        try {
            setUp(messenger, this)
        } catch (ex: Exception) {
            Log.e(TAG, "Received exception while setting up SharedPreferencesPlugin", ex)
        }
    }

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        setUp(binding.getBinaryMessenger(), binding.getApplicationContext())
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        setUp(binding.getBinaryMessenger(), null)
    }

    override fun setBool(key: String, value: Boolean): Boolean {
        return preferences!!.edit().putBoolean(key, value).commit()
    }

    override fun setString(key: String, value: String): Boolean {
        // TODO (tarrinneal): Move this string prefix checking logic to dart code and make it an
        // Argument Error.
        if (value.startsWith(LIST_IDENTIFIER)
            || value.startsWith(BIG_INTEGER_PREFIX)
            || value.startsWith(DOUBLE_PREFIX)
        ) {
            throw RuntimeException(
                "StorageError: This string cannot be stored as it clashes with special identifier"
                        + " prefixes"
            )
        }
        return preferences!!.edit().putString(key, value).commit()
    }

    override fun setInt(key: String, value: Long): Boolean {
        return preferences!!.edit().putLong(key, value).commit()
    }

    override fun setDouble(key: String, value: Double): Boolean {
        val doubleValueStr = value.toString()
        return preferences!!.edit().putString(key, DOUBLE_PREFIX + doubleValueStr).commit()
    }

    override fun remove(key: String): Boolean {
        return preferences!!.edit().remove(key).commit()
    }

    @Throws(RuntimeException::class)
    override fun setEncodedStringList(key: String, value: String): Boolean {
        return preferences!!.edit().putString(key, value).commit()
    }

    // Deprecated, for testing purposes only.
    @Deprecated("")
    @Throws(RuntimeException::class)
    override fun setDeprecatedStringList(key: String, value: List<String>): Boolean {
        return preferences!!.edit().putString(key, LIST_IDENTIFIER + listEncoder.encode(value))
            .commit()
    }

    @Throws(RuntimeException::class)
    override fun getAll(
        prefix: String, allowList: List<String>?
    ): Map<String, Any> {
        val allowSet: Set<String>? =
            if (allowList == null) null else HashSet<String>(allowList)
        return getAllPrefs(prefix, allowSet)
    }

    @Throws(RuntimeException::class)
    override fun clear(prefix: String, allowList: List<String>?): Boolean {
        val clearEditor = preferences!!.edit()
        val allPrefs = preferences!!.getAll()
        val filteredPrefs = ArrayList<String?>()
        for (key in allPrefs.keys) {
            if (key.startsWith(prefix) && (allowList == null || allowList.contains(key))) {
                filteredPrefs.add(key)
            }
        }
        for (key in filteredPrefs) {
            clearEditor.remove(key)
        }
        return clearEditor.commit()
    }

    // Gets all shared preferences, filtered to only those set with the given prefix.
    // Optionally filtered also to only those items in the optional [allowList].
    @Throws(RuntimeException::class)
    private fun getAllPrefs(
        prefix: String, allowList: Set<String>?
    ): Map<String, Any> {
        val allPrefs = preferences!!.getAll()
        val filteredPrefs: Map<String, Any> = HashMap()
        for (key in allPrefs.keys) {
            if (key.startsWith(prefix) && (allowList == null || allowList.contains(key))) {
                filteredPrefs.put(
                    key,
                    transformPref(key, Objects.requireNonNull(allPrefs.get(key)))
                )
            }
        }

        return filteredPrefs
    }

    private fun transformPref(key: String, value: Any): Any {
        if (value is String) {
            val stringValue = value
            if (stringValue.startsWith(LIST_IDENTIFIER)) {
                // The JSON-encoded lists use an extended prefix to distinguish them from
                // lists that are encoded on the platform.
                if (stringValue.startsWith(JSON_LIST_IDENTIFIER)) {
                    return value
                } else {
                    return listEncoder.decode(stringValue.substring(LIST_IDENTIFIER.length))
                }
            } else if (stringValue.startsWith(BIG_INTEGER_PREFIX)) {
                // TODO (tarrinneal): Remove all BigInt code.
                // https://github.com/flutter/flutter/issues/124420
                val encoded: String = stringValue.substring(BIG_INTEGER_PREFIX.length)
                return BigInteger(encoded, Character.MAX_RADIX)
            } else if (stringValue.startsWith(DOUBLE_PREFIX)) {
                val doubleStr: String = stringValue.substring(DOUBLE_PREFIX.length)
                return doubleStr.toDouble()
            }
        } else if (value is Set<*>) {
            // TODO (tarrinneal): Remove Set code.
            // https://github.com/flutter/flutter/issues/124420

            // This only happens for previous usage of setStringSet. The app expects a list.
            val listValue: List<String> = ArrayList(value as Set<String>)
            // Let's migrate the value too while we are at it.
            preferences!!
                .edit()
                .remove(key)
                .putString(key, LIST_IDENTIFIER + listEncoder.encode(listValue))
                .apply()

            return listValue
        }
        return value
    }

    internal class ListEncoder : SharedPreferencesListEncoder {
        @Throws(RuntimeException::class)
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

        @Throws(RuntimeException::class)
        override fun decode(listString: String): List<String> {
            try {
                val stream: ObjectInputStream =
                    StringListObjectInputStream(ByteArrayInputStream(Base64.decode(listString, 0)))
                return stream.readObject() as List<String>
            } catch (e: IOException) {
                throw RuntimeException(e)
            } catch (e: ClassNotFoundException) {
                throw RuntimeException(e)
            }
        }
    }

    companion object {
        private const val TAG = "SharedPreferencesPlugin"
        private const val SHARED_PREFERENCES_NAME = "FlutterSharedPreferences"

        // All identifiers must match the SharedPreferencesPlugin.kt file, as well as the strings.dart
        // file.
        private const val LIST_IDENTIFIER = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu"

        // The symbol `!` was chosen as it cannot be created by the base 64 encoding used with
        // LIST_IDENTIFIER.
        private val JSON_LIST_IDENTIFIER: String = LIST_IDENTIFIER + "!"
        private const val BIG_INTEGER_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy"
        private const val DOUBLE_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu"
    }
}
