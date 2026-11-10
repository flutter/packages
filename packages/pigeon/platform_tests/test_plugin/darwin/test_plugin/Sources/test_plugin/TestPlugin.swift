// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  import Flutter
  import UIKit
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
  var niHostApiImpl: NativeInteropTestsClass?
  var niReservedImpl: NativeInteropReservedNamesHostApiImpl?
  var niSealedImpl: NativeInteropSealedClassHostApiImpl?

  public static func register(with registrar: FlutterPluginRegistrar) {
    // Workaround for https://github.com/flutter/flutter/issues/118103.
    #if os(iOS)
      let messenger = registrar.messenger()
    #else
      let messenger = registrar.messenger
    #endif
    let plugin = TestPlugin(binaryMessenger: messenger, registrar: registrar)
    HostIntegrationCoreApiSetup.setUp(binaryMessenger: messenger, api: plugin)
    HostCallbackCoreApiSetup.setUp(binaryMessenger: messenger, api: plugin)
    TestPluginWithSuffix.register(with: registrar, suffix: "suffixOne")
    TestPluginWithSuffix.register(with: registrar, suffix: "suffixTwo")
    registrar.publish(plugin)
  }

  init(binaryMessenger: FlutterBinaryMessenger, registrar: FlutterPluginRegistrar) {
    flutterAPI = FlutterIntegrationCoreApi(binaryMessenger: binaryMessenger)
    flutterCallbackAPI = FlutterCallbackCoreApi(binaryMessenger: binaryMessenger)
    flutterSmallApiOne = FlutterSmallApi(
      binaryMessenger: binaryMessenger, messageChannelSuffix: "suffixOne")
    flutterSmallApiTwo = FlutterSmallApi(
      binaryMessenger: binaryMessenger, messageChannelSuffix: "suffixTwo")

    StreamIntsStreamHandler.register(with: binaryMessenger, streamHandler: SendInts())
    StreamEventsStreamHandler.register(with: binaryMessenger, streamHandler: SendEvents())
    // Store one handler to exercise the handler removal codepath, and discard
    // the other to test that the return value can be safely ignored.
    let streamHandlerOne = SendConsistentNumbers(numberToSend: 1)
    let channelOne = StreamConsistentNumbersStreamHandler.register(
      with: binaryMessenger,
      instanceName: "1",
      streamHandler: streamHandlerOne)
    streamHandlerOne.onCancelled = { channelOne.setStreamHandler(nil) }
    StreamConsistentNumbersStreamHandler.register(
      with: binaryMessenger,
      instanceName: "2",
      streamHandler: SendConsistentNumbers(numberToSend: 2))
    proxyApiRegistrar = ProxyApiTestsPigeonProxyApiRegistrar(
      binaryMessenger: binaryMessenger, apiDelegate: ProxyApiDelegate())
    proxyApiRegistrar!.setUp()
    let niImpl = NativeInteropTestsClass(registrar: registrar)
    niHostApiImpl = niImpl
    NativeInteropHostIntegrationCoreApiSetup.register(api: niImpl, registrar: registrar)
    let reservedImpl = NativeInteropReservedNamesHostApiImpl(registrar: registrar)
    niReservedImpl = reservedImpl
    NativeInteropReservedNamesHostApiSetup.register(api: reservedImpl, registrar: registrar)
    let sealedImpl = NativeInteropSealedClassHostApiImpl(registrar: registrar)
    niSealedImpl = sealedImpl
    NativeInteropSealedClassHostApiSetup.register(api: sealedImpl, registrar: registrar)
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    #if os(macOS)
      let messenger = registrar.messenger
      HostIntegrationCoreApiSetup.setUp(binaryMessenger: messenger, api: nil)
      HostCallbackCoreApiSetup.setUp(binaryMessenger: messenger, api: nil)
    #endif
    if let niHostApiImpl {
      NativeInteropHostIntegrationCoreApiSetup.unregister(api: niHostApiImpl, registrar: registrar)
      self.niHostApiImpl = nil
    }
    if let niReservedImpl {
      NativeInteropReservedNamesHostApiSetup.unregister(api: niReservedImpl, registrar: registrar)
      self.niReservedImpl = nil
    }
    if let niSealedImpl {
      NativeInteropSealedClassHostApiSetup.unregister(api: niSealedImpl, registrar: registrar)
      self.niSealedImpl = nil
    }
    proxyApiRegistrar?.tearDown()
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

  @MainActor
  func callFlutterIsAsyncFlutterApiOnRoot() async throws -> Bool {
    guard Thread.isMainThread else {
      return false
    }
    let result = try await self.flutterAPI.isAsyncFlutterApiOnRoot()
    guard Thread.isMainThread else {
      return false
    }
    return result
  }

  func testUnusedClassesGenerate() -> UnusedClass {
    return UnusedClass()
  }
}

class NativeInteropTestsClass: NSObject, NativeInteropHostIntegrationCoreApi {
  private static var nextLabelId = 1
  /// Unique to this instance; see `engineLabel()`.
  private let label: String = {
    defer { NativeInteropTestsClass.nextLabelId += 1 }
    return "instance-\(NativeInteropTestsClass.nextLabelId)"
  }()

  func engineLabel() throws -> String {
    return label
  }

  /// The registrar of the engine this instance serves; used to find that engine's Flutter APIs.
  weak var registrar: FlutterPluginRegistrar?
  /// Used for registrations made by test helpers when this instance has no engine.
  private lazy var detachedRegistrar = StubPluginRegistrar()

  init(registrar: FlutterPluginRegistrar? = nil) {
    self.registrar = registrar
    super.init()
  }

