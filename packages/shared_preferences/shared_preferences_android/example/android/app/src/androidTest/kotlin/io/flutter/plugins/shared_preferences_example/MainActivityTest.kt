// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins

import androidx.test.rule.ActivityTestRule
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugins.integration_test.FlutterTestRunner
import org.junit.Rule
import org.junit.runner.RunWith

@DartIntegrationTest
@RunWith(FlutterTestRunner::class)
class MainActivityTest {
  @Rule var rule: ActivityTestRule<FlutterActivity> = ActivityTestRule(FlutterActivity::class.java)
}
