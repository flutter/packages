// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

class Everything {
  bool? aBool;
  int? anInt;
  double? aDouble;
  String? aString;
  Uint8List? aByteArray;
  Int32List? a4ByteArray;
  Int64List? a8ByteArray;
  Float64List? aFloatArray;
  // ignore: always_specify_types, strict_raw_type
  List? aList;
  // ignore: always_specify_types, strict_raw_type
  Map? aMap;
  List<List<bool?>?>? nestedList;
  Map<String?, String?>? mapWithAnnotations;
  Map<String?, Object?>? mapWithObject;
}

@HostApi()
abstract class HostEverything {
  Everything giveMeEverything();
  Everything echo(Everything everything);
}

@FlutterApi()
abstract class FlutterEverything {
  Everything giveMeEverything();
  Everything echo(Everything everything);
}
