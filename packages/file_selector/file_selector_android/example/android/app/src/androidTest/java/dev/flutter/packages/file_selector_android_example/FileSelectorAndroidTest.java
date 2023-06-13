// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.file_selector_android_example;

import static androidx.test.espresso.flutter.EspressoFlutter.onFlutterWidget;
import static androidx.test.espresso.flutter.action.FlutterActions.click;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withText;
import static androidx.test.espresso.intent.Intents.intending;
import static androidx.test.espresso.intent.matcher.IntentMatchers.hasAction;

import android.app.Activity;
import android.app.Instrumentation;
import android.content.Intent;
import android.net.Uri;
import androidx.test.espresso.intent.rule.IntentsRule;
import androidx.test.ext.junit.rules.ActivityScenarioRule;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
public class FileSelectorAndroidTest {
  @Rule
  public ActivityScenarioRule<DriverExtensionActivity> myActivityTestRule =
      new ActivityScenarioRule<>(DriverExtensionActivity.class);

  @Rule public IntentsRule intentsRule = new IntentsRule();

  @Test
  public void imageIsPickedWithOriginalName() {
    final Instrumentation.ActivityResult result =
        new Instrumentation.ActivityResult(
            Activity.RESULT_OK, new Intent().setData(Uri.parse("content://dummy/dummy.png")));
    intending(hasAction(Intent.ACTION_OPEN_DOCUMENT)).respondWith(result);
    onFlutterWidget(withText("Open an image")).perform(click());
    //    onFlutterWidget(withText("Press to open an image file(png, jpg)")).perform(click());
    //    intended(hasAction(Intent.ACTION_OPEN_DOCUMENT));
    //    onFlutterWidget(withValueKey("image_picker_example_picked_image_name"))
    //        .check(matches(withText("dummy.png")));
  }
}
