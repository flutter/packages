// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepickerexample;

import static org.junit.Assert.assertTrue;

import androidx.test.ext.junit.rules.ActivityScenarioRule;
import io.flutter.plugins.imagepicker.ImagePickerPlugin;
import org.junit.Rule;
import org.junit.Test;

public class ImagePickerTest {
  @Rule
  public ActivityScenarioRule<ImagePickerTestActivity> myActivityTestRule =
      new ActivityScenarioRule<>(ImagePickerTestActivity.class);

  @Test
  public void imagePickerPluginIsAdded() {
    myActivityTestRule
        .getScenario()
        .onActivity(
            activity -> {
              assertTrue(activity.engine.getPlugins().has(ImagePickerPlugin.class));
            });
  }
}
