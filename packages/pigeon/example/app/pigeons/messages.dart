// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

// #docregion config
@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartOptions: DartOptions(),
  cppOptions: CppOptions(namespace: 'pigeon_example'),
  cppHeaderOut: 'windows/runner/messages.g.h',
  cppSourceOut: 'windows/runner/messages.g.cpp',
  kotlinOut:
      'android/app/src/main/kotlin/dev/flutter/pigeon_example_app/Messages.g.kt',
  kotlinOptions: KotlinOptions(),
  javaOut: 'android/app/src/main/java/io/flutter/plugins/Messages.java',
  javaOptions: JavaOptions(),
  swiftOut: 'ios/Runner/Messages.g.swift',
  swiftOptions: SwiftOptions(),
  objcHeaderOut: 'macos/runner/messages_objc.h',
  objcOptions: ObjcOptions(),
  copyrightHeader: 'pigeons/copyright.txt',
))
// #enddocregion config

// #docregion host-definitions
class CreateMessage {
  CreateMessage({required this.code, required this.httpHeaders});
  String? asset;
  String? uri;
  int code;
  Map<String?, String?> httpHeaders;
}

@HostApi()
abstract class ExampleHostApi {
  String getHostLanguage();
  int add(int a, int b);
  @async
  bool sendMessage(CreateMessage message);
}
// #enddocregion host-definitions

@FlutterApi()
abstract class MessageFlutterApi {
  String method(String? aString);
}
