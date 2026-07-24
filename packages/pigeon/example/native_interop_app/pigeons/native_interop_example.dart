// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

// #docregion config
@ConfigurePigeon(
  PigeonOptions(
    dartOptions: DartOptions(),
    kotlinOptions: KotlinOptions(
      useJni: true,
      // Optional: Paths to search for compiled local classes (primarily needed for standalone Apps)
      jniClassPaths: <String>['build/app/tmp/kotlin-classes/release'],
    ),
    swiftOptions: SwiftOptions(useFfi: true, ffiModuleName: 'Runner'),
  ),
)
// #enddocregion config
@HostApi()
abstract class NativeInteropExampleApi {
  void doSomething();
}
