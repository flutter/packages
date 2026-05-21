// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.urllauncher;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import android.os.Bundle;
import androidx.test.core.app.ApplicationProvider;
import java.util.Collections;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.Robolectric;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class WebViewActivityTest {

  @Test
  public void extractHeaders_returnsEmptyMapWhenHeadersBundleNull() {
    assertEquals(WebViewActivity.extractHeaders(null), Collections.emptyMap());
  }

  @Test
  public void onCreate_webviewIsNotNull() {
    WebViewActivity activity =
        Robolectric.buildActivity(
                WebViewActivity.class,
                WebViewActivity.createIntent(
                    ApplicationProvider.getApplicationContext(),
                    "https://flutter.dev",
                    false,
                    false,
                    new Bundle()))
            .create()
            .get();

    assertNotNull(activity.webview);
  }
}