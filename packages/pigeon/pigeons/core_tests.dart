// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

enum AnEnum {
  one,
  two,
  three,
}

// A class containing all supported types.
class AllTypes {
  AllTypes({
    this.aBool = false,
    this.anInt = 0,
    this.aDouble = 0,
    required this.aByteArray,
    required this.a4ByteArray,
    required this.a8ByteArray,
    required this.aFloatArray,
    this.aList = const <Object?>[],
    this.aMap = const <String?, Object?>{},
    this.anEnum = AnEnum.one,
    this.aString = '',
  });

  bool aBool;
  int anInt;
  double aDouble;
  Uint8List aByteArray;
  Int32List a4ByteArray;
  Int64List a8ByteArray;
  Float64List aFloatArray;
  // ignore: always_specify_types, strict_raw_type
  List aList;
  // ignore: always_specify_types, strict_raw_type
  Map aMap;
  AnEnum anEnum;
  String aString;
}

// A class containing all supported nullable types.
class AllNullableTypes {
  AllNullableTypes(
    this.aNullableBool,
    this.aNullableInt,
    this.aNullableDouble,
    this.aNullableByteArray,
    this.aNullable4ByteArray,
    this.aNullable8ByteArray,
    this.aNullableFloatArray,
    this.aNullableList,
    this.aNullableMap,
    this.nullableNestedList,
    this.nullableMapWithAnnotations,
    this.nullableMapWithObject,
    this.aNullableEnum,
    this.aNullableString,
  );

  bool? aNullableBool;
  int? aNullableInt;
  double? aNullableDouble;
  Uint8List? aNullableByteArray;
  Int32List? aNullable4ByteArray;
  Int64List? aNullable8ByteArray;
  Float64List? aNullableFloatArray;
  // ignore: always_specify_types, strict_raw_type
  List? aNullableList;
  // ignore: always_specify_types, strict_raw_type
  Map? aNullableMap;
  List<List<bool?>?>? nullableNestedList;
  Map<String?, String?>? nullableMapWithAnnotations;
  Map<String?, Object?>? nullableMapWithObject;
  AnEnum? aNullableEnum;
  String? aNullableString;
}

// A class for testing nested object handling.
class AllNullableTypesWrapper {
  AllNullableTypesWrapper(this.values);
  AllNullableTypes values;
}

/// The core interface that each host language plugin must implement in
/// platform_test integration tests.
@HostApi()
abstract class HostIntegrationCoreApi {
  // ========== Syncronous method tests ==========

  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic calling.
  void noop();

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoAllTypes:')
  @SwiftFunction('echo(_:)')
  AllTypes echoAllTypes(AllTypes everything);

  /// Returns an error, to test error handling.
  Object? throwError();

  /// Responds with an error from an async void function.
  void throwErrorFromVoid();

  /// Returns passed in int.
  @ObjCSelector('echoInt:')
  @SwiftFunction('echo(_:)')
  int echoInt(int anInt);

  /// Returns passed in double.
  @ObjCSelector('echoDouble:')
  @SwiftFunction('echo(_:)')
  double echoDouble(double aDouble);

  /// Returns the passed in boolean.
  @ObjCSelector('echoBool:')
  @SwiftFunction('echo(_:)')
  bool echoBool(bool aBool);

  /// Returns the passed in string.
  @ObjCSelector('echoString:')
  @SwiftFunction('echo(_:)')
  String echoString(String aString);

  /// Returns the passed in Uint8List.
  @ObjCSelector('echoUint8List:')
  @SwiftFunction('echo(_:)')
  Uint8List echoUint8List(Uint8List aUint8List);

  /// Returns the passed in generic Object.
  @ObjCSelector('echoObject:')
  @SwiftFunction('echo(_:)')
  Object echoObject(Object anObject);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoList:')
  @SwiftFunction('echo(_:)')
  List<Object?> echoList(List<Object?> aList);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoMap:')
  @SwiftFunction('echo(_:)')
  Map<String?, Object?> echoMap(Map<String?, Object?> aMap);

  // ========== Syncronous nullable method tests ==========

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoAllNullableTypes:')
  @SwiftFunction('echo(_:)')
  AllNullableTypes? echoAllNullableTypes(AllNullableTypes? everything);

  /// Returns the inner `aString` value from the wrapped object, to test
  /// sending of nested objects.
  @ObjCSelector('extractNestedNullableStringFrom:')
  @SwiftFunction('extractNestedNullableString(from:)')
  String? extractNestedNullableString(AllNullableTypesWrapper wrapper);

