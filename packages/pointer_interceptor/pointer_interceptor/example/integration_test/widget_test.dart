// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // TODO(louisehsu): given the difficulty of making the same integration tests
  // work for both web and ios implementations, please find tests in their respective
  // platform implementation packages.
  testWidgets('placeholder test', (WidgetTester tester) async {});
}
