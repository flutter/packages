// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

// This file exists to test compilation for multi-file stream HostApi usage.

@HostApi()
abstract class SecondFileStreamHostTestApi {
  Stream<int> streamIntsAgain();

  @asyncCallback
  Stream<int> streamIntsViaCallbackAgain();
}