  private var effectiveRegistrar: FlutterPluginRegistrar {
    return registrar ?? detachedRegistrar
  }

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
    // Return boxed NSNumber instances to test NSNumber/CFBoolean/CFNumber bridging across FFI.
    if let boolValue = aNullableObject as? Bool {
      return NSNumber(value: boolValue)
    }
    if let doubleValue = aNullableObject as? Double {
      return NSNumber(value: doubleValue)
    }
    if let intValue = aNullableObject as? Int64 {
      return NSNumber(value: intValue)
    }
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

  func echoAsync(sealedClass: NativeInteropSealedClass) async throws -> NativeInteropSealedClass {
    return sealedClass
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
    guard let registrar,
      let flutterApi = NativeInteropFlutterIntegrationCoreApiRegistrar.getInstance(
        registrar: registrar)
    else {
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

  func callFlutterEcho(sealedClass: NativeInteropSealedClass) throws -> NativeInteropSealedClass {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNativeInteropSealedClass(sealedClass: sealedClass)
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

  func echo(sealedClass: NativeInteropSealedClass) throws -> NativeInteropSealedClass {
    return sealedClass
  }

  func echoNullable(sealedClass: NativeInteropSealedClass?) throws -> NativeInteropSealedClass? {
    return sealedClass
  }

  func echo(sealedClassList: [NativeInteropSealedClass]) throws -> [NativeInteropSealedClass] {
    return sealedClassList
  }

  func echo(sealedClassWrapper: NativeInteropSealedClassWrapper) throws
    -> NativeInteropSealedClassWrapper
  {
    return sealedClassWrapper
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

  func isMainThread() throws -> Bool {
    return Thread.isMainThread
  }

  func asyncIsBackgroundThread() async throws -> Bool {
    return await withCheckedContinuation { continuation in
      DispatchQueue.global(qos: .background).async {
        continuation.resume(returning: !Thread.isMainThread)
      }
    }
  }

  private var getterValue: Int64 = 0

  func isGetter() throws -> Bool {
    return true
  }

  func getGetter() throws -> Int64 {
    return getterValue
  }

  func setSetter(value: Int64) throws {
    getterValue = value
  }

  func callFlutterNoopOnBackgroundThread() async throws -> Bool {
    return await withCheckedContinuation { continuation in
      DispatchQueue.global(qos: .background).async {
        Task {
          do {
            guard let registrar = self.registrar,
              let flutterApi = NativeInteropFlutterIntegrationCoreApiRegistrar.getInstance(
                registrar: registrar)
            else {
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
    let stub = StubPluginRegistrar()
    let singleApi = NativeInteropTestsClass()
    NativeInteropHostIntegrationCoreApiSetup.register(api: singleApi, registrar: stub, name: name)
    guard
      NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min, name: name) != nil
    else {
      return false
    }
    NativeInteropHostIntegrationCoreApiSetup.unregister(api: singleApi, registrar: stub, name: name)
    guard
      NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min, name: name) == nil
    else {
      return false
    }

    // Out-of-order instance-aware unregister(api:) keeps remaining instances active,
    // and duplicate or never-registered unregister calls are safe no-ops.
    let outOfOrderName = "testOutOfOrderHostInstance"
    let api1 = NativeInteropTestsClass()
    let api2 = NativeInteropTestsClass()
    let unregisteredApi = NativeInteropTestsClass()
    NativeInteropHostIntegrationCoreApiSetup.register(
      api: api1, registrar: stub, name: outOfOrderName)
    NativeInteropHostIntegrationCoreApiSetup.register(
      api: api2, registrar: stub, name: outOfOrderName)
    let outOfOrderSetup2 = NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
      engineId: Int64.min, affinityKey: Int64.min, name: outOfOrderName)
    NativeInteropHostIntegrationCoreApiSetup.unregister(
      api: api1, registrar: stub, name: outOfOrderName)
    NativeInteropHostIntegrationCoreApiSetup.unregister(
      api: api1, registrar: stub, name: outOfOrderName)
    NativeInteropHostIntegrationCoreApiSetup.unregister(
      api: unregisteredApi, registrar: stub, name: outOfOrderName)
    guard
      outOfOrderSetup2 != nil,
      NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min, name: outOfOrderName)
        === outOfOrderSetup2
    else {
      return false
    }
    NativeInteropHostIntegrationCoreApiSetup.unregister(
      api: api2, registrar: stub, name: outOfOrderName)
    guard
      NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min, name: outOfOrderName) == nil
    else {
      return false
    }

    // Default instance is distinct from an explicit empty string (name: "").
    let defaultReservedSetup = NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
      engineId: Int64.min, affinityKey: Int64.min)
    guard
      defaultReservedSetup != nil,
      NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min, name: "") == nil
    else {
      return false
    }
    let emptyNameApi = NativeInteropReservedNamesHostApiImpl()
    NativeInteropReservedNamesHostApiSetup.register(api: emptyNameApi, registrar: stub, name: "")
    let emptyNameSetup = NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
      engineId: Int64.min, affinityKey: Int64.min, name: "")
    guard
      emptyNameSetup != nil,
      emptyNameSetup !== defaultReservedSetup,
      NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min) === defaultReservedSetup
    else {
      NativeInteropReservedNamesHostApiSetup.unregister(
        api: emptyNameApi, registrar: stub, name: "")
      return false
    }
    NativeInteropReservedNamesHostApiSetup.unregister(api: emptyNameApi, registrar: stub, name: "")
    guard
      NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min, name: "") == nil,
      NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min) === defaultReservedSetup
    else {
      return false
    }

    guard verifyEngineKeyedHostRegistration() else {
      return false
    }

    // Exercise secondary TestPlugin attach and out-of-order detach while primary engine stays
    // registered.
    let registrar1 = StubPluginRegistrar()
    let registrar2 = StubPluginRegistrar()
    TestPlugin.register(with: registrar1)
    TestPlugin.register(with: registrar2)
    guard let plugin1 = registrar1.published as? TestPlugin,
      let plugin2 = registrar2.published as? TestPlugin
    else {
      return false
    }
    plugin1.detachFromEngine(for: registrar1)
    guard
      NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min) != nil,
      NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min) != nil
    else {
      return false
    }
    plugin2.detachFromEngine(for: registrar2)
    guard
      NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min) != nil,
      NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min) != nil
    else {
      return false
    }

    #if os(macOS)
      // Exercise real secondary FlutterEngine creation and out-of-order teardown synchronously.
      // On iOS, real secondary FlutterEngine execution and deallocation require yielding the main
      // dispatch queue asynchronously and are verified in `testSecondaryEngineDartExecution()` and
      // `RunnerTests`.
      return SecondaryEngineTestRunner.verifyRealSecondaryEnginesLifecycle()
    #else
      return true
    #endif
  }

  func testDeregisterFlutterApi() throws -> Bool {
    let name = "testDeregisterFlutterInstance"
    let stub = StubPluginRegistrar()
    let engineId = stub.engineIdentifier
    let noKey = Int64.min
    let bridge1 = TestPluginReservedFlutterBridge("engine1")
    let bridge2 = TestPluginReservedFlutterBridge("engine2")
    let bridge3 = TestPluginReservedFlutterBridge("engine3")
    func lookup() -> NativeInteropReservedNamesFlutterApi? {
      return NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub, name: name)
    }

    NativeInteropReservedNamesFlutterApiRegistrar.registerInstance(
      api: bridge1, engineId: engineId, affinityKey: noKey, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.registerInstance(
      api: bridge2, engineId: engineId, affinityKey: noKey, name: name)
    guard try lookup()?.release(value: "ping") == "engine2:ping" else {
      return false
    }

    // Re-registering bridge1 updates it in place, so bridge2 stays on top.
    NativeInteropReservedNamesFlutterApiRegistrar.registerInstance(
      api: bridge1, engineId: engineId, affinityKey: noKey, name: name)
    guard try lookup()?.release(value: "ping") == "engine2:ping" else {
      return false
    }

    // Single unregister removes bridge1 completely and restores bridge2.
    NativeInteropReservedNamesFlutterApiRegistrar.unregisterInstance(api: bridge1, name: name)
    guard try lookup()?.release(value: "ping") == "engine2:ping" else {
      return false
    }

    // Out-of-order unregister on bottom entry leaves top entry intact.
    NativeInteropReservedNamesFlutterApiRegistrar.registerInstance(
      api: bridge3, engineId: engineId, affinityKey: noKey, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.unregisterInstance(api: bridge2, name: name)
    guard try lookup()?.release(value: "ping") == "engine3:ping" else {
      return false
    }

    // Unregistering the remaining entry clears the registration list completely.
    NativeInteropReservedNamesFlutterApiRegistrar.unregisterInstance(api: bridge3, name: name)
    guard lookup() == nil else {
      return false
    }

    // Duplicate unregister is a safe no-op.
    NativeInteropReservedNamesFlutterApiRegistrar.unregisterInstance(api: bridge3, name: name)
    guard lookup() == nil else {
      return false
    }

    return verifyEngineKeyedFlutterLookup()
  }

  /// Verifies that Flutter API lookups prefer the registration from the registrar's engine.
  private func verifyEngineKeyedFlutterLookup() -> Bool {
    let name = "testEngineKeyedFlutterLookup"
    let noKey = Int64.min
    let registrar1 = StubPluginRegistrar()
    let registrar2 = StubPluginRegistrar()
    let unrelated = StubPluginRegistrar()
    let bridge1 = TestPluginReservedFlutterBridge("engine1")
    let bridge2 = TestPluginReservedFlutterBridge("engine2")
    let affinityBridge = TestPluginReservedFlutterBridge("affinity")
    defer {
      for bridge in [bridge1, bridge2, affinityBridge] {
        NativeInteropReservedNamesFlutterApiRegistrar.unregisterInstance(api: bridge, name: name)
      }
    }
    func release(_ registrar: FlutterPluginRegistrar) -> String? {
      return try? NativeInteropReservedNamesFlutterApiRegistrar.getInstance(
        registrar: registrar, name: name)?.release(value: "ping")
    }

    NativeInteropReservedNamesFlutterApiRegistrar.registerInstance(
      api: bridge1, engineId: registrar1.engineIdentifier, affinityKey: noKey, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.registerInstance(
      api: bridge2, engineId: registrar2.engineIdentifier, affinityKey: noKey, name: name)
    guard
      release(registrar1) == "engine1:ping",
      release(registrar2) == "engine2:ping",
      // No matching engine falls back to the top of the stack.
      release(unrelated) == "engine2:ping"
    else {
      return false
    }

    // A registration whose Dart engine id is unknown matches by affinity key.
    NativeInteropReservedNamesFlutterApiRegistrar.registerInstance(
      api: affinityBridge, engineId: noKey, affinityKey: registrar1.engineIdentifier, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.unregisterInstance(api: bridge1, name: name)
    guard
      release(registrar1) == "affinity:ping",
      release(registrar2) == "engine2:ping"
    else {
      return false
    }
    return true
  }

  /// Verifies engine-keyed Host API registration, unregistration, and resolution.
  private func verifyEngineKeyedHostRegistration() -> Bool {
    let name = "testEngineKeyedHostRegistration"
    let noKey = Int64.min
    let registrar1 = StubPluginRegistrar()
    let registrar2 = StubPluginRegistrar()
    let engine1 = registrar1.engineIdentifier
    let engine2 = registrar2.engineIdentifier
    let shared = NativeInteropTestsClass()
    let other = NativeInteropTestsClass()
    typealias Setup = NativeInteropHostIntegrationCoreApiSetup
    defer {
      Setup.unregister(api: shared, registrar: registrar1, name: name)
      Setup.unregister(api: shared, registrar: registrar2, name: name)
      Setup.unregister(api: other, registrar: registrar1, name: name)
    }

    // The same api registered from two engines is tracked separately.
    Setup.register(api: shared, registrar: registrar1, name: name)
    let setup1 = Setup.pigeonResolveInstance(
      engineId: Int64.min, affinityKey: Int64.min, name: name)
    Setup.register(api: shared, registrar: registrar2, name: name)
    let setup2 = Setup.pigeonResolveInstance(
      engineId: Int64.min, affinityKey: Int64.min, name: name)
    guard let setup1, let setup2, setup1 !== setup2,
      Setup.pigeonEngineKey(of: setup1) == engine1,
      Setup.pigeonEngineKey(of: setup2) == engine2
    else {
      return false
    }

    // Resolution prefers engineId, then affinityKey, then the top of the stack.
    guard
      Setup.pigeonResolveInstance(engineId: engine1, affinityKey: engine2, name: name) === setup1,
      Setup.pigeonResolveInstance(engineId: engine2, affinityKey: engine1, name: name) === setup2,
      Setup.pigeonResolveInstance(engineId: noKey, affinityKey: engine1, name: name) === setup1,
      Setup.pigeonResolveInstance(engineId: noKey, affinityKey: noKey, name: name) === setup2,
      Setup.pigeonResolveInstance(engineId: 42, affinityKey: 43, name: name) === setup2,
      Setup.pigeonResolveInstance(engineId: engine1, affinityKey: noKey, name: "unknown") == nil
    else {
      return false
    }

    // Re-registering from the same engine reuses the wrapper and moves it to the top.
    Setup.register(api: shared, registrar: registrar1, name: name)
    guard
      Setup.pigeonResolveInstance(engineId: Int64.min, affinityKey: Int64.min, name: name)
        === setup1
    else {
      return false
    }

    // Out-of-order unregister removes only the entry for that engine.
    Setup.unregister(api: shared, registrar: registrar1, name: name)
    guard
      Setup.pigeonResolveInstance(engineId: Int64.min, affinityKey: Int64.min, name: name)
        === setup2,
      Setup.pigeonResolveInstance(engineId: engine1, affinityKey: noKey, name: name) === setup2
    else {
      return false
    }

    // Unregistering from an engine with no matching entry falls back to identity matching.
    Setup.register(api: other, registrar: registrar1, name: name)
    Setup.unregister(api: shared, registrar: registrar1, name: name)
    guard
      let remaining = Setup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min, name: name),
      remaining !== setup2,
      Setup.pigeonEngineKey(of: remaining) == engine1,
      Setup.pigeonResolveInstance(engineId: engine2, affinityKey: noKey, name: name) === remaining
    else {
      return false
    }
    Setup.unregister(api: other, registrar: registrar1, name: name)
    return Setup.pigeonResolveInstance(engineId: Int64.min, affinityKey: Int64.min, name: name)
      == nil
  }

  private var namedHostApis: [String: NativeInteropTestsClass] = [:]

  func registerAndImmediatelyDeregisterHostApi(name: String) throws {
    let api = NativeInteropTestsClass()
    NativeInteropHostIntegrationCoreApiSetup.register(
      api: api, registrar: effectiveRegistrar, name: name)
    NativeInteropHostIntegrationCoreApiSetup.unregister(
      api: api, registrar: effectiveRegistrar, name: name)
  }

  func registerNamedHostApi(name: String) throws {
    let api = NativeInteropTestsClass()
    namedHostApis[name] = api
    NativeInteropHostIntegrationCoreApiSetup.register(
      api: api, registrar: effectiveRegistrar, name: name)
  }

  func deregisterNamedHostApi(name: String) throws {
    guard let api = namedHostApis.removeValue(forKey: name) else {
      return
    }
    NativeInteropHostIntegrationCoreApiSetup.unregister(
      api: api, registrar: effectiveRegistrar, name: name)
  }

  func testCallDeregisteredFlutterApi(name: String) throws -> Bool {
    return NativeInteropFlutterIntegrationCoreApiRegistrar.getInstance(
      registrar: effectiveRegistrar, name: name) == nil
  }

  func testSecondaryEngineDartExecution() async throws -> Bool {
    #if os(iOS)
      return await SecondaryEngineTestRunner.verifyIOSLiveSecondaryEngineExecution()
    #elseif os(macOS)
      // Under `flutter test`, macOS FlutterEngine's `run(withEntrypoint:)` resolves symbols only
      // from flutter_tools' synthetic bootstrap library; two-engine live Dart execution on macOS
      // is therefore exercised in RunnerTests (`BasicCompileTest`) where `Runner.app`'s root
      // library exports `secondaryEngineMain`.
      return await MainActor.run {
        SecondaryEngineTestRunner.verifyRealSecondaryEnginesOnMain()
      }
    #endif
  }

  func isSecondaryEngineRegistrationReady() throws -> Bool {
    return SecondaryEngineCheckTracker.shared.isReady()
  }

  func reportSecondaryEngineCheck(success: Bool) throws {
    SecondaryEngineCheckTracker.shared.report(success: success, receiver: self)
  }

  func registeredEngineKey() throws -> Int64 {
    guard
      let registration = NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min)
    else {
      throw NativeInteropTestsError(
        code: "no-registration", message: "No default Host API registration.", details: nil)
    }
    return NativeInteropHostIntegrationCoreApiSetup.pigeonEngineKey(of: registration)
  }

  func pluginEngineIdentifierIsAvailable() throws -> Bool {
    guard let registrar = registrar else {
      return false
    }
    return (registrar as AnyObject).responds(to: NSSelectorFromString("engineIdentifier"))
  }
}

