// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v16.0.5), do not edit directly.
// See also: https://pub.dev/packages/pigeon

package io.flutter.plugins.sharedpreferences

import android.util.Log
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.StandardMessageCodec
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

private fun wrapResult(result: Any?): List<Any?> {
  return listOf(result)
}

private fun wrapError(exception: Throwable): List<Any?> {
  if (exception is SharedPreferencesError) {
    return listOf(exception.code, exception.message, exception.details)
  } else {
    return listOf(
        exception.javaClass.simpleName,
        exception.toString(),
        "Cause: " + exception.cause + ", Stacktrace: " + Log.getStackTraceString(exception))
  }
}

/**
 * Error class for passing custom error details to Flutter via a thrown PlatformException.
 *
 * @property code The error code.
 * @property message The error message.
 * @property details The error details. Must be a datatype supported by the api codec.
 */
class SharedPreferencesError(
    val code: String,
    override val message: String? = null,
    val details: Any? = null
) : Throwable()

/** Generated class from Pigeon that represents data sent in messages. */
data class SharedPreferencesPigeonOptions(val fileKey: String? = null) {

  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): SharedPreferencesPigeonOptions {
      val fileKey = list[0] as String?
      return SharedPreferencesPigeonOptions(fileKey)
    }
  }

  fun toList(): List<Any?> {
    return listOf<Any?>(
        fileKey,
    )
  }
}

@Suppress("UNCHECKED_CAST")
private object SharedPreferencesAsyncApiCodec : StandardMessageCodec() {
  override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? {
    return when (type) {
      128.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          SharedPreferencesPigeonOptions.fromList(it)
        }
      }
      else -> super.readValueOfType(type, buffer)
    }
  }

  override fun writeValue(stream: ByteArrayOutputStream, value: Any?) {
    when (value) {
      is SharedPreferencesPigeonOptions -> {
        stream.write(128)
        writeValue(stream, value.toList())
      }
      else -> super.writeValue(stream, value)
    }
  }
}

/** Generated interface from Pigeon that represents a handler of messages from Flutter. */
interface SharedPreferencesAsyncApi {
  /** Adds property to shared preferences data set of type bool. */
  fun setBool(key: String, value: Boolean, options: SharedPreferencesPigeonOptions)
  /** Adds property to shared preferences data set of type String. */
  fun setString(key: String, value: String, options: SharedPreferencesPigeonOptions)
  /** Adds property to shared preferences data set of type int. */
  fun setInt(key: String, value: Long, options: SharedPreferencesPigeonOptions)
  /** Adds property to shared preferences data set of type double. */
  fun setDouble(key: String, value: Double, options: SharedPreferencesPigeonOptions)
  /** Adds property to shared preferences data set of type List<String>. */
  fun setStringList(key: String, value: List<String>, options: SharedPreferencesPigeonOptions)
  /** Gets individual String value stored with [key], if any. */
  fun getString(key: String, options: SharedPreferencesPigeonOptions): String?
  /** Gets individual void value stored with [key], if any. */
  fun getBool(key: String, options: SharedPreferencesPigeonOptions): Boolean?
  /** Gets individual double value stored with [key], if any. */
  fun getDouble(key: String, options: SharedPreferencesPigeonOptions): Double?
  /** Gets individual int value stored with [key], if any. */
  fun getInt(key: String, options: SharedPreferencesPigeonOptions): Long?
  /** Gets individual List<String> value stored with [key], if any. */
  fun getStringList(key: String, options: SharedPreferencesPigeonOptions): List<String>?
  /** Removes all properties from shared preferences data set with matching prefix. */
  fun clear(allowList: List<String>?, options: SharedPreferencesPigeonOptions)
  /** Gets all properties from shared preferences data set with matching prefix. */
  fun getAll(allowList: List<String>?, options: SharedPreferencesPigeonOptions): Map<String, Any>
  /** Gets all properties from shared preferences data set with matching prefix. */
  fun getKeys(allowList: List<String>?, options: SharedPreferencesPigeonOptions): List<String>

