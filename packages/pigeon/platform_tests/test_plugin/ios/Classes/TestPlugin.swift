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

  func echoAllTypes(everything: AllTypes) -> AllTypes {
    return everything
  }

  func echoAllNullableTypes(everything: AllNullableTypes?) -> AllNullableTypes? {
    return everything
  }

  func throwError() throws {
    throw ErrType.thrownErrow
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

  func echoObject(anObject: Any) -> Any {
    return anObject
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

  func echoNullableObject(aNullableObject: Any?) -> Any? {
    return aNullableObject
  }

  func noopAsync(completion: @escaping () -> Void) {
    completion()
  }

  func echoAsyncString(aString: String, completion: @escaping (Result<String, Error>) -> Void) {
    let result: Result<String, Error>
    result = .success(aString)
    completion(result)
  }

  func throwAsyncError(completion: @escaping (Result<Any?, Error>) -> Void) {
    let result: Result<Any?, Error>
    result = .failure(ErrType.thrownErrow)
    completion(result)
  }

  func callFlutterNoop(completion: @escaping () -> Void) {
    flutterAPI.noop() {
      completion()
    }
  }

  func callFlutterEchoAllTypes(everything: AllTypes, completion: @escaping (Result<AllTypes, Error>) -> Void) {
    flutterAPI.echoAllTypes(everything: everything) { 
      let result: Result<AllTypes, Error>
      result = .success($0)
      completion(result) 
    }
  }

  func callFlutterSendMultipleNullableTypes(
    aNullableBool: Bool?,
    aNullableInt: Int32?,
    aNullableString: String?,
    completion: @escaping (Result<AllNullableTypes, Error>) -> Void
  ) {
    flutterAPI.sendMultipleNullableTypes(
      aNullableBool: aNullableBool,
      aNullableInt: aNullableInt,
      aNullableString: aNullableString
    ) {
      let result: Result<AllNullableTypes, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoBool(aBool: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
    flutterAPI.echoBool(aBool: aBool) { 
      let result: Result<Bool, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoInt(anInt: Int32, completion: @escaping (Result<Int32, Error>) -> Void) {
    flutterAPI.echoInt(anInt: anInt) { 
      let result: Result<Int32, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoDouble(aDouble: Double, completion: @escaping (Result<Double, Error>) -> Void) {
    flutterAPI.echoDouble(aDouble: aDouble) { 
      let result: Result<Double, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoString(aString: String, completion: @escaping (Result<String, Error>) -> Void) {
    flutterAPI.echoString(aString: aString) { 
      let result: Result<String, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoUint8List(aList: FlutterStandardTypedData, completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void) {
    flutterAPI.echoUint8List(aList: aList) { 
      let result: Result<FlutterStandardTypedData, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoList(aList: [Any?], completion: @escaping (Result<[Any?], Error>) -> Void) {
    flutterAPI.echoList(aList: aList) { 
      let result: Result<[Any?], Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoMap(aMap: [String? : Any?], completion: @escaping (Result<[String? : Any?], Error>) -> Void) {
    flutterAPI.echoMap(aMap: aMap) { 
      let result: Result<[String? : Any?], Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoNullableBool(aBool: Bool?, completion: @escaping (Result<Bool?, Error>) -> Void) {
    flutterAPI.echoNullableBool(aBool: aBool) { 
      let result: Result<Bool?, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoNullableInt(anInt: Int32?, completion: @escaping (Result<Int32?, Error>) -> Void) {
    flutterAPI.echoNullableInt(anInt: anInt) { 
      let result: Result<Int32?, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoNullableDouble(aDouble: Double?, completion: @escaping (Result<Double?, Error>) -> Void) {
    flutterAPI.echoNullableDouble(aDouble: aDouble) { 
      let result: Result<Double?, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoNullableString(aString: String?, completion: @escaping (Result<String?, Error>) -> Void) {
    flutterAPI.echoNullableString(aString: aString) { 
      let result: Result<String?, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoNullableUint8List(aList: FlutterStandardTypedData?, completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void) {
    flutterAPI.echoNullableUint8List(aList: aList) { 
      let result: Result<FlutterStandardTypedData?, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoNullableList(aList: [Any?]?, completion: @escaping (Result<[Any?]?, Error>) -> Void) {
    flutterAPI.echoNullableList(aList: aList) { 
      let result: Result<[Any?]?, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoNullableMap(aMap: [String? : Any?]?, completion: @escaping (Result<[String? : Any?]?, Error>) -> Void) {
    flutterAPI.echoNullableMap(aMap: aMap) { 
      let result: Result<[String? : Any?]?, Error>
      result = .success($0)
      completion(result)
    }
  }
}

enum ErrType: Error {
  case thrownErrow
}