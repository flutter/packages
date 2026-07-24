// Manual Proxy API Tests

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

extension TestPlugin {

  func aNullableProxyApi(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
  ) throws -> ProxyApiSuperClass? {
    return nil
  }

  func noop(pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass) throws {
  }

  func throwError(pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass)
    throws -> Any?
  {
    throw ProxyApiTestsError(code: "code", message: "message", details: "details")
  }

  func throwErrorFromVoid(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
  ) throws {
    throw ProxyApiTestsError(code: "code", message: "message", details: "details")
  }

  func throwFlutterError(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
  ) throws -> Any? {
    throw ProxyApiTestsError(code: "code", message: "message", details: "details")
  }

  func echoInt(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anInt: Int64
  ) throws -> Int64 {
    return anInt
  }

  func echoDouble(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aDouble: Double
  ) throws -> Double {
    return aDouble
  }

  func echoBool(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aBool: Bool
  ) throws -> Bool {
    return aBool
  }

  func echoString(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aString: String
  ) throws -> String {
    return aString
  }

  func echoUint8List(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aUint8List: FlutterStandardTypedData
  ) throws -> FlutterStandardTypedData {
    return aUint8List
  }

  func echoObject(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anObject: Any
  ) throws -> Any {
    return anObject
  }

  func echoList(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aList: [Any?]
  ) throws -> [Any?] {
    return aList
  }

  func echoProxyApiList(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aList: [ProxyApiTestClass]
  ) throws -> [ProxyApiTestClass] {
    return aList
  }

  func echoMap(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aMap: [String?: Any?]
  ) throws -> [String?: Any?] {
    return aMap
  }

  func echoProxyApiMap(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aMap: [String: ProxyApiTestClass]
  ) throws -> [String: ProxyApiTestClass] {
    return aMap
  }

  func echoEnum(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    anEnum: ProxyApiTestEnum
  ) throws -> ProxyApiTestEnum {
    return anEnum
  }

  func echoProxyApi(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aProxyApi: ProxyApiSuperClass
  ) throws -> ProxyApiSuperClass {
    return aProxyApi
  }

  func echoNullableInt(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aNullableInt: Int64?
  ) throws -> Int64? {
    return aNullableInt
  }

  func echoNullableDouble(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aNullableDouble: Double?
  ) throws -> Double? {
    return aNullableDouble
  }

  func echoNullableBool(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aNullableBool: Bool?
  ) throws -> Bool? {
    return aNullableBool
  }

  func echoNullableString(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aNullableString: String?
  ) throws -> String? {
    return aNullableString
  }

  func echoNullableUint8List(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aNullableUint8List: FlutterStandardTypedData?
  ) throws -> FlutterStandardTypedData? {
    return aNullableUint8List
  }

  func echoNullableObject(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aNullableObject: Any?
  ) throws -> Any? {
    return aNullableObject
  }

  func echoNullableList(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aNullableList: [Any?]?
  ) throws -> [Any?]? {
    return aNullableList
  }

  func echoNullableMap(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aNullableMap: [String?: Any?]?
  ) throws -> [String?: Any?]? {
    return aNullableMap
  }

  func echoNullableEnum(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aNullableEnum: ProxyApiTestEnum?
  ) throws -> ProxyApiTestEnum? {
    return aNullableEnum
  }

  func echoNullableProxyApi(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aNullableProxyApi: ProxyApiSuperClass?
  ) throws -> ProxyApiSuperClass? {
    return aNullableProxyApi
  }

  func noopAsync(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    completion(.success(Void()))
  }

  func echoAsyncInt(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anInt: Int64,
    completion: @escaping (Result<Int64, Error>) -> Void
  ) {
    completion(.success(anInt))
  }

  func echoAsyncDouble(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aDouble: Double,
    completion: @escaping (Result<Double, Error>) -> Void
  ) {
    completion(.success(aDouble))
  }

  func echoAsyncBool(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aBool: Bool,
    completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    completion(.success(aBool))
  }

