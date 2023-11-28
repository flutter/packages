// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Integration tests for iOS requires a native platform view and thus
  // can not be tested in Dart. These tests can instead
  // be found in the XCUITests
  testWidgets('placeholder test', (WidgetTester tester) async {});
}
