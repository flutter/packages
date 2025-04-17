// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Autogenerated from Pigeon, do not edit directly.
// See also: https://pub.dev/packages/pigeon
@file:Suppress("UNCHECKED_CAST", "ArrayInDataClass")

import androidx.annotation.Keep

/**
 * Error class for passing custom error details to Flutter via a thrown PlatformException.
 *
 * @property code The error code.
 * @property message The error message.
 * @property details The error details. Must be a datatype supported by the api codec.
 */
class JniTestsError(
    val code: String,
    override val message: String? = null,
    val details: Any? = null
) : Throwable()

/** Generated class from Pigeon that represents data sent in messages. */
data class SomeTypes(
    val aString: String,
    val anInt: Long,
    val aDouble: Double,
    val aBool: Boolean
) {
  companion object {
    fun fromList(pigeonVar_list: List<Any?>): SomeTypes {
      val aString = pigeonVar_list[0] as String
      val anInt = pigeonVar_list[1] as Long
      val aDouble = pigeonVar_list[2] as Double
      val aBool = pigeonVar_list[3] as Boolean
      return SomeTypes(aString, anInt, aDouble, aBool)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
        aString,
        anInt,
        aDouble,
        aBool,
    )
  }

  override fun equals(other: Any?): Boolean {
    if (other !is SomeTypes) {
      return false
    }
    if (this === other) {
      return true
    }
    return aString == other.aString &&
        anInt == other.anInt &&
        aDouble == other.aDouble &&
        aBool == other.aBool
  }

  override fun hashCode(): Int = toList().hashCode()
}

/** Generated class from Pigeon that represents data sent in messages. */
data class SomeNullableTypes(
    val aString: String? = null,
    val anInt: Long? = null,
    val aDouble: Double? = null,
    val aBool: Boolean? = null
) {
  companion object {
    fun fromList(pigeonVar_list: List<Any?>): SomeNullableTypes {
      val aString = pigeonVar_list[0] as String?
      val anInt = pigeonVar_list[1] as Long?
      val aDouble = pigeonVar_list[2] as Double?
      val aBool = pigeonVar_list[3] as Boolean?
      return SomeNullableTypes(aString, anInt, aDouble, aBool)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
        aString,
        anInt,
        aDouble,
        aBool,
    )
  }

  override fun equals(other: Any?): Boolean {
    if (other !is SomeNullableTypes) {
      return false
    }
    if (this === other) {
      return true
    }
    return aString == other.aString &&
        anInt == other.anInt &&
        aDouble == other.aDouble &&
        aBool == other.aBool
  }

  override fun hashCode(): Int = toList().hashCode()
}

val JniMessageApiInstances: MutableMap<String, JniMessageApiRegistrar> = mutableMapOf()

@Keep
abstract class JniMessageApi {
  abstract fun doNothing()

  abstract fun echoString(request: String): String

  abstract fun echoInt(request: Long): Long

  abstract fun echoDouble(request: Double): Double

  abstract fun echoBool(request: Boolean): Boolean

  abstract fun sendSomeTypes(someTypes: SomeTypes): SomeTypes
}

@Keep
class JniMessageApiRegistrar : JniMessageApi() {
  var api: JniMessageApi? = null

  fun register(
      api: JniMessageApi,
      name: String = "PigeonDefaultClassName32uh4ui3lh445uh4h3l2l455g4y34u"
  ): JniMessageApiRegistrar {
    this.api = api
    JniMessageApiInstances[name] = this
    return this
  }

  @Keep
  fun getInstance(name: String): JniMessageApiRegistrar? {
    return JniMessageApiInstances[name]
  }

