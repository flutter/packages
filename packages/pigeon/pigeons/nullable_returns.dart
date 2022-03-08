// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is an example pigeon file that is used in compilation, unit, mock
// handler, and e2e tests.

import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class NonNullHostApi {
  int? doit();
}

@FlutterApi()
abstract class NonNullFlutterApi {
  int? doit();
}

@HostApi()
abstract class NullableArgHostApi {
  int doit(int? x);
}

@FlutterApi()
abstract class NullableArgFlutterApi {
  int doit(int? x);
}
