// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

class TestMessage {
  TestMessage({required this.testList});

  // ignore: always_specify_types
  List testList;
}

@HostApi()
abstract class TestApi {
  void test(TestMessage msg);
}
