// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.urllauncher

import org.junit.Assert.assertEquals
import org.junit.Test

class WebViewActivityTest {
  @Test
  fun extractHeaders_returnsEmptyMapWhenHeadersBundleNull() {
    assertEquals(WebViewActivity.extractHeaders(null), emptyMap<String, String>())
  }
}
