// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:android_local_network/android_local_network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('checkPermission returns true on non-Android', () async {
    if (!Platform.isAndroid) {
      expect(await AndroidLocalNetwork.checkPermission(), isTrue);
    }
  });

  test('requestPermission returns true on non-Android', () async {
    if (!Platform.isAndroid) {
      expect(await AndroidLocalNetwork.requestPermission(), isTrue);
    }
  });
}