  /// Returns the inner `aString` value from the wrapped object, to test
  /// sending of nested objects.
  @ObjCSelector('createNestedObjectWithNullableString:')
  @SwiftFunction('createNestedObject(with:)')
  AllNullableTypesWrapper createNestedNullableString(String? nullableString);

  /// Returns passed in arguments of multiple types.
  @ObjCSelector('sendMultipleNullableTypesABool:anInt:aString:')
  @SwiftFunction('sendMultipleNullableTypes(aBool:anInt:aString:)')
  AllNullableTypes sendMultipleNullableTypes(
      bool? aNullableBool, int? aNullableInt, String? aNullableString);

  /// Returns passed in int.
  @ObjCSelector('echoNullableInt:')
  @SwiftFunction('echo(_:)')
  int? echoNullableInt(int? aNullableInt);

  /// Returns passed in double.
  @ObjCSelector('echoNullableDouble:')
  @SwiftFunction('echo(_:)')
  double? echoNullableDouble(double? aNullableDouble);

  /// Returns the passed in boolean.
  @ObjCSelector('echoNullableBool:')
  @SwiftFunction('echo(_:)')
  bool? echoNullableBool(bool? aNullableBool);

  /// Returns the passed in string.
  @ObjCSelector('echoNullableString:')
  @SwiftFunction('echo(_:)')
  String? echoNullableString(String? aNullableString);

  /// Returns the passed in Uint8List.
  @ObjCSelector('echoNullableUint8List:')
  @SwiftFunction('echo(_:)')
  Uint8List? echoNullableUint8List(Uint8List? aNullableUint8List);

  /// Returns the passed in generic Object.
  @ObjCSelector('echoNullableObject:')
  @SwiftFunction('echo(_:)')
  Object? echoNullableObject(Object? aNullableObject);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableList:')
  @SwiftFunction('echoNullable(_:)')
  List<Object?>? echoNullableList(List<Object?>? aNullableList);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableMap:')
  @SwiftFunction('echoNullable(_:)')
  Map<String?, Object?>? echoNullableMap(Map<String?, Object?>? aNullableMap);

  // ========== Asyncronous method tests ==========

  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic asynchronous calling.
  @async
  void noopAsync();

  /// Returns passed in int asynchronously.
  @async
  @ObjCSelector('echoAsyncInt:')
  @SwiftFunction('echoAsync(_:)')
  int echoAsyncInt(int anInt);

  /// Returns passed in double asynchronously.
  @async
  @ObjCSelector('echoAsyncDouble:')
  @SwiftFunction('echoAsync(_:)')
  double echoAsyncDouble(double aDouble);

  /// Returns the passed in boolean asynchronously.
  @async
  @ObjCSelector('echoAsyncBool:')
  @SwiftFunction('echoAsync(_:)')
  bool echoAsyncBool(bool aBool);

  /// Returns the passed string asynchronously.
  @async
  @ObjCSelector('echoAsyncString:')
  @SwiftFunction('echoAsync(_:)')
  String echoAsyncString(String aString);

  /// Returns the passed in Uint8List asynchronously.
  @async
  @ObjCSelector('echoAsyncUint8List:')
  @SwiftFunction('echoAsync(_:)')
  Uint8List echoAsyncUint8List(Uint8List aUint8List);

  /// Returns the passed in generic Object asynchronously.
  @async
  @ObjCSelector('echoAsyncObject:')
  @SwiftFunction('echoAsync(_:)')
  Object echoAsyncObject(Object anObject);

  /// Returns the passed list, to test serialization and deserialization asynchronously.
  @async
  @ObjCSelector('echoAsyncList:')
  @SwiftFunction('echoAsync(_:)')
  List<Object?> echoAsyncList(List<Object?> aList);

  /// Returns the passed map, to test serialization and deserialization asynchronously.
  @async
  @ObjCSelector('echoAsyncMap:')
  @SwiftFunction('echoAsync(_:)')
  Map<String?, Object?> echoAsyncMap(Map<String?, Object?> aMap);

  /// Responds with an error from an async function returning a value.
  @async
  Object? throwAsyncError();

  /// Responds with an error from an async void function.
  @async
  void throwAsyncErrorFromVoid();

  /// Returns the passed object, to test async serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncAllTypes:')
  @SwiftFunction('echoAsync(_:)')
  AllTypes echoAsyncAllTypes(AllTypes everything);

  /// Returns the passed object, to test serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableAllNullableTypes:')
  @SwiftFunction('echoAsync(_:)')
  AllNullableTypes? echoAsyncNullableAllNullableTypes(
      AllNullableTypes? everything);

