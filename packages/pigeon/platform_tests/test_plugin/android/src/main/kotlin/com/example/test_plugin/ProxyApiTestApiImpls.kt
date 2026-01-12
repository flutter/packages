// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import androidx.annotation.RequiresApi
import io.flutter.plugin.common.BinaryMessenger

class ProxyApiTestClass : ProxyApiSuperClass(), ProxyApiInterface

open class ProxyApiSuperClass

interface ProxyApiInterface

@RequiresApi(25) class ClassWithApiRequirement

class ProxyApiRegistrar(binaryMessenger: BinaryMessenger) :
    ProxyApiTestsPigeonProxyApiRegistrar(binaryMessenger) {
  override fun getPigeonApiProxyApiTestClass(): PigeonApiProxyApiTestClass {
    return ProxyApiTestClassApi(this)
  }

  override fun getPigeonApiProxyApiSuperClass(): PigeonApiProxyApiSuperClass {
    return ProxyApiSuperClassApi(this)
  }

  override fun getPigeonApiClassWithApiRequirement(): PigeonApiClassWithApiRequirement {
    return ClassWithApiRequirementApi(this)
  }
}

class ProxyApiTestClassApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiProxyApiTestClass(pigeonRegistrar) {

  override fun pigeon_defaultConstructor(
      aBool: Boolean,
      anInt: Long,
      aDouble: Double,
      aString: String,
      aUint8List: ByteArray,
      aList: List<Any?>,
      aMap: Map<String?, Any?>,
      anEnum: ProxyApiTestEnum,
      aProxyApi: ProxyApiSuperClass,
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableDouble: Double?,
      aNullableString: String?,
      aNullableUint8List: ByteArray?,
      aNullableList: List<Any?>?,
      aNullableMap: Map<String?, Any?>?,
      aNullableEnum: ProxyApiTestEnum?,
      aNullableProxyApi: ProxyApiSuperClass?,
      boolParam: Boolean,
      intParam: Long,
      doubleParam: Double,
      stringParam: String,
      aUint8ListParam: ByteArray,
      listParam: List<Any?>,
      mapParam: Map<String?, Any?>,
      enumParam: ProxyApiTestEnum,
      proxyApiParam: ProxyApiSuperClass,
      nullableBoolParam: Boolean?,
      nullableIntParam: Long?,
      nullableDoubleParam: Double?,
      nullableStringParam: String?,
      nullableUint8ListParam: ByteArray?,
      nullableListParam: List<Any?>?,
      nullableMapParam: Map<String?, Any?>?,
      nullableEnumParam: ProxyApiTestEnum?,
      nullableProxyApiParam: ProxyApiSuperClass?
  ): ProxyApiTestClass {
    return ProxyApiTestClass()
  }

  override fun namedConstructor(
      aBool: Boolean,
      anInt: Long,
      aDouble: Double,
      aString: String,
      aUint8List: ByteArray,
      aList: List<Any?>,
      aMap: Map<String?, Any?>,
      anEnum: ProxyApiTestEnum,
      aProxyApi: ProxyApiSuperClass,
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableDouble: Double?,
      aNullableString: String?,
      aNullableUint8List: ByteArray?,
      aNullableList: List<Any?>?,
      aNullableMap: Map<String?, Any?>?,
      aNullableEnum: ProxyApiTestEnum?,
      aNullableProxyApi: ProxyApiSuperClass?,
  ): ProxyApiTestClass {
    return ProxyApiTestClass()
  }

  override fun attachedField(pigeon_instance: ProxyApiTestClass): ProxyApiSuperClass {
    return ProxyApiSuperClass()
  }

  override fun staticAttachedField(): ProxyApiSuperClass {
    return ProxyApiSuperClass()
  }

  override fun noop(pigeon_instance: ProxyApiTestClass) {}

  override fun throwError(pigeon_instance: ProxyApiTestClass): Any? {
    throw Exception("message")
  }

  override fun throwErrorFromVoid(pigeon_instance: ProxyApiTestClass) {
    throw Exception("message")
  }

  override fun throwFlutterError(pigeon_instance: ProxyApiTestClass): Any? {
    throw ProxyApiTestsError("code", "message", "details")
  }

