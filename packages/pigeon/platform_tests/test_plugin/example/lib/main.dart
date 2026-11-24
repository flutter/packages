// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:shared_test_plugin_code/example_app.dart';
import 'package:shared_test_plugin_code/secondary_engine_entrypoints.dart' as secondary_entrypoints;

void main() {
  runApp(const ExampleApp());
}

/// Entrypoint for a passive secondary `FlutterEngine` used in lifecycle tests.
@pragma('vm:entry-point')
void idleSecondaryEngineMain() {
  secondary_entrypoints.idleSecondaryEngineMain();
}

/// Entrypoint for an active secondary `FlutterEngine` used in multi-engine tests.
@pragma('vm:entry-point')
Future<void> secondaryEngineMain() {
  return secondary_entrypoints.secondaryEngineMain();
}
