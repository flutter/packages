// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlinx.coroutines.suspendCancellableCoroutine

/**
 * Helper to adapt callback-based Flutter API calls into Kotlin coroutines, allowing integration
 * tests and host handlers to `await` Flutter API calls.
 */
internal suspend inline fun <T> suspendFlutterApi(
    crossinline block: ((Result<T>) -> Unit) -> Unit
): T = suspendCancellableCoroutine { continuation ->
  block { result ->
    if (result.isSuccess) {
      @Suppress("UNCHECKED_CAST") continuation.resume(result.getOrNull() as T)
    } else {
      continuation.resumeWithException(result.exceptionOrNull()!!)
    }
  }
}

/** This plugin handles the native side of the integration tests in example/integration_test/. */
class TestPlugin : FlutterPlugin, HostIntegrationCoreApi, HostCallbackCoreApi {
  private var flutterApi: FlutterIntegrationCoreApi? = null
  private var flutterCallbackApi: FlutterCallbackCoreApi? = null
  private var flutterSmallApiOne: FlutterSmallApi? = null
  private var flutterSmallApiTwo: FlutterSmallApi? = null
  private var proxyApiRegistrar: ProxyApiRegistrar? = null

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    HostIntegrationCoreApi.setUp(binding.binaryMessenger, this)
    HostCallbackCoreApi.setUp(binding.binaryMessenger, this)
    val testSuffixApiOne = TestPluginWithSuffix()
    testSuffixApiOne.setUp(binding, "suffixOne")
    val testSuffixApiTwo = TestPluginWithSuffix()
    testSuffixApiTwo.setUp(binding, "suffixTwo")
    flutterApi = FlutterIntegrationCoreApi(binding.binaryMessenger)
    flutterCallbackApi = FlutterCallbackCoreApi(binding.binaryMessenger)
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

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    HostIntegrationCoreApi.setUp(binding.binaryMessenger, null)
    HostCallbackCoreApi.setUp(binding.binaryMessenger, null)
    proxyApiRegistrar?.tearDown()
  }

  // HostCallbackCoreApi
  override fun noop(callback: (Result<Unit>) -> Unit) {
    callback(Result.success(Unit))
  }

  override fun echoString(aString: String, callback: (Result<String>) -> Unit) {
    callback(Result.success(aString))
  }

  override fun echoAllTypes(everything: AllTypes, callback: (Result<AllTypes>) -> Unit) {
    callback(Result.success(everything))
  }

  override fun echoNullableString(aString: String?, callback: (Result<String?>) -> Unit) {
    callback(Result.success(aString))
  }

  override fun throwError(callback: (Result<Any?>) -> Unit) {
    callback(Result.failure(FlutterError("code", "message", "details")))
  }

  override fun throwErrorFromVoid(callback: (Result<Unit>) -> Unit) {
    callback(Result.failure(FlutterError("code", "message", "details")))
  }

  override fun taskQueueIsBackgroundThread(callback: (Result<Boolean>) -> Unit) {
    callback(Result.success(Looper.myLooper() != Looper.getMainLooper()))
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

  override suspend fun noopAsync() {}

  override suspend fun throwAsyncError(): Any? {
    throw Exception("except")
  }

  override suspend fun throwAsyncErrorFromVoid() {
    throw Exception("except")
  }

  override suspend fun throwAsyncFlutterError(): Any? {
    throw FlutterError("code", "message", "details")
  }

  override suspend fun echoAsyncAllTypes(everything: AllTypes): AllTypes {
    return everything
  }

  override suspend fun echoAsyncNullableAllNullableTypes(
      everything: AllNullableTypes?
  ): AllNullableTypes? {
    return everything
  }

  override suspend fun echoAsyncNullableAllNullableTypesWithoutRecursion(
      everything: AllNullableTypesWithoutRecursion?
  ): AllNullableTypesWithoutRecursion? {
    return everything
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

  override suspend fun echoAsyncObject(anObject: Any): Any {
    return anObject
  }

  override suspend fun echoAsyncList(list: List<Any?>): List<Any?> {
    return list
  }

  override suspend fun echoAsyncEnumList(enumList: List<AnEnum?>): List<AnEnum?> {
    return enumList
  }

  override suspend fun echoAsyncClassList(
      classList: List<AllNullableTypes?>
  ): List<AllNullableTypes?> {
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

  override suspend fun echoAsyncEnumMap(enumMap: Map<AnEnum?, AnEnum?>): Map<AnEnum?, AnEnum?> {
    return enumMap
  }

  override suspend fun echoAsyncClassMap(
      classMap: Map<Long?, AllNullableTypes?>
  ): Map<Long?, AllNullableTypes?> {
    return classMap
  }

  override suspend fun echoAsyncEnum(anEnum: AnEnum): AnEnum {
    return anEnum
  }

  override suspend fun echoAnotherAsyncEnum(anotherEnum: AnotherEnum): AnotherEnum {
    return anotherEnum
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

  override suspend fun echoAsyncNullableObject(anObject: Any?): Any? {
    return anObject
  }

  override suspend fun echoAsyncNullableList(list: List<Any?>?): List<Any?>? {
    return list
  }

  override suspend fun echoAsyncNullableEnumList(enumList: List<AnEnum?>?): List<AnEnum?>? {
    return enumList
  }

  override suspend fun echoAsyncNullableClassList(
      classList: List<AllNullableTypes?>?
  ): List<AllNullableTypes?>? {
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
      enumMap: Map<AnEnum?, AnEnum?>?
  ): Map<AnEnum?, AnEnum?>? {
    return enumMap
  }

  override suspend fun echoAsyncNullableClassMap(
      classMap: Map<Long?, AllNullableTypes?>?
  ): Map<Long?, AllNullableTypes?>? {
    return classMap
  }

  override suspend fun echoAsyncNullableEnum(anEnum: AnEnum?): AnEnum? {
    return anEnum
  }

  override suspend fun echoAnotherAsyncNullableEnum(anotherEnum: AnotherEnum?): AnotherEnum? {
    return anotherEnum
  }

  override fun defaultIsMainThread(): Boolean {
    return Thread.currentThread() == Looper.getMainLooper().getThread()
  }

  override fun taskQueueIsBackgroundThread(): Boolean {
    return Thread.currentThread() != Looper.getMainLooper().getThread()
  }

  override suspend fun asyncTaskQueueIsBackgroundThread(): Boolean {
    return Thread.currentThread() != Looper.getMainLooper().getThread()
  }

  override suspend fun callFlutterNoop() {
    flutterApi!!.noop()
  }

  override suspend fun callFlutterThrowError(): Any? {
    return flutterApi!!.throwError()
  }

  override suspend fun callFlutterThrowErrorFromVoid() {
    flutterApi!!.throwErrorFromVoid()
  }

  override suspend fun callFlutterEchoAllTypes(everything: AllTypes): AllTypes {
    return flutterApi!!.echoAllTypes(everything)
  }

  override suspend fun callFlutterSendMultipleNullableTypes(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?
  ): AllNullableTypes {
    return flutterApi!!.sendMultipleNullableTypes(aNullableBool, aNullableInt, aNullableString)
  }

  override suspend fun callFlutterEchoAllNullableTypesWithoutRecursion(
      everything: AllNullableTypesWithoutRecursion?
  ): AllNullableTypesWithoutRecursion? {
    return flutterApi!!.echoAllNullableTypesWithoutRecursion(everything)
  }

  override suspend fun callFlutterSendMultipleNullableTypesWithoutRecursion(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?
  ): AllNullableTypesWithoutRecursion {
    return flutterApi!!.sendMultipleNullableTypesWithoutRecursion(
        aNullableBool, aNullableInt, aNullableString)
  }

  override suspend fun callFlutterEchoBool(aBool: Boolean): Boolean {
    return flutterApi!!.echoBool(aBool)
  }

  override suspend fun callFlutterEchoInt(anInt: Long): Long {
    return flutterApi!!.echoInt(anInt)
  }

  override suspend fun callFlutterEchoDouble(aDouble: Double): Double {
    return flutterApi!!.echoDouble(aDouble)
  }

  override suspend fun callFlutterEchoString(aString: String): String {
    return flutterApi!!.echoString(aString)
  }

  override suspend fun callFlutterEchoUint8List(list: ByteArray): ByteArray {
    return flutterApi!!.echoUint8List(list)
  }

  override suspend fun callFlutterEchoList(list: List<Any?>): List<Any?> {
    return flutterApi!!.echoList(list)
  }

  override suspend fun callFlutterEchoEnumList(enumList: List<AnEnum?>): List<AnEnum?> {
    return flutterApi!!.echoEnumList(enumList)
  }

  override suspend fun callFlutterEchoClassList(
      classList: List<AllNullableTypes?>
  ): List<AllNullableTypes?> {
    return flutterApi!!.echoClassList(classList)
  }

  override suspend fun callFlutterEchoNonNullEnumList(enumList: List<AnEnum>): List<AnEnum> {
    return flutterApi!!.echoNonNullEnumList(enumList)
  }

  override suspend fun callFlutterEchoNonNullClassList(
      classList: List<AllNullableTypes>
  ): List<AllNullableTypes> {
    return flutterApi!!.echoNonNullClassList(classList)
  }

  override suspend fun callFlutterEchoMap(map: Map<Any?, Any?>): Map<Any?, Any?> {
    return flutterApi!!.echoMap(map)
  }

  override suspend fun callFlutterEchoStringMap(
      stringMap: Map<String?, String?>
  ): Map<String?, String?> {
    return flutterApi!!.echoStringMap(stringMap)
  }

  override suspend fun callFlutterEchoIntMap(intMap: Map<Long?, Long?>): Map<Long?, Long?> {
    return flutterApi!!.echoIntMap(intMap)
  }

  override suspend fun callFlutterEchoEnumMap(
      enumMap: Map<AnEnum?, AnEnum?>
  ): Map<AnEnum?, AnEnum?> {
    return flutterApi!!.echoEnumMap(enumMap)
  }

  override suspend fun callFlutterEchoClassMap(
      classMap: Map<Long?, AllNullableTypes?>
  ): Map<Long?, AllNullableTypes?> {
    return flutterApi!!.echoClassMap(classMap)
  }

  override suspend fun callFlutterEchoNonNullStringMap(
      stringMap: Map<String, String>
  ): Map<String, String> {
    return flutterApi!!.echoNonNullStringMap(stringMap)
  }

  override suspend fun callFlutterEchoNonNullIntMap(intMap: Map<Long, Long>): Map<Long, Long> {
    return flutterApi!!.echoNonNullIntMap(intMap)
  }

  override suspend fun callFlutterEchoNonNullEnumMap(
      enumMap: Map<AnEnum, AnEnum>
  ): Map<AnEnum, AnEnum> {
    return flutterApi!!.echoNonNullEnumMap(enumMap)
  }

  override suspend fun callFlutterEchoNonNullClassMap(
      classMap: Map<Long, AllNullableTypes>
  ): Map<Long, AllNullableTypes> {
    return flutterApi!!.echoNonNullClassMap(classMap)
  }

  override suspend fun callFlutterEchoEnum(anEnum: AnEnum): AnEnum {
    return flutterApi!!.echoEnum(anEnum)
  }

  override suspend fun callFlutterEchoAnotherEnum(anotherEnum: AnotherEnum): AnotherEnum {
    return flutterApi!!.echoAnotherEnum(anotherEnum)
  }

  override suspend fun callFlutterEchoAllNullableTypes(
      everything: AllNullableTypes?
  ): AllNullableTypes? {
    return flutterApi!!.echoAllNullableTypes(everything)
  }

  override suspend fun callFlutterEchoNullableBool(aBool: Boolean?): Boolean? {
    return flutterApi!!.echoNullableBool(aBool)
  }

  override suspend fun callFlutterEchoNullableInt(anInt: Long?): Long? {
    return flutterApi!!.echoNullableInt(anInt)
  }

  override suspend fun callFlutterEchoNullableDouble(aDouble: Double?): Double? {
    return flutterApi!!.echoNullableDouble(aDouble)
  }

  override suspend fun callFlutterEchoNullableString(aString: String?): String? {
    return flutterApi!!.echoNullableString(aString)
  }

  override suspend fun callFlutterEchoNullableUint8List(list: ByteArray?): ByteArray? {
    return flutterApi!!.echoNullableUint8List(list)
  }

  override suspend fun callFlutterEchoNullableList(list: List<Any?>?): List<Any?>? {
    return flutterApi!!.echoNullableList(list)
  }

  override suspend fun callFlutterEchoNullableEnumList(enumList: List<AnEnum?>?): List<AnEnum?>? {
    return flutterApi!!.echoNullableEnumList(enumList)
  }

  override suspend fun callFlutterEchoNullableClassList(
      classList: List<AllNullableTypes?>?
  ): List<AllNullableTypes?>? {
    return flutterApi!!.echoNullableClassList(classList)
  }

  override suspend fun callFlutterEchoNullableNonNullEnumList(
      enumList: List<AnEnum>?
  ): List<AnEnum>? {
    return flutterApi!!.echoNullableNonNullEnumList(enumList)
  }

  override suspend fun callFlutterEchoNullableNonNullClassList(
      classList: List<AllNullableTypes>?
  ): List<AllNullableTypes>? {
    return flutterApi!!.echoNullableNonNullClassList(classList)
  }

  override suspend fun callFlutterEchoNullableMap(map: Map<Any?, Any?>?): Map<Any?, Any?>? {
    return flutterApi!!.echoNullableMap(map)
  }

  override suspend fun callFlutterEchoNullableStringMap(
      stringMap: Map<String?, String?>?
  ): Map<String?, String?>? {
    return flutterApi!!.echoNullableStringMap(stringMap)
  }

  override suspend fun callFlutterEchoNullableIntMap(
      intMap: Map<Long?, Long?>?
  ): Map<Long?, Long?>? {
    return flutterApi!!.echoNullableIntMap(intMap)
  }

  override suspend fun callFlutterEchoNullableEnumMap(
      enumMap: Map<AnEnum?, AnEnum?>?
  ): Map<AnEnum?, AnEnum?>? {
    return flutterApi!!.echoNullableEnumMap(enumMap)
  }

  override suspend fun callFlutterEchoNullableClassMap(
      classMap: Map<Long?, AllNullableTypes?>?
  ): Map<Long?, AllNullableTypes?>? {
    return flutterApi!!.echoNullableClassMap(classMap)
  }

  override suspend fun callFlutterEchoNullableNonNullStringMap(
      stringMap: Map<String, String>?
  ): Map<String, String>? {
    return flutterApi!!.echoNullableNonNullStringMap(stringMap)
  }

  override suspend fun callFlutterEchoNullableNonNullIntMap(
      intMap: Map<Long, Long>?
  ): Map<Long, Long>? {
    return flutterApi!!.echoNullableNonNullIntMap(intMap)
  }

  override suspend fun callFlutterEchoNullableNonNullEnumMap(
      enumMap: Map<AnEnum, AnEnum>?
  ): Map<AnEnum, AnEnum>? {
    return flutterApi!!.echoNullableNonNullEnumMap(enumMap)
  }

  override suspend fun callFlutterEchoNullableNonNullClassMap(
      classMap: Map<Long, AllNullableTypes>?
  ): Map<Long, AllNullableTypes>? {
    return flutterApi!!.echoNullableNonNullClassMap(classMap)
  }

  override suspend fun callFlutterEchoNullableEnum(anEnum: AnEnum?): AnEnum? {
    return flutterApi!!.echoNullableEnum(anEnum)
  }

  override suspend fun callFlutterEchoAnotherNullableEnum(anotherEnum: AnotherEnum?): AnotherEnum? {
    return flutterApi!!.echoAnotherNullableEnum(anotherEnum)
  }

  override suspend fun callFlutterSmallApiEchoString(aString: String): String {
    val echoOne = flutterSmallApiOne!!.echoString(aString)
    val echoTwo = flutterSmallApiTwo!!.echoString(aString)
    if (echoOne == echoTwo) {
      return echoTwo
    } else {
      throw Exception("Multi-instance responses were not matching: $echoOne, $echoTwo")
    }
  }

  override suspend fun callFlutterCallbackNoop() {
    return suspendFlutterApi { flutterCallbackApi!!.noop(it) }
  }

  override suspend fun callFlutterCallbackEchoString(aString: String): String {
    return suspendFlutterApi { flutterCallbackApi!!.echoString(aString, it) }
  }

  override suspend fun callFlutterCallbackThrowError(): Any? {
    return suspendFlutterApi { flutterCallbackApi!!.throwError(it) }
  }

  override suspend fun callFlutterCallbackThrowErrorFromVoid() {
    return suspendFlutterApi { flutterCallbackApi!!.throwErrorFromVoid(it) }
  }

  fun testUnusedClassesGenerate(): UnusedClass {
    return UnusedClass()
  }
}

class TestPluginWithSuffix : HostSmallApi {

  fun setUp(binding: FlutterPluginBinding, suffix: String) {
    HostSmallApi.setUp(binding.binaryMessenger, this, suffix)
  }

  override suspend fun echo(aString: String): String {
    return aString
  }

  override suspend fun voidVoid() {}
}

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
    var count: Int = 0
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
    var count: Int = 0
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