  override fun echoInt(pigeon_instance: ProxyApiTestClass, anInt: Long): Long {
    return anInt
  }

  override fun echoDouble(pigeon_instance: ProxyApiTestClass, aDouble: Double): Double {
    return aDouble
  }

  override fun echoBool(pigeon_instance: ProxyApiTestClass, aBool: Boolean): Boolean {
    return aBool
  }

  override fun echoString(pigeon_instance: ProxyApiTestClass, aString: String): String {
    return aString
  }

  override fun echoUint8List(pigeon_instance: ProxyApiTestClass, aUint8List: ByteArray): ByteArray {
    return aUint8List
  }

  override fun echoObject(pigeon_instance: ProxyApiTestClass, anObject: Any): Any {
    return anObject
  }

  override fun echoList(pigeon_instance: ProxyApiTestClass, aList: List<Any?>): List<Any?> {
    return aList
  }

  override fun echoProxyApiList(
      pigeon_instance: ProxyApiTestClass,
      aList: List<ProxyApiTestClass>
  ): List<ProxyApiTestClass> {
    return aList
  }

  override fun echoMap(
      pigeon_instance: ProxyApiTestClass,
      aMap: Map<String?, Any?>
  ): Map<String?, Any?> {
    return aMap
  }

  override fun echoProxyApiMap(
      pigeon_instance: ProxyApiTestClass,
      aMap: Map<String, ProxyApiTestClass>
  ): Map<String, ProxyApiTestClass> {
    return aMap
  }

  override fun echoEnum(
      pigeon_instance: ProxyApiTestClass,
      anEnum: ProxyApiTestEnum
  ): ProxyApiTestEnum {
    return anEnum
  }

  override fun echoProxyApi(
      pigeon_instance: ProxyApiTestClass,
      aProxyApi: ProxyApiSuperClass
  ): ProxyApiSuperClass {
    return aProxyApi
  }

  override fun echoNullableInt(pigeon_instance: ProxyApiTestClass, aNullableInt: Long?): Long? {
    return aNullableInt
  }

  override fun echoNullableDouble(
      pigeon_instance: ProxyApiTestClass,
      aNullableDouble: Double?
  ): Double? {
    return aNullableDouble
  }

  override fun echoNullableBool(
      pigeon_instance: ProxyApiTestClass,
      aNullableBool: Boolean?
  ): Boolean? {
    return aNullableBool
  }

  override fun echoNullableString(
      pigeon_instance: ProxyApiTestClass,
      aNullableString: String?
  ): String? {
    return aNullableString
  }

  override fun echoNullableUint8List(
      pigeon_instance: ProxyApiTestClass,
      aNullableUint8List: ByteArray?
  ): ByteArray? {
    return aNullableUint8List
  }

  override fun echoNullableObject(pigeon_instance: ProxyApiTestClass, aNullableObject: Any?): Any? {
    return aNullableObject
  }

  override fun echoNullableList(
      pigeon_instance: ProxyApiTestClass,
      aNullableList: List<Any?>?
  ): List<Any?>? {
    return aNullableList
  }

  override fun echoNullableMap(
      pigeon_instance: ProxyApiTestClass,
      aNullableMap: Map<String?, Any?>?
  ): Map<String?, Any?>? {
    return aNullableMap
  }

  override fun echoNullableEnum(
      pigeon_instance: ProxyApiTestClass,
      aNullableEnum: ProxyApiTestEnum?
  ): ProxyApiTestEnum? {
    return aNullableEnum
  }

  override fun echoNullableProxyApi(
      pigeon_instance: ProxyApiTestClass,
      aNullableProxyApi: ProxyApiSuperClass?
  ): ProxyApiSuperClass? {
    return aNullableProxyApi
  }

  override fun noopAsync(pigeon_instance: ProxyApiTestClass, callback: (Result<Unit>) -> Unit) {
    callback(Result.success(Unit))
  }

  override fun echoAsyncInt(
      pigeon_instance: ProxyApiTestClass,
      anInt: Long,
      callback: (Result<Long>) -> Unit
  ) {
    callback(Result.success(anInt))
  }

