// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

class SetRequest {
  SetRequest({required this.value});

  int value;
}

@FlutterApi()
abstract class Api {
  void setValue(SetRequest request);
}