final class SecondaryEngineCheckTracker: @unchecked Sendable {
  static let shared = SecondaryEngineCheckTracker()

  private let lock = NSLock()
  private var registrationReady = false
  private var expectedReceiver: NativeInteropTestsClass?
  private var completedResult: Bool?
  private var continuation: CheckedContinuation<Bool, Never>?

  func begin() {
    lock.lock()
    defer { lock.unlock() }
    registrationReady = false
    expectedReceiver = nil
    completedResult = nil
    continuation = nil
  }

  func markRegistrationReady(expected: NativeInteropTestsClass?) {
    lock.lock()
    defer { lock.unlock() }
    expectedReceiver = expected
    registrationReady = true
  }

  func isReady() -> Bool {
    lock.lock()
    defer { lock.unlock() }
    return registrationReady
  }

  func report(success: Bool, receiver: NativeInteropTestsClass) {
    var pendingContinuation: CheckedContinuation<Bool, Never>?
    let finalOutcome: Bool
    lock.lock()
    let receiverMatches = expectedReceiver == nil || expectedReceiver === receiver
    finalOutcome = success && receiverMatches
    if let cont = continuation {
      pendingContinuation = cont
      continuation = nil
    } else if completedResult == nil {
      completedResult = finalOutcome
    }
    lock.unlock()
    pendingContinuation?.resume(returning: finalOutcome)
  }