  override fun echoAsyncDouble(
      pigeon_instance: ProxyApiTestClass,
      aDouble: Double,
      callback: (Result<Double>) -> Unit
  ) {
    callback(Result.success(aDouble))
  }

  override fun echoAsyncBool(
      pigeon_instance: ProxyApiTestClass,
      aBool: Boolean,
      callback: (Result<Boolean>) -> Unit
  ) {
    callback(Result.success(aBool))
  }

  override fun echoAsyncString(
      pigeon_instance: ProxyApiTestClass,
      aString: String,
      callback: (Result<String>) -> Unit
  ) {
    callback(Result.success(aString))
  }

  override fun echoAsyncUint8List(
      pigeon_instance: ProxyApiTestClass,
      aUint8List: ByteArray,
      callback: (Result<ByteArray>) -> Unit
  ) {
    callback(Result.success(aUint8List))
  }

  override fun echoAsyncObject(
      pigeon_instance: ProxyApiTestClass,
      anObject: Any,
      callback: (Result<Any>) -> Unit
  ) {
    callback(Result.success(anObject))
  }

  override fun echoAsyncList(
      pigeon_instance: ProxyApiTestClass,
      aList: List<Any?>,
      callback: (Result<List<Any?>>) -> Unit
  ) {
    callback(Result.success(aList))
  }

  override fun echoAsyncMap(
      pigeon_instance: ProxyApiTestClass,
      aMap: Map<String?, Any?>,
      callback: (Result<Map<String?, Any?>>) -> Unit
  ) {
    callback(Result.success(aMap))
  }

  override fun echoAsyncEnum(
      pigeon_instance: ProxyApiTestClass,
      anEnum: ProxyApiTestEnum,
      callback: (Result<ProxyApiTestEnum>) -> Unit
  ) {
    callback(Result.success(anEnum))
  }

  override fun throwAsyncError(
      pigeon_instance: ProxyApiTestClass,
      callback: (Result<Any?>) -> Unit
  ) {
    callback(Result.failure(Exception("message")))
  }

  override fun throwAsyncErrorFromVoid(
      pigeon_instance: ProxyApiTestClass,
      callback: (Result<Unit>) -> Unit
  ) {
    callback(Result.failure(Exception("message")))
  }

  override fun throwAsyncFlutterError(
      pigeon_instance: ProxyApiTestClass,
      callback: (Result<Any?>) -> Unit
  ) {
    callback(Result.failure(ProxyApiTestsError("code", "message", "details")))
  }

  override fun echoAsyncNullableInt(
      pigeon_instance: ProxyApiTestClass,
      anInt: Long?,
      callback: (Result<Long?>) -> Unit
  ) {
    callback(Result.success(anInt))
  }

  override fun echoAsyncNullableDouble(
      pigeon_instance: ProxyApiTestClass,
      aDouble: Double?,
      callback: (Result<Double?>) -> Unit
  ) {
    callback(Result.success(aDouble))
  }

  override fun echoAsyncNullableBool(
      pigeon_instance: ProxyApiTestClass,
      aBool: Boolean?,
      callback: (Result<Boolean?>) -> Unit
  ) {
    callback(Result.success(aBool))
  }

  override fun echoAsyncNullableString(
      pigeon_instance: ProxyApiTestClass,
      aString: String?,
      callback: (Result<String?>) -> Unit
  ) {
    callback(Result.success(aString))
  }

  override fun echoAsyncNullableUint8List(
      pigeon_instance: ProxyApiTestClass,
      aUint8List: ByteArray?,
      callback: (Result<ByteArray?>) -> Unit
  ) {
    callback(Result.success(aUint8List))
  }

  override fun echoAsyncNullableObject(
      pigeon_instance: ProxyApiTestClass,
      anObject: Any?,
      callback: (Result<Any?>) -> Unit
  ) {
    callback(Result.success(anObject))
  }

  override fun echoAsyncNullableList(
      pigeon_instance: ProxyApiTestClass,
      aList: List<Any?>?,
      callback: (Result<List<Any?>?>) -> Unit
  ) {
    callback(Result.success(aList))
  }

  override fun echoAsyncNullableMap(
      pigeon_instance: ProxyApiTestClass,
      aMap: Map<String?, Any?>?,
      callback: (Result<Map<String?, Any?>?>) -> Unit
  ) {
    callback(Result.success(aMap))
  }

