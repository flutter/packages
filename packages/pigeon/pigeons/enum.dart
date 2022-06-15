// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

enum EnumState {
  Pending,
  Success,
  Error,
}

class DataWithEnum {
  EnumState? state;
}

@HostApi()
abstract class EnumApi2Host {
  DataWithEnum echo(DataWithEnum data);
}

@FlutterApi()
abstract class EnumApi2Flutter {
  DataWithEnum echo(DataWithEnum data);
}
