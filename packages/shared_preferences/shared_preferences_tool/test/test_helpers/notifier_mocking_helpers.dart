// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_tool/src/async_state.dart';
import 'package:shared_preferences_tool/src/shared_preferences_state.dart';
import 'package:shared_preferences_tool/src/shared_preferences_state_notifier.dart';

@GenerateNiceMocks(<MockSpec<dynamic>>[
  MockSpec<SharedPreferencesStateNotifier>(),
])
// ignore: unused_import
import 'notifier_mocking_helpers.mocks.dart';

void setupDummies() {
  setUpAll(() {
    provideDummy(
      const AsyncState<SharedPreferencesData>.data(
        SharedPreferencesData.int(value: 42),
      ),
    );
    provideDummy(
      const AsyncState<SharedPreferencesState>.data(
        SharedPreferencesState(),
      ),
    );
  });
}
