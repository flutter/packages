// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import androidx.browser.customtabs.CustomTabsIntent;
import io.flutter.plugins.urllauncher.Messages.WebViewOptions;

public interface CustomTabsIntentFactory {
  CustomTabsIntent getCustomTabsIntent(WebViewOptions options);
}