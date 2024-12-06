// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package dev.flutter.plugins.shared_preferences_example

import androidx.test.rule.ActivityTestRule
import dev.flutter.plugins.DartIntegrationTest
import dev.flutter.plugins.integration_test.FlutterTestRunner
import io.flutter.embedding.android.FlutterActivity
import org.junit.Rule
import org.junit.runner.RunWith

@DartIntegrationTest
@RunWith(FlutterTestRunner::class)
class MainActivityTest {
    @Rule
    var rule: ActivityTestRule<FlutterActivity> = ActivityTestRule(
        FlutterActivity::class.java
    )
}