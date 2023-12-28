// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger

/** This plugin handles the native side of the integration tests in example/integration_test/. */
class TestPlugin : FlutterPlugin, HostIntegrationCoreApi {
  var flutterApi: FlutterIntegrationCoreApi? = null
  var instanceManager: Pigeon_InstanceManager? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    HostIntegrationCoreApi.setUp(binding.binaryMessenger, this)
    flutterApi = FlutterIntegrationCoreApi(binding.binaryMessenger)

    val instanceManagerApi = Pigeon_InstanceManagerApi(binding.binaryMessenger)
    instanceManager = Pigeon_InstanceManager.create(instanceManagerApi)

    Pigeon_InstanceManagerApi.setUpMessageHandlers(binding.binaryMessenger, instanceManager!!)

    val codec = ProxyApiCodec(binding.binaryMessenger, instanceManager!!)
    ProxyIntegrationCoreApi_Api.setUpMessageHandlers(
        binding.binaryMessenger, codec.getProxyIntegrationCoreApi_Api())
    ProxyApiSuperClass_Api.setUpMessageHandlers(
        binding.binaryMessenger, codec.getProxyApiSuperClass_Api())
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}

  // HostIntegrationCoreApi

  override fun noop() {}

  override fun echoAllTypes(everything: AllTypes): AllTypes {
    return everything
  }

  override fun echoAllNullableTypes(everything: AllNullableTypes?): AllNullableTypes? {
    return everything
  }

  override fun throwError(): Any? {
    throw Exception("An error")
  }

  override fun throwErrorFromVoid() {
    throw Exception("An error")
  }

  override fun throwFlutterError(): Any? {
    throw CoreTestsError("code", "message", "details")
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

  override fun echoList(aList: List<Any?>): List<Any?> {
    return aList
  }

  override fun echoMap(aMap: Map<String?, Any?>): Map<String?, Any?> {
    return aMap
  }

  override fun echoClassWrapper(wrapper: AllClassesWrapper): AllClassesWrapper {
    return wrapper
  }

  override fun echoEnum(anEnum: AnEnum): AnEnum {
    return anEnum
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

  override fun echoNullableMap(aNullableMap: Map<String?, Any?>?): Map<String?, Any?>? {
    return aNullableMap
  }

  override fun echoNullableEnum(anEnum: AnEnum?): AnEnum? {
    return anEnum
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
    callback(Result.failure(CoreTestsError("code", "message", "details")))
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

  override fun echoAsyncList(aList: List<Any?>, callback: (Result<List<Any?>>) -> Unit) {
    callback(Result.success(aList))
  }

  override fun echoAsyncMap(
      aMap: Map<String?, Any?>,
      callback: (Result<Map<String?, Any?>>) -> Unit
  ) {
    callback(Result.success(aMap))
  }

  override fun echoAsyncEnum(anEnum: AnEnum, callback: (Result<AnEnum>) -> Unit) {
    callback(Result.success(anEnum))
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

  override fun echoAsyncNullableList(aList: List<Any?>?, callback: (Result<List<Any?>?>) -> Unit) {
    callback(Result.success(aList))
  }

  override fun echoAsyncNullableMap(
      aMap: Map<String?, Any?>?,
      callback: (Result<Map<String?, Any?>?>) -> Unit
  ) {
    callback(Result.success(aMap))
  }

  override fun echoAsyncNullableEnum(anEnum: AnEnum?, callback: (Result<AnEnum?>) -> Unit) {
    callback(Result.success(anEnum))
  }

  override fun callFlutterNoop(callback: (Result<Unit>) -> Unit) {
    flutterApi!!.noop() { callback(Result.success(Unit)) }
  }

  override fun callFlutterThrowError(callback: (Result<Any?>) -> Unit) {
    flutterApi!!.throwError() { result -> callback(result) }
  }

  override fun callFlutterThrowErrorFromVoid(callback: (Result<Unit>) -> Unit) {
    flutterApi!!.throwErrorFromVoid() { result -> callback(result) }
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

  override fun callFlutterEchoUint8List(aList: ByteArray, callback: (Result<ByteArray>) -> Unit) {
    flutterApi!!.echoUint8List(aList) { echo -> callback(echo) }
  }

  override fun callFlutterEchoList(aList: List<Any?>, callback: (Result<List<Any?>>) -> Unit) {
    flutterApi!!.echoList(aList) { echo -> callback(echo) }
  }

  override fun callFlutterEchoMap(
      aMap: Map<String?, Any?>,
      callback: (Result<Map<String?, Any?>>) -> Unit
  ) {
    flutterApi!!.echoMap(aMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoEnum(anEnum: AnEnum, callback: (Result<AnEnum>) -> Unit) {
    flutterApi!!.echoEnum(anEnum) { echo -> callback(echo) }
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
      aList: ByteArray?,
      callback: (Result<ByteArray?>) -> Unit
  ) {
    flutterApi!!.echoNullableUint8List(aList) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableList(
      aList: List<Any?>?,
      callback: (Result<List<Any?>?>) -> Unit
  ) {
    flutterApi!!.echoNullableList(aList) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableMap(
      aMap: Map<String?, Any?>?,
      callback: (Result<Map<String?, Any?>?>) -> Unit
  ) {
    flutterApi!!.echoNullableMap(aMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableEnum(anEnum: AnEnum?, callback: (Result<AnEnum?>) -> Unit) {
    flutterApi!!.echoNullableEnum(anEnum) { echo -> callback(echo) }
  }
}

class ProxyApiCodec(binaryMessenger: BinaryMessenger, instanceManager: Pigeon_InstanceManager) :
    Pigeon_ProxyApiBaseCodec(binaryMessenger, instanceManager) {
  override fun getProxyIntegrationCoreApi_Api(): ProxyIntegrationCoreApi_Api {
    return ProxyIntegrationCoreApiApiImpl(this)
  }

  override fun getProxyApiSuperClass_Api(): ProxyApiSuperClass_Api {
    return ProxyApiSuperClassApiImpl(this)
  }

  override fun getProxyApiInterface_Api(): ProxyApiInterface_Api {
    return ProxyApiInterfaceApiImpl(this)
  }
}

class ProxyIntegrationCoreApiApiImpl(codec: Pigeon_ProxyApiBaseCodec) :
    ProxyIntegrationCoreApi_Api(codec) {
  override fun pigeon_defaultConstructor(
      aBool: Boolean,
      anInt: Long,
      aDouble: Double,
      aString: String,
      aUint8List: ByteArray,
      aList: List<Any?>,
      aMap: Map<String?, Any?>,
      anEnum: AnEnum,
      aProxyApi: ProxyApiSuperClass,
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableDouble: Double?,
      aNullableString: String?,
      aNullableUint8List: ByteArray?,
      aNullableList: List<Any?>?,
      aNullableMap: Map<String?, Any?>?,
      aNullableEnum: AnEnum?,
      aNullableProxyApi: ProxyApiSuperClass?,
      boolParam: Boolean,
      intParam: Long,
      doubleParam: Double,
      stringParam: String,
      aUint8ListParam: ByteArray,
      listParam: List<Any?>,
      mapParam: Map<String?, Any?>,
      enumParam: AnEnum,
      proxyApiParam: ProxyApiSuperClass,
      nullableBoolParam: Boolean?,
      nullableIntParam: Long?,
      nullableDoubleParam: Double?,
      nullableStringParam: String?,
      nullableUint8ListParam: ByteArray?,
      nullableListParam: List<Any?>?,
      nullableMapParam: Map<String?, Any?>?,
      nullableEnumParam: AnEnum?,
      nullableProxyApiParam: ProxyApiSuperClass?
  ): ProxyIntegrationCoreApi {
    return ProxyIntegrationCoreApi()
  }

  override fun attachedField(pigeon_instance: ProxyIntegrationCoreApi): ProxyApiSuperClass {
    return ProxyApiSuperClass()
  }

  override fun staticAttachedField(): ProxyApiSuperClass {
    return ProxyApiSuperClass()
  }

  override fun aBool(pigeon_instance: ProxyIntegrationCoreApi): Boolean {
    return true
  }

  override fun anInt(pigeon_instance: ProxyIntegrationCoreApi): Long {
    return 0
  }

  override fun aDouble(pigeon_instance: ProxyIntegrationCoreApi): Double {
    return 0.0
  }

  override fun aString(pigeon_instance: ProxyIntegrationCoreApi): String {
    return ""
  }

  override fun aUint8List(pigeon_instance: ProxyIntegrationCoreApi): ByteArray {
    return byteArrayOf()
  }

  override fun aList(pigeon_instance: ProxyIntegrationCoreApi): List<Any?> {
    return listOf<String>()
  }

  override fun aMap(pigeon_instance: ProxyIntegrationCoreApi): Map<String?, Any?> {
    return mapOf<String?, String>()
  }

  override fun anEnum(pigeon_instance: ProxyIntegrationCoreApi): AnEnum {
    return AnEnum.ONE
  }

  override fun aProxyApi(pigeon_instance: ProxyIntegrationCoreApi): ProxyApiSuperClass {
    return ProxyApiSuperClass()
  }

  override fun aNullableBool(pigeon_instance: ProxyIntegrationCoreApi): Boolean? {
    return null
  }

  override fun aNullableInt(pigeon_instance: ProxyIntegrationCoreApi): Long? {
    return null
  }

  override fun aNullableDouble(pigeon_instance: ProxyIntegrationCoreApi): Double? {
    return null
  }

  override fun aNullableString(pigeon_instance: ProxyIntegrationCoreApi): String? {
    return null
  }

  override fun aNullableUint8List(pigeon_instance: ProxyIntegrationCoreApi): ByteArray? {
    return null
  }

  override fun aNullableList(pigeon_instance: ProxyIntegrationCoreApi): List<Any?>? {
    return null
  }

  override fun aNullableMap(pigeon_instance: ProxyIntegrationCoreApi): Map<String?, Any?>? {
    return null
  }

  override fun aNullableEnum(pigeon_instance: ProxyIntegrationCoreApi): AnEnum? {
    return null
  }

  override fun aNullableProxyApi(pigeon_instance: ProxyIntegrationCoreApi): ProxyApiSuperClass? {
    return null
  }

  override fun noop(pigeon_instance: ProxyIntegrationCoreApi) {}

  override fun throwError(pigeon_instance: ProxyIntegrationCoreApi): Any? {
    throw Exception("message")
  }

  override fun throwErrorFromVoid(pigeon_instance: ProxyIntegrationCoreApi) {
    throw Exception("message")
  }

  override fun throwFlutterError(pigeon_instance: ProxyIntegrationCoreApi): Any? {
    throw CoreTestsError("code", "message", "details")
  }

  override fun echoInt(pigeon_instance: ProxyIntegrationCoreApi, anInt: Long): Long {
    return anInt
  }

  override fun echoDouble(pigeon_instance: ProxyIntegrationCoreApi, aDouble: Double): Double {
    return aDouble
  }

  override fun echoBool(pigeon_instance: ProxyIntegrationCoreApi, aBool: Boolean): Boolean {
    return aBool
  }

  override fun echoString(pigeon_instance: ProxyIntegrationCoreApi, aString: String): String {
    return aString
  }

  override fun echoUint8List(
      pigeon_instance: ProxyIntegrationCoreApi,
      aUint8List: ByteArray
  ): ByteArray {
    return aUint8List
  }

  override fun echoObject(pigeon_instance: ProxyIntegrationCoreApi, anObject: Any): Any {
    return anObject
  }

  override fun echoList(pigeon_instance: ProxyIntegrationCoreApi, aList: List<Any?>): List<Any?> {
    return aList
  }

  override fun echoProxyApiList(
      pigeon_instance: ProxyIntegrationCoreApi,
      aList: List<ProxyIntegrationCoreApi>
  ): List<ProxyIntegrationCoreApi> {
    return aList
  }

  override fun echoMap(
      pigeon_instance: ProxyIntegrationCoreApi,
      aMap: Map<String?, Any?>
  ): Map<String?, Any?> {
    return aMap
  }

  override fun echoProxyApiMap(
      pigeon_instance: ProxyIntegrationCoreApi,
      aMap: Map<String, ProxyIntegrationCoreApi>
  ): Map<String, ProxyIntegrationCoreApi> {
    return aMap
  }

  override fun echoEnum(pigeon_instance: ProxyIntegrationCoreApi, anEnum: AnEnum): AnEnum {
    return anEnum
  }

  override fun echoProxyApi(
      pigeon_instance: ProxyIntegrationCoreApi,
      aProxyApi: ProxyApiSuperClass
  ): ProxyApiSuperClass {
    return aProxyApi
  }

  override fun echoNullableInt(
      pigeon_instance: ProxyIntegrationCoreApi,
      aNullableInt: Long?
  ): Long? {
    return aNullableInt
  }

  override fun echoNullableDouble(
      pigeon_instance: ProxyIntegrationCoreApi,
      aNullableDouble: Double?
  ): Double? {
    return aNullableDouble
  }

  override fun echoNullableBool(
      pigeon_instance: ProxyIntegrationCoreApi,
      aNullableBool: Boolean?
  ): Boolean? {
    return aNullableBool
  }

  override fun echoNullableString(
      pigeon_instance: ProxyIntegrationCoreApi,
      aNullableString: String?
  ): String? {
    return aNullableString
  }

  override fun echoNullableUint8List(
      pigeon_instance: ProxyIntegrationCoreApi,
      aNullableUint8List: ByteArray?
  ): ByteArray? {
    return aNullableUint8List
  }

  override fun echoNullableObject(
      pigeon_instance: ProxyIntegrationCoreApi,
      aNullableObject: Any?
  ): Any? {
    return aNullableObject
  }

  override fun echoNullableList(
      pigeon_instance: ProxyIntegrationCoreApi,
      aNullableList: List<Any?>?
  ): List<Any?>? {
    return aNullableList
  }

  override fun echoNullableMap(
      pigeon_instance: ProxyIntegrationCoreApi,
      aNullableMap: Map<String?, Any?>?
  ): Map<String?, Any?>? {
    return aNullableMap
  }

  override fun echoNullableEnum(
      pigeon_instance: ProxyIntegrationCoreApi,
      aNullableEnum: AnEnum?
  ): AnEnum? {
    return aNullableEnum
  }

  override fun echoNullableProxyApi(
      pigeon_instance: ProxyIntegrationCoreApi,
      aNullableProxyApi: ProxyApiSuperClass?
  ): ProxyApiSuperClass? {
    return aNullableProxyApi
  }

  override fun noopAsync(
      pigeon_instance: ProxyIntegrationCoreApi,
      callback: (Result<Unit>) -> Unit
  ) {
    callback(Result.success(Unit))
  }

  override fun echoAsyncInt(
      pigeon_instance: ProxyIntegrationCoreApi,
      anInt: Long,
      callback: (Result<Long>) -> Unit
  ) {
    callback(Result.success(anInt))
  }

  override fun echoAsyncDouble(
      pigeon_instance: ProxyIntegrationCoreApi,
      aDouble: Double,
      callback: (Result<Double>) -> Unit
  ) {
    callback(Result.success(aDouble))
  }

  override fun echoAsyncBool(
      pigeon_instance: ProxyIntegrationCoreApi,
      aBool: Boolean,
      callback: (Result<Boolean>) -> Unit
  ) {
    callback(Result.success(aBool))
  }

  override fun echoAsyncString(
      pigeon_instance: ProxyIntegrationCoreApi,
      aString: String,
      callback: (Result<String>) -> Unit
  ) {
    callback(Result.success(aString))
  }

  override fun echoAsyncUint8List(
      pigeon_instance: ProxyIntegrationCoreApi,
      aUint8List: ByteArray,
      callback: (Result<ByteArray>) -> Unit
  ) {
    callback(Result.success(aUint8List))
  }

  override fun echoAsyncObject(
      pigeon_instance: ProxyIntegrationCoreApi,
      anObject: Any,
      callback: (Result<Any>) -> Unit
  ) {
    callback(Result.success(anObject))
  }

  override fun echoAsyncList(
      pigeon_instance: ProxyIntegrationCoreApi,
      aList: List<Any?>,
      callback: (Result<List<Any?>>) -> Unit
  ) {
    callback(Result.success(aList))
  }

  override fun echoAsyncMap(
      pigeon_instance: ProxyIntegrationCoreApi,
      aMap: Map<String?, Any?>,
      callback: (Result<Map<String?, Any?>>) -> Unit
  ) {
    callback(Result.success(aMap))
  }

  override fun echoAsyncEnum(
      pigeon_instance: ProxyIntegrationCoreApi,
      anEnum: AnEnum,
      callback: (Result<AnEnum>) -> Unit
  ) {
    callback(Result.success(anEnum))
  }

  override fun throwAsyncError(
      pigeon_instance: ProxyIntegrationCoreApi,
      callback: (Result<Any?>) -> Unit
  ) {
    callback(Result.failure(Exception("message")))
  }

  override fun throwAsyncErrorFromVoid(
      pigeon_instance: ProxyIntegrationCoreApi,
      callback: (Result<Unit>) -> Unit
  ) {
    callback(Result.failure(Exception("message")))
  }

  override fun throwAsyncFlutterError(
      pigeon_instance: ProxyIntegrationCoreApi,
      callback: (Result<Any?>) -> Unit
  ) {
    callback(Result.failure(CoreTestsError("message")))
  }

  override fun echoAsyncNullableInt(
      pigeon_instance: ProxyIntegrationCoreApi,
      anInt: Long?,
      callback: (Result<Long?>) -> Unit
  ) {
    callback(Result.success(anInt))
  }

  override fun echoAsyncNullableDouble(
      pigeon_instance: ProxyIntegrationCoreApi,
      aDouble: Double?,
      callback: (Result<Double?>) -> Unit
  ) {
    callback(Result.success(aDouble))
  }

  override fun echoAsyncNullableBool(
      pigeon_instance: ProxyIntegrationCoreApi,
      aBool: Boolean?,
      callback: (Result<Boolean?>) -> Unit
  ) {
    callback(Result.success(aBool))
  }

  override fun echoAsyncNullableString(
      pigeon_instance: ProxyIntegrationCoreApi,
      aString: String?,
      callback: (Result<String?>) -> Unit
  ) {
    callback(Result.success(aString))
  }

  override fun echoAsyncNullableUint8List(
      pigeon_instance: ProxyIntegrationCoreApi,
      aUint8List: ByteArray?,
      callback: (Result<ByteArray?>) -> Unit
  ) {
    callback(Result.success(aUint8List))
  }

  override fun echoAsyncNullableObject(
      pigeon_instance: ProxyIntegrationCoreApi,
      anObject: Any?,
      callback: (Result<Any?>) -> Unit
  ) {
    callback(Result.success(anObject))
  }

  override fun echoAsyncNullableList(
      pigeon_instance: ProxyIntegrationCoreApi,
      aList: List<Any?>?,
      callback: (Result<List<Any?>?>) -> Unit
  ) {
    callback(Result.success(aList))
  }

  override fun echoAsyncNullableMap(
      pigeon_instance: ProxyIntegrationCoreApi,
      aMap: Map<String?, Any?>?,
      callback: (Result<Map<String?, Any?>?>) -> Unit
  ) {
    callback(Result.success(aMap))
  }

  override fun echoAsyncNullableEnum(
      pigeon_instance: ProxyIntegrationCoreApi,
      anEnum: AnEnum?,
      callback: (Result<AnEnum?>) -> Unit
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
      pigeon_instance: ProxyIntegrationCoreApi,
      callback: (Result<Unit>) -> Unit
  ) {
    flutterNoop(pigeon_instance, callback)
  }

  override fun callFlutterThrowError(
      pigeon_instance: ProxyIntegrationCoreApi,
      callback: (Result<Any?>) -> Unit
  ) {
    flutterThrowError(pigeon_instance, callback)
  }

  override fun callFlutterThrowErrorFromVoid(
      pigeon_instance: ProxyIntegrationCoreApi,
      callback: (Result<Unit>) -> Unit
  ) {
    flutterThrowErrorFromVoid(pigeon_instance, callback)
  }

  override fun callFlutterEchoBool(
      pigeon_instance: ProxyIntegrationCoreApi,
      aBool: Boolean,
      callback: (Result<Boolean>) -> Unit
  ) {
    flutterEchoBool(pigeon_instance, aBool, callback)
  }

  override fun callFlutterEchoInt(
      pigeon_instance: ProxyIntegrationCoreApi,
      anInt: Long,
      callback: (Result<Long>) -> Unit
  ) {
    flutterEchoInt(pigeon_instance, anInt, callback)
  }

  override fun callFlutterEchoDouble(
      pigeon_instance: ProxyIntegrationCoreApi,
      aDouble: Double,
      callback: (Result<Double>) -> Unit
  ) {
    flutterEchoDouble(pigeon_instance, aDouble, callback)
  }

  override fun callFlutterEchoString(
      pigeon_instance: ProxyIntegrationCoreApi,
      aString: String,
      callback: (Result<String>) -> Unit
  ) {
    flutterEchoString(pigeon_instance, aString, callback)
  }

  override fun callFlutterEchoUint8List(
      pigeon_instance: ProxyIntegrationCoreApi,
      aUint8List: ByteArray,
      callback: (Result<ByteArray>) -> Unit
  ) {
    flutterEchoUint8List(pigeon_instance, aUint8List, callback)
  }

  override fun callFlutterEchoList(
      pigeon_instance: ProxyIntegrationCoreApi,
      aList: List<Any?>,
      callback: (Result<List<Any?>>) -> Unit
  ) {
    flutterEchoList(pigeon_instance, aList, callback)
  }

  override fun callFlutterEchoProxyApiList(
      pigeon_instance: ProxyIntegrationCoreApi,
      aList: List<ProxyIntegrationCoreApi?>,
      callback: (Result<List<ProxyIntegrationCoreApi?>>) -> Unit
  ) {
    flutterEchoProxyApiList(pigeon_instance, aList, callback)
  }

  override fun callFlutterEchoMap(
      pigeon_instance: ProxyIntegrationCoreApi,
      aMap: Map<String?, Any?>,
      callback: (Result<Map<String?, Any?>>) -> Unit
  ) {
    flutterEchoMap(pigeon_instance, aMap, callback)
  }

  override fun callFlutterEchoProxyApiMap(
      pigeon_instance: ProxyIntegrationCoreApi,
      aMap: Map<String?, ProxyIntegrationCoreApi?>,
      callback: (Result<Map<String?, ProxyIntegrationCoreApi?>>) -> Unit
  ) {
    flutterEchoProxyApiMap(pigeon_instance, aMap, callback)
  }

  override fun callFlutterEchoEnum(
      pigeon_instance: ProxyIntegrationCoreApi,
      anEnum: AnEnum,
      callback: (Result<AnEnum>) -> Unit
  ) {
    flutterEchoEnum(pigeon_instance, anEnum, callback)
  }

  override fun callFlutterEchoProxyApi(
      pigeon_instance: ProxyIntegrationCoreApi,
      aProxyApi: ProxyApiSuperClass,
      callback: (Result<ProxyApiSuperClass>) -> Unit
  ) {
    flutterEchoProxyApi(pigeon_instance, aProxyApi, callback)
  }

  override fun callFlutterEchoNullableBool(
      pigeon_instance: ProxyIntegrationCoreApi,
      aBool: Boolean?,
      callback: (Result<Boolean?>) -> Unit
  ) {
    flutterEchoNullableBool(pigeon_instance, aBool, callback)
  }

  override fun callFlutterEchoNullableInt(
      pigeon_instance: ProxyIntegrationCoreApi,
      anInt: Long?,
      callback: (Result<Long?>) -> Unit
  ) {
    flutterEchoNullableInt(pigeon_instance, anInt, callback)
  }

  override fun callFlutterEchoNullableDouble(
      pigeon_instance: ProxyIntegrationCoreApi,
      aDouble: Double?,
      callback: (Result<Double?>) -> Unit
  ) {
    flutterEchoNullableDouble(pigeon_instance, aDouble, callback)
  }

  override fun callFlutterEchoNullableString(
      pigeon_instance: ProxyIntegrationCoreApi,
      aString: String?,
      callback: (Result<String?>) -> Unit
  ) {
    flutterEchoNullableString(pigeon_instance, aString, callback)
  }

  override fun callFlutterEchoNullableUint8List(
      pigeon_instance: ProxyIntegrationCoreApi,
      aUint8List: ByteArray?,
      callback: (Result<ByteArray?>) -> Unit
  ) {
    flutterEchoNullableUint8List(pigeon_instance, aUint8List, callback)
  }

  override fun callFlutterEchoNullableList(
      pigeon_instance: ProxyIntegrationCoreApi,
      aList: List<Any?>?,
      callback: (Result<List<Any?>?>) -> Unit
  ) {
    flutterEchoNullableList(pigeon_instance, aList, callback)
  }

  override fun callFlutterEchoNullableMap(
      pigeon_instance: ProxyIntegrationCoreApi,
      aMap: Map<String?, Any?>?,
      callback: (Result<Map<String?, Any?>?>) -> Unit
  ) {
    flutterEchoNullableMap(pigeon_instance, aMap, callback)
  }

  override fun callFlutterEchoNullableEnum(
      pigeon_instance: ProxyIntegrationCoreApi,
      anEnum: AnEnum?,
      callback: (Result<AnEnum?>) -> Unit
  ) {
    flutterEchoNullableEnum(pigeon_instance, anEnum, callback)
  }

  override fun callFlutterEchoNullableProxyApi(
      pigeon_instance: ProxyIntegrationCoreApi,
      aProxyApi: ProxyApiSuperClass?,
      callback: (Result<ProxyApiSuperClass?>) -> Unit
  ) {
    flutterEchoNullableProxyApi(pigeon_instance, aProxyApi, callback)
  }

  override fun callFlutterNoopAsync(
      pigeon_instance: ProxyIntegrationCoreApi,
      callback: (Result<Unit>) -> Unit
  ) {
    flutterNoopAsync(pigeon_instance, callback)
  }

  override fun callFlutterEchoAsyncString(
      pigeon_instance: ProxyIntegrationCoreApi,
      aString: String,
      callback: (Result<String>) -> Unit
  ) {
    flutterEchoAsyncString(pigeon_instance, aString, callback)
  }
}

class ProxyApiSuperClassApiImpl(codec: Pigeon_ProxyApiBaseCodec) : ProxyApiSuperClass_Api(codec) {
  override fun pigeon_defaultConstructor(): ProxyApiSuperClass {
    return ProxyApiSuperClass()
  }

  override fun aSuperMethod(pigeon_instance: ProxyApiSuperClass) {}
}

class ProxyApiInterfaceApiImpl(codec: Pigeon_ProxyApiBaseCodec) : ProxyApiInterface_Api(codec)
