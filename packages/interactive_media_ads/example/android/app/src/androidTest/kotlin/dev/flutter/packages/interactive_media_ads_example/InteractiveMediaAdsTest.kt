// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads_example

import androidx.test.espresso.intent.rule.IntentsRule
import androidx.test.ext.junit.rules.ActivityScenarioRule
import org.junit.Rule

class InteractiveMediaAdsTest {
  @JvmField
  @Rule
  var myActivityTestRule: ActivityScenarioRule<DriverExtensionActivity> =
      ActivityScenarioRule(DriverExtensionActivity::class.java)

  @JvmField @Rule var intentsRule = IntentsRule()

  @org.junit.Test fun placeholderIntegrationTest() {}
}
