// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

class TestMessage {
  // ignore: always_specify_types, strict_raw_type
  List? testList;
}

@HostApi()
abstract class TestApi {
  void test(TestMessage msg);
}

@FlutterApi()
abstract class EchoApi {
  TestMessage echo(TestMessage msg);
}