  /// Returns passed in int asynchronously.
  @async
  @ObjCSelector('echoAsyncNullableInt:')
  @SwiftFunction('echoAsyncNullable(_:)')
  int? echoAsyncNullableInt(int? anInt);

  /// Returns passed in double asynchronously.
  @async
  @ObjCSelector('echoAsyncNullableDouble:')
  @SwiftFunction('echoAsyncNullable(_:)')
  double? echoAsyncNullableDouble(double? aDouble);

  /// Returns the passed in boolean asynchronously.
  @async
  @ObjCSelector('echoAsyncNullableBool:')
  @SwiftFunction('echoAsyncNullable(_:)')
  bool? echoAsyncNullableBool(bool? aBool);

  /// Returns the passed string asynchronously.
  @async
  @ObjCSelector('echoAsyncNullableString:')
  @SwiftFunction('echoAsyncNullable(_:)')
  String? echoAsyncNullableString(String? aString);

  /// Returns the passed in Uint8List asynchronously.
  @async
  @ObjCSelector('echoAsyncNullableUint8List:')
  @SwiftFunction('echoAsyncNullable(_:)')
  Uint8List? echoAsyncNullableUint8List(Uint8List? aUint8List);

  /// Returns the passed in generic Object asynchronously.
  @async
  @ObjCSelector('echoAsyncNullableObject:')
  @SwiftFunction('echoAsyncNullable(_:)')
  Object? echoAsyncNullableObject(Object? anObject);

  /// Returns the passed list, to test serialization and deserialization asynchronously.
  @async
  @ObjCSelector('echoAsyncNullableList:')
  @SwiftFunction('echoAsyncNullable(_:)')
  List<Object?>? echoAsyncNullableList(List<Object?>? aList);

  /// Returns the passed map, to test serialization and deserialization asynchronously.
  @async
  @ObjCSelector('echoAsyncNullableMap:')
  @SwiftFunction('echAsyncoNullable(_:)')
  Map<String?, Object?>? echoAsyncNullableMap(Map<String?, Object?>? aMap);

  // ========== Flutter API test wrappers ==========

  @async
  void callFlutterNoop();

  @async
  Object? callFlutterThrowError();

  @async
  void callFlutterThrowErrorFromVoid();

  @async
  @ObjCSelector('callFlutterEchoAllTypes:')
  @SwiftFunction('callFlutterEcho(_:)')
  AllTypes callFlutterEchoAllTypes(AllTypes everything);

  // TODO(stuartmorgan): Add callFlutterEchoAllNullableTypes and the associated
  // test once either https://github.com/flutter/flutter/issues/116117 is fixed,
  // or the problematic type is moved out of AllNullableTypes and into its own
  // test, since the type mismatch breaks the second `encode` round.

  @async
  @ObjCSelector('callFlutterSendMultipleNullableTypesABool:anInt:aString:')
  @SwiftFunction('callFlutterSendMultipleNullableTypes(aBool:anInt:aString:)')
  AllNullableTypes callFlutterSendMultipleNullableTypes(
      bool? aNullableBool, int? aNullableInt, String? aNullableString);

  @async
  @ObjCSelector('callFlutterEchoBool:')
  @SwiftFunction('callFlutterEcho(_:)')
  bool callFlutterEchoBool(bool aBool);

  @async
  @ObjCSelector('callFlutterEchoInt:')
  @SwiftFunction('callFlutterEcho(_:)')
  int callFlutterEchoInt(int anInt);

  @async
  @ObjCSelector('callFlutterEchoDouble:')
  @SwiftFunction('callFlutterEcho(_:)')
  double callFlutterEchoDouble(double aDouble);

  @async
  @ObjCSelector('callFlutterEchoString:')
  @SwiftFunction('callFlutterEcho(_:)')
  String callFlutterEchoString(String aString);

  @async
  @ObjCSelector('callFlutterEchoUint8List:')
  @SwiftFunction('callFlutterEcho(_:)')
  Uint8List callFlutterEchoUint8List(Uint8List aList);

  @async
  @ObjCSelector('callFlutterEchoList:')
  @SwiftFunction('callFlutterEcho(_:)')
  List<Object?> callFlutterEchoList(List<Object?> aList);

  @async
  @ObjCSelector('callFlutterEchoMap:')
  @SwiftFunction('callFlutterEcho(_:)')
  Map<String?, Object?> callFlutterEchoMap(Map<String?, Object?> aMap);

