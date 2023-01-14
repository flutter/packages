// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * This plugin handles the native side of the integration tests in
 * example/integration_test/.
 */
class TestPlugin: FlutterPlugin, HostIntegrationCoreApi {
  var flutterApi: FlutterIntegrationCoreApi? = null

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    HostIntegrationCoreApi.setUp(binding.getBinaryMessenger(), this)
    flutterApi = FlutterIntegrationCoreApi(binding.getBinaryMessenger())
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }

  // HostIntegrationCoreApi

  override fun noop() {
  }

  override fun echoAllTypes(everything: AllTypes): AllTypes {
    return everything
  }

  override fun echoAllNullableTypes(everything: AllNullableTypes?): AllNullableTypes? {
    return everything
  }

  override fun throwError() {
    throw Exception("An error");
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

  override fun extractNestedNullableString(wrapper: AllNullableTypesWrapper): String? {
    return wrapper.values.aNullableString
  }

  override fun createNestedNullableString(nullableString: String?): AllNullableTypesWrapper {
    return AllNullableTypesWrapper(AllNullableTypes(aNullableString = nullableString))
  }

  override fun sendMultipleNullableTypes(aNullableBool: Boolean?, aNullableInt: Long?, aNullableString: String?): AllNullableTypes {
    return AllNullableTypes(aNullableBool = aNullableBool, aNullableInt = aNullableInt, aNullableString = aNullableString)
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

  override fun noopAsync(callback: () -> Unit) {
    callback()
  }

  override fun echoAsyncString(aString: String, callback: (String) -> Unit) {
    callback(aString)
  }

  override fun callFlutterNoop(callback: () -> Unit) {
    flutterApi!!.noop() { callback() }
  }

  override fun callFlutterEchoString(aString: String, callback: (String) -> Unit) {
    flutterApi!!.echoString(aString) { flutterString -> callback(flutterString) }
  }
}
