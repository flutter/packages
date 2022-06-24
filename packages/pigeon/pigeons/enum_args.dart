// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

enum EnumArgsState {
  Pending,
  Success,
  Error,
}

class EnumArgsData {
  EnumArgsState? state;
}

@HostApi()
abstract class EnumArgs2Host {
  void foo(EnumArgsState state);
}