  func echoAsyncString(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aString: String,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    completion(.success(aString))
  }

  func echoAsyncUint8List(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aUint8List: FlutterStandardTypedData,
    completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
  ) {
    completion(.success(aUint8List))
  }

  func echoAsyncObject(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anObject: Any,
    completion: @escaping (Result<Any, Error>) -> Void
  ) {
    completion(.success(anObject))
  }

  func echoAsyncList(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aList: [Any?],
    completion: @escaping (Result<[Any?], Error>) -> Void
  ) {
    completion(.success(aList))
  }

  func echoAsyncMap(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aMap: [String?: Any?], completion: @escaping (Result<[String?: Any?], Error>) -> Void
  ) {
    completion(.success(aMap))
  }

  func echoAsyncEnum(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    anEnum: ProxyApiTestEnum, completion: @escaping (Result<ProxyApiTestEnum, Error>) -> Void
  ) {
    completion(.success(anEnum))
  }

  func throwAsyncError(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    completion: @escaping (Result<Any?, Error>) -> Void
  ) {
    completion(
      .failure(ProxyApiTestsError(code: "code", message: "message", details: "details")))
  }

  func throwAsyncErrorFromVoid(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    completion(
      .failure(ProxyApiTestsError(code: "code", message: "message", details: "details")))
  }

  func throwAsyncFlutterError(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    completion: @escaping (Result<Any?, Error>) -> Void
  ) {
    completion(
      .failure(ProxyApiTestsError(code: "code", message: "message", details: "details")))
  }

  func echoAsyncNullableInt(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anInt: Int64?,
    completion: @escaping (Result<Int64?, Error>) -> Void
  ) {
    completion(.success(anInt))
  }

  func echoAsyncNullableDouble(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aDouble: Double?,
    completion: @escaping (Result<Double?, Error>) -> Void
  ) {
    completion(.success(aDouble))
  }

  func echoAsyncNullableBool(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aBool: Bool?,
    completion: @escaping (Result<Bool?, Error>) -> Void
  ) {
    completion(.success(aBool))
  }

  func echoAsyncNullableString(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aString: String?,
    completion: @escaping (Result<String?, Error>) -> Void
  ) {
    completion(.success(aString))
  }

  func echoAsyncNullableUint8List(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aUint8List: FlutterStandardTypedData?,
    completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void
  ) {
    completion(.success(aUint8List))
  }

  func echoAsyncNullableObject(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anObject: Any?,
    completion: @escaping (Result<Any?, Error>) -> Void
  ) {
    completion(.success(anObject))
  }

  func echoAsyncNullableList(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aList: [Any?]?,
    completion: @escaping (Result<[Any?]?, Error>) -> Void
  ) {
    completion(.success(aList))
  }

  func echoAsyncNullableMap(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aMap: [String?: Any?]?, completion: @escaping (Result<[String?: Any?]?, Error>) -> Void
  ) {
    completion(.success(aMap))
  }

  func echoAsyncNullableEnum(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    anEnum: ProxyApiTestEnum?, completion: @escaping (Result<ProxyApiTestEnum?, Error>) -> Void
  ) {
    completion(.success(anEnum))
  }

  func staticNoop(pigeonApi: PigeonApiProxyApiTestClass) throws {

  }

  func echoStaticString(pigeonApi: PigeonApiProxyApiTestClass, aString: String) throws -> String {
    return aString
  }

  func staticAsyncNoop(
    pigeonApi: PigeonApiProxyApiTestClass, completion: @escaping (Result<Void, Error>) -> Void
  ) {
    completion(.success(Void()))
  }

