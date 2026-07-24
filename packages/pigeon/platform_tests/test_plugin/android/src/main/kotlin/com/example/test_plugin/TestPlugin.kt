// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/** This plugin handles the native side of the integration tests in example/integration_test/. */
class TestPlugin : FlutterPlugin, HostIntegrationCoreApi {
  private var flutterApi: FlutterIntegrationCoreApi? = null
  private var flutterSmallApiOne: FlutterSmallApi? = null
  private var flutterSmallApiTwo: FlutterSmallApi? = null
  private var proxyApiRegistrar: ProxyApiRegistrar? = null
  private var niMessageApi: NativeInteropHostIntegrationCoreApiRegistrar? = null
  // private var niSmallApiOne: NIHostSmallApiRegistrar? = null
  // private var niSmallApiTwo: NIHostSmallApiRegistrar? = null

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    HostIntegrationCoreApi.setUp(binding.binaryMessenger, this)
    val testSuffixApiOne = TestPluginWithSuffix()
    testSuffixApiOne.setUp(binding, "suffixOne")
    val testSuffixApiTwo = TestPluginWithSuffix()
    testSuffixApiTwo.setUp(binding, "suffixTwo")
    niMessageApi =
        NativeInteropHostIntegrationCoreApiRegistrar().register(NativeInteropIntegrationTests())
    flutterApi = FlutterIntegrationCoreApi(binding.binaryMessenger)
    flutterSmallApiOne = FlutterSmallApi(binding.binaryMessenger, "suffixOne")
    flutterSmallApiTwo = FlutterSmallApi(binding.binaryMessenger, "suffixTwo")

    proxyApiRegistrar = ProxyApiRegistrar(binding.binaryMessenger)
    proxyApiRegistrar!!.setUp()

