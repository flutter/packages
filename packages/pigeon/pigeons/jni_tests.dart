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
@HostApi()
abstract class JniHostIntegrationCoreApi {
  void noop();
  int echoInt(int anInt);
  double echoDouble(double aDouble);
  bool echoBool(bool aBool);
  String echoString(String aString);
}
