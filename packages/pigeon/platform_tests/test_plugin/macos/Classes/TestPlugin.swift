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

  func echo(_ everything: AllTypes) -> AllTypes {
    return everything
  }

  func echo(_ everything: AllNullableTypes?) -> AllNullableTypes? {
    return everything
  }

  func throwError() throws {
    throw ErrType.thrownErrow
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

  func echoAsync(_ aString: String, completion: @escaping (Result<String, Error>) -> Void) {
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

  func callFlutterEcho(_ everything: AllTypes, completion: @escaping (Result<AllTypes, Error>) -> Void) {
    flutterAPI.echoAllTypes(everything: everything) { 
      let result: Result<AllTypes, Error>
      result = .success($0)
      completion(result) 
    }
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
      let result: Result<AllNullableTypes, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEcho(_ aBool: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
    flutterAPI.echoBool(aBool: aBool) { 
      let result: Result<Bool, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEcho(_ anInt: Int32, completion: @escaping (Result<Int32, Error>) -> Void) {
    flutterAPI.echoInt(anInt: anInt) { 
      let result: Result<Int32, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEcho(_ aDouble: Double,  completion: @escaping (Result<Double, Error>) -> Void) {
    flutterAPI.echoDouble(aDouble: aDouble) { 
      let result: Result<Double, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEcho(_ aString: String, completion: @escaping (Result<String, Error>) -> Void) {
    flutterAPI.echoString(aString: aString) { 
      let result: Result<String, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEcho(_ aList: FlutterStandardTypedData, completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void) {
    flutterAPI.echoUint8List(aList: aList) { 
      let result: Result<FlutterStandardTypedData, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEcho(_ aList: [Any?], completion: @escaping (Result<[Any?], Error>) -> Void) {
    flutterAPI.echoList(aList: aList) { 
      let result: Result<[Any?], Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEcho(_ aMap: [String? : Any?], completion: @escaping (Result<[String? : Any?], Error>) -> Void) {
    flutterAPI.echoMap(aMap: aMap) { 
      let result: Result<[String? : Any?], Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoNullable(_ aBool: Bool?, completion: @escaping (Result<Bool?, Error>) -> Void) {
    flutterAPI.echoNullableBool(aBool: aBool) { 
      let result: Result<Bool?, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoNullable(_ anInt: Int32?, completion: @escaping (Result<Int32?, Error>) -> Void) {
    flutterAPI.echoNullableInt(anInt: anInt) { 
      let result: Result<Int32?, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoNullable(_ aDouble: Double?, completion: @escaping (Result<Double?, Error>) -> Void) {
    flutterAPI.echoNullableDouble(aDouble: aDouble) { 
      let result: Result<Double?, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoNullable(_ aString: String?, completion: @escaping (Result<String?, Error>) -> Void) {
    flutterAPI.echoNullableString(aString: aString) { 
      let result: Result<String?, Error>
      result = .success($0)
      completion(result)
    }
  }
  
  func callFlutterEchoNullable(_ aList: FlutterStandardTypedData?, completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void) {
    flutterAPI.echoNullableUint8List(aList: aList) { 
      let result: Result<FlutterStandardTypedData?, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoNullable(_ aList: [Any?]?, completion: @escaping (Result<[Any?]?, Error>) -> Void) {
    flutterAPI.echoNullableList(aList: aList) { 
      let result: Result<[Any?]?, Error>
      result = .success($0)
      completion(result)
    }
  }

  func callFlutterEchoNullable(_ aMap: [String? : Any?]?, completion: @escaping (Result<[String? : Any?]?, Error>) -> Void) {
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