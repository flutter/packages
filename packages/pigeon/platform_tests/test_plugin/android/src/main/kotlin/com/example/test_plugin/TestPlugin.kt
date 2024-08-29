// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

/** This plugin handles the native side of the integration tests in example/integration_test/. */
class TestPlugin : FlutterPlugin, HostIntegrationCoreApi {
  private var flutterApi: FlutterIntegrationCoreApi? = null
  private var flutterSmallApiOne: FlutterSmallApi? = null
  private var flutterSmallApiTwo: FlutterSmallApi? = null

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    HostIntegrationCoreApi.setUp(binding.binaryMessenger, this)
    val testSuffixApiOne = TestPluginWithSuffix()
    testSuffixApiOne.setUp(binding, "suffixOne")
    val testSuffixApiTwo = TestPluginWithSuffix()
    testSuffixApiTwo.setUp(binding, "suffixTwo")
    flutterApi = FlutterIntegrationCoreApi(binding.binaryMessenger)
    flutterSmallApiOne = FlutterSmallApi(binding.binaryMessenger, "suffixOne")
    flutterSmallApiTwo = FlutterSmallApi(binding.binaryMessenger, "suffixTwo")
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {}

  // HostIntegrationCoreApi

  override fun noop() {}

  override fun echoAllTypes(everything: AllTypes): AllTypes {
    return everything
  }

  override fun echoAllNullableTypes(everything: AllNullableTypes?): AllNullableTypes? {
    return everything
  }

  override fun echoAllNullableTypesWithoutRecursion(
      everything: AllNullableTypesWithoutRecursion?
  ): AllNullableTypesWithoutRecursion? {
    return everything
  }

  override fun throwError(): Any? {
    throw Exception("An error")
  }

  override fun throwErrorFromVoid() {
    throw Exception("An error")
  }

  override fun throwFlutterError(): Any? {
    throw FlutterError("code", "message", "details")
  }

  override fun echoInt(anInt: Long): Long {
    return anInt
  }

  override fun echoDouble(aDouble: Double): Double {
    return aDouble
  }

  override fun echoBool(aBool: Boolean): Boolean {
    return aBool
  }

  override fun echoString(aString: String): String {
    return aString
  }

  override fun echoUint8List(aUint8List: ByteArray): ByteArray {
    return aUint8List
  }

  override fun echoObject(anObject: Any): Any {
    return anObject
  }

  override fun echoList(list: List<Any?>): List<Any?> {
    return list
  }

  override fun echoMap(map: Map<Any?, Any?>): Map<Any?, Any?> {
    return map
  }

  override fun echoStringMap(stringMap: Map<String?, String?>): Map<String?, String?> {
    return stringMap
  }

  override fun echoIntMap(intMap: Map<Long?, Long?>): Map<Long?, Long?> {
    return intMap
  }

  override fun echoClassWrapper(wrapper: AllClassesWrapper): AllClassesWrapper {
    return wrapper
  }

  override fun echoEnum(anEnum: AnEnum): AnEnum {
    return anEnum
  }

  override fun echoAnotherEnum(anotherEnum: AnotherEnum): AnotherEnum {
    return anotherEnum
  }

  override fun echoNamedDefaultString(aString: String): String {
    return aString
  }

  override fun echoOptionalDefaultDouble(aDouble: Double): Double {
    return aDouble
  }

  override fun echoRequiredInt(anInt: Long): Long {
    return anInt
  }

  override fun extractNestedNullableString(wrapper: AllClassesWrapper): String? {
    return wrapper.allNullableTypes.aNullableString
  }

  override fun createNestedNullableString(nullableString: String?): AllClassesWrapper {
    return AllClassesWrapper(AllNullableTypes(aNullableString = nullableString))
  }

  override fun sendMultipleNullableTypes(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?
  ): AllNullableTypes {
    return AllNullableTypes(
        aNullableBool = aNullableBool,
        aNullableInt = aNullableInt,
        aNullableString = aNullableString)
  }

  override fun sendMultipleNullableTypesWithoutRecursion(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?
  ): AllNullableTypesWithoutRecursion {
    return AllNullableTypesWithoutRecursion(
        aNullableBool = aNullableBool,
        aNullableInt = aNullableInt,
        aNullableString = aNullableString)
  }

  override fun echoNullableInt(aNullableInt: Long?): Long? {
    return aNullableInt
  }

  override fun echoNullableDouble(aNullableDouble: Double?): Double? {
    return aNullableDouble
  }

  override fun echoNullableBool(aNullableBool: Boolean?): Boolean? {
    return aNullableBool
  }

