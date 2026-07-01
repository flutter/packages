// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

/// This plugin handles the native side of the integration tests in
/// example/integration_test/.
public class TestPlugin: NSObject, FlutterPlugin, HostIntegrationCoreApi {
  var flutterAPI: FlutterIntegrationCoreApi
  var flutterSmallApiOne: FlutterSmallApi
  var flutterSmallApiTwo: FlutterSmallApi
  var proxyApiRegistrar: ProxyApiTestsPigeonProxyApiRegistrar?

  public static func register(with registrar: FlutterPluginRegistrar) {
    // Workaround for https://github.com/flutter/flutter/issues/118103.
    #if os(iOS)
      let messenger = registrar.messenger()
    #else
      let messenger = registrar.messenger
    #endif
    let plugin = TestPlugin(binaryMessenger: messenger)
    HostIntegrationCoreApiSetup.setUp(binaryMessenger: messenger, api: plugin)
    TestPluginWithSuffix.register(with: registrar, suffix: "suffixOne")
    TestPluginWithSuffix.register(with: registrar, suffix: "suffixTwo")
    registrar.publish(plugin)
  }

  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterAPI = FlutterIntegrationCoreApi(binaryMessenger: binaryMessenger)
    flutterSmallApiOne = FlutterSmallApi(
      binaryMessenger: binaryMessenger, messageChannelSuffix: "suffixOne")
    flutterSmallApiTwo = FlutterSmallApi(
      binaryMessenger: binaryMessenger, messageChannelSuffix: "suffixTwo")

    StreamIntsStreamHandler.register(with: binaryMessenger, streamHandler: SendInts())
    StreamEventsStreamHandler.register(with: binaryMessenger, streamHandler: SendEvents())
    StreamConsistentNumbersStreamHandler.register(
      with: binaryMessenger, instanceName: "1",
      streamHandler: SendConsistentNumbers(numberToSend: 1))
    StreamConsistentNumbersStreamHandler.register(
      with: binaryMessenger, instanceName: "2",
      streamHandler: SendConsistentNumbers(numberToSend: 2))
    proxyApiRegistrar = ProxyApiTestsPigeonProxyApiRegistrar(
      binaryMessenger: binaryMessenger, apiDelegate: ProxyApiDelegate())
    proxyApiRegistrar!.setUp()
    NIHostIntegrationCoreApiSetup.register(api: NITestsClass())
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    proxyApiRegistrar!.tearDown()
    proxyApiRegistrar = nil
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

  func areAllNullableTypesEqual(a: AllNullableTypes, b: AllNullableTypes) -> Bool {
    return a == b
  }

  func getAllNullableTypesHash(value: AllNullableTypes) -> Int64 {
    var hasher = Hasher()
    value.hash(into: &hasher)
    return Int64(hasher.finalize())
  }

  func getAllNullableTypesWithoutRecursionHash(value: AllNullableTypesWithoutRecursion) -> Int64 {
    var hasher = Hasher()
    value.hash(into: &hasher)
    return Int64(hasher.finalize())
  }
  func echo(_ everything: AllNullableTypesWithoutRecursion?) throws
    -> AllNullableTypesWithoutRecursion?
  {
    return everything
  }

  func throwError() throws -> Any? {
    throw PigeonError(code: "code", message: "message", details: "details")
  }

  func throwErrorFromVoid() throws {
    throw PigeonError(code: "code", message: "message", details: "details")
  }

