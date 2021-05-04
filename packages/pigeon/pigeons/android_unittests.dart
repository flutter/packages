// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

class SetRequest {
  int? value;
}

class NestedRequest {
  String? context;
  SetRequest? request;
}

@HostApi()
abstract class Api {
  void setValue(SetRequest request);
}

@HostApi()
abstract class NestedApi {
  void setValueWithContext(NestedRequest request);
}
