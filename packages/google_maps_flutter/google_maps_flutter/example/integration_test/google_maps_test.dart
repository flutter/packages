// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:integration_test/integration_test.dart';

import 'src/maps_controller.dart' as maps_controller;
import 'src/maps_inspector.dart' as maps_inspector;
import 'src/tiles_inspector.dart' as tiles_inspector;

/// Recombine all test files in `src` into a single test app.
///
/// This is done to ensure that all the integration tests run in the same FTL app,
/// rather than spinning multiple different tasks.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  maps_controller.runTests();
  maps_inspector.runTests();
  tiles_inspector.runTests();
}
