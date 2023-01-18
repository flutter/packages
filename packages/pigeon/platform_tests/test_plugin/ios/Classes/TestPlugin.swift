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

  func noop() {
  }

  func echo(allTypes everything: AllTypes) -> AllTypes {
    return everything
  }

  func echo(allNullableTypes everything: AllNullableTypes?) -> AllNullableTypes? {
    return everything
  }

  func throwError() {
    // TODO(stuartmorgan): Implement this. See
    // https://github.com/flutter/flutter/issues/112483
  }

  func echo(int anInt: Int32) -> Int32 {
    return anInt
  }

  func echo(double aDouble: Double) -> Double {
    return aDouble
  }

  func echo(bool aBool: Bool) -> Bool {
    return aBool
  }

  func echo(string aString: String) -> String {
    return aString
  }

  func echo(uint8List aUint8List: FlutterStandardTypedData) -> FlutterStandardTypedData {
    return aUint8List
  }

  func echo(object anObject: Any) -> Any {
    return anObject
  }

  func extractNestedNullableString(from wrapper: AllNullableTypesWrapper) -> String? {
    return wrapper.values.aNullableString;
  }

  func createNestedObject(with nullableString: String?) -> AllNullableTypesWrapper {
    return AllNullableTypesWrapper(values: AllNullableTypes(aNullableString: nullableString))
  }

  func sendMultipleNullableTypes(aBool aNullableBool: Bool?, anInt aNullableInt: Int32?, aString aNullableString: String?) -> AllNullableTypes {
    let someThings = AllNullableTypes(aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
    return someThings
  }

  func echo(nullableInt aNullableInt: Int32?) -> Int32? {
    return aNullableInt
  }

  func echo(nullableDouble aNullableDouble: Double?) -> Double? {
    return aNullableDouble
  }

  func echo(nullableBool aNullableBool: Bool?) -> Bool? {
    return aNullableBool
  }

  func echo(nullableString aNullableString: String?) -> String? {
    return aNullableString
  }

  func echo(nullableUint8List aNullableUint8List: FlutterStandardTypedData?) -> FlutterStandardTypedData? {
    return aNullableUint8List
  }

  func echo(nullableObject aNullableObject: Any?) -> Any? {
    return aNullableObject
  }

  func noopAsync(completion: @escaping () -> Void) {
    completion()
  }

  func echoAsync(string aString: String, completion: @escaping (String) -> Void) {
    completion(aString)
  }

  func callFlutterNoop(completion: @escaping () -> Void) {
    flutterAPI.noop() {
      completion()
    }
  }

  func callFlutterEcho(string aString: String, completion: @escaping (String) -> Void) {
    flutterAPI.echo(string: aString) { flutterString in
      completion(flutterString)
    }
  }
}