  override fun echoAsyncNullableEnum(
      pigeon_instance: ProxyApiTestClass,
      anEnum: ProxyApiTestEnum?,
      callback: (Result<ProxyApiTestEnum?>) -> Unit
  ) {
    callback(Result.success(anEnum))
  }

  override fun staticNoop() {}

  override fun echoStaticString(aString: String): String {
    return aString
  }

  override fun staticAsyncNoop(callback: (Result<Unit>) -> Unit) {
    callback(Result.success(Unit))
  }

  override fun callFlutterNoop(
      pigeon_instance: ProxyApiTestClass,
      callback: (Result<Unit>) -> Unit
  ) {
    flutterNoop(pigeon_instance, callback)
  }

  override fun callFlutterThrowError(
      pigeon_instance: ProxyApiTestClass,
      callback: (Result<Any?>) -> Unit
  ) {
    flutterThrowError(pigeon_instance) { result ->
      val exception = result.exceptionOrNull()
      callback(Result.failure(exception!!))
    }
  }

  override fun callFlutterThrowErrorFromVoid(
      pigeon_instance: ProxyApiTestClass,
      callback: (Result<Unit>) -> Unit
  ) {
    flutterThrowErrorFromVoid(pigeon_instance) { result ->
      val exception = result.exceptionOrNull()
      callback(Result.failure(exception!!))
    }
  }

  override fun callFlutterEchoBool(
      pigeon_instance: ProxyApiTestClass,
      aBool: Boolean,
      callback: (Result<Boolean>) -> Unit
  ) {
    flutterEchoBool(pigeon_instance, aBool, callback)
  }

  override fun callFlutterEchoInt(
      pigeon_instance: ProxyApiTestClass,
      anInt: Long,
      callback: (Result<Long>) -> Unit
  ) {
    flutterEchoInt(pigeon_instance, anInt, callback)
  }

  override fun callFlutterEchoDouble(
      pigeon_instance: ProxyApiTestClass,
      aDouble: Double,
      callback: (Result<Double>) -> Unit
  ) {
    flutterEchoDouble(pigeon_instance, aDouble, callback)
  }

  override fun callFlutterEchoString(
      pigeon_instance: ProxyApiTestClass,
      aString: String,
      callback: (Result<String>) -> Unit
  ) {
    flutterEchoString(pigeon_instance, aString, callback)
  }

  override fun callFlutterEchoUint8List(
      pigeon_instance: ProxyApiTestClass,
      aUint8List: ByteArray,
      callback: (Result<ByteArray>) -> Unit
  ) {
    flutterEchoUint8List(pigeon_instance, aUint8List, callback)
  }

  override fun callFlutterEchoList(
      pigeon_instance: ProxyApiTestClass,
      aList: List<Any?>,
      callback: (Result<List<Any?>>) -> Unit
  ) {
    flutterEchoList(pigeon_instance, aList, callback)
  }

  override fun callFlutterEchoProxyApiList(
      pigeon_instance: ProxyApiTestClass,
      aList: List<ProxyApiTestClass?>,
      callback: (Result<List<ProxyApiTestClass?>>) -> Unit
  ) {
    flutterEchoProxyApiList(pigeon_instance, aList, callback)
  }

  override fun callFlutterEchoMap(
      pigeon_instance: ProxyApiTestClass,
      aMap: Map<String?, Any?>,
      callback: (Result<Map<String?, Any?>>) -> Unit
  ) {
    flutterEchoMap(pigeon_instance, aMap, callback)
  }

  override fun callFlutterEchoProxyApiMap(
      pigeon_instance: ProxyApiTestClass,
      aMap: Map<String?, ProxyApiTestClass?>,
      callback: (Result<Map<String?, ProxyApiTestClass?>>) -> Unit
  ) {
    flutterEchoProxyApiMap(pigeon_instance, aMap, callback)
  }

  override fun callFlutterEchoEnum(
      pigeon_instance: ProxyApiTestClass,
      anEnum: ProxyApiTestEnum,
      callback: (Result<ProxyApiTestEnum>) -> Unit
  ) {
    flutterEchoEnum(pigeon_instance, anEnum, callback)
  }

