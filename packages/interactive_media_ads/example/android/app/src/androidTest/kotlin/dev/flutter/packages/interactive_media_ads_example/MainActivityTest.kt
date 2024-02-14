// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads_example

import androidx.test.rule.ActivityTestRule
import dev.flutter.plugins.integration_test.FlutterTestRunner
import io.flutter.plugins.DartIntegrationTest
import org.junit.Rule
import org.junit.runner.RunWith

@DartIntegrationTest
@RunWith(FlutterTestRunner::class)
class MainActivityTest {
  @JvmField @Rule var rule = ActivityTestRule(MainActivity::class.java)
}