  func waitForResult(timeoutNanoseconds: UInt64 = 15_000_000_000) async -> Bool {
    let timeoutTask = Task {
      try? await Task.sleep(nanoseconds: timeoutNanoseconds)
      self.timeoutIfPending()
    }
    let outcome = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
      var immediateResult: Bool?
      lock.lock()
      if let existing = completedResult {
        immediateResult = existing
        completedResult = nil
      } else {
        continuation = cont
      }
      lock.unlock()
      if let immediateResult {
        cont.resume(returning: immediateResult)
      }
    }
    timeoutTask.cancel()
    return outcome
  }

  private func timeoutIfPending() {
    var pendingContinuation: CheckedContinuation<Bool, Never>?
    lock.lock()
    if let cont = continuation {
      pendingContinuation = cont
      continuation = nil
    } else if completedResult == nil {
      completedResult = false
    }
    lock.unlock()
    pendingContinuation?.resume(returning: false)
  }

  func reset() {
    lock.lock()
    defer { lock.unlock() }
    registrationReady = false
    expectedReceiver = nil
    completedResult = nil
    continuation = nil
  }
}

enum SecondaryEngineTestRunner {
  #if os(iOS)
    private final class WeakEngineBox {
      weak var engine: FlutterEngine?
      init(_ engine: FlutterEngine?) {
        self.engine = engine
      }
    }