  override fun callFlutterEchoProxyApi(
      pigeon_instance: ProxyApiTestClass,
      aProxyApi: ProxyApiSuperClass,
      callback: (Result<ProxyApiSuperClass>) -> Unit
  ) {
    flutterEchoProxyApi(pigeon_instance, aProxyApi, callback)
  }

  override fun callFlutterEchoNullableBool(
      pigeon_instance: ProxyApiTestClass,
      aBool: Boolean?,
      callback: (Result<Boolean?>) -> Unit
  ) {
    flutterEchoNullableBool(pigeon_instance, aBool, callback)
  }

  override fun callFlutterEchoNullableInt(
      pigeon_instance: ProxyApiTestClass,
      anInt: Long?,
      callback: (Result<Long?>) -> Unit
  ) {
    flutterEchoNullableInt(pigeon_instance, anInt, callback)
  }

  override fun callFlutterEchoNullableDouble(
      pigeon_instance: ProxyApiTestClass,
      aDouble: Double?,
      callback: (Result<Double?>) -> Unit
  ) {
    flutterEchoNullableDouble(pigeon_instance, aDouble, callback)
  }

  override fun callFlutterEchoNullableString(
      pigeon_instance: ProxyApiTestClass,
      aString: String?,
      callback: (Result<String?>) -> Unit
  ) {
    flutterEchoNullableString(pigeon_instance, aString, callback)
  }

  override fun callFlutterEchoNullableUint8List(
      pigeon_instance: ProxyApiTestClass,
      aUint8List: ByteArray?,
      callback: (Result<ByteArray?>) -> Unit
  ) {
    flutterEchoNullableUint8List(pigeon_instance, aUint8List, callback)
  }

  override fun callFlutterEchoNullableList(
      pigeon_instance: ProxyApiTestClass,
      aList: List<Any?>?,
      callback: (Result<List<Any?>?>) -> Unit
  ) {
    flutterEchoNullableList(pigeon_instance, aList, callback)
  }

  override fun callFlutterEchoNullableMap(
      pigeon_instance: ProxyApiTestClass,
      aMap: Map<String?, Any?>?,
      callback: (Result<Map<String?, Any?>?>) -> Unit
  ) {
    flutterEchoNullableMap(pigeon_instance, aMap, callback)
  }

  override fun callFlutterEchoNullableEnum(
      pigeon_instance: ProxyApiTestClass,
      anEnum: ProxyApiTestEnum?,
      callback: (Result<ProxyApiTestEnum?>) -> Unit
  ) {
    flutterEchoNullableEnum(pigeon_instance, anEnum, callback)
  }

  override fun callFlutterEchoNullableProxyApi(
      pigeon_instance: ProxyApiTestClass,
      aProxyApi: ProxyApiSuperClass?,
      callback: (Result<ProxyApiSuperClass?>) -> Unit
  ) {
    flutterEchoNullableProxyApi(pigeon_instance, aProxyApi, callback)
  }

  override fun callFlutterNoopAsync(
      pigeon_instance: ProxyApiTestClass,
      callback: (Result<Unit>) -> Unit
  ) {
    flutterNoopAsync(pigeon_instance, callback)
  }

  override fun callFlutterEchoAsyncString(
      pigeon_instance: ProxyApiTestClass,
      aString: String,
      callback: (Result<String>) -> Unit
  ) {
    flutterEchoAsyncString(pigeon_instance, aString, callback)
  }
}

class ProxyApiSuperClassApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiProxyApiSuperClass(pigeonRegistrar) {
  override fun pigeon_defaultConstructor(): ProxyApiSuperClass {
    return ProxyApiSuperClass()
  }

  override fun aSuperMethod(pigeon_instance: ProxyApiSuperClass) {}
}

class ClassWithApiRequirementApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiClassWithApiRequirement(pigeonRegistrar) {
  @RequiresApi(25)
  override fun pigeon_defaultConstructor(): ClassWithApiRequirement {
    return ClassWithApiRequirement()
  }

  override fun aMethod(pigeon_instance: ClassWithApiRequirement) {
    // Do nothing
  }
}
