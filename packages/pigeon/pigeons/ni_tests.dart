// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: always_specify_types, strict_raw_type

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOptions: DartOptions(),
    kotlinOptions: KotlinOptions(useJni: true),
    swiftOptions: SwiftOptions(useFfi: true, ffiModuleName: 'test_plugin'),
  ),
)
enum NIAnEnum { one, two, three, fortyTwo, fourHundredTwentyTwo }

// Enums require special logic, having multiple ensures that the logic can be
// replicated without collision.
enum NIAnotherEnum { justInCase }

// // This exists to show that unused data classes still generate.
// class NIUnusedClass {
//   NIUnusedClass({this.aField});

//   Object? aField;
// }

/// A class containing all supported types.
class NIAllTypes {
  NIAllTypes({
    this.aBool = false,
    this.anInt = 0,
    this.anInt64 = 0,
    this.aDouble = 0,
    required this.aByteArray,
    required this.a4ByteArray,
    required this.a8ByteArray,
    required this.aFloatArray,
    this.anEnum = NIAnEnum.one,
    this.anotherEnum = NIAnotherEnum.justInCase,
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
  NIAnEnum anEnum;
  NIAnotherEnum anotherEnum;
  String aString;
  Object anObject;

  // Lists
  List list;
  List<String> stringList;
  List<int> intList;
  List<double> doubleList;
  List<bool> boolList;
  List<NIAnEnum> enumList;
  List<Object> objectList;
  List<List<Object?>> listList;
  List<Map<Object?, Object?>> mapList;

  // Maps
  Map map;
  Map<String, String> stringMap;
  Map<int, int> intMap;
  Map<NIAnEnum, NIAnEnum> enumMap;
  Map<Object, Object> objectMap;
  Map<int, List<Object?>> listMap;
  Map<int, Map<Object?, Object?>> mapMap;
}

/// A class containing all supported nullable types.
// @SwiftClass()
// class NIAllNullableTypes {
//   NIAllNullableTypes(
//     this.aNullableBool,
//     this.aNullableInt,
//     this.aNullableInt64,
//     this.aNullableDouble,
//     this.aNullableByteArray,
//     this.aNullable4ByteArray,
//     this.aNullable8ByteArray,
//     this.aNullableFloatArray,
//     this.aNullableEnum,
//     this.anotherNullableEnum,
//     this.aNullableString,
//     this.aNullableObject,
//     this.allNullableTypes,

//     // Lists
//     // This name is in a different format than the others to ensure that name
//     // collision with the word 'list' doesn't occur in the generated files.
//     this.list,
//     this.stringList,
//     this.intList,
//     this.doubleList,
//     this.boolList,
//     this.enumList,
//     this.objectList,
//     this.listList,
//     this.mapList,
//     this.recursiveClassList,

//     // Maps
//     this.map,
//     this.stringMap,
//     this.intMap,
//     this.enumMap,
//     this.objectMap,
//     this.listMap,
//     this.mapMap,
//     this.recursiveClassMap,
// );

// bool? aNullableBool;
// int? aNullableInt;
// int? aNullableInt64;
// double? aNullableDouble;
//   Uint8List? aNullableByteArray;
//   Int32List? aNullable4ByteArray;
//   Int64List? aNullable8ByteArray;
//   Float64List? aNullableFloatArray;
//   NIAnEnum? aNullableEnum;
//   NIAnotherEnum? anotherNullableEnum;
//   String? aNullableString;
//   Object? aNullableObject;
//   NIAllNullableTypes? allNullableTypes;

//   // Lists
//   List? list;
//   List<String?>? stringList;
//   List<int?>? intList;
//   List<double?>? doubleList;
//   List<bool?>? boolList;
//   List<NIAnEnum?>? enumList;
//   List<Object?>? objectList;
//   List<List<Object?>?>? listList;
//   List<Map<Object?, Object?>?>? mapList;
//   List<NIAllNullableTypes?>? recursiveClassList;

//   // Maps
//   Map? map;
//   Map<String?, String?>? stringMap;
//   Map<int?, int?>? intMap;
//   Map<NIAnEnum?, NIAnEnum?>? enumMap;
//   Map<Object?, Object?>? objectMap;
//   Map<int?, List<Object?>?>? listMap;
//   Map<int?, Map<Object?, Object?>?>? mapMap;
//   Map<int?, NIAllNullableTypes?>? recursiveClassMap;
// }

/// The primary purpose for this class is to ensure coverage of Swift structs
/// with nullable items, as the primary [NIAllNullableTypes] class is being used to
/// test Swift classes.
class NIAllNullableTypesWithoutRecursion {
  NIAllNullableTypesWithoutRecursion(
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

    //     // Lists
    //     // This name is in a different format than the others to ensure that name
    //     // collision with the word 'list' doesn't occur in the generated files.
    this.list,
    this.stringList,
    this.intList,
    this.doubleList,
    this.boolList,
    this.enumList,
    this.objectList,
    this.listList,
    this.mapList,

    //     // Maps
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
  NIAnEnum? aNullableEnum;
  NIAnotherEnum? anotherNullableEnum;
  String? aNullableString;
  Object? aNullableObject;

  //   // Lists
  List? list;
  List<String?>? stringList;
  List<int?>? intList;
  List<double?>? doubleList;
  List<bool?>? boolList;
  List<NIAnEnum?>? enumList;
  List<Object?>? objectList;
  List<List<Object?>?>? listList;
  List<Map<Object?, Object?>?>? mapList;

  //   // Maps
  Map? map;
  Map<String?, String?>? stringMap;
  Map<int?, int?>? intMap;
  Map<NIAnEnum?, NIAnEnum?>? enumMap;
  Map<Object?, Object?>? objectMap;
  Map<int?, List<Object?>?>? listMap;
  Map<int?, Map<Object?, Object?>?>? mapMap;
}

/// A class for testing nested class handling.
///
/// This is needed to test nested nullable and non-nullable classes,
/// `NIAllNullableTypes` is non-nullable here as it is easier to instantiate
/// than `NIAllTypes` when testing doesn't require both (ie. testing null classes).
class NIAllClassesWrapper {
  NIAllClassesWrapper(
    // this.allNullableTypes,
    this.allNullableTypesWithoutRecursion,
    this.allTypes,
    this.classList,
    this.nullableClassList,
    this.classMap,
    this.nullableClassMap,
  );
  // NIAllNullableTypes allNullableTypes;
  NIAllNullableTypesWithoutRecursion? allNullableTypesWithoutRecursion;
  NIAllTypes? allTypes;
  List<NIAllTypes?> classList;
  List<NIAllNullableTypesWithoutRecursion?>? nullableClassList;
  Map<int?, NIAllTypes?> classMap;
  Map<int?, NIAllNullableTypesWithoutRecursion?>? nullableClassMap;
}

/// The core interface that each host language plugin must implement in
/// platform_test integration tests.
@HostApi()
abstract class NIHostIntegrationCoreApi {
  // ========== Synchronous method tests ==========

  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic calling.
  void noop();

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoAllTypes:')
  // @SwiftFunction('echo(_:)')
  NIAllTypes echoAllTypes(NIAllTypes everything);

  // /// Returns an error, to test error handling.
  // Object? throwError();

  // /// Returns an error from a void function, to test error handling.
  // void throwErrorFromVoid();

  // /// Returns a Flutter error, to test error handling.
  // Object? throwFlutterError();

  /// Returns passed in int.
  @ObjCSelector('echoInt:')
  // @SwiftFunction('echo(_:)')
  int echoInt(int anInt);

  /// Returns passed in double.
  @ObjCSelector('echoDouble:')
  // @SwiftFunction('echo(_:)')
  double echoDouble(double aDouble);

  /// Returns the passed in boolean.
  @ObjCSelector('echoBool:')
  // @SwiftFunction('echo(_:)')
  bool echoBool(bool aBool);

  /// Returns the passed in string.
  @ObjCSelector('echoString:')
  // @SwiftFunction('echo(_:)')
  String echoString(String aString);

  /// Returns the passed in Uint8List.
  @ObjCSelector('echoUint8List:')
  // @SwiftFunction('echo(_:)')
  Uint8List echoUint8List(Uint8List aUint8List);

  /// Returns the passed in Int32List.
  @ObjCSelector('echoInt32List:')
  // @SwiftFunction('echo(_:)')
  Int32List echoInt32List(Int32List aInt32List);

  /// Returns the passed in Int64List.
  @ObjCSelector('echoInt64List:')
  // @SwiftFunction('echo(_:)')
  Int64List echoInt64List(Int64List aInt64List);

  /// Returns the passed in Float64List.
  @ObjCSelector('echoFloat64List:')
  // @SwiftFunction('echo(_:)')
  Float64List echoFloat64List(Float64List aFloat64List);

  /// Returns the passed in generic Object.
  @ObjCSelector('echoObject:')
  // @SwiftFunction('echo(_:)')
  Object echoObject(Object anObject);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoList:')
  // @SwiftFunction('echo(_:)')
  List<Object?> echoList(List<Object?> list);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoStringList:')
  // @SwiftFunction('echo(stringList:)')
  List<String?> echoStringList(List<String?> stringList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoIntList:')
  // @SwiftFunction('echo(intList:)')
  List<int?> echoIntList(List<int?> intList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoDoubleList:')
  // @SwiftFunction('echo(doubleList:)')
  List<double?> echoDoubleList(List<double?> doubleList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoBoolList:')
  // @SwiftFunction('echo(boolList:)')
  List<bool?> echoBoolList(List<bool?> boolList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoEnumList:')
  // @SwiftFunction('echo(enumList:)')
  List<NIAnEnum?> echoEnumList(List<NIAnEnum?> enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoClassList:')
  // @SwiftFunction('echo(classList:)')
  List<NIAllNullableTypesWithoutRecursion?> echoClassList(
    List<NIAllNullableTypesWithoutRecursion?> classList,
  );

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNonNullEnumList:')
  // @SwiftFunction('echoNonNull(enumList:)')
  List<NIAnEnum> echoNonNullEnumList(List<NIAnEnum> enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNonNullClassList:')
  // @SwiftFunction('echoNonNull(classList:)')
  List<NIAllNullableTypesWithoutRecursion> echoNonNullClassList(
    List<NIAllNullableTypesWithoutRecursion> classList,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoMap:')
  // @SwiftFunction('echo(_:)')
  Map<Object?, Object?> echoMap(Map<Object?, Object?> map);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoStringMap:')
  // @SwiftFunction('echo(stringMap:)')
  Map<String?, String?> echoStringMap(Map<String?, String?> stringMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoIntMap:')
  // @SwiftFunction('echo(intMap:)')
  Map<int?, int?> echoIntMap(Map<int?, int?> intMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoEnumMap:')
  // @SwiftFunction('echo(enumMap:)')
  Map<NIAnEnum?, NIAnEnum?> echoEnumMap(Map<NIAnEnum?, NIAnEnum?> enumMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoClassMap:')
  // @SwiftFunction('echo(classMap:)')
  Map<int?, NIAllNullableTypesWithoutRecursion?> echoClassMap(
    Map<int?, NIAllNullableTypesWithoutRecursion?> classMap,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNonNullStringMap:')
  // @SwiftFunction('echoNonNull(stringMap:)')
  Map<String, String> echoNonNullStringMap(Map<String, String> stringMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNonNullIntMap:')
  // @SwiftFunction('echoNonNull(intMap:)')
  Map<int, int> echoNonNullIntMap(Map<int, int> intMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNonNullEnumMap:')
  // @SwiftFunction('echoNonNull(enumMap:)')
  Map<NIAnEnum, NIAnEnum> echoNonNullEnumMap(Map<NIAnEnum, NIAnEnum> enumMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNonNullClassMap:')
  // @SwiftFunction('echoNonNull(classMap:)')
  Map<int, NIAllNullableTypesWithoutRecursion> echoNonNullClassMap(
    Map<int, NIAllNullableTypesWithoutRecursion> classMap,
  );

  /// Returns the passed class to test nested class serialization and deserialization.
  @ObjCSelector('echoClassWrapper:')
  // @SwiftFunction('echo(_:)')
  NIAllClassesWrapper echoClassWrapper(NIAllClassesWrapper wrapper);

  /// Returns the passed enum to test serialization and deserialization.
  @ObjCSelector('echoEnum:')
  // @SwiftFunction('echo(_:)')
  NIAnEnum echoEnum(NIAnEnum anEnum);

  /// Returns the passed enum to test serialization and deserialization.
  @ObjCSelector('echoAnotherEnum:')
  // @SwiftFunction('echo(_:)')
  NIAnotherEnum echoAnotherEnum(NIAnotherEnum anotherEnum);

  // /// Returns the default string.
  // @ObjCSelector('echoNamedDefaultString:')
  // @SwiftFunction('echoNamedDefault(_:)')
  // String echoNamedDefaultString({String aString = 'default'});

  // /// Returns passed in double.
  // @ObjCSelector('echoOptionalDefaultDouble:')
  // @SwiftFunction('echoOptionalDefault(_:)')
  // double echoOptionalDefaultDouble([double aDouble = 3.14]);

  // /// Returns passed in int.
  // @ObjCSelector('echoRequiredInt:')
  // @SwiftFunction('echoRequired(_:)')
  // int echoRequiredInt({required int anInt});

  // // ========== Synchronous nullable method tests ==========

  /// Returns the passed object, to test serialization and deserialization.
  // @ObjCSelector('echoAllNullableTypes:')
  // @SwiftFunction('echo(_:)')
  // NIAllNullableTypes? echoAllNullableTypes(NIAllNullableTypes? everything);

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoAllNullableTypesWithoutRecursion:')
  // @SwiftFunction('echo(_:)')
  NIAllNullableTypesWithoutRecursion? echoAllNullableTypesWithoutRecursion(
    NIAllNullableTypesWithoutRecursion? everything,
  );

  /// Returns the inner `aString` value from the wrapped object, to test
  /// sending of nested objects.
  @ObjCSelector('extractNestedNullableStringFrom:')
  // @SwiftFunction('extractNestedNullableString(from:)')
  String? extractNestedNullableString(NIAllClassesWrapper wrapper);

  /// Returns the inner `aString` value from the wrapped object, to test
  /// sending of nested objects.
  @ObjCSelector('createNestedObjectWithNullableString:')
  // @SwiftFunction('createNestedObject(with:)')
  NIAllClassesWrapper createNestedNullableString(String? nullableString);

  // Returns passed in arguments of multiple types.
  @ObjCSelector('sendMultipleNullableTypesABool:anInt:aString:')
  // @SwiftFunction('sendMultipleNullableTypes(aBool:anInt:aString:)')
  NIAllNullableTypesWithoutRecursion sendMultipleNullableTypes(
    bool? aNullableBool,
    int? aNullableInt,
    String? aNullableString,
  );

  // /// Returns passed in arguments of multiple types.
  @ObjCSelector('sendMultipleNullableTypesWithoutRecursionABool:anInt:aString:')
  // @SwiftFunction(
  //     'sendMultipleNullableTypesWithoutRecursion(aBool:anInt:aString:)')
  NIAllNullableTypesWithoutRecursion sendMultipleNullableTypesWithoutRecursion(
    bool? aNullableBool,
    int? aNullableInt,
    String? aNullableString,
  );

  /// Returns passed in int.
  @ObjCSelector('echoNullableInt:')
  // @SwiftFunction('echo(_:)')
  int? echoNullableInt(int? aNullableInt);

  /// Returns passed in double.
  @ObjCSelector('echoNullableDouble:')
  // @SwiftFunction('echo(_:)')
  double? echoNullableDouble(double? aNullableDouble);

  /// Returns the passed in boolean.
  @ObjCSelector('echoNullableBool:')
  // @SwiftFunction('echo(_:)')
  bool? echoNullableBool(bool? aNullableBool);

  /// Returns the passed in string.
  @ObjCSelector('echoNullableString:')
  // @SwiftFunction('echo(_:)')
  String? echoNullableString(String? aNullableString);

  /// Returns the passed in Uint8List.
  @ObjCSelector('echoNullableUint8List:')
  // @SwiftFunction('echo(_:)')
  Uint8List? echoNullableUint8List(Uint8List? aNullableUint8List);

  /// Returns the passed in Int32List.
  @ObjCSelector('echoNullableInt32List:')
  // @SwiftFunction('echo(_:)')
  Int32List? echoNullableInt32List(Int32List? aNullableInt32List);

  /// Returns the passed in Int64List.
  @ObjCSelector('echoNullableInt64List:')
  // @SwiftFunction('echo(_:)')
  Int64List? echoNullableInt64List(Int64List? aNullableInt64List);

  /// Returns the passed in Float64List.
  @ObjCSelector('echoNullableFloat64List:')
  // @SwiftFunction('echo(_:)')
  Float64List? echoNullableFloat64List(Float64List? aNullableFloat64List);

  /// Returns the passed in generic Object.
  @ObjCSelector('echoNullableObject:')
  // @SwiftFunction('echo(_:)')
  Object? echoNullableObject(Object? aNullableObject);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableList:')
  // @SwiftFunction('echoNullable(_:)')
  List<Object?>? echoNullableList(List<Object?>? aNullableList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableEnumList:')
  // @SwiftFunction('echoNullable(enumList:)')
  List<NIAnEnum?>? echoNullableEnumList(List<NIAnEnum?>? enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableClassList:')
  // @SwiftFunction('echoNullable(classList:)')
  List<NIAllNullableTypesWithoutRecursion?>? echoNullableClassList(
    List<NIAllNullableTypesWithoutRecursion?>? classList,
  );

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullEnumList:')
  // @SwiftFunction('echoNullableNonNull(enumList:)')
  List<NIAnEnum>? echoNullableNonNullEnumList(List<NIAnEnum>? enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullClassList:')
  // @SwiftFunction('echoNullableNonNull(classList:)')
  List<NIAllNullableTypesWithoutRecursion>? echoNullableNonNullClassList(
    List<NIAllNullableTypesWithoutRecursion>? classList,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableMap:')
  // @SwiftFunction('echoNullable(_:)')
  Map<Object?, Object?>? echoNullableMap(Map<Object?, Object?>? map);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableStringMap:')
  // @SwiftFunction('echoNullable(stringMap:)')
  Map<String?, String?>? echoNullableStringMap(
    Map<String?, String?>? stringMap,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableIntMap:')
  // @SwiftFunction('echoNullable(intMap:)')
  Map<int?, int?>? echoNullableIntMap(Map<int?, int?>? intMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableEnumMap:')
  // @SwiftFunction('echoNullable(enumMap:)')
  Map<NIAnEnum?, NIAnEnum?>? echoNullableEnumMap(
    Map<NIAnEnum?, NIAnEnum?>? enumMap,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableClassMap:')
  // @SwiftFunction('echoNullable(classMap:)')
  Map<int?, NIAllNullableTypesWithoutRecursion?>? echoNullableClassMap(
    Map<int?, NIAllNullableTypesWithoutRecursion?>? classMap,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullStringMap:')
  // @SwiftFunction('echoNullableNonNull(stringMap:)')
  Map<String, String>? echoNullableNonNullStringMap(
    Map<String, String>? stringMap,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullIntMap:')
  // @SwiftFunction('echoNullableNonNull(intMap:)')
  Map<int, int>? echoNullableNonNullIntMap(Map<int, int>? intMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullEnumMap:')
  // @SwiftFunction('echoNullableNonNull(enumMap:)')
  Map<NIAnEnum, NIAnEnum>? echoNullableNonNullEnumMap(
    Map<NIAnEnum, NIAnEnum>? enumMap,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullClassMap:')
  // @SwiftFunction('echoNullableNonNull(classMap:)')
  Map<int, NIAllNullableTypesWithoutRecursion>? echoNullableNonNullClassMap(
    Map<int, NIAllNullableTypesWithoutRecursion>? classMap,
  );

  @ObjCSelector('echoNullableEnum:')
  // @SwiftFunction('echoNullable(_:)')
  NIAnEnum? echoNullableEnum(NIAnEnum? anEnum);

  @ObjCSelector('echoAnotherNullableEnum:')
  // @SwiftFunction('echoNullable(_:)')
  NIAnotherEnum? echoAnotherNullableEnum(NIAnotherEnum? anotherEnum);

  // /// Returns passed in int.
  // @ObjCSelector('echoOptionalNullableInt:')
  // @SwiftFunction('echoOptional(_:)')
  // int? echoOptionalNullableInt([int? aNullableInt]);

  // /// Returns the passed in string.
  // @ObjCSelector('echoNamedNullableString:')
  // @SwiftFunction('echoNamed(_:)')
  // String? echoNamedNullableString({String? aNullableString});

  // // ========== Asynchronous method tests ==========

  // /// A no-op function taking no arguments and returning no value, to sanity
  // /// test basic asynchronous calling.
  // @async
  // void noopAsync();

  // /// Returns passed in int asynchronously.
  // @async
  // @ObjCSelector('echoAsyncInt:')
  // // @SwiftFunction('echoAsync(_:)')
  // int echoAsyncInt(int anInt);

  // /// Returns passed in double asynchronously.
  // @async
  // @ObjCSelector('echoAsyncDouble:')
  // @SwiftFunction('echoAsync(_:)')
  // double echoAsyncDouble(double aDouble);

  // /// Returns the passed in boolean asynchronously.
  // @async
  // @ObjCSelector('echoAsyncBool:')
  // @SwiftFunction('echoAsync(_:)')
  // bool echoAsyncBool(bool aBool);

  // /// Returns the passed string asynchronously.
  // @async
  // @ObjCSelector('echoAsyncString:')
  // @SwiftFunction('echoAsync(_:)')
  // String echoAsyncString(String aString);

  // /// Returns the passed in Uint8List asynchronously.
  // @async
  // @ObjCSelector('echoAsyncUint8List:')
  // @SwiftFunction('echoAsync(_:)')
  // Uint8List echoAsyncUint8List(Uint8List aUint8List);

  // /// Returns the passed in Int32List asynchronously.
  // @async
  // @ObjCSelector('echoAsyncInt32List:')
  // @SwiftFunction('echoAsync(_:)')
  // Int32List echoAsyncInt32List(Int32List aInt32List);

  // /// Returns the passed in Int64List asynchronously.
  // @async
  // @ObjCSelector('echoAsyncInt64List:')
  // @SwiftFunction('echoAsync(_:)')
  // Int64List echoAsyncInt64List(Int64List aInt64List);

  // /// Returns the passed in Float64List asynchronously.
  // @async
  // @ObjCSelector('echoAsyncFloat64List:')
  // @SwiftFunction('echoAsync(_:)')
  // Float64List echoAsyncFloat64List(Float64List aFloat64List);

  // /// Returns the passed in generic Object asynchronously.
  // @async
  // @ObjCSelector('echoAsyncObject:')
  // @SwiftFunction('echoAsync(_:)')
  // Object echoAsyncObject(Object anObject);

  // /// Returns the passed list, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncList:')
  // @SwiftFunction('echoAsync(_:)')
  // List<Object?> echoAsyncList(List<Object?> list);

  // /// Returns the passed list, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncEnumList:')
  // @SwiftFunction('echoAsync(enumList:)')
  // List<NIAnEnum?> echoAsyncEnumList(List<NIAnEnum?> enumList);

  // /// Returns the passed list, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncClassList:')
  // @SwiftFunction('echoAsync(classList:)')
  // List<NIAllNullableTypes?> echoAsyncClassList(
  //     List<NIAllNullableTypes?> classList);

  // /// Returns the passed map, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncMap:')
  // @SwiftFunction('echoAsync(_:)')
  // Map<Object?, Object?> echoAsyncMap(Map<Object?, Object?> map);

  // /// Returns the passed map, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncStringMap:')
  // @SwiftFunction('echoAsync(stringMap:)')
  // Map<String?, String?> echoAsyncStringMap(Map<String?, String?> stringMap);

  // /// Returns the passed map, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncIntMap:')
  // @SwiftFunction('echoAsync(intMap:)')
  // Map<int?, int?> echoAsyncIntMap(Map<int?, int?> intMap);

  // /// Returns the passed map, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncEnumMap:')
  // @SwiftFunction('echoAsync(enumMap:)')
  // Map<NIAnEnum?, NIAnEnum?> echoAsyncEnumMap(Map<NIAnEnum?, NIAnEnum?> enumMap);

  // /// Returns the passed map, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncClassMap:')
  // @SwiftFunction('echoAsync(classMap:)')
  // Map<int?, NIAllNullableTypes?> echoAsyncClassMap(
  //     Map<int?, NIAllNullableTypes?> classMap);

  // /// Returns the passed enum, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncEnum:')
  // @SwiftFunction('echoAsync(_:)')
  // NIAnEnum echoAsyncEnum(NIAnEnum anEnum);

  // /// Returns the passed enum, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAnotherAsyncEnum:')
  // @SwiftFunction('echoAsync(_:)')
  // NIAnotherEnum echoAnotherAsyncEnum(NIAnotherEnum anotherEnum);

  // /// Responds with an error from an async function returning a value.
  // @async
  // Object? throwAsyncError();

  // /// Responds with an error from an async void function.
  // @async
  // void throwAsyncErrorFromVoid();

  // /// Responds with a Flutter error from an async function returning a value.
  // @async
  // Object? throwAsyncFlutterError();

  // /// Returns the passed object, to test async serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncNIAllTypes:')
  // @SwiftFunction('echoAsync(_:)')
  // NIAllTypes echoAsyncNIAllTypes(NIAllTypes everything);

  // /// Returns the passed object, to test serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncNullableNIAllNullableTypes:')
  // @SwiftFunction('echoAsync(_:)')
  // NIAllNullableTypes? echoAsyncNullableNIAllNullableTypes(
  //     NIAllNullableTypes? everything);

  // /// Returns the passed object, to test serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncNullableNIAllNullableTypesWithoutRecursion:')
  // @SwiftFunction('echoAsync(_:)')
  // NIAllNullableTypesWithoutRecursion?
  //     echoAsyncNullableNIAllNullableTypesWithoutRecursion(
  //         NIAllNullableTypesWithoutRecursion? everything);

  // /// Returns passed in int asynchronously.
  // @async
  // @ObjCSelector('echoAsyncNullableInt:')
  // @SwiftFunction('echoAsyncNullable(_:)')
  // int? echoAsyncNullableInt(int? anInt);

  // /// Returns passed in double asynchronously.
  // @async
  // @ObjCSelector('echoAsyncNullableDouble:')
  // @SwiftFunction('echoAsyncNullable(_:)')
  // double? echoAsyncNullableDouble(double? aDouble);

  // /// Returns the passed in boolean asynchronously.
  // @async
  // @ObjCSelector('echoAsyncNullableBool:')
  // @SwiftFunction('echoAsyncNullable(_:)')
  // bool? echoAsyncNullableBool(bool? aBool);

  // /// Returns the passed string asynchronously.
  // @async
  // @ObjCSelector('echoAsyncNullableString:')
  // @SwiftFunction('echoAsyncNullable(_:)')
  // String? echoAsyncNullableString(String? aString);

  // /// Returns the passed in Uint8List asynchronously.
  // @async
  // @ObjCSelector('echoAsyncNullableUint8List:')
  // @SwiftFunction('echoAsyncNullable(_:)')
  // Uint8List? echoAsyncNullableUint8List(Uint8List? aUint8List);

  // /// Returns the passed in Int32List asynchronously.
  // @async
  // @ObjCSelector('echoAsyncNullableInt32List:')
  // @SwiftFunction('echoAsyncNullable(_:)')
  // Int32List? echoAsyncNullableInt32List(Int32List? aInt32List);

  // /// Returns the passed in Int64List asynchronously.
  // @async
  // @ObjCSelector('echoAsyncNullableInt64List:')
  // @SwiftFunction('echoAsyncNullable(_:)')
  // Int64List? echoAsyncNullableInt64List(Int64List? aInt64List);

  // /// Returns the passed in Float64List asynchronously.
  // @async
  // @ObjCSelector('echoAsyncNullableFloat64List:')
  // @SwiftFunction('echoAsyncNullable(_:)')
  // Float64List? echoAsyncNullableFloat64List(Float64List? aFloat64List);

  // /// Returns the passed in generic Object asynchronously.
  // @async
  // @ObjCSelector('echoAsyncNullableObject:')
  // @SwiftFunction('echoAsyncNullable(_:)')
  // Object? echoAsyncNullableObject(Object? anObject);

  // /// Returns the passed list, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncNullableList:')
  // @SwiftFunction('echoAsyncNullable(_:)')
  // List<Object?>? echoAsyncNullableList(List<Object?>? list);

  // /// Returns the passed list, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncNullableEnumList:')
  // @SwiftFunction('echoAsyncNullable(enumList:)')
  // List<NIAnEnum?>? echoAsyncNullableEnumList(List<NIAnEnum?>? enumList);

  // /// Returns the passed list, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncNullableClassList:')
  // @SwiftFunction('echoAsyncNullable(classList:)')
  // List<NIAllNullableTypes?>? echoAsyncNullableClassList(
  //     List<NIAllNullableTypes?>? classList);

  // /// Returns the passed map, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncNullableMap:')
  // @SwiftFunction('echoAsyncNullable(_:)')
  // Map<Object?, Object?>? echoAsyncNullableMap(Map<Object?, Object?>? map);

  // /// Returns the passed map, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncNullableStringMap:')
  // @SwiftFunction('echoAsyncNullable(stringMap:)')
  // Map<String?, String?>? echoAsyncNullableStringMap(
  //     Map<String?, String?>? stringMap);

  // /// Returns the passed map, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncNullableIntMap:')
  // @SwiftFunction('echoAsyncNullable(intMap:)')
  // Map<int?, int?>? echoAsyncNullableIntMap(Map<int?, int?>? intMap);

  // /// Returns the passed map, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncNullableEnumMap:')
  // @SwiftFunction('echoAsyncNullable(enumMap:)')
  // Map<NIAnEnum?, NIAnEnum?>? echoAsyncNullableEnumMap(
  //     Map<NIAnEnum?, NIAnEnum?>? enumMap);

  // /// Returns the passed map, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncNullableClassMap:')
  // @SwiftFunction('echoAsyncNullable(classMap:)')
  // Map<int?, NIAllNullableTypes?>? echoAsyncNullableClassMap(
  //     Map<int?, NIAllNullableTypes?>? classMap);

  // /// Returns the passed enum, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAsyncNullableEnum:')
  // @SwiftFunction('echoAsyncNullable(_:)')
  // NIAnEnum? echoAsyncNullableEnum(NIAnEnum? anEnum);

  // /// Returns the passed enum, to test asynchronous serialization and deserialization.
  // @async
  // @ObjCSelector('echoAnotherAsyncNullableEnum:')
  // @SwiftFunction('echoAsyncNullable(_:)')
  // NIAnotherEnum? echoAnotherAsyncNullableEnum(NIAnotherEnum? anotherEnum);

  // void callFlutterNoop();

  // Object? callFlutterThrowError();

  // void callFlutterThrowErrorFromVoid();

  // @ObjCSelector('callFlutterEchoAllTypes:')
  // @SwiftFunction('callFlutterEcho(_:)')
  // NIAllTypes callFlutterEchoNIAllTypes(NIAllTypes everything);

  // @ObjCSelector('callFlutterEchoAllNullableTypes:')
  // @SwiftFunction('callFlutterEcho(_:)')
  // NIAllNullableTypes? callFlutterEchoNIAllNullableTypes(
  //     NIAllNullableTypes? everything);

  // @ObjCSelector('callFlutterSendMultipleNullableTypesABool:anInt:aString:')
  // @SwiftFunction('callFlutterSendMultipleNullableTypes(aBool:anInt:aString:)')
  // NIAllNullableTypes callFlutterSendMultipleNullableTypes(
  //     bool? aNullableBool, int? aNullableInt, String? aNullableString);

  // @ObjCSelector('callFlutterEchoNIAllNullableTypesWithoutRecursion:')
  // @SwiftFunction('callFlutterEcho(_:)')
  // NIAllNullableTypesWithoutRecursion?
  //     callFlutterEchoNIAllNullableTypesWithoutRecursion(
  //         NIAllNullableTypesWithoutRecursion? everything);

  // @ObjCSelector(
  //     'callFlutterSendMultipleNullableTypesWithoutRecursionABool:anInt:aString:')
  // @SwiftFunction(
  //     'callFlutterSendMultipleNullableTypesWithoutRecursion(aBool:anInt:aString:)')
  // NIAllNullableTypesWithoutRecursion
  //     callFlutterSendMultipleNullableTypesWithoutRecursion(
  //         bool? aNullableBool, int? aNullableInt, String? aNullableString);

  // @ObjCSelector('callFlutterEchoBool:')
  // @SwiftFunction('callFlutterEcho(_:)')
  // bool callFlutterEchoBool(bool aBool);

  // @ObjCSelector('callFlutterEchoInt:')
  // @SwiftFunction('callFlutterEcho(_:)')
  // int callFlutterEchoInt(int anInt);

  // @ObjCSelector('callFlutterEchoDouble:')
  // @SwiftFunction('callFlutterEcho(_:)')
  // double callFlutterEchoDouble(double aDouble);

  // @ObjCSelector('callFlutterEchoString:')
  // @SwiftFunction('callFlutterEcho(_:)')
  // String callFlutterEchoString(String aString);

  // @ObjCSelector('callFlutterEchoUint8List:')
  // @SwiftFunction('callFlutterEcho(_:)')
  // Uint8List callFlutterEchoUint8List(Uint8List list);

  // @ObjCSelector('callFlutterEchoList:')
  // @SwiftFunction('callFlutterEcho(_:)')
  // List<Object?> callFlutterEchoList(List<Object?> list);

  // @ObjCSelector('callFlutterEchoEnumList:')
  // @SwiftFunction('callFlutterEcho(enumList:)')
  // List<NIAnEnum?> callFlutterEchoEnumList(List<NIAnEnum?> enumList);

  // @ObjCSelector('callFlutterEchoClassList:')
  // @SwiftFunction('callFlutterEcho(classList:)')
  // List<NIAllNullableTypes?> callFlutterEchoClassList(
  //     List<NIAllNullableTypes?> classList);

  // @ObjCSelector('callFlutterEchoNonNullEnumList:')
  // @SwiftFunction('callFlutterEchoNonNull(enumList:)')
  // List<NIAnEnum> callFlutterEchoNonNullEnumList(List<NIAnEnum> enumList);

  // @ObjCSelector('callFlutterEchoNonNullClassList:')
  // @SwiftFunction('callFlutterEchoNonNull(classList:)')
  // List<NIAllNullableTypes> callFlutterEchoNonNullClassList(
  //     List<NIAllNullableTypes> classList);

  // @ObjCSelector('callFlutterEchoMap:')
  // @SwiftFunction('callFlutterEcho(_:)')
  // Map<Object?, Object?> callFlutterEchoMap(Map<Object?, Object?> map);

  // @ObjCSelector('callFlutterEchoStringMap:')
  // @SwiftFunction('callFlutterEcho(stringMap:)')
  // Map<String?, String?> callFlutterEchoStringMap(
  //     Map<String?, String?> stringMap);

  // @ObjCSelector('callFlutterEchoIntMap:')
  // @SwiftFunction('callFlutterEcho(intMap:)')
  // Map<int?, int?> callFlutterEchoIntMap(Map<int?, int?> intMap);

  // @ObjCSelector('callFlutterEchoEnumMap:')
  // @SwiftFunction('callFlutterEcho(enumMap:)')
  // Map<NIAnEnum?, NIAnEnum?> callFlutterEchoEnumMap(
  //     Map<NIAnEnum?, NIAnEnum?> enumMap);

  // @ObjCSelector('callFlutterEchoClassMap:')
  // @SwiftFunction('callFlutterEcho(classMap:)')
  // Map<int?, NIAllNullableTypes?> callFlutterEchoClassMap(
  //     Map<int?, NIAllNullableTypes?> classMap);

  // @ObjCSelector('callFlutterEchoNonNullStringMap:')
  // @SwiftFunction('callFlutterEchoNonNull(stringMap:)')
  // Map<String, String> callFlutterEchoNonNullStringMap(
  //     Map<String, String> stringMap);

  // @ObjCSelector('callFlutterEchoNonNullIntMap:')
  // @SwiftFunction('callFlutterEchoNonNull(intMap:)')
  // Map<int, int> callFlutterEchoNonNullIntMap(Map<int, int> intMap);

  // @ObjCSelector('callFlutterEchoNonNullEnumMap:')
  // @SwiftFunction('callFlutterEchoNonNull(enumMap:)')
  // Map<NIAnEnum, NIAnEnum> callFlutterEchoNonNullEnumMap(
  //     Map<NIAnEnum, NIAnEnum> enumMap);

  // @ObjCSelector('callFlutterEchoNonNullClassMap:')
  // @SwiftFunction('callFlutterEchoNonNull(classMap:)')
  // Map<int, NIAllNullableTypes> callFlutterEchoNonNullClassMap(
  //     Map<int, NIAllNullableTypes> classMap);

  // @ObjCSelector('callFlutterEchoEnum:')
  // @SwiftFunction('callFlutterEcho(_:)')
  // NIAnEnum callFlutterEchoEnum(NIAnEnum anEnum);

  // @ObjCSelector('callFlutterEchoAnotherEnum:')
  // @SwiftFunction('callFlutterEcho(_:)')
  // NIAnotherEnum callFlutterEchoNIAnotherEnum(NIAnotherEnum anotherEnum);

  // @ObjCSelector('callFlutterEchoNullableBool:')
  // @SwiftFunction('callFlutterEchoNullable(_:)')
  // bool? callFlutterEchoNullableBool(bool? aBool);

  // @ObjCSelector('callFlutterEchoNullableInt:')
  // @SwiftFunction('callFlutterEchoNullable(_:)')
  // int? callFlutterEchoNullableInt(int? anInt);

  // @ObjCSelector('callFlutterEchoNullableDouble:')
  // @SwiftFunction('callFlutterEchoNullable(_:)')
  // double? callFlutterEchoNullableDouble(double? aDouble);

  // @ObjCSelector('callFlutterEchoNullableString:')
  // @SwiftFunction('callFlutterEchoNullable(_:)')
  // String? callFlutterEchoNullableString(String? aString);

  // @ObjCSelector('callFlutterEchoNullableUint8List:')
  // @SwiftFunction('callFlutterEchoNullable(_:)')
  // Uint8List? callFlutterEchoNullableUint8List(Uint8List? list);

  // @ObjCSelector('callFlutterEchoNullableList:')
  // @SwiftFunction('callFlutterEchoNullable(_:)')
  // List<Object?>? callFlutterEchoNullableList(List<Object?>? list);

  // @ObjCSelector('callFlutterEchoNullableEnumList:')
  // @SwiftFunction('callFlutterEchoNullable(enumList:)')
  // List<NIAnEnum?>? callFlutterEchoNullableEnumList(List<NIAnEnum?>? enumList);

  // @ObjCSelector('callFlutterEchoNullableClassList:')
  // @SwiftFunction('callFlutterEchoNullable(classList:)')
  // List<NIAllNullableTypes?>? callFlutterEchoNullableClassList(
  //     List<NIAllNullableTypes?>? classList);

  // @ObjCSelector('callFlutterEchoNullableNonNullEnumList:')
  // @SwiftFunction('callFlutterEchoNullableNonNull(enumList:)')
  // List<NIAnEnum>? callFlutterEchoNullableNonNullEnumList(
  //     List<NIAnEnum>? enumList);

  // @ObjCSelector('callFlutterEchoNullableNonNullClassList:')
  // @SwiftFunction('callFlutterEchoNullableNonNull(classList:)')
  // List<NIAllNullableTypes>? callFlutterEchoNullableNonNullClassList(
  //     List<NIAllNullableTypes>? classList);

  // @ObjCSelector('callFlutterEchoNullableMap:')
  // @SwiftFunction('callFlutterEchoNullable(_:)')
  // Map<Object?, Object?>? callFlutterEchoNullableMap(Map<Object?, Object?>? map);

  // @ObjCSelector('callFlutterEchoNullableStringMap:')
  // @SwiftFunction('callFlutterEchoNullable(stringMap:)')
  // Map<String?, String?>? callFlutterEchoNullableStringMap(
  //     Map<String?, String?>? stringMap);

  // @ObjCSelector('callFlutterEchoNullableIntMap:')
  // @SwiftFunction('callFlutterEchoNullable(intMap:)')
  // Map<int?, int?>? callFlutterEchoNullableIntMap(Map<int?, int?>? intMap);

  // @ObjCSelector('callFlutterEchoNullableEnumMap:')
  // @SwiftFunction('callFlutterEchoNullable(enumMap:)')
  // Map<NIAnEnum?, NIAnEnum?>? callFlutterEchoNullableEnumMap(
  //     Map<NIAnEnum?, NIAnEnum?>? enumMap);

  // @ObjCSelector('callFlutterEchoNullableClassMap:')
  // @SwiftFunction('callFlutterEchoNullable(classMap:)')
  // Map<int?, NIAllNullableTypes?>? callFlutterEchoNullableClassMap(
  //     Map<int?, NIAllNullableTypes?>? classMap);

  // @ObjCSelector('callFlutterEchoNullableNonNullStringMap:')
  // @SwiftFunction('callFlutterEchoNullableNonNull(stringMap:)')
  // Map<String, String>? callFlutterEchoNullableNonNullStringMap(
  //     Map<String, String>? stringMap);

  // @ObjCSelector('callFlutterEchoNullableNonNullIntMap:')
  // @SwiftFunction('callFlutterEchoNullableNonNull(intMap:)')
  // Map<int, int>? callFlutterEchoNullableNonNullIntMap(Map<int, int>? intMap);

  // @ObjCSelector('callFlutterEchoNullableNonNullEnumMap:')
  // @SwiftFunction('callFlutterEchoNullableNonNull(enumMap:)')
  // Map<NIAnEnum, NIAnEnum>? callFlutterEchoNullableNonNullEnumMap(
  //     Map<NIAnEnum, NIAnEnum>? enumMap);

  // @ObjCSelector('callFlutterEchoNullableNonNullClassMap:')
  // @SwiftFunction('callFlutterEchoNullableNonNull(classMap:)')
  // Map<int, NIAllNullableTypes>? callFlutterEchoNullableNonNullClassMap(
  //     Map<int, NIAllNullableTypes>? classMap);

  // @ObjCSelector('callFlutterEchoNullableEnum:')
  // @SwiftFunction('callFlutterEchoNullable(_:)')
  // NIAnEnum? callFlutterEchoNullableEnum(NIAnEnum? anEnum);

  // @ObjCSelector('callFlutterEchoAnotherNullableEnum:')
  // @SwiftFunction('callFlutterEchoNullable(_:)')
  // NIAnotherEnum? callFlutterEchoAnotherNullableEnum(NIAnotherEnum? anotherEnum);

  // // @async
  // // void callFlutterNoopAsync();

  // // @async
  // // @ObjCSelector('callFlutterEchoAsyncString:')
  // // @SwiftFunction('callFlutterEchoAsyncString(_:)')
  // // String callFlutterEchoAsyncString(String aString);
}

// /// An API that can be implemented for minimal, compile-only tests.
// //
// // This is also here to test that multiple host APIs can be generated
// // successfully in all languages (e.g., in Java where it requires having a
// // wrapper class).
// @HostApi()
// abstract class NIHostTrivialApi {
//   void noop();
// }

// /// A simple API implemented in some unit tests.
// //
// // This is separate from NIHostIntegrationCoreApi to avoid having to update a
// // lot of unit tests every time we add something to the integration test API.
// // TODO(stuartmorgan): Restructure the unit tests to reduce the number of
// // different APIs we define.
// @HostApi()
// abstract class NIHostSmallApi {
//   @async
//   @ObjCSelector('echoString:')
//   String echo(String aString);

//   @async
//   void voidVoid();
// }

// /// The core interface that the Dart platform_test code implements for host
// /// integration tests to call into.
// @FlutterApi()
// abstract class NIFlutterIntegrationCoreApi {
//   /// A no-op function taking no arguments and returning no value, to sanity
//   /// test basic calling.
//   void noop();

//   /// Responds with an error from an async function returning a value.
//   Object? throwError();

//   /// Responds with an error from an async void function.
//   void throwErrorFromVoid();

//   /// Returns the passed object, to test serialization and deserialization.
//   @ObjCSelector('echoNIAllTypes:')
//   @SwiftFunction('echo(_:)')
//   NIAllTypes echoNIAllTypes(NIAllTypes everything);

//   /// Returns the passed object, to test serialization and deserialization.
//   @ObjCSelector('echoNIAllNullableTypes:')
//   @SwiftFunction('echoNullable(_:)')
//   NIAllNullableTypes? echoNIAllNullableTypes(NIAllNullableTypes? everything);

//   /// Returns passed in arguments of multiple types.
//   ///
//   /// Tests multiple-arity FlutterApi handling.
//   @ObjCSelector('sendMultipleNullableTypesABool:anInt:aString:')
//   @SwiftFunction('sendMultipleNullableTypes(aBool:anInt:aString:)')
//   NIAllNullableTypes sendMultipleNullableTypes(
//       bool? aNullableBool, int? aNullableInt, String? aNullableString);

//   /// Returns the passed object, to test serialization and deserialization.
//   @ObjCSelector('echoNIAllNullableTypesWithoutRecursion:')
//   @SwiftFunction('echoNullable(_:)')
//   NIAllNullableTypesWithoutRecursion? echoNIAllNullableTypesWithoutRecursion(
//       NIAllNullableTypesWithoutRecursion? everything);

//   /// Returns passed in arguments of multiple types.
//   ///
//   /// Tests multiple-arity FlutterApi handling.
//   @ObjCSelector('sendMultipleNullableTypesWithoutRecursionABool:anInt:aString:')
//   @SwiftFunction(
//       'sendMultipleNullableTypesWithoutRecursion(aBool:anInt:aString:)')
//   NIAllNullableTypesWithoutRecursion sendMultipleNullableTypesWithoutRecursion(
//       bool? aNullableBool, int? aNullableInt, String? aNullableString);

//   // ========== Non-nullable argument/return type tests ==========

//   /// Returns the passed boolean, to test serialization and deserialization.
//   @ObjCSelector('echoBool:')
//   @SwiftFunction('echo(_:)')
//   bool echoBool(bool aBool);

//   /// Returns the passed int, to test serialization and deserialization.
//   @ObjCSelector('echoInt:')
//   @SwiftFunction('echo(_:)')
//   int echoInt(int anInt);

//   /// Returns the passed double, to test serialization and deserialization.
//   @ObjCSelector('echoDouble:')
//   @SwiftFunction('echo(_:)')
//   double echoDouble(double aDouble);

//   /// Returns the passed string, to test serialization and deserialization.
//   @ObjCSelector('echoString:')
//   @SwiftFunction('echo(_:)')
//   String echoString(String aString);

//   /// Returns the passed byte list, to test serialization and deserialization.
//   @ObjCSelector('echoUint8List:')
//   @SwiftFunction('echo(_:)')
//   Uint8List echoUint8List(Uint8List list);

//   /// Returns the passed list, to test serialization and deserialization.
//   @ObjCSelector('echoList:')
//   @SwiftFunction('echo(_:)')
//   List<Object?> echoList(List<Object?> list);

//   /// Returns the passed list, to test serialization and deserialization.
//   @ObjCSelector('echoEnumList:')
//   @SwiftFunction('echo(enumList:)')
//   List<NIAnEnum?> echoEnumList(List<NIAnEnum?> enumList);

//   /// Returns the passed list, to test serialization and deserialization.
//   @ObjCSelector('echoClassList:')
//   @SwiftFunction('echo(classList:)')
//   List<NIAllNullableTypes?> echoClassList(List<NIAllNullableTypes?> classList);

//   /// Returns the passed list, to test serialization and deserialization.
//   @ObjCSelector('echoNonNullEnumList:')
//   @SwiftFunction('echoNonNull(enumList:)')
//   List<NIAnEnum> echoNonNullEnumList(List<NIAnEnum> enumList);

//   /// Returns the passed list, to test serialization and deserialization.
//   @ObjCSelector('echoNonNullClassList:')
//   @SwiftFunction('echoNonNull(classList:)')
//   List<NIAllNullableTypes> echoNonNullClassList(
//       List<NIAllNullableTypes> classList);

//   /// Returns the passed map, to test serialization and deserialization.
//   @ObjCSelector('echoMap:')
//   @SwiftFunction('echo(_:)')
//   Map<Object?, Object?> echoMap(Map<Object?, Object?> map);

//   /// Returns the passed map, to test serialization and deserialization.
//   @ObjCSelector('echoStringMap:')
//   @SwiftFunction('echo(stringMap:)')
//   Map<String?, String?> echoStringMap(Map<String?, String?> stringMap);

//   /// Returns the passed map, to test serialization and deserialization.
//   @ObjCSelector('echoIntMap:')
//   @SwiftFunction('echo(intMap:)')
//   Map<int?, int?> echoIntMap(Map<int?, int?> intMap);

//   /// Returns the passed map, to test serialization and deserialization.
//   @ObjCSelector('echoEnumMap:')
//   @SwiftFunction('echo(enumMap:)')
//   Map<NIAnEnum?, NIAnEnum?> echoEnumMap(Map<NIAnEnum?, NIAnEnum?> enumMap);

//   /// Returns the passed map, to test serialization and deserialization.
//   @ObjCSelector('echoClassMap:')
//   @SwiftFunction('echo(classMap:)')
//   Map<int?, NIAllNullableTypes?> echoClassMap(
//       Map<int?, NIAllNullableTypes?> classMap);

//   /// Returns the passed map, to test serialization and deserialization.
//   @ObjCSelector('echoNonNullStringMap:')
//   @SwiftFunction('echoNonNull(stringMap:)')
//   Map<String, String> echoNonNullStringMap(Map<String, String> stringMap);

//   /// Returns the passed map, to test serialization and deserialization.
//   @ObjCSelector('echoNonNullIntMap:')
//   @SwiftFunction('echoNonNull(intMap:)')
//   Map<int, int> echoNonNullIntMap(Map<int, int> intMap);

//   /// Returns the passed map, to test serialization and deserialization.
//   @ObjCSelector('echoNonNullEnumMap:')
//   @SwiftFunction('echoNonNull(enumMap:)')
//   Map<NIAnEnum, NIAnEnum> echoNonNullEnumMap(Map<NIAnEnum, NIAnEnum> enumMap);

//   /// Returns the passed map, to test serialization and deserialization.
//   @ObjCSelector('echoNonNullClassMap:')
//   @SwiftFunction('echoNonNull(classMap:)')
//   Map<int, NIAllNullableTypes> echoNonNullClassMap(
//       Map<int, NIAllNullableTypes> classMap);

//   /// Returns the passed enum to test serialization and deserialization.
//   @ObjCSelector('echoEnum:')
//   @SwiftFunction('echo(_:)')
//   NIAnEnum echoEnum(NIAnEnum anEnum);

//   /// Returns the passed enum to test serialization and deserialization.
//   @ObjCSelector('echoAnotherEnum:')
//   @SwiftFunction('echo(_:)')
//   NIAnotherEnum echoNIAnotherEnum(NIAnotherEnum anotherEnum);

//   // ========== Nullable argument/return type tests ==========

//   /// Returns the passed boolean, to test serialization and deserialization.
//   @ObjCSelector('echoNullableBool:')
//   @SwiftFunction('echoNullable(_:)')
//   bool? echoNullableBool(bool? aBool);

//   /// Returns the passed int, to test serialization and deserialization.
//   @ObjCSelector('echoNullableInt:')
//   @SwiftFunction('echoNullable(_:)')
//   int? echoNullableInt(int? anInt);

//   /// Returns the passed double, to test serialization and deserialization.
//   @ObjCSelector('echoNullableDouble:')
//   @SwiftFunction('echoNullable(_:)')
//   double? echoNullableDouble(double? aDouble);

//   /// Returns the passed string, to test serialization and deserialization.
//   @ObjCSelector('echoNullableString:')
//   @SwiftFunction('echoNullable(_:)')
//   String? echoNullableString(String? aString);

//   /// Returns the passed byte list, to test serialization and deserialization.
//   @ObjCSelector('echoNullableUint8List:')
//   @SwiftFunction('echoNullable(_:)')
//   Uint8List? echoNullableUint8List(Uint8List? list);

//   /// Returns the passed list, to test serialization and deserialization.
//   @ObjCSelector('echoNullableList:')
//   @SwiftFunction('echoNullable(_:)')
//   List<Object?>? echoNullableList(List<Object?>? list);

//   /// Returns the passed list, to test serialization and deserialization.
//   @ObjCSelector('echoNullableEnumList:')
//   @SwiftFunction('echoNullable(enumList:)')
//   List<NIAnEnum?>? echoNullableEnumList(List<NIAnEnum?>? enumList);

//   /// Returns the passed list, to test serialization and deserialization.
//   @ObjCSelector('echoNullableClassList:')
//   @SwiftFunction('echoNullable(classList:)')
//   List<NIAllNullableTypes?>? echoNullableClassList(
//       List<NIAllNullableTypes?>? classList);

//   /// Returns the passed list, to test serialization and deserialization.
//   @ObjCSelector('echoNullableNonNullEnumList:')
//   @SwiftFunction('echoNullableNonNull(enumList:)')
//   List<NIAnEnum>? echoNullableNonNullEnumList(List<NIAnEnum>? enumList);

//   /// Returns the passed list, to test serialization and deserialization.
//   @ObjCSelector('echoNullableNonNullClassList:')
//   @SwiftFunction('echoNullableNonNull(classList:)')
//   List<NIAllNullableTypes>? echoNullableNonNullClassList(
//       List<NIAllNullableTypes>? classList);

//   /// Returns the passed map, to test serialization and deserialization.
//   @ObjCSelector('echoNullableMap:')
//   @SwiftFunction('echoNullable(_:)')
//   Map<Object?, Object?>? echoNullableMap(Map<Object?, Object?>? map);

//   /// Returns the passed map, to test serialization and deserialization.
//   @ObjCSelector('echoNullableStringMap:')
//   @SwiftFunction('echoNullable(stringMap:)')
//   Map<String?, String?>? echoNullableStringMap(
//       Map<String?, String?>? stringMap);

//   /// Returns the passed map, to test serialization and deserialization.
//   @ObjCSelector('echoNullableIntMap:')
//   @SwiftFunction('echoNullable(intMap:)')
//   Map<int?, int?>? echoNullableIntMap(Map<int?, int?>? intMap);

//   /// Returns the passed map, to test serialization and deserialization.
//   @ObjCSelector('echoNullableEnumMap:')
//   @SwiftFunction('echoNullable(enumMap:)')
//   Map<NIAnEnum?, NIAnEnum?>? echoNullableEnumMap(
//       Map<NIAnEnum?, NIAnEnum?>? enumMap);

//   /// Returns the passed map, to test serialization and deserialization.
//   @ObjCSelector('echoNullableClassMap:')
//   @SwiftFunction('echoNullable(classMap:)')
//   Map<int?, NIAllNullableTypes?>? echoNullableClassMap(
//       Map<int?, NIAllNullableTypes?>? classMap);

//   /// Returns the passed map, to test serialization and deserialization.
//   @ObjCSelector('echoNullableNonNullStringMap:')
//   @SwiftFunction('echoNullableNonNull(stringMap:)')
//   Map<String, String>? echoNullableNonNullStringMap(
//       Map<String, String>? stringMap);

//   /// Returns the passed map, to test serialization and deserialization.
//   @ObjCSelector('echoNullableNonNullIntMap:')
//   @SwiftFunction('echoNullableNonNull(intMap:)')
//   Map<int, int>? echoNullableNonNullIntMap(Map<int, int>? intMap);

//   /// Returns the passed map, to test serialization and deserialization.
//   @ObjCSelector('echoNullableNonNullEnumMap:')
//   @SwiftFunction('echoNullableNonNull(enumMap:)')
//   Map<NIAnEnum, NIAnEnum>? echoNullableNonNullEnumMap(
//       Map<NIAnEnum, NIAnEnum>? enumMap);

//   /// Returns the passed map, to test serialization and deserialization.
//   @ObjCSelector('echoNullableNonNullClassMap:')
//   @SwiftFunction('echoNullableNonNull(classMap:)')
//   Map<int, NIAllNullableTypes>? echoNullableNonNullClassMap(
//       Map<int, NIAllNullableTypes>? classMap);

//   /// Returns the passed enum to test serialization and deserialization.
//   @ObjCSelector('echoNullableEnum:')
//   @SwiftFunction('echoNullable(_:)')
//   NIAnEnum? echoNullableEnum(NIAnEnum? anEnum);

//   /// Returns the passed enum to test serialization and deserialization.
//   @ObjCSelector('echoAnotherNullableEnum:')
//   @SwiftFunction('echoNullable(_:)')
//   NIAnotherEnum? echoAnotherNullableEnum(NIAnotherEnum? anotherEnum);

//   // ========== Async tests ==========
//   // These are minimal since async FlutterApi only changes Dart generation.
//   // Currently they aren't integration tested, but having them here ensures
//   // analysis coverage.

//   /// A no-op function taking no arguments and returning no value, to sanity
//   /// test basic asynchronous calling.
//   // @async
//   // void noopAsync();

//   // /// Returns the passed in generic Object asynchronously.
//   // @async
//   // @ObjCSelector('echoAsyncString:')
//   // @SwiftFunction('echoAsync(_:)')
//   // String echoAsyncString(String aString);
// }
