// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.file_selector_android_example;

import androidx.test.ext.junit.rules.ActivityScenarioRule;
import dev.flutter.plugins.integration_test.FlutterTestRunner;
import io.flutter.plugins.DartIntegrationTest;
import org.junit.Rule;
import org.junit.runner.RunWith;

@DartIntegrationTest
@RunWith(FlutterTestRunner.class)
public class MainActivityTest {
  @Rule
  public ActivityScenarioRule<MainActivity> myActivityTestRule =
      new ActivityScenarioRule<>(MainActivity.class);
}
