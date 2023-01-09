// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:shared_test_plugin_code/integration_tests.dart';

void main() => runPigeonIntegrationTests(_getTarget());

TargetGenerator _getTarget() {
  if (Platform.isAndroid) {
    return TargetGenerator.kotlin;
  }
  if (Platform.isIOS || Platform.isMacOS) {
    return TargetGenerator.swift;
  }
  if (Platform.isWindows) {
    return TargetGenerator.cpp;
  }
  throw UnimplementedError('Unsupported target.');
}
