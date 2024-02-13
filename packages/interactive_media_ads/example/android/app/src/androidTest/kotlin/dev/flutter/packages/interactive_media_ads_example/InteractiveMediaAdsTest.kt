// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads_example

import androidx.test.ext.junit.rules.ActivityScenarioRule
import dev.flutter.plugins.interactive_media_ads_example.DriverExtensionActivity
import org.junit.Rule

class InteractiveMediaAdsTest {
  @JvmField
  @Rule
  var myActivityTestRule: ActivityScenarioRule<DriverExtensionActivity> =
      ActivityScenarioRule(DriverExtensionActivity::class.java)

  @org.junit.Test fun placeholderIntegrationTest() {}
}
