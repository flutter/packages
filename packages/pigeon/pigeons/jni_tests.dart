// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: always_specify_types, strict_raw_type

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOptions: DartOptions(
    useJni: true,
    useFfi: true,
  ),
  kotlinOptions: KotlinOptions(useJni: true),
  swiftOptions: SwiftOptions(useFfi: true),
))
enum JniAnEnum {
  one,
  two,
  three,
  fortyTwo,
  fourHundredTwentyTwo,
}

// Enums require special logic, having multiple ensures that the logic can be
// replicated without collision.
enum JniAnotherEnum {
  justInCase,
}

// This exists to show that unused data classes still generate.
class JniUnusedClass {
  JniUnusedClass({this.aField});

  Object? aField;
}

/// A class containing all supported types.
class JniAllTypes {
  JniAllTypes({
    this.aBool = false,
    this.anInt = 0,
    this.anInt64 = 0,
    this.aDouble = 0,
    required this.aByteArray,
    required this.a4ByteArray,
    required this.a8ByteArray,
    required this.aFloatArray,
    this.anEnum = JniAnEnum.one,
    this.anotherEnum = JniAnotherEnum.justInCase,
    this.aString = '',
    this.anObject = 0,

    // Lists
    // This name is in a different format than the others to ensure that name
    // collision with the word 'list' doesn't occur in the generated files.
    required this.list,
    required this.stringList,
    required this.intList,
    required this.doubleList,
    required this.boolList,
    required this.enumList,
    required this.objectList,
    required this.listList,
    required this.mapList,

    // Maps
    required this.map,
    required this.stringMap,
    required this.intMap,
    required this.enumMap,
    required this.objectMap,
    required this.listMap,
    required this.mapMap,
  });

  bool aBool;
  int anInt;
  int anInt64;
  double aDouble;
  Uint8List aByteArray;
  Int32List a4ByteArray;
  Int64List a8ByteArray;
  Float64List aFloatArray;
  JniAnEnum anEnum;
  JniAnotherEnum anotherEnum;
  String aString;
  Object anObject;

  // Lists
  List list;
  List<String> stringList;
  List<int> intList;
  List<double> doubleList;
  List<bool> boolList;
  List<JniAnEnum> enumList;
  List<Object> objectList;
  List<List<Object?>> listList;
  List<Map<Object?, Object?>> mapList;

  // Maps
  Map map;
  Map<String, String> stringMap;
  Map<int, int> intMap;
  Map<JniAnEnum, JniAnEnum> enumMap;
  Map<Object, Object> objectMap;
  Map<int, List<Object?>> listMap;
  Map<int, Map<Object?, Object?>> mapMap;
}

/// A class containing all supported nullable types.
@SwiftClass()
class JniAllNullableTypes {
  JniAllNullableTypes(
    this.aNullableBool,
    this.aNullableInt,
    this.aNullableInt64,
    this.aNullableDouble,
    this.aNullableByteArray,
    this.aNullable4ByteArray,
    this.aNullable8ByteArray,
    this.aNullableFloatArray,
    this.aNullableEnum,
    this.anotherNullableEnum,
    this.aNullableString,
    this.aNullableObject,
    this.allNullableTypes,

    // Lists
    // This name is in a different format than the others to ensure that name
    // collision with the word 'list' doesn't occur in the generated files.
    this.list,
    this.stringList,
    this.intList,
    this.doubleList,
    this.boolList,
    this.enumList,
    this.objectList,
    this.listList,
    this.mapList,
    this.recursiveClassList,

    // Maps
    this.map,
    this.stringMap,
    this.intMap,
    this.enumMap,
    this.objectMap,
    this.listMap,
    this.mapMap,
    this.recursiveClassMap,
  );

  bool? aNullableBool;
  int? aNullableInt;
  int? aNullableInt64;
  double? aNullableDouble;
  Uint8List? aNullableByteArray;
  Int32List? aNullable4ByteArray;
  Int64List? aNullable8ByteArray;
  Float64List? aNullableFloatArray;
  JniAnEnum? aNullableEnum;
  JniAnotherEnum? anotherNullableEnum;
  String? aNullableString;
  Object? aNullableObject;
  JniAllNullableTypes? allNullableTypes;

  // Lists
  List? list;
  List<String?>? stringList;
  List<int?>? intList;
  List<double?>? doubleList;
  List<bool?>? boolList;
  List<JniAnEnum?>? enumList;
  List<Object?>? objectList;
  List<List<Object?>?>? listList;
  List<Map<Object?, Object?>?>? mapList;
  List<JniAllNullableTypes?>? recursiveClassList;

  // Maps
  Map? map;
  Map<String?, String?>? stringMap;
  Map<int?, int?>? intMap;
  Map<JniAnEnum?, JniAnEnum?>? enumMap;
  Map<Object?, Object?>? objectMap;
  Map<int?, List<Object?>?>? listMap;
  Map<int?, Map<Object?, Object?>?>? mapMap;
  Map<int?, JniAllNullableTypes?>? recursiveClassMap;
}

/// The primary purpose for this class is to ensure coverage of Swift structs
/// with nullable items, as the primary [JniAllNullableTypes] class is being used to
/// test Swift classes.
class JniAllNullableTypesWithoutRecursion {
  JniAllNullableTypesWithoutRecursion(
    this.aNullableBool,
    this.aNullableInt,
    this.aNullableInt64,
    this.aNullableDouble,
    this.aNullableByteArray,
    this.aNullable4ByteArray,
    this.aNullable8ByteArray,
    this.aNullableFloatArray,
    this.aNullableEnum,
    this.anotherNullableEnum,
    this.aNullableString,
    this.aNullableObject,

    // Lists
    // This name is in a different format than the others to ensure that name
    // collision with the word 'list' doesn't occur in the generated files.
    this.list,
    this.stringList,
    this.intList,
    this.doubleList,
    this.boolList,
    this.enumList,
    this.objectList,
    this.listList,
    this.mapList,

    // Maps
    this.map,
    this.stringMap,
    this.intMap,
    this.enumMap,
    this.objectMap,
    this.listMap,
    this.mapMap,
  );