    StreamEventsStreamHandler.register(binding.binaryMessenger, SendClass)
    StreamIntsStreamHandler.register(binding.binaryMessenger, SendInts)
    StreamConsistentNumbersStreamHandler.register(
        binding.binaryMessenger, SendConsistentNumbers(1), "1")
    StreamConsistentNumbersStreamHandler.register(
        binding.binaryMessenger, SendConsistentNumbers(2), "2")
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    proxyApiRegistrar?.tearDown()
  }

  // HostIntegrationCoreApi

  override fun noop() {}

  override fun echoAllTypes(everything: AllTypes): AllTypes {
    return everything
  }

  override fun echoAllNullableTypes(everything: AllNullableTypes?): AllNullableTypes? {
    return everything
  }

  override fun areAllNullableTypesEqual(a: AllNullableTypes, b: AllNullableTypes): Boolean {
    return a == b
  }

  override fun getAllNullableTypesHash(value: AllNullableTypes): Long {
    return value.hashCode().toLong()
  }

  override fun getAllNullableTypesWithoutRecursionHash(
      value: AllNullableTypesWithoutRecursion
  ): Long {
    return value.hashCode().toLong()
  }

  override fun echoAllNullableTypesWithoutRecursion(
      everything: AllNullableTypesWithoutRecursion?
  ): AllNullableTypesWithoutRecursion? {
    return everything
  }

  override fun throwError(): Any {
    throw Exception("An error")
  }

  override fun throwErrorFromVoid() {
    throw Exception("An error")
  }

  override fun throwFlutterError(): Any {
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

  override fun echoStringList(stringList: List<String?>): List<String?> {
    return stringList
  }

  override fun echoIntList(intList: List<Long?>): List<Long?> {
    return intList
  }

  override fun echoDoubleList(doubleList: List<Double?>): List<Double?> {
    return doubleList
  }

  override fun echoBoolList(boolList: List<Boolean?>): List<Boolean?> {
    return boolList
  }

  override fun echoEnumList(enumList: List<AnEnum?>): List<AnEnum?> {
    return enumList
  }

  override fun echoClassList(classList: List<AllNullableTypes?>): List<AllNullableTypes?> {
    return classList
  }

  override fun echoNonNullEnumList(enumList: List<AnEnum>): List<AnEnum> {
    return enumList
  }

  override fun echoNonNullClassList(classList: List<AllNullableTypes>): List<AllNullableTypes> {
    return classList
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

  override fun echoEnumMap(enumMap: Map<AnEnum?, AnEnum?>): Map<AnEnum?, AnEnum?> {
    return enumMap
  }

  override fun echoClassMap(
      classMap: Map<Long?, AllNullableTypes?>
  ): Map<Long?, AllNullableTypes?> {
    return classMap
  }

  override fun echoNonNullStringMap(stringMap: Map<String, String>): Map<String, String> {
    return stringMap
  }

  override fun echoNonNullIntMap(intMap: Map<Long, Long>): Map<Long, Long> {
    return intMap
  }

  override fun echoNonNullEnumMap(enumMap: Map<AnEnum, AnEnum>): Map<AnEnum, AnEnum> {
    return enumMap
  }

  override fun echoNonNullClassMap(
      classMap: Map<Long, AllNullableTypes>
  ): Map<Long, AllNullableTypes> {
    return classMap
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
    return AllClassesWrapper(
        AllNullableTypes(aNullableString = nullableString),
        classList = arrayOf<AllTypes>().toList(),
        classMap = HashMap())
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

  override fun echoNullableEnumList(enumList: List<AnEnum?>?): List<AnEnum?>? {
    return enumList
  }

  override fun echoNullableClassList(
      classList: List<AllNullableTypes?>?
  ): List<AllNullableTypes?>? {
    return classList
  }

  override fun echoNullableNonNullEnumList(enumList: List<AnEnum>?): List<AnEnum>? {
    return enumList
  }

  override fun echoNullableNonNullClassList(
      classList: List<AllNullableTypes>?
  ): List<AllNullableTypes>? {
    return classList
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

  override fun echoNullableEnumMap(enumMap: Map<AnEnum?, AnEnum?>?): Map<AnEnum?, AnEnum?>? {
    return enumMap
  }

  override fun echoNullableClassMap(
      classMap: Map<Long?, AllNullableTypes?>?
  ): Map<Long?, AllNullableTypes?>? {
    return classMap
  }

  override fun echoNullableNonNullStringMap(stringMap: Map<String, String>?): Map<String, String>? {
    return stringMap
  }

  override fun echoNullableNonNullIntMap(intMap: Map<Long, Long>?): Map<Long, Long>? {
    return intMap
  }

  override fun echoNullableNonNullEnumMap(enumMap: Map<AnEnum, AnEnum>?): Map<AnEnum, AnEnum>? {
    return enumMap
  }

  override fun echoNullableNonNullClassMap(
      classMap: Map<Long, AllNullableTypes>?
  ): Map<Long, AllNullableTypes>? {
    return classMap
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

  override fun echoAsyncEnumList(
      enumList: List<AnEnum?>,
      callback: (Result<List<AnEnum?>>) -> Unit
  ) {
    callback(Result.success(enumList))
  }

  override fun echoAsyncClassList(
      classList: List<AllNullableTypes?>,
      callback: (Result<List<AllNullableTypes?>>) -> Unit
  ) {
    callback(Result.success(classList))
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

  override fun echoAsyncEnumMap(
      enumMap: Map<AnEnum?, AnEnum?>,
      callback: (Result<Map<AnEnum?, AnEnum?>>) -> Unit
  ) {
    callback(Result.success(enumMap))
  }

  override fun echoAsyncClassMap(
      classMap: Map<Long?, AllNullableTypes?>,
      callback: (Result<Map<Long?, AllNullableTypes?>>) -> Unit
  ) {
    callback(Result.success(classMap))
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

  override fun echoAsyncNullableEnumList(
      enumList: List<AnEnum?>?,
      callback: (Result<List<AnEnum?>?>) -> Unit
  ) {
    callback(Result.success(enumList))
  }

  override fun echoAsyncNullableClassList(
      classList: List<AllNullableTypes?>?,
      callback: (Result<List<AllNullableTypes?>?>) -> Unit
  ) {
    callback(Result.success(classList))
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

  override fun echoAsyncNullableEnumMap(
      enumMap: Map<AnEnum?, AnEnum?>?,
      callback: (Result<Map<AnEnum?, AnEnum?>?>) -> Unit
  ) {
    callback(Result.success(enumMap))
  }

  override fun echoAsyncNullableClassMap(
      classMap: Map<Long?, AllNullableTypes?>?,
      callback: (Result<Map<Long?, AllNullableTypes?>?>) -> Unit
  ) {
    callback(Result.success(classMap))
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

  override fun defaultIsMainThread(): Boolean {
    return Thread.currentThread() == Looper.getMainLooper().getThread()
  }

  override fun taskQueueIsBackgroundThread(): Boolean {
    return Thread.currentThread() != Looper.getMainLooper().getThread()
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

  override fun callFlutterEchoEnumList(
      enumList: List<AnEnum?>,
      callback: (Result<List<AnEnum?>>) -> Unit
  ) {
    flutterApi!!.echoEnumList(enumList) { echo -> callback(echo) }
  }

  override fun callFlutterEchoClassList(
      classList: List<AllNullableTypes?>,
      callback: (Result<List<AllNullableTypes?>>) -> Unit
  ) {
    flutterApi!!.echoClassList(classList) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNonNullEnumList(
      enumList: List<AnEnum>,
      callback: (Result<List<AnEnum>>) -> Unit
  ) {
    flutterApi!!.echoNonNullEnumList(enumList) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNonNullClassList(
      classList: List<AllNullableTypes>,
      callback: (Result<List<AllNullableTypes>>) -> Unit
  ) {
    flutterApi!!.echoNonNullClassList(classList) { echo -> callback(echo) }
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

  override fun callFlutterEchoEnumMap(
      enumMap: Map<AnEnum?, AnEnum?>,
      callback: (Result<Map<AnEnum?, AnEnum?>>) -> Unit
  ) {
    flutterApi!!.echoEnumMap(enumMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoClassMap(
      classMap: Map<Long?, AllNullableTypes?>,
      callback: (Result<Map<Long?, AllNullableTypes?>>) -> Unit
  ) {
    flutterApi!!.echoClassMap(classMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNonNullStringMap(
      stringMap: Map<String, String>,
      callback: (Result<Map<String, String>>) -> Unit
  ) {
    flutterApi!!.echoNonNullStringMap(stringMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNonNullIntMap(
      intMap: Map<Long, Long>,
      callback: (Result<Map<Long, Long>>) -> Unit
  ) {
    flutterApi!!.echoNonNullIntMap(intMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNonNullEnumMap(
      enumMap: Map<AnEnum, AnEnum>,
      callback: (Result<Map<AnEnum, AnEnum>>) -> Unit
  ) {
    flutterApi!!.echoNonNullEnumMap(enumMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNonNullClassMap(
      classMap: Map<Long, AllNullableTypes>,
      callback: (Result<Map<Long, AllNullableTypes>>) -> Unit
  ) {
    flutterApi!!.echoNonNullClassMap(classMap) { echo -> callback(echo) }
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

  override fun callFlutterEchoNullableEnumList(
      enumList: List<AnEnum?>?,
      callback: (Result<List<AnEnum?>?>) -> Unit
  ) {
    flutterApi!!.echoNullableEnumList(enumList) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableClassList(
      classList: List<AllNullableTypes?>?,
      callback: (Result<List<AllNullableTypes?>?>) -> Unit
  ) {
    flutterApi!!.echoNullableClassList(classList) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableNonNullEnumList(
      enumList: List<AnEnum>?,
      callback: (Result<List<AnEnum>?>) -> Unit
  ) {
    flutterApi!!.echoNullableNonNullEnumList(enumList) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableNonNullClassList(
      classList: List<AllNullableTypes>?,
      callback: (Result<List<AllNullableTypes>?>) -> Unit
  ) {
    flutterApi!!.echoNullableNonNullClassList(classList) { echo -> callback(echo) }
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

  override fun callFlutterEchoNullableEnumMap(
      enumMap: Map<AnEnum?, AnEnum?>?,
      callback: (Result<Map<AnEnum?, AnEnum?>?>) -> Unit
  ) {
    flutterApi!!.echoNullableEnumMap(enumMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableClassMap(
      classMap: Map<Long?, AllNullableTypes?>?,
      callback: (Result<Map<Long?, AllNullableTypes?>?>) -> Unit
  ) {
    flutterApi!!.echoNullableClassMap(classMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableNonNullStringMap(
      stringMap: Map<String, String>?,
      callback: (Result<Map<String, String>?>) -> Unit
  ) {
    flutterApi!!.echoNullableNonNullStringMap(stringMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableNonNullIntMap(
      intMap: Map<Long, Long>?,
      callback: (Result<Map<Long, Long>?>) -> Unit
  ) {
    flutterApi!!.echoNullableNonNullIntMap(intMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableNonNullEnumMap(
      enumMap: Map<AnEnum, AnEnum>?,
      callback: (Result<Map<AnEnum, AnEnum>?>) -> Unit
  ) {
    flutterApi!!.echoNullableNonNullEnumMap(enumMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableNonNullClassMap(
      classMap: Map<Long, AllNullableTypes>?,
      callback: (Result<Map<Long, AllNullableTypes>?>) -> Unit
  ) {
    flutterApi!!.echoNullableNonNullClassMap(classMap) { echo -> callback(echo) }
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

class NativeInteropIntegrationTests : NativeInteropHostIntegrationCoreApi() {
  override fun noop() {}

  override fun echoAllTypes(everything: NativeInteropAllTypes): NativeInteropAllTypes {
    return everything
  }

  override fun throwError(): Any? {
    throw Exception("An error")
  }

  override fun throwErrorFromVoid() {
    throw Exception("An error")
  }

  override fun throwFlutterError(): Any? {
    throw NativeInteropTestsError("code", "message", "details")
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

  override fun echoInt32List(aInt32List: IntArray): IntArray {
    return aInt32List
  }

  override fun echoInt64List(aInt64List: LongArray): LongArray {
    return aInt64List
  }

  override fun echoFloat64List(aFloat64List: DoubleArray): DoubleArray {
    return aFloat64List
  }

  override fun echoObject(anObject: Any): Any {
    return anObject
  }

  override fun echoList(list: List<Any?>): List<Any?> {
    return list
  }

  override fun echoStringList(stringList: List<String?>): List<String?> {
    return stringList
  }

  override fun echoIntList(intList: List<Long?>): List<Long?> {
    return intList
  }

  override fun echoDoubleList(doubleList: List<Double?>): List<Double?> {
    return doubleList
  }

  override fun echoBoolList(boolList: List<Boolean?>): List<Boolean?> {
    return boolList
  }

  override fun echoEnumList(enumList: List<NativeInteropAnEnum?>): List<NativeInteropAnEnum?> {
    return enumList
  }

  override fun echoClassList(
      classList: List<NativeInteropAllNullableTypes?>
  ): List<NativeInteropAllNullableTypes?> {
    return classList
  }

  override fun echoNonNullEnumList(enumList: List<NativeInteropAnEnum>): List<NativeInteropAnEnum> {
    return enumList
  }

  override fun echoNonNullClassList(
      classList: List<NativeInteropAllNullableTypes>
  ): List<NativeInteropAllNullableTypes> {
    return classList
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

  override fun echoEnumMap(
      enumMap: Map<NativeInteropAnEnum?, NativeInteropAnEnum?>
  ): Map<NativeInteropAnEnum?, NativeInteropAnEnum?> {
    return enumMap
  }

  override fun echoClassMap(
      classMap: Map<Long?, NativeInteropAllNullableTypes?>
  ): Map<Long?, NativeInteropAllNullableTypes?> {
    return classMap
  }

  override fun echoNonNullStringMap(stringMap: Map<String, String>): Map<String, String> {
    return stringMap
  }

  override fun echoNonNullIntMap(intMap: Map<Long, Long>): Map<Long, Long> {
    return intMap
  }

  override fun echoNonNullEnumMap(
      enumMap: Map<NativeInteropAnEnum, NativeInteropAnEnum>
  ): Map<NativeInteropAnEnum, NativeInteropAnEnum> {
    return enumMap
  }

  override fun echoNonNullClassMap(
      classMap: Map<Long, NativeInteropAllNullableTypes>
  ): Map<Long, NativeInteropAllNullableTypes> {
    return classMap
  }

  override fun echoClassWrapper(
      wrapper: NativeInteropAllClassesWrapper
  ): NativeInteropAllClassesWrapper {
    return wrapper
  }

  override fun echoEnum(anEnum: NativeInteropAnEnum): NativeInteropAnEnum {
    return anEnum
  }

  override fun echoAnotherEnum(anotherEnum: NativeInteropAnotherEnum): NativeInteropAnotherEnum {
    return anotherEnum
  }
  //
  override fun echoNamedDefaultString(aString: String): String {
    return aString
  }

  override fun echoOptionalDefaultDouble(aDouble: Double): Double {
    return aDouble
  }

  override fun echoRequiredInt(anInt: Long): Long {
    return anInt
  }

  override fun echoAllNullableTypes(
      everything: NativeInteropAllNullableTypes?
  ): NativeInteropAllNullableTypes? {
    return everything
  }

  override fun echoAllNullableTypesWithoutRecursion(
      everything: NativeInteropAllNullableTypesWithoutRecursion?
  ): NativeInteropAllNullableTypesWithoutRecursion? {
    return everything
  }

  override fun extractNestedNullableString(wrapper: NativeInteropAllClassesWrapper): String? {
    return wrapper.allNullableTypes.aNullableString
  }

  override fun createNestedNullableString(nullableString: String?): NativeInteropAllClassesWrapper {
    return NativeInteropAllClassesWrapper(
        NativeInteropAllNullableTypes(aNullableString = nullableString),
        classList = arrayOf<NativeInteropAllTypes>().toList(),
        classMap = HashMap())
  }

  override fun sendMultipleNullableTypes(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?
  ): NativeInteropAllNullableTypes {
    return NativeInteropAllNullableTypes(
        aNullableBool = aNullableBool,
        aNullableInt = aNullableInt,
        aNullableString = aNullableString)
  }

  override fun sendMultipleNullableTypesWithoutRecursion(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?
  ): NativeInteropAllNullableTypesWithoutRecursion {
    return NativeInteropAllNullableTypesWithoutRecursion(
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

  override fun echoNullableInt32List(aNullableInt32List: IntArray?): IntArray? {
    return aNullableInt32List
  }

  override fun echoNullableInt64List(aNullableInt64List: LongArray?): LongArray? {
    return aNullableInt64List
  }

  override fun echoNullableFloat64List(aNullableFloat64List: DoubleArray?): DoubleArray? {
    return aNullableFloat64List
  }

  override fun echoNullableObject(aNullableObject: Any?): Any? {
    return aNullableObject
  }

  override fun echoNullableList(aNullableList: List<Any?>?): List<Any?>? {
    return aNullableList
  }

  override fun echoNullableEnumList(
      enumList: List<NativeInteropAnEnum?>?
  ): List<NativeInteropAnEnum?>? {
    return enumList
  }

  override fun echoNullableClassList(
      classList: List<NativeInteropAllNullableTypes?>?
  ): List<NativeInteropAllNullableTypes?>? {
    return classList
  }

  override fun echoNullableNonNullEnumList(
      enumList: List<NativeInteropAnEnum>?
  ): List<NativeInteropAnEnum>? {
    return enumList
  }

  override fun echoNullableNonNullClassList(
      classList: List<NativeInteropAllNullableTypes>?
  ): List<NativeInteropAllNullableTypes>? {
    return classList
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

  override fun echoNullableEnumMap(
      enumMap: Map<NativeInteropAnEnum?, NativeInteropAnEnum?>?
  ): Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? {
    return enumMap
  }

  override fun echoNullableClassMap(
      classMap: Map<Long?, NativeInteropAllNullableTypes?>?
  ): Map<Long?, NativeInteropAllNullableTypes?>? {
    return classMap
  }

  override fun echoNullableNonNullStringMap(stringMap: Map<String, String>?): Map<String, String>? {
    return stringMap
  }

  override fun echoNullableNonNullIntMap(intMap: Map<Long, Long>?): Map<Long, Long>? {
    return intMap
  }

  override fun echoNullableNonNullEnumMap(
      enumMap: Map<NativeInteropAnEnum, NativeInteropAnEnum>?
  ): Map<NativeInteropAnEnum, NativeInteropAnEnum>? {
    return enumMap
  }

  override fun echoNullableNonNullClassMap(
      classMap: Map<Long, NativeInteropAllNullableTypes>?
  ): Map<Long, NativeInteropAllNullableTypes>? {
    return classMap
  }

  override fun echoNullableEnum(anEnum: NativeInteropAnEnum?): NativeInteropAnEnum? {
    return anEnum
  }

  override fun echoAnotherNullableEnum(
      anotherEnum: NativeInteropAnotherEnum?
  ): NativeInteropAnotherEnum? {
    return anotherEnum
  }

  override fun echoOptionalNullableInt(aNullableInt: Long?): Long? {
    return aNullableInt
  }

  override fun echoNamedNullableString(aNullableString: String?): String? {
    return aNullableString
  }

  override suspend fun noopAsync() {
    return
  }

  override suspend fun echoAsyncInt(anInt: Long): Long {
    return anInt
  }

  override suspend fun echoAsyncDouble(aDouble: Double): Double {
    return aDouble
  }

  override suspend fun echoAsyncBool(aBool: Boolean): Boolean {
    return aBool
  }

  override suspend fun echoAsyncString(aString: String): String {
    return aString
  }

  override suspend fun echoAsyncUint8List(aUint8List: ByteArray): ByteArray {
    return aUint8List
  }

  override suspend fun echoAsyncInt32List(aInt32List: IntArray): IntArray {
    return aInt32List
  }

  override suspend fun echoAsyncInt64List(aInt64List: LongArray): LongArray {
    return aInt64List
  }

  override suspend fun echoAsyncFloat64List(aFloat64List: DoubleArray): DoubleArray {
    return aFloat64List
  }

  override suspend fun echoAsyncObject(anObject: Any): Any {
    return anObject
  }

  override suspend fun echoAsyncList(list: List<Any?>): List<Any?> {
    return list
  }

  override suspend fun echoAsyncEnumList(
      enumList: List<NativeInteropAnEnum?>
  ): List<NativeInteropAnEnum?> {
    return enumList
  }

  override suspend fun echoAsyncClassList(
      classList: List<NativeInteropAllNullableTypes?>
  ): List<NativeInteropAllNullableTypes?> {
    return classList
  }

  override suspend fun echoAsyncMap(map: Map<Any?, Any?>): Map<Any?, Any?> {
    return map
  }

  override suspend fun echoAsyncStringMap(stringMap: Map<String?, String?>): Map<String?, String?> {
    return stringMap
  }

  override suspend fun echoAsyncIntMap(intMap: Map<Long?, Long?>): Map<Long?, Long?> {
    return intMap
  }

  override suspend fun echoAsyncEnumMap(
      enumMap: Map<NativeInteropAnEnum?, NativeInteropAnEnum?>
  ): Map<NativeInteropAnEnum?, NativeInteropAnEnum?> {
    return enumMap
  }

  override suspend fun echoAsyncClassMap(
      classMap: Map<Long?, NativeInteropAllNullableTypes?>
  ): Map<Long?, NativeInteropAllNullableTypes?> {
    return classMap
  }

  override suspend fun echoAsyncEnum(anEnum: NativeInteropAnEnum): NativeInteropAnEnum {
    return anEnum
  }

  override suspend fun echoAnotherAsyncEnum(
      anotherEnum: NativeInteropAnotherEnum
  ): NativeInteropAnotherEnum {
    return anotherEnum
  }

  override suspend fun throwAsyncError(): Any? {
    throw Exception("An error")
  }

  override suspend fun throwAsyncErrorFromVoid() {
    throw Exception("An error")
  }

  override suspend fun throwAsyncFlutterError(): Any? {
    throw NativeInteropTestsError("code", "message", "details")
  }

  override suspend fun echoAsyncNativeInteropAllTypes(
      everything: NativeInteropAllTypes
  ): NativeInteropAllTypes {
    return everything
  }

  override suspend fun echoAsyncNullableNativeInteropAllNullableTypes(
      everything: NativeInteropAllNullableTypes?
  ): NativeInteropAllNullableTypes? {
    return everything
  }

  override suspend fun echoAsyncNullableNativeInteropAllNullableTypesWithoutRecursion(
      everything: NativeInteropAllNullableTypesWithoutRecursion?
  ): NativeInteropAllNullableTypesWithoutRecursion? {
    return everything
  }

  override suspend fun echoAsyncNullableInt(anInt: Long?): Long? {
    return anInt
  }

  override suspend fun echoAsyncNullableDouble(aDouble: Double?): Double? {
    return aDouble
  }

  override suspend fun echoAsyncNullableBool(aBool: Boolean?): Boolean? {
    return aBool
  }

  override suspend fun echoAsyncNullableString(aString: String?): String? {
    return aString
  }

  override suspend fun echoAsyncNullableUint8List(aUint8List: ByteArray?): ByteArray? {
    return aUint8List
  }

  override suspend fun echoAsyncNullableInt32List(aInt32List: IntArray?): IntArray? {
    return aInt32List
  }

  override suspend fun echoAsyncNullableInt64List(aInt64List: LongArray?): LongArray? {
    return aInt64List
  }

  override suspend fun echoAsyncNullableFloat64List(aFloat64List: DoubleArray?): DoubleArray? {
    return aFloat64List
  }

  override suspend fun echoAsyncNullableObject(anObject: Any?): Any? {
    return anObject
  }

  override suspend fun echoAsyncNullableList(list: List<Any?>?): List<Any?>? {
    return list
  }

  override suspend fun echoAsyncNullableEnumList(
      enumList: List<NativeInteropAnEnum?>?
  ): List<NativeInteropAnEnum?>? {
    return enumList
  }

  override suspend fun echoAsyncNullableClassList(
      classList: List<NativeInteropAllNullableTypes?>?
  ): List<NativeInteropAllNullableTypes?>? {
    return classList
  }

  override suspend fun echoAsyncNullableMap(map: Map<Any?, Any?>?): Map<Any?, Any?>? {
    return map
  }

  override suspend fun echoAsyncNullableStringMap(
      stringMap: Map<String?, String?>?
  ): Map<String?, String?>? {
    return stringMap
  }

  override suspend fun echoAsyncNullableIntMap(intMap: Map<Long?, Long?>?): Map<Long?, Long?>? {
    return intMap
  }

  override suspend fun echoAsyncNullableEnumMap(
      enumMap: Map<NativeInteropAnEnum?, NativeInteropAnEnum?>?
  ): Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? {
    return enumMap
  }

  override suspend fun echoAsyncNullableClassMap(
      classMap: Map<Long?, NativeInteropAllNullableTypes?>?
  ): Map<Long?, NativeInteropAllNullableTypes?>? {
    return classMap
  }

  override suspend fun echoAsyncNullableEnum(anEnum: NativeInteropAnEnum?): NativeInteropAnEnum? {
    return anEnum
  }

  override suspend fun echoAnotherAsyncNullableEnum(
      anotherEnum: NativeInteropAnotherEnum?
  ): NativeInteropAnotherEnum? {
    return anotherEnum
  }

  override fun callFlutterNoop() {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.noop()
  }

  override fun callFlutterThrowError(): Any? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.throwError()
  }

  override fun callFlutterThrowErrorFromVoid() {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.throwErrorFromVoid()
  }

  override fun callFlutterEchoNativeInteropAllTypes(
      everything: NativeInteropAllTypes
  ): NativeInteropAllTypes {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNativeInteropAllTypes(everything)
  }

  override fun callFlutterEchoNativeInteropAllNullableTypes(
      everything: NativeInteropAllNullableTypes?
  ): NativeInteropAllNullableTypes? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNativeInteropAllNullableTypes(everything)
  }

  override fun callFlutterSendMultipleNullableTypes(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?
  ): NativeInteropAllNullableTypes {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .sendMultipleNullableTypes(aNullableBool, aNullableInt, aNullableString)
  }

  override fun callFlutterEchoNativeInteropAllNullableTypesWithoutRecursion(
      everything: NativeInteropAllNullableTypesWithoutRecursion?
  ): NativeInteropAllNullableTypesWithoutRecursion? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNativeInteropAllNullableTypesWithoutRecursion(everything)
  }

  override fun callFlutterSendMultipleNullableTypesWithoutRecursion(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?
  ): NativeInteropAllNullableTypesWithoutRecursion {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .sendMultipleNullableTypesWithoutRecursion(aNullableBool, aNullableInt, aNullableString)
  }

  override fun callFlutterEchoBool(aBool: Boolean): Boolean {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoBool(aBool)
  }

  override fun callFlutterEchoInt(anInt: Long): Long {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoInt(anInt)
  }

  override fun callFlutterEchoDouble(aDouble: Double): Double {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoDouble(aDouble)
  }
  //
  override fun callFlutterEchoString(aString: String): String {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoString(aString)
  }

  override fun callFlutterEchoUint8List(list: ByteArray): ByteArray {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoUint8List(list)
  }

  override fun callFlutterEchoInt32List(list: IntArray): IntArray {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoInt32List(list)
  }

  override fun callFlutterEchoInt64List(list: LongArray): LongArray {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoInt64List(list)
  }

  override fun callFlutterEchoFloat64List(list: DoubleArray): DoubleArray {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoFloat64List(list)
  }

  override fun callFlutterEchoList(list: List<Any?>): List<Any?> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoList(list)
  }

  override fun callFlutterEchoEnumList(
      enumList: List<NativeInteropAnEnum?>
  ): List<NativeInteropAnEnum?> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoEnumList(enumList)
  }

  override fun callFlutterEchoClassList(
      classList: List<NativeInteropAllNullableTypes?>
  ): List<NativeInteropAllNullableTypes?> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoClassList(classList)
  }

  override fun callFlutterEchoNonNullEnumList(
      enumList: List<NativeInteropAnEnum>
  ): List<NativeInteropAnEnum> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNonNullEnumList(enumList)
  }

  override fun callFlutterEchoNonNullClassList(
      classList: List<NativeInteropAllNullableTypes>
  ): List<NativeInteropAllNullableTypes> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNonNullClassList(classList)
  }

  override fun callFlutterEchoMap(map: Map<Any?, Any?>): Map<Any?, Any?> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoMap(map)
  }

  override fun callFlutterEchoStringMap(stringMap: Map<String?, String?>): Map<String?, String?> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoStringMap(stringMap)
  }

  override fun callFlutterEchoIntMap(intMap: Map<Long?, Long?>): Map<Long?, Long?> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoIntMap(intMap)
  }

  override fun callFlutterEchoEnumMap(
      enumMap: Map<NativeInteropAnEnum?, NativeInteropAnEnum?>
  ): Map<NativeInteropAnEnum?, NativeInteropAnEnum?> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoEnumMap(enumMap)
  }

  override fun callFlutterEchoClassMap(
      classMap: Map<Long?, NativeInteropAllNullableTypes?>
  ): Map<Long?, NativeInteropAllNullableTypes?> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoClassMap(classMap)
  }

  override fun callFlutterEchoNonNullStringMap(
      stringMap: Map<String, String>
  ): Map<String, String> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNonNullStringMap(stringMap)
  }

  override fun callFlutterEchoNonNullIntMap(intMap: Map<Long, Long>): Map<Long, Long> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNonNullIntMap(intMap)
  }

  override fun callFlutterEchoNonNullEnumMap(
      enumMap: Map<NativeInteropAnEnum, NativeInteropAnEnum>
  ): Map<NativeInteropAnEnum, NativeInteropAnEnum> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNonNullEnumMap(enumMap)
  }

  override fun callFlutterEchoNonNullClassMap(
      classMap: Map<Long, NativeInteropAllNullableTypes>
  ): Map<Long, NativeInteropAllNullableTypes> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNonNullClassMap(classMap)
  }

  override fun callFlutterEchoEnum(anEnum: NativeInteropAnEnum): NativeInteropAnEnum {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoEnum(anEnum)
  }

  override fun callFlutterEchoNativeInteropAnotherEnum(
      anotherEnum: NativeInteropAnotherEnum
  ): NativeInteropAnotherEnum {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNativeInteropAnotherEnum(anotherEnum)
  }

  override fun callFlutterEchoNullableBool(aBool: Boolean?): Boolean? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableBool(aBool)
  }

  override fun callFlutterEchoNullableInt(anInt: Long?): Long? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableInt(anInt)
  }

  override fun callFlutterEchoNullableDouble(aDouble: Double?): Double? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableDouble(aDouble)
  }

  override fun callFlutterEchoNullableString(aString: String?): String? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableString(aString)
  }

  override fun callFlutterEchoNullableUint8List(list: ByteArray?): ByteArray? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableUint8List(list)
  }

  override fun callFlutterEchoNullableInt32List(list: IntArray?): IntArray? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableInt32List(list)
  }

  override fun callFlutterEchoNullableInt64List(list: LongArray?): LongArray? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableInt64List(list)
  }

  override fun callFlutterEchoNullableFloat64List(list: DoubleArray?): DoubleArray? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableFloat64List(list)
  }

  override fun callFlutterEchoNullableList(list: List<Any?>?): List<Any?>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableList(list)
  }

  override fun callFlutterEchoNullableEnumList(
      enumList: List<NativeInteropAnEnum?>?
  ): List<NativeInteropAnEnum?>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableEnumList(enumList)
  }

  override fun callFlutterEchoNullableClassList(
      classList: List<NativeInteropAllNullableTypes?>?
  ): List<NativeInteropAllNullableTypes?>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableClassList(classList)
  }

  override fun callFlutterEchoNullableNonNullEnumList(
      enumList: List<NativeInteropAnEnum>?
  ): List<NativeInteropAnEnum>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableNonNullEnumList(enumList)
  }

  override fun callFlutterEchoNullableNonNullClassList(
      classList: List<NativeInteropAllNullableTypes>?
  ): List<NativeInteropAllNullableTypes>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableNonNullClassList(classList)
  }

  override fun callFlutterEchoNullableMap(map: Map<Any?, Any?>?): Map<Any?, Any?>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableMap(map)
  }

  override fun callFlutterEchoNullableStringMap(
      stringMap: Map<String?, String?>?
  ): Map<String?, String?>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableStringMap(stringMap)
  }

  override fun callFlutterEchoNullableIntMap(intMap: Map<Long?, Long?>?): Map<Long?, Long?>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableIntMap(intMap)
  }

  override fun callFlutterEchoNullableEnumMap(
      enumMap: Map<NativeInteropAnEnum?, NativeInteropAnEnum?>?
  ): Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableEnumMap(enumMap)
  }

  override fun callFlutterEchoNullableClassMap(
      classMap: Map<Long?, NativeInteropAllNullableTypes?>?
  ): Map<Long?, NativeInteropAllNullableTypes?>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableClassMap(classMap)
  }

  override fun callFlutterEchoNullableNonNullStringMap(
      stringMap: Map<String, String>?
  ): Map<String, String>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableNonNullStringMap(stringMap)
  }

  override fun callFlutterEchoNullableNonNullIntMap(intMap: Map<Long, Long>?): Map<Long, Long>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableNonNullIntMap(intMap)
  }

  override fun callFlutterEchoNullableNonNullEnumMap(
      enumMap: Map<NativeInteropAnEnum, NativeInteropAnEnum>?
  ): Map<NativeInteropAnEnum, NativeInteropAnEnum>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableNonNullEnumMap(enumMap)
  }

  override fun callFlutterEchoNullableNonNullClassMap(
      classMap: Map<Long, NativeInteropAllNullableTypes>?
  ): Map<Long, NativeInteropAllNullableTypes>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableNonNullClassMap(classMap)
  }

  override fun callFlutterEchoNullableEnum(anEnum: NativeInteropAnEnum?): NativeInteropAnEnum? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoNullableEnum(anEnum)
  }

  override fun callFlutterEchoAnotherNullableEnum(
      anotherEnum: NativeInteropAnotherEnum?
  ): NativeInteropAnotherEnum? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAnotherNullableEnum(anotherEnum)
  }

  override suspend fun callFlutterNoopAsync() {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.noopAsync()
  }

  override suspend fun callFlutterEchoAsyncNativeInteropAllTypes(
      everything: NativeInteropAllTypes
  ): NativeInteropAllTypes {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNativeInteropAllTypes(everything)
  }

  override suspend fun callFlutterEchoAsyncNullableNativeInteropAllNullableTypes(
      everything: NativeInteropAllNullableTypes?
  ): NativeInteropAllNullableTypes? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableNativeInteropAllNullableTypes(everything)
  }

  override suspend fun callFlutterEchoAsyncNullableNativeInteropAllNullableTypesWithoutRecursion(
      everything: NativeInteropAllNullableTypesWithoutRecursion?
  ): NativeInteropAllNullableTypesWithoutRecursion? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableNativeInteropAllNullableTypesWithoutRecursion(everything)
  }

  override suspend fun callFlutterEchoAsyncBool(aBool: Boolean): Boolean {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoAsyncBool(aBool)
  }

  override suspend fun callFlutterEchoAsyncInt(anInt: Long): Long {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoAsyncInt(anInt)
  }

  override suspend fun callFlutterEchoAsyncDouble(aDouble: Double): Double {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncDouble(aDouble)
  }

  override suspend fun callFlutterEchoAsyncString(aString: String): String {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncString(aString)
  }

  override suspend fun callFlutterEchoAsyncUint8List(list: ByteArray): ByteArray {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncUint8List(list)
  }

  override suspend fun callFlutterEchoAsyncInt32List(list: IntArray): IntArray {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncInt32List(list)
  }

  override suspend fun callFlutterEchoAsyncInt64List(list: LongArray): LongArray {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncInt64List(list)
  }

  override suspend fun callFlutterEchoAsyncFloat64List(list: DoubleArray): DoubleArray {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncFloat64List(list)
  }

  override suspend fun callFlutterEchoAsyncObject(anObject: Any): Any {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncObject(anObject)
  }

  override suspend fun callFlutterEchoAsyncList(list: List<Any?>): List<Any?> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoAsyncList(list)
  }

  override suspend fun callFlutterEchoAsyncEnumList(
      enumList: List<NativeInteropAnEnum?>
  ): List<NativeInteropAnEnum?> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncEnumList(enumList)
  }

  override suspend fun callFlutterEchoAsyncClassList(
      classList: List<NativeInteropAllNullableTypes?>
  ): List<NativeInteropAllNullableTypes?> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncClassList(classList)
  }

  override suspend fun callFlutterEchoAsyncNonNullEnumList(
      enumList: List<NativeInteropAnEnum>
  ): List<NativeInteropAnEnum> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNonNullEnumList(enumList)
  }

  override suspend fun callFlutterEchoAsyncNonNullClassList(
      classList: List<NativeInteropAllNullableTypes>
  ): List<NativeInteropAllNullableTypes> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNonNullClassList(classList)
  }

  override suspend fun callFlutterEchoAsyncMap(map: Map<Any?, Any?>): Map<Any?, Any?> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoAsyncMap(map)
  }

  override suspend fun callFlutterEchoAsyncStringMap(
      stringMap: Map<String?, String?>
  ): Map<String?, String?> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncStringMap(stringMap)
  }

  override suspend fun callFlutterEchoAsyncIntMap(intMap: Map<Long?, Long?>): Map<Long?, Long?> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoAsyncIntMap(intMap)
  }

  override suspend fun callFlutterEchoAsyncEnumMap(
      enumMap: Map<NativeInteropAnEnum?, NativeInteropAnEnum?>
  ): Map<NativeInteropAnEnum?, NativeInteropAnEnum?> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncEnumMap(enumMap)
  }

  override suspend fun callFlutterEchoAsyncClassMap(
      classMap: Map<Long?, NativeInteropAllNullableTypes?>
  ): Map<Long?, NativeInteropAllNullableTypes?> {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncClassMap(classMap)
  }

  override suspend fun callFlutterEchoAsyncEnum(anEnum: NativeInteropAnEnum): NativeInteropAnEnum {
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoAsyncEnum(anEnum)
  }

  override suspend fun callFlutterEchoAnotherAsyncEnum(
      anotherEnum: NativeInteropAnotherEnum
  ): NativeInteropAnotherEnum {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAnotherAsyncEnum(anotherEnum)
  }

  override suspend fun callFlutterEchoAsyncNullableBool(aBool: Boolean?): Boolean? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableBool(aBool)
  }

  override suspend fun callFlutterEchoAsyncNullableInt(anInt: Long?): Long? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableInt(anInt)
  }

  override suspend fun callFlutterEchoAsyncNullableDouble(aDouble: Double?): Double? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableDouble(aDouble)
  }

  override suspend fun callFlutterEchoAsyncNullableString(aString: String?): String? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableString(aString)
  }

  override suspend fun callFlutterEchoAsyncNullableUint8List(list: ByteArray?): ByteArray? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableUint8List(list)
  }

  override suspend fun callFlutterEchoAsyncNullableInt32List(list: IntArray?): IntArray? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableInt32List(list)
  }

  override suspend fun callFlutterEchoAsyncNullableInt64List(list: LongArray?): LongArray? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableInt64List(list)
  }

  override suspend fun callFlutterEchoAsyncNullableFloat64List(list: DoubleArray?): DoubleArray? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableFloat64List(list)
  }

  override suspend fun callFlutterThrowFlutterErrorAsync(): Any? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .throwFlutterErrorAsync()
  }

  override suspend fun callFlutterEchoAsyncNullableObject(anObject: Any?): Any? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableObject(anObject)
  }

  override suspend fun callFlutterEchoAsyncNullableList(list: List<Any?>?): List<Any?>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableList(list)
  }

  override suspend fun callFlutterEchoAsyncNullableEnumList(
      enumList: List<NativeInteropAnEnum?>?
  ): List<NativeInteropAnEnum?>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableEnumList(enumList)
  }

  override suspend fun callFlutterEchoAsyncNullableClassList(
      classList: List<NativeInteropAllNullableTypes?>?
  ): List<NativeInteropAllNullableTypes?>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableClassList(classList)
  }

  override suspend fun callFlutterEchoAsyncNullableNonNullEnumList(
      enumList: List<NativeInteropAnEnum>?
  ): List<NativeInteropAnEnum>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableNonNullEnumList(enumList)
  }

  override suspend fun callFlutterEchoAsyncNullableNonNullClassList(
      classList: List<NativeInteropAllNullableTypes>?
  ): List<NativeInteropAllNullableTypes>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableNonNullClassList(classList)
  }

  override suspend fun callFlutterEchoAsyncNullableMap(map: Map<Any?, Any?>?): Map<Any?, Any?>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableMap(map)
  }

  override suspend fun callFlutterEchoAsyncNullableStringMap(
      stringMap: Map<String?, String?>?
  ): Map<String?, String?>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableStringMap(stringMap)
  }

  override suspend fun callFlutterEchoAsyncNullableIntMap(
      intMap: Map<Long?, Long?>?
  ): Map<Long?, Long?>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableIntMap(intMap)
  }

  override suspend fun callFlutterEchoAsyncNullableEnumMap(
      enumMap: Map<NativeInteropAnEnum?, NativeInteropAnEnum?>?
  ): Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableEnumMap(enumMap)
  }

  override suspend fun callFlutterEchoAsyncNullableClassMap(
      classMap: Map<Long?, NativeInteropAllNullableTypes?>?
  ): Map<Long?, NativeInteropAllNullableTypes?>? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableClassMap(classMap)
  }

  override suspend fun callFlutterEchoAsyncNullableEnum(
      anEnum: NativeInteropAnEnum?
  ): NativeInteropAnEnum? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAsyncNullableEnum(anEnum)
  }

  override suspend fun callFlutterEchoAnotherAsyncNullableEnum(
      anotherEnum: NativeInteropAnotherEnum?
  ): NativeInteropAnotherEnum? {
    return NativeInteropFlutterIntegrationCoreApiRegistrar()
        .getInstance()!!
        .echoAnotherAsyncNullableEnum(anotherEnum)
  }

  override fun defaultIsMainThread(): Boolean {
    return Thread.currentThread() == Looper.getMainLooper().thread
  }

  override suspend fun callFlutterNoopOnBackgroundThread(): Boolean {
    return withContext(Dispatchers.Default) {
      try {
        NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance()!!.noopAsync()
        true
      } catch (e: Exception) {
        false
      }
    }
  }

  override fun testDeregisterHostApi(): Boolean {
    val name = "testDeregisterHostInstance"
    NativeInteropHostIntegrationCoreApiRegistrar()
        .register(NativeInteropIntegrationTests(), name = name)
    if (NativeInteropHostIntegrationCoreApiRegistrar().getInstance(name) == null) {
      return false
    }
    NativeInteropHostIntegrationCoreApiRegistrar().register(null, name = name)
    return NativeInteropHostIntegrationCoreApiRegistrar().getInstance(name) == null
  }

  override fun testDeregisterFlutterApi(): Boolean {
    val name = "testDeregisterFlutterInstance"
    NativeInteropFlutterIntegrationCoreApiRegistrar().registerInstance(null, name = name)
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance(name) == null
  }

  override fun registerAndImmediatelyDeregisterHostApi(name: String) {
    NativeInteropHostIntegrationCoreApiRegistrar()
        .register(NativeInteropIntegrationTests(), name = name)
    NativeInteropHostIntegrationCoreApiRegistrar().register(null, name = name)
  }

  override fun testCallDeregisteredFlutterApi(name: String): Boolean {
    NativeInteropFlutterIntegrationCoreApiRegistrar().registerInstance(null, name = name)
    return NativeInteropFlutterIntegrationCoreApiRegistrar().getInstance(name) == null
  }
}