  override fun echoNullableString(aNullableString: String?): String? {
    return aNullableString
  }

  override fun echoNullableUint8List(aNullableUint8List: ByteArray?): ByteArray? {
    return aNullableUint8List
  }

  override fun echoNullableObject(aNullableObject: Any?): Any? {
    return aNullableObject
  }

  override fun echoNullableList(aNullableList: List<Any?>?): List<Any?>? {
    return aNullableList
  }

  override fun echoNullableMap(map: Map<Any?, Any?>?): Map<Any?, Any?>? {
    return map
  }

  override fun echoNullableStringMap(stringMap: Map<String?, String?>?): Map<String?, String?>? {
    return stringMap
  }

  override fun echoNullableIntMap(intMap: Map<Long?, Long?>?): Map<Long?, Long?>? {
    return intMap
  }

  override fun echoNullableEnum(anEnum: AnEnum?): AnEnum? {
    return anEnum
  }

  override fun echoAnotherNullableEnum(anotherEnum: AnotherEnum?): AnotherEnum? {
    return anotherEnum
  }

  override fun echoOptionalNullableInt(aNullableInt: Long?): Long? {
    return aNullableInt
  }

  override fun echoNamedNullableString(aNullableString: String?): String? {
    return aNullableString
  }

  override fun noopAsync(callback: (Result<Unit>) -> Unit) {
    callback(Result.success(Unit))
  }

  override fun throwAsyncError(callback: (Result<Any?>) -> Unit) {
    callback(Result.failure(Exception("except")))
  }

  override fun throwAsyncErrorFromVoid(callback: (Result<Unit>) -> Unit) {
    callback(Result.failure(Exception("except")))
  }

  override fun throwAsyncFlutterError(callback: (Result<Any?>) -> Unit) {
    callback(Result.failure(FlutterError("code", "message", "details")))
  }

  override fun echoAsyncAllTypes(everything: AllTypes, callback: (Result<AllTypes>) -> Unit) {
    callback(Result.success(everything))
  }

  override fun echoAsyncNullableAllNullableTypes(
      everything: AllNullableTypes?,
      callback: (Result<AllNullableTypes?>) -> Unit
  ) {
    callback(Result.success(everything))
  }

  override fun echoAsyncNullableAllNullableTypesWithoutRecursion(
      everything: AllNullableTypesWithoutRecursion?,
      callback: (Result<AllNullableTypesWithoutRecursion?>) -> Unit
  ) {
    callback(Result.success(everything))
  }

  override fun echoAsyncInt(anInt: Long, callback: (Result<Long>) -> Unit) {
    callback(Result.success(anInt))
  }

  override fun echoAsyncDouble(aDouble: Double, callback: (Result<Double>) -> Unit) {
    callback(Result.success(aDouble))
  }

  override fun echoAsyncBool(aBool: Boolean, callback: (Result<Boolean>) -> Unit) {
    callback(Result.success(aBool))
  }

  override fun echoAsyncString(aString: String, callback: (Result<String>) -> Unit) {
    callback(Result.success(aString))
  }

  override fun echoAsyncUint8List(aUint8List: ByteArray, callback: (Result<ByteArray>) -> Unit) {
    callback(Result.success(aUint8List))
  }

  override fun echoAsyncObject(anObject: Any, callback: (Result<Any>) -> Unit) {
    callback(Result.success(anObject))
  }

  override fun echoAsyncList(list: List<Any?>, callback: (Result<List<Any?>>) -> Unit) {
    callback(Result.success(list))
  }

  override fun echoAsyncMap(map: Map<Any?, Any?>, callback: (Result<Map<Any?, Any?>>) -> Unit) {
    callback(Result.success(map))
  }

  override fun echoAsyncStringMap(
      stringMap: Map<String?, String?>,
      callback: (Result<Map<String?, String?>>) -> Unit
  ) {
    callback(Result.success(stringMap))
  }

  override fun echoAsyncIntMap(
      intMap: Map<Long?, Long?>,
      callback: (Result<Map<Long?, Long?>>) -> Unit
  ) {
    callback(Result.success(intMap))
  }

  override fun echoAsyncEnum(anEnum: AnEnum, callback: (Result<AnEnum>) -> Unit) {
    callback(Result.success(anEnum))
  }

  override fun echoAnotherAsyncEnum(
      anotherEnum: AnotherEnum,
      callback: (Result<AnotherEnum>) -> Unit
  ) {
    callback(Result.success(anotherEnum))
  }

  override fun echoAsyncNullableInt(anInt: Long?, callback: (Result<Long?>) -> Unit) {
    callback(Result.success(anInt))
  }

