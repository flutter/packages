// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

// #docregion config
@ConfigurePigeon(
  PigeonOptions(
    dartOptions: DartOptions(),
    kotlinOptions: KotlinOptions(useJni: true),
    swiftOptions: SwiftOptions(useFfi: true, ffiModuleName: 'my_plugin'),
  ),
)
// #enddocregion config
@HostApi()
abstract class NativeInteropExampleApi {
  void doSomething();
}
