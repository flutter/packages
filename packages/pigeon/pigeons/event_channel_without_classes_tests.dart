// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@EventChannelApi(
    swiftOptions: SwiftEventChannelOptions(includeSharedClasses: false),
    kotlinOptions: KotlinEventChannelOptions(includeSharedClasses: false))
abstract class EventChannelMethods {
  int streamIntsAgain();
}
