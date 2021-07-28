// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class PrimitiveHostApi {
  int anInt(int value);
  bool aBool(bool value);
  String aString(String value);
  double aDouble(double value);
  // ignore: always_specify_types
  Map aMap(Map value);
  // ignore: always_specify_types
  List aList(List value);
  Int32List anInt32List(Int32List value);
}

@FlutterApi()
abstract class PrimitiveFlutterApi {
  int anInt(int value);
  bool aBool(bool value);
  String aString(String value);
  double aDouble(double value);
  // ignore: always_specify_types
  Map aMap(Map value);
  // ignore: always_specify_types
  List aList(List value);
  Int32List anInt32List(Int32List value);
}
