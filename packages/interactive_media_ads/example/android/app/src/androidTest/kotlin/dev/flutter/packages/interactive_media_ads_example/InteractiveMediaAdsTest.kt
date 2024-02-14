// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads_example

import androidx.test.espresso.flutter.EspressoFlutter.onFlutterWidget
import androidx.test.espresso.flutter.assertion.FlutterAssertions.matches
import androidx.test.espresso.flutter.matcher.FlutterMatchers.isExisting
import androidx.test.espresso.flutter.matcher.FlutterMatchers.withText
import androidx.test.ext.junit.rules.ActivityScenarioRule
import org.junit.Rule

class InteractiveMediaAdsTest {
  @JvmField
  @Rule
  var myActivityTestRule: ActivityScenarioRule<DriverExtensionActivity> =
      ActivityScenarioRule(DriverExtensionActivity::class.java)

  @org.junit.Test
  fun launchTest() {
    println("before onFlutterWidget")
    onFlutterWidget(withText("Running on: TargetPlatform.android")).check(matches(isExisting()))
    println("after onFlutterWidget")
  }
}
