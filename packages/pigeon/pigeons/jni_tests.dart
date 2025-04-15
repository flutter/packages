// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOptions: DartOptions(useJni: true),
  kotlinOptions: KotlinOptions(useJni: true),
))
class SomeTypes {
  const SomeTypes(this.aString, this.anInt, this.aDouble, this.aBool);
  final String aString;
  final int anInt;
  final double aDouble;
  final bool aBool;
  // Object anObject;
}

class SomeNullableTypes {
  String? aString;
  int? anInt;
  double? aDouble;
  bool? aBool;
  // Object? anObject;
}

@HostApi()
abstract class JniMessageApi {
  void doNothing();
  String echoString(String request);
  int echoInt(int request);
  double echoDouble(double request);
  bool echoBool(bool request);
  SomeTypes sendSomeTypes(SomeTypes someTypes);
}

@HostApi()
abstract class JniMessageApiNullable {
  String? echoString(String? request);
  int? echoInt(int? request);
  double? echoDouble(double? request);
  bool? echoBool(bool? request);
  SomeNullableTypes? sendSomeNullableTypes(SomeNullableTypes? someTypes);
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
  SomeTypes sendSomeTypes(SomeTypes someTypes);
}

// @HostApi()
// abstract class JniMessageApiNullableAsync {
//   @async
//   String? echoString(String? request);
//   @async
//   int? echoInt(int? request);
//   @async
//   double? echoDouble(double? request);
//   @async
//   bool? echoBool(bool? request);
//   @async
//   SomeNullableTypes? sendSomeNullableTypes(SomeNullableTypes? someTypes);
// }