    @MainActor
    private static func startRegisteredIOSEngine(
      name: String,
      entrypoint: String,
      engineOut: inout FlutterEngine?,
      hostSetupOut: inout NativeInteropHostIntegrationCoreApiSetup?,
      reservedSetupOut: inout NativeInteropReservedNamesHostApiSetup?,
      hostImplOut: inout NativeInteropTestsClass?
    ) -> Bool {
      autoreleasepool {
        let engine = FlutterEngine(name: name, project: nil, allowHeadlessExecution: true)
        let libUri = "package:shared_test_plugin_code/secondary_engine_entrypoints.dart"
        guard
          engine.run(withEntrypoint: entrypoint, libraryURI: libUri),
          let registrar = engine.registrar(forPlugin: "TestPlugin")
        else {
          engine.destroyContext()
          return false
        }
        TestPlugin.register(with: registrar)
        engineOut = engine
        hostSetupOut = NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
          engineId: Int64.min, affinityKey: Int64.min)
        reservedSetupOut = NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
          engineId: Int64.min, affinityKey: Int64.min)
        hostImplOut = (engine.valuePublished(byPlugin: "TestPlugin") as? TestPlugin)?.niHostApiImpl
        return true
      }
    }

    @MainActor
    private static func beginIOSEngineDestroy(_ engine: inout FlutterEngine?) -> WeakEngineBox {
      let box = WeakEngineBox(engine)
      autoreleasepool {
        engine?.destroyContext()
        engine = nil
      }
      return box
    }

    @MainActor
    private static func awaitIOSEngineDealloc(_ box: WeakEngineBox) async -> Bool {
      var attempts = 0
      while box.engine != nil && attempts < 400 {
        try? await Task.sleep(nanoseconds: 5_000_000)
        attempts += 1
      }
      return box.engine == nil
    }

    @MainActor
    static func verifyRealSecondaryEnginesIOS() async -> Bool {
      let preexistingHostSetup = NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min)
      let preexistingReservedSetup = NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min)
      var engine1: FlutterEngine?
      var engine2: FlutterEngine?
      var setup1: NativeInteropHostIntegrationCoreApiSetup?
      var setup2: NativeInteropHostIntegrationCoreApiSetup?
      var reservedSetup1: NativeInteropReservedNamesHostApiSetup?
      var reservedSetup2: NativeInteropReservedNamesHostApiSetup?
      var impl1: NativeInteropTestsClass?
      var impl2: NativeInteropTestsClass?

      let started =
        startRegisteredIOSEngine(
          name: "pigeon_secondary_1",
          entrypoint: "idleSecondaryEngineMain",
          engineOut: &engine1,
          hostSetupOut: &setup1,
          reservedSetupOut: &reservedSetup1,
          hostImplOut: &impl1)
        && startRegisteredIOSEngine(
          name: "pigeon_secondary_2",
          entrypoint: "idleSecondaryEngineMain",
          engineOut: &engine2,
          hostSetupOut: &setup2,
          reservedSetupOut: &reservedSetup2,
          hostImplOut: &impl2)
      impl1 = nil
      impl2 = nil

      guard
        started,
        setup1 != nil, setup1 !== preexistingHostSetup,
        setup2 != nil, setup2 !== setup1,
        reservedSetup1 != nil, reservedSetup1 !== preexistingReservedSetup,
        reservedSetup2 != nil, reservedSetup2 !== reservedSetup1
      else {
        let box1 = beginIOSEngineDestroy(&engine1)
        let box2 = beginIOSEngineDestroy(&engine2)
        _ = await awaitIOSEngineDealloc(box1)
        _ = await awaitIOSEngineDealloc(box2)
        return false
      }

      // Destroy engine1 out-of-order without calling detachFromEngine manually;
      // iOS FlutterEngine deallocation invokes detachFromEngine(for:) automatically.
      let box1 = beginIOSEngineDestroy(&engine1)
      let deallocated1 = await awaitIOSEngineDealloc(box1)
      guard
        deallocated1,
        NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
          engineId: Int64.min, affinityKey: Int64.min) === setup2,
        NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
          engineId: Int64.min, affinityKey: Int64.min) === reservedSetup2
      else {
        let box2 = beginIOSEngineDestroy(&engine2)
        _ = await awaitIOSEngineDealloc(box2)
        return false
      }

      let box2 = beginIOSEngineDestroy(&engine2)
      let deallocated2 = await awaitIOSEngineDealloc(box2)
      return deallocated2
        && NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
          engineId: Int64.min, affinityKey: Int64.min) === preexistingHostSetup
        && NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
          engineId: Int64.min, affinityKey: Int64.min) === preexistingReservedSetup
    }

    @MainActor
    static func verifyIOSLiveSecondaryEngineExecution() async -> Bool {
      let preexistingHostSetup = NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min)
      let preexistingReservedSetup = NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min)
      SecondaryEngineCheckTracker.shared.begin()
      var engine1: FlutterEngine?
      var engine2: FlutterEngine?
      var setup1: NativeInteropHostIntegrationCoreApiSetup?
      var setup2: NativeInteropHostIntegrationCoreApiSetup?
      var reservedSetup1: NativeInteropReservedNamesHostApiSetup?
      var reservedSetup2: NativeInteropReservedNamesHostApiSetup?
      var impl1: NativeInteropTestsClass?
      var expectedImpl: NativeInteropTestsClass?

      let started =
        startRegisteredIOSEngine(
          name: "pigeon_live_1",
          entrypoint: "idleSecondaryEngineMain",
          engineOut: &engine1,
          hostSetupOut: &setup1,
          reservedSetupOut: &reservedSetup1,
          hostImplOut: &impl1)
        && startRegisteredIOSEngine(
          name: "pigeon_live_2",
          entrypoint: "secondaryEngineMain",
          engineOut: &engine2,
          hostSetupOut: &setup2,
          reservedSetupOut: &reservedSetup2,
          hostImplOut: &expectedImpl)
      impl1 = nil

      guard started, expectedImpl != nil else {
        SecondaryEngineCheckTracker.shared.reset()
        let box1 = beginIOSEngineDestroy(&engine1)
        let box2 = beginIOSEngineDestroy(&engine2)
        _ = await awaitIOSEngineDealloc(box1)
        _ = await awaitIOSEngineDealloc(box2)
        return false
      }

      // Destroy engine1 out-of-order before unblocking engine2's Dart isolate.
      let box1 = beginIOSEngineDestroy(&engine1)
      let deallocated1 = await awaitIOSEngineDealloc(box1)
      SecondaryEngineCheckTracker.shared.markRegistrationReady(expected: expectedImpl)
      expectedImpl = nil
      let passed = await SecondaryEngineCheckTracker.shared.waitForResult()
      SecondaryEngineCheckTracker.shared.reset()
      let box2 = beginIOSEngineDestroy(&engine2)
      let deallocated2 = await awaitIOSEngineDealloc(box2)
      return deallocated1 && passed && deallocated2
        && NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
          engineId: Int64.min, affinityKey: Int64.min) === preexistingHostSetup
        && NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
          engineId: Int64.min, affinityKey: Int64.min) === preexistingReservedSetup
    }
  #elseif os(macOS)
    static func verifyRealSecondaryEnginesLifecycle() -> Bool {
      if Thread.isMainThread {
        return MainActor.assumeIsolated {
          verifyRealSecondaryEnginesOnMain()
        }
      }
      return DispatchQueue.main.sync {
        MainActor.assumeIsolated {
          verifyRealSecondaryEnginesOnMain()
        }
      }
    }

    @MainActor
    static func verifyRealSecondaryEnginesOnMain() -> Bool {
      let preexistingHostSetup = NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min)
      let preexistingReservedSetup = NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min)
      let engine1 = FlutterEngine(
        name: "pigeon_secondary_1", project: nil, allowHeadlessExecution: true)
      let engine2 = FlutterEngine(
        name: "pigeon_secondary_2", project: nil, allowHeadlessExecution: true)
      let reg1 = engine1.registrar(forPlugin: "TestPlugin")
      let reg2 = engine2.registrar(forPlugin: "TestPlugin")
      TestPlugin.register(with: reg1)
      let setup1 = NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min)
      TestPlugin.register(with: reg2)
      let setup2 = NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min)
      guard
        let plugin1 = engine1.valuePublished(byPlugin: "TestPlugin") as? TestPlugin,
        let plugin2 = engine2.valuePublished(byPlugin: "TestPlugin") as? TestPlugin,
        setup1 != nil, setup1 !== preexistingHostSetup,
        setup2 != nil, setup2 !== setup1
      else {
        engine1.shutDownEngine()
        engine2.shutDownEngine()
        return false
      }
      plugin1.detachFromEngine(for: reg1)
      engine1.shutDownEngine()
      guard
        NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
          engineId: Int64.min, affinityKey: Int64.min) === setup2
      else {
        plugin2.detachFromEngine(for: reg2)
        engine2.shutDownEngine()
        return false
      }
      plugin2.detachFromEngine(for: reg2)
      engine2.shutDownEngine()
      return NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min) === preexistingHostSetup
        && NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
          engineId: Int64.min, affinityKey: Int64.min) === preexistingReservedSetup
    }

    @MainActor
    static func verifyMacOSLiveSecondaryEnginesWithEntrypoint(
      _ entrypoint: String = "secondaryEngineMain"
    ) async -> Bool {
      let preexistingHostSetup = NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min)
      let engine1 = FlutterEngine(
        name: "pigeon_macos_live_1", project: nil, allowHeadlessExecution: true)
      let engine2 = FlutterEngine(
        name: "pigeon_macos_live_2", project: nil, allowHeadlessExecution: true)
      let reg1 = engine1.registrar(forPlugin: "TestPlugin")
      let reg2 = engine2.registrar(forPlugin: "TestPlugin")

      // Register engine1 and verify its live Dart isolate invokes engine1's Host API.
      SecondaryEngineCheckTracker.shared.begin()
      TestPlugin.register(with: reg1)
      guard let plugin1 = engine1.valuePublished(byPlugin: "TestPlugin") as? TestPlugin,
        let impl1 = plugin1.niHostApiImpl
      else {
        SecondaryEngineCheckTracker.shared.reset()
        engine1.shutDownEngine()
        engine2.shutDownEngine()
        return false
      }
      SecondaryEngineCheckTracker.shared.markRegistrationReady(expected: impl1)
      guard engine1.run(withEntrypoint: entrypoint) else {
        SecondaryEngineCheckTracker.shared.reset()
        plugin1.detachFromEngine(for: reg1)
        engine1.shutDownEngine()
        engine2.shutDownEngine()
        return false
      }
      let firstPassed = await SecondaryEngineCheckTracker.shared.waitForResult()

      // Register engine2 while engine1 is still running, then tear down engine1 out-of-order
      // and verify engine2's live Dart isolate invokes engine2's Host API.
      SecondaryEngineCheckTracker.shared.begin()
      TestPlugin.register(with: reg2)
      guard let plugin2 = engine2.valuePublished(byPlugin: "TestPlugin") as? TestPlugin,
        let impl2 = plugin2.niHostApiImpl
      else {
        SecondaryEngineCheckTracker.shared.reset()
        plugin1.detachFromEngine(for: reg1)
        engine1.shutDownEngine()
        engine2.shutDownEngine()
        return false
      }
      plugin1.detachFromEngine(for: reg1)
      engine1.shutDownEngine()

      SecondaryEngineCheckTracker.shared.markRegistrationReady(expected: impl2)
      guard engine2.run(withEntrypoint: entrypoint) else {
        SecondaryEngineCheckTracker.shared.reset()
        plugin2.detachFromEngine(for: reg2)
        engine2.shutDownEngine()
        return false
      }
      let secondPassed = await SecondaryEngineCheckTracker.shared.waitForResult()
      SecondaryEngineCheckTracker.shared.reset()

      plugin2.detachFromEngine(for: reg2)
      engine2.shutDownEngine()
      return firstPassed && secondPassed
        && NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
          engineId: Int64.min, affinityKey: Int64.min) === preexistingHostSetup
    }
  #endif
}

