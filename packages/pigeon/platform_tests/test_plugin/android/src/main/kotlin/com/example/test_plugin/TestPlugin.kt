// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

// import NIFlutterIntegrationCoreApiRegistrar
// import NIHostSmallApi
// import NIHostSmallApiRegistrar
import NIAllClassesWrapper
import NIAllNullableTypes
import NIAllNullableTypesWithoutRecursion
import NIAllTypes
import NIAnEnum
import NIAnotherEnum
import NIHostIntegrationCoreApi
import NIHostIntegrationCoreApiRegistrar
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

/** This plugin handles the native side of the integration tests in example/integration_test/. */
class TestPlugin : FlutterPlugin, HostIntegrationCoreApi {
  private var flutterApi: FlutterIntegrationCoreApi? = null
  private var flutterSmallApiOne: FlutterSmallApi? = null
  private var flutterSmallApiTwo: FlutterSmallApi? = null
  private var proxyApiRegistrar: ProxyApiRegistrar? = null
  private var niMessageApi: NIHostIntegrationCoreApiRegistrar? = null
  // private var niSmallApiOne: NIHostSmallApiRegistrar? = null
  // private var niSmallApiTwo: NIHostSmallApiRegistrar? = null

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    HostIntegrationCoreApi.setUp(binding.binaryMessenger, this)
    val testSuffixApiOne = TestPluginWithSuffix()
    testSuffixApiOne.setUp(binding, "suffixOne")
    val testSuffixApiTwo = TestPluginWithSuffix()
    testSuffixApiTwo.setUp(binding, "suffixTwo")