  @async
  @ObjCSelector('callFlutterEchoNullableBool:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  bool? callFlutterEchoNullableBool(bool? aBool);

  @async
  @ObjCSelector('callFlutterEchoNullableInt:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  int? callFlutterEchoNullableInt(int? anInt);

  @async
  @ObjCSelector('callFlutterEchoNullableDouble:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  double? callFlutterEchoNullableDouble(double? aDouble);

  @async
  @ObjCSelector('callFlutterEchoNullableString:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  String? callFlutterEchoNullableString(String? aString);

  @async
  @ObjCSelector('callFlutterEchoNullableUint8List:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  Uint8List? callFlutterEchoNullableUint8List(Uint8List? aList);

  @async
  @ObjCSelector('callFlutterEchoNullableList:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  List<Object?>? callFlutterEchoNullableList(List<Object?>? aList);

  @async
  @ObjCSelector('callFlutterEchoNullableMap:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  Map<String?, Object?>? callFlutterEchoNullableMap(
      Map<String?, Object?>? aMap);
}

/// The core interface that the Dart platform_test code implements for host
/// integration tests to call into.
@FlutterApi()
abstract class FlutterIntegrationCoreApi {
  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic calling.
  void noop();

  /// Responds with an error from an async function returning a value.
  Object? throwError();

  /// Responds with an error from an async void function.
  void throwErrorFromVoid();

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoAllTypes:')
  @SwiftFunction('echo(_:)')
  AllTypes echoAllTypes(AllTypes everything);

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoAllNullableTypes:')
  @SwiftFunction('echoNullable(_:)')
  AllNullableTypes echoAllNullableTypes(AllNullableTypes everything);

  /// Returns passed in arguments of multiple types.
  ///
  /// Tests multiple-arity FlutterApi handling.
  @ObjCSelector('sendMultipleNullableTypesABool:anInt:aString:')
  @SwiftFunction('sendMultipleNullableTypes(aBool:anInt:aString:)')
  AllNullableTypes sendMultipleNullableTypes(
      bool? aNullableBool, int? aNullableInt, String? aNullableString);

  // ========== Non-nullable argument/return type tests ==========

  /// Returns the passed boolean, to test serialization and deserialization.
  @ObjCSelector('echoBool:')
  @SwiftFunction('echo(_:)')
  bool echoBool(bool aBool);

  /// Returns the passed int, to test serialization and deserialization.
  @ObjCSelector('echoInt:')
  @SwiftFunction('echo(_:)')
  int echoInt(int anInt);

  /// Returns the passed double, to test serialization and deserialization.
  @ObjCSelector('echoDouble:')
  @SwiftFunction('echo(_:)')
  double echoDouble(double aDouble);

  /// Returns the passed string, to test serialization and deserialization.
  @ObjCSelector('echoString:')
  @SwiftFunction('echo(_:)')
  String echoString(String aString);

  /// Returns the passed byte list, to test serialization and deserialization.
  @ObjCSelector('echoUint8List:')
  @SwiftFunction('echo(_:)')
  Uint8List echoUint8List(Uint8List aList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoList:')
  @SwiftFunction('echo(_:)')
  List<Object?> echoList(List<Object?> aList);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoMap:')
  @SwiftFunction('echo(_:)')
  Map<String?, Object?> echoMap(Map<String?, Object?> aMap);

  // ========== Nullable argument/return type tests ==========

  /// Returns the passed boolean, to test serialization and deserialization.
  @ObjCSelector('echoNullableBool:')
  @SwiftFunction('echoNullable(_:)')
  bool? echoNullableBool(bool? aBool);

  /// Returns the passed int, to test serialization and deserialization.
  @ObjCSelector('echoNullableInt:')
  @SwiftFunction('echoNullable(_:)')
  int? echoNullableInt(int? anInt);

  /// Returns the passed double, to test serialization and deserialization.
  @ObjCSelector('echoNullableDouble:')
  @SwiftFunction('echoNullable(_:)')
  double? echoNullableDouble(double? aDouble);

  /// Returns the passed string, to test serialization and deserialization.
  @ObjCSelector('echoNullableString:')
  @SwiftFunction('echoNullable(_:)')
  String? echoNullableString(String? aString);

  /// Returns the passed byte list, to test serialization and deserialization.
  @ObjCSelector('echoNullableUint8List:')
  @SwiftFunction('echoNullable(_:)')
  Uint8List? echoNullableUint8List(Uint8List? aList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableList:')
  @SwiftFunction('echoNullable(_:)')
  List<Object?>? echoNullableList(List<Object?>? aList);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableMap:')
  @SwiftFunction('echoNullable(_:)')
  Map<String?, Object?>? echoNullableMap(Map<String?, Object?>? aMap);
}

/// An API that can be implemented for minimal, compile-only tests.
@HostApi()
abstract class HostTrivialApi {
  void noop();
}
