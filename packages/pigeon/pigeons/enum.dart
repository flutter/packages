// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

/// This comment is to test enum documentation comments.
enum EnumState {
  Pending,
  Success,
  Error,
}

/// This comment is to test class documentation comments.
class DataWithEnum {
  /// This comment is to test field documentation comments.
  EnumState? state;
}

@HostApi()

/// This comment is to test api documentation comments.
abstract class EnumApi2Host {
  /// This comment is to test method documentation comments.
  DataWithEnum echo(DataWithEnum data);
}

@FlutterApi()

/// This comment is to test api documentation comments.
abstract class EnumApi2Flutter {
  /// This comment is to test method documentation comments.
  DataWithEnum echo(DataWithEnum data);
}