  bool? aNullableBool;
  int? aNullableInt;
  int? aNullableInt64;
  double? aNullableDouble;
  Uint8List? aNullableByteArray;
  Int32List? aNullable4ByteArray;
  Int64List? aNullable8ByteArray;
  Float64List? aNullableFloatArray;
  JniAnEnum? aNullableEnum;
  JniAnotherEnum? anotherNullableEnum;
  String? aNullableString;
  Object? aNullableObject;

  // Lists
  List? list;
  List<String?>? stringList;
  List<int?>? intList;
  List<double?>? doubleList;
  List<bool?>? boolList;
  List<JniAnEnum?>? enumList;
  List<Object?>? objectList;
  List<List<Object?>?>? listList;
  List<Map<Object?, Object?>?>? mapList;

  // Maps
  Map? map;
  Map<String?, String?>? stringMap;
  Map<int?, int?>? intMap;
  Map<JniAnEnum?, JniAnEnum?>? enumMap;
  Map<Object?, Object?>? objectMap;
  Map<int?, List<Object?>?>? listMap;
  Map<int?, Map<Object?, Object?>?>? mapMap;
}

/// A class for testing nested class handling.
///
/// This is needed to test nested nullable and non-nullable classes,
/// `JniAllNullableTypes` is non-nullable here as it is easier to instantiate
/// than `JniAllTypes` when testing doesn't require both (ie. testing null classes).
class JniAllClassesWrapper {
  JniAllClassesWrapper(
    this.allNullableTypes,
    this.allNullableTypesWithoutRecursion,
    this.allTypes,
    this.classList,
    this.classMap,
    this.nullableClassList,
    this.nullableClassMap,
  );
  JniAllNullableTypes allNullableTypes;
  JniAllNullableTypesWithoutRecursion? allNullableTypesWithoutRecursion;
  JniAllTypes? allTypes;
  List<JniAllTypes?> classList;
  List<JniAllNullableTypesWithoutRecursion?>? nullableClassList;
  Map<int?, JniAllTypes?> classMap;
  Map<int?, JniAllNullableTypesWithoutRecursion?>? nullableClassMap;
}

/// The core interface that each host language plugin must implement in
/// platform_test integration tests.
@HostApi()
abstract class JniHostIntegrationCoreApi {
  // ========== Synchronous method tests ==========

  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic calling.
  void noop();

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoAllTypes:')
  @SwiftFunction('echo(_:)')
  JniAllTypes echoAllTypes(JniAllTypes everything);

  /// Returns an error, to test error handling.
  Object? throwError();

  /// Returns an error from a void function, to test error handling.
  void throwErrorFromVoid();

  /// Returns a Flutter error, to test error handling.
  Object? throwFlutterError();

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

  /// Returns the passed in Int32List.
  @ObjCSelector('echoInt32List:')
  @SwiftFunction('echo(_:)')
  Int32List echoInt32List(Int32List aInt32List);

  /// Returns the passed in Int64List.
  @ObjCSelector('echoInt64List:')
  @SwiftFunction('echo(_:)')
  Int64List echoInt64List(Int64List aInt64List);

  /// Returns the passed in Float64List.
  @ObjCSelector('echoFloat64List:')
  @SwiftFunction('echo(_:)')
  Float64List echoFloat64List(Float64List aFloat64List);

