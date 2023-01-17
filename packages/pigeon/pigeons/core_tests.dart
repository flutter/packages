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
  AllTypes echoAllTypes(AllTypes everything);

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoAllNullableTypes:')
  AllNullableTypes? echoAllNullableTypes(AllNullableTypes? everything);

  /// Returns an error, to test error handling.
  void throwError();

  /// Returns passed in int.
  @ObjCSelector('echoInt:')
  int echoInt(int anInt);

  /// Returns passed in double.
  @ObjCSelector('echoDouble:')
  double echoDouble(double aDouble);

  /// Returns the passed in boolean.
  @ObjCSelector('echoBool:')
  bool echoBool(bool aBool);

  /// Returns the passed in string.
  @ObjCSelector('echoString:')
  String echoString(String aString);

  /// Returns the passed in Uint8List.
  @ObjCSelector('echoUint8List:')
  Uint8List echoUint8List(Uint8List aUint8List);

  /// Returns the passed in generic Object.
  @ObjCSelector('echoObject:')
  Object echoObject(Object anObject);

  // ========== Syncronous nullable method tests ==========

  /// Returns the inner `aString` value from the wrapped object, to test
  /// sending of nested objects.
  @ObjCSelector('extractNestedNullableStringFrom:')
  String? extractNestedNullableString(AllNullableTypesWrapper wrapper);

  /// Returns the inner `aString` value from the wrapped object, to test
  /// sending of nested objects.
  @ObjCSelector('createNestedObjectWithNullableString:')
  AllNullableTypesWrapper createNestedNullableString(String? nullableString);

  /// Returns passed in arguments of multiple types.
  @ObjCSelector('sendMultipleNullableTypesABool:anInt:aString:')
  AllNullableTypes sendMultipleNullableTypes(
      bool? aNullableBool, int? aNullableInt, String? aNullableString);

  /// Returns passed in int.
  @ObjCSelector('echoNullableInt:')
  int? echoNullableInt(int? aNullableInt);

  /// Returns passed in double.
  @ObjCSelector('echoNullableDouble:')
  double? echoNullableDouble(double? aNullableDouble);

  /// Returns the passed in boolean.
  @ObjCSelector('echoNullableBool:')
  bool? echoNullableBool(bool? aNullableBool);

  /// Returns the passed in string.
  @ObjCSelector('echoNullableString:')
  String? echoNullableString(String? aNullableString);

  /// Returns the passed in Uint8List.
  @ObjCSelector('echoNullableUint8List:')
  Uint8List? echoNullableUint8List(Uint8List? aNullableUint8List);

  /// Returns the passed in generic Object.
  @ObjCSelector('echoNullableObject:')
  Object? echoNullableObject(Object? aNullableObject);

  // ========== Asyncronous method tests ==========

  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic asynchronous calling.
  @async
  void noopAsync();

  /// Returns the passed string asynchronously.
  @async
  @ObjCSelector('echoAsyncString:')
  String echoAsyncString(String aString);

  // ========== Flutter API test wrappers ==========

  @async
  void callFlutterNoop();

  @async
  @ObjCSelector('callFlutterEchoString:')
  String callFlutterEchoString(String aString);

  // TODO(stuartmorgan): Add callFlutterEchoAllTypes and the associated test
  // once either https://github.com/flutter/flutter/issues/116117 is fixed, or
  // the problematic type is moved out of AllTypes and into its own test, since
  // the type mismatch breaks the second `encode` round.

  // TODO(stuartmorgan): Fill in the rest of the callFlutterEcho* tests.
}

/// The core interface that the Dart platform_test code implements for host
/// integration tests to call into.
@FlutterApi()
abstract class FlutterIntegrationCoreApi {
  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic calling.
  void noop();

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoAllTypes:')
  AllTypes echoAllTypes(AllTypes everything);

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoAllNullableTypes:')
  AllNullableTypes echoAllNullableTypes(AllNullableTypes everything);

  /// Returns passed in arguments of multiple types.
  ///
  /// Tests multiple-arity FlutterApi handling.
  @ObjCSelector('sendMultipleNullableTypesABool:anInt:aString:')
  AllNullableTypes sendMultipleNullableTypes(
      bool? aNullableBool, int? aNullableInt, String? aNullableString);

  // ========== Non-nullable argument/return type tests ==========

  /// Returns the passed boolean, to test serialization and deserialization.
  @ObjCSelector('echoBool:')
  bool echoBool(bool aBool);

  /// Returns the passed int, to test serialization and deserialization.
  @ObjCSelector('echoInt:')
  int echoInt(int anInt);

  /// Returns the passed double, to test serialization and deserialization.
  @ObjCSelector('echoDouble:')
  double echoDouble(double aDouble);

  /// Returns the passed string, to test serialization and deserialization.
  @ObjCSelector('echoString:')
  String echoString(String aString);

  /// Returns the passed byte list, to test serialization and deserialization.
  @ObjCSelector('echoUint8List:')
  Uint8List echoUint8List(Uint8List aList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoList:')
  List<Object?> echoList(List<Object?> aList);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoMap:')
  Map<String?, Object?> echoMap(Map<String?, Object?> aMap);

  // ========== Nullable argument/return type tests ==========

  /// Returns the passed boolean, to test serialization and deserialization.
  @ObjCSelector('echoNullableBool:')
  bool? echoNullableBool(bool? aBool);

  /// Returns the passed int, to test serialization and deserialization.
  @ObjCSelector('echoNullableInt:')
  int? echoNullableInt(int? anInt);

  /// Returns the passed double, to test serialization and deserialization.
  @ObjCSelector('echoNullableDouble:')
  double? echoNullableDouble(double? aDouble);

  /// Returns the passed string, to test serialization and deserialization.
  @ObjCSelector('echoNullableString:')
  String? echoNullableString(String? aString);

  /// Returns the passed byte list, to test serialization and deserialization.
  @ObjCSelector('echoNullableUint8List:')
  Uint8List? echoNullableUint8List(Uint8List? aList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableList:')
  List<Object?>? echoNullableList(List<Object?>? aList);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableMap:')
  Map<String?, Object?> echoNullableMap(Map<String?, Object?> aMap);
}

/// An API that can be implemented for minimal, compile-only tests.
@HostApi()
abstract class HostTrivialApi {
  void noop();
}
