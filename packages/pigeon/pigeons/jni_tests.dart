// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: always_specify_types, strict_raw_type

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOptions: DartOptions(),
  kotlinOptions: KotlinOptions(useJni: true),
  swiftOptions: SwiftOptions(useFfi: true, ffiModuleName: 'test_plugin'),
))
enum JniAnEnum {
  one,
  two,
  three,
  fortyTwo,
  fourHundredTwentyTwo,
}

// // Enums require special logic, having multiple ensures that the logic can be
// // replicated without collision.
// enum JniAnotherEnum {
//   justInCase,
// }

// /// A class containing all supported types.
// class JniAllTypes {
//   JniAllTypes({
//     this.aBool = false,
//     this.anInt = 0,
//     this.anInt64 = 0,
//     this.aDouble = 0,
//     // required this.aByteArray,
//     // required this.a4ByteArray,
//     // required this.a8ByteArray,
//     // required this.aFloatArray,
//     this.anEnum = JniAnEnum.one,
//     this.anotherEnum = JniAnotherEnum.justInCase,
//     this.aString = '',
//     this.anObject = 0,

//     // Lists
//     // This name is in a different format than the others to ensure that name
//     // collision with the word 'list' doesn't occur in the generated files.
//     required this.list,
//     required this.stringList,
//     required this.intList,
//     required this.doubleList,
//     required this.boolList,
//     required this.enumList,
//     required this.objectList,
//     required this.listList,
//     required this.mapList,

//     // Maps
//     required this.map,
//     required this.stringMap,
//     required this.intMap,
//     required this.enumMap,
//     required this.objectMap,
//     required this.listMap,
//     required this.mapMap,
//   });

//   bool aBool;
//   int anInt;
//   int anInt64;
//   double aDouble;
//   // Uint8List aByteArray;
//   // Int32List a4ByteArray;
//   // Int64List a8ByteArray;
//   // Float64List aFloatArray;
//   JniAnEnum anEnum;
//   JniAnotherEnum anotherEnum;
//   String aString;
//   Object anObject;

//   // Lists
//   List list;
//   List<String> stringList;
//   List<int> intList;
//   List<double> doubleList;
//   List<bool> boolList;
//   List<JniAnEnum> enumList;
//   List<Object> objectList;
//   List<List<Object?>> listList;
//   List<Map<Object?, Object?>> mapList;

//   // Maps
//   Map map;
//   Map<String, String> stringMap;
//   Map<int, int> intMap;
//   Map<JniAnEnum, JniAnEnum> enumMap;
//   Map<Object, Object> objectMap;
//   Map<int, List<Object?>> listMap;
//   Map<int, Map<Object?, Object?>> mapMap;
// }

// /// A class containing all supported nullable types.
// @SwiftClass()
// class JniAllNullableTypes {
//   JniAllNullableTypes(
//     this.aNullableBool,
//     this.aNullableInt,
//     this.aNullableInt64,
//     this.aNullableDouble,
//     // this.aNullableByteArray,
//     // this.aNullable4ByteArray,
//     // this.aNullable8ByteArray,
//     // this.aNullableFloatArray,
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
//   );

//   bool? aNullableBool;
//   int? aNullableInt;
//   int? aNullableInt64;
//   double? aNullableDouble;
//   // Uint8List? aNullableByteArray;
//   // Int32List? aNullable4ByteArray;
//   // Int64List? aNullable8ByteArray;
//   // Float64List? aNullableFloatArray;
//   JniAnEnum? aNullableEnum;
//   JniAnotherEnum? anotherNullableEnum;
//   String? aNullableString;
//   Object? aNullableObject;
//   JniAllNullableTypes? allNullableTypes;

//   // Lists
//   List? list;
//   List<String?>? stringList;
//   List<int?>? intList;
//   List<double?>? doubleList;
//   List<bool?>? boolList;
//   List<JniAnEnum?>? enumList;
//   List<Object?>? objectList;
//   List<List<Object?>?>? listList;
//   List<Map<Object?, Object?>?>? mapList;
//   List<JniAllNullableTypes?>? recursiveClassList;

//   // Maps
//   Map? map;
//   Map<String?, String?>? stringMap;
//   Map<int?, int?>? intMap;
//   Map<JniAnEnum?, JniAnEnum?>? enumMap;
//   Map<Object?, Object?>? objectMap;
//   Map<int?, List<Object?>?>? listMap;
//   Map<int?, Map<Object?, Object?>?>? mapMap;
//   Map<int?, JniAllNullableTypes?>? recursiveClassMap;
// }

// /// The primary purpose for this class is to ensure coverage of Swift structs
// /// with nullable items, as the primary [JniAllNullableTypes] class is being used to
// /// test Swift classes.
// class JniAllNullableTypesWithoutRecursion {
//   JniAllNullableTypesWithoutRecursion(
//     this.aNullableBool,
//     this.aNullableInt,
//     this.aNullableInt64,
//     this.aNullableDouble,
//     // this.aNullableByteArray,
//     // this.aNullable4ByteArray,
//     // this.aNullable8ByteArray,
//     // this.aNullableFloatArray,
//     this.aNullableEnum,
//     this.anotherNullableEnum,
//     this.aNullableString,
//     this.aNullableObject,

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

