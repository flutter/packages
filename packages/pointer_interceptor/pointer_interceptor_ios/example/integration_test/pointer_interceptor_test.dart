// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Full tests are done via XCUITest and can be found in RunnerUITests.
  // This test just validates that the example builds and launches successfully.
  testWidgets('launch test', (WidgetTester tester) async {});
}
