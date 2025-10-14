// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class PrimitiveHostApi {
  int anInt(int value);
  bool aBool(bool value);
  String aString(String value);
  double aDouble(double value);
  // ignore: always_specify_types, strict_raw_type
  Map aMap(Map value);
  // ignore: always_specify_types, strict_raw_type
  List aList(List value);
  Int32List anInt32List(Int32List value);
  List<bool?> aBoolList(List<bool?> value);
  Map<String?, int?> aStringIntMap(Map<String?, int?> value);
}

@FlutterApi()
abstract class PrimitiveFlutterApi {
  int anInt(int value);
  bool aBool(bool value);
  String aString(String value);
  double aDouble(double value);
  // ignore: always_specify_types, strict_raw_type
  Map aMap(Map value);
  // ignore: always_specify_types, strict_raw_type
  List aList(List value);
  Int32List anInt32List(Int32List value);
  List<bool?> aBoolList(List<bool?> value);
  Map<String?, int?> aStringIntMap(Map<String?, int?> value);
}