//     // Maps
//     this.map,
//     this.stringMap,
//     this.intMap,
//     this.enumMap,
//     this.objectMap,
//     this.listMap,
//     this.mapMap,
//   );

//   bool? aNullableBool;
//   int? aNullableInt;
//   int? aNullableInt64;
//   double? aNullableDouble;
//   // Uint8List? aNullableByteArray;
//   // Int32List? aNullable4ByteArray;
//   // Int64List? aNullable8ByteArray;
//   // Float64List? aNullableFloatArray;
//   JniAnEnum? aNullableEnum;
//   JniAnotherEnum? anotherNullableEnum;
//   String? aNullableString;
//   Object? aNullableObject;

//   // Lists
//   List? list;
//   List<String?>? stringList;
//   List<int?>? intList;
//   List<double?>? doubleList;
//   List<bool?>? boolList;
//   List<JniAnEnum?>? enumList;
//   List<Object?>? objectList;
//   List<List<Object?>?>? listList;
//   List<Map<Object?, Object?>?>? mapList;

//   // Maps
//   Map? map;
//   Map<String?, String?>? stringMap;
//   Map<int?, int?>? intMap;
//   Map<JniAnEnum?, JniAnEnum?>? enumMap;
//   Map<Object?, Object?>? objectMap;
//   Map<int?, List<Object?>?>? listMap;
//   Map<int?, Map<Object?, Object?>?>? mapMap;
// }

// /// A class for testing nested class handling.
// ///
// /// This is needed to test nested nullable and non-nullable classes,
// /// `JniAllNullableTypes` is non-nullable here as it is easier to instantiate
// /// than `JniAllTypes` when testing doesn't require both (ie. testing null classes).
// class JniAllClassesWrapper {
//   JniAllClassesWrapper(
//     this.allNullableTypes,
//     this.allNullableTypesWithoutRecursion,
//     this.allTypes,
//     this.classList,
//     this.classMap,
//     this.nullableClassList,
//     this.nullableClassMap,
//   );
//   JniAllNullableTypes allNullableTypes;
//   JniAllNullableTypesWithoutRecursion? allNullableTypesWithoutRecursion;
//   JniAllTypes? allTypes;
//   List<JniAllTypes?> classList;
//   List<JniAllNullableTypesWithoutRecursion?>? nullableClassList;
//   Map<int?, JniAllTypes?> classMap;
//   Map<int?, JniAllNullableTypesWithoutRecursion?>? nullableClassMap;
// }

class BasicClass {
  BasicClass(
    this.anInt,
    this.aString,
  );

  int anInt;
  String aString;
}

@HostApi()
abstract class JniHostIntegrationCoreApi {
  void noop();
  int echoInt(int anInt);
  double echoDouble(double aDouble);
  bool echoBool(bool aBool);
  String echoString(String aString);
  BasicClass echoBasicClass(BasicClass aBasicClass);
  JniAnEnum echoEnum(JniAnEnum anEnum);

  // Uint8List echoUint8List(Uint8List aUint8List);
  // Int32List echoInt32List(Int32List aInt32List);
  // Int64List echoInt64List(Int64List aInt64List);
  // Float64List echoFloat64List(Float64List aFloat64List);
  // Object echoObject(Object anObject);
  // List<Object?> echoList(List<Object?> list);
  // List<JniAnEnum?> echoEnumList(List<JniAnEnum?> enumList);
  // List<JniAllNullableTypes?> echoClassList(
  //     List<JniAllNullableTypes?> classList);
  // List<JniAnEnum> echoNonNullEnumList(List<JniAnEnum> enumList);
  // List<JniAllNullableTypes> echoNonNullClassList(
  //     List<JniAllNullableTypes> classList);
  // Map<Object?, Object?> echoMap(Map<Object?, Object?> map);
  // Map<String?, String?> echoStringMap(Map<String?, String?> stringMap);
  // Map<int?, int?> echoIntMap(Map<int?, int?> intMap);
  // Map<JniAnEnum?, JniAnEnum?> echoEnumMap(Map<JniAnEnum?, JniAnEnum?> enumMap);
  // Map<int?, JniAllNullableTypes?> echoClassMap(
  //     Map<int?, JniAllNullableTypes?> classMap);
  // Map<String, String> echoNonNullStringMap(Map<String, String> stringMap);
  // Map<int, int> echoNonNullIntMap(Map<int, int> intMap);
  // Map<JniAnEnum, JniAnEnum> echoNonNullEnumMap(
  //     Map<JniAnEnum, JniAnEnum> enumMap);
  // Map<int, JniAllNullableTypes> echoNonNullClassMap(
  //     Map<int, JniAllNullableTypes> classMap);
  // JniAllClassesWrapper echoClassWrapper(JniAllClassesWrapper wrapper);
  // JniAnotherEnum echoAnotherEnum(JniAnotherEnum anotherEnum);
}
