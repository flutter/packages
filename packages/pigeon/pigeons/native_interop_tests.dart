// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: always_specify_types, strict_raw_type

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOptions: DartOptions(),
    kotlinOptions: KotlinOptions(useJni: true, appDirectory: 'platform_tests/test_plugin/example/'),
    swiftOptions: SwiftOptions(
      useFfi: true,
      ffiModuleName: 'test_plugin',
      appDirectory: 'platform_tests/test_plugin/example/',
    ),
  ),
)
enum NativeInteropAnEnum { one, two, three, fortyTwo, fourHundredTwentyTwo }

// Enums require special logic, having multiple ensures that the logic can be
// replicated without collision.
enum NativeInteropAnotherEnum { justInCase }

// This exists to show that unused data classes still generate.
class NativeInteropUnusedClass {
  NativeInteropUnusedClass({this.aField});

  Object? aField;
}

/// A class containing all supported types.
class NativeInteropAllTypes {
  NativeInteropAllTypes({
    this.aBool = false,
    this.anInt = 0,
    this.anInt64 = 0,
    this.aDouble = 0,
    required this.aByteArray,
    required this.a4ByteArray,
    required this.a8ByteArray,
    required this.aFloatArray,
    this.anEnum = NativeInteropAnEnum.one,
    this.anotherEnum = NativeInteropAnotherEnum.justInCase,
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
  NativeInteropAnEnum anEnum;
  NativeInteropAnotherEnum anotherEnum;
  String aString;
  Object anObject;

  // Lists
  List list;
  List<String> stringList;
  List<int> intList;
  List<double> doubleList;
  List<bool> boolList;
  List<NativeInteropAnEnum> enumList;
  List<Object> objectList;
  List<List<Object?>> listList;
  List<Map<Object?, Object?>> mapList;

  // Maps
  Map map;
  Map<String, String> stringMap;
  Map<int, int> intMap;
  Map<NativeInteropAnEnum, NativeInteropAnEnum> enumMap;
  Map<Object, Object> objectMap;
  Map<int, List<Object?>> listMap;
  Map<int, Map<Object?, Object?>> mapMap;
}

/// A class containing all supported nullable types.
@SwiftClass()
class NativeInteropAllNullableTypes {
  NativeInteropAllNullableTypes(
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
  NativeInteropAnEnum? aNullableEnum;
  NativeInteropAnotherEnum? anotherNullableEnum;
  String? aNullableString;
  Object? aNullableObject;
  NativeInteropAllNullableTypes? allNullableTypes;

  // Lists
  List? list;
  List<String?>? stringList;
  List<int?>? intList;
  List<double?>? doubleList;
  List<bool?>? boolList;
  List<NativeInteropAnEnum?>? enumList;
  List<Object?>? objectList;
  List<List<Object?>?>? listList;
  List<Map<Object?, Object?>?>? mapList;
  List<NativeInteropAllNullableTypes?>? recursiveClassList;

  // Maps
  Map? map;
  Map<String?, String?>? stringMap;
  Map<int?, int?>? intMap;
  Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? enumMap;
  Map<Object?, Object?>? objectMap;
  Map<int?, List<Object?>?>? listMap;
  Map<int?, Map<Object?, Object?>?>? mapMap;
  Map<int?, NativeInteropAllNullableTypes?>? recursiveClassMap;
}

/// The primary purpose for this class is to ensure coverage of Swift structs
/// with nullable items, as the primary [NativeInteropAllNullableTypes] class is being used to
/// test Swift classes.
class NativeInteropAllNullableTypesWithoutRecursion {
  NativeInteropAllNullableTypesWithoutRecursion(
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
  NativeInteropAnEnum? aNullableEnum;
  NativeInteropAnotherEnum? anotherNullableEnum;
  String? aNullableString;
  Object? aNullableObject;

  // Lists
  List? list;
  List<String?>? stringList;
  List<int?>? intList;
  List<double?>? doubleList;
  List<bool?>? boolList;
  List<NativeInteropAnEnum?>? enumList;
  List<Object?>? objectList;
  List<List<Object?>?>? listList;
  List<Map<Object?, Object?>?>? mapList;

  // Maps
  Map? map;
  Map<String?, String?>? stringMap;
  Map<int?, int?>? intMap;
  Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? enumMap;
  Map<Object?, Object?>? objectMap;
  Map<int?, List<Object?>?>? listMap;
  Map<int?, Map<Object?, Object?>?>? mapMap;
}

/// A class for testing nested class handling.
///
/// This is needed to test nested nullable and non-nullable classes,
/// `NativeInteropAllNullableTypes` is non-nullable here as it is easier to instantiate
/// than `NativeInteropAllTypes` when testing doesn't require both (ie. testing null classes).
class NativeInteropAllClassesWrapper {
  NativeInteropAllClassesWrapper(
    this.allNullableTypes,
    this.allNullableTypesWithoutRecursion,
    this.allTypes,
    this.classList,
    this.nullableClassList,
    this.classMap,
    this.nullableClassMap,
  );
  NativeInteropAllNullableTypes allNullableTypes;
  NativeInteropAllNullableTypesWithoutRecursion? allNullableTypesWithoutRecursion;
  NativeInteropAllTypes? allTypes;
  List<NativeInteropAllTypes?> classList;
  List<NativeInteropAllNullableTypesWithoutRecursion?>? nullableClassList;
  Map<int?, NativeInteropAllTypes?> classMap;
  Map<int?, NativeInteropAllNullableTypesWithoutRecursion?>? nullableClassMap;
}

/// The core interface that each host language plugin must implement in
/// platform_test integration tests.
@HostApi()
abstract class NativeInteropHostIntegrationCoreApi {
  // ========== Synchronous method tests ==========

  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic calling.
  void noop();

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoAllTypes:')
  @SwiftFunction('echo(_:)')
  NativeInteropAllTypes echoAllTypes(NativeInteropAllTypes everything);

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
  @ObjCSelector('echoStringList:')
  @SwiftFunction('echo(stringList:)')
  List<String?> echoStringList(List<String?> stringList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoIntList:')
  @SwiftFunction('echo(intList:)')
  List<int?> echoIntList(List<int?> intList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoDoubleList:')
  @SwiftFunction('echo(doubleList:)')
  List<double?> echoDoubleList(List<double?> doubleList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoBoolList:')
  @SwiftFunction('echo(boolList:)')
  List<bool?> echoBoolList(List<bool?> boolList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoEnumList:')
  @SwiftFunction('echo(enumList:)')
  List<NativeInteropAnEnum?> echoEnumList(List<NativeInteropAnEnum?> enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoClassList:')
  @SwiftFunction('echo(classList:)')
  List<NativeInteropAllNullableTypes?> echoClassList(
    List<NativeInteropAllNullableTypes?> classList,
  );

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNonNullEnumList:')
  @SwiftFunction('echoNonNull(enumList:)')
  List<NativeInteropAnEnum> echoNonNullEnumList(List<NativeInteropAnEnum> enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNonNullClassList:')
  @SwiftFunction('echoNonNull(classList:)')
  List<NativeInteropAllNullableTypes> echoNonNullClassList(
    List<NativeInteropAllNullableTypes> classList,
  );

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
  Map<NativeInteropAnEnum?, NativeInteropAnEnum?> echoEnumMap(
    Map<NativeInteropAnEnum?, NativeInteropAnEnum?> enumMap,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoClassMap:')
  @SwiftFunction('echo(classMap:)')
  Map<int?, NativeInteropAllNullableTypes?> echoClassMap(
    Map<int?, NativeInteropAllNullableTypes?> classMap,
  );

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
  Map<NativeInteropAnEnum, NativeInteropAnEnum> echoNonNullEnumMap(
    Map<NativeInteropAnEnum, NativeInteropAnEnum> enumMap,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNonNullClassMap:')
  @SwiftFunction('echoNonNull(classMap:)')
  Map<int, NativeInteropAllNullableTypes> echoNonNullClassMap(
    Map<int, NativeInteropAllNullableTypes> classMap,
  );

  /// Returns the passed class to test nested class serialization and deserialization.
  @ObjCSelector('echoClassWrapper:')
  @SwiftFunction('echo(_:)')
  NativeInteropAllClassesWrapper echoClassWrapper(NativeInteropAllClassesWrapper wrapper);

  /// Returns the passed enum to test serialization and deserialization.
  @ObjCSelector('echoEnum:')
  @SwiftFunction('echo(_:)')
  NativeInteropAnEnum echoEnum(NativeInteropAnEnum anEnum);

  /// Returns the passed enum to test serialization and deserialization.
  @ObjCSelector('echoAnotherEnum:')
  @SwiftFunction('echo(_:)')
  NativeInteropAnotherEnum echoAnotherEnum(NativeInteropAnotherEnum anotherEnum);

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
  @SwiftFunction('echoNullable(_:)')
  NativeInteropAllNullableTypes? echoAllNullableTypes(NativeInteropAllNullableTypes? everything);

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoAllNullableTypesWithoutRecursion:')
  @SwiftFunction('echoNullable(_:)')
  NativeInteropAllNullableTypesWithoutRecursion? echoAllNullableTypesWithoutRecursion(
    NativeInteropAllNullableTypesWithoutRecursion? everything,
  );

  /// Returns the inner `aString` value from the wrapped object, to test
  /// sending of nested objects.
  @ObjCSelector('extractNestedNullableStringFrom:')
  @SwiftFunction('extractNestedNullableString(from:)')
  String? extractNestedNullableString(NativeInteropAllClassesWrapper wrapper);

  /// Returns the inner `aString` value from the wrapped object, to test
  /// sending of nested objects.
  @ObjCSelector('createNestedObjectWithNullableString:')
  @SwiftFunction('createNestedObject(with:)')
  NativeInteropAllClassesWrapper createNestedNullableString(String? nullableString);

  // Returns passed in arguments of multiple types.
  @ObjCSelector('sendMultipleNullableTypesABool:anInt:aString:')
  @SwiftFunction('sendMultipleNullableTypes(aBool:anInt:aString:)')
  NativeInteropAllNullableTypes sendMultipleNullableTypes(
    bool? aNullableBool,
    int? aNullableInt,
    String? aNullableString,
  );

  /// Returns passed in arguments of multiple types.
  @ObjCSelector('sendMultipleNullableTypesWithoutRecursionABool:anInt:aString:')
  @SwiftFunction('sendMultipleNullableTypesWithoutRecursion(aBool:anInt:aString:)')
  NativeInteropAllNullableTypesWithoutRecursion sendMultipleNullableTypesWithoutRecursion(
    bool? aNullableBool,
    int? aNullableInt,
    String? aNullableString,
  );

  /// Returns passed in int.
  @ObjCSelector('echoNullableInt:')
  @SwiftFunction('echoNullable(_:)')
  int? echoNullableInt(int? aNullableInt);

  /// Returns passed in double.
  @ObjCSelector('echoNullableDouble:')
  @SwiftFunction('echoNullable(_:)')
  double? echoNullableDouble(double? aNullableDouble);

  /// Returns the passed in boolean.
  @ObjCSelector('echoNullableBool:')
  @SwiftFunction('echoNullable(_:)')
  bool? echoNullableBool(bool? aNullableBool);

  /// Returns the passed in string.
  @ObjCSelector('echoNullableString:')
  @SwiftFunction('echoNullable(_:)')
  String? echoNullableString(String? aNullableString);

  /// Returns the passed in Uint8List.
  @ObjCSelector('echoNullableUint8List:')
  @SwiftFunction('echoNullable(_:)')
  Uint8List? echoNullableUint8List(Uint8List? aNullableUint8List);

  /// Returns the passed in Int32List.
  @ObjCSelector('echoNullableInt32List:')
  @SwiftFunction('echoNullable(_:)')
  Int32List? echoNullableInt32List(Int32List? aNullableInt32List);

  /// Returns the passed in Int64List.
  @ObjCSelector('echoNullableInt64List:')
  @SwiftFunction('echoNullable(_:)')
  Int64List? echoNullableInt64List(Int64List? aNullableInt64List);

  /// Returns the passed in Float64List.
  @ObjCSelector('echoNullableFloat64List:')
  @SwiftFunction('echoNullable(_:)')
  Float64List? echoNullableFloat64List(Float64List? aNullableFloat64List);

  /// Returns the passed in generic Object.
  @ObjCSelector('echoNullableObject:')
  @SwiftFunction('echoNullable(_:)')
  Object? echoNullableObject(Object? aNullableObject);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableList:')
  @SwiftFunction('echoNullable(_:)')
  List<Object?>? echoNullableList(List<Object?>? aNullableList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableEnumList:')
  @SwiftFunction('echoNullable(enumList:)')
  List<NativeInteropAnEnum?>? echoNullableEnumList(List<NativeInteropAnEnum?>? enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableClassList:')
  @SwiftFunction('echoNullable(classList:)')
  List<NativeInteropAllNullableTypes?>? echoNullableClassList(
    List<NativeInteropAllNullableTypes?>? classList,
  );

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullEnumList:')
  @SwiftFunction('echoNullableNonNull(enumList:)')
  List<NativeInteropAnEnum>? echoNullableNonNullEnumList(List<NativeInteropAnEnum>? enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullClassList:')
  @SwiftFunction('echoNullableNonNull(classList:)')
  List<NativeInteropAllNullableTypes>? echoNullableNonNullClassList(
    List<NativeInteropAllNullableTypes>? classList,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableMap:')
  @SwiftFunction('echoNullable(_:)')
  Map<Object?, Object?>? echoNullableMap(Map<Object?, Object?>? map);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableStringMap:')
  @SwiftFunction('echoNullable(stringMap:)')
  Map<String?, String?>? echoNullableStringMap(Map<String?, String?>? stringMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableIntMap:')
  @SwiftFunction('echoNullable(intMap:)')
  Map<int?, int?>? echoNullableIntMap(Map<int?, int?>? intMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableEnumMap:')
  @SwiftFunction('echoNullable(enumMap:)')
  Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? echoNullableEnumMap(
    Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? enumMap,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableClassMap:')
  @SwiftFunction('echoNullable(classMap:)')
  Map<int?, NativeInteropAllNullableTypes?>? echoNullableClassMap(
    Map<int?, NativeInteropAllNullableTypes?>? classMap,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullStringMap:')
  @SwiftFunction('echoNullableNonNull(stringMap:)')
  Map<String, String>? echoNullableNonNullStringMap(Map<String, String>? stringMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullIntMap:')
  @SwiftFunction('echoNullableNonNull(intMap:)')
  Map<int, int>? echoNullableNonNullIntMap(Map<int, int>? intMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullEnumMap:')
  @SwiftFunction('echoNullableNonNull(enumMap:)')
  Map<NativeInteropAnEnum, NativeInteropAnEnum>? echoNullableNonNullEnumMap(
    Map<NativeInteropAnEnum, NativeInteropAnEnum>? enumMap,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullClassMap:')
  @SwiftFunction('echoNullableNonNull(classMap:)')
  Map<int, NativeInteropAllNullableTypes>? echoNullableNonNullClassMap(
    Map<int, NativeInteropAllNullableTypes>? classMap,
  );

  @ObjCSelector('echoNullableEnum:')
  @SwiftFunction('echoNullable(_:)')
  NativeInteropAnEnum? echoNullableEnum(NativeInteropAnEnum? anEnum);

  @ObjCSelector('echoAnotherNullableEnum:')
  @SwiftFunction('echoNullable(_:)')
  NativeInteropAnotherEnum? echoAnotherNullableEnum(NativeInteropAnotherEnum? anotherEnum);

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
  List<NativeInteropAnEnum?> echoAsyncEnumList(List<NativeInteropAnEnum?> enumList);

  /// Returns the passed list, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncClassList:')
  @SwiftFunction('echoAsync(classList:)')
  List<NativeInteropAllNullableTypes?> echoAsyncClassList(
    List<NativeInteropAllNullableTypes?> classList,
  );

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
  Map<NativeInteropAnEnum?, NativeInteropAnEnum?> echoAsyncEnumMap(
    Map<NativeInteropAnEnum?, NativeInteropAnEnum?> enumMap,
  );

  /// Returns the passed map, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncClassMap:')
  @SwiftFunction('echoAsync(classMap:)')
  Map<int?, NativeInteropAllNullableTypes?> echoAsyncClassMap(
    Map<int?, NativeInteropAllNullableTypes?> classMap,
  );

  /// Returns the passed enum, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncEnum:')
  @SwiftFunction('echoAsync(_:)')
  NativeInteropAnEnum echoAsyncEnum(NativeInteropAnEnum anEnum);

  /// Returns the passed enum, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAnotherAsyncEnum:')
  @SwiftFunction('echoAsync(_:)')
  NativeInteropAnotherEnum echoAnotherAsyncEnum(NativeInteropAnotherEnum anotherEnum);

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
  @ObjCSelector('echoAsyncNativeInteropAllTypes:')
  @SwiftFunction('echoAsync(_:)')
  NativeInteropAllTypes echoAsyncNativeInteropAllTypes(NativeInteropAllTypes everything);

  /// Returns the passed object, to test serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableNativeInteropAllNullableTypes:')
  @SwiftFunction('echoAsync(_:)')
  NativeInteropAllNullableTypes? echoAsyncNullableNativeInteropAllNullableTypes(
    NativeInteropAllNullableTypes? everything,
  );

  /// Returns the passed object, to test serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableNativeInteropAllNullableTypesWithoutRecursion:')
  @SwiftFunction('echoAsync(_:)')
  NativeInteropAllNullableTypesWithoutRecursion?
  echoAsyncNullableNativeInteropAllNullableTypesWithoutRecursion(
    NativeInteropAllNullableTypesWithoutRecursion? everything,
  );

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
  List<NativeInteropAnEnum?>? echoAsyncNullableEnumList(List<NativeInteropAnEnum?>? enumList);

  /// Returns the passed list, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableClassList:')
  @SwiftFunction('echoAsyncNullable(classList:)')
  List<NativeInteropAllNullableTypes?>? echoAsyncNullableClassList(
    List<NativeInteropAllNullableTypes?>? classList,
  );

  /// Returns the passed map, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableMap:')
  @SwiftFunction('echoAsyncNullable(_:)')
  Map<Object?, Object?>? echoAsyncNullableMap(Map<Object?, Object?>? map);

  /// Returns the passed map, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableStringMap:')
  @SwiftFunction('echoAsyncNullable(stringMap:)')
  Map<String?, String?>? echoAsyncNullableStringMap(Map<String?, String?>? stringMap);

  /// Returns the passed map, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableIntMap:')
  @SwiftFunction('echoAsyncNullable(intMap:)')
  Map<int?, int?>? echoAsyncNullableIntMap(Map<int?, int?>? intMap);

  /// Returns the passed map, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableEnumMap:')
  @SwiftFunction('echoAsyncNullable(enumMap:)')
  Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? echoAsyncNullableEnumMap(
    Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? enumMap,
  );

  /// Returns the passed map, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableClassMap:')
  @SwiftFunction('echoAsyncNullable(classMap:)')
  Map<int?, NativeInteropAllNullableTypes?>? echoAsyncNullableClassMap(
    Map<int?, NativeInteropAllNullableTypes?>? classMap,
  );

  /// Returns the passed enum, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAsyncNullableEnum:')
  @SwiftFunction('echoAsyncNullable(_:)')
  NativeInteropAnEnum? echoAsyncNullableEnum(NativeInteropAnEnum? anEnum);

  /// Returns the passed enum, to test asynchronous serialization and deserialization.
  @async
  @ObjCSelector('echoAnotherAsyncNullableEnum:')
  @SwiftFunction('echoAsyncNullable(_:)')
  NativeInteropAnotherEnum? echoAnotherAsyncNullableEnum(NativeInteropAnotherEnum? anotherEnum);

  void callFlutterNoop();

  Object? callFlutterThrowError();

  void callFlutterThrowErrorFromVoid();

  @ObjCSelector('callFlutterEchoAllTypes:')
  @SwiftFunction('callFlutterEcho(_:)')
  NativeInteropAllTypes callFlutterEchoNativeInteropAllTypes(NativeInteropAllTypes everything);

  @ObjCSelector('callFlutterEchoAllNullableTypes:')
  @SwiftFunction('callFlutterEcho(_:)')
  NativeInteropAllNullableTypes? callFlutterEchoNativeInteropAllNullableTypes(
    NativeInteropAllNullableTypes? everything,
  );

  @ObjCSelector('callFlutterSendMultipleNullableTypesABool:anInt:aString:')
  @SwiftFunction('callFlutterSendMultipleNullableTypes(aBool:anInt:aString:)')
  NativeInteropAllNullableTypes callFlutterSendMultipleNullableTypes(
    bool? aNullableBool,
    int? aNullableInt,
    String? aNullableString,
  );

  @ObjCSelector('callFlutterEchoNativeInteropAllNullableTypesWithoutRecursion:')
  @SwiftFunction('callFlutterEcho(_:)')
  NativeInteropAllNullableTypesWithoutRecursion?
  callFlutterEchoNativeInteropAllNullableTypesWithoutRecursion(
    NativeInteropAllNullableTypesWithoutRecursion? everything,
  );

  @ObjCSelector('callFlutterSendMultipleNullableTypesWithoutRecursionABool:anInt:aString:')
  @SwiftFunction('callFlutterSendMultipleNullableTypesWithoutRecursion(aBool:anInt:aString:)')
  NativeInteropAllNullableTypesWithoutRecursion
  callFlutterSendMultipleNullableTypesWithoutRecursion(
    bool? aNullableBool,
    int? aNullableInt,
    String? aNullableString,
  );

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

  @ObjCSelector('callFlutterEchoInt32List:')
  @SwiftFunction('callFlutterEcho(_:)')
  Int32List callFlutterEchoInt32List(Int32List list);

  @ObjCSelector('callFlutterEchoInt64List:')
  @SwiftFunction('callFlutterEcho(_:)')
  Int64List callFlutterEchoInt64List(Int64List list);

  @ObjCSelector('callFlutterEchoFloat64List:')
  @SwiftFunction('callFlutterEcho(_:)')
  Float64List callFlutterEchoFloat64List(Float64List list);

  @ObjCSelector('callFlutterEchoList:')
  @SwiftFunction('callFlutterEcho(_:)')
  List<Object?> callFlutterEchoList(List<Object?> list);

  @ObjCSelector('callFlutterEchoEnumList:')
  @SwiftFunction('callFlutterEcho(enumList:)')
  List<NativeInteropAnEnum?> callFlutterEchoEnumList(List<NativeInteropAnEnum?> enumList);

  @ObjCSelector('callFlutterEchoClassList:')
  @SwiftFunction('callFlutterEcho(classList:)')
  List<NativeInteropAllNullableTypes?> callFlutterEchoClassList(
    List<NativeInteropAllNullableTypes?> classList,
  );

  @ObjCSelector('callFlutterEchoNonNullEnumList:')
  @SwiftFunction('callFlutterEchoNonNull(enumList:)')
  List<NativeInteropAnEnum> callFlutterEchoNonNullEnumList(List<NativeInteropAnEnum> enumList);

  @ObjCSelector('callFlutterEchoNonNullClassList:')
  @SwiftFunction('callFlutterEchoNonNull(classList:)')
  List<NativeInteropAllNullableTypes> callFlutterEchoNonNullClassList(
    List<NativeInteropAllNullableTypes> classList,
  );

  @ObjCSelector('callFlutterEchoMap:')
  @SwiftFunction('callFlutterEcho(_:)')
  Map<Object?, Object?> callFlutterEchoMap(Map<Object?, Object?> map);

  @ObjCSelector('callFlutterEchoStringMap:')
  @SwiftFunction('callFlutterEcho(stringMap:)')
  Map<String?, String?> callFlutterEchoStringMap(Map<String?, String?> stringMap);

  @ObjCSelector('callFlutterEchoIntMap:')
  @SwiftFunction('callFlutterEcho(intMap:)')
  Map<int?, int?> callFlutterEchoIntMap(Map<int?, int?> intMap);

  @ObjCSelector('callFlutterEchoEnumMap:')
  @SwiftFunction('callFlutterEcho(enumMap:)')
  Map<NativeInteropAnEnum?, NativeInteropAnEnum?> callFlutterEchoEnumMap(
    Map<NativeInteropAnEnum?, NativeInteropAnEnum?> enumMap,
  );

  @ObjCSelector('callFlutterEchoClassMap:')
  @SwiftFunction('callFlutterEcho(classMap:)')
  Map<int?, NativeInteropAllNullableTypes?> callFlutterEchoClassMap(
    Map<int?, NativeInteropAllNullableTypes?> classMap,
  );

  @ObjCSelector('callFlutterEchoNonNullStringMap:')
  @SwiftFunction('callFlutterEchoNonNull(stringMap:)')
  Map<String, String> callFlutterEchoNonNullStringMap(Map<String, String> stringMap);

  @ObjCSelector('callFlutterEchoNonNullIntMap:')
  @SwiftFunction('callFlutterEchoNonNull(intMap:)')
  Map<int, int> callFlutterEchoNonNullIntMap(Map<int, int> intMap);

  @ObjCSelector('callFlutterEchoNonNullEnumMap:')
  @SwiftFunction('callFlutterEchoNonNull(enumMap:)')
  Map<NativeInteropAnEnum, NativeInteropAnEnum> callFlutterEchoNonNullEnumMap(
    Map<NativeInteropAnEnum, NativeInteropAnEnum> enumMap,
  );

  @ObjCSelector('callFlutterEchoNonNullClassMap:')
  @SwiftFunction('callFlutterEchoNonNull(classMap:)')
  Map<int, NativeInteropAllNullableTypes> callFlutterEchoNonNullClassMap(
    Map<int, NativeInteropAllNullableTypes> classMap,
  );

  @ObjCSelector('callFlutterEchoEnum:')
  @SwiftFunction('callFlutterEcho(_:)')
  NativeInteropAnEnum callFlutterEchoEnum(NativeInteropAnEnum anEnum);

  @ObjCSelector('callFlutterEchoAnotherEnum:')
  @SwiftFunction('callFlutterEcho(_:)')
  NativeInteropAnotherEnum callFlutterEchoNativeInteropAnotherEnum(
    NativeInteropAnotherEnum anotherEnum,
  );

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

  @ObjCSelector('callFlutterEchoNullableInt32List:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  Int32List? callFlutterEchoNullableInt32List(Int32List? list);

  @ObjCSelector('callFlutterEchoNullableInt64List:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  Int64List? callFlutterEchoNullableInt64List(Int64List? list);

  @ObjCSelector('callFlutterEchoNullableFloat64List:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  Float64List? callFlutterEchoNullableFloat64List(Float64List? list);

  @ObjCSelector('callFlutterEchoNullableList:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  List<Object?>? callFlutterEchoNullableList(List<Object?>? list);

  @ObjCSelector('callFlutterEchoNullableEnumList:')
  @SwiftFunction('callFlutterEchoNullable(enumList:)')
  List<NativeInteropAnEnum?>? callFlutterEchoNullableEnumList(List<NativeInteropAnEnum?>? enumList);

  @ObjCSelector('callFlutterEchoNullableClassList:')
  @SwiftFunction('callFlutterEchoNullable(classList:)')
  List<NativeInteropAllNullableTypes?>? callFlutterEchoNullableClassList(
    List<NativeInteropAllNullableTypes?>? classList,
  );

  @ObjCSelector('callFlutterEchoNullableNonNullEnumList:')
  @SwiftFunction('callFlutterEchoNullableNonNull(enumList:)')
  List<NativeInteropAnEnum>? callFlutterEchoNullableNonNullEnumList(
    List<NativeInteropAnEnum>? enumList,
  );

  @ObjCSelector('callFlutterEchoNullableNonNullClassList:')
  @SwiftFunction('callFlutterEchoNullableNonNull(classList:)')
  List<NativeInteropAllNullableTypes>? callFlutterEchoNullableNonNullClassList(
    List<NativeInteropAllNullableTypes>? classList,
  );

  @ObjCSelector('callFlutterEchoNullableMap:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  Map<Object?, Object?>? callFlutterEchoNullableMap(Map<Object?, Object?>? map);

  @ObjCSelector('callFlutterEchoNullableStringMap:')
  @SwiftFunction('callFlutterEchoNullable(stringMap:)')
  Map<String?, String?>? callFlutterEchoNullableStringMap(Map<String?, String?>? stringMap);

  @ObjCSelector('callFlutterEchoNullableIntMap:')
  @SwiftFunction('callFlutterEchoNullable(intMap:)')
  Map<int?, int?>? callFlutterEchoNullableIntMap(Map<int?, int?>? intMap);

  @ObjCSelector('callFlutterEchoNullableEnumMap:')
  @SwiftFunction('callFlutterEchoNullable(enumMap:)')
  Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? callFlutterEchoNullableEnumMap(
    Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? enumMap,
  );

  @ObjCSelector('callFlutterEchoNullableClassMap:')
  @SwiftFunction('callFlutterEchoNullable(classMap:)')
  Map<int?, NativeInteropAllNullableTypes?>? callFlutterEchoNullableClassMap(
    Map<int?, NativeInteropAllNullableTypes?>? classMap,
  );

  @ObjCSelector('callFlutterEchoNullableNonNullStringMap:')
  @SwiftFunction('callFlutterEchoNullableNonNull(stringMap:)')
  Map<String, String>? callFlutterEchoNullableNonNullStringMap(Map<String, String>? stringMap);

  @ObjCSelector('callFlutterEchoNullableNonNullIntMap:')
  @SwiftFunction('callFlutterEchoNullableNonNull(intMap:)')
  Map<int, int>? callFlutterEchoNullableNonNullIntMap(Map<int, int>? intMap);

  @ObjCSelector('callFlutterEchoNullableNonNullEnumMap:')
  @SwiftFunction('callFlutterEchoNullableNonNull(enumMap:)')
  Map<NativeInteropAnEnum, NativeInteropAnEnum>? callFlutterEchoNullableNonNullEnumMap(
    Map<NativeInteropAnEnum, NativeInteropAnEnum>? enumMap,
  );

  @ObjCSelector('callFlutterEchoNullableNonNullClassMap:')
  @SwiftFunction('callFlutterEchoNullableNonNull(classMap:)')
  Map<int, NativeInteropAllNullableTypes>? callFlutterEchoNullableNonNullClassMap(
    Map<int, NativeInteropAllNullableTypes>? classMap,
  );

  @ObjCSelector('callFlutterEchoNullableEnum:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  NativeInteropAnEnum? callFlutterEchoNullableEnum(NativeInteropAnEnum? anEnum);

  @ObjCSelector('callFlutterEchoAnotherNullableEnum:')
  @SwiftFunction('callFlutterEchoNullable(_:)')
  NativeInteropAnotherEnum? callFlutterEchoAnotherNullableEnum(
    NativeInteropAnotherEnum? anotherEnum,
  );

  @async
  void callFlutterNoopAsync();

  @async
  NativeInteropAllTypes callFlutterEchoAsyncNativeInteropAllTypes(NativeInteropAllTypes everything);

  @async
  NativeInteropAllNullableTypes? callFlutterEchoAsyncNullableNativeInteropAllNullableTypes(
    NativeInteropAllNullableTypes? everything,
  );

  @async
  NativeInteropAllNullableTypesWithoutRecursion?
  callFlutterEchoAsyncNullableNativeInteropAllNullableTypesWithoutRecursion(
    NativeInteropAllNullableTypesWithoutRecursion? everything,
  );

  @async
  bool callFlutterEchoAsyncBool(bool aBool);

  @async
  int callFlutterEchoAsyncInt(int anInt);

  @async
  double callFlutterEchoAsyncDouble(double aDouble);

  @async
  String callFlutterEchoAsyncString(String aString);

  @async
  Uint8List callFlutterEchoAsyncUint8List(Uint8List list);

  @async
  Int32List callFlutterEchoAsyncInt32List(Int32List list);

  @async
  Int64List callFlutterEchoAsyncInt64List(Int64List list);

  @async
  Float64List callFlutterEchoAsyncFloat64List(Float64List list);

  @async
  Object callFlutterEchoAsyncObject(Object anObject);

  @async
  List<Object?> callFlutterEchoAsyncList(List<Object?> list);

  @async
  List<NativeInteropAnEnum?> callFlutterEchoAsyncEnumList(List<NativeInteropAnEnum?> enumList);

  @async
  List<NativeInteropAllNullableTypes?> callFlutterEchoAsyncClassList(
    List<NativeInteropAllNullableTypes?> classList,
  );

  @async
  List<NativeInteropAnEnum> callFlutterEchoAsyncNonNullEnumList(List<NativeInteropAnEnum> enumList);

  @async
  List<NativeInteropAllNullableTypes> callFlutterEchoAsyncNonNullClassList(
    List<NativeInteropAllNullableTypes> classList,
  );

  @async
  Map<Object?, Object?> callFlutterEchoAsyncMap(Map<Object?, Object?> map);

  @async
  Map<String?, String?> callFlutterEchoAsyncStringMap(Map<String?, String?> stringMap);

  @async
  Map<int?, int?> callFlutterEchoAsyncIntMap(Map<int?, int?> intMap);

  @async
  Map<NativeInteropAnEnum?, NativeInteropAnEnum?> callFlutterEchoAsyncEnumMap(
    Map<NativeInteropAnEnum?, NativeInteropAnEnum?> enumMap,
  );

  @async
  Map<int?, NativeInteropAllNullableTypes?> callFlutterEchoAsyncClassMap(
    Map<int?, NativeInteropAllNullableTypes?> classMap,
  );

  @async
  NativeInteropAnEnum callFlutterEchoAsyncEnum(NativeInteropAnEnum anEnum);

  @async
  NativeInteropAnotherEnum callFlutterEchoAnotherAsyncEnum(NativeInteropAnotherEnum anotherEnum);

  @async
  bool? callFlutterEchoAsyncNullableBool(bool? aBool);

  @async
  int? callFlutterEchoAsyncNullableInt(int? anInt);

  @async
  double? callFlutterEchoAsyncNullableDouble(double? aDouble);

  @async
  String? callFlutterEchoAsyncNullableString(String? aString);

  @async
  Uint8List? callFlutterEchoAsyncNullableUint8List(Uint8List? list);

  @async
  Int32List? callFlutterEchoAsyncNullableInt32List(Int32List? list);

  @async
  Int64List? callFlutterEchoAsyncNullableInt64List(Int64List? list);

  @async
  Float64List? callFlutterEchoAsyncNullableFloat64List(Float64List? list);

  @async
  Object? callFlutterThrowFlutterErrorAsync();

  @async
  Object? callFlutterEchoAsyncNullableObject(Object? anObject);

  @async
  List<Object?>? callFlutterEchoAsyncNullableList(List<Object?>? list);

  @async
  List<NativeInteropAnEnum?>? callFlutterEchoAsyncNullableEnumList(
    List<NativeInteropAnEnum?>? enumList,
  );

  @async
  List<NativeInteropAllNullableTypes?>? callFlutterEchoAsyncNullableClassList(
    List<NativeInteropAllNullableTypes?>? classList,
  );

  @async
  List<NativeInteropAnEnum>? callFlutterEchoAsyncNullableNonNullEnumList(
    List<NativeInteropAnEnum>? enumList,
  );

  @async
  List<NativeInteropAllNullableTypes>? callFlutterEchoAsyncNullableNonNullClassList(
    List<NativeInteropAllNullableTypes>? classList,
  );

  @async
  Map<Object?, Object?>? callFlutterEchoAsyncNullableMap(Map<Object?, Object?>? map);

  @async
  Map<String?, String?>? callFlutterEchoAsyncNullableStringMap(Map<String?, String?>? stringMap);

  @async
  Map<int?, int?>? callFlutterEchoAsyncNullableIntMap(Map<int?, int?>? intMap);

  @async
  Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? callFlutterEchoAsyncNullableEnumMap(
    Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? enumMap,
  );

  @async
  Map<int?, NativeInteropAllNullableTypes?>? callFlutterEchoAsyncNullableClassMap(
    Map<int?, NativeInteropAllNullableTypes?>? classMap,
  );

  @async
  NativeInteropAnEnum? callFlutterEchoAsyncNullableEnum(NativeInteropAnEnum? anEnum);

  @async
  NativeInteropAnotherEnum? callFlutterEchoAnotherAsyncNullableEnum(
    NativeInteropAnotherEnum? anotherEnum,
  );

  // ========== Threading tests ==========

  /// Returns true if the handler is run on a main thread.
  bool defaultIsMainThread();

  /// Spawns a background thread and calls `noop` on the [NativeInteropFlutterIntegrationCoreApi].
  ///
  /// Returns the result of whether the flutter call was successful.
  @async
  bool callFlutterNoopOnBackgroundThread();
}

/// The core interface that the Dart platform_test code implements for host
/// integration tests to call into.
@FlutterApi()
abstract class NativeInteropFlutterIntegrationCoreApi {
  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic calling.
  void noop();

  /// Returns a Flutter error, to test error handling.
  Object? throwFlutterError();

  /// Responds with an error from an async function returning a value.
  Object? throwError();

  /// Responds with an error from an async void function.
  void throwErrorFromVoid();

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoNativeInteropAllTypes:')
  @SwiftFunction('echo(_:)')
  NativeInteropAllTypes echoNativeInteropAllTypes(NativeInteropAllTypes everything);

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoNativeInteropAllNullableTypes:')
  @SwiftFunction('echoNullable(_:)')
  NativeInteropAllNullableTypes? echoNativeInteropAllNullableTypes(
    NativeInteropAllNullableTypes? everything,
  );

  /// Returns passed in arguments of multiple types.
  ///
  /// Tests multiple-arity FlutterApi handling.
  @ObjCSelector('sendMultipleNullableTypesABool:anInt:aString:')
  @SwiftFunction('sendMultipleNullableTypes(aBool:anInt:aString:)')
  NativeInteropAllNullableTypes sendMultipleNullableTypes(
    bool? aNullableBool,
    int? aNullableInt,
    String? aNullableString,
  );

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoNativeInteropAllNullableTypesWithoutRecursion:')
  @SwiftFunction('echoNullable(_:)')
  NativeInteropAllNullableTypesWithoutRecursion? echoNativeInteropAllNullableTypesWithoutRecursion(
    NativeInteropAllNullableTypesWithoutRecursion? everything,
  );

  /// Returns passed in arguments of multiple types.
  ///
  /// Tests multiple-arity FlutterApi handling.
  @ObjCSelector('sendMultipleNullableTypesWithoutRecursionABool:anInt:aString:')
  @SwiftFunction('sendMultipleNullableTypesWithoutRecursion(aBool:anInt:aString:)')
  NativeInteropAllNullableTypesWithoutRecursion sendMultipleNullableTypesWithoutRecursion(
    bool? aNullableBool,
    int? aNullableInt,
    String? aNullableString,
  );

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

  /// Returns the passed int32 list, to test serialization and deserialization.
  @ObjCSelector('echoInt32List:')
  @SwiftFunction('echo(_:)')
  Int32List echoInt32List(Int32List list);

  /// Returns the passed int64 list, to test serialization and deserialization.
  @ObjCSelector('echoInt64List:')
  @SwiftFunction('echo(_:)')
  Int64List echoInt64List(Int64List list);

  /// Returns the passed float64 list, to test serialization and deserialization.
  @ObjCSelector('echoFloat64List:')
  @SwiftFunction('echo(_:)')
  Float64List echoFloat64List(Float64List list);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoList:')
  @SwiftFunction('echo(_:)')
  List<Object?> echoList(List<Object?> list);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoEnumList:')
  @SwiftFunction('echo(enumList:)')
  List<NativeInteropAnEnum?> echoEnumList(List<NativeInteropAnEnum?> enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoClassList:')
  @SwiftFunction('echo(classList:)')
  List<NativeInteropAllNullableTypes?> echoClassList(
    List<NativeInteropAllNullableTypes?> classList,
  );

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNonNullEnumList:')
  @SwiftFunction('echoNonNull(enumList:)')
  List<NativeInteropAnEnum> echoNonNullEnumList(List<NativeInteropAnEnum> enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNonNullClassList:')
  @SwiftFunction('echoNonNull(classList:)')
  List<NativeInteropAllNullableTypes> echoNonNullClassList(
    List<NativeInteropAllNullableTypes> classList,
  );

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
  @SwiftFunction('echo(enumList:)')
  Map<NativeInteropAnEnum?, NativeInteropAnEnum?> echoEnumMap(
    Map<NativeInteropAnEnum?, NativeInteropAnEnum?> enumMap,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoClassMap:')
  @SwiftFunction('echo(classList:)')
  Map<int?, NativeInteropAllNullableTypes?> echoClassMap(
    Map<int?, NativeInteropAllNullableTypes?> classMap,
  );

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
  @SwiftFunction('echoNonNull(enumList:)')
  Map<NativeInteropAnEnum, NativeInteropAnEnum> echoNonNullEnumMap(
    Map<NativeInteropAnEnum, NativeInteropAnEnum> enumMap,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNonNullClassMap:')
  @SwiftFunction('echoNonNull(classList:)')
  Map<int, NativeInteropAllNullableTypes> echoNonNullClassMap(
    Map<int, NativeInteropAllNullableTypes> classMap,
  );

  /// Returns the passed enum to test serialization and deserialization.
  @ObjCSelector('echoEnum:')
  @SwiftFunction('echo(_:)')
  NativeInteropAnEnum echoEnum(NativeInteropAnEnum anEnum);

  /// Returns the passed enum to test serialization and deserialization.
  @ObjCSelector('echoAnotherEnum:')
  @SwiftFunction('echo(_:)')
  NativeInteropAnotherEnum echoNativeInteropAnotherEnum(NativeInteropAnotherEnum anotherEnum);

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

  /// Returns the passed int32 list, to test serialization and deserialization.
  @ObjCSelector('echoNullableInt32List:')
  @SwiftFunction('echoNullable(_:)')
  Int32List? echoNullableInt32List(Int32List? list);

  /// Returns the passed int64 list, to test serialization and deserialization.
  @ObjCSelector('echoNullableInt64List:')
  @SwiftFunction('echoNullable(_:)')
  Int64List? echoNullableInt64List(Int64List? list);

  /// Returns the passed float64 list, to test serialization and deserialization.
  @ObjCSelector('echoNullableFloat64List:')
  @SwiftFunction('echoNullable(_:)')
  Float64List? echoNullableFloat64List(Float64List? list);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableList:')
  @SwiftFunction('echoNullable(_:)')
  List<Object?>? echoNullableList(List<Object?>? list);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableEnumList:')
  @SwiftFunction('echoNullable(enumList:)')
  List<NativeInteropAnEnum?>? echoNullableEnumList(List<NativeInteropAnEnum?>? enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableClassList:')
  @SwiftFunction('echoNullable(classList:)')
  List<NativeInteropAllNullableTypes?>? echoNullableClassList(
    List<NativeInteropAllNullableTypes?>? classList,
  );

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullEnumList:')
  @SwiftFunction('echoNullableNonNull(enumList:)')
  List<NativeInteropAnEnum>? echoNullableNonNullEnumList(List<NativeInteropAnEnum>? enumList);

  /// Returns the passed list, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullClassList:')
  @SwiftFunction('echoNullableNonNull(classList:)')
  List<NativeInteropAllNullableTypes>? echoNullableNonNullClassList(
    List<NativeInteropAllNullableTypes>? classList,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableMap:')
  @SwiftFunction('echoNullable(_:)')
  Map<Object?, Object?>? echoNullableMap(Map<Object?, Object?>? map);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableStringMap:')
  @SwiftFunction('echoNullable(stringMap:)')
  Map<String?, String?>? echoNullableStringMap(Map<String?, String?>? stringMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableIntMap:')
  @SwiftFunction('echoNullable(intMap:)')
  Map<int?, int?>? echoNullableIntMap(Map<int?, int?>? intMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableEnumMap:')
  @SwiftFunction('echoNullable(enumMap:)')
  Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? echoNullableEnumMap(
    Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? enumMap,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableClassMap:')
  @SwiftFunction('echoNullable(classMap:)')
  Map<int?, NativeInteropAllNullableTypes?>? echoNullableClassMap(
    Map<int?, NativeInteropAllNullableTypes?>? classMap,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullStringMap:')
  @SwiftFunction('echoNullableNonNull(stringMap:)')
  Map<String, String>? echoNullableNonNullStringMap(Map<String, String>? stringMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullIntMap:')
  @SwiftFunction('echoNullableNonNull(intMap:)')
  Map<int, int>? echoNullableNonNullIntMap(Map<int, int>? intMap);

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullEnumMap:')
  @SwiftFunction('echoNullableNonNull(enumMap:)')
  Map<NativeInteropAnEnum, NativeInteropAnEnum>? echoNullableNonNullEnumMap(
    Map<NativeInteropAnEnum, NativeInteropAnEnum>? enumMap,
  );

  /// Returns the passed map, to test serialization and deserialization.
  @ObjCSelector('echoNullableNonNullClassMap:')
  @SwiftFunction('echoNullableNonNull(classMap:)')
  Map<int, NativeInteropAllNullableTypes>? echoNullableNonNullClassMap(
    Map<int, NativeInteropAllNullableTypes>? classMap,
  );

  /// Returns the passed enum to test serialization and deserialization.
  @ObjCSelector('echoNullableEnum:')
  @SwiftFunction('echoNullable(_:)')
  NativeInteropAnEnum? echoNullableEnum(NativeInteropAnEnum? anEnum);

  /// Returns the passed enum to test serialization and deserialization.
  @ObjCSelector('echoAnotherNullableEnum:')
  @SwiftFunction('echoNullable(_:)')
  NativeInteropAnotherEnum? echoAnotherNullableEnum(NativeInteropAnotherEnum? anotherEnum);

  // ========== Async tests ==========

  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic asynchronous calling.
  @async
  void noopAsync();

  @async
  Object? throwFlutterErrorAsync();

  @async
  NativeInteropAllTypes echoAsyncNativeInteropAllTypes(NativeInteropAllTypes everything);

  @async
  NativeInteropAllNullableTypes? echoAsyncNullableNativeInteropAllNullableTypes(
    NativeInteropAllNullableTypes? everything,
  );

  @async
  NativeInteropAllNullableTypesWithoutRecursion?
  echoAsyncNullableNativeInteropAllNullableTypesWithoutRecursion(
    NativeInteropAllNullableTypesWithoutRecursion? everything,
  );

  @async
  bool echoAsyncBool(bool aBool);

  @async
  int echoAsyncInt(int anInt);

  @async
  double echoAsyncDouble(double aDouble);

  @async
  String echoAsyncString(String aString);

  @async
  Uint8List echoAsyncUint8List(Uint8List list);

  @async
  Int32List echoAsyncInt32List(Int32List list);

  @async
  Int64List echoAsyncInt64List(Int64List list);

  @async
  Float64List echoAsyncFloat64List(Float64List list);

  @async
  Object echoAsyncObject(Object anObject);

  @async
  List<Object?> echoAsyncList(List<Object?> list);

  @async
  List<NativeInteropAnEnum?> echoAsyncEnumList(List<NativeInteropAnEnum?> enumList);

  @async
  List<NativeInteropAllNullableTypes?> echoAsyncClassList(
    List<NativeInteropAllNullableTypes?> classList,
  );

  @async
  List<NativeInteropAnEnum> echoAsyncNonNullEnumList(List<NativeInteropAnEnum> enumList);

  @async
  List<NativeInteropAllNullableTypes> echoAsyncNonNullClassList(
    List<NativeInteropAllNullableTypes> classList,
  );

  @async
  Map<Object?, Object?> echoAsyncMap(Map<Object?, Object?> map);

  @async
  Map<String?, String?> echoAsyncStringMap(Map<String?, String?> stringMap);

  @async
  Map<int?, int?> echoAsyncIntMap(Map<int?, int?> intMap);

  @async
  Map<NativeInteropAnEnum?, NativeInteropAnEnum?> echoAsyncEnumMap(
    Map<NativeInteropAnEnum?, NativeInteropAnEnum?> enumMap,
  );

  @async
  Map<int?, NativeInteropAllNullableTypes?> echoAsyncClassMap(
    Map<int?, NativeInteropAllNullableTypes?> classMap,
  );

  @async
  NativeInteropAnEnum echoAsyncEnum(NativeInteropAnEnum anEnum);

  @async
  NativeInteropAnotherEnum echoAnotherAsyncEnum(NativeInteropAnotherEnum anotherEnum);

  @async
  bool? echoAsyncNullableBool(bool? aBool);

  @async
  int? echoAsyncNullableInt(int? anInt);

  @async
  double? echoAsyncNullableDouble(double? aDouble);

  @async
  String? echoAsyncNullableString(String? aString);

  @async
  Uint8List? echoAsyncNullableUint8List(Uint8List? list);

  @async
  Int32List? echoAsyncNullableInt32List(Int32List? list);

  @async
  Int64List? echoAsyncNullableInt64List(Int64List? list);

  @async
  Float64List? echoAsyncNullableFloat64List(Float64List? list);

  @async
  Object? echoAsyncNullableObject(Object? anObject);

  @async
  List<Object?>? echoAsyncNullableList(List<Object?>? list);

  @async
  List<NativeInteropAnEnum?>? echoAsyncNullableEnumList(List<NativeInteropAnEnum?>? enumList);

  @async
  List<NativeInteropAllNullableTypes?>? echoAsyncNullableClassList(
    List<NativeInteropAllNullableTypes?>? classList,
  );

  @async
  List<NativeInteropAnEnum>? echoAsyncNullableNonNullEnumList(List<NativeInteropAnEnum>? enumList);

  @async
  List<NativeInteropAllNullableTypes>? echoAsyncNullableNonNullClassList(
    List<NativeInteropAllNullableTypes>? classList,
  );

  @async
  Map<Object?, Object?>? echoAsyncNullableMap(Map<Object?, Object?>? map);

  @async
  Map<String?, String?>? echoAsyncNullableStringMap(Map<String?, String?>? stringMap);

  @async
  Map<int?, int?>? echoAsyncNullableIntMap(Map<int?, int?>? intMap);

  @async
  Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? echoAsyncNullableEnumMap(
    Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? enumMap,
  );

  @async
  Map<int?, NativeInteropAllNullableTypes?>? echoAsyncNullableClassMap(
    Map<int?, NativeInteropAllNullableTypes?>? classMap,
  );

  @async
  NativeInteropAnEnum? echoAsyncNullableEnum(NativeInteropAnEnum? anEnum);

  @async
  NativeInteropAnotherEnum? echoAnotherAsyncNullableEnum(NativeInteropAnotherEnum? anotherEnum);
}