  /// Returns the passed in generic Object.
  @ObjCSelector('echoObject:')
  @SwiftFunction('echo(_:)')
  Object echoObject(Object anObject);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoList:')
  @SwiftFunction('echo(_:)')
  List<Object?> echoList(List<Object?> list);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoEnumList:')
  @SwiftFunction('echo(enumList:)')
  List<JniAnEnum?> echoEnumList(List<JniAnEnum?> enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoClassList:')
  @SwiftFunction('echo(classList:)')
  List<JniAllNullableTypes?> echoClassList(
      List<JniAllNullableTypes?> classList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNonNullEnumList:')
  @SwiftFunction('echoNonNull(enumList:)')
  List<JniAnEnum> echoNonNullEnumList(List<JniAnEnum> enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNonNullClassList:')
  @SwiftFunction('echoNonNull(classList:)')
  List<JniAllNullableTypes> echoNonNullClassList(
      List<JniAllNullableTypes> classList);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoMap:')
  @SwiftFunction('echo(_:)')
  Map<Object?, Object?> echoMap(Map<Object?, Object?> map);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoStringMap:')
  @SwiftFunction('echo(stringMap:)')
  Map<String?, String?> echoStringMap(Map<String?, String?> stringMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoIntMap:')
  @SwiftFunction('echo(intMap:)')
  Map<int?, int?> echoIntMap(Map<int?, int?> intMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoEnumMap:')
  @SwiftFunction('echo(enumMap:)')
  Map<JniAnEnum?, JniAnEnum?> echoEnumMap(Map<JniAnEnum?, JniAnEnum?> enumMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoClassMap:')
  @SwiftFunction('echo(classMap:)')
  Map<int?, JniAllNullableTypes?> echoClassMap(
      Map<int?, JniAllNullableTypes?> classMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNonNullStringMap:')
  @SwiftFunction('echoNonNull(stringMap:)')
  Map<String, String> echoNonNullStringMap(Map<String, String> stringMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNonNullIntMap:')
  @SwiftFunction('echoNonNull(intMap:)')
  Map<int, int> echoNonNullIntMap(Map<int, int> intMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNonNullEnumMap:')
  @SwiftFunction('echoNonNull(enumMap:)')
  Map<JniAnEnum, JniAnEnum> echoNonNullEnumMap(
      Map<JniAnEnum, JniAnEnum> enumMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNonNullClassMap:')
  @SwiftFunction('echoNonNull(classMap:)')
  Map<int, JniAllNullableTypes> echoNonNullClassMap(
      Map<int, JniAllNullableTypes> classMap);

  /// Returns the passed class to test nested class serialization and deserialization.
  @ObjCSelector('echoClassWrapper:')
  @SwiftFunction('echo(_:)')
  JniAllClassesWrapper echoClassWrapper(JniAllClassesWrapper wrapper);

  /// Returns the passed enum to test serialization and deserialization.
  @ObjCSelector('echoEnum:')
  @SwiftFunction('echo(_:)')
  JniAnEnum echoEnum(JniAnEnum anEnum);

  /// Returns the passed enum to test serialization and deserialization.
  @ObjCSelector('echoAnotherEnum:')
  @SwiftFunction('echo(_:)')
  JniAnotherEnum echoAnotherEnum(JniAnotherEnum anotherEnum);

  /// Returns the default string.
  @ObjCSelector('echoNamedDefaultString:')
  @SwiftFunction('echoNamedDefault(_:)')
  String echoNamedDefaultString({String aString = 'default'});

  /// Returns passed in double.
  @ObjCSelector('echoOptionalDefaultDouble:')
  @SwiftFunction('echoOptionalDefault(_:)')
  double echoOptionalDefaultDouble([double aDouble = 3.14]);

  /// Returns passed in int.
  @ObjCSelector('echoRequiredInt:')
  @SwiftFunction('echoRequired(_:)')
  int echoRequiredInt({required int anInt});

  // ========== Synchronous nullable method tests ==========

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoAllNullableTypes:')
  @SwiftFunction('echo(_:)')
  JniAllNullableTypes? echoAllNullableTypes(JniAllNullableTypes? everything);

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoAllNullableTypesWithoutRecursion:')
  @SwiftFunction('echo(_:)')
  JniAllNullableTypesWithoutRecursion? echoAllNullableTypesWithoutRecursion(
      JniAllNullableTypesWithoutRecursion? everything);

  /// Returns the inner `aString` value from the wrapped object, to test
  /// sending of nested objects.
  @ObjCSelector('extractNestedNullableStringFrom:')
  @SwiftFunction('extractNestedNullableString(from:)')
  String? extractNestedNullableString(JniAllClassesWrapper wrapper);

  /// Returns the inner `aString` value from the wrapped object, to test
  /// sending of nested objects.
  @ObjCSelector('createNestedObjectWithNullableString:')
  @SwiftFunction('createNestedObject(with:)')
  JniAllClassesWrapper createNestedNullableString(String? nullableString);

  /// Returns passed in arguments of multiple types.
  @ObjCSelector('sendMultipleNullableTypesABool:anInt:aString:')
  @SwiftFunction('sendMultipleNullableTypes(aBool:anInt:aString:)')
  JniAllNullableTypes sendMultipleNullableTypes(
      bool? aNullableBool, int? aNullableInt, String? aNullableString);

  /// Returns passed in arguments of multiple types.
  @ObjCSelector('sendMultipleNullableTypesWithoutRecursionABool:anInt:aString:')
  @SwiftFunction(
      'sendMultipleNullableTypesWithoutRecursion(aBool:anInt:aString:)')
  JniAllNullableTypesWithoutRecursion sendMultipleNullableTypesWithoutRecursion(
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

  /// Returns the passed in Int32List.
  @ObjCSelector('echoNullableInt32List:')
  @SwiftFunction('echo(_:)')
  Int32List? echoNullableInt32List(Int32List? aNullableInt32List);

  /// Returns the passed in Int64List.
  @ObjCSelector('echoNullableInt64List:')
  @SwiftFunction('echo(_:)')
  Int64List? echoNullableInt64List(Int64List? aNullableInt64List);

  /// Returns the passed in Float64List.
  @ObjCSelector('echoNullableFloat64List:')
  @SwiftFunction('echo(_:)')
  Float64List? echoNullableFloat64List(Float64List? aNullableFloat64List);

  /// Returns the passed in generic Object.
  @ObjCSelector('echoNullableObject:')
  @SwiftFunction('echo(_:)')
  Object? echoNullableObject(Object? aNullableObject);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableList:')
  @SwiftFunction('echoNullable(_:)')
  List<Object?>? echoNullableList(List<Object?>? aNullableList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableEnumList:')
  @SwiftFunction('echoNullable(enumList:)')
  List<JniAnEnum?>? echoNullableEnumList(List<JniAnEnum?>? enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableClassList:')
  @SwiftFunction('echoNullable(classList:)')
  List<JniAllNullableTypes?>? echoNullableClassList(
      List<JniAllNullableTypes?>? classList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullEnumList:')
  @SwiftFunction('echoNullableNonNull(enumList:)')
  List<JniAnEnum>? echoNullableNonNullEnumList(List<JniAnEnum>? enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullClassList:')
  @SwiftFunction('echoNullableNonNull(classList:)')
  List<JniAllNullableTypes>? echoNullableNonNullClassList(
      List<JniAllNullableTypes>? classList);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableMap:')
  @SwiftFunction('echoNullable(_:)')
  Map<Object?, Object?>? echoNullableMap(Map<Object?, Object?>? map);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableStringMap:')
  @SwiftFunction('echoNullable(stringMap:)')
  Map<String?, String?>? echoNullableStringMap(
      Map<String?, String?>? stringMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableIntMap:')
  @SwiftFunction('echoNullable(intMap:)')
  Map<int?, int?>? echoNullableIntMap(Map<int?, int?>? intMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableEnumMap:')
  @SwiftFunction('echoNullable(enumMap:)')
  Map<JniAnEnum?, JniAnEnum?>? echoNullableEnumMap(
      Map<JniAnEnum?, JniAnEnum?>? enumMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableClassMap:')
  @SwiftFunction('echoNullable(classMap:)')
  Map<int?, JniAllNullableTypes?>? echoNullableClassMap(
      Map<int?, JniAllNullableTypes?>? classMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullStringMap:')
  @SwiftFunction('echoNullableNonNull(stringMap:)')
  Map<String, String>? echoNullableNonNullStringMap(
      Map<String, String>? stringMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullIntMap:')
  @SwiftFunction('echoNullableNonNull(intMap:)')
  Map<int, int>? echoNullableNonNullIntMap(Map<int, int>? intMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullEnumMap:')
  @SwiftFunction('echoNullableNonNull(enumMap:)')
  Map<JniAnEnum, JniAnEnum>? echoNullableNonNullEnumMap(
      Map<JniAnEnum, JniAnEnum>? enumMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullClassMap:')
  @SwiftFunction('echoNullableNonNull(classMap:)')
  Map<int, JniAllNullableTypes>? echoNullableNonNullClassMap(
      Map<int, JniAllNullableTypes>? classMap);

  @ObjCSelector('echoNullableEnum:')
  @SwiftFunction('echoNullable(_:)')
  JniAnEnum? echoNullableEnum(JniAnEnum? anEnum);

  @ObjCSelector('echoAnotherNullableEnum:')
  @SwiftFunction('echoNullable(_:)')
  JniAnotherEnum? echoAnotherNullableEnum(JniAnotherEnum? anotherEnum);

  /// Returns passed in int.
  @ObjCSelector('echoOptionalNullableInt:')
  @SwiftFunction('echoOptional(_:)')
  int? echoOptionalNullableInt([int? aNullableInt]);

  /// Returns the passed in string.
  @ObjCSelector('echoNamedNullableString:')
  @SwiftFunction('echoNamed(_:)')
  String? echoNamedNullableString({String? aNullableString});

  // ========== Asynchronous method tests ==========

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

  /// Returns the passed in Int32List asynchronously.
  @async
  @ObjCSelector('echoAsyncInt32List:')
  @SwiftFunction('echoAsync(_:)')
  Int32List echoAsyncInt32List(Int32List aInt32List);

  /// Returns the passed in Int64List asynchronously.
  @async
  @ObjCSelector('echoAsyncInt64List:')
  @SwiftFunction('echoAsync(_:)')
  Int64List echoAsyncInt64List(Int64List aInt64List);

  /// Returns the passed in Float64List asynchronously.
  @async
  @ObjCSelector('echoAsyncFloat64List:')
  @SwiftFunction('echoAsync(_:)')
  Float64List echoAsyncFloat64List(Float64List aFloat64List);

  /// Returns the passed in generic Object asynchronously.
  @async
  @ObjCSelector('echoAsyncObject:')
  @SwiftFunction('echoAsync(_:)')
  Object echoAsyncObject(Object anObject);

  /// Returns the passed list, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncList:')
  @SwiftFunction('echoAsync(_:)')
  List<Object?> echoAsyncList(List<Object?> list);

  /// Returns the passed list, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncEnumList:')
  @SwiftFunction('echoAsync(enumList:)')
  List<JniAnEnum?> echoAsyncEnumList(List<JniAnEnum?> enumList);

  /// Returns the passed list, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncClassList:')
  @SwiftFunction('echoAsync(classList:)')
  List<JniAllNullableTypes?> echoAsyncClassList(
      List<JniAllNullableTypes?> classList);

  /// Returns the passed map, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncMap:')
  @SwiftFunction('echoAsync(_:)')
  Map<Object?, Object?> echoAsyncMap(Map<Object?, Object?> map);

  /// Returns the passed map, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncStringMap:')
  @SwiftFunction('echoAsync(stringMap:)')
  Map<String?, String?> echoAsyncStringMap(Map<String?, String?> stringMap);

  /// Returns the passed map, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncIntMap:')
  @SwiftFunction('echoAsync(intMap:)')
  Map<int?, int?> echoAsyncIntMap(Map<int?, int?> intMap);

  /// Returns the passed map, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncEnumMap:')
  @SwiftFunction('echoAsync(enumMap:)')
  Map<JniAnEnum?, JniAnEnum?> echoAsyncEnumMap(
      Map<JniAnEnum?, JniAnEnum?> enumMap);

  /// Returns the passed map, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncClassMap:')
  @SwiftFunction('echoAsync(classMap:)')
  Map<int?, JniAllNullableTypes?> echoAsyncClassMap(
      Map<int?, JniAllNullableTypes?> classMap);

  /// Returns the passed enum, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncEnum:')
  @SwiftFunction('echoAsync(_:)')
  JniAnEnum echoAsyncEnum(JniAnEnum anEnum);

  /// Returns the passed enum, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAnotherAsyncEnum:')
  @SwiftFunction('echoAsync(_:)')
  JniAnotherEnum echoAnotherAsyncEnum(JniAnotherEnum anotherEnum);

  /// Responds with an error from an async function returning a value.
  @async
  Object? throwAsyncError();

  /// Responds with an error from an async void function.
  @async
  void throwAsyncErrorFromVoid();

  /// Responds with a Flutter error from an async function returning a value.
  @async
  Object? throwAsyncFlutterError();

  /// Returns the passed object, to test async serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncJniAllTypes:')
  @SwiftFunction('echoAsync(_:)')
  JniAllTypes echoAsyncJniAllTypes(JniAllTypes everything);

  /// Returns the passed object, to test serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableJniAllNullableTypes:')
  @SwiftFunction('echoAsync(_:)')
  JniAllNullableTypes? echoAsyncNullableJniAllNullableTypes(
      JniAllNullableTypes? everything);

  /// Returns the passed object, to test serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableJniAllNullableTypesWithoutRecursion:')
  @SwiftFunction('echoAsync(_:)')
  JniAllNullableTypesWithoutRecursion?
      echoAsyncNullableJniAllNullableTypesWithoutRecursion(
          JniAllNullableTypesWithoutRecursion? everything);

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

  /// Returns the passed in Int32List asynchronously.
  @async
  @ObjCSelector('echoAsyncNullableInt32List:')
  @SwiftFunction('echoAsyncNullable(_:)')
  Int32List? echoAsyncNullableInt32List(Int32List? aInt32List);

  /// Returns the passed in Int64List asynchronously.
  @async
  @ObjCSelector('echoAsyncNullableInt64List:')
  @SwiftFunction('echoAsyncNullable(_:)')
  Int64List? echoAsyncNullableInt64List(Int64List? aInt64List);

  /// Returns the passed in Float64List asynchronously.
  @async
  @ObjCSelector('echoAsyncNullableFloat64List:')
  @SwiftFunction('echoAsyncNullable(_:)')
  Float64List? echoAsyncNullableFloat64List(Float64List? aFloat64List);

  /// Returns the passed in generic Object asynchronously.
  @async
  @ObjCSelector('echoAsyncNullableObject:')
  @SwiftFunction('echoAsyncNullable(_:)')
  Object? echoAsyncNullableObject(Object? anObject);

  /// Returns the passed list, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableList:')
  @SwiftFunction('echoAsyncNullable(_:)')
  List<Object?>? echoAsyncNullableList(List<Object?>? list);

  /// Returns the passed list, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableEnumList:')
  @SwiftFunction('echoAsyncNullable(enumList:)')
  List<JniAnEnum?>? echoAsyncNullableEnumList(List<JniAnEnum?>? enumList);

  /// Returns the passed list, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableClassList:')
  @SwiftFunction('echoAsyncNullable(classList:)')
  List<JniAllNullableTypes?>? echoAsyncNullableClassList(
      List<JniAllNullableTypes?>? classList);

  /// Returns the passed map, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableMap:')
  @SwiftFunction('echoAsyncNullable(_:)')
  Map<Object?, Object?>? echoAsyncNullableMap(Map<Object?, Object?>? map);

  /// Returns the passed map, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableStringMap:')
  @SwiftFunction('echoAsyncNullable(stringMap:)')
  Map<String?, String?>? echoAsyncNullableStringMap(
      Map<String?, String?>? stringMap);

  /// Returns the passed map, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableIntMap:')
  @SwiftFunction('echoAsyncNullable(intMap:)')
  Map<int?, int?>? echoAsyncNullableIntMap(Map<int?, int?>? intMap);

  /// Returns the passed map, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableEnumMap:')
  @SwiftFunction('echoAsyncNullable(enumMap:)')
  Map<JniAnEnum?, JniAnEnum?>? echoAsyncNullableEnumMap(
      Map<JniAnEnum?, JniAnEnum?>? enumMap);

  /// Returns the passed map, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableClassMap:')
  @SwiftFunction('echoAsyncNullable(classMap:)')
  Map<int?, JniAllNullableTypes?>? echoAsyncNullableClassMap(
      Map<int?, JniAllNullableTypes?>? classMap);

  /// Returns the passed enum, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableEnum:')
  @SwiftFunction('echoAsyncNullable(_:)')
  JniAnEnum? echoAsyncNullableEnum(JniAnEnum? anEnum);

  /// Returns the passed enum, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAnotherAsyncNullableEnum:')
  @SwiftFunction('echoAsyncNullable(_:)')
  JniAnotherEnum? echoAnotherAsyncNullableEnum(JniAnotherEnum? anotherEnum);

  void callFlutterNoop();

  Object? callFlutterThrowError();

  void callFlutterThrowErrorFromVoid();

  @ObjCSelector('callFlutterEchoAllTypes:')
  @SwiftFunction('callFlutterEcho(_:)')
  JniAllTypes callFlutterEchoJniAllTypes(JniAllTypes everything);

  @ObjCSelector('callFlutterEchoAllNullableTypes:')
  @SwiftFunction('callFlutterEcho(_:)')
  JniAllNullableTypes? callFlutterEchoJniAllNullableTypes(
      JniAllNullableTypes? everything);

  @ObjCSelector('callFlutterSendMultipleNullableTypesABool:anInt:aString:')
  @SwiftFunction('callFlutterSendMultipleNullableTypes(aBool:anInt:aString:)')
  JniAllNullableTypes callFlutterSendMultipleNullableTypes(
      bool? aNullableBool, int? aNullableInt, String? aNullableString);

  @ObjCSelector('callFlutterEchoJniAllNullableTypesWithoutRecursion:')
  @SwiftFunction('callFlutterEcho(_:)')
  JniAllNullableTypesWithoutRecursion?
      callFlutterEchoJniAllNullableTypesWithoutRecursion(
          JniAllNullableTypesWithoutRecursion? everything);

  @ObjCSelector(
      'callFlutterSendMultipleNullableTypesWithoutRecursionABool:anInt:aString:')
  @SwiftFunction(
      'callFlutterSendMultipleNullableTypesWithoutRecursion(aBool:anInt:aString:)')
  JniAllNullableTypesWithoutRecursion
      callFlutterSendMultipleNullableTypesWithoutRecursion(
          bool? aNullableBool, int? aNullableInt, String? aNullableString);

  @ObjCSelector('callFlutterEchoBool:')
  @SwiftFunction('callFlutterEcho(_:)')
  bool callFlutterEchoBool(bool aBool);

  @ObjCSelector('callFlutterEchoInt:')
  @SwiftFunction('callFlutterEcho(_:)')
  int callFlutterEchoInt(int anInt);

  @ObjCSelector('callFlutterEchoDouble:')
  @SwiftFunction('callFlutterEcho(_:)')
  double callFlutterEchoDouble(double aDouble);

  @ObjCSelector('callFlutterEchoString:')
  @SwiftFunction('callFlutterEcho(_:)')
  String callFlutterEchoString(String aString);

  @ObjCSelector('callFlutterEchoUint8List:')
  @SwiftFunction('callFlutterEcho(_:)')
  Uint8List callFlutterEchoUint8List(Uint8List list);

  @ObjCSelector('callFlutterEchoList:')
  @SwiftFunction('callFlutterEcho(_:)')
  List<Object?> callFlutterEchoList(List<Object?> list);

  @ObjCSelector('callFlutterEchoEnumList:')
  @SwiftFunction('callFlutterEcho(enumList:)')
  List<JniAnEnum?> callFlutterEchoEnumList(List<JniAnEnum?> enumList);

  @ObjCSelector('callFlutterEchoClassList:')
  @SwiftFunction('callFlutterEcho(classList:)')
  List<JniAllNullableTypes?> callFlutterEchoClassList(
      List<JniAllNullableTypes?> classList);

  @ObjCSelector('callFlutterEchoNonNullEnumList:')
  @SwiftFunction('callFlutterEchoNonNull(enumList:)')
  List<JniAnEnum> callFlutterEchoNonNullEnumList(List<JniAnEnum> enumList);

  @ObjCSelector('callFlutterEchoNonNullClassList:')
  @SwiftFunction('callFlutterEchoNonNull(classList:)')
  List<JniAllNullableTypes> callFlutterEchoNonNullClassList(
      List<JniAllNullableTypes> classList);

  @ObjCSelector('callFlutterEchoMap:')
  @SwiftFunction('callFlutterEcho(_:)')
  Map<Object?, Object?> callFlutterEchoMap(Map<Object?, Object?> map);

  @ObjCSelector('callFlutterEchoStringMap:')
  @SwiftFunction('callFlutterEcho(stringMap:)')
  Map<String?, String?> callFlutterEchoStringMap(
      Map<String?, String?> stringMap);

  @ObjCSelector('callFlutterEchoIntMap:')
  @SwiftFunction('callFlutterEcho(intMap:)')
  Map<int?, int?> callFlutterEchoIntMap(Map<int?, int?> intMap);

  @ObjCSelector('callFlutterEchoEnumMap:')
  @SwiftFunction('callFlutterEcho(enumMap:)')
  Map<JniAnEnum?, JniAnEnum?> callFlutterEchoEnumMap(
      Map<JniAnEnum?, JniAnEnum?> enumMap);

  @ObjCSelector('callFlutterEchoClassMap:')
  @SwiftFunction('callFlutterEcho(classMap:)')
  Map<int?, JniAllNullableTypes?> callFlutterEchoClassMap(
      Map<int?, JniAllNullableTypes?> classMap);

  @ObjCSelector('callFlutterEchoNonNullStringMap:')
  @SwiftFunction('callFlutterEchoNonNull(stringMap:)')
  Map<String, String> callFlutterEchoNonNullStringMap(
      Map<String, String> stringMap);

  @ObjCSelector('callFlutterEchoNonNullIntMap:')
  @SwiftFunction('callFlutterEchoNonNull(intMap:)')
  Map<int, int> callFlutterEchoNonNullIntMap(Map<int, int> intMap);

  @ObjCSelector('callFlutterEchoNonNullEnumMap:')
  @SwiftFunction('callFlutterEchoNonNull(enumMap:)')
  Map<JniAnEnum, JniAnEnum> callFlutterEchoNonNullEnumMap(
      Map<JniAnEnum, JniAnEnum> enumMap);

  @ObjCSelector('callFlutterEchoNonNullClassMap:')
  @SwiftFunction('callFlutterEchoNonNull(classMap:)')
  Map<int, JniAllNullableTypes> callFlutterEchoNonNullClassMap(
      Map<int, JniAllNullableTypes> classMap);

  @ObjCSelector('callFlutterEchoEnum:')
  @SwiftFunction('callFlutterEcho(_:)')
  JniAnEnum callFlutterEchoEnum(JniAnEnum anEnum);

  @ObjCSelector('callFlutterEchoAnotherEnum:')
  @SwiftFunction('callFlutterEcho(_:)')
  JniAnotherEnum callFlutterEchoJniAnotherEnum(JniAnotherEnum anotherEnum);

  @ObjCSelector('callFlutterEchoNullableBool:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  bool? callFlutterEchoNullableBool(bool? aBool);

  @ObjCSelector('callFlutterEchoNullableInt:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  int? callFlutterEchoNullableInt(int? anInt);

  @ObjCSelector('callFlutterEchoNullableDouble:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  double? callFlutterEchoNullableDouble(double? aDouble);

  @ObjCSelector('callFlutterEchoNullableString:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  String? callFlutterEchoNullableString(String? aString);

  @ObjCSelector('callFlutterEchoNullableUint8List:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  Uint8List? callFlutterEchoNullableUint8List(Uint8List? list);

  @ObjCSelector('callFlutterEchoNullableList:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  List<Object?>? callFlutterEchoNullableList(List<Object?>? list);

  @ObjCSelector('callFlutterEchoNullableEnumList:')
  @SwiftFunction('callFlutterEchoNullable(enumList:)')
  List<JniAnEnum?>? callFlutterEchoNullableEnumList(List<JniAnEnum?>? enumList);

  @ObjCSelector('callFlutterEchoNullableClassList:')
  @SwiftFunction('callFlutterEchoNullable(classList:)')
  List<JniAllNullableTypes?>? callFlutterEchoNullableClassList(
      List<JniAllNullableTypes?>? classList);

  @ObjCSelector('callFlutterEchoNullableNonNullEnumList:')
  @SwiftFunction('callFlutterEchoNullableNonNull(enumList:)')
  List<JniAnEnum>? callFlutterEchoNullableNonNullEnumList(
      List<JniAnEnum>? enumList);

  @ObjCSelector('callFlutterEchoNullableNonNullClassList:')
  @SwiftFunction('callFlutterEchoNullableNonNull(classList:)')
  List<JniAllNullableTypes>? callFlutterEchoNullableNonNullClassList(
      List<JniAllNullableTypes>? classList);

  @ObjCSelector('callFlutterEchoNullableMap:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  Map<Object?, Object?>? callFlutterEchoNullableMap(Map<Object?, Object?>? map);

  @ObjCSelector('callFlutterEchoNullableStringMap:')
  @SwiftFunction('callFlutterEchoNullable(stringMap:)')
  Map<String?, String?>? callFlutterEchoNullableStringMap(
      Map<String?, String?>? stringMap);

  @ObjCSelector('callFlutterEchoNullableIntMap:')
  @SwiftFunction('callFlutterEchoNullable(intMap:)')
  Map<int?, int?>? callFlutterEchoNullableIntMap(Map<int?, int?>? intMap);

  @ObjCSelector('callFlutterEchoNullableEnumMap:')
  @SwiftFunction('callFlutterEchoNullable(enumMap:)')
  Map<JniAnEnum?, JniAnEnum?>? callFlutterEchoNullableEnumMap(
      Map<JniAnEnum?, JniAnEnum?>? enumMap);

  @ObjCSelector('callFlutterEchoNullableClassMap:')
  @SwiftFunction('callFlutterEchoNullable(classMap:)')
  Map<int?, JniAllNullableTypes?>? callFlutterEchoNullableClassMap(
      Map<int?, JniAllNullableTypes?>? classMap);

  @ObjCSelector('callFlutterEchoNullableNonNullStringMap:')
  @SwiftFunction('callFlutterEchoNullableNonNull(stringMap:)')
  Map<String, String>? callFlutterEchoNullableNonNullStringMap(
      Map<String, String>? stringMap);

  @ObjCSelector('callFlutterEchoNullableNonNullIntMap:')
  @SwiftFunction('callFlutterEchoNullableNonNull(intMap:)')
  Map<int, int>? callFlutterEchoNullableNonNullIntMap(Map<int, int>? intMap);

  @ObjCSelector('callFlutterEchoNullableNonNullEnumMap:')
  @SwiftFunction('callFlutterEchoNullableNonNull(enumMap:)')
  Map<JniAnEnum, JniAnEnum>? callFlutterEchoNullableNonNullEnumMap(
      Map<JniAnEnum, JniAnEnum>? enumMap);

  @ObjCSelector('callFlutterEchoNullableNonNullClassMap:')
  @SwiftFunction('callFlutterEchoNullableNonNull(classMap:)')
  Map<int, JniAllNullableTypes>? callFlutterEchoNullableNonNullClassMap(
      Map<int, JniAllNullableTypes>? classMap);

  @ObjCSelector('callFlutterEchoNullableEnum:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  JniAnEnum? callFlutterEchoNullableEnum(JniAnEnum? anEnum);

  @ObjCSelector('callFlutterEchoAnotherNullableEnum:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  JniAnotherEnum? callFlutterEchoAnotherNullableEnum(
      JniAnotherEnum? anotherEnum);

  // @async
  // void callFlutterNoopAsync();

  // @async
  // @ObjCSelector('callFlutterEchoAsyncString:')
  // @SwiftFunction('callFlutterEchoAsyncString(_:)')
  // String callFlutterEchoAsyncString(String aString);
}

/// An API that can be implemented for minimal, compile-only tests.
//
// This is also here to test that multiple host APIs can be generated
// successfully in all languages (e.g., in Java where it requires having a
// wrapper class).
@HostApi()
abstract class JniHostTrivialApi {
  void noop();
}

/// A simple API implemented in some unit tests.
//
// This is separate from JniHostIntegrationCoreApi to avoid having to update a
// lot of unit tests every time we add something to the integration test API.
// TODO(stuartmorgan): Restructure the unit tests to reduce the number of
// different APIs we define.
@HostApi()
abstract class JniHostSmallApi {
  @async
  @ObjCSelector('echoString:')
  String echo(String aString);

  @async
  void voidVoid();
}

/// The core interface that the Dart platform_test code implements for host
/// integration tests to call into.
@FlutterApi()
abstract class JniFlutterIntegrationCoreApi {
  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic calling.
  void noop();

  /// Responds with an error from an async function returning a value.
  Object? throwError();

  /// Responds with an error from an async void function.
  void throwErrorFromVoid();

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoJniAllTypes:')
  @SwiftFunction('echo(_:)')
  JniAllTypes echoJniAllTypes(JniAllTypes everything);

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoJniAllNullableTypes:')
  @SwiftFunction('echoNullable(_:)')
  JniAllNullableTypes? echoJniAllNullableTypes(JniAllNullableTypes? everything);

  /// Returns passed in arguments of multiple types.
  ///
  /// Tests multiple-arity FlutterApi handling.
  @ObjCSelector('sendMultipleNullableTypesABool:anInt:aString:')
  @SwiftFunction('sendMultipleNullableTypes(aBool:anInt:aString:)')
  JniAllNullableTypes sendMultipleNullableTypes(
      bool? aNullableBool, int? aNullableInt, String? aNullableString);

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoJniAllNullableTypesWithoutRecursion:')
  @SwiftFunction('echoNullable(_:)')
  JniAllNullableTypesWithoutRecursion? echoJniAllNullableTypesWithoutRecursion(
      JniAllNullableTypesWithoutRecursion? everything);

  /// Returns passed in arguments of multiple types.
  ///
  /// Tests multiple-arity FlutterApi handling.
  @ObjCSelector('sendMultipleNullableTypesWithoutRecursionABool:anInt:aString:')
  @SwiftFunction(
      'sendMultipleNullableTypesWithoutRecursion(aBool:anInt:aString:)')
  JniAllNullableTypesWithoutRecursion sendMultipleNullableTypesWithoutRecursion(
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
  Uint8List echoUint8List(Uint8List list);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoList:')
  @SwiftFunction('echo(_:)')
  List<Object?> echoList(List<Object?> list);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoEnumList:')
  @SwiftFunction('echo(enumList:)')
  List<JniAnEnum?> echoEnumList(List<JniAnEnum?> enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoClassList:')
  @SwiftFunction('echo(classList:)')
  List<JniAllNullableTypes?> echoClassList(
      List<JniAllNullableTypes?> classList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNonNullEnumList:')
  @SwiftFunction('echoNonNull(enumList:)')
  List<JniAnEnum> echoNonNullEnumList(List<JniAnEnum> enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNonNullClassList:')
  @SwiftFunction('echoNonNull(classList:)')
  List<JniAllNullableTypes> echoNonNullClassList(
      List<JniAllNullableTypes> classList);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoMap:')
  @SwiftFunction('echo(_:)')
  Map<Object?, Object?> echoMap(Map<Object?, Object?> map);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoStringMap:')
  @SwiftFunction('echo(stringMap:)')
  Map<String?, String?> echoStringMap(Map<String?, String?> stringMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoIntMap:')
  @SwiftFunction('echo(intMap:)')
  Map<int?, int?> echoIntMap(Map<int?, int?> intMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoEnumMap:')
  @SwiftFunction('echo(enumMap:)')
  Map<JniAnEnum?, JniAnEnum?> echoEnumMap(Map<JniAnEnum?, JniAnEnum?> enumMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoClassMap:')
  @SwiftFunction('echo(classMap:)')
  Map<int?, JniAllNullableTypes?> echoClassMap(
      Map<int?, JniAllNullableTypes?> classMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNonNullStringMap:')
  @SwiftFunction('echoNonNull(stringMap:)')
  Map<String, String> echoNonNullStringMap(Map<String, String> stringMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNonNullIntMap:')
  @SwiftFunction('echoNonNull(intMap:)')
  Map<int, int> echoNonNullIntMap(Map<int, int> intMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNonNullEnumMap:')
  @SwiftFunction('echoNonNull(enumMap:)')
  Map<JniAnEnum, JniAnEnum> echoNonNullEnumMap(
      Map<JniAnEnum, JniAnEnum> enumMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNonNullClassMap:')
  @SwiftFunction('echoNonNull(classMap:)')
  Map<int, JniAllNullableTypes> echoNonNullClassMap(
      Map<int, JniAllNullableTypes> classMap);

  /// Returns the passed enum to test serialization and deserialization.
  @ObjCSelector('echoEnum:')
  @SwiftFunction('echo(_:)')
  JniAnEnum echoEnum(JniAnEnum anEnum);

  /// Returns the passed enum to test serialization and deserialization.
  @ObjCSelector('echoAnotherEnum:')
  @SwiftFunction('echo(_:)')
  JniAnotherEnum echoJniAnotherEnum(JniAnotherEnum anotherEnum);

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
  Uint8List? echoNullableUint8List(Uint8List? list);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableList:')
  @SwiftFunction('echoNullable(_:)')
  List<Object?>? echoNullableList(List<Object?>? list);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableEnumList:')
  @SwiftFunction('echoNullable(enumList:)')
  List<JniAnEnum?>? echoNullableEnumList(List<JniAnEnum?>? enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableClassList:')
  @SwiftFunction('echoNullable(classList:)')
  List<JniAllNullableTypes?>? echoNullableClassList(
      List<JniAllNullableTypes?>? classList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullEnumList:')
  @SwiftFunction('echoNullableNonNull(enumList:)')
  List<JniAnEnum>? echoNullableNonNullEnumList(List<JniAnEnum>? enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullClassList:')
  @SwiftFunction('echoNullableNonNull(classList:)')
  List<JniAllNullableTypes>? echoNullableNonNullClassList(
      List<JniAllNullableTypes>? classList);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableMap:')
  @SwiftFunction('echoNullable(_:)')
  Map<Object?, Object?>? echoNullableMap(Map<Object?, Object?>? map);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableStringMap:')
  @SwiftFunction('echoNullable(stringMap:)')
  Map<String?, String?>? echoNullableStringMap(
      Map<String?, String?>? stringMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableIntMap:')
  @SwiftFunction('echoNullable(intMap:)')
  Map<int?, int?>? echoNullableIntMap(Map<int?, int?>? intMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableEnumMap:')
  @SwiftFunction('echoNullable(enumMap:)')
  Map<JniAnEnum?, JniAnEnum?>? echoNullableEnumMap(
      Map<JniAnEnum?, JniAnEnum?>? enumMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableClassMap:')
  @SwiftFunction('echoNullable(classMap:)')
  Map<int?, JniAllNullableTypes?>? echoNullableClassMap(
      Map<int?, JniAllNullableTypes?>? classMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullStringMap:')
  @SwiftFunction('echoNullableNonNull(stringMap:)')
  Map<String, String>? echoNullableNonNullStringMap(
      Map<String, String>? stringMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullIntMap:')
  @SwiftFunction('echoNullableNonNull(intMap:)')
  Map<int, int>? echoNullableNonNullIntMap(Map<int, int>? intMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullEnumMap:')
  @SwiftFunction('echoNullableNonNull(enumMap:)')
  Map<JniAnEnum, JniAnEnum>? echoNullableNonNullEnumMap(
      Map<JniAnEnum, JniAnEnum>? enumMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullClassMap:')
  @SwiftFunction('echoNullableNonNull(classMap:)')
  Map<int, JniAllNullableTypes>? echoNullableNonNullClassMap(
      Map<int, JniAllNullableTypes>? classMap);

  /// Returns the passed enum to test serialization and deserialization.
  @ObjCSelector('echoNullableEnum:')
  @SwiftFunction('echoNullable(_:)')
  JniAnEnum? echoNullableEnum(JniAnEnum? anEnum);

  /// Returns the passed enum to test serialization and deserialization.
  @ObjCSelector('echoAnotherNullableEnum:')
  @SwiftFunction('echoNullable(_:)')
  JniAnotherEnum? echoAnotherNullableEnum(JniAnotherEnum? anotherEnum);

  // ========== Async tests ==========
  // These are minimal since async FlutterApi only changes Dart generation.
  // Currently they aren't integration tested, but having them here ensures
  // analysis coverage.

  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic asynchronous calling.
  // @async
  // void noopAsync();

  // /// Returns the passed in generic Object asynchronously.
  // @async
  // @ObjCSelector('echoAsyncString:')
  // @SwiftFunction('echoAsync(_:)')
  // String echoAsyncString(String aString);
}