    niMessageApi = NIHostIntegrationCoreApiRegistrar().register(NIIntegrationTests())
    // niSmallApiOne = NIHostSmallApiRegistrar().register(NIHostSmallApiTests(), "suffixOne")
    // niSmallApiTwo = NIHostSmallApiRegistrar().register(NIHostSmallApiTests(), "suffixTwo")

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
    return Thread.currentThread() == Looper.getMainLooper().thread
  }

  override fun taskQueueIsBackgroundThread(): Boolean {
    return Thread.currentThread() != Looper.getMainLooper().thread
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

class NIIntegrationTests : NIHostIntegrationCoreApi() {
  override fun noop() {}

  override fun echoAllTypes(everything: NIAllTypes): NIAllTypes {
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

  override fun echoEnumList(enumList: List<NIAnEnum?>): List<NIAnEnum?> {
    return enumList
  }

  override fun echoClassList(classList: List<NIAllNullableTypes?>): List<NIAllNullableTypes?> {
    return classList
  }

  override fun echoNonNullEnumList(enumList: List<NIAnEnum>): List<NIAnEnum> {
    return enumList
  }

  override fun echoNonNullClassList(classList: List<NIAllNullableTypes>): List<NIAllNullableTypes> {
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

  override fun echoEnumMap(enumMap: Map<NIAnEnum?, NIAnEnum?>): Map<NIAnEnum?, NIAnEnum?> {
    return enumMap
  }

  override fun echoClassMap(
      classMap: Map<Long?, NIAllNullableTypes?>
  ): Map<Long?, NIAllNullableTypes?> {
    return classMap
  }

  override fun echoNonNullStringMap(stringMap: Map<String, String>): Map<String, String> {
    return stringMap
  }

  override fun echoNonNullIntMap(intMap: Map<Long, Long>): Map<Long, Long> {
    return intMap
  }

  override fun echoNonNullEnumMap(enumMap: Map<NIAnEnum, NIAnEnum>): Map<NIAnEnum, NIAnEnum> {
    return enumMap
  }

  override fun echoNonNullClassMap(
      classMap: Map<Long, NIAllNullableTypes>
  ): Map<Long, NIAllNullableTypes> {
    return classMap
  }

  override fun echoClassWrapper(wrapper: NIAllClassesWrapper): NIAllClassesWrapper {
    return wrapper
  }

  override fun echoEnum(anEnum: NIAnEnum): NIAnEnum {
    return anEnum
  }

  override fun echoAnotherEnum(anotherEnum: NIAnotherEnum): NIAnotherEnum {
    return anotherEnum
  }
  //
  // override fun echoNamedDefaultString(aString: String): String {
  //   return aString
  // }
  //
  // override fun echoOptionalDefaultDouble(aDouble: Double): Double {
  //   return aDouble
  // }
  //
  // override fun echoRequiredInt(anInt: Long): Long {
  //   return anInt
  // }

  override fun echoAllNullableTypes(everything: NIAllNullableTypes?): NIAllNullableTypes? {
    return everything
  }

  override fun echoAllNullableTypesWithoutRecursion(
      everything: NIAllNullableTypesWithoutRecursion?
  ): NIAllNullableTypesWithoutRecursion? {
    return everything
  }

  override fun extractNestedNullableString(wrapper: NIAllClassesWrapper): String? {
    return wrapper.allNullableTypes.aNullableString
  }

  override fun createNestedNullableString(nullableString: String?): NIAllClassesWrapper {
    return NIAllClassesWrapper(
        NIAllNullableTypes(aNullableString = nullableString),
        classList = arrayOf<NIAllTypes>().toList(),
        classMap = HashMap())
  }

  override fun sendMultipleNullableTypes(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?
  ): NIAllNullableTypes {
    return NIAllNullableTypes(
        aNullableBool = aNullableBool,
        aNullableInt = aNullableInt,
        aNullableString = aNullableString)
  }

  override fun sendMultipleNullableTypesWithoutRecursion(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?
  ): NIAllNullableTypesWithoutRecursion {
    return NIAllNullableTypesWithoutRecursion(
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

  override fun echoNullableEnumList(enumList: List<NIAnEnum?>?): List<NIAnEnum?>? {
    return enumList
  }

  override fun echoNullableClassList(
      classList: List<NIAllNullableTypes?>?
  ): List<NIAllNullableTypes?>? {
    return classList
  }

  override fun echoNullableNonNullEnumList(enumList: List<NIAnEnum>?): List<NIAnEnum>? {
    return enumList
  }

  override fun echoNullableNonNullClassList(
      classList: List<NIAllNullableTypes>?
  ): List<NIAllNullableTypes>? {
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
      enumMap: Map<NIAnEnum?, NIAnEnum?>?
  ): Map<NIAnEnum?, NIAnEnum?>? {
    return enumMap
  }

  override fun echoNullableClassMap(
      classMap: Map<Long?, NIAllNullableTypes?>?
  ): Map<Long?, NIAllNullableTypes?>? {
    return classMap
  }

  override fun echoNullableNonNullStringMap(stringMap: Map<String, String>?): Map<String, String>? {
    return stringMap
  }

  override fun echoNullableNonNullIntMap(intMap: Map<Long, Long>?): Map<Long, Long>? {
    return intMap
  }

  override fun echoNullableNonNullEnumMap(
      enumMap: Map<NIAnEnum, NIAnEnum>?
  ): Map<NIAnEnum, NIAnEnum>? {
    return enumMap
  }

  override fun echoNullableNonNullClassMap(
      classMap: Map<Long, NIAllNullableTypes>?
  ): Map<Long, NIAllNullableTypes>? {
    return classMap
  }

  override fun echoNullableEnum(anEnum: NIAnEnum?): NIAnEnum? {
    return anEnum
  }

  override fun echoAnotherNullableEnum(anotherEnum: NIAnotherEnum?): NIAnotherEnum? {
    return anotherEnum
  }
  //
  // override fun echoOptionalNullableInt(aNullableInt: Long?): Long? {
  //   return aNullableInt
  // }
  //
  // override fun echoNamedNullableString(aNullableString: String?): String? {
  //   return aNullableString
  // }

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

  override suspend fun echoAsyncEnumList(enumList: List<NIAnEnum?>): List<NIAnEnum?> {
    return enumList
  }

  override suspend fun echoAsyncClassList(
      classList: List<NIAllNullableTypes?>
  ): List<NIAllNullableTypes?> {
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
      enumMap: Map<NIAnEnum?, NIAnEnum?>
  ): Map<NIAnEnum?, NIAnEnum?> {
    return enumMap
  }

  override suspend fun echoAsyncClassMap(
      classMap: Map<Long?, NIAllNullableTypes?>
  ): Map<Long?, NIAllNullableTypes?> {
    return classMap
  }

  override suspend fun echoAsyncEnum(anEnum: NIAnEnum): NIAnEnum {
    return anEnum
  }

  override suspend fun echoAnotherAsyncEnum(anotherEnum: NIAnotherEnum): NIAnotherEnum {
    return anotherEnum
  }

  override suspend fun throwAsyncError(): Any? {
    throw Exception("An error")
  }

  override suspend fun throwAsyncErrorFromVoid() {
    throw Exception("An error")
  }

  override suspend fun throwAsyncFlutterError(): Any? {
    throw FlutterError("code", "message", "details")
  }

  override suspend fun echoAsyncNIAllTypes(everything: NIAllTypes): NIAllTypes {
    return everything
  }

  override suspend fun echoAsyncNullableNIAllNullableTypes(
      everything: NIAllNullableTypes?
  ): NIAllNullableTypes? {
    return everything
  }

  override suspend fun echoAsyncNullableNIAllNullableTypesWithoutRecursion(
      everything: NIAllNullableTypesWithoutRecursion?
  ): NIAllNullableTypesWithoutRecursion? {
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

  override suspend fun echoAsyncNullableEnumList(enumList: List<NIAnEnum?>?): List<NIAnEnum?>? {
    return enumList
  }

  override suspend fun echoAsyncNullableClassList(
      classList: List<NIAllNullableTypes?>?
  ): List<NIAllNullableTypes?>? {
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
      enumMap: Map<NIAnEnum?, NIAnEnum?>?
  ): Map<NIAnEnum?, NIAnEnum?>? {
    return enumMap
  }

  override suspend fun echoAsyncNullableClassMap(
      classMap: Map<Long?, NIAllNullableTypes?>?
  ): Map<Long?, NIAllNullableTypes?>? {
    return classMap
  }

  override suspend fun echoAsyncNullableEnum(anEnum: NIAnEnum?): NIAnEnum? {
    return anEnum
  }

  override suspend fun echoAnotherAsyncNullableEnum(anotherEnum: NIAnotherEnum?): NIAnotherEnum? {
    return anotherEnum
  }
  //
  //   override fun callFlutterNoop() {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.noop()
  //   }
  //
  //   override fun callFlutterThrowError(): Any? {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.throwError()
  //   }
  //
  //   override fun callFlutterThrowErrorFromVoid() {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.throwErrorFromVoid()
  //   }
  //
  //   override fun callFlutterEchoNIAllTypes(everything: NIAllTypes): NIAllTypes {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNIAllTypes(everything)
  //   }
  //
  //   override fun callFlutterEchoNIAllNullableTypes(
  //       everything: NIAllNullableTypes?
  //   ): NIAllNullableTypes? {
  //     return
  // NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNIAllNullableTypes(everything)
  //   }
  //
  //   override fun callFlutterSendMultipleNullableTypes(
  //       aNullableBool: Boolean?,
  //       aNullableInt: Long?,
  //       aNullableString: String?
  //   ): NIAllNullableTypes {
  //     return NIFlutterIntegrationCoreApiRegistrar()
  //         .getInstance()!!
  //         .sendMultipleNullableTypes(aNullableBool, aNullableInt, aNullableString)
  //   }
  //
  //   override fun callFlutterEchoNIAllNullableTypesWithoutRecursion(
  //       everything: NIAllNullableTypesWithoutRecursion?
  //   ): NIAllNullableTypesWithoutRecursion? {
  //     return NIFlutterIntegrationCoreApiRegistrar()
  //         .getInstance()!!
  //         .echoNIAllNullableTypesWithoutRecursion(everything)
  //   }
  //
  //   override fun callFlutterSendMultipleNullableTypesWithoutRecursion(
  //       aNullableBool: Boolean?,
  //       aNullableInt: Long?,
  //       aNullableString: String?
  //   ): NIAllNullableTypesWithoutRecursion {
  //     return NIFlutterIntegrationCoreApiRegistrar()
  //         .getInstance()!!
  //         .sendMultipleNullableTypesWithoutRecursion(aNullableBool, aNullableInt,
  // aNullableString)
  //   }
  //
  //   override fun callFlutterEchoBool(aBool: Boolean): Boolean {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoBool(aBool)
  //   }
  //
  //   override fun callFlutterEchoInt(anInt: Long): Long {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoInt(anInt)
  //   }
  //
  //   override fun callFlutterEchoDouble(aDouble: Double): Double {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoDouble(aDouble)
  //   }
  //
  //   override fun callFlutterEchoString(aString: String): String {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoString(aString)
  //   }
  //
  //   override fun callFlutterEchoUint8List(list: ByteArray): ByteArray {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoUint8List(list)
  //   }
  //
  //   override fun callFlutterEchoList(list: List<Any?>): List<Any?> {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoList(list)
  //   }
  //
  //   override fun callFlutterEchoEnumList(enumList: List<NIAnEnum?>): List<NIAnEnum?> {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoEnumList(enumList)
  //   }
  //
  //   override fun callFlutterEchoClassList(
  //       classList: List<NIAllNullableTypes?>
  //   ): List<NIAllNullableTypes?> {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoClassList(classList)
  //   }
  //
  //   override fun callFlutterEchoNonNullEnumList(enumList: List<NIAnEnum>): List<NIAnEnum> {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNonNullEnumList(enumList)
  //   }
  //
  //   override fun callFlutterEchoNonNullClassList(
  //       classList: List<NIAllNullableTypes>
  //   ): List<NIAllNullableTypes> {
  //     return
  // NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNonNullClassList(classList)
  //   }
  //
  //   override fun callFlutterEchoMap(map: Map<Any?, Any?>): Map<Any?, Any?> {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoMap(map)
  //   }
  //
  //   override fun callFlutterEchoStringMap(stringMap: Map<String?, String?>): Map<String?,
  // String?> {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoStringMap(stringMap)
  //   }
  //
  //   override fun callFlutterEchoIntMap(intMap: Map<Long?, Long?>): Map<Long?, Long?> {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoIntMap(intMap)
  //   }
  //
  //   override fun callFlutterEchoEnumMap(
  //       enumMap: Map<NIAnEnum?, NIAnEnum?>
  //   ): Map<NIAnEnum?, NIAnEnum?> {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoEnumMap(enumMap)
  //   }
  //
  //   override fun callFlutterEchoClassMap(
  //       classMap: Map<Long?, NIAllNullableTypes?>
  //   ): Map<Long?, NIAllNullableTypes?> {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoClassMap(classMap)
  //   }
  //
  //   override fun callFlutterEchoNonNullStringMap(
  //       stringMap: Map<String, String>
  //   ): Map<String, String> {
  //     return
  // NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNonNullStringMap(stringMap)
  //   }
  //
  //   override fun callFlutterEchoNonNullIntMap(intMap: Map<Long, Long>): Map<Long, Long> {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNonNullIntMap(intMap)
  //   }
  //
  //   override fun callFlutterEchoNonNullEnumMap(
  //       enumMap: Map<NIAnEnum, NIAnEnum>
  //   ): Map<NIAnEnum, NIAnEnum> {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNonNullEnumMap(enumMap)
  //   }
  //
  //   override fun callFlutterEchoNonNullClassMap(
  //       classMap: Map<Long, NIAllNullableTypes>
  //   ): Map<Long, NIAllNullableTypes> {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNonNullClassMap(classMap)
  //   }
  //
  //   override fun callFlutterEchoEnum(anEnum: NIAnEnum): NIAnEnum {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoEnum(anEnum)
  //   }
  //
  //   override fun callFlutterEchoNIAnotherEnum(anotherEnum: NIAnotherEnum): NIAnotherEnum {
  //     return
  // NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNIAnotherEnum(anotherEnum)
  //   }
  //
  //   override fun callFlutterEchoNullableBool(aBool: Boolean?): Boolean? {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableBool(aBool)
  //   }
  //
  //   override fun callFlutterEchoNullableInt(anInt: Long?): Long? {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableInt(anInt)
  //   }
  //
  //   override fun callFlutterEchoNullableDouble(aDouble: Double?): Double? {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableDouble(aDouble)
  //   }
  //
  //   override fun callFlutterEchoNullableString(aString: String?): String? {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableString(aString)
  //   }
  //
  //   override fun callFlutterEchoNullableUint8List(list: ByteArray?): ByteArray? {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableUint8List(list)
  //   }
  //
  //   override fun callFlutterEchoNullableList(list: List<Any?>?): List<Any?>? {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableList(list)
  //   }
  //
  //   override fun callFlutterEchoNullableEnumList(enumList: List<NIAnEnum?>?): List<NIAnEnum?>? {
  //     return
  // NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableEnumList(enumList)
  //   }
  //
  //   override fun callFlutterEchoNullableClassList(
  //       classList: List<NIAllNullableTypes?>?
  //   ): List<NIAllNullableTypes?>? {
  //     return
  // NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableClassList(classList)
  //   }
  //
  //   override fun callFlutterEchoNullableNonNullEnumList(enumList: List<NIAnEnum>?):
  // List<NIAnEnum>? {
  //     return NIFlutterIntegrationCoreApiRegistrar()
  //         .getInstance()!!
  //         .echoNullableNonNullEnumList(enumList)
  //   }
  //
  //   override fun callFlutterEchoNullableNonNullClassList(
  //       classList: List<NIAllNullableTypes>?
  //   ): List<NIAllNullableTypes>? {
  //     return NIFlutterIntegrationCoreApiRegistrar()
  //         .getInstance()!!
  //         .echoNullableNonNullClassList(classList)
  //   }
  //
  //   override fun callFlutterEchoNullableMap(map: Map<Any?, Any?>?): Map<Any?, Any?>? {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableMap(map)
  //   }
  //
  //   override fun callFlutterEchoNullableStringMap(
  //       stringMap: Map<String?, String?>?
  //   ): Map<String?, String?>? {
  //     return
  // NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableStringMap(stringMap)
  //   }
  //
  //   override fun callFlutterEchoNullableIntMap(intMap: Map<Long?, Long?>?): Map<Long?, Long?>? {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableIntMap(intMap)
  //   }
  //
  //   override fun callFlutterEchoNullableEnumMap(
  //       enumMap: Map<NIAnEnum?, NIAnEnum?>?
  //   ): Map<NIAnEnum?, NIAnEnum?>? {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableEnumMap(enumMap)
  //   }
  //
  //   override fun callFlutterEchoNullableClassMap(
  //       classMap: Map<Long?, NIAllNullableTypes?>?
  //   ): Map<Long?, NIAllNullableTypes?>? {
  //     return
  // NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableClassMap(classMap)
  //   }
  //
  //   override fun callFlutterEchoNullableNonNullStringMap(
  //       stringMap: Map<String, String>?
  //   ): Map<String, String>? {
  //     return NIFlutterIntegrationCoreApiRegistrar()
  //         .getInstance()!!
  //         .echoNullableNonNullStringMap(stringMap)
  //   }
  //
  //   override fun callFlutterEchoNullableNonNullIntMap(intMap: Map<Long, Long>?): Map<Long, Long>?
  // {
  //     return
  // NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableNonNullIntMap(intMap)
  //   }
  //
  //   override fun callFlutterEchoNullableNonNullEnumMap(
  //       enumMap: Map<NIAnEnum, NIAnEnum>?
  //   ): Map<NIAnEnum, NIAnEnum>? {
  //     return NIFlutterIntegrationCoreApiRegistrar()
  //         .getInstance()!!
  //         .echoNullableNonNullEnumMap(enumMap)
  //   }
  //
  //   override fun callFlutterEchoNullableNonNullClassMap(
  //       classMap: Map<Long, NIAllNullableTypes>?
  //   ): Map<Long, NIAllNullableTypes>? {
  //     return NIFlutterIntegrationCoreApiRegistrar()
  //         .getInstance()!!
  //         .echoNullableNonNullClassMap(classMap)
  //   }
  //
  //   override fun callFlutterEchoNullableEnum(anEnum: NIAnEnum?): NIAnEnum? {
  //     return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoNullableEnum(anEnum)
  //   }
  //
  //   override fun callFlutterEchoAnotherNullableEnum(anotherEnum: NIAnotherEnum?): NIAnotherEnum?
  // {
  //     return NIFlutterIntegrationCoreApiRegistrar()
  //         .getInstance()!!
  //         .echoAnotherNullableEnum(anotherEnum)
  //   }
  //
  //   //  override suspend fun callFlutterNoopAsync() {
  //   //    return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.noopAsync()
  //   //  }
  //   //
  //   //  override suspend fun callFlutterEchoAsyncString(aString: String): String {
  //   //    return NIFlutterIntegrationCoreApiRegistrar().getInstance()!!.echoAsyncString(aString)
  //   //  }
  // }
  //
  // class NIHostSmallApiTests : NIHostSmallApi() {
  //   override suspend fun echo(aString: String): String {
  //     return aString
  //   }
  //
  //   override suspend fun voidVoid() {
  //     return
  //   }
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
          ClassEvent(EventAllNullableTypes(aNullableInt = 0)))

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
