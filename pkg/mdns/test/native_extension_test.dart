// Copyright (c) 2015, the Dartino project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

import 'dart:async';

import 'package:expect/expect.dart';
import 'package:mdns/src/native_extension_client.dart';

Future<Null> main() async {
  String message1 = 'Hello, world!';
  String result1 = await nativeExtensionEchoTest(message1);
  Expect.equals(message1, result1);

  List<int> message2 = [1, 2];
  List<int> result2 = await nativeExtensionEchoTest(message2);
  Expect.listEquals(message2, result2);
}