  override fun echoAsyncNullableDouble(aDouble: Double?, callback: (Result<Double?>) -> Unit) {
    callback(Result.success(aDouble))
  }

  override fun echoAsyncNullableBool(aBool: Boolean?, callback: (Result<Boolean?>) -> Unit) {
    callback(Result.success(aBool))
  }

  override fun echoAsyncNullableString(aString: String?, callback: (Result<String?>) -> Unit) {
    callback(Result.success(aString))
  }

  override fun echoAsyncNullableUint8List(
      aUint8List: ByteArray?,
      callback: (Result<ByteArray?>) -> Unit
  ) {
    callback(Result.success(aUint8List))
  }

  override fun echoAsyncNullableObject(anObject: Any?, callback: (Result<Any?>) -> Unit) {
    callback(Result.success(anObject))
  }

  override fun echoAsyncNullableList(list: List<Any?>?, callback: (Result<List<Any?>?>) -> Unit) {
    callback(Result.success(list))
  }

  override fun echoAsyncNullableMap(
      map: Map<Any?, Any?>?,
      callback: (Result<Map<Any?, Any?>?>) -> Unit
  ) {
    callback(Result.success(map))
  }

  override fun echoAsyncNullableStringMap(
      stringMap: Map<String?, String?>?,
      callback: (Result<Map<String?, String?>?>) -> Unit
  ) {
    callback(Result.success(stringMap))
  }

  override fun echoAsyncNullableIntMap(
      intMap: Map<Long?, Long?>?,
      callback: (Result<Map<Long?, Long?>?>) -> Unit
  ) {
    callback(Result.success(intMap))
  }

  override fun echoAsyncNullableEnum(anEnum: AnEnum?, callback: (Result<AnEnum?>) -> Unit) {
    callback(Result.success(anEnum))
  }

  override fun echoAnotherAsyncNullableEnum(
      anotherEnum: AnotherEnum?,
      callback: (Result<AnotherEnum?>) -> Unit
  ) {
    callback(Result.success(anotherEnum))
  }

  override fun callFlutterNoop(callback: (Result<Unit>) -> Unit) {
    flutterApi!!.noop { callback(Result.success(Unit)) }
  }

  override fun callFlutterThrowError(callback: (Result<Any?>) -> Unit) {
    flutterApi!!.throwError { result -> callback(result) }
  }

  override fun callFlutterThrowErrorFromVoid(callback: (Result<Unit>) -> Unit) {
    flutterApi!!.throwErrorFromVoid { result -> callback(result) }
  }

  override fun callFlutterEchoAllTypes(everything: AllTypes, callback: (Result<AllTypes>) -> Unit) {
    flutterApi!!.echoAllTypes(everything) { echo -> callback(echo) }
  }

  override fun callFlutterSendMultipleNullableTypes(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?,
      callback: (Result<AllNullableTypes>) -> Unit
  ) {
    flutterApi!!.sendMultipleNullableTypes(aNullableBool, aNullableInt, aNullableString) { echo ->
      callback(echo)
    }
  }

  override fun callFlutterEchoAllNullableTypesWithoutRecursion(
      everything: AllNullableTypesWithoutRecursion?,
      callback: (Result<AllNullableTypesWithoutRecursion?>) -> Unit
  ) {
    flutterApi!!.echoAllNullableTypesWithoutRecursion(everything) { echo -> callback(echo) }
  }

  override fun callFlutterSendMultipleNullableTypesWithoutRecursion(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?,
      callback: (Result<AllNullableTypesWithoutRecursion>) -> Unit
  ) {
    flutterApi!!.sendMultipleNullableTypesWithoutRecursion(
        aNullableBool, aNullableInt, aNullableString) { echo ->
          callback(echo)
        }
  }

  override fun callFlutterEchoBool(aBool: Boolean, callback: (Result<Boolean>) -> Unit) {
    flutterApi!!.echoBool(aBool) { echo -> callback(echo) }
  }

  override fun callFlutterEchoInt(anInt: Long, callback: (Result<Long>) -> Unit) {
    flutterApi!!.echoInt(anInt) { echo -> callback(echo) }
  }

  override fun callFlutterEchoDouble(aDouble: Double, callback: (Result<Double>) -> Unit) {
    flutterApi!!.echoDouble(aDouble) { echo -> callback(echo) }
  }

  override fun callFlutterEchoString(aString: String, callback: (Result<String>) -> Unit) {
    flutterApi!!.echoString(aString) { echo -> callback(echo) }
  }

  override fun callFlutterEchoUint8List(list: ByteArray, callback: (Result<ByteArray>) -> Unit) {
    flutterApi!!.echoUint8List(list) { echo -> callback(echo) }
  }

