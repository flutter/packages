// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

enum EventEnum {
  one,
  two,
  three,
  fortyTwo,
  fourHundredTwentyTwo,
}

// Enums require special logic, having multiple ensures that the logic can be
// replicated without collision.
enum AnotherEventEnum {
  justInCase,
}

/// A class containing all supported nullable types.
@SwiftClass()
class EventAllNullableTypes {
  EventAllNullableTypes(
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
  EventEnum? aNullableEnum;
  AnotherEventEnum? anotherNullableEnum;
  String? aNullableString;
  Object? aNullableObject;
  EventAllNullableTypes? allNullableTypes;

  // Lists
  // ignore: strict_raw_type, always_specify_types
  List? list;
  List<String?>? stringList;
  List<int?>? intList;
  List<double?>? doubleList;
  List<bool?>? boolList;
  List<EventEnum?>? enumList;
  List<Object?>? objectList;
  List<List<Object?>?>? listList;
  List<Map<Object?, Object?>?>? mapList;
  List<EventAllNullableTypes?>? recursiveClassList;

  // Maps
  // ignore: strict_raw_type, always_specify_types
  Map? map;
  Map<String?, String?>? stringMap;
  Map<int?, int?>? intMap;
  Map<EventEnum?, EventEnum?>? enumMap;
  Map<Object?, Object?>? objectMap;
  Map<int?, List<Object?>?>? listMap;
  Map<int?, Map<Object?, Object?>?>? mapMap;
  Map<int?, EventAllNullableTypes?>? recursiveClassMap;
}

sealed class PlatformEvent {}

class IntEvent extends PlatformEvent {
  IntEvent(this.value);
  final int value;
}

class StringEvent extends PlatformEvent {
  StringEvent(this.value);
  final String value;
}

class BoolEvent extends PlatformEvent {
  BoolEvent(this.value);
  final bool value;
}

class DoubleEvent extends PlatformEvent {
  DoubleEvent(this.value);
  final double value;
}

class ObjectsEvent extends PlatformEvent {
  ObjectsEvent(this.value);
  final Object value;
}

class EnumEvent extends PlatformEvent {
  EnumEvent(this.value);
  final EventEnum value;
}

class ClassEvent extends PlatformEvent {
  ClassEvent(this.value);
  final EventAllNullableTypes value;
}

@EventChannelApi()
abstract class EventChannelMethods {
  int streamInts();
  PlatformEvent streamEvents();
  int streamConsistentNumbers();
}
