// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.file_selector_android_example;

import static androidx.test.espresso.flutter.EspressoFlutter.onFlutterWidget;
import static androidx.test.espresso.flutter.action.FlutterActions.click;
import static androidx.test.espresso.flutter.assertion.FlutterAssertions.matches;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.isExisting;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withText;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withValueKey;
import static androidx.test.espresso.intent.Intents.intended;
import static androidx.test.espresso.intent.Intents.intending;
import static androidx.test.espresso.intent.matcher.IntentMatchers.hasAction;
import static androidx.test.espresso.intent.matcher.IntentMatchers.hasExtra;

import android.app.Activity;
import android.app.Instrumentation;
import android.content.ClipData;
import android.content.Intent;
import android.net.Uri;
import androidx.test.espresso.intent.rule.IntentsRule;
import androidx.test.ext.junit.rules.ActivityScenarioRule;
import org.junit.Rule;
import org.junit.Test;

public class FileSelectorAndroidTest {
  @Rule
  public ActivityScenarioRule<DriverExtensionActivity> myActivityTestRule =
      new ActivityScenarioRule<>(DriverExtensionActivity.class);

  @Rule public IntentsRule intentsRule = new IntentsRule();

  @Test
  public void openImageFile() {
    final Instrumentation.ActivityResult result =
        new Instrumentation.ActivityResult(
            Activity.RESULT_OK,
            new Intent().setData(Uri.parse("content://file_selector_android_test/dummy.png")));
    intending(hasAction(Intent.ACTION_OPEN_DOCUMENT)).respondWith(result);
    onFlutterWidget(withText("Open an image")).perform(click());
    onFlutterWidget(withText("Press to open an image file(png, jpg)")).perform(click());
    intended(hasAction(Intent.ACTION_OPEN_DOCUMENT));
    onFlutterWidget(withValueKey("result_image_name"))
        .check(matches(withText("content://file_selector_android_test/dummy.png")));
  }

  @Test
  public void openImageFiles() {
    final ClipData.Item clipDataItem =
        new ClipData.Item(Uri.parse("content://file_selector_android_test/dummy.png"));
    final ClipData clipData = new ClipData("", new String[0], clipDataItem);
    clipData.addItem(clipDataItem);

    final Intent resultIntent = new Intent();
    resultIntent.setClipData(clipData);

    final Instrumentation.ActivityResult result =
        new Instrumentation.ActivityResult(Activity.RESULT_OK, resultIntent);
    intending(hasAction(Intent.ACTION_OPEN_DOCUMENT)).respondWith(result);
    onFlutterWidget(withText("Open multiple images")).perform(click());
    onFlutterWidget(withText("Press to open multiple images (png, jpg)")).perform(click());

    intended(hasAction(Intent.ACTION_OPEN_DOCUMENT));
    intended(hasExtra(Intent.EXTRA_ALLOW_MULTIPLE, true));

    onFlutterWidget(withValueKey("result_image_name0")).check(matches(isExisting()));
    onFlutterWidget(withValueKey("result_image_name1")).check(matches(isExisting()));
  }
}