class NativeInteropReservedNamesHostApiImpl: NativeInteropReservedNamesHostApi {
  private var storedReference = ""
  /// The registrar of the engine this instance serves; used to find that engine's Flutter APIs.
  weak var registrar: FlutterPluginRegistrar?

  init(registrar: FlutterPluginRegistrar? = nil) {
    self.registrar = registrar
  }

  func release(value: String) throws -> String {
    return value
  }

  func use(value: Int64) throws -> Int64 {
    return value
  }

  func type() throws -> String {
    return "type"
  }

  func isNull() throws -> Bool {
    return true
  }

  func isNullable() throws -> Bool? {
    return true
  }

  func isOpen() throws -> Bool {
    return true
  }

  func getReference() throws -> String {
    return storedReference
  }

  func setReference(value: String) throws {
    storedReference = value
  }

  func getDefault() throws -> String {
    return "default"
  }

  func getValueAsync() async throws -> String {
    return "value"
  }

  func register(value: String) throws -> String {
    return value
  }

  func unregister(value: String) throws -> String {
    return value
  }

  func getGetInstance() throws -> String {
    return "getInstance"
  }

  func echoReservedNames(names: NativeInteropReservedNames) throws -> NativeInteropReservedNames {
    return names
  }

  private func flutterApi() throws -> NativeInteropReservedNamesFlutterApi {
    guard let registrar,
      let flutterApi = NativeInteropReservedNamesFlutterApiRegistrar.getInstance(
        registrar: registrar)
    else {
      throw NativeInteropTestsError(
        code: "not_registered", message: "NativeInteropReservedNamesFlutterApi not registered",
        details: nil)
    }
    return flutterApi
  }

