// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/event_channel_messages.g.dart',
  dartOptions: DartOptions(),
  cppOptions: CppOptions(namespace: 'pigeon_example'),
  kotlinOut:
      'android/app/src/main/kotlin/dev/flutter/pigeon_example_app/EventChannelMessages.g.kt',
  kotlinOptions: KotlinOptions(
    includeErrorClass: false,
  ),
  swiftOut: 'ios/Runner/EventChannelMessages.g.swift',
  swiftOptions: SwiftOptions(
    includeErrorClass: false,
  ),
  copyrightHeader: 'pigeons/copyright.txt',
  dartPackageName: 'pigeon_example_package',
))

// #docregion sealed-definitions
sealed class PlatformEvent {}

class IntEvent extends PlatformEvent {
  IntEvent(this.data);
  int data;
}

class StringEvent extends PlatformEvent {
  StringEvent(this.data);
  String data;
}
// #enddocregion sealed-definitions

// #docregion event-definitions
@EventChannelApi()
abstract class EventChannelMethods {
  PlatformEvent streamEvents();
}
// #enddocregion event-definitions