  override fun doNothing() {
    api?.let {
      try {
        return api!!.doNothing()
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApi has not been set")
  }

  override fun echoString(request: String): String {
    api?.let {
      try {
        return api!!.echoString(request)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApi has not been set")
  }

  override fun echoInt(request: Long): Long {
    api?.let {
      try {
        return api!!.echoInt(request)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApi has not been set")
  }

  override fun echoDouble(request: Double): Double {
    api?.let {
      try {
        return api!!.echoDouble(request)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApi has not been set")
  }

  override fun echoBool(request: Boolean): Boolean {
    api?.let {
      try {
        return api!!.echoBool(request)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApi has not been set")
  }

  override fun sendSomeTypes(someTypes: SomeTypes): SomeTypes {
    api?.let {
      try {
        return api!!.sendSomeTypes(someTypes)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApi has not been set")
  }
}

val JniMessageApiNullableInstances: MutableMap<String, JniMessageApiNullableRegistrar> =
    mutableMapOf()

@Keep
abstract class JniMessageApiNullable {
  abstract fun echoString(request: String?): String?

  abstract fun echoInt(request: Long?): Long?

  abstract fun echoDouble(request: Double?): Double?

  abstract fun echoBool(request: Boolean?): Boolean?

  abstract fun sendSomeNullableTypes(someTypes: SomeNullableTypes?): SomeNullableTypes?
}

@Keep
class JniMessageApiNullableRegistrar : JniMessageApiNullable() {
  var api: JniMessageApiNullable? = null

  fun register(
      api: JniMessageApiNullable,
      name: String = "PigeonDefaultClassName32uh4ui3lh445uh4h3l2l455g4y34u"
  ): JniMessageApiNullableRegistrar {
    this.api = api
    JniMessageApiNullableInstances[name] = this
    return this
  }

  @Keep
  fun getInstance(name: String): JniMessageApiNullableRegistrar? {
    return JniMessageApiNullableInstances[name]
  }

  override fun echoString(request: String?): String? {
    api?.let {
      try {
        return api!!.echoString(request)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApiNullable has not been set")
  }

  override fun echoInt(request: Long?): Long? {
    api?.let {
      try {
        return api!!.echoInt(request)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApiNullable has not been set")
  }

  override fun echoDouble(request: Double?): Double? {
    api?.let {
      try {
        return api!!.echoDouble(request)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApiNullable has not been set")
  }

  override fun echoBool(request: Boolean?): Boolean? {
    api?.let {
      try {
        return api!!.echoBool(request)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApiNullable has not been set")
  }

  override fun sendSomeNullableTypes(someTypes: SomeNullableTypes?): SomeNullableTypes? {
    api?.let {
      try {
        return api!!.sendSomeNullableTypes(someTypes)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApiNullable has not been set")
  }
}

val JniMessageApiAsyncInstances: MutableMap<String, JniMessageApiAsyncRegistrar> = mutableMapOf()

@Keep
abstract class JniMessageApiAsync {
  abstract suspend fun doNothing()

  abstract suspend fun echoString(request: String): String

  abstract suspend fun echoInt(request: Long): Long

  abstract suspend fun echoDouble(request: Double): Double

  abstract suspend fun echoBool(request: Boolean): Boolean

  abstract suspend fun sendSomeTypes(someTypes: SomeTypes): SomeTypes
}

@Keep
class JniMessageApiAsyncRegistrar : JniMessageApiAsync() {
  var api: JniMessageApiAsync? = null

  fun register(
      api: JniMessageApiAsync,
      name: String = "PigeonDefaultClassName32uh4ui3lh445uh4h3l2l455g4y34u"
  ): JniMessageApiAsyncRegistrar {
    this.api = api
    JniMessageApiAsyncInstances[name] = this
    return this
  }

  @Keep
  fun getInstance(name: String): JniMessageApiAsyncRegistrar? {
    return JniMessageApiAsyncInstances[name]
  }

  override suspend fun doNothing() {
    api?.let {
      try {
        return api!!.doNothing()
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApiAsync has not been set")
  }

  override suspend fun echoString(request: String): String {
    api?.let {
      try {
        return api!!.echoString(request)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApiAsync has not been set")
  }

  override suspend fun echoInt(request: Long): Long {
    api?.let {
      try {
        return api!!.echoInt(request)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApiAsync has not been set")
  }

  override suspend fun echoDouble(request: Double): Double {
    api?.let {
      try {
        return api!!.echoDouble(request)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApiAsync has not been set")
  }

  override suspend fun echoBool(request: Boolean): Boolean {
    api?.let {
      try {
        return api!!.echoBool(request)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApiAsync has not been set")
  }

  override suspend fun sendSomeTypes(someTypes: SomeTypes): SomeTypes {
    api?.let {
      try {
        return api!!.sendSomeTypes(someTypes)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApiAsync has not been set")
  }
}

val JniMessageApiNullableAsyncInstances: MutableMap<String, JniMessageApiNullableAsyncRegistrar> =
    mutableMapOf()

@Keep
abstract class JniMessageApiNullableAsync {
  abstract suspend fun echoString(request: String?): String?

  abstract suspend fun echoInt(request: Long?): Long?

  abstract suspend fun echoDouble(request: Double?): Double?

  abstract suspend fun echoBool(request: Boolean?): Boolean?

  abstract suspend fun sendSomeNullableTypes(someTypes: SomeNullableTypes?): SomeNullableTypes?
}

@Keep
class JniMessageApiNullableAsyncRegistrar : JniMessageApiNullableAsync() {
  var api: JniMessageApiNullableAsync? = null

  fun register(
      api: JniMessageApiNullableAsync,
      name: String = "PigeonDefaultClassName32uh4ui3lh445uh4h3l2l455g4y34u"
  ): JniMessageApiNullableAsyncRegistrar {
    this.api = api
    JniMessageApiNullableAsyncInstances[name] = this
    return this
  }

  @Keep
  fun getInstance(name: String): JniMessageApiNullableAsyncRegistrar? {
    return JniMessageApiNullableAsyncInstances[name]
  }

  override suspend fun echoString(request: String?): String? {
    api?.let {
      try {
        return api!!.echoString(request)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApiNullableAsync has not been set")
  }

  override suspend fun echoInt(request: Long?): Long? {
    api?.let {
      try {
        return api!!.echoInt(request)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApiNullableAsync has not been set")
  }

  override suspend fun echoDouble(request: Double?): Double? {
    api?.let {
      try {
        return api!!.echoDouble(request)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApiNullableAsync has not been set")
  }

  override suspend fun echoBool(request: Boolean?): Boolean? {
    api?.let {
      try {
        return api!!.echoBool(request)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApiNullableAsync has not been set")
  }

  override suspend fun sendSomeNullableTypes(someTypes: SomeNullableTypes?): SomeNullableTypes? {
    api?.let {
      try {
        return api!!.sendSomeNullableTypes(someTypes)
      } catch (e: Exception) {
        throw e
      }
    }
    error("JniMessageApiNullableAsync has not been set")
  }
}