  func callFlutterRelease(value: String) throws -> String {
    return try flutterApi().release(value: value)
  }

  func callFlutterType() throws -> String {
    return try flutterApi().type()
  }

  func callFlutterImplementIn(value: String) throws -> String {
    return try flutterApi().implementIn(value: value)
  }

  func callFlutterIsNull() throws -> Bool {
    return try flutterApi().isNull()
  }

  func callFlutterGetReference() throws -> String {
    return try flutterApi().getReference()
  }

  func callFlutterRegister(value: String) throws -> String {
    return try flutterApi().register(value: value)
  }

  func callFlutterDartApi() throws -> String {
    return try flutterApi().dartApi()
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
  var onCancelled: (() -> Void)?
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

  // Closing the stream causes the Dart side to send a "cancel" call, so any
  // handler removal must wait until that call has been received. Removing the
  // handler immediately after endOfStream races with the "cancel" call, which
  // then fails with a MissingPluginException.
  override func onCancel(withArguments arguments: Any?) {
    onCancelled?()
  }
}

final class StubBinaryMessenger: NSObject, FlutterBinaryMessenger {
  func send(onChannel channel: String, message: Data?) {}

  func send(
    onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply? = nil
  ) {
    callback?(nil)
  }

  func setMessageHandlerOnChannel(
    _ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler? = nil
  ) -> FlutterBinaryMessengerConnection {
    return 0
  }

  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}
}

