// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

enum ProxyApiTestEnum { one, two, three }

/// The core ProxyApi test class that each supported host language must
/// implement in platform_tests integration tests.
@ProxyApi()
abstract class ProxyApiTestClass extends ProxyApiSuperClass
    implements ProxyApiInterface {
  ProxyApiTestClass(
    // ignore: avoid_unused_constructor_parameters
    bool boolParam,
    // ignore: avoid_unused_constructor_parameters
    int intParam,
    // ignore: avoid_unused_constructor_parameters
    double doubleParam,
    // ignore: avoid_unused_constructor_parameters
    String stringParam,
    // ignore: avoid_unused_constructor_parameters
    Uint8List aUint8ListParam,
    // ignore: avoid_unused_constructor_parameters
    List<Object?> listParam,
    // ignore: avoid_unused_constructor_parameters
    Map<String?, Object?> mapParam,
    // ignore: avoid_unused_constructor_parameters
    ProxyApiTestEnum enumParam,
    // ignore: avoid_unused_constructor_parameters
    ProxyApiSuperClass proxyApiParam,
    // ignore: avoid_unused_constructor_parameters
    bool? nullableBoolParam,
    // ignore: avoid_unused_constructor_parameters
    int? nullableIntParam,
    // ignore: avoid_unused_constructor_parameters
    double? nullableDoubleParam,
    // ignore: avoid_unused_constructor_parameters
    String? nullableStringParam,
    // ignore: avoid_unused_constructor_parameters
    Uint8List? nullableUint8ListParam,
    // ignore: avoid_unused_constructor_parameters
    List<Object?>? nullableListParam,
    // ignore: avoid_unused_constructor_parameters
    Map<String?, Object?>? nullableMapParam,
    // ignore: avoid_unused_constructor_parameters
    ProxyApiTestEnum? nullableEnumParam,
    // ignore: avoid_unused_constructor_parameters
    ProxyApiSuperClass? nullableProxyApiParam,
  );

  ProxyApiTestClass.namedConstructor();

  late bool aBool;
  late int anInt;
  late double aDouble;
  late String aString;
  late Uint8List aUint8List;
  late List<Object?> aList;
  late Map<String?, Object?> aMap;
  late ProxyApiTestEnum anEnum;
  late ProxyApiSuperClass aProxyApi;

  late bool? aNullableBool;
  late int? aNullableInt;
  late double? aNullableDouble;
  late String? aNullableString;
  late Uint8List? aNullableUint8List;
  late List<Object?>? aNullableList;
  late Map<String?, Object?>? aNullableMap;
  late ProxyApiTestEnum? aNullableEnum;
  late ProxyApiSuperClass? aNullableProxyApi;

  @attached
  late ProxyApiSuperClass attachedField;

  @static
  late ProxyApiSuperClass staticAttachedField;

  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic calling.
  late void Function()? flutterNoop;

  /// Responds with an error from an async function returning a value.
  late Object? Function()? flutterThrowError;

  /// Responds with an error from an async void function.
  late void Function()? flutterThrowErrorFromVoid;

  // ========== Non-nullable argument/return type tests ==========

  /// Returns the passed boolean, to test serialization and deserialization.
  late bool Function(bool aBool) flutterEchoBool;

  /// Returns the passed int, to test serialization and deserialization.
  late int Function(int anInt) flutterEchoInt;

  /// Returns the passed double, to test serialization and deserialization.
  late double Function(double aDouble) flutterEchoDouble;

  /// Returns the passed string, to test serialization and deserialization.
  late String Function(String aString) flutterEchoString;

  /// Returns the passed byte list, to test serialization and deserialization.
  late Uint8List Function(Uint8List aList) flutterEchoUint8List;

  /// Returns the passed list, to test serialization and deserialization.
  late List<Object?> Function(List<Object?> aList) flutterEchoList;

  /// Returns the passed list with ProxyApis, to test serialization and
  /// deserialization.
  late List<ProxyApiTestClass?> Function(List<ProxyApiTestClass?> aList)
  flutterEchoProxyApiList;

  /// Returns the passed map, to test serialization and deserialization.
  late Map<String?, Object?> Function(Map<String?, Object?> aMap)
  flutterEchoMap;

  /// Returns the passed map with ProxyApis, to test serialization and
  /// deserialization.
  late Map<String?, ProxyApiTestClass?> Function(
    Map<String?, ProxyApiTestClass?> aMap,
  )
  flutterEchoProxyApiMap;

  /// Returns the passed enum to test serialization and deserialization.
  late ProxyApiTestEnum Function(ProxyApiTestEnum anEnum) flutterEchoEnum;

  /// Returns the passed ProxyApi to test serialization and deserialization.
  late ProxyApiSuperClass Function(ProxyApiSuperClass aProxyApi)
  flutterEchoProxyApi;

  // ========== Nullable argument/return type tests ==========

  /// Returns the passed boolean, to test serialization and deserialization.
  late bool? Function(bool? aBool)? flutterEchoNullableBool;

  /// Returns the passed int, to test serialization and deserialization.
  late int? Function(int? anInt)? flutterEchoNullableInt;

  /// Returns the passed double, to test serialization and deserialization.
  late double? Function(double? aDouble)? flutterEchoNullableDouble;

  /// Returns the passed string, to test serialization and deserialization.
  late String? Function(String? aString)? flutterEchoNullableString;

  /// Returns the passed byte list, to test serialization and deserialization.
  late Uint8List? Function(Uint8List? aList)? flutterEchoNullableUint8List;

  /// Returns the passed list, to test serialization and deserialization.
  late List<Object?>? Function(List<Object?>? aList)? flutterEchoNullableList;

  /// Returns the passed map, to test serialization and deserialization.
  late Map<String?, Object?>? Function(Map<String?, Object?>? aMap)?
  flutterEchoNullableMap;

  /// Returns the passed enum to test serialization and deserialization.
  late ProxyApiTestEnum? Function(ProxyApiTestEnum? anEnum)?
  flutterEchoNullableEnum;

  /// Returns the passed ProxyApi to test serialization and deserialization.
  late ProxyApiSuperClass? Function(ProxyApiSuperClass? aProxyApi)?
  flutterEchoNullableProxyApi;

  // ========== Async tests ==========
  // These are minimal since async FlutterApi only changes Dart generation.
  // Currently they aren't integration tested, but having them here ensures
  // analysis coverage.

  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic asynchronous calling.
  @async
  late void Function()? flutterNoopAsync;

  /// Returns the passed in generic Object asynchronously.
  @async
  late String Function(String aString) flutterEchoAsyncString;

  // ========== Synchronous host method tests ==========

  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic calling.
  void noop();

  /// Returns an error, to test error handling.
  Object? throwError();

  /// Returns an error from a void function, to test error handling.
  void throwErrorFromVoid();

  /// Returns a Flutter error, to test error handling.
  Object? throwFlutterError();

  /// Returns passed in int.
  int echoInt(int anInt);

  /// Returns passed in double.
  double echoDouble(double aDouble);

  /// Returns the passed in boolean.
  bool echoBool(bool aBool);

  /// Returns the passed in string.
  String echoString(String aString);

  /// Returns the passed in Uint8List.
  Uint8List echoUint8List(Uint8List aUint8List);

  /// Returns the passed in generic Object.
  Object echoObject(Object anObject);

  /// Returns the passed list, to test serialization and deserialization.
  List<Object?> echoList(List<Object?> aList);

  /// Returns the passed list with ProxyApis, to test serialization and
  /// deserialization.
  List<ProxyApiTestClass> echoProxyApiList(List<ProxyApiTestClass> aList);

  /// Returns the passed map, to test serialization and deserialization.
  Map<String?, Object?> echoMap(Map<String?, Object?> aMap);

  /// Returns the passed map with ProxyApis, to test serialization and
  /// deserialization.
  Map<String, ProxyApiTestClass> echoProxyApiMap(
    Map<String, ProxyApiTestClass> aMap,
  );

  /// Returns the passed enum to test serialization and deserialization.
  ProxyApiTestEnum echoEnum(ProxyApiTestEnum anEnum);

  /// Returns the passed ProxyApi to test serialization and deserialization.
  ProxyApiSuperClass echoProxyApi(ProxyApiSuperClass aProxyApi);

  // ========== Synchronous host nullable method tests ==========

  /// Returns passed in int.
  int? echoNullableInt(int? aNullableInt);

  /// Returns passed in double.
  double? echoNullableDouble(double? aNullableDouble);

  /// Returns the passed in boolean.
  bool? echoNullableBool(bool? aNullableBool);

  /// Returns the passed in string.
  String? echoNullableString(String? aNullableString);

  /// Returns the passed in Uint8List.
  Uint8List? echoNullableUint8List(Uint8List? aNullableUint8List);

  /// Returns the passed in generic Object.
  Object? echoNullableObject(Object? aNullableObject);

  /// Returns the passed list, to test serialization and deserialization.
  List<Object?>? echoNullableList(List<Object?>? aNullableList);

  /// Returns the passed map, to test serialization and deserialization.
  Map<String?, Object?>? echoNullableMap(Map<String?, Object?>? aNullableMap);

  ProxyApiTestEnum? echoNullableEnum(ProxyApiTestEnum? aNullableEnum);

  /// Returns the passed ProxyApi to test serialization and deserialization.
  ProxyApiSuperClass? echoNullableProxyApi(
    ProxyApiSuperClass? aNullableProxyApi,
  );

  // ========== Asynchronous method tests ==========

  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic asynchronous calling.
  @async
  void noopAsync();

  /// Returns passed in int asynchronously.
  @async
  int echoAsyncInt(int anInt);

  /// Returns passed in double asynchronously.
  @async
  double echoAsyncDouble(double aDouble);

  /// Returns the passed in boolean asynchronously.
  @async
  bool echoAsyncBool(bool aBool);

  /// Returns the passed string asynchronously.
  @async
  String echoAsyncString(String aString);

  /// Returns the passed in Uint8List asynchronously.
  @async
  Uint8List echoAsyncUint8List(Uint8List aUint8List);

  /// Returns the passed in generic Object asynchronously.
  @async
  Object echoAsyncObject(Object anObject);

  /// Returns the passed list, to test asynchronous serialization and deserialization.
  @async
  List<Object?> echoAsyncList(List<Object?> aList);

  /// Returns the passed map, to test asynchronous serialization and deserialization.
  @async
  Map<String?, Object?> echoAsyncMap(Map<String?, Object?> aMap);

  /// Returns the passed enum, to test asynchronous serialization and deserialization.
  @async
  ProxyApiTestEnum echoAsyncEnum(ProxyApiTestEnum anEnum);

  /// Responds with an error from an async function returning a value.
  @async
  Object? throwAsyncError();

  /// Responds with an error from an async void function.
  @async
  void throwAsyncErrorFromVoid();

  /// Responds with a Flutter error from an async function returning a value.
  @async
  Object? throwAsyncFlutterError();

  /// Returns passed in int asynchronously.
  @async
  int? echoAsyncNullableInt(int? anInt);

  /// Returns passed in double asynchronously.
  @async
  double? echoAsyncNullableDouble(double? aDouble);

  /// Returns the passed in boolean asynchronously.
  @async
  bool? echoAsyncNullableBool(bool? aBool);

  /// Returns the passed string asynchronously.
  @async
  String? echoAsyncNullableString(String? aString);

  /// Returns the passed in Uint8List asynchronously.
  @async
  Uint8List? echoAsyncNullableUint8List(Uint8List? aUint8List);

  /// Returns the passed in generic Object asynchronously.
  @async
  Object? echoAsyncNullableObject(Object? anObject);

  /// Returns the passed list, to test asynchronous serialization and deserialization.
  @async
  List<Object?>? echoAsyncNullableList(List<Object?>? aList);

  /// Returns the passed map, to test asynchronous serialization and deserialization.
  @async
  Map<String?, Object?>? echoAsyncNullableMap(Map<String?, Object?>? aMap);

  /// Returns the passed enum, to test asynchronous serialization and deserialization.
  @async
  ProxyApiTestEnum? echoAsyncNullableEnum(ProxyApiTestEnum? anEnum);

  // ========== Static method test ==========

  @static
  void staticNoop();

  @static
  String echoStaticString(String aString);

  @static
  @async
  void staticAsyncNoop();

  // ========== Flutter methods test wrappers ==========

  @async
  void callFlutterNoop();

  @async
  Object? callFlutterThrowError();

  @async
  void callFlutterThrowErrorFromVoid();

  @async
  bool callFlutterEchoBool(bool aBool);

  @async
  int callFlutterEchoInt(int anInt);

  @async
  double callFlutterEchoDouble(double aDouble);

  @async
  String callFlutterEchoString(String aString);

  @async
  Uint8List callFlutterEchoUint8List(Uint8List aUint8List);

  @async
  List<Object?> callFlutterEchoList(List<Object?> aList);

  @async
  List<ProxyApiTestClass?> callFlutterEchoProxyApiList(
    List<ProxyApiTestClass?> aList,
  );

  @async
  Map<String?, Object?> callFlutterEchoMap(Map<String?, Object?> aMap);

  @async
  Map<String?, ProxyApiTestClass?> callFlutterEchoProxyApiMap(
    Map<String?, ProxyApiTestClass?> aMap,
  );

  @async
  ProxyApiTestEnum callFlutterEchoEnum(ProxyApiTestEnum anEnum);

  @async
  ProxyApiSuperClass callFlutterEchoProxyApi(ProxyApiSuperClass aProxyApi);

  @async
  bool? callFlutterEchoNullableBool(bool? aBool);

  @async
  int? callFlutterEchoNullableInt(int? anInt);

  @async
  double? callFlutterEchoNullableDouble(double? aDouble);

  @async
  String? callFlutterEchoNullableString(String? aString);

  @async
  Uint8List? callFlutterEchoNullableUint8List(Uint8List? aUint8List);

  @async
  List<Object?>? callFlutterEchoNullableList(List<Object?>? aList);

  @async
  Map<String?, Object?>? callFlutterEchoNullableMap(
    Map<String?, Object?>? aMap,
  );

  @async
  ProxyApiTestEnum? callFlutterEchoNullableEnum(ProxyApiTestEnum? anEnum);

  @async
  ProxyApiSuperClass? callFlutterEchoNullableProxyApi(
    ProxyApiSuperClass? aProxyApi,
  );

  @async
  void callFlutterNoopAsync();

  @async
  String callFlutterEchoAsyncString(String aString);
}

/// ProxyApi to serve as a super class to the core ProxyApi class.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.example.test_plugin.ProxyApiSuperClass',
  ),
  swiftOptions: SwiftProxyApiOptions(name: 'ProxyApiSuperClass'),
)
abstract class ProxyApiSuperClass {
  ProxyApiSuperClass();

  void aSuperMethod();
}

/// ProxyApi to serve as an interface to the core ProxyApi class.
@ProxyApi()
abstract class ProxyApiInterface {
  late void Function()? anInterfaceMethod;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(minAndroidApi: 25),
  swiftOptions: SwiftProxyApiOptions(
    minIosApi: '15.0.0',
    minMacosApi: '10.0.0',
  ),
)
abstract class ClassWithApiRequirement {
  ClassWithApiRequirement();

  void aMethod();
}
