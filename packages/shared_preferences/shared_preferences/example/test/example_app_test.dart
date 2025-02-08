// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_example/main.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../test/shared_preferences_async_test.dart';

void main() {
  group('SharedPreferences example app', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance = FakeSharedPreferencesAsync();
    });

    tearDown(() {
      SharedPreferencesAsyncPlatform.instance = null;
    });

    testWidgets('builds successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
    });
  });
}
