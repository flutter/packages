// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is an example pigeon file that is used in compilation, unit, mock
// handler, and e2e tests.

import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class NullableReturnHostApi {
  int? doit();
}

@FlutterApi()
abstract class NullableReturnFlutterApi {
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

@HostApi()
abstract class NullableCollectionReturnHostApi {
  List<String?>? doit();
}

@FlutterApi()
abstract class NullableCollectionReturnFlutterApi {
  List<String?>? doit();
}

@HostApi()
abstract class NullableCollectionArgHostApi {
  List<String?> doit(List<String?>? x);
}

@FlutterApi()
abstract class NullableCollectionArgFlutterApi {
  List<String?> doit(List<String?>? x);
}
