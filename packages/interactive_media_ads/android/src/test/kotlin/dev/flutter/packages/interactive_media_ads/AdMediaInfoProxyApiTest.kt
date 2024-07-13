// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.player.AdMediaInfo
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.Mockito
import org.mockito.kotlin.whenever

class AdMediaInfoProxyApiTest {
  @Test
  fun url() {
    val api = TestProxyApiRegistrar().getPigeonApiAdMediaInfo()

    val instance = Mockito.mock<AdMediaInfo>()
    whenever(instance.url).thenReturn("url")

    assertEquals("url", api.url(instance))
  }
}
