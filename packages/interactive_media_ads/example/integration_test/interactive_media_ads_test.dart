// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Since this test is lacking integration tests, this test ensures the example
  // app can be launched on an emulator/device.
  testWidgets('Launch Test', (WidgetTester tester) async {});
}
