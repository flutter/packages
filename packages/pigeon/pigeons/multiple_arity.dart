// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is an example pigeon file that is used in compilation, unit, mock
// handler, and e2e tests.

import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class MultipleArityHostApi {
  int subtract(int x, int y);
}

@FlutterApi()
abstract class MultipleArityFlutterApi {
  int subtract(int x, int y);
}