//   class NIHostSmallApiTests : NIHostSmallApi() {
//     override suspend fun echo(aString: String): String {
//       return aString
//     }
//
//     override suspend fun voidVoid() {
//       return
//     }
// }

object SendInts : StreamIntsStreamHandler() {
  val handler = Handler(Looper.getMainLooper())

  override fun onListen(p0: Any?, sink: PigeonEventSink<Long>) {
    var count: Long = 0
    val r: Runnable =
        object : Runnable {
          override fun run() {
            handler.post {
              if (count >= 5) {
                sink.endOfStream()
              } else {
                sink.success(count)
                count++
                handler.postDelayed(this, 10)
              }
            }
          }
        }
    handler.postDelayed(r, 10)
  }
}

object SendClass : StreamEventsStreamHandler() {
  val handler = Handler(Looper.getMainLooper())
  val eventList =
      listOf(
          IntEvent(1),
          StringEvent("string"),
          BoolEvent(false),
          DoubleEvent(3.14),
          ObjectsEvent(true),
          EnumEvent(EventEnum.FORTY_TWO),
          ClassEvent(EventAllNullableTypes(aNullableInt = 0)),
          EmptyEvent())

  override fun onListen(p0: Any?, sink: PigeonEventSink<PlatformEvent>) {
    var count = 0
    val r: Runnable =
        object : Runnable {
          override fun run() {
            if (count >= eventList.size) {
              sink.endOfStream()
            } else {
              handler.post {
                sink.success(eventList[count])
                count++
              }
              handler.postDelayed(this, 10)
            }
          }
        }
    handler.postDelayed(r, 10)
  }
}

class SendConsistentNumbers(private val numberToSend: Long) :
    StreamConsistentNumbersStreamHandler() {
  private val handler = Handler(Looper.getMainLooper())

  override fun onListen(p0: Any?, sink: PigeonEventSink<Long>) {
    var count = 0
    val r: Runnable =
        object : Runnable {
          override fun run() {
            if (count >= 10) {
              sink.endOfStream()
            } else {
              handler.post {
                sink.success(numberToSend)
                count++
              }
              handler.postDelayed(this, 10)
            }
          }
        }
    handler.postDelayed(r, 10)
  }
}
