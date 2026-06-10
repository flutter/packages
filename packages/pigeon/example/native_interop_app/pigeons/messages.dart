// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    appDirectory: 'example/native_interop_app',
    dartOut: 'lib/src/messages.g.dart',
    dartOptions: DartOptions(),
    cppOptions: CppOptions(namespace: 'pigeon_example'),
    cppHeaderOut: 'windows/runner/messages.g.h',
    cppSourceOut: 'windows/runner/messages.g.cpp',
    gobjectHeaderOut: 'linux/messages.g.h',
    gobjectSourceOut: 'linux/messages.g.cc',
    gobjectOptions: GObjectOptions(),
    kotlinOut: 'android/app/src/main/kotlin/dev/flutter/pigeon_example_app/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'dev.flutter.pigeon_example_app', useJni: true),
    javaOut: 'android/app/src/main/java/io/flutter/plugins/Messages.java',
    javaOptions: JavaOptions(package: 'io.flutter.plugins'),
    swiftOut: 'ios/Runner/Messages.g.swift',
    swiftOptions: SwiftOptions(useFfi: true),
    objcHeaderOut: 'macos/Runner/messages.g.h',
    objcSourceOut: 'macos/Runner/messages.g.m',
    // Set this to a unique prefix for your plugin or application, per Objective-C naming conventions.
    objcOptions: ObjcOptions(prefix: 'PGN'),
    copyrightHeader: 'pigeons/copyright.txt',
    dartPackageName: 'pigeon_example_package',
  ),
)
enum Code { one, two }

class MessageData {
  MessageData({required this.code, required this.data});
  String? name;
  String? messageDescription;
  Code code;
  Map<String, String> data;
}

@HostApi()
abstract class ExampleHostApi {
  String determineHostLanguage();

  // These annotations create more idiomatic naming of methods in Objc and Swift.
  @ObjCSelector('addNumber:toNumber:')
  @SwiftFunction('add(_:to:)')
  int add(int a, int b);

  @async
  bool sendMessage(MessageData message);
}

@FlutterApi()
abstract class MessageFlutterApi {
  String flutterMethod(String? aString);
}
