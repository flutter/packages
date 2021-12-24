// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/services.dart';

// ignore: avoid_classes_with_only_static_members
class WindowsUnitTests {
  static const MethodChannel _channel = MethodChannel('windows_unit_tests');

  static Future<bool?> get checkPlaceholder async {
    final bool? result = await _channel.invokeMethod('placeholder');
    return result;
  }
}
