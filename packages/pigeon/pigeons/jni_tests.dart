// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: always_specify_types, strict_raw_type

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOptions: DartOptions(useJni: true),
  kotlinOptions: KotlinOptions(useJni: true),
))
enum SomeEnum {
  value1,
  value2,
  value3,
}

enum SomeOtherEnum {
  value1,
  value2,
  value3,
}

class SomeTypes {
  const SomeTypes(
    this.aString,
    this.anInt,
    this.aDouble,
    this.aBool,
    this.aByteArray,
    this.a4ByteArray,
    this.a8ByteArray,
    this.aFloatArray,
    this.anObject,
    this.anEnum,
    this.someNullableTypes,
    // Lists
    // This name is in a different format than the others to ensure that name
    // collision with the word 'list' doesn't occur in the generated files.
    this.list,
    this.stringList,
    this.intList,
    this.doubleList,
    this.boolList,
    this.enumList,
    this.classList,
    this.objectList,
    this.listList,
    this.mapList,

    // Maps
    this.map,
    this.stringMap,
    this.intMap,
    this.enumMap,
    this.classMap,
    this.objectMap,
    this.listMap,
    this.mapMap,
  );
  final String aString;
  final int anInt;
  final double aDouble;
  final bool aBool;
  final Uint8List aByteArray;
  final Int32List a4ByteArray;
  final Int64List a8ByteArray;
  final Float64List aFloatArray;
  final Object anObject;
  final SomeEnum anEnum;
  final SomeNullableTypes someNullableTypes;
  // Lists
  final List list;
  final List<String> stringList;
  final List<int> intList;
  final List<double> doubleList;
  final List<bool> boolList;
  final List<SomeEnum> enumList;
  final List<SomeNullableTypes> classList;
  final List<Object> objectList;
  final List<List<Object?>> listList;
  final List<Map<Object?, Object?>> mapList;

  // Maps
  final Map map;
  final Map<String, String> stringMap;
  final Map<int, int> intMap;
  final Map<SomeEnum, SomeEnum> enumMap;
  final Map<SomeNullableTypes, SomeNullableTypes> classMap;
  final Map<Object, Object> objectMap;
  final Map<int, List<Object?>> listMap;
  final Map<int, Map<Object?, Object?>> mapMap;
}

class SomeNullableTypes {
  String? aString;
  int? anInt;
  double? aDouble;
  bool? aBool;
  Uint8List? aByteArray;
  Int32List? a4ByteArray;
  Int64List? a8ByteArray;
  Float64List? aFloatArray;
  Object? anObject;
  SomeEnum? anEnum;
  SomeTypes? someTypes;
  List? list;
  Map? map;
}

@HostApi()
abstract class JniMessageApi {
  void doNothing();
  String echoString(String request);
  int echoInt(int request);
  double echoDouble(double request);
  bool echoBool(bool request);
  Object echoObj(Object request);
  SomeTypes sendSomeTypes(SomeTypes someTypes);
  SomeEnum sendSomeEnum(SomeEnum anEnum);
  List echoList(List list);
  Map echoMap(Map map);
}

@HostApi()
abstract class JniMessageApiNullable {
  String? echoString(String? request);
  int? echoInt(int? request);
  double? echoDouble(double? request);
  bool? echoBool(bool? request);
  Object? echoObj(Object? request);
  SomeNullableTypes? sendSomeNullableTypes(SomeNullableTypes? someTypes);
  SomeEnum? sendSomeEnum(SomeEnum? anEnum);
  List? echoList(List? list);
  Map? echoMap(Map? map);
}

@HostApi()
abstract class JniMessageApiAsync {
  @async
  void doNothing();
  @async
  String echoString(String request);
  @async
  int echoInt(int request);
  @async
  double echoDouble(double request);
  @async
  bool echoBool(bool request);
  @async
  Object echoObj(Object request);
  @async
  SomeTypes sendSomeTypes(SomeTypes someTypes);
  @async
  SomeEnum sendSomeEnum(SomeEnum anEnum);
  @async
  List echoList(List list);
  @async
  Map echoMap(Map map);
}

@HostApi()
abstract class JniMessageApiNullableAsync {
  @async
  String? echoString(String? request);
  @async
  int? echoInt(int? request);
  @async
  double? echoDouble(double? request);
  @async
  bool? echoBool(bool? request);
  @async
  Object? echoObj(Object? request);
  @async
  SomeNullableTypes? sendSomeNullableTypes(SomeNullableTypes? someTypes);
  @async
  SomeEnum? sendSomeEnum(SomeEnum? anEnum);
  @async
  List? echoList(List? list);
  @async
  Map? echoMap(Map? map);
}
