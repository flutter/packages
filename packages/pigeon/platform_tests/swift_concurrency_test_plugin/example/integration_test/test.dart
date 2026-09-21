// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:integration_test/integration_test.dart';
import 'package:shared_test_plugin_code/integration_tests.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  runPigeonIntegrationTests(TargetGenerator.swift);
}
