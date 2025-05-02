// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayerexample;

import static androidx.test.espresso.flutter.EspressoFlutter.WidgetInteraction;
import static androidx.test.espresso.flutter.EspressoFlutter.onFlutterWidget;
import static androidx.test.espresso.flutter.action.FlutterActions.click;
import static androidx.test.espresso.flutter.assertion.FlutterAssertions.matches;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.isExisting;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withText;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withValueKey;

import androidx.test.ext.junit.rules.ActivityScenarioRule;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import org.junit.Ignore;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
public class VideoPlayerUITest {
  @Rule
  public ActivityScenarioRule<DriverExtensionActivity> activityRule =
      new ActivityScenarioRule<>(DriverExtensionActivity.class);

  @Test
  @Ignore("Doesn't run in Firebase Test Lab: https://github.com/flutter/flutter/issues/94748")
  public void playVideo() {
    WidgetInteraction remoteTab = onFlutterWidget(withText("Remote"));
    remoteTab.check(matches(isExisting()));

    for (String tabName : new String[] {"Platform view", "Texture view"}) {
      WidgetInteraction viewTypeTab = onFlutterWidget(withText(tabName));
      viewTypeTab.check(matches(isExisting()));
      viewTypeTab.perform(click());

      WidgetInteraction playButton = onFlutterWidget(withValueKey("Play"));
      playButton.check(matches(isExisting()));
      playButton.perform(click());

      WidgetInteraction playbackSpeed1x = onFlutterWidget(withText("1.0x"));
      playbackSpeed1x.check(matches(isExisting()));
      playbackSpeed1x.perform(click());

      WidgetInteraction playbackSpeed5xButton = onFlutterWidget(withText("5.0x"));
      playbackSpeed5xButton.check(matches(isExisting()));
      playbackSpeed5xButton.perform(click());

      WidgetInteraction playbackSpeed5x = onFlutterWidget(withText("5.0x"));
      playbackSpeed5x.check(matches(isExisting()));
    }

    for (String[] tabData :
        new String[][] {{"Asset", "With assets mp4"}, {"Remote", "With remote mp4"}}) {
      String tabName = tabData[0];
      String videoDescription = tabData[1];
      WidgetInteraction tab = onFlutterWidget(withText(tabName));
      WidgetInteraction tabDescription = onFlutterWidget(withText(videoDescription));
      tab.check(matches(isExisting()));

      // TODO(FirentisTFW): Assert that testDescription is not visible before we tap on tab.
      //  This should be done once the Espresso API allows us to perform such an assertion. See
      //  https://github.com/flutter/flutter/issues/160599

      tab.perform(click());

      tab.check(matches(isExisting()));
      tabDescription.check(matches(isExisting()));
    }
  }
}