  func throwFlutterError() throws -> Any? {
    throw PigeonError(code: "code", message: "message", details: "details")
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

  func echo(_ list: [Any?]) throws -> [Any?] {
    return list
  }

  func echo(stringList: [String?]) throws -> [String?] {
    return stringList
  }

  func echo(intList: [Int64?]) throws -> [Int64?] {
    return intList
  }

  func echo(doubleList: [Double?]) throws -> [Double?] {
    return doubleList
  }

  func echo(boolList: [Bool?]) throws -> [Bool?] {
    return boolList
  }

  func echo(enumList: [AnEnum?]) throws -> [AnEnum?] {
    return enumList
  }

  func echo(classList: [AllNullableTypes?]) throws -> [AllNullableTypes?] {
    return classList
  }

  func echoNonNull(enumList: [AnEnum]) throws -> [AnEnum] {
    return enumList
  }

  func echoNonNull(classList: [AllNullableTypes]) throws -> [AllNullableTypes] {
    return classList
  }

  func echo(_ map: [AnyHashable?: Any?]) throws -> [AnyHashable?: Any?] {
    return map
  }

  func echo(stringMap: [String?: String?]) throws -> [String?: String?] {
    return stringMap
  }

  func echo(intMap: [Int64?: Int64?]) throws -> [Int64?: Int64?] {
    return intMap
  }

  func echo(enumMap: [AnEnum?: AnEnum?]) throws -> [AnEnum?: AnEnum?] {
    return enumMap
  }

  func echo(classMap: [Int64?: AllNullableTypes?]) throws -> [Int64?: AllNullableTypes?] {
    return classMap
  }

  func echoNonNull(stringMap: [String: String]) throws -> [String: String] {
    return stringMap
  }

  func echoNonNull(intMap: [Int64: Int64]) throws -> [Int64: Int64] {
    return intMap
  }

  func echoNonNull(enumMap: [AnEnum: AnEnum]) throws -> [AnEnum: AnEnum] {
    return enumMap
  }

  func echoNonNull(classMap: [Int64: AllNullableTypes]) throws -> [Int64: AllNullableTypes] {
    return classMap
  }

  func echo(_ wrapper: AllClassesWrapper) throws -> AllClassesWrapper {
    return wrapper
  }

  func echo(_ anEnum: AnEnum) throws -> AnEnum {
    return anEnum
  }

  func echo(_ anotherEnum: AnotherEnum) throws -> AnotherEnum {
    return anotherEnum
  }

  func extractNestedNullableString(from wrapper: AllClassesWrapper) -> String? {
    return wrapper.allNullableTypes.aNullableString
  }

  func createNestedObject(with nullableString: String?) -> AllClassesWrapper {
    return AllClassesWrapper(
      allNullableTypes: AllNullableTypes(aNullableString: nullableString), classList: [],
      classMap: [:])
  }

  func sendMultipleNullableTypes(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?
  ) -> AllNullableTypes {
    let someThings = AllNullableTypes(
      aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
    return someThings
  }

  func sendMultipleNullableTypesWithoutRecursion(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?
  ) throws -> AllNullableTypesWithoutRecursion {
    let someThings = AllNullableTypesWithoutRecursion(
      aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
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

  func echoNamedDefault(_ aString: String) throws -> String {
    return aString
  }

  func echoOptionalDefault(_ aDouble: Double) throws -> Double {
    return aDouble
  }

  func echoRequired(_ anInt: Int64) throws -> Int64 {
    return anInt
  }

  func echoNullable(_ aNullableList: [Any?]?) throws -> [Any?]? {
    return aNullableList
  }

  func echoNullable(enumList: [AnEnum?]?) throws -> [AnEnum?]? {
    return enumList
  }

  func echoNullable(classList: [AllNullableTypes?]?) throws -> [AllNullableTypes?]? {
    return classList
  }

  func echoNullableNonNull(enumList: [AnEnum]?) throws -> [AnEnum]? {
    return enumList
  }

  func echoNullableNonNull(classList: [AllNullableTypes]?) throws -> [AllNullableTypes]? {
    return classList
  }

  func echoNullable(_ map: [AnyHashable?: Any?]?) throws -> [AnyHashable?: Any?]? {
    return map
  }

  func echoNullable(stringMap: [String?: String?]?) throws -> [String?: String?]? {
    return stringMap
  }

  func echoNullable(intMap: [Int64?: Int64?]?) throws -> [Int64?: Int64?]? {
    return intMap
  }

  func echoNullable(enumMap: [AnEnum?: AnEnum?]?) throws -> [AnEnum?: AnEnum?]? {
    return enumMap
  }

  func echoNullable(classMap: [Int64?: AllNullableTypes?]?) throws -> [Int64?: AllNullableTypes?]? {
    return classMap
  }

  func echoNullableNonNull(stringMap: [String: String]?) throws -> [String: String]? {
    return stringMap
  }

  func echoNullableNonNull(intMap: [Int64: Int64]?) throws -> [Int64: Int64]? {
    return intMap
  }

  func echoNullableNonNull(enumMap: [AnEnum: AnEnum]?) throws -> [AnEnum: AnEnum]? {
    return enumMap
  }

  func echoNullableNonNull(classMap: [Int64: AllNullableTypes]?) throws -> [Int64:
    AllNullableTypes]?
  {
    return classMap
  }

  func echoNullable(_ anEnum: AnEnum?) throws -> AnEnum? {
    return anEnum
  }

  func echoNullable(_ anotherEnum: AnotherEnum?) throws -> AnotherEnum? {
    return anotherEnum
  }

  func echoAsync(_ everything: AllTypes, completion: @escaping (Result<AllTypes, Error>) -> Void) {
    completion(.success(everything))
  }

  func echoAsync(
    _ everything: AllNullableTypes?,
    completion: @escaping (Result<AllNullableTypes?, Error>) -> Void
  ) {
    completion(.success(everything))
  }

  func echoAsync(
    _ everything: AllNullableTypesWithoutRecursion?,
    completion: @escaping (Result<AllNullableTypesWithoutRecursion?, Error>) -> Void
  ) {
    completion(.success(everything))
  }

  func echoAsync(
    _ aUint8List: FlutterStandardTypedData,
    completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
  ) {
    completion(.success(aUint8List))
  }

  func echoAsync(_ anObject: Any, completion: @escaping (Result<Any, Error>) -> Void) {
    completion(.success(anObject))
  }

  func echoAsync(_ list: [Any?], completion: @escaping (Result<[Any?], Error>) -> Void) {
    completion(.success(list))
  }

  func echoAsync(enumList: [AnEnum?], completion: @escaping (Result<[AnEnum?], Error>) -> Void) {
    completion(.success(enumList))
  }

  func echoAsync(
    classList: [AllNullableTypes?],
    completion: @escaping (Result<[AllNullableTypes?], Error>) -> Void
  ) {
    completion(.success(classList))
  }

  func echoAsync(
    _ map: [AnyHashable?: Any?], completion: @escaping (Result<[AnyHashable?: Any?], Error>) -> Void
  ) {
    completion(.success(map))
  }

  func echoAsync(
    stringMap: [String?: String?], completion: @escaping (Result<[String?: String?], Error>) -> Void
  ) {
    completion(.success(stringMap))
  }

  func echoAsync(
    intMap: [Int64?: Int64?], completion: @escaping (Result<[Int64?: Int64?], Error>) -> Void
  ) {
    completion(.success(intMap))
  }

  func echoAsync(
    enumMap: [AnEnum?: AnEnum?], completion: @escaping (Result<[AnEnum?: AnEnum?], Error>) -> Void
  ) {
    completion(.success(enumMap))
  }

  func echoAsync(
    classMap: [Int64?: AllNullableTypes?],
    completion: @escaping (Result<[Int64?: AllNullableTypes?], Error>) -> Void
  ) {
    completion(.success(classMap))
  }

  func echoAsync(_ anEnum: AnEnum, completion: @escaping (Result<AnEnum, Error>) -> Void) {
    completion(.success(anEnum))
  }

  func echoAsync(
    _ anotherEnum: AnotherEnum, completion: @escaping (Result<AnotherEnum, Error>) -> Void
  ) {
    completion(.success(anotherEnum))
  }

  func echoAsyncNullable(_ anInt: Int64?, completion: @escaping (Result<Int64?, Error>) -> Void) {
    completion(.success(anInt))
  }

  func echoAsyncNullable(_ aDouble: Double?, completion: @escaping (Result<Double?, Error>) -> Void)
  {
    completion(.success(aDouble))
  }

  func echoAsyncNullable(_ aBool: Bool?, completion: @escaping (Result<Bool?, Error>) -> Void) {
    completion(.success(aBool))
  }

  func echoAsyncNullable(_ aString: String?, completion: @escaping (Result<String?, Error>) -> Void)
  {
    completion(.success(aString))
  }

  func echoAsyncNullable(
    _ aUint8List: FlutterStandardTypedData?,
    completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void
  ) {
    completion(.success(aUint8List))
  }

  func echoAsyncNullable(_ anObject: Any?, completion: @escaping (Result<Any?, Error>) -> Void) {
    completion(.success(anObject))
  }

  func echoAsyncNullable(_ list: [Any?]?, completion: @escaping (Result<[Any?]?, Error>) -> Void) {
    completion(.success(list))
  }

  func echoAsyncNullable(
    enumList: [AnEnum?]?, completion: @escaping (Result<[AnEnum?]?, Error>) -> Void
  ) {
    completion(.success(enumList))
  }

  func echoAsyncNullable(
    classList: [AllNullableTypes?]?,
    completion: @escaping (Result<[AllNullableTypes?]?, Error>) -> Void
  ) {
    completion(.success(classList))
  }

  func echoAsyncNullable(
    _ map: [AnyHashable?: Any?]?,
    completion: @escaping (Result<[AnyHashable?: Any?]?, Error>) -> Void
  ) {
    completion(.success(map))
  }

  func echoAsyncNullable(
    stringMap: [String?: String?]?,
    completion: @escaping (Result<[String?: String?]?, Error>) -> Void
  ) {
    completion(.success(stringMap))
  }

  func echoAsyncNullable(
    intMap: [Int64?: Int64?]?, completion: @escaping (Result<[Int64?: Int64?]?, Error>) -> Void
  ) {
    completion(.success(intMap))
  }

  func echoAsyncNullable(
    enumMap: [AnEnum?: AnEnum?]?, completion: @escaping (Result<[AnEnum?: AnEnum?]?, Error>) -> Void
  ) {
    completion(.success(enumMap))
  }

  func echoAsyncNullable(
    classMap: [Int64?: AllNullableTypes?]?,
    completion: @escaping (Result<[Int64?: AllNullableTypes?]?, Error>) -> Void
  ) {
    completion(.success(classMap))
  }

  func echoAsyncNullable(
    _ anEnum: AnEnum?, completion: @escaping (Result<AnEnum?, Error>) -> Void
  ) {
    completion(.success(anEnum))
  }

  func echoAsyncNullable(
    _ anotherEnum: AnotherEnum?, completion: @escaping (Result<AnotherEnum?, Error>) -> Void
  ) {
    completion(.success(anotherEnum))
  }

  func defaultIsMainThread() -> Bool {
    return Thread.isMainThread
  }

  func taskQueueIsBackgroundThread() -> Bool {
    return !Thread.isMainThread
  }

  func callFlutterNoop(completion: @escaping (Result<Void, Error>) -> Void) {
    flutterAPI.noop { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterThrowError(completion: @escaping (Result<Any?, Error>) -> Void) {
    flutterAPI.throwError { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterThrowErrorFromVoid(completion: @escaping (Result<Void, Error>) -> Void) {
    flutterAPI.throwErrorFromVoid { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(
    _ everything: AllTypes, completion: @escaping (Result<AllTypes, Error>) -> Void
  ) {
    flutterAPI.echo(everything) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(
    _ everything: AllNullableTypes?,
    completion: @escaping (Result<AllNullableTypes?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(everything) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(
    _ everything: AllNullableTypesWithoutRecursion?,
    completion: @escaping (Result<AllNullableTypesWithoutRecursion?, Error>) -> Void
  ) {
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

  func callFlutterSendMultipleNullableTypesWithoutRecursion(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?,
    completion: @escaping (Result<AllNullableTypesWithoutRecursion, Error>) -> Void
  ) {
    flutterAPI.sendMultipleNullableTypesWithoutRecursion(
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

  func callFlutterEcho(
    _ list: FlutterStandardTypedData,
    completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
  ) {
    flutterAPI.echo(list) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(_ list: [Any?], completion: @escaping (Result<[Any?], Error>) -> Void) {
    flutterAPI.echo(list) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(
    enumList: [AnEnum?], completion: @escaping (Result<[AnEnum?], Error>) -> Void
  ) {
    flutterAPI.echo(enumList: enumList) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(
    classList: [AllNullableTypes?],
    completion: @escaping (Result<[AllNullableTypes?], Error>) -> Void
  ) {
    flutterAPI.echo(classList: classList) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNonNull(
    enumList: [AnEnum], completion: @escaping (Result<[AnEnum], Error>) -> Void
  ) {
    flutterAPI.echoNonNull(enumList: enumList) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNonNull(
    classList: [AllNullableTypes], completion: @escaping (Result<[AllNullableTypes], Error>) -> Void
  ) {
    flutterAPI.echoNonNull(classList: classList) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(
    _ map: [AnyHashable?: Any?], completion: @escaping (Result<[AnyHashable?: Any?], Error>) -> Void
  ) {
    flutterAPI.echo(map) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(
    stringMap: [String?: String?], completion: @escaping (Result<[String?: String?], Error>) -> Void
  ) {
    flutterAPI.echo(stringMap: stringMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(
    intMap: [Int64?: Int64?], completion: @escaping (Result<[Int64?: Int64?], Error>) -> Void
  ) {
    flutterAPI.echo(intMap: intMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(
    enumMap: [AnEnum?: AnEnum?], completion: @escaping (Result<[AnEnum?: AnEnum?], Error>) -> Void
  ) {
    flutterAPI.echo(enumMap: enumMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(
    classMap: [Int64?: AllNullableTypes?],
    completion: @escaping (Result<[Int64?: AllNullableTypes?], Error>) -> Void
  ) {
    flutterAPI.echo(classMap: classMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNonNull(
    stringMap: [String: String], completion: @escaping (Result<[String: String], Error>) -> Void
  ) {
    flutterAPI.echoNonNull(stringMap: stringMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNonNull(
    intMap: [Int64: Int64], completion: @escaping (Result<[Int64: Int64], Error>) -> Void
  ) {
    flutterAPI.echoNonNull(intMap: intMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNonNull(
    enumMap: [AnEnum: AnEnum], completion: @escaping (Result<[AnEnum: AnEnum], Error>) -> Void
  ) {
    flutterAPI.echoNonNull(enumMap: enumMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNonNull(
    classMap: [Int64: AllNullableTypes],
    completion: @escaping (Result<[Int64: AllNullableTypes], Error>) -> Void
  ) {
    flutterAPI.echoNonNull(classMap: classMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(
    _ anEnum: AnEnum, completion: @escaping (Result<AnEnum, Error>) -> Void
  ) {
    flutterAPI.echo(anEnum) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEcho(
    _ anotherEnum: AnotherEnum, completion: @escaping (Result<AnotherEnum, Error>) -> Void
  ) {
    flutterAPI.echo(anotherEnum) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(_ aBool: Bool?, completion: @escaping (Result<Bool?, Error>) -> Void)
  {
    flutterAPI.echoNullable(aBool) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(
    _ anInt: Int64?, completion: @escaping (Result<Int64?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(anInt) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(
    _ aDouble: Double?, completion: @escaping (Result<Double?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(aDouble) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(
    _ aString: String?, completion: @escaping (Result<String?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(aString) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(
    _ list: FlutterStandardTypedData?,
    completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(list) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(
    _ list: [Any?]?, completion: @escaping (Result<[Any?]?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(list) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(
    enumList: [AnEnum?]?, completion: @escaping (Result<[AnEnum?]?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(enumList: enumList) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(
    classList: [AllNullableTypes?]?,
    completion: @escaping (Result<[AllNullableTypes?]?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(classList: classList) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullableNonNull(
    enumList: [AnEnum]?, completion: @escaping (Result<[AnEnum]?, Error>) -> Void
  ) {
    flutterAPI.echoNullableNonNull(enumList: enumList) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullableNonNull(
    classList: [AllNullableTypes]?,
    completion: @escaping (Result<[AllNullableTypes]?, Error>) -> Void
  ) {
    flutterAPI.echoNullableNonNull(classList: classList) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(
    _ map: [AnyHashable?: Any?]?,
    completion: @escaping (Result<[AnyHashable?: Any?]?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(map) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(
    stringMap: [String?: String?]?,
    completion: @escaping (Result<[String?: String?]?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(stringMap: stringMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(
    intMap: [Int64?: Int64?]?, completion: @escaping (Result<[Int64?: Int64?]?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(intMap: intMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(
    enumMap: [AnEnum?: AnEnum?]?, completion: @escaping (Result<[AnEnum?: AnEnum?]?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(enumMap: enumMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(
    classMap: [Int64?: AllNullableTypes?]?,
    completion: @escaping (Result<[Int64?: AllNullableTypes?]?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(classMap: classMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullableNonNull(
    stringMap: [String: String]?, completion: @escaping (Result<[String: String]?, Error>) -> Void
  ) {
    flutterAPI.echoNullableNonNull(stringMap: stringMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullableNonNull(
    intMap: [Int64: Int64]?, completion: @escaping (Result<[Int64: Int64]?, Error>) -> Void
  ) {
    flutterAPI.echoNullableNonNull(intMap: intMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullableNonNull(
    enumMap: [AnEnum: AnEnum]?, completion: @escaping (Result<[AnEnum: AnEnum]?, Error>) -> Void
  ) {
    flutterAPI.echoNullableNonNull(enumMap: enumMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullableNonNull(
    classMap: [Int64: AllNullableTypes]?,
    completion: @escaping (Result<[Int64: AllNullableTypes]?, Error>) -> Void
  ) {
    flutterAPI.echoNullableNonNull(classMap: classMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(
    _ anEnum: AnEnum?, completion: @escaping (Result<AnEnum?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(anEnum) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullable(
    _ anotherEnum: AnotherEnum?, completion: @escaping (Result<AnotherEnum?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(anotherEnum) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterSmallApiEcho(
    _ aString: String, completion: @escaping (Result<String, Error>) -> Void
  ) {
    flutterSmallApiOne.echo(string: aString) { responseOne in
      self.flutterSmallApiTwo.echo(string: aString) { responseTwo in
        switch responseOne {
        case .success(let resOne):
          switch responseTwo {
          case .success(let resTwo):
            if resOne == resTwo {
              completion(.success(resOne))
            } else {
              completion(
                .failure(
                  PigeonError(
                    code: "",
                    message: "Multi-instance responses were not matching: \(resOne), \(resTwo)",
                    details: nil)))
            }
          case .failure(let error):
            completion(.failure(error))
          }
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
  }

  func noopAsync(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.success(Void()))
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

  func throwAsyncError(completion: @escaping (Result<Any?, Error>) -> Void) {
    completion(.failure(PigeonError(code: "code", message: "message", details: "details")))
  }

  func throwAsyncErrorFromVoid(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(PigeonError(code: "code", message: "message", details: "details")))
  }

  func throwAsyncFlutterError(completion: @escaping (Result<Any?, Error>) -> Void) {
    completion(.failure(PigeonError(code: "code", message: "message", details: "details")))
  }

  func echoOptional(_ aNullableInt: Int64?) throws -> Int64? {
    return aNullableInt
  }

  func echoNamed(_ aNullableString: String?) throws -> String? {
    return aNullableString
  }

  func testUnusedClassesGenerate() -> UnusedClass {
    return UnusedClass()
  }
}

class NITestsClass: NSObject, NIHostIntegrationCoreApi {
  func noop() throws {
    return
  }

  func echo(_ everything: NIAllTypes) throws -> NIAllTypes {
    return everything
  }

  func throwError() throws -> Any? {
    throw NiTestsError(code: "code", message: "message", details: "details")
  }

  func throwErrorFromVoid() throws {
    throw NiTestsError(code: "code", message: "message", details: "details")
  }

  func throwFlutterError() throws -> Any? {
    throw NiTestsError(code: "code", message: "message", details: "details")
  }

  func echo(_ anInt: Int64) throws -> Int64 {
    return anInt
  }

  func echo(_ aDouble: Double) throws -> Double {
    return aDouble
  }

  func echo(_ aBool: Bool) throws -> Bool {
    return aBool
  }

  func echo(_ aString: String) throws -> String {
    return aString
  }

  func echo(_ aUint8List: [UInt8]) throws -> [UInt8] {
    return aUint8List
  }

  func echo(_ aInt32List: [Int32]) throws -> [Int32] {
    return aInt32List
  }

  func echo(_ aInt64List: [Int64]) throws -> [Int64] {
    return aInt64List
  }

  func echo(_ aFloat64List: [Float64]) throws -> [Float64] {
    return aFloat64List
  }

  func echo(_ anObject: Any) throws -> Any {
    return anObject
  }

  func echo(_ list: [Any?]) throws -> [Any?] {
    return list
  }

  func echo(_ map: [AnyHashable?: Any?]) throws -> [AnyHashable?: Any?] {
    return map
  }

  func echo(stringMap: [String?: String?]) throws -> [String?: String?] {
    return stringMap
  }

  func echo(intMap: [Int64?: Int64?]) throws -> [Int64?: Int64?] {
    return intMap
  }

  func echo(enumMap: [NIAnEnum?: NIAnEnum?]) throws -> [NIAnEnum?: NIAnEnum?] {
    return enumMap
  }

  func echo(classMap: [Int64?: NIAllNullableTypes?]) throws -> [Int64?: NIAllNullableTypes?] {
    return classMap
  }

  func echo(_ anEnum: NIAnEnum) throws -> NIAnEnum {
    return anEnum
  }

  func echo(_ anotherEnum: NIAnotherEnum) throws -> NIAnotherEnum {
    return anotherEnum
  }

  func echoNamedDefault(_ aString: String) throws -> String {
    return aString
  }

  func echoOptionalDefault(_ aDouble: Double) throws -> Double {
    return aDouble
  }

  func echoRequired(_ anInt: Int64) throws -> Int64 {
    return anInt
  }

  func echoOptional(_ aNullableInt: Int64?) throws -> Int64? {
    return aNullableInt
  }

  func echoNamed(_ aNullableString: String?) throws -> String? {
    return aNullableString
  }

  func echoNonNull(enumList: [NIAnEnum]) throws -> [NIAnEnum] {
    return enumList
  }

  func echoNonNull(classList: [NIAllNullableTypes]) throws -> [NIAllNullableTypes] {
    return classList
  }

  func echoNonNull(stringMap: [String: String]) throws -> [String: String] {
    return stringMap
  }

  func echoNonNull(intMap: [Int64: Int64]) throws -> [Int64: Int64] {
    return intMap
  }

  func echoNonNull(enumMap: [NIAnEnum: NIAnEnum]) throws -> [NIAnEnum: NIAnEnum] {
    return enumMap
  }

  func echoNonNull(classMap: [Int64: NIAllNullableTypes]) throws -> [Int64: NIAllNullableTypes] {
    return classMap
  }

  func echoNullable(_ everything: NIAllNullableTypes?) throws -> NIAllNullableTypes? {
    return everything
  }

  func echoNullable(_ aNullableUint8List: [UInt8]?) throws -> [UInt8]? {
    return aNullableUint8List
  }

  func echoNullable(_ aNullableInt32List: [Int32]?) throws -> [Int32]? {
    return aNullableInt32List
  }

  func echoNullable(_ aNullableInt64List: [Int64]?) throws -> [Int64]? {
    return aNullableInt64List
  }

  func echoNullable(_ aNullableFloat64List: [Float64]?) throws -> [Float64]? {
    return aNullableFloat64List
  }

  func echoNullable(_ aNullableObject: Any?) throws -> Any? {
    return aNullableObject
  }

  func echoNullable(_ aNullableList: [Any?]?) throws -> [Any?]? {
    return aNullableList
  }

  func echoNullable(enumList: [NIAnEnum?]?) throws -> [NIAnEnum?]? {
    return enumList
  }

  func echoNullable(classList: [NIAllNullableTypes?]?) throws -> [NIAllNullableTypes?]? {
    return classList
  }

  func echoNullable(stringMap: [String?: String?]?) throws -> [String?: String?]? {
    return stringMap
  }

  func echoNullable(intMap: [Int64?: Int64?]?) throws -> [Int64?: Int64?]? {
    return intMap
  }

  func echoNullable(enumMap: [NIAnEnum?: NIAnEnum?]?) throws -> [NIAnEnum?: NIAnEnum?]? {
    return enumMap
  }

  func echoNullable(classMap: [Int64?: NIAllNullableTypes?]?) throws -> [Int64?:
    NIAllNullableTypes?]?
  {
    return classMap
  }

  func echoNullable(_ anEnum: NIAnEnum?) throws -> NIAnEnum? {
    return anEnum
  }

  func echoNullable(_ anotherEnum: NIAnotherEnum?) throws -> NIAnotherEnum? {
    return anotherEnum
  }

  func echoNullableNonNull(enumList: [NIAnEnum]?) throws -> [NIAnEnum]? {
    return enumList
  }

  func echoNullableNonNull(classList: [NIAllNullableTypes]?) throws -> [NIAllNullableTypes]? {
    return classList
  }

  func echoNullable(_ map: [AnyHashable?: Any?]?) throws -> [AnyHashable?: Any?]? {
    return map
  }

  func echoNullableNonNull(stringMap: [String: String]?) throws -> [String: String]? {
    return stringMap
  }

  func echoNullableNonNull(intMap: [Int64: Int64]?) throws -> [Int64: Int64]? {
    return intMap
  }

  func echoNullableNonNull(enumMap: [NIAnEnum: NIAnEnum]?) throws -> [NIAnEnum: NIAnEnum]? {
    return enumMap
  }

  func echoNullableNonNull(classMap: [Int64: NIAllNullableTypes]?) throws -> [Int64:
    NIAllNullableTypes]?
  {
    return classMap
  }

  func extractNestedNullableString(from wrapper: NIAllClassesWrapper) throws -> String? {
    return wrapper.allNullableTypes.aNullableString
  }

  func createNestedObject(with nullableString: String?) throws -> NIAllClassesWrapper {
    return NIAllClassesWrapper(
      allNullableTypes: .init(aNullableString: nullableString), classList: [],
      classMap: [:])
  }

  func sendMultipleNullableTypes(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?
  ) throws -> NIAllNullableTypes {
    return NIAllNullableTypes(
      aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
  }

  func sendMultipleNullableTypesWithoutRecursion(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?
  ) throws -> NIAllNullableTypesWithoutRecursion {
    return NIAllNullableTypesWithoutRecursion(
      aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
  }

  func echoAsync(_ aUint8List: [UInt8]) async throws -> [UInt8] {
    return aUint8List
  }

  func echoAsync(_ aInt32List: [Int32]) async throws -> [Int32] {
    return aInt32List
  }

  func echoAsync(_ aInt64List: [Int64]) async throws -> [Int64] {
    return aInt64List
  }

  func echoAsync(_ aFloat64List: [Float64]) async throws -> [Float64] {
    return aFloat64List
  }

  func echoAsync(_ anObject: Any) async throws -> Any {
    return anObject
  }

  func echoAsync(_ list: [Any?]) async throws -> [Any?] {
    return list
  }

  func echoAsync(enumList: [NIAnEnum?]) async throws -> [NIAnEnum?] {
    return enumList
  }

  func echoAsync(classList: [NIAllNullableTypes?]) async throws -> [NIAllNullableTypes?] {
    return classList
  }

  func echoAsync(_ map: [AnyHashable?: Any?]) async throws -> [AnyHashable?: Any?] {
    return map
  }

  func echoAsync(stringMap: [String?: String?]) async throws -> [String?: String?] {
    return stringMap
  }

  func echoAsync(intMap: [Int64?: Int64?]) async throws -> [Int64?: Int64?] {
    return intMap
  }

  func echoAsync(enumMap: [NIAnEnum?: NIAnEnum?]) async throws -> [NIAnEnum?: NIAnEnum?] {
    return enumMap
  }

  func echoAsync(classMap: [Int64?: NIAllNullableTypes?]) async throws -> [Int64?:
    NIAllNullableTypes?]
  {
    return classMap
  }

  func echoAsync(_ anEnum: NIAnEnum) async throws -> NIAnEnum {
    return anEnum
  }

  func echoAsync(_ anotherEnum: NIAnotherEnum) async throws -> NIAnotherEnum {
    return anotherEnum
  }

  func throwAsyncError() async throws -> Any? {
    throw NiTestsError(code: "code", message: "message", details: "details")
  }

  func throwAsyncErrorFromVoid() async throws {
    throw NiTestsError(code: "code", message: "message", details: "details")
  }

  func throwAsyncFlutterError() async throws -> Any? {
    throw NiTestsError(code: "code", message: "message", details: "details")
  }

  func echoAsync(_ everything: NIAllTypes) async throws -> NIAllTypes {
    return everything
  }

  func echoAsync(_ everything: NIAllNullableTypes?) async throws -> NIAllNullableTypes? {
    return everything
  }

  func echoAsync(_ everything: NIAllNullableTypesWithoutRecursion?) async throws
    -> NIAllNullableTypesWithoutRecursion?
  {
    return everything
  }

  func echoAsyncNullable(_ anInt: Int64?) async throws -> Int64? {
    return anInt
  }

  func echoAsyncNullable(_ aDouble: Double?) async throws -> Double? {
    return aDouble
  }

  func echoAsyncNullable(_ aBool: Bool?) async throws -> Bool? {
    return aBool
  }

  func echoAsyncNullable(_ aString: String?) async throws -> String? {
    return aString
  }

  func echoAsyncNullable(_ aUint8List: [UInt8]?) async throws -> [UInt8]? {
    return aUint8List
  }

  func echoAsyncNullable(_ aInt32List: [Int32]?) async throws -> [Int32]? {
    return aInt32List
  }

  func echoAsyncNullable(_ aInt64List: [Int64]?) async throws -> [Int64]? {
    return aInt64List
  }

  func echoAsyncNullable(_ aFloat64List: [Float64]?) async throws -> [Float64]? {
    return aFloat64List
  }

  func echoAsyncNullable(_ anObject: Any?) async throws -> Any? {
    return anObject
  }

  func echoAsyncNullable(_ list: [Any?]?) async throws -> [Any?]? {
    return list
  }

  func echoAsyncNullable(enumList: [NIAnEnum?]?) async throws -> [NIAnEnum?]? {
    return enumList
  }

  func echoAsyncNullable(classList: [NIAllNullableTypes?]?) async throws -> [NIAllNullableTypes?]? {
    return classList
  }

  func echoAsyncNullable(_ map: [AnyHashable?: Any?]?) async throws -> [AnyHashable?: Any?]? {
    return map
  }

  func echoAsyncNullable(stringMap: [String?: String?]?) async throws -> [String?: String?]? {
    return stringMap
  }

  func echoAsyncNullable(intMap: [Int64?: Int64?]?) async throws -> [Int64?: Int64?]? {
    return intMap
  }

  func echoAsyncNullable(enumMap: [NIAnEnum?: NIAnEnum?]?) async throws -> [NIAnEnum?: NIAnEnum?]? {
    return enumMap
  }

  func echoAsyncNullable(classMap: [Int64?: NIAllNullableTypes?]?) async throws -> [Int64?:
    NIAllNullableTypes?]?
  {
    return classMap
  }

  func echoAsyncNullable(_ anEnum: NIAnEnum?) async throws -> NIAnEnum? {
    return anEnum
  }

  func echoAsyncNullable(_ anotherEnum: NIAnotherEnum?) async throws -> NIAnotherEnum? {
    return anotherEnum
  }

  func callFlutterNoop() throws {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    try flutterApi.noop()
  }

  func callFlutterThrowError() throws -> Any? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.throwError()
  }

  func callFlutterThrowErrorFromVoid() throws {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    try flutterApi.throwErrorFromVoid()
  }

  func callFlutterEcho(_ everything: NIAllTypes) throws -> NIAllTypes {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNIAllTypes(everything: everything)
  }

  func callFlutterEcho(_ aBool: Bool) throws -> Bool {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoBool(aBool: aBool)
  }

  func callFlutterEcho(_ anInt: Int64) throws -> Int64 {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoInt(anInt: anInt)
  }

  func callFlutterEcho(_ aDouble: Double) throws -> Double {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoDouble(aDouble: aDouble)
  }

  func callFlutterEcho(_ aString: String) throws -> String {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoString(aString: aString)
  }

  func callFlutterEcho(_ list: [UInt8]) throws -> [UInt8] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoUint8List(list: list)
  }

  func callFlutterEcho(_ list: [Int32]) throws -> [Int32] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoInt32List(list: list)
  }

  func callFlutterEcho(_ list: [Int64]) throws -> [Int64] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoInt64List(list: list)
  }

  func callFlutterEcho(_ list: [Float64]) throws -> [Float64] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoFloat64List(list: list)
  }

  func callFlutterEcho(_ list: [Any?]) throws -> [Any?] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoList(list: list)
  }

  func callFlutterEcho(enumList: [NIAnEnum?]) throws -> [NIAnEnum?] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoEnumList(enumList: enumList)
  }

  func callFlutterEcho(classList: [NIAllNullableTypes?]) throws -> [NIAllNullableTypes?] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoClassList(classList: classList)
  }

  func callFlutterEchoNonNull(enumList: [NIAnEnum]) throws -> [NIAnEnum] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNonNullEnumList(enumList: enumList)
  }

  func callFlutterEchoNonNull(classList: [NIAllNullableTypes]) throws -> [NIAllNullableTypes] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNonNullClassList(classList: classList)
  }

  func callFlutterEcho(_ map: [AnyHashable?: Any?]) throws -> [AnyHashable?: Any?] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoMap(map: map)
  }

  func callFlutterEcho(stringMap: [String?: String?]) throws -> [String?: String?] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoStringMap(stringMap: stringMap)
  }

  func callFlutterEcho(intMap: [Int64?: Int64?]) throws -> [Int64?: Int64?] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoIntMap(intMap: intMap)
  }

  func callFlutterEcho(enumMap: [NIAnEnum?: NIAnEnum?]) throws -> [NIAnEnum?: NIAnEnum?] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoEnumMap(enumMap: enumMap)
  }

  func callFlutterEcho(classMap: [Int64?: NIAllNullableTypes?]) throws -> [Int64?:
    NIAllNullableTypes?]
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoClassMap(classMap: classMap)
  }

  func callFlutterEchoNonNull(stringMap: [String: String]) throws -> [String: String] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNonNullStringMap(stringMap: stringMap)
  }

  func callFlutterEchoNonNull(intMap: [Int64: Int64]) throws -> [Int64: Int64] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNonNullIntMap(intMap: intMap)
  }

  func callFlutterEchoNonNull(enumMap: [NIAnEnum: NIAnEnum]) throws -> [NIAnEnum: NIAnEnum] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNonNullEnumMap(enumMap: enumMap)
  }

  func callFlutterEchoNonNull(classMap: [Int64: NIAllNullableTypes]) throws -> [Int64:
    NIAllNullableTypes]
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNonNullClassMap(classMap: classMap)
  }

  func callFlutterEchoNullable(_ anEnum: NIAnEnum?) throws -> NIAnEnum? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableEnum(anEnum: anEnum)
  }

  func callFlutterEchoNullable(_ anotherEnum: NIAnotherEnum?) throws -> NIAnotherEnum? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoAnotherNullableEnum(anotherEnum: anotherEnum)
  }

  func callFlutterEchoNullable(_ aBool: Bool?) throws -> Bool? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableBool(aBool: aBool)
  }

  func callFlutterEchoNullable(_ anInt: Int64?) throws -> Int64? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableInt(anInt: anInt)
  }

  func callFlutterEchoNullable(_ aDouble: Double?) throws -> Double? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableDouble(aDouble: aDouble)
  }

  func callFlutterEchoNullable(_ aString: String?) throws -> String? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableString(aString: aString)
  }

  func callFlutterEchoNullable(_ list: [UInt8]?) throws -> [UInt8]? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableUint8List(list: list)
  }

  func callFlutterEchoNullable(_ list: [Int32]?) throws -> [Int32]? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableInt32List(list: list)
  }

  func callFlutterEchoNullable(_ list: [Int64]?) throws -> [Int64]? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableInt64List(list: list)
  }

  func callFlutterEchoNullable(_ list: [Float64]?) throws -> [Float64]? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableFloat64List(list: list)
  }

  func callFlutterEchoNullable(_ list: [Any?]?) throws -> [Any?]? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableList(list: list)
  }

  func callFlutterEchoNullable(enumList: [NIAnEnum?]?) throws -> [NIAnEnum?]? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableEnumList(enumList: enumList)
  }

  func callFlutterEchoNullable(classList: [NIAllNullableTypes?]?) throws
    -> [NIAllNullableTypes?]?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableClassList(classList: classList)
  }

  func callFlutterEchoNullableNonNull(enumList: [NIAnEnum]?) throws -> [NIAnEnum]? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableNonNullEnumList(enumList: enumList)
  }

  func callFlutterEchoNullableNonNull(classList: [NIAllNullableTypes]?) throws
    -> [NIAllNullableTypes]?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableNonNullClassList(classList: classList)
  }

  func callFlutterEchoNullable(_ map: [AnyHashable?: Any?]?) throws -> [AnyHashable?: Any?]? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableMap(map: map)
  }

  func callFlutterEchoNullable(stringMap: [String?: String?]?) throws -> [String?:
    String?]?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableStringMap(stringMap: stringMap)
  }

  func callFlutterEchoNullable(intMap: [Int64?: Int64?]?) throws -> [Int64?: Int64?]? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableIntMap(intMap: intMap)
  }

  func callFlutterEchoNullable(enumMap: [NIAnEnum?: NIAnEnum?]?) throws -> [NIAnEnum?:
    NIAnEnum?]?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableEnumMap(enumMap: enumMap)
  }

  func callFlutterEchoNullable(classMap: [Int64?: NIAllNullableTypes?]?) throws -> [Int64?:
    NIAllNullableTypes?]?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableClassMap(classMap: classMap)
  }

  func callFlutterEchoNullableNonNull(stringMap: [String: String]?) throws -> [String:
    String]?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableNonNullStringMap(stringMap: stringMap)
  }

  func callFlutterEchoNullableNonNull(intMap: [Int64: Int64]?) throws -> [Int64: Int64]? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableNonNullIntMap(intMap: intMap)
  }

  func callFlutterEchoNullableNonNull(enumMap: [NIAnEnum: NIAnEnum]?) throws -> [NIAnEnum:
    NIAnEnum]?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableNonNullEnumMap(enumMap: enumMap)
  }

  func callFlutterEchoNullableNonNull(classMap: [Int64: NIAllNullableTypes]?) throws
    -> [Int64: NIAllNullableTypes]?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNullableNonNullClassMap(classMap: classMap)
  }

  func callFlutterNoopAsync() async throws {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    try await flutterApi.noopAsync()
  }

  func callFlutterEchoAsyncNIAllTypes(everything: NIAllTypes) async throws -> NIAllTypes {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNIAllTypes(everything: everything)
  }

  func callFlutterEchoAsyncNullableNIAllNullableTypes(everything: NIAllNullableTypes?) async throws
    -> NIAllNullableTypes?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableNIAllNullableTypes(everything: everything)
  }

  func callFlutterEchoAsyncNullableNIAllNullableTypesWithoutRecursion(
    everything: NIAllNullableTypesWithoutRecursion?
  ) async throws -> NIAllNullableTypesWithoutRecursion? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableNIAllNullableTypesWithoutRecursion(
      everything: everything)
  }

  func callFlutterEchoAsyncBool(aBool: Bool) async throws -> Bool {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncBool(aBool: aBool)
  }

  func callFlutterEchoAsyncInt(anInt: Int64) async throws -> Int64 {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncInt(anInt: anInt)
  }

  func callFlutterEchoAsyncDouble(aDouble: Double) async throws -> Double {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncDouble(aDouble: aDouble)
  }

  func callFlutterEchoAsyncString(aString: String) async throws -> String {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncString(aString: aString)
  }

  func callFlutterEchoAsyncUint8List(list: [UInt8]) async throws -> [UInt8] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncUint8List(list: list)
  }

  func callFlutterEchoAsyncInt32List(list: [Int32]) async throws -> [Int32] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncInt32List(list: list)
  }

  func callFlutterEchoAsyncInt64List(list: [Int64]) async throws -> [Int64] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncInt64List(list: list)
  }

  func callFlutterEchoAsyncFloat64List(list: [Float64]) async throws -> [Float64] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncFloat64List(list: list)
  }

  func callFlutterEchoAsyncObject(anObject: Any) async throws -> Any {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncObject(anObject: anObject)
  }

  func callFlutterEchoAsyncList(list: [Any?]) async throws -> [Any?] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncList(list: list)
  }

  func callFlutterEchoAsyncEnumList(enumList: [NIAnEnum?]) async throws -> [NIAnEnum?] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncEnumList(enumList: enumList)
  }

  func callFlutterEchoAsyncClassList(classList: [NIAllNullableTypes?]) async throws
    -> [NIAllNullableTypes?]
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncClassList(classList: classList)
  }

  func callFlutterEchoAsyncNonNullEnumList(enumList: [NIAnEnum]) async throws -> [NIAnEnum] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNonNullEnumList(enumList: enumList)
  }

  func callFlutterEchoAsyncNonNullClassList(classList: [NIAllNullableTypes]) async throws
    -> [NIAllNullableTypes]
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNonNullClassList(classList: classList)
  }

  func callFlutterEchoAsyncMap(map: [AnyHashable?: Any?]) async throws -> [AnyHashable?: Any?] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncMap(map: map)
  }

  func callFlutterEchoAsyncStringMap(stringMap: [String?: String?]) async throws -> [String?:
    String?]
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncStringMap(stringMap: stringMap)
  }

  func callFlutterEchoAsyncIntMap(intMap: [Int64?: Int64?]) async throws -> [Int64?: Int64?] {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncIntMap(intMap: intMap)
  }

  func callFlutterEchoAsyncEnumMap(enumMap: [NIAnEnum?: NIAnEnum?]) async throws -> [NIAnEnum?:
    NIAnEnum?]
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncEnumMap(enumMap: enumMap)
  }

  func callFlutterThrowFlutterErrorAsync() async throws -> Any? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.throwFlutterErrorAsync()
  }

  func callFlutterEchoAsyncNullableFloat64List(list: [Float64]?) async throws -> [Float64]? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableFloat64List(list: list)
  }

  func callFlutterThrowFlutterError() throws -> Any? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.throwFlutterError()
  }

  func callFlutterEcho(_ everything: NIAllNullableTypes?) throws
    -> NIAllNullableTypes?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNIAllNullableTypes(everything: everything)
  }

  func callFlutterSendMultipleNullableTypes(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?
  ) throws -> NIAllNullableTypes {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.sendMultipleNullableTypes(
      aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
  }

  func callFlutterEcho(_ everything: NIAllNullableTypesWithoutRecursion?)
    throws -> NIAllNullableTypesWithoutRecursion?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNIAllNullableTypesWithoutRecursion(everything: everything)
  }

  func callFlutterSendMultipleNullableTypesWithoutRecursion(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?
  ) throws -> NIAllNullableTypesWithoutRecursion {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.sendMultipleNullableTypesWithoutRecursion(
      aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
  }

  func callFlutterEcho(_ anEnum: NIAnEnum) throws -> NIAnEnum {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoEnum(anEnum: anEnum)
  }

  func callFlutterEcho(_ anotherEnum: NIAnotherEnum) throws -> NIAnotherEnum {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try flutterApi.echoNIAnotherEnum(anotherEnum: anotherEnum)
  }

  func echoAsync(_ aDouble: Double) async throws -> Double {
    return aDouble
  }

  func echoAsync(_ aBool: Bool) async throws -> Bool {
    return aBool
  }

  func echoAsync(_ aString: String) async throws -> String {
    return aString
  }

  func noopAsync() async throws {
    return
  }

  func echoAsync(_ anInt: Int64) async throws -> Int64 {
    return anInt
  }

  func echo(enumList: [NIAnEnum?]) throws -> [NIAnEnum?] {
    return enumList
  }

  func echo(classList: [NIAllNullableTypes?]) throws
    -> [NIAllNullableTypes?]
  {
    return classList
  }

  func echo(stringList: [String?]) throws -> [String?] {
    return stringList
  }

  func echo(intList: [Int64?]) throws -> [Int64?] {
    return intList
  }

  func echo(doubleList: [Double?]) throws -> [Double?] {
    return doubleList
  }

  func echo(boolList: [Bool?]) throws -> [Bool?] {
    return boolList
  }

  func echo(_ wrapper: NIAllClassesWrapper) throws -> NIAllClassesWrapper {
    return wrapper
  }

  func echoNullable(_ everything: NIAllNullableTypesWithoutRecursion?) throws
    -> NIAllNullableTypesWithoutRecursion?
  {
    return everything
  }

  func echoNullable(_ aNullableInt: Int64?) throws -> Int64? {
    return aNullableInt
  }

  func echoNullable(_ aNullableDouble: Double?) throws -> Double? {
    return aNullableDouble
  }

  func echoNullable(_ aNullableBool: Bool?) throws -> Bool? {
    return aNullableBool
  }

  func echoNullable(_ aNullableString: String?) throws -> String? {
    return aNullableString
  }

  func callFlutterEchoAsyncNullableEnumMap(enumMap: [NIAnEnum?: NIAnEnum?]?) async throws
    -> [NIAnEnum?: NIAnEnum?]?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableEnumMap(enumMap: enumMap)
  }

  func callFlutterEchoAsyncNullableClassMap(classMap: [Int64?: NIAllNullableTypes?]?) async throws
    -> [Int64?: NIAllNullableTypes?]?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableClassMap(classMap: classMap)
  }

  func callFlutterEchoAsyncNullableEnum(anEnum: NIAnEnum?) async throws -> NIAnEnum? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableEnum(anEnum: anEnum)
  }

  func callFlutterEchoAnotherAsyncNullableEnum(anotherEnum: NIAnotherEnum?) async throws
    -> NIAnotherEnum?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAnotherAsyncNullableEnum(anotherEnum: anotherEnum)
  }

  func callFlutterEchoAsyncClassMap(classMap: [Int64?: NIAllNullableTypes?]) async throws
    -> [Int64?:
    NIAllNullableTypes?]
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncClassMap(classMap: classMap)
  }

  func callFlutterEchoAsyncEnum(anEnum: NIAnEnum) async throws -> NIAnEnum {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncEnum(anEnum: anEnum)
  }

  func callFlutterEchoAnotherAsyncEnum(anotherEnum: NIAnotherEnum) async throws -> NIAnotherEnum {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAnotherAsyncEnum(anotherEnum: anotherEnum)
  }

  func callFlutterEchoAsyncNullableBool(aBool: Bool?) async throws -> Bool? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableBool(aBool: aBool)
  }

  func callFlutterEchoAsyncNullableInt(anInt: Int64?) async throws -> Int64? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableInt(anInt: anInt)
  }

  func callFlutterEchoAsyncNullableDouble(aDouble: Double?) async throws -> Double? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableDouble(aDouble: aDouble)
  }

  func callFlutterEchoAsyncNullableString(aString: String?) async throws -> String? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableString(aString: aString)
  }

  func callFlutterEchoAsyncNullableUint8List(list: [UInt8]?) async throws -> [UInt8]? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableUint8List(list: list)
  }

  func callFlutterEchoAsyncNullableInt32List(list: [Int32]?) async throws -> [Int32]? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableInt32List(list: list)
  }

  func callFlutterEchoAsyncNullableInt64List(list: [Int64]?) async throws -> [Int64]? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableInt64List(list: list)
  }

  func callFlutterEchoAsyncNullableObject(anObject: Any?) async throws -> Any? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableObject(anObject: anObject)
  }

  func callFlutterEchoAsyncNullableList(list: [Any?]?) async throws -> [Any?]? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableList(list: list)
  }

  func callFlutterEchoAsyncNullableEnumList(enumList: [NIAnEnum?]?) async throws -> [NIAnEnum?]? {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableEnumList(enumList: enumList)
  }

  func callFlutterEchoAsyncNullableClassList(classList: [NIAllNullableTypes?]?) async throws
    -> [NIAllNullableTypes?]?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableClassList(classList: classList)
  }

  func callFlutterEchoAsyncNullableNonNullEnumList(enumList: [NIAnEnum]?) async throws
    -> [NIAnEnum]?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableNonNullEnumList(enumList: enumList)
  }

  func callFlutterEchoAsyncNullableNonNullClassList(classList: [NIAllNullableTypes]?) async throws
    -> [NIAllNullableTypes]?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableNonNullClassList(classList: classList)
  }

  func callFlutterEchoAsyncNullableMap(map: [AnyHashable?: Any?]?) async throws -> [AnyHashable?:
    Any?]?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableMap(map: map)
  }

  func callFlutterEchoAsyncNullableStringMap(stringMap: [String?: String?]?) async throws
    -> [String?:
    String?]?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableStringMap(stringMap: stringMap)
  }

  func callFlutterEchoAsyncNullableIntMap(intMap: [Int64?: Int64?]?) async throws -> [Int64?:
    Int64?]?
  {
    guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
      throw NiTestsError(
        code: "not_registered", message: "NIFlutterIntegrationCoreApi not registered", details: nil)
    }
    return try await flutterApi.echoAsyncNullableIntMap(intMap: intMap)
  }

  func defaultIsMainThread() throws -> Bool {
    return Thread.isMainThread
  }

  func callFlutterNoopOnBackgroundThread() async throws -> Bool {
    return await withCheckedContinuation { continuation in
      DispatchQueue.global(qos: .background).async {
        Task {
          do {
            guard let flutterApi = NIFlutterIntegrationCoreApi.getInstance() else {
              continuation.resume(returning: false)
              return
            }
            try await flutterApi.noopAsync()
            continuation.resume(returning: true)
          } catch {
            continuation.resume(returning: false)
          }
        }
      }
    }
  }
}

public class TestPluginWithSuffix: HostSmallApi {
  public static func register(with registrar: FlutterPluginRegistrar, suffix: String) {
    // Workaround for https://github.com/flutter/flutter/issues/118103.
    #if os(iOS)
      let messenger = registrar.messenger()
    #else
      let messenger = registrar.messenger
    #endif
    let plugin = TestPluginWithSuffix()
    HostSmallApiSetup.setUp(
      binaryMessenger: messenger, api: plugin, messageChannelSuffix: suffix)
  }

  func echo(aString: String, completion: @escaping (Result<String, Error>) -> Void) {
    completion(.success(aString))
  }

  func voidVoid(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.success(Void()))
  }

}

class SendInts: StreamIntsStreamHandler {
  var timerActive = false
  var timer: Timer?

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<Int64>) {
    var count: Int64 = 0
    if !timerActive {
      timerActive = true
      timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
        DispatchQueue.main.async {
          sink.success(count)
          count += 1
          if count >= 5 {
            sink.endOfStream()
            self.timer?.invalidate()
          }
        }
      }
    }
  }
}

class SendEvents: StreamEventsStreamHandler {
  var timerActive = false
  var timer: Timer?
  var eventList: [PlatformEvent] =
    [
      IntEvent(value: 1),
      StringEvent(value: "string"),
      BoolEvent(value: false),
      DoubleEvent(value: 3.14),
      ObjectsEvent(value: true),
      EnumEvent(value: EventEnum.fortyTwo),
      ClassEvent(value: EventAllNullableTypes(aNullableInt: 0)),
    ]

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<PlatformEvent>) {
    var count = 0
    if !timerActive {
      timerActive = true
      timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
        DispatchQueue.main.async {
          if count >= self.eventList.count {
            sink.endOfStream()
            self.timer?.invalidate()
          } else {
            sink.success(self.eventList[count])
            count += 1
          }
        }
      }
    }
  }
}

class SendConsistentNumbers: StreamConsistentNumbersStreamHandler {
  let numberToSend: Int64
  init(numberToSend: Int64) {
    self.numberToSend = numberToSend
  }
  var timerActive = false
  var timer: Timer?

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<Int64>) {
    let numberThatWillBeSent: Int64 = numberToSend
    var count: Int64 = 0
    if !timerActive {
      timerActive = true
      timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
        DispatchQueue.main.async {
          sink.success(numberThatWillBeSent)
          count += 1
          if count >= 10 {
            sink.endOfStream()
            self.timer?.invalidate()
          }
        }
      }
    }
  }
}
