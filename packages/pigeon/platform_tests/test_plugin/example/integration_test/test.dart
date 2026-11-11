// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:shared_test_plugin_code/integration_tests.dart';
import 'package:shared_test_plugin_code/secondary_engine_entrypoints.dart' as secondary_entrypoints;

void main() => runPigeonIntegrationTests(_getTarget());

@pragma('vm:entry-point')
void idleSecondaryEngineMain() => secondary_entrypoints.idleSecondaryEngineMain();

@pragma('vm:entry-point')
Future<void> secondaryEngineMain() => secondary_entrypoints.secondaryEngineMain();

TargetGenerator _getTarget() {
  if (Platform.isAndroid) {
    return TargetGenerator.kotlin;
  }
  if (Platform.isIOS || Platform.isMacOS) {
    return TargetGenerator.swift;
  }
  if (Platform.isLinux) {
    return TargetGenerator.gobject;
  }
  if (Platform.isWindows) {
    return TargetGenerator.cpp;
  }
  throw UnimplementedError('Unsupported target.');
}
