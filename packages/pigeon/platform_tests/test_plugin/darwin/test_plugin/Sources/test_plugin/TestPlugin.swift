// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

/// Helper to adapt callback-based Flutter API calls into Swift async/await,
/// allowing integration tests and host handlers to `await` Flutter API calls.
private func awaitFlutterApi<T>(
  _ block: @escaping (@escaping (Result<T, PigeonError>) -> Void) -> Void
) async throws -> T {
  try await withCheckedThrowingContinuation { continuation in
    block { result in
      switch result {
      case .success(let value):
        continuation.resume(returning: value)
      case .failure(let error):
        continuation.resume(throwing: error)
      }
    }
  }
}

/// This plugin handles the native side of the integration tests in
/// example/integration_test/.
public class TestPlugin: NSObject, FlutterPlugin, HostIntegrationCoreApi, HostCallbackCoreApi {
  var flutterAPI: FlutterIntegrationCoreApi
  var flutterCallbackAPI: FlutterCallbackCoreApi
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
    HostCallbackCoreApiSetup.setUp(binaryMessenger: messenger, api: plugin)
    TestPluginWithSuffix.register(with: registrar, suffix: "suffixOne")
    TestPluginWithSuffix.register(with: registrar, suffix: "suffixTwo")
    registrar.publish(plugin)
  }

  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterAPI = FlutterIntegrationCoreApi(binaryMessenger: binaryMessenger)
    flutterCallbackAPI = FlutterCallbackCoreApi(binaryMessenger: binaryMessenger)
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
    NativeInteropHostIntegrationCoreApiSetup.register(api: NativeInteropTestsClass())
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    proxyApiRegistrar!.tearDown()
    proxyApiRegistrar = nil
  }

  // MARK: HostCallbackCoreApi implementation

  func noop(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.success(()))
  }

  func echo(_ aString: String, completion: @escaping (Result<String, Error>) -> Void) {
    completion(.success(aString))
  }

  func echo(_ everything: AllTypes, completion: @escaping (Result<AllTypes, Error>) -> Void) {
    completion(.success(everything))
  }

  func echoNullable(_ aString: String?, completion: @escaping (Result<String?, Error>) -> Void) {
    completion(.success(aString))
  }

  func throwError(completion: @escaping (Result<Any?, Error>) -> Void) {
    completion(.failure(PigeonError(code: "code", message: "message", details: "details")))
  }

  func throwErrorFromVoid(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(PigeonError(code: "code", message: "message", details: "details")))
  }

  func taskQueueIsBackgroundThread(completion: @escaping (Result<Bool, Error>) -> Void) {
    completion(.success(!Thread.isMainThread))
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

  func echoOptional(_ aNullableInt: Int64?) throws -> Int64? {
    return aNullableInt
  }

  func echoNamed(_ aNullableString: String?) throws -> String? {
    return aNullableString
  }

  func noopAsync() async throws {}

  func throwAsyncError() async throws -> Any? {
    throw PigeonError(code: "code", message: "message", details: "details")
  }

  func throwAsyncErrorFromVoid() async throws {
    throw PigeonError(code: "code", message: "message", details: "details")
  }

  func throwAsyncFlutterError() async throws -> Any? {
    throw PigeonError(code: "code", message: "message", details: "details")
  }

  func echoAsync(_ everything: AllTypes) async throws -> AllTypes {
    return everything
  }

  func echoAsync(_ everything: AllNullableTypes?) async throws -> AllNullableTypes? {
    return everything
  }

  func echoAsync(_ everything: AllNullableTypesWithoutRecursion?) async throws
    -> AllNullableTypesWithoutRecursion?
  {
    return everything
  }

  func echoAsync(_ anInt: Int64) async throws -> Int64 {
    return anInt
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

  func echoAsync(_ aUint8List: FlutterStandardTypedData) async throws -> FlutterStandardTypedData {
    return aUint8List
  }

  func echoAsync(_ anObject: Any) async throws -> Any {
    return anObject
  }

  func echoAsync(_ list: [Any?]) async throws -> [Any?] {
    return list
  }

  func echoAsync(enumList: [AnEnum?]) async throws -> [AnEnum?] {
    return enumList
  }

  func echoAsync(classList: [AllNullableTypes?]) async throws -> [AllNullableTypes?] {
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

  func echoAsync(enumMap: [AnEnum?: AnEnum?]) async throws -> [AnEnum?: AnEnum?] {
    return enumMap
  }

  func echoAsync(classMap: [Int64?: AllNullableTypes?]) async throws -> [Int64?: AllNullableTypes?]
  {
    return classMap
  }

  func echoAsync(_ anEnum: AnEnum) async throws -> AnEnum {
    return anEnum
  }

  func echoAsync(_ anotherEnum: AnotherEnum) async throws -> AnotherEnum {
    return anotherEnum
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

  func echoAsyncNullable(_ aUint8List: FlutterStandardTypedData?) async throws
    -> FlutterStandardTypedData?
  {
    return aUint8List
  }

  func echoAsyncNullable(_ anObject: Any?) async throws -> Any? {
    return anObject
  }

  func echoAsyncNullable(_ list: [Any?]?) async throws -> [Any?]? {
    return list
  }

  func echoAsyncNullable(enumList: [AnEnum?]?) async throws -> [AnEnum?]? {
    return enumList
  }

  func echoAsyncNullable(classList: [AllNullableTypes?]?) async throws -> [AllNullableTypes?]? {
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

  func echoAsyncNullable(enumMap: [AnEnum?: AnEnum?]?) async throws -> [AnEnum?: AnEnum?]? {
    return enumMap
  }

  func echoAsyncNullable(classMap: [Int64?: AllNullableTypes?]?) async throws -> [Int64?:
    AllNullableTypes?]?
  {
    return classMap
  }

  func echoAsyncNullable(_ anEnum: AnEnum?) async throws -> AnEnum? {
    return anEnum
  }

  func echoAsyncNullable(_ anotherEnum: AnotherEnum?) async throws -> AnotherEnum? {
    return anotherEnum
  }

  func defaultIsMainThread() -> Bool {
    return Thread.isMainThread
  }

  func taskQueueIsBackgroundThread() -> Bool {
    return !Thread.isMainThread
  }

  func asyncTaskQueueIsBackgroundThread() async throws -> Bool {
    return !Thread.isMainThread
  }

  func callFlutterNoop() async throws {
    try await self.flutterAPI.noop()
  }

  func callFlutterThrowError() async throws -> Any? {
    return try await self.flutterAPI.throwError()
  }

  func callFlutterThrowErrorFromVoid() async throws {
    try await self.flutterAPI.throwErrorFromVoid()
  }

  func callFlutterEcho(_ everything: AllTypes) async throws -> AllTypes {
    return try await self.flutterAPI.echo(everything)
  }

  func callFlutterEcho(_ everything: AllNullableTypes?) async throws -> AllNullableTypes? {
    return try await self.flutterAPI.echoNullable(everything)
  }

  func callFlutterEcho(_ everything: AllNullableTypesWithoutRecursion?) async throws
    -> AllNullableTypesWithoutRecursion?
  {
    return try await self.flutterAPI.echoNullable(everything)
  }

  func callFlutterSendMultipleNullableTypes(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?
  ) async throws -> AllNullableTypes {
    return try await self.flutterAPI.sendMultipleNullableTypes(
      aBool: aNullableBool, anInt: aNullableInt, aString: aNullableString)
  }

  func callFlutterSendMultipleNullableTypesWithoutRecursion(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?
  ) async throws -> AllNullableTypesWithoutRecursion {
    return try await self.flutterAPI.sendMultipleNullableTypesWithoutRecursion(
      aBool: aNullableBool, anInt: aNullableInt, aString: aNullableString)
  }

  func callFlutterEcho(_ aBool: Bool) async throws -> Bool {
    return try await self.flutterAPI.echo(aBool)
  }

  func callFlutterEcho(_ anInt: Int64) async throws -> Int64 {
    return try await self.flutterAPI.echo(anInt)
  }

  func callFlutterEcho(_ aDouble: Double) async throws -> Double {
    return try await self.flutterAPI.echo(aDouble)
  }

  func callFlutterEcho(_ aString: String) async throws -> String {
    return try await self.flutterAPI.echo(aString)
  }

  func callFlutterEcho(_ list: FlutterStandardTypedData) async throws -> FlutterStandardTypedData {
    return try await self.flutterAPI.echo(list)
  }

  func callFlutterEcho(_ list: [Any?]) async throws -> [Any?] {
    return try await self.flutterAPI.echo(list)
  }

  func callFlutterEcho(enumList: [AnEnum?]) async throws -> [AnEnum?] {
    return try await self.flutterAPI.echo(enumList: enumList)
  }

  func callFlutterEcho(classList: [AllNullableTypes?]) async throws -> [AllNullableTypes?] {
    return try await self.flutterAPI.echo(classList: classList)
  }

  func callFlutterEchoNonNull(enumList: [AnEnum]) async throws -> [AnEnum] {
    return try await self.flutterAPI.echoNonNull(enumList: enumList)
  }

  func callFlutterEchoNonNull(classList: [AllNullableTypes]) async throws -> [AllNullableTypes] {
    return try await self.flutterAPI.echoNonNull(classList: classList)
  }

  func callFlutterEcho(_ map: [AnyHashable?: Any?]) async throws -> [AnyHashable?: Any?] {
    return try await self.flutterAPI.echo(map)
  }

  func callFlutterEcho(stringMap: [String?: String?]) async throws -> [String?: String?] {
    return try await self.flutterAPI.echo(stringMap: stringMap)
  }

  func callFlutterEcho(intMap: [Int64?: Int64?]) async throws -> [Int64?: Int64?] {
    return try await self.flutterAPI.echo(intMap: intMap)
  }

  func callFlutterEcho(enumMap: [AnEnum?: AnEnum?]) async throws -> [AnEnum?: AnEnum?] {
    return try await self.flutterAPI.echo(enumMap: enumMap)
  }

  func callFlutterEcho(classMap: [Int64?: AllNullableTypes?]) async throws -> [Int64?:
    AllNullableTypes?]
  {
    return try await self.flutterAPI.echo(classMap: classMap)
  }

  func callFlutterEchoNonNull(stringMap: [String: String]) async throws -> [String: String] {
    return try await self.flutterAPI.echoNonNull(stringMap: stringMap)
  }

  func callFlutterEchoNonNull(intMap: [Int64: Int64]) async throws -> [Int64: Int64] {
    return try await self.flutterAPI.echoNonNull(intMap: intMap)
  }

  func callFlutterEchoNonNull(enumMap: [AnEnum: AnEnum]) async throws -> [AnEnum: AnEnum] {
    return try await self.flutterAPI.echoNonNull(enumMap: enumMap)
  }

  func callFlutterEchoNonNull(classMap: [Int64: AllNullableTypes]) async throws -> [Int64:
    AllNullableTypes]
  {
    return try await self.flutterAPI.echoNonNull(classMap: classMap)
  }

  func callFlutterEcho(_ anEnum: AnEnum) async throws -> AnEnum {
    return try await self.flutterAPI.echo(anEnum)
  }

  func callFlutterEcho(_ anotherEnum: AnotherEnum) async throws -> AnotherEnum {
    return try await self.flutterAPI.echo(anotherEnum)
  }

  func callFlutterEchoNullable(_ aBool: Bool?) async throws -> Bool? {
    return try await self.flutterAPI.echoNullable(aBool)
  }

  func callFlutterEchoNullable(_ anInt: Int64?) async throws -> Int64? {
    return try await self.flutterAPI.echoNullable(anInt)
  }

  func callFlutterEchoNullable(_ aDouble: Double?) async throws -> Double? {
    return try await self.flutterAPI.echoNullable(aDouble)
  }

  func callFlutterEchoNullable(_ aString: String?) async throws -> String? {
    return try await self.flutterAPI.echoNullable(aString)
  }

  func callFlutterEchoNullable(_ list: FlutterStandardTypedData?) async throws
    -> FlutterStandardTypedData?
  {
    return try await self.flutterAPI.echoNullable(list)
  }

  func callFlutterEchoNullable(_ list: [Any?]?) async throws -> [Any?]? {
    return try await self.flutterAPI.echoNullable(list)
  }

  func callFlutterEchoNullable(enumList: [AnEnum?]?) async throws -> [AnEnum?]? {
    return try await self.flutterAPI.echoNullable(enumList: enumList)
  }

  func callFlutterEchoNullable(classList: [AllNullableTypes?]?) async throws -> [AllNullableTypes?]?
  {
    return try await self.flutterAPI.echoNullable(classList: classList)
  }

  func callFlutterEchoNullableNonNull(enumList: [AnEnum]?) async throws -> [AnEnum]? {
    return try await self.flutterAPI.echoNullableNonNull(enumList: enumList)
  }

  func callFlutterEchoNullableNonNull(classList: [AllNullableTypes]?) async throws
    -> [AllNullableTypes]?
  {
    return try await self.flutterAPI.echoNullableNonNull(classList: classList)
  }

  func callFlutterEchoNullable(_ map: [AnyHashable?: Any?]?) async throws -> [AnyHashable?: Any?]? {
    return try await self.flutterAPI.echoNullable(map)
  }

  func callFlutterEchoNullable(stringMap: [String?: String?]?) async throws -> [String?: String?]? {
    return try await self.flutterAPI.echoNullable(stringMap: stringMap)
  }

  func callFlutterEchoNullable(intMap: [Int64?: Int64?]?) async throws -> [Int64?: Int64?]? {
    return try await self.flutterAPI.echoNullable(intMap: intMap)
  }

  func callFlutterEchoNullable(enumMap: [AnEnum?: AnEnum?]?) async throws -> [AnEnum?: AnEnum?]? {
    return try await self.flutterAPI.echoNullable(enumMap: enumMap)
  }

  func callFlutterEchoNullable(classMap: [Int64?: AllNullableTypes?]?) async throws -> [Int64?:
    AllNullableTypes?]?
  {
    return try await self.flutterAPI.echoNullable(classMap: classMap)
  }

  func callFlutterEchoNullableNonNull(stringMap: [String: String]?) async throws -> [String:
    String]?
  {
    return try await self.flutterAPI.echoNullableNonNull(stringMap: stringMap)
  }

  func callFlutterEchoNullableNonNull(intMap: [Int64: Int64]?) async throws -> [Int64: Int64]? {
    return try await self.flutterAPI.echoNullableNonNull(intMap: intMap)
  }

  func callFlutterEchoNullableNonNull(enumMap: [AnEnum: AnEnum]?) async throws -> [AnEnum: AnEnum]?
  {
    return try await self.flutterAPI.echoNullableNonNull(enumMap: enumMap)
  }

  func callFlutterEchoNullableNonNull(classMap: [Int64: AllNullableTypes]?) async throws -> [Int64:
    AllNullableTypes]?
  {
    return try await self.flutterAPI.echoNullableNonNull(classMap: classMap)
  }

  func callFlutterEchoNullable(_ anEnum: AnEnum?) async throws -> AnEnum? {
    return try await self.flutterAPI.echoNullable(anEnum)
  }

  func callFlutterEchoNullable(_ anotherEnum: AnotherEnum?) async throws -> AnotherEnum? {
    return try await self.flutterAPI.echoNullable(anotherEnum)
  }

  func callFlutterSmallApiEcho(_ aString: String) async throws -> String {
    let resOne = try await self.flutterSmallApiOne.echo(string: aString)
    let resTwo = try await self.flutterSmallApiTwo.echo(string: aString)
    if resOne == resTwo {
      return resOne
    } else {
      throw PigeonError(
        code: "Multi-instance error",
        message: "Multi-instance responses were not matching: \(resOne), \(resTwo)", details: "")
    }
  }

  func callFlutterCallbackNoop() async throws {
    try await awaitFlutterApi { self.flutterCallbackAPI.noop(completion: $0) }
  }

  func callFlutterCallbackEcho(_ aString: String) async throws -> String {
    return try await awaitFlutterApi {
      self.flutterCallbackAPI.echo(string: aString, completion: $0)
    }
  }

  func callFlutterCallbackThrowError() async throws -> Any? {
    return try await awaitFlutterApi { self.flutterCallbackAPI.throwError(completion: $0) }
  }

  func callFlutterCallbackThrowErrorFromVoid() async throws {
    try await awaitFlutterApi { self.flutterCallbackAPI.throwErrorFromVoid(completion: $0) }
  }

  func testUnusedClassesGenerate() -> UnusedClass {
    return UnusedClass()
  }
}

class NativeInteropTestsClass: NSObject, NativeInteropHostIntegrationCoreApi {
  func noop() throws {
    return
  }

  func echo(_ everything: NativeInteropAllTypes) throws -> NativeInteropAllTypes {
    return everything
  }

  func throwError() throws -> Any? {
    throw NativeInteropTestsError(code: "code", message: "message", details: "details")
  }

  func throwErrorFromVoid() throws {
    throw NativeInteropTestsError(code: "code", message: "message", details: "details")
  }

  func throwFlutterError() throws -> Any? {
    throw NativeInteropTestsError(code: "code", message: "message", details: "details")
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

  func echo(enumMap: [NativeInteropAnEnum?: NativeInteropAnEnum?]) throws -> [NativeInteropAnEnum?:
    NativeInteropAnEnum?]
  {
    return enumMap
  }

  func echo(classMap: [Int64?: NativeInteropAllNullableTypes?]) throws -> [Int64?:
    NativeInteropAllNullableTypes?]
  {
    return classMap
  }

  func echo(_ anEnum: NativeInteropAnEnum) throws -> NativeInteropAnEnum {
    return anEnum
  }

  func echo(_ anotherEnum: NativeInteropAnotherEnum) throws -> NativeInteropAnotherEnum {
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

  func echoNonNull(enumList: [NativeInteropAnEnum]) throws -> [NativeInteropAnEnum] {
    return enumList
  }

  func echoNonNull(classList: [NativeInteropAllNullableTypes]) throws
    -> [NativeInteropAllNullableTypes]
  {
    return classList
  }

  func echoNonNull(stringMap: [String: String]) throws -> [String: String] {
    return stringMap
  }

  func echoNonNull(intMap: [Int64: Int64]) throws -> [Int64: Int64] {
    return intMap
  }

  func echoNonNull(enumMap: [NativeInteropAnEnum: NativeInteropAnEnum]) throws
    -> [NativeInteropAnEnum: NativeInteropAnEnum]
  {
    return enumMap
  }

  func echoNonNull(classMap: [Int64: NativeInteropAllNullableTypes]) throws -> [Int64:
    NativeInteropAllNullableTypes]
  {
    return classMap
  }

  func echoNullable(_ everything: NativeInteropAllNullableTypes?) throws
    -> NativeInteropAllNullableTypes?
  {
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

  func echoNullable(enumList: [NativeInteropAnEnum?]?) throws -> [NativeInteropAnEnum?]? {
    return enumList
  }

  func echoNullable(classList: [NativeInteropAllNullableTypes?]?) throws
    -> [NativeInteropAllNullableTypes?]?
  {
    return classList
  }

  func echoNullable(stringMap: [String?: String?]?) throws -> [String?: String?]? {
    return stringMap
  }

  func echoNullable(intMap: [Int64?: Int64?]?) throws -> [Int64?: Int64?]? {
    return intMap
  }

  func echoNullable(enumMap: [NativeInteropAnEnum?: NativeInteropAnEnum?]?) throws
    -> [NativeInteropAnEnum?: NativeInteropAnEnum?]?
  {
    return enumMap
  }

  func echoNullable(classMap: [Int64?: NativeInteropAllNullableTypes?]?) throws -> [Int64?:
    NativeInteropAllNullableTypes?]?
  {
    return classMap
  }

  func echoNullable(_ anEnum: NativeInteropAnEnum?) throws -> NativeInteropAnEnum? {
    return anEnum
  }

  func echoNullable(_ anotherEnum: NativeInteropAnotherEnum?) throws -> NativeInteropAnotherEnum? {
    return anotherEnum
  }

  func echoNullableNonNull(enumList: [NativeInteropAnEnum]?) throws -> [NativeInteropAnEnum]? {
    return enumList
  }

  func echoNullableNonNull(classList: [NativeInteropAllNullableTypes]?) throws
    -> [NativeInteropAllNullableTypes]?
  {
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

  func echoNullableNonNull(enumMap: [NativeInteropAnEnum: NativeInteropAnEnum]?) throws
    -> [NativeInteropAnEnum: NativeInteropAnEnum]?
  {
    return enumMap
  }

  func echoNullableNonNull(classMap: [Int64: NativeInteropAllNullableTypes]?) throws -> [Int64:
    NativeInteropAllNullableTypes]?
  {
    return classMap
  }

  func extractNestedNullableString(from wrapper: NativeInteropAllClassesWrapper) throws -> String? {
    return wrapper.allNullableTypes.aNullableString
  }

  func createNestedObject(with nullableString: String?) throws -> NativeInteropAllClassesWrapper {
    return NativeInteropAllClassesWrapper(
      allNullableTypes: .init(aNullableString: nullableString), classList: [],
      classMap: [:])
  }

  func sendMultipleNullableTypes(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?
  ) throws -> NativeInteropAllNullableTypes {
    return NativeInteropAllNullableTypes(
      aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
  }

  func sendMultipleNullableTypesWithoutRecursion(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?
  ) throws -> NativeInteropAllNullableTypesWithoutRecursion {
    return NativeInteropAllNullableTypesWithoutRecursion(
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

  func echoAsync(enumList: [NativeInteropAnEnum?]) async throws -> [NativeInteropAnEnum?] {
    return enumList
  }

  func echoAsync(classList: [NativeInteropAllNullableTypes?]) async throws
    -> [NativeInteropAllNullableTypes?]
  {
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

  func echoAsync(enumMap: [NativeInteropAnEnum?: NativeInteropAnEnum?]) async throws
    -> [NativeInteropAnEnum?: NativeInteropAnEnum?]
  {
    return enumMap
  }

  func echoAsync(classMap: [Int64?: NativeInteropAllNullableTypes?]) async throws -> [Int64?:
    NativeInteropAllNullableTypes?]
  {
    return classMap
  }

  func echoAsync(_ anEnum: NativeInteropAnEnum) async throws -> NativeInteropAnEnum {
    return anEnum
  }

  func echoAsync(_ anotherEnum: NativeInteropAnotherEnum) async throws -> NativeInteropAnotherEnum {
    return anotherEnum
  }

  func throwAsyncError() async throws -> Any? {
    throw NativeInteropTestsError(code: "code", message: "message", details: "details")
  }

  func throwAsyncErrorFromVoid() async throws {
    throw NativeInteropTestsError(code: "code", message: "message", details: "details")
  }

  func throwAsyncFlutterError() async throws -> Any? {
    throw NativeInteropTestsError(code: "code", message: "message", details: "details")
  }

  func echoAsync(_ everything: NativeInteropAllTypes) async throws -> NativeInteropAllTypes {
    return everything
  }

  func echoAsync(_ everything: NativeInteropAllNullableTypes?) async throws
    -> NativeInteropAllNullableTypes?
  {
    return everything
  }

  func echoAsync(_ everything: NativeInteropAllNullableTypesWithoutRecursion?) async throws
    -> NativeInteropAllNullableTypesWithoutRecursion?
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

  func echoAsyncNullable(enumList: [NativeInteropAnEnum?]?) async throws -> [NativeInteropAnEnum?]?
  {
    return enumList
  }

  func echoAsyncNullable(classList: [NativeInteropAllNullableTypes?]?) async throws
    -> [NativeInteropAllNullableTypes?]?
  {
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

  func echoAsyncNullable(enumMap: [NativeInteropAnEnum?: NativeInteropAnEnum?]?) async throws
    -> [NativeInteropAnEnum?: NativeInteropAnEnum?]?
  {
    return enumMap
  }

  func echoAsyncNullable(classMap: [Int64?: NativeInteropAllNullableTypes?]?) async throws
    -> [Int64?:
    NativeInteropAllNullableTypes?]?
  {
    return classMap
  }

  func echoAsyncNullable(_ anEnum: NativeInteropAnEnum?) async throws -> NativeInteropAnEnum? {
    return anEnum
  }

  func echoAsyncNullable(_ anotherEnum: NativeInteropAnotherEnum?) async throws
    -> NativeInteropAnotherEnum?
  {
    return anotherEnum
  }

  private func getNativeInteropFlutterApi() throws -> NativeInteropFlutterIntegrationCoreApi {
    guard let flutterApi = NativeInteropFlutterIntegrationCoreApi.getInstance() else {
      throw NativeInteropTestsError(
        code: "not_registered", message: "NativeInteropFlutterIntegrationCoreApi not registered",
        details: nil)
    }
    return flutterApi
  }

  func callFlutterNoop() throws {
    let flutterApi = try getNativeInteropFlutterApi()
    try flutterApi.noop()
  }

  func callFlutterThrowError() throws -> Any? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.throwError()
  }

  func callFlutterThrowErrorFromVoid() throws {
    let flutterApi = try getNativeInteropFlutterApi()
    try flutterApi.throwErrorFromVoid()
  }

  func callFlutterEcho(_ everything: NativeInteropAllTypes) throws -> NativeInteropAllTypes {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNativeInteropAllTypes(everything: everything)
  }

  func callFlutterEcho(_ aBool: Bool) throws -> Bool {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoBool(aBool: aBool)
  }

  func callFlutterEcho(_ anInt: Int64) throws -> Int64 {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoInt(anInt: anInt)
  }

  func callFlutterEcho(_ aDouble: Double) throws -> Double {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoDouble(aDouble: aDouble)
  }

  func callFlutterEcho(_ aString: String) throws -> String {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoString(aString: aString)
  }

  func callFlutterEcho(_ list: [UInt8]) throws -> [UInt8] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoUint8List(list: list)
  }

  func callFlutterEcho(_ list: [Int32]) throws -> [Int32] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoInt32List(list: list)
  }

  func callFlutterEcho(_ list: [Int64]) throws -> [Int64] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoInt64List(list: list)
  }

  func callFlutterEcho(_ list: [Float64]) throws -> [Float64] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoFloat64List(list: list)
  }

  func callFlutterEcho(_ list: [Any?]) throws -> [Any?] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoList(list: list)
  }

  func callFlutterEcho(enumList: [NativeInteropAnEnum?]) throws -> [NativeInteropAnEnum?] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoEnumList(enumList: enumList)
  }

  func callFlutterEcho(classList: [NativeInteropAllNullableTypes?]) throws
    -> [NativeInteropAllNullableTypes?]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoClassList(classList: classList)
  }

  func callFlutterEchoNonNull(enumList: [NativeInteropAnEnum]) throws -> [NativeInteropAnEnum] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNonNullEnumList(enumList: enumList)
  }

  func callFlutterEchoNonNull(classList: [NativeInteropAllNullableTypes]) throws
    -> [NativeInteropAllNullableTypes]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNonNullClassList(classList: classList)
  }

  func callFlutterEcho(_ map: [AnyHashable?: Any?]) throws -> [AnyHashable?: Any?] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoMap(map: map)
  }

  func callFlutterEcho(stringMap: [String?: String?]) throws -> [String?: String?] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoStringMap(stringMap: stringMap)
  }

  func callFlutterEcho(intMap: [Int64?: Int64?]) throws -> [Int64?: Int64?] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoIntMap(intMap: intMap)
  }

  func callFlutterEcho(enumMap: [NativeInteropAnEnum?: NativeInteropAnEnum?]) throws
    -> [NativeInteropAnEnum?: NativeInteropAnEnum?]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoEnumMap(enumMap: enumMap)
  }

  func callFlutterEcho(classMap: [Int64?: NativeInteropAllNullableTypes?]) throws -> [Int64?:
    NativeInteropAllNullableTypes?]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoClassMap(classMap: classMap)
  }

  func callFlutterEchoNonNull(stringMap: [String: String]) throws -> [String: String] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNonNullStringMap(stringMap: stringMap)
  }

  func callFlutterEchoNonNull(intMap: [Int64: Int64]) throws -> [Int64: Int64] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNonNullIntMap(intMap: intMap)
  }

  func callFlutterEchoNonNull(enumMap: [NativeInteropAnEnum: NativeInteropAnEnum]) throws
    -> [NativeInteropAnEnum: NativeInteropAnEnum]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNonNullEnumMap(enumMap: enumMap)
  }

  func callFlutterEchoNonNull(classMap: [Int64: NativeInteropAllNullableTypes]) throws -> [Int64:
    NativeInteropAllNullableTypes]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNonNullClassMap(classMap: classMap)
  }

  func callFlutterEchoNullable(_ anEnum: NativeInteropAnEnum?) throws -> NativeInteropAnEnum? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableEnum(anEnum: anEnum)
  }

  func callFlutterEchoNullable(_ anotherEnum: NativeInteropAnotherEnum?) throws
    -> NativeInteropAnotherEnum?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoAnotherNullableEnum(anotherEnum: anotherEnum)
  }

  func callFlutterEchoNullable(_ aBool: Bool?) throws -> Bool? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableBool(aBool: aBool)
  }

  func callFlutterEchoNullable(_ anInt: Int64?) throws -> Int64? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableInt(anInt: anInt)
  }

  func callFlutterEchoNullable(_ aDouble: Double?) throws -> Double? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableDouble(aDouble: aDouble)
  }

  func callFlutterEchoNullable(_ aString: String?) throws -> String? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableString(aString: aString)
  }

  func callFlutterEchoNullable(_ list: [UInt8]?) throws -> [UInt8]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableUint8List(list: list)
  }

  func callFlutterEchoNullable(_ list: [Int32]?) throws -> [Int32]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableInt32List(list: list)
  }

  func callFlutterEchoNullable(_ list: [Int64]?) throws -> [Int64]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableInt64List(list: list)
  }

  func callFlutterEchoNullable(_ list: [Float64]?) throws -> [Float64]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableFloat64List(list: list)
  }

  func callFlutterEchoNullable(_ list: [Any?]?) throws -> [Any?]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableList(list: list)
  }

  func callFlutterEchoNullable(enumList: [NativeInteropAnEnum?]?) throws -> [NativeInteropAnEnum?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableEnumList(enumList: enumList)
  }

  func callFlutterEchoNullable(classList: [NativeInteropAllNullableTypes?]?) throws
    -> [NativeInteropAllNullableTypes?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableClassList(classList: classList)
  }

  func callFlutterEchoNullableNonNull(enumList: [NativeInteropAnEnum]?) throws
    -> [NativeInteropAnEnum]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableNonNullEnumList(enumList: enumList)
  }

  func callFlutterEchoNullableNonNull(classList: [NativeInteropAllNullableTypes]?) throws
    -> [NativeInteropAllNullableTypes]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableNonNullClassList(classList: classList)
  }

  func callFlutterEchoNullable(_ map: [AnyHashable?: Any?]?) throws -> [AnyHashable?: Any?]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableMap(map: map)
  }

  func callFlutterEchoNullable(stringMap: [String?: String?]?) throws -> [String?:
    String?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableStringMap(stringMap: stringMap)
  }

  func callFlutterEchoNullable(intMap: [Int64?: Int64?]?) throws -> [Int64?: Int64?]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableIntMap(intMap: intMap)
  }

  func callFlutterEchoNullable(enumMap: [NativeInteropAnEnum?: NativeInteropAnEnum?]?) throws
    -> [NativeInteropAnEnum?:
    NativeInteropAnEnum?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableEnumMap(enumMap: enumMap)
  }

  func callFlutterEchoNullable(classMap: [Int64?: NativeInteropAllNullableTypes?]?) throws
    -> [Int64?:
    NativeInteropAllNullableTypes?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableClassMap(classMap: classMap)
  }

  func callFlutterEchoNullableNonNull(stringMap: [String: String]?) throws -> [String:
    String]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableNonNullStringMap(stringMap: stringMap)
  }

  func callFlutterEchoNullableNonNull(intMap: [Int64: Int64]?) throws -> [Int64: Int64]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableNonNullIntMap(intMap: intMap)
  }

  func callFlutterEchoNullableNonNull(enumMap: [NativeInteropAnEnum: NativeInteropAnEnum]?) throws
    -> [NativeInteropAnEnum:
    NativeInteropAnEnum]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableNonNullEnumMap(enumMap: enumMap)
  }

  func callFlutterEchoNullableNonNull(classMap: [Int64: NativeInteropAllNullableTypes]?) throws
    -> [Int64: NativeInteropAllNullableTypes]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableNonNullClassMap(classMap: classMap)
  }

  func callFlutterNoopAsync() async throws {
    let flutterApi = try getNativeInteropFlutterApi()
    try await flutterApi.noopAsync()
  }

  func callFlutterEchoAsyncNativeInteropAllTypes(everything: NativeInteropAllTypes) async throws
    -> NativeInteropAllTypes
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNativeInteropAllTypes(everything: everything)
  }

  func callFlutterEchoAsyncNullableNativeInteropAllNullableTypes(
    everything: NativeInteropAllNullableTypes?
  ) async throws
    -> NativeInteropAllNullableTypes?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableNativeInteropAllNullableTypes(
      everything: everything)
  }

  func callFlutterEchoAsyncNullableNativeInteropAllNullableTypesWithoutRecursion(
    everything: NativeInteropAllNullableTypesWithoutRecursion?
  ) async throws -> NativeInteropAllNullableTypesWithoutRecursion? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableNativeInteropAllNullableTypesWithoutRecursion(
      everything: everything)
  }

  func callFlutterEchoAsyncBool(aBool: Bool) async throws -> Bool {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncBool(aBool: aBool)
  }

  func callFlutterEchoAsyncInt(anInt: Int64) async throws -> Int64 {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncInt(anInt: anInt)
  }

  func callFlutterEchoAsyncDouble(aDouble: Double) async throws -> Double {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncDouble(aDouble: aDouble)
  }

  func callFlutterEchoAsyncString(aString: String) async throws -> String {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncString(aString: aString)
  }

  func callFlutterEchoAsyncUint8List(list: [UInt8]) async throws -> [UInt8] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncUint8List(list: list)
  }

  func callFlutterEchoAsyncInt32List(list: [Int32]) async throws -> [Int32] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncInt32List(list: list)
  }

  func callFlutterEchoAsyncInt64List(list: [Int64]) async throws -> [Int64] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncInt64List(list: list)
  }

  func callFlutterEchoAsyncFloat64List(list: [Float64]) async throws -> [Float64] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncFloat64List(list: list)
  }

  func callFlutterEchoAsyncObject(anObject: Any) async throws -> Any {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncObject(anObject: anObject)
  }

  func callFlutterEchoAsyncList(list: [Any?]) async throws -> [Any?] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncList(list: list)
  }

  func callFlutterEchoAsyncEnumList(enumList: [NativeInteropAnEnum?]) async throws
    -> [NativeInteropAnEnum?]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncEnumList(enumList: enumList)
  }

  func callFlutterEchoAsyncClassList(classList: [NativeInteropAllNullableTypes?]) async throws
    -> [NativeInteropAllNullableTypes?]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncClassList(classList: classList)
  }

  func callFlutterEchoAsyncNonNullEnumList(enumList: [NativeInteropAnEnum]) async throws
    -> [NativeInteropAnEnum]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNonNullEnumList(enumList: enumList)
  }

  func callFlutterEchoAsyncNonNullClassList(classList: [NativeInteropAllNullableTypes]) async throws
    -> [NativeInteropAllNullableTypes]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNonNullClassList(classList: classList)
  }

  func callFlutterEchoAsyncMap(map: [AnyHashable?: Any?]) async throws -> [AnyHashable?: Any?] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncMap(map: map)
  }

  func callFlutterEchoAsyncStringMap(stringMap: [String?: String?]) async throws -> [String?:
    String?]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncStringMap(stringMap: stringMap)
  }

  func callFlutterEchoAsyncIntMap(intMap: [Int64?: Int64?]) async throws -> [Int64?: Int64?] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncIntMap(intMap: intMap)
  }

  func callFlutterEchoAsyncEnumMap(enumMap: [NativeInteropAnEnum?: NativeInteropAnEnum?])
    async throws -> [NativeInteropAnEnum?:
    NativeInteropAnEnum?]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncEnumMap(enumMap: enumMap)
  }

  func callFlutterThrowFlutterErrorAsync() async throws -> Any? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.throwFlutterErrorAsync()
  }

  func callFlutterEchoAsyncNullableFloat64List(list: [Float64]?) async throws -> [Float64]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableFloat64List(list: list)
  }

  func callFlutterThrowFlutterError() throws -> Any? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.throwFlutterError()
  }

  func callFlutterEcho(_ everything: NativeInteropAllNullableTypes?) throws
    -> NativeInteropAllNullableTypes?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNativeInteropAllNullableTypes(everything: everything)
  }

  func callFlutterSendMultipleNullableTypes(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?
  ) throws -> NativeInteropAllNullableTypes {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.sendMultipleNullableTypes(
      aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
  }

  func callFlutterEcho(_ everything: NativeInteropAllNullableTypesWithoutRecursion?)
    throws -> NativeInteropAllNullableTypesWithoutRecursion?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNativeInteropAllNullableTypesWithoutRecursion(everything: everything)
  }

  func callFlutterSendMultipleNullableTypesWithoutRecursion(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?
  ) throws -> NativeInteropAllNullableTypesWithoutRecursion {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.sendMultipleNullableTypesWithoutRecursion(
      aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
  }

  func callFlutterEcho(_ anEnum: NativeInteropAnEnum) throws -> NativeInteropAnEnum {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoEnum(anEnum: anEnum)
  }

  func callFlutterEcho(_ anotherEnum: NativeInteropAnotherEnum) throws -> NativeInteropAnotherEnum {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNativeInteropAnotherEnum(anotherEnum: anotherEnum)
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

  func echo(enumList: [NativeInteropAnEnum?]) throws -> [NativeInteropAnEnum?] {
    return enumList
  }

  func echo(classList: [NativeInteropAllNullableTypes?]) throws
    -> [NativeInteropAllNullableTypes?]
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

  func echo(_ wrapper: NativeInteropAllClassesWrapper) throws -> NativeInteropAllClassesWrapper {
    return wrapper
  }

  func echoNullable(_ everything: NativeInteropAllNullableTypesWithoutRecursion?) throws
    -> NativeInteropAllNullableTypesWithoutRecursion?
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

  func callFlutterEchoAsyncNullableEnumMap(enumMap: [NativeInteropAnEnum?: NativeInteropAnEnum?]?)
    async throws
    -> [NativeInteropAnEnum?: NativeInteropAnEnum?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableEnumMap(enumMap: enumMap)
  }

  func callFlutterEchoAsyncNullableClassMap(classMap: [Int64?: NativeInteropAllNullableTypes?]?)
    async throws
    -> [Int64?: NativeInteropAllNullableTypes?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableClassMap(classMap: classMap)
  }

  func callFlutterEchoAsyncNullableEnum(anEnum: NativeInteropAnEnum?) async throws
    -> NativeInteropAnEnum?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableEnum(anEnum: anEnum)
  }

  func callFlutterEchoAnotherAsyncNullableEnum(anotherEnum: NativeInteropAnotherEnum?) async throws
    -> NativeInteropAnotherEnum?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAnotherAsyncNullableEnum(anotherEnum: anotherEnum)
  }

  func callFlutterEchoAsyncClassMap(classMap: [Int64?: NativeInteropAllNullableTypes?]) async throws
    -> [Int64?:
    NativeInteropAllNullableTypes?]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncClassMap(classMap: classMap)
  }

  func callFlutterEchoAsyncEnum(anEnum: NativeInteropAnEnum) async throws -> NativeInteropAnEnum {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncEnum(anEnum: anEnum)
  }

  func callFlutterEchoAnotherAsyncEnum(anotherEnum: NativeInteropAnotherEnum) async throws
    -> NativeInteropAnotherEnum
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAnotherAsyncEnum(anotherEnum: anotherEnum)
  }

  func callFlutterEchoAsyncNullableBool(aBool: Bool?) async throws -> Bool? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableBool(aBool: aBool)
  }

  func callFlutterEchoAsyncNullableInt(anInt: Int64?) async throws -> Int64? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableInt(anInt: anInt)
  }

  func callFlutterEchoAsyncNullableDouble(aDouble: Double?) async throws -> Double? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableDouble(aDouble: aDouble)
  }

  func callFlutterEchoAsyncNullableString(aString: String?) async throws -> String? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableString(aString: aString)
  }

  func callFlutterEchoAsyncNullableUint8List(list: [UInt8]?) async throws -> [UInt8]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableUint8List(list: list)
  }

  func callFlutterEchoAsyncNullableInt32List(list: [Int32]?) async throws -> [Int32]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableInt32List(list: list)
  }

  func callFlutterEchoAsyncNullableInt64List(list: [Int64]?) async throws -> [Int64]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableInt64List(list: list)
  }

  func callFlutterEchoAsyncNullableObject(anObject: Any?) async throws -> Any? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableObject(anObject: anObject)
  }

  func callFlutterEchoAsyncNullableList(list: [Any?]?) async throws -> [Any?]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableList(list: list)
  }

  func callFlutterEchoAsyncNullableEnumList(enumList: [NativeInteropAnEnum?]?) async throws
    -> [NativeInteropAnEnum?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableEnumList(enumList: enumList)
  }

  func callFlutterEchoAsyncNullableClassList(classList: [NativeInteropAllNullableTypes?]?)
    async throws
    -> [NativeInteropAllNullableTypes?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableClassList(classList: classList)
  }

  func callFlutterEchoAsyncNullableNonNullEnumList(enumList: [NativeInteropAnEnum]?) async throws
    -> [NativeInteropAnEnum]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableNonNullEnumList(enumList: enumList)
  }

  func callFlutterEchoAsyncNullableNonNullClassList(classList: [NativeInteropAllNullableTypes]?)
    async throws
    -> [NativeInteropAllNullableTypes]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableNonNullClassList(classList: classList)
  }

  func callFlutterEchoAsyncNullableMap(map: [AnyHashable?: Any?]?) async throws -> [AnyHashable?:
    Any?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableMap(map: map)
  }

  func callFlutterEchoAsyncNullableStringMap(stringMap: [String?: String?]?) async throws
    -> [String?:
    String?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableStringMap(stringMap: stringMap)
  }

  func callFlutterEchoAsyncNullableIntMap(intMap: [Int64?: Int64?]?) async throws -> [Int64?:
    Int64?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
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
            guard let flutterApi = NativeInteropFlutterIntegrationCoreApi.getInstance() else {
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

  func testDeregisterHostApi() throws -> Bool {
    let name = "testDeregisterHostInstance"
    NativeInteropHostIntegrationCoreApiSetup.register(api: NativeInteropTestsClass(), name: name)
    guard NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) != nil else {
      return false
    }
    NativeInteropHostIntegrationCoreApiSetup.register(api: nil, name: name)
    return NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) == nil
  }

  func testDeregisterFlutterApi() throws -> Bool {
    let name = "testDeregisterFlutterInstance"
    NativeInteropFlutterIntegrationCoreApiRegistrar.registerInstance(api: nil, name: name)
    return NativeInteropFlutterIntegrationCoreApiRegistrar.getInstance(name: name) == nil
  }

  func registerAndImmediatelyDeregisterHostApi(name: String) throws {
    NativeInteropHostIntegrationCoreApiSetup.register(api: NativeInteropTestsClass(), name: name)
    NativeInteropHostIntegrationCoreApiSetup.register(api: nil, name: name)
  }

  func testCallDeregisteredFlutterApi(name: String) throws -> Bool {
    NativeInteropFlutterIntegrationCoreApiRegistrar.registerInstance(api: nil, name: name)
    return NativeInteropFlutterIntegrationCoreApi.getInstance(name: name) == nil
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

  func echo(aString: String) async throws -> String {
    return aString
  }

  func voidVoid() async throws {}

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
      EmptyEvent(),
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
