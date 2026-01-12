// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

// This file exists to test compilation for multi-file event channel usage.

@EventChannelApi(
  swiftOptions: SwiftEventChannelOptions(includeSharedClasses: false),
  kotlinOptions: KotlinEventChannelOptions(includeSharedClasses: false),
)
abstract class EventChannelMethods {
  int streamIntsAgain();
}
