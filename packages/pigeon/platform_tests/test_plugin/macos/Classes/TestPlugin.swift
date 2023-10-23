// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Cocoa
import FlutterMacOS

extension FlutterError: Error {}

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

  func throwError() throws -> Any? {
    throw FlutterError(code: "code", message: "message", details: "details")
  }

  func throwErrorFromVoid() throws {
    throw FlutterError(code: "code", message: "message", details: "details")
  }

  func throwFlutterError() throws -> Any? {
    throw FlutterError(code: "code", message: "message", details: "details")
  }

  func echo(_ anInt: Int64) -> Int64 {
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

  func echo(_ wrapper: AllClassesWrapper) throws -> AllClassesWrapper {
    return wrapper
  }

  func echo(_ anEnum: AnEnum) throws -> AnEnum {
    return anEnum
  }

  func extractNestedNullableString(from wrapper: AllClassesWrapper) -> String? {
    return wrapper.allNullableTypes.aNullableString;
  }

  func createNestedObject(with nullableString: String?) -> AllClassesWrapper {
    return AllClassesWrapper(allNullableTypes: AllNullableTypes(aNullableString: nullableString))
  }

  func sendMultipleNullableTypes(aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?) -> AllNullableTypes {
    let someThings = AllNullableTypes(aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
    return someThings
  }

  func echo(_ aNullableInt: Int64?) -> Int64? {
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

  func echoNullable(_ anEnum: AnEnum?) throws -> AnEnum? {
    return anEnum
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

  func throwAsyncFlutterError(completion: @escaping (Result<Any?, Error>) -> Void) {
    completion(.failure(FlutterError(code: "code", message: "message", details: "details")))
  }

  func echoAsync(_ everything: AllTypes, completion: @escaping (Result<AllTypes, Error>) -> Void) {
    completion(.success(everything))
  }

  func echoAsync(_ everything: AllNullableTypes?, completion: @escaping (Result<AllNullableTypes?, Error>) -> Void) {
    completion(.success(everything))
  }

  func echoAsync(_ anInt: Int64, completion: @escaping (Result<Int64, Error>) -> Void) {
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

  func echoAsync(_ anEnum: AnEnum, completion: @escaping (Result<AnEnum, Error>) -> Void) {
    completion(.success(anEnum))
  }

  func echoAsyncNullable(_ anInt: Int64?, completion: @escaping (Result<Int64?, Error>) -> Void) {
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

  func echoAsyncNullable(_ aMap: [String?: Any?]?, completion: @escaping (Result<[String?: Any?]?, Error>) -> Void) {
    completion(.success(aMap))
  }

  func echoAsyncNullable(_ anEnum: AnEnum?, completion: @escaping (Result<AnEnum?, Error>) -> Void) {
    completion(.success(anEnum))
  }

  func callFlutterNoop(completion: @escaping (Result<Void, Error>) -> Void) {
    flutterAPI.noop() { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  func callFlutterThrowError(completion: @escaping (Result<Any?, Error>) -> Void) {
    flutterAPI.throwError() { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  func callFlutterThrowErrorFromVoid(completion: @escaping (Result<Void, Error>) -> Void) {
    flutterAPI.throwErrorFromVoid() { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(_ everything: AllTypes, completion: @escaping (Result<AllTypes, Error>) -> Void) {
    flutterAPI.echo(everything) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      } 
    }
  }

  func callFlutterEcho(_ everything: AllNullableTypes?, completion: @escaping (Result<AllNullableTypes?, Error>) -> Void) {
    flutterAPI.echoNullable(everything) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      } 
    }
  }

  func callFlutterSendMultipleNullableTypes(
    aBool aNullableBool: Bool?,
    anInt aNullableInt: Int64?,
    aString aNullableString: String?,
    completion: @escaping (Result<AllNullableTypes, Error>) -> Void
  ) {
    flutterAPI.sendMultipleNullableTypes(
      aBool: aNullableBool,
      anInt: aNullableInt,
      aString: aNullableString
    ) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(_ aBool: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
    flutterAPI.echo(aBool) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(_ anInt: Int64, completion: @escaping (Result<Int64, Error>) -> Void) {
    flutterAPI.echo(anInt) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(_ aDouble: Double, completion: @escaping (Result<Double, Error>) -> Void) {
    flutterAPI.echo(aDouble) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(_ aString: String, completion: @escaping (Result<String, Error>) -> Void) {
    flutterAPI.echo(aString) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(_ aList: FlutterStandardTypedData, completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void) {
    flutterAPI.echo(aList) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(_ aList: [Any?], completion: @escaping (Result<[Any?], Error>) -> Void) {
    flutterAPI.echo(aList) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(_ aMap: [String? : Any?], completion: @escaping (Result<[String? : Any?], Error>) -> Void) {
    flutterAPI.echo(aMap) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(_ anEnum: AnEnum, completion: @escaping (Result<AnEnum, Error>) -> Void) {
    flutterAPI.echo(anEnum) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(_ aBool: Bool?, completion: @escaping (Result<Bool?, Error>) -> Void) {
    flutterAPI.echoNullable(aBool) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(_ anInt: Int64?, completion: @escaping (Result<Int64?, Error>) -> Void) {
    flutterAPI.echoNullable(anInt) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(_ aDouble: Double?, completion: @escaping (Result<Double?, Error>) -> Void) {
    flutterAPI.echoNullable(aDouble) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(_ aString: String?, completion: @escaping (Result<String?, Error>) -> Void) {
    flutterAPI.echoNullable(aString) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }
  
  func callFlutterEchoNullable(_ aList: FlutterStandardTypedData?, completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void) {
    flutterAPI.echoNullable(aList) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(_ aList: [Any?]?, completion: @escaping (Result<[Any?]?, Error>) -> Void) {
    flutterAPI.echoNullable(aList) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(_ aMap: [String? : Any?]?, completion: @escaping (Result<[String? : Any?]?, Error>) -> Void) {
    flutterAPI.echoNullable(aMap) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  func callFlutterNullableEcho(_ anEnum: AnEnum?, completion: @escaping (Result<AnEnum?, Error>) -> Void) {
    flutterAPI.echoNullable(anEnum) { response in
      switch response {
        case .success(let res):
          completion(.success(res))
        case .failure(let error):
          completion(.failure(error))
      }
    }    
  }
}
