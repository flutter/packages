// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Cocoa
import FlutterMacOS

/**
 * This plugin handles the native side of the integration tests in
 * example/integration_test/.
 */
public class TestPlugin: NSObject, FlutterPlugin, HostIntegrationCoreApi {
  var flutterAPI: FlutterIntegrationCoreApi

  public static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = TestPlugin(binaryMessenger: registrar.messenger)
    HostIntegrationCoreApiSetup.setUp(binaryMessenger: registrar.messenger, api: plugin)
  }

  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterAPI = FlutterIntegrationCoreApi(binaryMessenger: binaryMessenger)
  }

  // MARK: HostIntegrationCoreApi implementation

    func noop() {
  }

  func echoAllTypes(everything: AllTypes) -> AllTypes {
    return everything
  }

  func echoAllNullableTypes(everything: AllNullableTypes?) -> AllNullableTypes? {
    return everything
  }

  func throwError() {
    // TODO(stuartmorgan): Implement this. See
    // https://github.com/flutter/flutter/issues/112483
  }

  func echoInt(anInt: Int32) -> Int32 {
    return anInt
  }

  func echoDouble(aDouble: Double) -> Double {
    return aDouble
  }

  func echoBool(aBool: Bool) -> Bool {
    return aBool
  }

  func echoString(aString: String) -> String {
    return aString
  }

  func echoUint8List(aUint8List: FlutterStandardTypedData) -> FlutterStandardTypedData {
    return aUint8List
  }

  func extractNestedNullableString(wrapper: AllNullableTypesWrapper) -> String? {
    return wrapper.values.aNullableString;
  }

  func createNestedNullableString(nullableString: String?) -> AllNullableTypesWrapper {
    return AllNullableTypesWrapper(values: AllNullableTypes(aNullableString: nullableString))
  }

  func sendMultipleNullableTypes(aNullableBool: Bool?, aNullableInt: Int32?, aNullableString: String?) -> AllNullableTypes {
    let someThings = AllNullableTypes(aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
    return someThings
  }

  func echoNullableInt(aNullableInt: Int32?) -> Int32? {
    return aNullableInt
  }

  func echoNullableDouble(aNullableDouble: Double?) -> Double? {
    return aNullableDouble
  }

  func echoNullableBool(aNullableBool: Bool?) -> Bool? {
    return aNullableBool
  }

  func echoNullableString(aNullableString: String?) -> String? {
    return aNullableString
  }

  func echoNullableUint8List(aNullableUint8List: FlutterStandardTypedData?) -> FlutterStandardTypedData? {
    return aNullableUint8List
  }

  func noopAsync(completion: @escaping () -> Void) {
    completion()
  }

  func echoAsyncString(aString: String, completion: @escaping (String) -> Void) {
    completion(aString)
  }

  func callFlutterNoop(completion: @escaping () -> Void) {
    flutterAPI.noop() {
      completion()
    }
  }

  func callFlutterEchoString(aString: String, completion: @escaping (String) -> Void) {
    flutterAPI.echoString(aString: aString) { flutterString in
      completion(flutterString)
    }
  }
}
