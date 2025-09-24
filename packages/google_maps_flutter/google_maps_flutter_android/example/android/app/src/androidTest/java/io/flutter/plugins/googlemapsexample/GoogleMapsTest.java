// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemapsexample;

import static org.junit.Assert.assertTrue;

import androidx.test.core.app.ActivityScenario;
import io.flutter.plugins.googlemaps.GoogleMapsPlugin;
import org.junit.Test;

public class GoogleMapsTest {
  @Test
  public void googleMapsPluginIsAdded() {
    final ActivityScenario<GoogleMapsTestActivity> scenario =
        ActivityScenario.launch(GoogleMapsTestActivity.class);
    scenario.onActivity(
        activity -> {
          assertTrue(activity.engine.getPlugins().has(GoogleMapsPlugin.class));
        });
  }
}
