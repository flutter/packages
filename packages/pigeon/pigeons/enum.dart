// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

enum State {
  Pending,
  Success,
  Error,
}

class Data {
  State? state;
}

@HostApi()
abstract class EnumApi2Host {
  Data echo(Data data);
}

@FlutterApi()
abstract class EnumApi2Flutter {
  Data echo(Data data);
}
