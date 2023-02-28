// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

extension FlutterError: Error {}

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

  func throwError() throws -> Any? {
    throw FlutterError(code: "code", message: "message", details: "details")
  }

  func throwErrorFromVoid() throws {
    throw FlutterError(code: "code", message: "message", details: "details")
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

  func echo(_ aList: [Any?]) throws -> [Any?] {
    return aList
  }

  func echo(_ aMap: [String?: Any?]) throws -> [String?: Any?] {
    return aMap
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

  func echoNullable(_ aNullableList: [Any?]?) throws -> [Any?]? {
    return aNullableList
  }

  func echoNullable(_ aNullableMap: [String?: Any?]?) throws -> [String?: Any?]? {
    return aNullableMap
  }

  func noopAsync(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.success(Void()))
  }

  func throwAsyncError(completion: @escaping (Result<Any?, Error>) -> Void) {
    completion(.failure(FlutterError(code: "code", message: "message", details: "details")))
  }

  func throwAsyncErrorFromVoid(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(FlutterError(code: "code", message: "message", details: "details")))
  }

  func echoAsync(_ everything: AllTypes, completion: @escaping (Result<AllTypes, Error>) -> Void) {
    completion(.success(everything))
  }

  func echoAsync(_ everything: AllNullableTypes?, completion: @escaping (Result<AllNullableTypes?, Error>) -> Void) {
    completion(.success(everything))
  }

  func echoAsync(_ anInt: Int32, completion: @escaping (Result<Int32, Error>) -> Void) {
    completion(.success(anInt))
  }

  func echoAsync(_ aDouble: Double, completion: @escaping (Result<Double, Error>) -> Void) {
    completion(.success(aDouble))
  }

  func echoAsync(_ aBool: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
    completion(.success(aBool))
  }

  func echoAsync(_ aString: String, completion: @escaping (Result<String, Error>) -> Void) {
    completion(.success(aString))
  }

  func echoAsync(_ aUint8List: FlutterStandardTypedData, completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void) {
    completion(.success(aUint8List))
  }

  func echoAsync(_ anObject: Any, completion: @escaping (Result<Any, Error>) -> Void) {
    completion(.success(anObject))
  }

  func echoAsync(_ aList: [Any?], completion: @escaping (Result<[Any?], Error>) -> Void) {
    completion(.success(aList))
  }

  func echoAsync(_ aMap: [String?: Any?], completion: @escaping (Result<[String?: Any?], Error>) -> Void) {
    completion(.success(aMap))
  }

  func echoAsyncNullable(_ anInt: Int32?, completion: @escaping (Result<Int32?, Error>) -> Void) {
    completion(.success(anInt))
  }

  func echoAsyncNullable(_ aDouble: Double?, completion: @escaping (Result<Double?, Error>) -> Void) {
    completion(.success(aDouble))
  }

  func echoAsyncNullable(_ aBool: Bool?, completion: @escaping (Result<Bool?, Error>) -> Void) {
    completion(.success(aBool))
  }

  func echoAsyncNullable(_ aString: String?, completion: @escaping (Result<String?, Error>) -> Void) {
    completion(.success(aString))
  }

  func echoAsyncNullable(_ aUint8List: FlutterStandardTypedData?, completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void) {
    completion(.success(aUint8List))
  }

  func echoAsyncNullable(_ anObject: Any?, completion: @escaping (Result<Any?, Error>) -> Void) {
    completion(.success(anObject))
  }

  func echoAsyncNullable(_ aList: [Any?]?, completion: @escaping (Result<[Any?]?, Error>) -> Void) {
    completion(.success(aList))
  }

  func echAsyncoNullable(_ aMap: [String?: Any?]?, completion: @escaping (Result<[String?: Any?]?, Error>) -> Void) {
    completion(.success(aMap))
  }

  func callFlutterNoop(completion: @escaping (Result<Void, Error>) -> Void) {
    flutterAPI.noop() {
      completion(.success(Void()))
    }
  }

  func callFlutterThrowError(completion: @escaping (Result<Any?, Error>) -> Void) {
    // TODO: (tarrinneal) Once flutter api error handling is added, enable these tests.
    // See issue https://github.com/flutter/flutter/issues/118243
  }

  func callFlutterThrowErrorFromVoid(completion: @escaping (Result<Void, Error>) -> Void) {
    // TODO: (tarrinneal) Once flutter api error handling is added, enable these tests.
    // See issue https://github.com/flutter/flutter/issues/118243
  }

  func callFlutterEcho(_ everything: AllTypes, completion: @escaping (Result<AllTypes, Error>) -> Void) {
    flutterAPI.echo(everything) { 
      completion(.success($0)) 
    }
  }

  func callFlutterSendMultipleNullableTypes(
    aBool aNullableBool: Bool?,
    anInt aNullableInt: Int32?,
    aString aNullableString: String?,
    completion: @escaping (Result<AllNullableTypes, Error>) -> Void
  ) {
    flutterAPI.sendMultipleNullableTypes(
      aBool: aNullableBool,
      anInt: aNullableInt,
      aString: aNullableString
    ) {
      completion(.success($0))
    }
  }

  func callFlutterEcho(_ aBool: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
    flutterAPI.echo(aBool) {
      completion(.success($0))
    }
  }

  func callFlutterEcho(_ anInt: Int32, completion: @escaping (Result<Int32, Error>) -> Void) {
    flutterAPI.echo(anInt) {
      completion(.success($0))
    }
  }

  func callFlutterEcho(_ aDouble: Double, completion: @escaping (Result<Double, Error>) -> Void) {
    flutterAPI.echo(aDouble) {
      completion(.success($0))
    }
  }

  func callFlutterEcho(_ aString: String, completion: @escaping (Result<String, Error>) -> Void) {
    flutterAPI.echo(aString) {
      completion(.success($0))
    }
  }

  func callFlutterEcho(_ aList: FlutterStandardTypedData, completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void) {
    flutterAPI.echo(aList) {
      completion(.success($0))
    }
  }

  func callFlutterEcho(_ aList: [Any?], completion: @escaping (Result<[Any?], Error>) -> Void) {
    flutterAPI.echo(aList) {
      completion(.success($0))
    }
  }

  func callFlutterEcho(_ aMap: [String? : Any?], completion: @escaping (Result<[String? : Any?], Error>) -> Void) {
    flutterAPI.echo(aMap) {
      completion(.success($0))
    }
  }

  func callFlutterEchoNullable(_ aBool: Bool?, completion: @escaping (Result<Bool?, Error>) -> Void) {
    flutterAPI.echoNullable(aBool) {
      completion(.success($0))
    }
  }

  func callFlutterEchoNullable(_ anInt: Int32?, completion: @escaping (Result<Int32?, Error>) -> Void) {
    flutterAPI.echoNullable(anInt) {
      completion(.success($0))
    }
  }

  func callFlutterEchoNullable(_ aDouble: Double?, completion: @escaping (Result<Double?, Error>) -> Void) {
    flutterAPI.echoNullable(aDouble) {
      completion(.success($0))
    }
  }

  func callFlutterEchoNullable(_ aString: String?, completion: @escaping (Result<String?, Error>) -> Void) {
    flutterAPI.echoNullable(aString) {
      completion(.success($0))
    }
  }
  
  func callFlutterEchoNullable(_ aList: FlutterStandardTypedData?, completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void) {
    flutterAPI.echoNullable(aList) {
      completion(.success($0))
    }
  }

  func callFlutterEchoNullable(_ aList: [Any?]?, completion: @escaping (Result<[Any?]?, Error>) -> Void) {
    flutterAPI.echoNullable(aList) {
      completion(.success($0))
    }
  }

  func callFlutterEchoNullable(_ aMap: [String? : Any?]?, completion: @escaping (Result<[String? : Any?]?, Error>) -> Void) {
    flutterAPI.echoNullable(aMap) {
      completion(.success($0))
    }
  }
}
