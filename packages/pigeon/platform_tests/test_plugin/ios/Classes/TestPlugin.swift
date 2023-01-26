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

  func echo(_ everything: AllTypes) -> AllTypes {
    return everything
  }

  func echo(_ everything: AllNullableTypes?) -> AllNullableTypes? {
    return everything
  }

  func throwError() {
    // TODO(stuartmorgan): Implement this. See
    // https://github.com/flutter/flutter/issues/112483
  }

  func echo(_ anInt: Int32) -> Int32 {
    return anInt
  }

  func echo(_ aDouble: Double) -> Double {
    return aDouble
  }

  func echo(_ aBool: Bool) -> Bool {
    return aBool
  }

  func echo(_ aString: String) -> String {
    return aString
  }

  func echo(_ aUint8List: FlutterStandardTypedData) -> FlutterStandardTypedData {
    return aUint8List
  }

  func echo(_ anObject: Any) -> Any {
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

  func echo(_ aNullableInt: Int32?) -> Int32? {
    return aNullableInt
  }

  func echo(_ aNullableDouble: Double?) -> Double? {
    return aNullableDouble
  }

  func echo(_ aNullableBool: Bool?) -> Bool? {
    return aNullableBool
  }

  func echo(_ aNullableString: String?) -> String? {
    return aNullableString
  }

  func echo(_ aNullableUint8List: FlutterStandardTypedData?) -> FlutterStandardTypedData? {
    return aNullableUint8List
  }

  func echo(_ aNullableObject: Any?) -> Any? {
    return aNullableObject
  }

  func noopAsync(completion: @escaping () -> Void) {
    completion()
  }

  func echoAsync(_ aString: String, completion: @escaping (String) -> Void) {
    completion(aString)
  }

  func callFlutterNoop(completion: @escaping () -> Void) {
    flutterAPI.noop() {
      completion()
    }
  }

  func callFlutterEcho(_ everything: AllTypes, completion: @escaping (AllTypes) -> Void) {
      flutterAPI.echo(everything) { completion($0) }
  }

  func callFlutterSendMultipleNullableTypes(
    aBool aNullableBool: Bool?,
    anInt aNullableInt: Int32?,
    aString aNullableString: String?,
    completion: @escaping (AllNullableTypes) -> Void
  ) {
    flutterAPI.sendMultipleNullableTypes(
      aBool: aNullableBool,
      anInt: aNullableInt,
      aString: aNullableString
    ) {
      completion($0)
    }
  }

  func callFlutterEcho(_ aBool: Bool, completion: @escaping (Bool) -> Void) {
    flutterAPI.echo(aBool) { completion($0) }
  }

  func callFlutterEcho(_ anInt: Int32, completion: @escaping (Int32) -> Void) {
    flutterAPI.echo(anInt) { completion($0) }
  }

  func callFlutterEcho(_ aDouble: Double, completion: @escaping (Double) -> Void) {
    flutterAPI.echo(aDouble) { completion($0) }
  }

  func callFlutterEcho(_ aString: String, completion: @escaping (String) -> Void) {
    flutterAPI.echo(aString) { completion($0) }
  }

  func callFlutterEcho(_ aList: FlutterStandardTypedData, completion: @escaping (FlutterStandardTypedData) -> Void) {
    flutterAPI.echo(aList) { completion($0) }
  }

  func callFlutterEcho(_ aList: [Any?], completion: @escaping ([Any?]) -> Void) {
    flutterAPI.echo(aList) { completion($0) }
  }

  func callFlutterEcho(_ aMap: [String? : Any?], completion: @escaping ([String? : Any?]) -> Void) {
    flutterAPI.echo(aMap) { completion($0) }
  }

  func callFlutterEchoNullable(_ aBool: Bool?, completion: @escaping (Bool?) -> Void) {
    flutterAPI.echoNullable(aBool) { completion($0) }
  }

  func callFlutterEchoNullable(_ anInt: Int32?, completion: @escaping (Int32?) -> Void) {
    flutterAPI.echoNullable(anInt) { completion($0) }
  }

  func callFlutterEchoNullable(_ aDouble: Double?, completion: @escaping (Double?) -> Void) {
    flutterAPI.echoNullable(aDouble) { completion($0) }
  }

  func callFlutterEchoNullable(_ aString: String?, completion: @escaping (String?) -> Void) {
    flutterAPI.echoNullable(aString) { completion($0) }
  }

  func callFlutterEchoNullable(_ aList: FlutterStandardTypedData?, completion: @escaping (FlutterStandardTypedData?) -> Void) {
    flutterAPI.echoNullable(aList) { completion($0) }
  }

  func callFlutterEchoNullable(_ aList: [Any?]?, completion: @escaping ([Any?]?) -> Void) {
    flutterAPI.echoNullable(aList) { completion($0) }
  }

  func callFlutterEchoNullable(_ aMap: [String? : Any?]?, completion: @escaping ([String? : Any?]?) -> Void) {
    flutterAPI.echoNullable(aMap) { completion($0) }
  }
}