  companion object {
    /** The codec used by SharedPreferencesAsyncApi. */
    val codec: MessageCodec<Any?> by lazy { SharedPreferencesAsyncApiCodec }
    /**
     * Sets up an instance of `SharedPreferencesAsyncApi` to handle messages through the
     * `binaryMessenger`.
     */
    @Suppress("UNCHECKED_CAST")
    fun setUp(binaryMessenger: BinaryMessenger, api: SharedPreferencesAsyncApi?) {
      run {
        val taskQueue = binaryMessenger.makeBackgroundTaskQueue()
        val channel =
            BasicMessageChannel<Any?>(
                binaryMessenger,
                "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.setBool",
                codec,
                taskQueue)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val keyArg = args[0] as String
            val valueArg = args[1] as Boolean
            val optionsArg = args[2] as SharedPreferencesPigeonOptions
            var wrapped: List<Any?>
            try {
              api.setBool(keyArg, valueArg, optionsArg)
              wrapped = listOf<Any?>(null)
            } catch (exception: Throwable) {
              wrapped = wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val taskQueue = binaryMessenger.makeBackgroundTaskQueue()
        val channel =
            BasicMessageChannel<Any?>(
                binaryMessenger,
                "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.setString",
                codec,
                taskQueue)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val keyArg = args[0] as String
            val valueArg = args[1] as String
            val optionsArg = args[2] as SharedPreferencesPigeonOptions
            var wrapped: List<Any?>
            try {
              api.setString(keyArg, valueArg, optionsArg)
              wrapped = listOf<Any?>(null)
            } catch (exception: Throwable) {
              wrapped = wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val taskQueue = binaryMessenger.makeBackgroundTaskQueue()
        val channel =
            BasicMessageChannel<Any?>(
                binaryMessenger,
                "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.setInt",
                codec,
                taskQueue)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val keyArg = args[0] as String
            val valueArg = args[1].let { if (it is Int) it.toLong() else it as Long }
            val optionsArg = args[2] as SharedPreferencesPigeonOptions
            var wrapped: List<Any?>
            try {
              api.setInt(keyArg, valueArg, optionsArg)
              wrapped = listOf<Any?>(null)
            } catch (exception: Throwable) {
              wrapped = wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val taskQueue = binaryMessenger.makeBackgroundTaskQueue()
        val channel =
            BasicMessageChannel<Any?>(
                binaryMessenger,
                "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.setDouble",
                codec,
                taskQueue)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val keyArg = args[0] as String
            val valueArg = args[1] as Double
            val optionsArg = args[2] as SharedPreferencesPigeonOptions
            var wrapped: List<Any?>
            try {
              api.setDouble(keyArg, valueArg, optionsArg)
              wrapped = listOf<Any?>(null)
            } catch (exception: Throwable) {
              wrapped = wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val taskQueue = binaryMessenger.makeBackgroundTaskQueue()
        val channel =
            BasicMessageChannel<Any?>(
                binaryMessenger,
                "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.setStringList",
                codec,
                taskQueue)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val keyArg = args[0] as String
            val valueArg = args[1] as List<String>
            val optionsArg = args[2] as SharedPreferencesPigeonOptions
            var wrapped: List<Any?>
            try {
              api.setStringList(keyArg, valueArg, optionsArg)
              wrapped = listOf<Any?>(null)
            } catch (exception: Throwable) {
              wrapped = wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel =
            BasicMessageChannel<Any?>(
                binaryMessenger,
                "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.getString",
                codec)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val keyArg = args[0] as String
            val optionsArg = args[1] as SharedPreferencesPigeonOptions
            var wrapped: List<Any?>
            try {
              wrapped = listOf<Any?>(api.getString(keyArg, optionsArg))
            } catch (exception: Throwable) {
              wrapped = wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel =
            BasicMessageChannel<Any?>(
                binaryMessenger,
                "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.getBool",
                codec)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val keyArg = args[0] as String
            val optionsArg = args[1] as SharedPreferencesPigeonOptions
            var wrapped: List<Any?>
            try {
              wrapped = listOf<Any?>(api.getBool(keyArg, optionsArg))
            } catch (exception: Throwable) {
              wrapped = wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel =
            BasicMessageChannel<Any?>(
                binaryMessenger,
                "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.getDouble",
                codec)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val keyArg = args[0] as String
            val optionsArg = args[1] as SharedPreferencesPigeonOptions
            var wrapped: List<Any?>
            try {
              wrapped = listOf<Any?>(api.getDouble(keyArg, optionsArg))
            } catch (exception: Throwable) {
              wrapped = wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel =
            BasicMessageChannel<Any?>(
                binaryMessenger,
                "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.getInt",
                codec)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val keyArg = args[0] as String
            val optionsArg = args[1] as SharedPreferencesPigeonOptions
            var wrapped: List<Any?>
            try {
              wrapped = listOf<Any?>(api.getInt(keyArg, optionsArg))
            } catch (exception: Throwable) {
              wrapped = wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel =
            BasicMessageChannel<Any?>(
                binaryMessenger,
                "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.getStringList",
                codec)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val keyArg = args[0] as String
            val optionsArg = args[1] as SharedPreferencesPigeonOptions
            var wrapped: List<Any?>
            try {
              wrapped = listOf<Any?>(api.getStringList(keyArg, optionsArg))
            } catch (exception: Throwable) {
              wrapped = wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val taskQueue = binaryMessenger.makeBackgroundTaskQueue()
        val channel =
            BasicMessageChannel<Any?>(
                binaryMessenger,
                "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.clear",
                codec,
                taskQueue)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val allowListArg = args[0] as List<String>?
            val optionsArg = args[1] as SharedPreferencesPigeonOptions
            var wrapped: List<Any?>
            try {
              api.clear(allowListArg, optionsArg)
              wrapped = listOf<Any?>(null)
            } catch (exception: Throwable) {
              wrapped = wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val taskQueue = binaryMessenger.makeBackgroundTaskQueue()
        val channel =
            BasicMessageChannel<Any?>(
                binaryMessenger,
                "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.getAll",
                codec,
                taskQueue)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val allowListArg = args[0] as List<String>?
            val optionsArg = args[1] as SharedPreferencesPigeonOptions
            var wrapped: List<Any?>
            try {
              wrapped = listOf<Any?>(api.getAll(allowListArg, optionsArg))
            } catch (exception: Throwable) {
              wrapped = wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val taskQueue = binaryMessenger.makeBackgroundTaskQueue()
        val channel =
            BasicMessageChannel<Any?>(
                binaryMessenger,
                "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.getKeys",
                codec,
                taskQueue)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val allowListArg = args[0] as List<String>?
            val optionsArg = args[1] as SharedPreferencesPigeonOptions
            var wrapped: List<Any?>
            try {
              wrapped = listOf<Any?>(api.getKeys(allowListArg, optionsArg))
            } catch (exception: Throwable) {
              wrapped = wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
    }
  }
}
