// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

class Everything {
  Everything({
    required this.aBool,
    required this.anInt,
    required this.aDouble,
    required this.aString,
    required this.aByteArray,
    required this.a4ByteArray,
    required this.a8ByteArray,
    required this.aFloatArray,
    required this.aList,
    required this.aMap,
  });

  bool aBool;
  int anInt;
  double aDouble;
  String aString;
  Uint8List aByteArray;
  Int32List a4ByteArray;
  Int64List a8ByteArray;
  Float64List aFloatArray;
  // ignore: always_specify_types
  List aList;
  // ignore: always_specify_types
  Map aMap;
}

@HostApi()
abstract class HostEverything {
  Everything giveMeEverything();
}

@FlutterApi()
abstract class FlutterEverything {
  Everything giveMeEverything();
}
