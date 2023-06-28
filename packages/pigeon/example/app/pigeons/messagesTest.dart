// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

// This file and ./messages.dart must be identical below this line.

// #docregion host-definitions
enum Code { one, two }

class MessageData {
  MessageData({required this.code, required this.data});
  String? name;
  String? description;
  Code code;
  Map<String?, String?> data;
}

@HostApi()
abstract class ExampleHostApi {
  String getHostLanguage();
  int add(int a, int b);
  @async
  bool sendMessage(MessageData message);
}
// #enddocregion host-definitions

// #docregion flutter-definitions
@FlutterApi()
abstract class MessageFlutterApi {
  String flutterMethod(String? aString);
}
// #enddocregion flutter-definitions
