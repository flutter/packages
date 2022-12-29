// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

/**
 * This plugin handles the native side of the integration tests in
 * example/integration_test/.
 */
public class TestPlugin: NSObject, FlutterPlugin, HostIntegrationCoreApi {
  var flutterAPI: FlutterIntegrationCoreApi

  public static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = TestPlugin(binaryMessenger: registrar.messenger())
    HostIntegrationCoreApiSetup.setUp(binaryMessenger: registrar.messenger(), api: plugin)
  }

  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterAPI = FlutterIntegrationCoreApi(binaryMessenger: binaryMessenger)
  }

  // MARK: HostIntegrationCoreApi implementation

  public func noop() {
  }

  public func echoAllTypes(everything: AllTypes) -> AllTypes {
    return everything
  }

  public func echoAllNullableTypes(everything: AllNullableTypes?) -> AllNullableTypes? {
    return everything
  }

  public func throwError() {
    // TODO(stuartmorgan): Implement this. See
    // https://github.com/flutter/flutter/issues/112483
  }

  public func echoInt(anInt: Int32) -> Int32 {
    return anInt
  }

  public func echoDouble(aDouble: Double) -> Double {
    return aDouble
  }

  public func echoBool(aBool: Bool) -> Bool {
    return aBool
  }

  public func echoString(aString: String) -> String {
    return aString
  }

  public func echoUint8List(aUint8List: FlutterStandardTypedData) -> FlutterStandardTypedData {
    return aUint8List
  }

  public func extractNestedNullableString(wrapper: AllNullableTypesWrapper) -> String? {
    return wrapper.values.aNullableString;
  }

  public func createNestedNullableString(nullableString: String?) -> AllNullableTypesWrapper {
    return AllNullableTypesWrapper(values: AllNullableTypes(aNullableString: nullableString))
  }

  public func sendMultipleNullableTypes(aNullableBool: Bool?, aNullableInt: Int32?, aNullableString: String?) -> AllNullableTypes {
    let someThings = AllNullableTypes(aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
    return someThings
  }

  public func echoNullableInt(aNullableInt: Int32?) -> Int32? {
    return aNullableInt
  }

  public func echoNullableDouble(aNullableDouble: Double?) -> Double? {
    return aNullableDouble
  }

  public func echoNullableBool(aNullableBool: Bool?) -> Bool? {
    return aNullableBool
  }

  public func echoNullableString(aNullableString: String?) -> String? {
    return aNullableString
  }

  public func echoNullableUint8List(aNullableUint8List: FlutterStandardTypedData?) -> FlutterStandardTypedData? {
    return aNullableUint8List
  }

  public func noopAsync(completion: @escaping () -> Void) {
    completion()
  }

  public func echoAsyncString(aString: String, completion: @escaping (String) -> Void) {
    completion(aString)
  }

  public func callFlutterNoop(completion: @escaping () -> Void) {
    flutterAPI.noop() {
      completion()
    }
  }

  public func callFlutterEchoString(aString: String, completion: @escaping (String) -> Void) {
    flutterAPI.echoString(aString: aString) { flutterString in
      completion(flutterString)
    }
  }
}