  func callFlutterNoop(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    pigeonApi.flutterNoop(pigeonInstance: pigeonInstance) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterThrowError(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    completion: @escaping (Result<Any?, Error>) -> Void
  ) {
    pigeonApi.flutterThrowError(pigeonInstance: pigeonInstance) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterThrowErrorFromVoid(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    pigeonApi.flutterThrowErrorFromVoid(pigeonInstance: pigeonInstance) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoBool(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aBool: Bool,
    completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    pigeonApi.flutterEchoBool(pigeonInstance: pigeonInstance, aBool: aBool) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoInt(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anInt: Int64,
    completion: @escaping (Result<Int64, Error>) -> Void
  ) {
    pigeonApi.flutterEchoInt(pigeonInstance: pigeonInstance, anInt: anInt) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoDouble(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aDouble: Double,
    completion: @escaping (Result<Double, Error>) -> Void
  ) {
    pigeonApi.flutterEchoDouble(pigeonInstance: pigeonInstance, aDouble: aDouble) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoString(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aString: String,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    pigeonApi.flutterEchoString(pigeonInstance: pigeonInstance, aString: aString) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoUint8List(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aUint8List: FlutterStandardTypedData,
    completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
  ) {
    pigeonApi.flutterEchoUint8List(pigeonInstance: pigeonInstance, aList: aUint8List) {
      response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoList(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aList: [Any?],
    completion: @escaping (Result<[Any?], Error>) -> Void
  ) {
    pigeonApi.flutterEchoList(pigeonInstance: pigeonInstance, aList: aList) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoProxyApiList(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aList: [ProxyApiTestClass?],
    completion: @escaping (Result<[ProxyApiTestClass?], Error>) -> Void
  ) {
    pigeonApi.flutterEchoProxyApiList(pigeonInstance: pigeonInstance, aList: aList) {
      response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoMap(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aMap: [String?: Any?], completion: @escaping (Result<[String?: Any?], Error>) -> Void
  ) {
    pigeonApi.flutterEchoMap(pigeonInstance: pigeonInstance, aMap: aMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoProxyApiMap(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aMap: [String?: ProxyApiTestClass?],
    completion: @escaping (Result<[String?: ProxyApiTestClass?], Error>) -> Void
  ) {
    pigeonApi.flutterEchoProxyApiMap(pigeonInstance: pigeonInstance, aMap: aMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoEnum(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    anEnum: ProxyApiTestEnum, completion: @escaping (Result<ProxyApiTestEnum, Error>) -> Void
  ) {
    pigeonApi.flutterEchoEnum(pigeonInstance: pigeonInstance, anEnum: anEnum) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoProxyApi(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aProxyApi: ProxyApiSuperClass,
    completion: @escaping (Result<ProxyApiSuperClass, Error>) -> Void
  ) {
    pigeonApi.flutterEchoProxyApi(pigeonInstance: pigeonInstance, aProxyApi: aProxyApi) {
      response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullableBool(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aBool: Bool?,
    completion: @escaping (Result<Bool?, Error>) -> Void
  ) {
    pigeonApi.flutterEchoNullableBool(pigeonInstance: pigeonInstance, aBool: aBool) {
      response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullableInt(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anInt: Int64?,
    completion: @escaping (Result<Int64?, Error>) -> Void
  ) {
    pigeonApi.flutterEchoNullableInt(pigeonInstance: pigeonInstance, anInt: anInt) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullableDouble(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aDouble: Double?,
    completion: @escaping (Result<Double?, Error>) -> Void
  ) {
    pigeonApi.flutterEchoNullableDouble(pigeonInstance: pigeonInstance, aDouble: aDouble) {
      response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullableString(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aString: String?,
    completion: @escaping (Result<String?, Error>) -> Void
  ) {
    pigeonApi.flutterEchoNullableString(pigeonInstance: pigeonInstance, aString: aString) {
      response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullableUint8List(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aUint8List: FlutterStandardTypedData?,
    completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void
  ) {
    pigeonApi.flutterEchoNullableUint8List(pigeonInstance: pigeonInstance, aList: aUint8List) {
      response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullableList(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aList: [Any?]?,
    completion: @escaping (Result<[Any?]?, Error>) -> Void
  ) {
    pigeonApi.flutterEchoNullableList(pigeonInstance: pigeonInstance, aList: aList) {
      response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullableMap(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aMap: [String?: Any?]?, completion: @escaping (Result<[String?: Any?]?, Error>) -> Void
  ) {
    pigeonApi.flutterEchoNullableMap(pigeonInstance: pigeonInstance, aMap: aMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullableEnum(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    anEnum: ProxyApiTestEnum?, completion: @escaping (Result<ProxyApiTestEnum?, Error>) -> Void
  ) {
    pigeonApi.flutterEchoNullableEnum(pigeonInstance: pigeonInstance, anEnum: anEnum) {
      response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoNullableProxyApi(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    aProxyApi: ProxyApiSuperClass?,
    completion: @escaping (Result<ProxyApiSuperClass?, Error>) -> Void
  ) {
    pigeonApi.flutterEchoNullableProxyApi(pigeonInstance: pigeonInstance, aProxyApi: aProxyApi) {
      response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterNoopAsync(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    pigeonApi.flutterNoopAsync(pigeonInstance: pigeonInstance) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func callFlutterEchoAsyncString(
    pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aString: String,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    pigeonApi.flutterEchoAsyncString(pigeonInstance: pigeonInstance, aString: aString) {
      response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}

class ProxyApiDelegate: ProxyApiTestsPigeonProxyApiDelegate {
  func pigeonApiProxyApiTestClass(_ registrar: ProxyApiTestsPigeonProxyApiRegistrar)
    -> PigeonApiProxyApiTestClass
  {
    class ProxyApiTestClassDelegate: PigeonApiDelegateProxyApiTestClass {
      func pigeonDefaultConstructor(
        pigeonApi: PigeonApiProxyApiTestClass, aBool: Bool, anInt: Int64, aDouble: Double,
        aString: String, aUint8List: FlutterStandardTypedData, aList: [Any?],
        aMap: [String?: Any?],
        anEnum: ProxyApiTestEnum, aProxyApi: ProxyApiSuperClass, aNullableBool: Bool?,
        aNullableInt: Int64?, aNullableDouble: Double?, aNullableString: String?,
        aNullableUint8List: FlutterStandardTypedData?, aNullableList: [Any?]?,
        aNullableMap: [String?: Any?]?, aNullableEnum: ProxyApiTestEnum?,
        aNullableProxyApi: ProxyApiSuperClass?, boolParam: Bool, intParam: Int64,
        doubleParam: Double, stringParam: String, aUint8ListParam: FlutterStandardTypedData,
        listParam: [Any?], mapParam: [String?: Any?], enumParam: ProxyApiTestEnum,
        proxyApiParam: ProxyApiSuperClass, nullableBoolParam: Bool?, nullableIntParam: Int64?,
        nullableDoubleParam: Double?, nullableStringParam: String?,
        nullableUint8ListParam: FlutterStandardTypedData?, nullableListParam: [Any?]?,
        nullableMapParam: [String?: Any?]?, nullableEnumParam: ProxyApiTestEnum?,
        nullableProxyApiParam: ProxyApiSuperClass?
      ) throws -> ProxyApiTestClass {
        return ProxyApiTestClass()
      }

      func namedConstructor(
        pigeonApi: PigeonApiProxyApiTestClass, aBool: Bool, anInt: Int64, aDouble: Double,
        aString: String, aUint8List: FlutterStandardTypedData, aList: [Any?], aMap: [String?: Any?],
        anEnum: ProxyApiTestEnum, aProxyApi: ProxyApiSuperClass, aNullableBool: Bool?,
        aNullableInt: Int64?, aNullableDouble: Double?, aNullableString: String?,
        aNullableUint8List: FlutterStandardTypedData?, aNullableList: [Any?]?,
        aNullableMap: [String?: Any?]?, aNullableEnum: ProxyApiTestEnum?,
        aNullableProxyApi: ProxyApiSuperClass?
      ) throws -> ProxyApiTestClass {
        return ProxyApiTestClass()
      }

      func attachedField(pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass)
        throws -> ProxyApiSuperClass
      {
        return ProxyApiSuperClass()
      }

      func staticAttachedField(pigeonApi: PigeonApiProxyApiTestClass) throws
        -> ProxyApiSuperClass
      {
        return ProxyApiSuperClass()
      }

      func noop(pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass) throws {
      }

      func throwError(pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass)
        throws -> Any?
      {
        throw ProxyApiTestsError(code: "code", message: "message", details: "details")
      }

      func throwErrorFromVoid(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
      ) throws {
        throw ProxyApiTestsError(code: "code", message: "message", details: "details")
      }

      func throwFlutterError(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
      ) throws -> Any? {
        throw ProxyApiTestsError(code: "code", message: "message", details: "details")
      }

      func echoInt(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anInt: Int64
      ) throws -> Int64 {
        return anInt
      }

      func echoDouble(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aDouble: Double
      ) throws -> Double {
        return aDouble
      }

      func echoBool(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aBool: Bool
      ) throws -> Bool {
        return aBool
      }

      func echoString(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aString: String
      ) throws -> String {
        return aString
      }

      func echoUint8List(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aUint8List: FlutterStandardTypedData
      ) throws -> FlutterStandardTypedData {
        return aUint8List
      }

      func echoObject(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anObject: Any
      ) throws -> Any {
        return anObject
      }

      func echoList(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aList: [Any?]
      ) throws -> [Any?] {
        return aList
      }

      func echoProxyApiList(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aList: [ProxyApiTestClass]
      ) throws -> [ProxyApiTestClass] {
        return aList
      }

      func echoMap(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aMap: [String?: Any?]
      ) throws -> [String?: Any?] {
        return aMap
      }

      func echoProxyApiMap(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aMap: [String: ProxyApiTestClass]
      ) throws -> [String: ProxyApiTestClass] {
        return aMap
      }

      func echoEnum(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        anEnum: ProxyApiTestEnum
      ) throws -> ProxyApiTestEnum {
        return anEnum
      }

      func echoProxyApi(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aProxyApi: ProxyApiSuperClass
      ) throws -> ProxyApiSuperClass {
        return aProxyApi
      }

      func echoNullableInt(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableInt: Int64?
      ) throws -> Int64? {
        return aNullableInt
      }

      func echoNullableDouble(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableDouble: Double?
      ) throws -> Double? {
        return aNullableDouble
      }

      func echoNullableBool(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableBool: Bool?
      ) throws -> Bool? {
        return aNullableBool
      }

      func echoNullableString(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableString: String?
      ) throws -> String? {
        return aNullableString
      }

      func echoNullableUint8List(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableUint8List: FlutterStandardTypedData?
      ) throws -> FlutterStandardTypedData? {
        return aNullableUint8List
      }

      func echoNullableObject(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableObject: Any?
      ) throws -> Any? {
        return aNullableObject
      }

      func echoNullableList(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableList: [Any?]?
      ) throws -> [Any?]? {
        return aNullableList
      }

      func echoNullableMap(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableMap: [String?: Any?]?
      ) throws -> [String?: Any?]? {
        return aNullableMap
      }

      func echoNullableEnum(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableEnum: ProxyApiTestEnum?
      ) throws -> ProxyApiTestEnum? {
        return aNullableEnum
      }

      func echoNullableProxyApi(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableProxyApi: ProxyApiSuperClass?
      ) throws -> ProxyApiSuperClass? {
        return aNullableProxyApi
      }

      func noopAsync(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        completion: @escaping (Result<Void, Error>) -> Void
      ) {
        completion(.success(Void()))
      }

      func echoAsyncInt(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anInt: Int64,
        completion: @escaping (Result<Int64, Error>) -> Void
      ) {
        completion(.success(anInt))
      }

      func echoAsyncDouble(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aDouble: Double,
        completion: @escaping (Result<Double, Error>) -> Void
      ) {
        completion(.success(aDouble))
      }

      func echoAsyncBool(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aBool: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
      ) {
        completion(.success(aBool))
      }

      func echoAsyncString(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aString: String,
        completion: @escaping (Result<String, Error>) -> Void
      ) {
        completion(.success(aString))
      }

      func echoAsyncUint8List(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aUint8List: FlutterStandardTypedData,
        completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
      ) {
        completion(.success(aUint8List))
      }

      func echoAsyncObject(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anObject: Any,
        completion: @escaping (Result<Any, Error>) -> Void
      ) {
        completion(.success(anObject))
      }

      func echoAsyncList(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aList: [Any?],
        completion: @escaping (Result<[Any?], Error>) -> Void
      ) {
        completion(.success(aList))
      }

      func echoAsyncMap(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aMap: [String?: Any?], completion: @escaping (Result<[String?: Any?], Error>) -> Void
      ) {
        completion(.success(aMap))
      }

      func echoAsyncEnum(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        anEnum: ProxyApiTestEnum,
        completion: @escaping (Result<ProxyApiTestEnum, Error>) -> Void
      ) {
        completion(.success(anEnum))
      }

      func throwAsyncError(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        completion: @escaping (Result<Any?, Error>) -> Void
      ) {
        completion(
          .failure(ProxyApiTestsError(code: "code", message: "message", details: "details")))
      }

      func throwAsyncErrorFromVoid(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        completion: @escaping (Result<Void, Error>) -> Void
      ) {
        completion(
          .failure(ProxyApiTestsError(code: "code", message: "message", details: "details")))
      }

      func throwAsyncFlutterError(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        completion: @escaping (Result<Any?, Error>) -> Void
      ) {
        completion(
          .failure(ProxyApiTestsError(code: "code", message: "message", details: "details")))
      }

      func echoAsyncNullableInt(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anInt: Int64?,
        completion: @escaping (Result<Int64?, Error>) -> Void
      ) {
        completion(.success(anInt))
      }

      func echoAsyncNullableDouble(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aDouble: Double?,
        completion: @escaping (Result<Double?, Error>) -> Void
      ) {
        completion(.success(aDouble))
      }

      func echoAsyncNullableBool(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aBool: Bool?,
        completion: @escaping (Result<Bool?, Error>) -> Void
      ) {
        completion(.success(aBool))
      }

      func echoAsyncNullableString(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aString: String?,
        completion: @escaping (Result<String?, Error>) -> Void
      ) {
        completion(.success(aString))
      }

      func echoAsyncNullableUint8List(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aUint8List: FlutterStandardTypedData?,
        completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void
      ) {
        completion(.success(aUint8List))
      }

      func echoAsyncNullableObject(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        anObject: Any?,
        completion: @escaping (Result<Any?, Error>) -> Void
      ) {
        completion(.success(anObject))
      }

      func echoAsyncNullableList(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aList: [Any?]?,
        completion: @escaping (Result<[Any?]?, Error>) -> Void
      ) {
        completion(.success(aList))
      }

      func echoAsyncNullableMap(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aMap: [String?: Any?]?, completion: @escaping (Result<[String?: Any?]?, Error>) -> Void
      ) {
        completion(.success(aMap))
      }

      func echoAsyncNullableEnum(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        anEnum: ProxyApiTestEnum?,
        completion: @escaping (Result<ProxyApiTestEnum?, Error>) -> Void
      ) {
        completion(.success(anEnum))
      }

      func staticNoop(pigeonApi: PigeonApiProxyApiTestClass) throws {

      }

      func echoStaticString(pigeonApi: PigeonApiProxyApiTestClass, aString: String) throws
        -> String
      {
        return aString
      }

      func staticAsyncNoop(
        pigeonApi: PigeonApiProxyApiTestClass,
        completion: @escaping (Result<Void, Error>) -> Void
      ) {
        completion(.success(Void()))
      }

      func callFlutterNoop(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        completion: @escaping (Result<Void, Error>) -> Void
      ) {
        pigeonApi.flutterNoop(pigeonInstance: pigeonInstance) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterThrowError(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        completion: @escaping (Result<Any?, Error>) -> Void
      ) {
        pigeonApi.flutterThrowError(pigeonInstance: pigeonInstance) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterThrowErrorFromVoid(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        completion: @escaping (Result<Void, Error>) -> Void
      ) {
        pigeonApi.flutterThrowErrorFromVoid(pigeonInstance: pigeonInstance) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoBool(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aBool: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
      ) {
        pigeonApi.flutterEchoBool(pigeonInstance: pigeonInstance, aBool: aBool) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoInt(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anInt: Int64,
        completion: @escaping (Result<Int64, Error>) -> Void
      ) {
        pigeonApi.flutterEchoInt(pigeonInstance: pigeonInstance, anInt: anInt) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoDouble(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aDouble: Double,
        completion: @escaping (Result<Double, Error>) -> Void
      ) {
        pigeonApi.flutterEchoDouble(pigeonInstance: pigeonInstance, aDouble: aDouble) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoString(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aString: String,
        completion: @escaping (Result<String, Error>) -> Void
      ) {
        pigeonApi.flutterEchoString(pigeonInstance: pigeonInstance, aString: aString) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoUint8List(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aUint8List: FlutterStandardTypedData,
        completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
      ) {
        pigeonApi.flutterEchoUint8List(pigeonInstance: pigeonInstance, aList: aUint8List) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoList(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aList: [Any?],
        completion: @escaping (Result<[Any?], Error>) -> Void
      ) {
        pigeonApi.flutterEchoList(pigeonInstance: pigeonInstance, aList: aList) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoProxyApiList(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aList: [ProxyApiTestClass?],
        completion: @escaping (Result<[ProxyApiTestClass?], Error>) -> Void
      ) {
        pigeonApi.flutterEchoProxyApiList(pigeonInstance: pigeonInstance, aList: aList) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoMap(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aMap: [String?: Any?], completion: @escaping (Result<[String?: Any?], Error>) -> Void
      ) {
        pigeonApi.flutterEchoMap(pigeonInstance: pigeonInstance, aMap: aMap) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoProxyApiMap(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aMap: [String?: ProxyApiTestClass?],
        completion: @escaping (Result<[String?: ProxyApiTestClass?], Error>) -> Void
      ) {
        pigeonApi.flutterEchoProxyApiMap(pigeonInstance: pigeonInstance, aMap: aMap) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoEnum(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        anEnum: ProxyApiTestEnum,
        completion: @escaping (Result<ProxyApiTestEnum, Error>) -> Void
      ) {
        pigeonApi.flutterEchoEnum(pigeonInstance: pigeonInstance, anEnum: anEnum) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoProxyApi(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aProxyApi: ProxyApiSuperClass,
        completion: @escaping (Result<ProxyApiSuperClass, Error>) -> Void
      ) {
        pigeonApi.flutterEchoProxyApi(pigeonInstance: pigeonInstance, aProxyApi: aProxyApi) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoNullableBool(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aBool: Bool?,
        completion: @escaping (Result<Bool?, Error>) -> Void
      ) {
        pigeonApi.flutterEchoNullableBool(pigeonInstance: pigeonInstance, aBool: aBool) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoNullableInt(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anInt: Int64?,
        completion: @escaping (Result<Int64?, Error>) -> Void
      ) {
        pigeonApi.flutterEchoNullableInt(pigeonInstance: pigeonInstance, anInt: anInt) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoNullableDouble(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aDouble: Double?,
        completion: @escaping (Result<Double?, Error>) -> Void
      ) {
        pigeonApi.flutterEchoNullableDouble(pigeonInstance: pigeonInstance, aDouble: aDouble) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoNullableString(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aString: String?,
        completion: @escaping (Result<String?, Error>) -> Void
      ) {
        pigeonApi.flutterEchoNullableString(pigeonInstance: pigeonInstance, aString: aString) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoNullableUint8List(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aUint8List: FlutterStandardTypedData?,
        completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void
      ) {
        pigeonApi.flutterEchoNullableUint8List(
          pigeonInstance: pigeonInstance, aList: aUint8List
        ) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoNullableList(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aList: [Any?]?,
        completion: @escaping (Result<[Any?]?, Error>) -> Void
      ) {
        pigeonApi.flutterEchoNullableList(pigeonInstance: pigeonInstance, aList: aList) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoNullableMap(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aMap: [String?: Any?]?, completion: @escaping (Result<[String?: Any?]?, Error>) -> Void
      ) {
        pigeonApi.flutterEchoNullableMap(pigeonInstance: pigeonInstance, aMap: aMap) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoNullableEnum(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        anEnum: ProxyApiTestEnum?,
        completion: @escaping (Result<ProxyApiTestEnum?, Error>) -> Void
      ) {
        pigeonApi.flutterEchoNullableEnum(pigeonInstance: pigeonInstance, anEnum: anEnum) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoNullableProxyApi(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aProxyApi: ProxyApiSuperClass?,
        completion: @escaping (Result<ProxyApiSuperClass?, Error>) -> Void
      ) {
        pigeonApi.flutterEchoNullableProxyApi(
          pigeonInstance: pigeonInstance, aProxyApi: aProxyApi
        ) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterNoopAsync(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        completion: @escaping (Result<Void, Error>) -> Void
      ) {
        pigeonApi.flutterNoopAsync(pigeonInstance: pigeonInstance) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      func callFlutterEchoAsyncString(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aString: String,
        completion: @escaping (Result<String, Error>) -> Void
      ) {
        pigeonApi.flutterEchoAsyncString(pigeonInstance: pigeonInstance, aString: aString) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

    }
    return PigeonApiProxyApiTestClass(
      pigeonRegistrar: registrar, delegate: ProxyApiTestClassDelegate())
  }

  func pigeonApiProxyApiSuperClass(_ registrar: ProxyApiTestsPigeonProxyApiRegistrar)
    -> PigeonApiProxyApiSuperClass
  {
    class ProxyApiSuperClassDelegate: PigeonApiDelegateProxyApiSuperClass {
      func pigeonDefaultConstructor(pigeonApi: PigeonApiProxyApiSuperClass) throws
        -> ProxyApiSuperClass
      {
        return ProxyApiSuperClass()
      }

      func aSuperMethod(pigeonApi: PigeonApiProxyApiSuperClass, pigeonInstance: ProxyApiSuperClass)
        throws
      {}
    }
    return PigeonApiProxyApiSuperClass(
      pigeonRegistrar: registrar, delegate: ProxyApiSuperClassDelegate())
  }

  func pigeonApiProxyApiInterface(_ registrar: ProxyApiTestsPigeonProxyApiRegistrar)
    -> PigeonApiProxyApiInterface
  {
    class ProxyApiInterfaceDelegate: PigeonApiDelegateProxyApiInterface {}
    return PigeonApiProxyApiInterface(
      pigeonRegistrar: registrar, delegate: ProxyApiInterfaceDelegate())
  }

  func pigeonApiClassWithApiRequirement(_ registrar: ProxyApiTestsPigeonProxyApiRegistrar)
    -> PigeonApiClassWithApiRequirement
  {
    class ClassWithApiRequirementDelegate: PigeonApiDelegateClassWithApiRequirement {
      @available(iOS 15, macOS 10, *)
      func pigeonDefaultConstructor(pigeonApi: PigeonApiClassWithApiRequirement) throws
        -> ClassWithApiRequirement
      {
        return ClassWithApiRequirement()
      }

      @available(iOS 15, macOS 10, *)
      func aMethod(
        pigeonApi: PigeonApiClassWithApiRequirement, pigeonInstance: ClassWithApiRequirement
      ) throws {

      }
    }

    return PigeonApiClassWithApiRequirement(
      pigeonRegistrar: registrar, delegate: ClassWithApiRequirementDelegate())
  }
}