  override fun callFlutterEchoList(list: List<Any?>, callback: (Result<List<Any?>>) -> Unit) {
    flutterApi!!.echoList(list) { echo -> callback(echo) }
  }

  override fun callFlutterEchoMap(
      map: Map<Any?, Any?>,
      callback: (Result<Map<Any?, Any?>>) -> Unit
  ) {
    flutterApi!!.echoMap(map) { echo -> callback(echo) }
  }

  override fun callFlutterEchoStringMap(
      stringMap: Map<String?, String?>,
      callback: (Result<Map<String?, String?>>) -> Unit
  ) {
    flutterApi!!.echoStringMap(stringMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoIntMap(
      intMap: Map<Long?, Long?>,
      callback: (Result<Map<Long?, Long?>>) -> Unit
  ) {
    flutterApi!!.echoIntMap(intMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoEnum(anEnum: AnEnum, callback: (Result<AnEnum>) -> Unit) {
    flutterApi!!.echoEnum(anEnum) { echo -> callback(echo) }
  }

  override fun callFlutterEchoAnotherEnum(
      anotherEnum: AnotherEnum,
      callback: (Result<AnotherEnum>) -> Unit
  ) {
    flutterApi!!.echoAnotherEnum(anotherEnum) { echo -> callback(echo) }
  }

  override fun callFlutterEchoAllNullableTypes(
      everything: AllNullableTypes?,
      callback: (Result<AllNullableTypes?>) -> Unit
  ) {
    flutterApi!!.echoAllNullableTypes(everything) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableBool(aBool: Boolean?, callback: (Result<Boolean?>) -> Unit) {
    flutterApi!!.echoNullableBool(aBool) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableInt(anInt: Long?, callback: (Result<Long?>) -> Unit) {
    flutterApi!!.echoNullableInt(anInt) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableDouble(
      aDouble: Double?,
      callback: (Result<Double?>) -> Unit
  ) {
    flutterApi!!.echoNullableDouble(aDouble) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableString(
      aString: String?,
      callback: (Result<String?>) -> Unit
  ) {
    flutterApi!!.echoNullableString(aString) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableUint8List(
      list: ByteArray?,
      callback: (Result<ByteArray?>) -> Unit
  ) {
    flutterApi!!.echoNullableUint8List(list) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableList(
      list: List<Any?>?,
      callback: (Result<List<Any?>?>) -> Unit
  ) {
    flutterApi!!.echoNullableList(list) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableMap(
      map: Map<Any?, Any?>?,
      callback: (Result<Map<Any?, Any?>?>) -> Unit
  ) {
    flutterApi!!.echoNullableMap(map) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableStringMap(
      stringMap: Map<String?, String?>?,
      callback: (Result<Map<String?, String?>?>) -> Unit
  ) {
    flutterApi!!.echoNullableStringMap(stringMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableIntMap(
      intMap: Map<Long?, Long?>?,
      callback: (Result<Map<Long?, Long?>?>) -> Unit
  ) {
    flutterApi!!.echoNullableIntMap(intMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableEnum(anEnum: AnEnum?, callback: (Result<AnEnum?>) -> Unit) {
    flutterApi!!.echoNullableEnum(anEnum) { echo -> callback(echo) }
  }

  override fun callFlutterEchoAnotherNullableEnum(
      anotherEnum: AnotherEnum?,
      callback: (Result<AnotherEnum?>) -> Unit
  ) {
    flutterApi!!.echoAnotherNullableEnum(anotherEnum) { echo -> callback(echo) }
  }

  override fun callFlutterSmallApiEchoString(aString: String, callback: (Result<String>) -> Unit) {
    flutterSmallApiOne!!.echoString(aString) { echoOne ->
      flutterSmallApiTwo!!.echoString(aString) { echoTwo ->
        if (echoOne == echoTwo) {
          callback(echoTwo)
        } else {
          callback(
              Result.failure(
                  Exception("Multi-instance responses were not matching: $echoOne, $echoTwo")))
        }
      }
    }
  }

  fun testUnusedClassesGenerate(): UnusedClass {
    return UnusedClass()
  }
}

class TestPluginWithSuffix : HostSmallApi {

  fun setUp(binding: FlutterPluginBinding, suffix: String) {
    HostSmallApi.setUp(binding.binaryMessenger, this, suffix)
  }

  override fun echo(aString: String, callback: (Result<String>) -> Unit) {
    callback(Result.success(aString))
  }

  override fun voidVoid(callback: (Result<Unit>) -> Unit) {
    callback(Result.success(Unit))
  }
}