final class StubTextureRegistry: NSObject, FlutterTextureRegistry {
  func register(_ texture: FlutterTexture) -> Int64 { 0 }
  func textureFrameAvailable(_ textureId: Int64) {}
  func unregisterTexture(_ textureId: Int64) {}
}

final class StubPluginRegistrar: NSObject, FlutterPluginRegistrar {
  let stubMessenger: FlutterBinaryMessenger = StubBinaryMessenger()
  let stubTextures: FlutterTextureRegistry = StubTextureRegistry()
  // `@objc` so that the generated runtime lookup finds it even on Flutter
  // versions whose `FlutterPluginRegistrar` doesn't declare it.
  @objc let engineIdentifier: Int64
  var published: NSObject?

  private static let identifierLock = NSLock()
  // Large enough not to collide with the identifiers of real engines in the test process.
  private static var nextEngineIdentifier: Int64 = 1 << 40

  /// Creates a registrar for a fake engine with a unique `engineIdentifier`.
  override init() {
    StubPluginRegistrar.identifierLock.lock()
    engineIdentifier = StubPluginRegistrar.nextEngineIdentifier
    StubPluginRegistrar.nextEngineIdentifier += 1
    StubPluginRegistrar.identifierLock.unlock()
    super.init()
  }

  func publish(_ value: NSObject) {
    published = value
  }

  func addMethodCallDelegate(_ delegate: FlutterPlugin, channel: FlutterMethodChannel) {}

  func lookupKey(forAsset asset: String) -> String { asset }

  func lookupKey(forAsset asset: String, fromPackage package: String) -> String { asset }

  func valuePublished(byPlugin pluginKey: String) -> NSObject? { published }

  func register(_ factory: FlutterPlatformViewFactory, withId factoryId: String) {}

  #if os(iOS)
    var viewController: UIViewController? { nil }
    func messenger() -> FlutterBinaryMessenger { stubMessenger }
    func textures() -> FlutterTextureRegistry { stubTextures }
    func addApplicationDelegate(_ delegate: FlutterPlugin) {}
    func addSceneDelegate(_ delegate: FlutterSceneLifeCycleDelegate) {}
    func register(
      _ factory: FlutterPlatformViewFactory, withId factoryId: String,
      gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicy
    ) {}
  #elseif os(macOS)
    var messenger: FlutterBinaryMessenger { stubMessenger }
    var textures: FlutterTextureRegistry { stubTextures }
    var view: NSView? { nil }
    var viewController: NSViewController? { nil }
    func addApplicationDelegate(_ delegate: FlutterAppLifecycleDelegate) {}
  #endif
}

@objc
private final class TestPluginReservedFlutterBridge: NSObject,
  NativeInteropReservedNamesFlutterApiBridge
{
  let label: String
  init(_ label: String) { self.label = label }
  func release(value valueArg: NSString, error: NativeInteropTestsError) -> NSString? {
    "\(label):\(valueArg)" as NSString
  }
  func type(error: NativeInteropTestsError) -> NSString? { label as NSString }
  func implementIn(value valueArg: NSString, error: NativeInteropTestsError) -> NSString? {
    "\(label):\(valueArg)" as NSString
  }
  func isNull(error: NativeInteropTestsError) -> NSNumber? { NSNumber(value: false) }
  func getReference(error: NativeInteropTestsError) -> NSString? { label as NSString }
  func register(value valueArg: NSString, error: NativeInteropTestsError) -> NSString? {
    "\(label):\(valueArg)" as NSString
  }
  func dartApi(error: NativeInteropTestsError) -> NSString? { label as NSString }
}

class NativeInteropSealedClassHostApiImpl: NativeInteropSealedClassHostApi {
  /// The registrar of the engine this instance serves; used to find that engine's Flutter APIs.
  weak var registrar: FlutterPluginRegistrar?

  init(registrar: FlutterPluginRegistrar? = nil) {
    self.registrar = registrar
  }

  func echoShape(shape: NativeInteropShape) throws -> NativeInteropShape {
    return shape
  }

  func echoNullableShape(shape: NativeInteropShape?) throws -> NativeInteropShape? {
    return shape
  }

  func echoShapeList(shapes: [NativeInteropShape]) throws -> [NativeInteropShape] {
    return shapes
  }

  func echoShapeMap(shapes: [String: NativeInteropShape]) throws -> [String: NativeInteropShape] {
    return shapes
  }

  func echoAsyncShape(shape: NativeInteropShape) async throws -> NativeInteropShape {
    return shape
  }

  func callFlutterEchoShape(shape: NativeInteropShape) throws -> NativeInteropShape {
    guard let registrar,
      let flutterApi = NativeInteropSealedClassFlutterApiRegistrar.getInstance(registrar: registrar)
    else {
      throw NativeInteropTestsError(
        code: "not_registered", message: "NativeInteropSealedClassFlutterApi not registered",
        details: nil)
    }
    return try flutterApi.echoShape(shape: shape)
  }
}
