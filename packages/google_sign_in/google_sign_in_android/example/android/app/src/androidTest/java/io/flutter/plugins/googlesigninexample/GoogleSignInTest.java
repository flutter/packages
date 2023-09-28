// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlesigninexample;

import static org.junit.Assert.assertTrue;

import androidx.test.ext.junit.rules.ActivityScenarioRule;
import io.flutter.plugins.googlesignin.GoogleSignInPlugin;
import org.junit.Rule;
import org.junit.Test;

public class GoogleSignInTest {
  @Rule
  public ActivityScenarioRule<GoogleSignInTestActivity> myActivityTestRule =
      new ActivityScenarioRule<>(GoogleSignInTestActivity.class);

  @Test
  public void googleSignInPluginIsAdded() {
    myActivityTestRule
        .getScenario()
        .onActivity(
            activity -> {
              assertTrue(activity.engine.getPlugins().has(GoogleSignInPlugin.class));
            });
  }
}
